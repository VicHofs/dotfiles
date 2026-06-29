local enabled = true

return {
	{
		"folke/which-key.nvim",
		enabled = enabled,
		event = "VeryLazy",
		opts = {
			preset = "modern",
			win = {
				width = 0.35,
				row = math.huge,
				col = math.huge,
			},
			layout = {
				width = { min = 20, max = 28 },
			},
			spec = {
				{ "<leader>p", group = "Picker" },
				{ "<leader>g", group = "Git" },
				{ "<leader>i", group = "i18n" },
				{ "<leader>9", group = "99" },
				{ "<leader>s", group = "Split/Search/Substitute" },
				{ "<leader>t", group = "Tabs/Toggle" },
				{ "<leader>f", group = "Find/File" },
				{ "<leader>l", group = "Lint/LSP" },
				{ "<leader>w", group = "Worktree" },
			},
		},
	},
}
