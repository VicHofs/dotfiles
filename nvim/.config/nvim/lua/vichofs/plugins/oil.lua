return {
	"stevearc/oil.nvim",
    -- enabled = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"refractalize/oil-git-status.nvim",
	},
	config = function()
			require("oil").setup({
            default_file_explorer = true, -- start up nvim with oil instead of netrw
			columns = { "icon" },
			watch_for_changes = true,
			win_options = {
				signcolumn = "yes:2",
			},
			keymaps = {
				["<C-h>"] = false,
                ["<C-c>"] = false, -- prevent from closing Oil as <C-c> is esc key
				["<M-h>"] = "actions.select_split",
                ["q"] = "actions.close",
			},
            delete_to_trash = true,
			view_options = {
				show_hidden = true,
			},
            skip_confirm_for_simple_edits = true,
		})

		require("oil-git-status").setup({
			show_ignored = true,
			symbols = {
				index = {
					["!"] = "",
					["?"] = "",
					["A"] = "✚",
					["C"] = "󰁕",
					["D"] = "✖",
					["M"] = "",
					["R"] = "󰁕",
					["T"] = "T",
					["U"] = "",
					[" "] = " ",
				},
				working_tree = {
					["!"] = "",
					["?"] = "",
					["A"] = "✚",
					["C"] = "󰁕",
					["D"] = "✖",
					["M"] = "󰄱",
					["R"] = "󰁕",
					["T"] = "T",
					["U"] = "",
					[" "] = " ",
				},
			},
		})

		local git_highlights = {
			OilGitStatusIndexAdded = "NeoTreeGitAdded",
			OilGitStatusWorkingTreeAdded = "NeoTreeGitAdded",
			OilGitStatusIndexCopied = "NeoTreeGitRenamed",
			OilGitStatusWorkingTreeCopied = "NeoTreeGitRenamed",
			OilGitStatusIndexDeleted = "NeoTreeGitDeleted",
			OilGitStatusWorkingTreeDeleted = "NeoTreeGitDeleted",
			OilGitStatusIndexIgnored = "NeoTreeGitIgnored",
			OilGitStatusWorkingTreeIgnored = "NeoTreeGitIgnored",
			OilGitStatusIndexModified = "NeoTreeGitStaged",
			OilGitStatusWorkingTreeModified = "NeoTreeGitUnstaged",
			OilGitStatusIndexRenamed = "NeoTreeGitRenamed",
			OilGitStatusWorkingTreeRenamed = "NeoTreeGitRenamed",
			OilGitStatusIndexTypeChanged = "NeoTreeGitModified",
			OilGitStatusWorkingTreeTypeChanged = "NeoTreeGitModified",
			OilGitStatusIndexUnmerged = "NeoTreeGitConflict",
			OilGitStatusWorkingTreeUnmerged = "NeoTreeGitConflict",
			OilGitStatusIndexUntracked = "NeoTreeGitUntracked",
			OilGitStatusWorkingTreeUntracked = "NeoTreeGitUntracked",
		}

		for target, source in pairs(git_highlights) do
			local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = source, link = false })
			if ok and hl then
				hl.default = nil
				vim.api.nvim_set_hl(0, target, hl)
			end
		end

		-- opens parent dir over current active window
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		-- open parent dir in float window
		vim.keymap.set("n", "<leader>-", require("oil").toggle_float)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil", -- Adjust if Oil uses a specific file type identifier
            callback = function()
                vim.opt_local.cursorline = true
            end,
        })
	end,

}
