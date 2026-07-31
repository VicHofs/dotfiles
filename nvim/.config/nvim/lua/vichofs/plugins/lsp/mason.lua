return {
    "mason-org/mason.nvim",
    lazy = false,
    dependencies = {
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "saghen/blink.cmp",
        "neovim/nvim-lspconfig",
        -- "saghen/blink.cmp",
    },
    config = function()
        -- import mason and mason_lspconfig
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            automatic_enable = false,
            -- servers for mason to install
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "html",
                "cssls",
                "tailwindcss",
                "gopls",
                "angularls",
                "astro",
                "emmet_ls",
                "emmet_language_server",
                "marksman",
            },
        })

		mason_tool_installer.setup({
			ensure_installed = {
				"biome",
				"markdownlint-cli2",
				"markdown-toc",
				"mdformat",
				"prettier", -- prettier formatter
				"stylua",   -- lua formatter
				"isort",    -- python formatter
				"pylint",
				"cpplint",
				"clang-format",
				"clangd",
				"denols",
			},

            -- NOTE: mason BREAKING Change! Removed setup_handlers
            -- moved lsp configuration settings back into lspconfig.lua file
        })
    end,
}
