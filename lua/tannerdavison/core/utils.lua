local M = {}

-- Utility function to get the visual selection
function M.get_visual_selection()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)

	if n_lines == 1 then
		lines[1] = string.sub(lines[1], s_start[3], s_end[3])
	else
		lines[1] = string.sub(lines[1], s_start[3])
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
	end

	return table.concat(lines, "\n")
end

return M
