--[[===========================================================================
  plugins/init.lua — plugin declarations (vim.pack) and module loading
  ============================================================================

  Plugins are managed by Neovim 0.12's built-in vim.pack (:h vim.pack). The
  first `vim.pack.add()` call clones anything missing (with a confirmation
  prompt), records exact versions in nvim-pack-lock.json next to init.lua
  (committed), and loads the plugins.

  Commands:
    :lua vim.pack.update()          -- fetch updates and review them in a
                                       buffer; :write applies, :quit rejects
    :lua vim.pack.update(nil, { target = "lockfile" })
                                    -- roll everything back to the lockfile
    :lua vim.pack.del({ "name" })   -- remove a plugin's files, after deleting
                                       its spec below (or it reinstalls)
    :checkhealth vim.pack           -- diagnose install and lockfile issues

  ── ADD A PLUGIN ────────────────────────────────────────────────────────────
    1. Append a spec to the vim.pack.add() list below:
         "https://github.com/user/repo"                     -- default branch
         { src = "…", version = "branch-or-tag" }           -- pinned
         { src = "…", version = vim.version.range("*") }    -- latest release tag
    2. Create lua/plugins/<name>.lua with its setup() and keymaps.
    3. require() it at the bottom of this file.
    Removing a plugin is the same three places in reverse, then
    :lua vim.pack.del({ "<name>" }).

  Everything loads at startup; there is no lazy loading. A headless start
  with every plugin measures about 80 ms (`nvim --startuptime /tmp/st.log`),
  and eager loading avoids load-order bugs.
===========================================================================]]--

-- WHAT: Recompile treesitter parsers whenever nvim-treesitter is installed or
--       updated.
-- WHY : Parsers are compiled artefacts tied to the plugin version, and stale
--       ones break highlighting. The hook is registered before vim.pack.add()
--       so it also fires for a first-time install inside that call.
vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("cfg_pack_hooks", { clear = true }),
    desc = "Recompile treesitter parsers when nvim-treesitter is installed/updated",
    callback = function(ev)
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
    -- LSP server configs (cmd, filetypes, root markers) for about 400 servers,
    -- consumed by the native vim.lsp.enable(); see plugins/lsp.lua.
    "https://github.com/neovim/nvim-lspconfig",

    -- Treesitter parser management. The rewritten `main` branch (needs Neovim
    -- 0.12; `master` is frozen). Activation is in plugins/treesitter.lua.
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

    -- Fuzzy finder on the fzf binary (Brewfile); see plugins/fzf.lua.
    "https://github.com/ibhagwan/fzf-lua",

    -- neo-tree's libraries, listed first because vim.pack loads in order:
    -- plenary (utility functions), nui (UI widgets), and nvim-web-devicons
    -- (Nerd Font file icons, also used by fzf-lua and lualine).
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    -- File explorer; see plugins/neotree.lua.
    "https://github.com/nvim-neo-tree/neo-tree.nvim",

    -- Completion, pinned to the latest release tag rather than `main`: each
    -- tagged release ships a prebuilt Rust fuzzy-matcher binary that blink
    -- downloads for that tag, and `main` would need a Rust nightly toolchain
    -- to build it. See plugins/completion.lua.
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },

    "https://github.com/nvim-lualine/lualine.nvim", -- statusline (plugins/statusline.lua)
    "https://github.com/lewis6991/gitsigns.nvim", -- git gutter and hunk actions (plugins/gitsigns.lua)
    "https://github.com/stevearc/conform.nvim", -- manual formatting (plugins/conform.lua)
    "https://github.com/lukas-reineke/indent-blankline.nvim", -- indent guides (plugins/indent.lua)
})

-- Per-plugin configuration. The completion module loads before lsp so its
-- LSP capabilities are registered before the servers are enabled.
require("plugins.treesitter")
require("plugins.completion")
require("plugins.lsp")
require("plugins.fzf")
require("plugins.neotree")
require("plugins.statusline")
require("plugins.gitsigns")
require("plugins.conform")
require("plugins.indent")
