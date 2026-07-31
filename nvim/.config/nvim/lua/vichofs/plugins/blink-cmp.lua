return {
	"saghen/blink.cmp",
	version = "v1.*",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
		},
		"rafamadriz/friendly-snippets",
	},
	opts = {
		fuzzy = {
			implementation = "prefer_rust",
		},
		keymap = {
			preset = "default",
		},
		completion = {
			menu = {
				auto_show = true,
			},
			documentation = {
				auto_show = true,
			},
			ghost_text = {
				enabled = false,
				show_with_menu = false,
			},
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
		},
		cmdline = {
			enabled = true,
			keymap = { preset = "cmdline" },
			completion = {
				menu = { auto_show = true },
			},
		},
		sources = {
			default = { "lsp", "path", "buffer", "snippets" },
			providers = {
				lsp = {
					opts = {
						tailwind_color_icon = "󱓻",
					},
				},
			},
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		snippets = {
			preset = "luasnip",
		},
	},
	config = function(_, opts)
		require("blink.cmp").setup(opts)
		require("luasnip.loaders.from_vscode").lazy_load()
	end,
}
