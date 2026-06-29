return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		local eslint = lint.linters.eslint_d

		local function executable_linter(binary, local_path)
			if vim.fn.executable(binary) == 1 then
				return true
			end
			return local_path and vim.loop.fs_stat(vim.fn.getcwd() .. local_path) ~= nil
		end

		local js_linters = {}
		if executable_linter("biome", "/node_modules/.bin/biome") then
			js_linters = { "biomejs" }
		elseif executable_linter("eslint_d", "/node_modules/.bin/eslint_d") then
			js_linters = { "eslint_d" }
		end

		-- if Eslint error configuration not found : change MasonInstall eslint@version or npm i -g eslint at a specific version
		lint.linters_by_ft = {
			javascript = js_linters,
			typescript = js_linters,
			javascriptreact = js_linters,
			typescriptreact = js_linters,
			svelte = js_linters,
			c = { "cpplint" },
			cpp = { "cpplint" },
			objc = { "cpplint" },
			objcpp = { "cpplint" },
			python = { "pylint" },
		}

		eslint.args = {
			"--no-warn-ignored",
			"--format",
			"json",
			"--stdin",
			"--stdin-filename",
			function()
                return vim.fn.expand("%:p")
			end,
		}

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
