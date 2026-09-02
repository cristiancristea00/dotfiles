--[[===========================================================================
  theme.lua — colorscheme selection
  ============================================================================

  Current choice: Neovim's built-in default colorscheme. It was redesigned in
  0.10+ (dark/light aware via 'background', full treesitter + LSP semantic
  highlight support) and needs no plugin.

  HOW TO SWITCH THEMES — three steps:

    1. Add the theme plugin in lua/plugins/init.lua, in the vim.pack.add()
       list, e.g.:
         { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

    2. If the theme needs setup() options, call it here BEFORE the colorscheme
       line, e.g.:
         require("catppuccin").setup({ flavour = "mocha" })

    3. Change the single variable below, e.g.:
         local colorscheme = "catppuccin"

    Built-in alternatives that need no plugin at all: "habamax", "retrobox",
    "sorbet", "slate", ... (:h colorscheme, then :colorscheme <Tab> to browse).
    lualine (plugins/statusline.lua) uses theme = "auto" and follows along.

  Light/dark: the default scheme follows vim.o.background. Neovim under
  Neovide/modern terminals detects the OS appearance; force it with
  `vim.o.background = "light"` (or "dark") above the colorscheme line.
===========================================================================]]--

local colorscheme = "default"

-- pcall so a typo or a not-yet-installed theme plugin degrades to a warning
-- instead of aborting the rest of the config load.
local ok = pcall(vim.cmd.colorscheme, colorscheme)
if not ok then
    vim.notify(("theme.lua: colorscheme %q not found, using default"):format(colorscheme), vim.log.levels.WARN)
end
