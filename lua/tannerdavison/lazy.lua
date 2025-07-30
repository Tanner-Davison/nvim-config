local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "tannerdavison.plugins" }, { import = "tannerdavison.plugins.lsp" } }, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  -- Performance optimizations
  performance = {
    rtp = {
      reset = false,
      paths = {},
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
      },
    },
  },
  -- Reduce startup time
  concurrency = 20,
  git = {
    timeout = 120,
  },
  install = {
    colorscheme = { "tokyonight" },
  },
})
