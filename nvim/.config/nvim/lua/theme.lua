--[[===========================================================================
  theme.lua — colorscheme selection
  ============================================================================

  Current choice: Catppuccin, in the Latte (light) and Macchiato (dark)
  flavours used by every other tool in this repo — Ghostty, bat, Zed and
  delta all name the same pair, so one palette follows you from the terminal
  to the editor to a git diff.

  WHY THIS FILE DECLARES ITS OWN PLUGIN
    init.lua loads this module BEFORE lua/plugins/, so a plain
    require("catppuccin") here would fail on a cold clone — the plugin would
    not be on the runtimepath yet. Rather than reorder the config and make
    every other module's loading depend on the colorscheme, this file calls
    vim.pack.add() itself. Adding a plugin twice is a no-op (the first call
    wins), so listing it here and in lua/plugins/init.lua would be harmless —
    but it is declared only here, next to the code that needs it.

  THE `name` KEY IS REQUIRED
    vim.pack derives a plugin's directory from the last segment of its URL.
    For catppuccin/nvim that segment is literally "nvim", which would install
    it as a plugin called "nvim". `name = "catppuccin"` fixes that, and is
    what makes require("catppuccin") resolve.

  HOW TO SWITCH THEMES — three steps:

    1. Change the `src` and `name` in the vim.pack.add() call below, e.g.:
         { src = "https://github.com/rebelot/kanagawa.nvim", name = "kanagawa" }

    2. Replace the setup() block with whatever that theme needs, or delete it
       if it needs none.

    3. Change the single variable below, e.g.:
         local colorscheme = "kanagawa"

    To go back to a built-in that needs no plugin at all — "default",
    "habamax", "retrobox", "sorbet", "slate" — delete the vim.pack.add() and
    setup() blocks entirely and just set the variable. (:h colorscheme, then
    :colorscheme <Tab> to browse.)

  Light/dark: `flavour = "auto"` makes Catppuccin read vim.o.background, so it
  flips between Latte and Macchiato exactly as the built-in default scheme did.
  Neovim under Neovide and modern terminals detects the OS appearance; force it
  with `vim.o.background = "light"` (or "dark") above the colorscheme line.
  lualine (plugins/statusline.lua) uses theme = "auto" and follows along.
===========================================================================]]--

local colorscheme = "catppuccin"

-- WHAT: Install and load the colorscheme plugin.
-- WHY : Wrapped in pcall so a network failure or a missing plugin degrades to
--       the built-in default with a warning, rather than aborting the whole
--       config before options, keymaps and LSP have loaded.
pcall(function()
    vim.pack.add({
        { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    })

    require("catppuccin").setup({
        -- WHAT: Which flavour to use. "auto" picks from `background`.
        -- WHY : Keeps the light/dark following the rest of the stack has.
        -- HOW : Pin one of "latte", "frappe", "macchiato", "mocha" instead if
        --       you never switch appearance.
        flavour = "auto",
        background = {
            light = "latte",
            dark = "macchiato",
        },
    })
end)

-- pcall so a typo or a not-yet-installed theme plugin degrades to a warning
-- instead of aborting the rest of the config load.
local ok = pcall(vim.cmd.colorscheme, colorscheme)
if not ok then
    vim.notify(("theme.lua: colorscheme %q not found, using default"):format(colorscheme), vim.log.levels.WARN)
end
