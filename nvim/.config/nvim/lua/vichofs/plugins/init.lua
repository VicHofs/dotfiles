return {
	"nvim-lua/plenary.nvim", --lua functions that many plugins use
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		cond = function()
			return vim.env.TMUX ~= nil
				and vim.env.TMUX ~= ""
				and (vim.env.HERDR_PANE_ID == nil or vim.env.HERDR_PANE_ID == "")
		end,
	},
	{
		"paulbkim-dev/vim-herdr-navigation",
		lazy = false,
		cond = function()
			return vim.env.HERDR_PANE_ID ~= nil and vim.env.HERDR_PANE_ID ~= ""
		end,
		config = function(plugin)
			dofile(plugin.dir .. "/editor/nvim.lua")
		end,
	},
    -- fixes the well know nvim bug
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                {
                    path = "${3rd}/plenary.nvim/lua",
                    words = { "plenary" }
                },
            },
        },
    },
  }
