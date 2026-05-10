return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
			local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })

			require("bufferline").setup({
				options = {
					mode = "tabs",
					show_tab_indicators = false,
					show_buffer_close_icons = false,
					show_close_icon = false,
					always_show_bufferline = true,
					separator_style = "thin",
				},
				highlights = {
					fill = {
						bg = "NONE",
					},
					background = {
						fg = comment.fg,
						bg = "NONE",
						italic = false,
					},
					buffer_visible = {
						fg = comment.fg,
						bg = "NONE",
					},
					buffer_selected = {
						fg = normal.fg,
						bg = "NONE",
						bold = true,
						italic = false,
					},
					modified = {
						fg = comment.fg,
						bg = "NONE",
					},
					modified_visible = {
						fg = comment.fg,
						bg = "NONE",
					},
					modified_selected = {
						fg = normal.fg,
						bg = "NONE",
					},
					separator = {
						fg = comment.fg,
						bg = "NONE",
					},
					separator_visible = {
						fg = comment.fg,
						bg = "NONE",
					},
					separator_selected = {
						fg = comment.fg,
						bg = "NONE",
					},
					indicator_selected = {
						fg = "NONE",
						bg = "NONE",
					},
					indicator_visible = {
						fg = "NONE",
						bg = "NONE",
					},
				},
			})

			vim.keymap.set("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab" })
			vim.keymap.set("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
		end,
	},
}
