return {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      lazy = true,  -- Keeps it efficient
      opts = {
        enable_autocmd = false,  -- Let Comment.nvim handle triggering
      },
    },
    {
      "numToStr/Comment.nvim",
      dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
      keys = {
        { "gc", mode = { "n", "v" } },
        { "gb", mode = { "n", "v" } },
        { "gcc", mode = "n" },
        { "gbc", mode = "n" },
      },
      opts = function()
        return {
          padding = true,
          sticky = true,
          ignore = "^$",
          pre_hook = function(ctx)
            local ts_pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
            local commentstring = ts_pre_hook(ctx)

            if commentstring and commentstring ~= "" then
              return commentstring
            end

            return vim.bo.commentstring ~= "" and vim.bo.commentstring or "# %s"
          end,
        }
      end,
    }
}
