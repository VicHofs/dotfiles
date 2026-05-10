local enabled = true

return {
	{
		"chentoast/marks.nvim",
		enabled = enabled,
		event = "VeryLazy",
		opts = {
			default_mappings = false,
			builtin_marks = { ".", "<", ">", "^" },
		},
	},
}
