--[[===========================================================================
  init.lua — entry point
  ============================================================================

  Sets the leader keys, then loads the modules in a fixed order.

  Layout:

    init.lua                  <- this file
    lua/core/options.lua      -- editor options
    lua/core/keymaps.lua      -- plugin-independent keymaps
    lua/core/autocmds.lua     -- plugin-independent autocommands
    lua/core/diagnostics.lua  -- diagnostic display (virtual text, signs, ...)
    lua/core/filetypes.lua    -- filetype detection rules (from languages.lua)
    lua/core/neovide.lua      -- font and everything Neovide-specific
    lua/theme.lua             -- colorscheme selection
    lua/languages.lua         -- the language table: add or remove languages here
    lua/plugins/init.lua      -- plugin declarations (vim.pack) and module loading
    lua/plugins/*.lua         -- one configuration module per plugin
    after/lsp/*.lua           -- per-server LSP overrides (see plugins/lsp.lua)

  `require("core.options")` finds lua/core/options.lua on the runtimepath.
  Files in after/lsp/ are not required; Neovim's LSP loader merges them over
  nvim-lspconfig's defaults (plugins/lsp.lua explains the after/ prefix).
===========================================================================]]--

-- Leader keys ----------------------------------------------------------------
-- WHAT: <leader> is the prefix for most custom mappings (e.g. <leader>ff);
--       `maplocalleader` is the buffer-local variant some filetype plugins use.
-- WHY : Space is the common choice (LazyVim, kickstart) and does nothing
--       useful in normal mode by default. Backslash for the local leader keeps
--       buffer-local maps out of the <leader> namespace. Both must be set
--       before any keymap or plugin is loaded, or those mappings bind to the
--       old leader.
-- HOW : Change these two lines; every <leader> mapping follows.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Core (plugin-independent) --------------------------------------------------
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.diagnostics")
require("core.filetypes")
require("core.neovide")

-- Colorscheme (before plugins so plugin UIs pick up the final highlights) ----
require("theme")

-- Plugins (vim.pack declarations and per-plugin configuration modules) -------
require("plugins")
