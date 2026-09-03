--[[===========================================================================
  theme.lua — colorscheme selection
  ============================================================================

  Catppuccin, in the Latte (light) and Mocha (dark) flavours the rest of the
  stack uses; see ../../../../README.md § Light and dark.

  WHY THIS FILE DECLARES ITS OWN PLUGIN
    The init.lua entry point loads this module before lua/plugins/, so a plain
    require("catppuccin") would fail on a fresh clone: the plugin is not on
    the runtimepath yet. This file therefore calls vim.pack.add() itself.
    Adding a plugin twice is a no-op, the first call winning, so it could
    also be listed in lua/plugins/init.lua; it is declared only here, next
    to the code that needs it.

  THE `name` KEY IS REQUIRED
    The vim.pack manager names a plugin's directory after the last segment
    of its URL, which for catppuccin/nvim is "nvim". `name = "catppuccin"`
    gives the directory the name require("catppuccin") looks for.

  HOW TO SWITCH THEMES
    Change `src` and `name` in vim.pack.add() (e.g.
    { src = "https://github.com/rebelot/kanagawa.nvim", name = "kanagawa" }),
    replace or delete the setup() block, and change the `colorscheme`
    variable. For a built-in scheme ("default", "habamax", "retrobox",
    "sorbet", "slate") delete the vim.pack.add() and setup() blocks and set the
    variable; `:colorscheme <Tab>` lists them.

  Light and dark: `flavour = "auto"` reads vim.o.background, which Neovide and
  modern terminals set from the OS appearance. Force one with
  `vim.o.background = "light"` (or "dark") above the colorscheme line. lualine
  (plugins/statusline.lua) uses theme = "auto" and follows.
===========================================================================]]--

-- WHAT: The colorscheme name passed to :colorscheme below.
-- WHY : One variable, so switching themes changes one line plus the plugin
--       spec.
local colorscheme = "catppuccin"

-- WHAT: Install and configure the colorscheme plugin.
-- WHY : Wrapped in pcall so a network failure or a missing plugin leaves the
--       built-in default with a warning instead of aborting the rest of the
--       config (options, keymaps, LSP) before it loads.
pcall(function()
    vim.pack.add({
        { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    })

    require("catppuccin").setup({
        -- WHAT: Which flavour to use; "auto" picks from `background`.
        -- WHY : Follows the appearance with the rest of the stack.
        -- HOW : Pin one of "latte", "frappe", "macchiato", "mocha" to ignore
        --       the appearance.
        flavour = "auto",
        background = {
            light = "latte",
            dark = "mocha",
        },
    })
end)

-- WHAT: Apply the colorscheme.
-- WHY : Wrapped in pcall for the same reason as above: a misspelt or
--       uninstalled theme warns instead of aborting the load.
local ok = pcall(vim.cmd.colorscheme, colorscheme)
if not ok then
    vim.notify(("theme.lua: colorscheme %q not found, using default"):format(colorscheme), vim.log.levels.WARN)
end
