return {
	{
		"Bekaboo/dropbar.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local sources = require("dropbar.sources")

			require("dropbar").setup({
				bar = {
					enable = function(buf, win, _)
						buf = vim._resolve_bufnr(buf)
						if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
							return false
						end

						if vim.fn.win_gettype(win) ~= "" or vim.wo[win].winbar ~= "" then
							return false
						end

						if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "help" then
							return false
						end

						return vim.api.nvim_buf_get_name(buf) ~= ""
					end,
					sources = function(_buf, _win)
						return { sources.path }
					end,
				},
			})
		end,
	},
}
