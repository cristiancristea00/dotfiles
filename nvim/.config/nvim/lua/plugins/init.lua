--[[===========================================================================
  plugins/init.lua — plugin declarations (vim.pack) + module loading
  ============================================================================

  This config uses Neovim 0.12's BUILT-IN plugin manager, vim.pack (:h vim.pack).
  No bootstrap code is needed: the first `vim.pack.add()` call clones anything
  missing (confirmation prompt on first install), records exact versions in
  nvim-pack-lock.json next to init.lua (commit that file!), and loads the
  plugins immediately.

  Daily driving:
    :lua vim.pack.update()          -- fetch updates, review them in a buffer,
                                       :write to apply, :quit to reject
    :lua vim.pack.update(nil, { target = "lockfile" })
                                    -- roll everything back to the lockfile
    :lua vim.pack.del({ "name" })   -- remove a plugin's files (after deleting
                                       its spec below, or it reinstalls)
    :checkhealth vim.pack           -- diagnose install/lockfile issues

  ── ADD A PLUGIN ────────────────────────────────────────────────────────────
    1. Append a spec to the vim.pack.add() list below.
         "https://github.com/user/repo"                     -- simplest form
         { src = "…", version = "branch-or-tag" }           -- pinned
         { src = "…", version = vim.version.range("*") }    -- latest release tag
    2. Create lua/plugins/<name>.lua with its setup()/keymaps, documented.
    3. require() it at the bottom of this file.
    Deleting a plugin is the same three places in reverse, then :lua
    vim.pack.del({ "<name>" }).

  DESIGN NOTE — no lazy loading: everything loads eagerly at startup. With
  this plugin count, startup stays well under ~100ms, and eager loading
  removes an entire class of "plugin X wasn't loaded yet" bugs. vim.pack's
  author recommends lazy-loading only sparingly. If startup ever feels slow,
  measure first: `nvim --startuptime /tmp/st.log`.
===========================================================================]]--

-- Hooks must exist BEFORE vim.pack.add() so they also fire for first-time
-- installs happening inside that very call.
vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("cfg_pack_hooks", { clear = true }),
    desc = "Recompile treesitter parsers when nvim-treesitter is installed/updated",
    callback = function(ev)
        -- Parsers are compiled artifacts tied to the plugin version; stale ones
        -- break highlighting, so resync them on every install/update.
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind ~= "delete" then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.schedule(function()
                vim.cmd("TSUpdate")
            end)
        end
    end,
})

vim.pack.add({
    -- ── LSP ──────────────────────────────────────────────────────────────────
    -- Data-only on 0.11+: provides default configs (cmd/filetypes/root markers)
    -- for ~400 servers, consumed by the NATIVE vim.lsp.enable() API. Our
    -- overrides live in this config's lsp/*.lua. See plugins/lsp.lua.
    "https://github.com/neovim/nvim-lspconfig",

    -- ── Treesitter (syntax highlighting / indent / folds) ────────────────────
    -- The rewritten "main" branch (requires Neovim 0.12; old "master" is
    -- frozen). Provides parser management; activation is manual and lives in
    -- plugins/treesitter.lua, driven by lua/languages.lua.
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

    -- ── Fuzzy finder ─────────────────────────────────────────────────────────
    -- fzf-lua: files/grep/buffers/LSP pickers on the fzf binary (Brewfile).
    "https://github.com/ibhagwan/fzf-lua",

    -- ── File explorer (neo-tree) and its libraries ───────────────────────────
    -- plenary (utility functions) and nui (UI widgets) are required by
    -- neo-tree; nvim-web-devicons supplies Nerd Font file icons (also used by
    -- fzf-lua and lualine). Listed before neo-tree: vim.pack loads in order.
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",

    -- ── Completion ───────────────────────────────────────────────────────────
    -- blink.cmp, pinned to its latest RELEASE TAG (not the main branch): each
    -- tagged release ships a prebuilt Rust fuzzy-matcher binary that blink
    -- downloads for exactly that tag. Tracking main would require a Rust
    -- nightly toolchain to build the matcher. See plugins/completion.lua.
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },

    -- ── UI / editing ─────────────────────────────────────────────────────────
    "https://github.com/nvim-lualine/lualine.nvim", -- statusline (plugins/statusline.lua)
    "https://github.com/lewis6991/gitsigns.nvim", -- git gutter + hunk actions (plugins/gitsigns.lua)
    "https://github.com/stevearc/conform.nvim", -- manual formatting (plugins/conform.lua)
    "https://github.com/lukas-reineke/indent-blankline.nvim", -- indent guides (plugins/indent.lua)
})

-- Per-plugin configuration. Order: completion first so it can register its
-- LSP capabilities before plugins/lsp.lua enables the servers.
require("plugins.treesitter")
require("plugins.completion")
require("plugins.lsp")
require("plugins.fzf")
require("plugins.neotree")
require("plugins.statusline")
require("plugins.gitsigns")
require("plugins.conform")
require("plugins.indent")
