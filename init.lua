return {
  -- Configure AstroNvim updates
  updater = {
    remote = "origin",     -- remote to use
    channel = "stable",    -- "stable" or "nightly"
    version = "latest",    -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "nightly",    -- branch name (NIGHTLY ONLY)
    commit = nil,          -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil,     -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false,  -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_quit = false,     -- automatically quit the current session after a successful update
    remotes = {},          -- easily add new remotes to track
  },

  -- Set colorscheme to use
  colorscheme = "astrodark",

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true,     -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
        "volar",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here

  polish = function()
    -- create augroups to easily manage autocommands
    vim.api.nvim_create_augroup("file_associations", { clear = true })
    vim.api.nvim_create_augroup("kitty_background", { clear = true })

    -- assosciate Jenkinsfile with groovy filetype
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      desc = "associate Jenkinsfile with the .groovy file type",
      pattern = "Jenkinsfile",
      group = "file_associations",
      callback = function()
        vim.cmd("set filetype=groovy")
        vim.bo.shiftwidth = 4
        vim.bo.tabstop = 4
        vim.bo.expandtab = true
      end
    })

    -- change kitty background to nvim's background while in nvim, then revert back
    if vim.env.KITTY_LISTEN_ON then
      local cmd = require("astronvim.utils").cmd
      local function set_bg(color) cmd { "kitty", "@", "set-colors", ("background=%s"):format(color) } end

      local orig_bg = "#300a24" -- hardcoded terminal fallback

      for _, color in ipairs(vim.fn.split(cmd { "kitty", "@", "get-colors" } or "", "\n")) do
        local current_bg = color:match "^background%s+(#[0-9a-fA-F]+)$"

        if current_bg then
          orig_bg = current_bg
          break
        end
      end

      local augroup = vim.api.nvim_create_augroup("kitty_background", { clear = true })

      vim.api.nvim_create_autocmd("User", {
        desc = "set kitty background to colorscheme's background",
        -- triggered when colorscheme is changed and `highlights` table is applied
        pattern = "AstroColorScheme", -- pattern is name of our User autocommand events
        group = augroup,              -- add autocmd to augroup
        callback = function()
          local bg_color = require("astronvim.utils").get_hlgroup("Normal")
              .bg                                                                            -- easy utility to get highlight group
          if not bg_color then return end                                                    -- if no Normal background color is set the do nothing
          if type(bg_color) == "number" then bg_color = string.format("#%06x", bg_color) end -- if number, make string

          set_bg(bg_color)
        end,
      })

      vim.api.nvim_create_autocmd("VimLeave", {
        desc = "set kitty background back to original background",
        group = augroup, -- add autocmd to augroup
        callback = function() set_bg(orig_bg) end,
      })
    end
  end,
}
