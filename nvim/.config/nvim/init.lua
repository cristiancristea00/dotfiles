--[[===========================================================================
  init.lua — entry point
  ============================================================================

  This file only does two things:

    1. Set the leader keys (MUST happen before anything creates keymaps or
       plugins are loaded, otherwise mappings would bind to the old leader).
    2. Load the config modules in a deliberate, documented order.

  Layout of this configuration:

    init.lua                  <- you are here
    lua/core/options.lua      -- editor options (every option documented)
    lua/core/keymaps.lua      -- plugin-independent keymaps
    lua/core/autocmds.lua     -- plugin-independent autocommands
    lua/core/diagnostics.lua  -- diagnostic display (virtual text, signs, ...)
    lua/core/filetypes.lua    -- filetype detection rules (from languages.lua)
    lua/core/neovide.lua      -- font + everything Neovide-specific
    lua/theme.lua             -- colorscheme selection (single-variable switch)
    lua/languages.lua         -- THE language table: add/remove languages here
    lua/plugins/init.lua      -- plugin declarations (vim.pack) + module loading
    lua/plugins/*.lua         -- one configuration module per plugin
    after/lsp/*.lua           -- per-server LSP overrides (native format;
                                 after/ makes them win over plugin defaults)

  How loading works:
    `require("core.options")` etc. finds files on Neovim's runtimepath under
    lua/, so lua/core/options.lua <=> require("core.options"). Files in
    after/lsp/ are NOT require()d — Neovim's native LSP loader (:h lsp-config)
    picks them up automatically and merges them on top of the defaults that
    the nvim-lspconfig plugin provides (the after/ prefix gives them
    priority, :h lsp-config-merge).
===========================================================================]]--

-- Leader keys ----------------------------------------------------------------
-- WHAT: <leader> is the prefix used by most custom mappings (e.g. <leader>ff).
-- WHY : Space is the de-facto community standard (LazyVim, kickstart, ...);
--       it is comfortable under either thumb and does nothing useful in
--       normal mode by default. `maplocalleader` is the buffer-local variant
--       used by some filetype plugins; keeping it distinct (backslash) avoids
--       collisions with global <leader> maps.
-- HOW : Change these two lines; every <leader> mapping follows automatically.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Core (plugin-independent — the config still works if plugins/ is deleted) --
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.diagnostics")
require("core.filetypes")
require("core.neovide")

-- Colorscheme (before plugins so plugin UIs pick up the final highlights) ----
require("theme")

-- Plugins (vim.pack declarations + per-plugin configuration modules) ---------
require("plugins")
