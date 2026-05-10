return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				enable_git_status = true,
				enable_diagnostics = true,
				filesystem = {
					hijack_netrw_behavior = "disabled",
					use_libuv_file_watcher = true,
					follow_current_file = {
						enabled = true,
						leave_dirs_open = false,
					},
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
					},
				},
				window = {
					position = "left",
					width = 32,
				},
			})

			vim.keymap.set("n", "<leader>ee", "<cmd>Neotree toggle filesystem reveal left<CR>", { desc = "Toggle file explorer" })
			vim.keymap.set("n", "<leader>ef", "<cmd>Neotree focus filesystem reveal left<CR>", { desc = "Reveal current file in explorer" })
		end,
	},
}
