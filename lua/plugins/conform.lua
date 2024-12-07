---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Set nixfmt as the default formatter for .nix files, removing alejandra
      opts.formatters_by_ft = {
        nix = { "nixfmt", stop_after_first = true },
      }
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local builtins = require("null-ls").builtins
      -- Remove alejandra and add nixfmt as the formatter for nix files
      opts.sources = require("astrocore").list_insert_unique(opts.sources, {
        builtins.formatting.nixfmt,
      })
      -- Remove any previous references to alejandra if they exist
      opts.sources = vim.tbl_filter(function(source) return source.name ~= "alejandra" end, opts.sources)
    end,
  },
}
