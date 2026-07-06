return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local treesitter = require("nvim-treesitter")

            local parsers = {
                "json",
                "javascript",
                "typescript",
                "tsx",
                "go",
                "yaml",
                "html",
                "css",
                "python",
                "http",
                "prisma",
                "markdown",
                "markdown_inline",
                "svelte",
                "graphql",
                "bash",
                "lua",
                "vim",
                "dockerfile",
                "gitignore",
                "query",
                "vimdoc",
                "c",
                "java",
                "rust",
                "ron",
            }

            treesitter.setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            treesitter.install(parsers)

            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    if pcall(vim.treesitter.start) and type(treesitter.indentexpr) == "function" then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "V",
                    },
                    include_surrounding_whitespace = false,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")
            local swap = require("nvim-treesitter-textobjects.swap")
            local textobjects = "textobjects"

            vim.keymap.set({ "x", "o" }, "af", function()
                select.select_textobject("@function.outer", textobjects)
            end, { desc = "Select outer function" })
            vim.keymap.set({ "x", "o" }, "if", function()
                select.select_textobject("@function.inner", textobjects)
            end, { desc = "Select inner function" })
            vim.keymap.set({ "x", "o" }, "ac", function()
                select.select_textobject("@class.outer", textobjects)
            end, { desc = "Select outer class" })
            vim.keymap.set({ "x", "o" }, "ic", function()
                select.select_textobject("@class.inner", textobjects)
            end, { desc = "Select inner class" })
            vim.keymap.set({ "x", "o" }, "aa", function()
                select.select_textobject("@parameter.outer", textobjects)
            end, { desc = "Select outer argument" })
            vim.keymap.set({ "x", "o" }, "ia", function()
                select.select_textobject("@parameter.inner", textobjects)
            end, { desc = "Select inner argument" })

            vim.keymap.set("n", "<leader>a", function()
                swap.swap_next("@parameter.inner")
            end, { desc = "Swap next argument" })
            vim.keymap.set("n", "<leader>A", function()
                swap.swap_previous("@parameter.inner")
            end, { desc = "Swap previous argument" })

            vim.keymap.set({ "n", "x", "o" }, "]f", function()
                move.goto_next_start("@function.outer", textobjects)
            end, { desc = "Next function start" })
            vim.keymap.set({ "n", "x", "o" }, "[f", function()
                move.goto_previous_start("@function.outer", textobjects)
            end, { desc = "Previous function start" })
            vim.keymap.set({ "n", "x", "o" }, "]F", function()
                move.goto_next_end("@function.outer", textobjects)
            end, { desc = "Next function end" })
            vim.keymap.set({ "n", "x", "o" }, "[F", function()
                move.goto_previous_end("@function.outer", textobjects)
            end, { desc = "Previous function end" })
            vim.keymap.set({ "n", "x", "o" }, "]]", function()
                move.goto_next_start("@class.outer", textobjects)
            end, { desc = "Next class start" })
            vim.keymap.set({ "n", "x", "o" }, "[[", function()
                move.goto_previous_start("@class.outer", textobjects)
            end, { desc = "Previous class start" })
            vim.keymap.set({ "n", "x", "o" }, "][", function()
                move.goto_next_end("@class.outer", textobjects)
            end, { desc = "Next class end" })
            vim.keymap.set({ "n", "x", "o" }, "[]", function()
                move.goto_previous_end("@class.outer", textobjects)
            end, { desc = "Previous class end" })
        end,
    },
    -- NOTE: js,ts,jsx,tsx Auto Close Tags
    {
        "windwp/nvim-ts-autotag",
        enabled = true,
        ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
        config = function()
            -- Independent nvim-ts-autotag setup
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,           -- Auto-close tags
                    enable_rename = true,          -- Auto-rename pairs
                    enable_close_on_slash = false, -- Disable auto-close on trailing `</`
                },
                per_filetype = {
                    ["html"] = {
                        enable_close = true, -- Disable auto-closing for HTML
                    },
                    ["typescriptreact"] = {
                        enable_close = true, -- Explicitly enable auto-closing (optional, defaults to `true`)
                    },
                },
            })
        end,
    },
}
