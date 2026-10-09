-- Copyright 2026 Tanner Davison
-- Parallel Claude Code agents: one git worktree + one tmux window per task.
-- All keymaps live under <leader>y.
--
--   <leader>yv  Vasion (Bedrock) agent in a NEW worktree   (prompts for a task name)
--   <leader>yp  personal agent in a NEW worktree
--   <leader>yV  Vasion agent in the current directory (no worktree)
--   <leader>yP  personal agent in the current directory
--   <leader>yl  list agent windows and jump to one
--   <leader>yd  remove an agent worktree (refuses if it has uncommitted changes)
--
-- The launch commands mirror your shell setup. They run through `bash -c` because
-- aliases/functions from ~/.bashrc are not visible to a spawned process.
-- ANTHROPIC_API_KEY is unset so the Console key (exported for CodeCompanion) never
-- leaks into a Claude Code CLI session.

local M = {}

local SESSION = "agents" -- used only when Neovim is not already running inside tmux
local PREFIX = { vasion = "v", personal = "p" }

local PATH_FIX = 'export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"; unset ANTHROPIC_API_KEY; '

local BODIES = {
	-- mirrors the claude-vasion shell function: check SSO, re-login if expired, then launch
	vasion = [[P=it-sandbox-dev; ]]
		.. [[aws sts get-caller-identity --profile "$P" >/dev/null 2>&1 ]]
		.. [[|| { echo "AWS SSO expired for $P -- logging in..."; aws sso login --profile "$P"; }; ]]
		.. [[CLAUDE_CONFIG_DIR="$HOME/.claude-vasion" exec claude]],
	-- mirrors the my-claude alias
	personal = [[CLAUDE_CONFIG_DIR="$HOME/.my-claude" exec claude]],
}

-- Runs in the new tmux window BEFORE the agent starts, only for fresh worktrees.
-- Installs dependencies if node_modules is missing (picks the package manager from the
-- lockfile). A failed install does not stop the agent from starting.
local DEPS_SETUP = [[if [ -f package.json ] && [ ! -d node_modules ]; then ]]
	.. [[echo "Installing dependencies..."; ]]
	.. [[if [ -f pnpm-lock.yaml ]; then pnpm install; ]]
	.. [[elif [ -f yarn.lock ]; then yarn install; ]]
	.. [[elif [ -f package-lock.json ]; then npm ci; ]]
	.. [[else npm install; fi; ]]
	.. [[fi; ]]

local function build_script(kind, setup)
	return PATH_FIX .. (setup or "") .. BODIES[kind]
end

-- Copy untracked env files (.env.local etc.) from the main checkout into a worktree.
-- Never overwrites a file that already exists there.
local function copy_env_files(root, dest)
	local copied = {}
	for _, src in ipairs(vim.fn.glob(root .. "/.env*", true, true)) do
		local st = vim.uv.fs_stat(src)
		local target = vim.fs.joinpath(dest, vim.fs.basename(src))
		if st and st.type == "file" and not vim.uv.fs_stat(target) then
			if vim.uv.fs_copyfile(src, target) then
				table.insert(copied, vim.fs.basename(src))
			end
		end
	end
	return copied
end

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "agents" })
end

local function run(cmd)
	local res = vim.system(cmd, { text = true }):wait()
	return res.code == 0, vim.trim(res.stdout or ""), vim.trim(res.stderr or "")
end

local function in_tmux()
	return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function slugify(s)
	s = s:lower():gsub("[^%w_%-]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
	return s
end

-- Main repo root, even when Neovim was started inside one of the agent worktrees.
local function repo_root()
	local cwd = vim.fn.getcwd()
	local ok, common = run({ "git", "-C", cwd, "rev-parse", "--path-format=absolute", "--git-common-dir" })
	if ok and vim.fs.basename(common) == ".git" then
		return vim.fs.dirname(common)
	end
	local ok2, top = run({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
	if ok2 then
		return top
	end
end

local function create_worktree(root, slug)
	local path = vim.fs.joinpath(vim.fs.dirname(root), vim.fs.basename(root) .. "-" .. slug)
	local branch = "agent/" .. slug
	if vim.uv.fs_stat(path) then
		return path, "reused"
	end
	local branch_exists = run({ "git", "-C", root, "show-ref", "--verify", "--quiet", "refs/heads/" .. branch })
	local cmd = branch_exists and { "git", "-C", root, "worktree", "add", path, branch }
		or { "git", "-C", root, "worktree", "add", "-b", branch, path }
	local ok, _, err = run(cmd)
	if not ok then
		return nil, err
	end
	return path, "created"
end

local function launch(kind, dir, name, setup)
	if vim.fn.executable("tmux") == 0 then
		return notify("tmux is not installed or not on PATH", vim.log.levels.ERROR)
	end
	local win = PREFIX[kind] .. "-" .. name
	local script = build_script(kind, setup)
	local cmd
	if in_tmux() then
		cmd = { "tmux", "new-window", "-n", win, "-c", dir, "bash", "-c", script }
	elseif run({ "tmux", "has-session", "-t", SESSION }) then
		cmd = { "tmux", "new-window", "-t", SESSION .. ":", "-n", win, "-c", dir, "bash", "-c", script }
	else
		cmd = { "tmux", "new-session", "-d", "-s", SESSION, "-n", win, "-c", dir, "bash", "-c", script }
	end
	local ok, _, err = run(cmd)
	if not ok then
		return notify("tmux failed: " .. err, vim.log.levels.ERROR)
	end
	if in_tmux() then
		notify(("Started %s in %s"):format(win, dir))
	else
		notify(("Started %s in tmux session '%s'. Attach with: tmux attach -t %s"):format(win, SESSION, SESSION))
	end
end

-- Windows whose name looks like one of ours (v-<task> / p-<task>).
local function agent_windows()
	local ok, out = run({
		"tmux", "list-windows", "-a", "-F",
		"#{window_id}|#{session_name}|#{window_name}|#{pane_current_path}",
	})
	if not ok then
		return {}
	end
	local wins = {}
	for line in out:gmatch("[^\n]+") do
		local id, session, name, path = line:match("^(.-)|(.-)|(.-)|(.*)$")
		if id and name:match("^[vp]%-") then
			table.insert(wins, { id = id, session = session, name = name, path = path })
		end
	end
	return wins
end

function M.new(kind, use_worktree)
	if not use_worktree then
		local dir = vim.fn.getcwd()
		return launch(kind, dir, slugify(vim.fs.basename(dir)))
	end
	local root = repo_root()
	if not root then
		return notify("Not inside a git repository", vim.log.levels.WARN)
	end
	vim.ui.input({ prompt = "Task name (branch will be agent/<name>): " }, function(input)
		if not input or vim.trim(input) == "" then
			return
		end
		local slug = slugify(input)
		if slug == "" then
			return notify("Task name had no usable characters", vim.log.levels.WARN)
		end
		local path, state = create_worktree(root, slug)
		if not path then
			return notify("git worktree failed:\n" .. state, vim.log.levels.ERROR)
		end
		if state == "reused" then
			notify("Worktree already exists, reusing " .. path)
		end
		local copied = copy_env_files(root, path)
		if #copied > 0 then
			notify("Copied " .. table.concat(copied, ", ") .. " into the worktree")
		end
		launch(kind, path, slug, DEPS_SETUP)
	end)
end

function M.list()
	if vim.fn.executable("tmux") == 0 then
		return notify("tmux is not installed or not on PATH", vim.log.levels.ERROR)
	end
	local wins = agent_windows()
	if #wins == 0 then
		return notify("No agent windows running")
	end
	vim.ui.select(wins, {
		prompt = "Agent windows",
		format_item = function(w)
			return ("%s   %s"):format(w.name, w.path)
		end,
	}, function(w)
		if not w then
			return
		end
		if not in_tmux() then
			return notify(("Not inside tmux. Attach with: tmux attach -t %s"):format(w.session))
		end
		run({ "tmux", "select-window", "-t", w.id })
		run({ "tmux", "switch-client", "-t", w.session })
	end)
end

function M.remove()
	local root = repo_root()
	if not root then
		return notify("Not inside a git repository", vim.log.levels.WARN)
	end
	local ok, out, err = run({ "git", "-C", root, "worktree", "list", "--porcelain" })
	if not ok then
		return notify("git worktree list failed: " .. err, vim.log.levels.ERROR)
	end
	local trees = {}
	for block in (out .. "\n\n"):gmatch("(.-)\n\n") do
		local path = block:match("worktree ([^\n]+)")
		local branch = block:match("branch refs/heads/(agent/[^\n]+)")
		if path and branch then
			table.insert(trees, { path = path, branch = branch })
		end
	end
	if #trees == 0 then
		return notify("No agent worktrees (branches named agent/*) found")
	end
	vim.ui.select(trees, {
		prompt = "Remove which worktree?",
		format_item = function(t)
			return ("%s   %s"):format(t.branch, t.path)
		end,
	}, function(t)
		if not t then
			return
		end
		local choice = vim.fn.confirm(
			("Remove worktree?\n%s\n\nThe branch %s is kept."):format(t.path, t.branch),
			"&Yes\n&No",
			2
		)
		if choice ~= 1 then
			return
		end
		local removed, _, rerr = run({ "git", "-C", root, "worktree", "remove", t.path })
		if not removed then
			return notify(
				"Not removed (uncommitted changes?):\n" .. rerr .. "\nCommit or discard, then retry.",
				vim.log.levels.WARN
			)
		end
		for _, w in ipairs(agent_windows()) do
			if w.path:sub(1, #t.path) == t.path then
				run({ "tmux", "kill-window", "-t", w.id })
			end
		end
		notify(("Removed %s (branch %s kept)"):format(t.path, t.branch))
	end)
end

local map = vim.keymap.set
map("n", "<leader>yv", function() M.new("vasion", true) end, { desc = "Vasion agent in new worktree" })
map("n", "<leader>yp", function() M.new("personal", true) end, { desc = "Personal agent in new worktree" })
map("n", "<leader>yV", function() M.new("vasion", false) end, { desc = "Vasion agent here (no worktree)" })
map("n", "<leader>yP", function() M.new("personal", false) end, { desc = "Personal agent here (no worktree)" })
map("n", "<leader>yl", M.list, { desc = "List / jump to agent windows" })
map("n", "<leader>yd", M.remove, { desc = "Remove an agent worktree" })

return M
