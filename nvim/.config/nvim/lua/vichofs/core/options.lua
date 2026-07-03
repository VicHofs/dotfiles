-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0
-- vim.cmd("let g:netrw_liststyle = 3")
-- Disable netrw banner
vim.cmd("let g:netrw_banner = 0")

vim.opt.termguicolors = true
-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Hard wrap prose at 80 characters while typing.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "text" },
    callback = function()
        vim.opt_local.textwidth = 80
        vim.opt_local.formatoptions:append("t")
    end,
})

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.autoread = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- search
vim.opt.inccommand = "split"

-- UI
vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- folding (for nvim-ufo)
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldcolumn = "0"

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.guicursor = ""
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = ""
vim.opt.clipboard:append("unnamedplus")
vim.opt.mouse = "a"

local checktime_group = vim.api.nvim_create_augroup("vichofs-checktime", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
    group = checktime_group,
    callback = function()
        if vim.fn.mode() ~= "c" then
            vim.cmd("checktime")
        end
    end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = checktime_group,
    callback = function()
        vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
    end,
})
