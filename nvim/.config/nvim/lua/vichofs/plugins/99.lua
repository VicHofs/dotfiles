return {
	{
		"ThePrimeagen/99",
		config = function()
			local _99 = require("99")
			local cwd = vim.uv.cwd()
			local basename = vim.fs.basename(cwd)
			local log_path = vim.fn.tempname() .. "." .. basename .. ".99.debug"

			_99.setup({
				logger = {
					level = _99.DEBUG,
					path = log_path,
					print_on_error = true,
				},
				tmp_dir = "./tmp",
				completion = {
					source = "native",
				},
				md_files = {
					"AGENT.md",
				},
			})

			vim.keymap.set("v", "<leader>9v", function()
				_99.visual()
			end, { desc = "99 visual prompt" })

			vim.keymap.set("n", "<leader>9x", function()
				_99.stop_all_requests()
			end, { desc = "99 stop requests" })

			vim.keymap.set("n", "<leader>9s", function()
				_99.search()
			end, { desc = "99 search project" })
		end,
	},
}
