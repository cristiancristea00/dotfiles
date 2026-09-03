--[[===========================================================================
  plugins/neotree.lua — neo-tree (file explorer sidebar)
  ============================================================================

  File tree with git status and Nerd Font icons. Depends on plenary.nvim,
  nui.nvim, and nvim-web-devicons (declared in plugins/init.lua).

  Keys inside the tree (? lists all):
    <CR> open        a  add file (trailing / = dir)   d  delete
    r    rename      x/c/p cut/copy/paste             H  toggle hidden files
    P    preview     /  filter                        R  refresh
===========================================================================]]--

require("neo-tree").setup({
    -- WHAT: Close the tree when it is the last window left.
    -- WHY : After :q in the only file window, Neovim would otherwise stay open
    --       showing only the sidebar. Off by default.
    close_if_last_window = true,

    filesystem = {
        -- WHAT: Select the current buffer's file in the tree as buffers change.
        -- WHY : Off by default. On, the tree keeps up when a file is opened
        --       through fzf or a jump rather than from the tree.
        follow_current_file = { enabled = true },
        -- WHAT: Watch the filesystem with libuv and refresh when files change
        --       outside Neovim (git checkout, build output).
        -- WHY : Off by default, so the tree would show stale entries until a
        --       manual refresh.
        use_libuv_file_watcher = true,
        filtered_items = {
            -- WHAT: Show dotfiles and gitignored entries, dimmed, instead of
            --       hiding them; H toggles full visibility.
            -- WHY : This is a dotfiles repository. The defaults hide both.
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },

    window = {
        -- WHAT: Sidebar position and width in columns.
        -- WHY : Left is the default; 34 is narrower than the default 40 and
        --       still fits the repo's longest file names. "right" and "float"
        --       also work.
        position = "left",
        width = 34,
    },
})

-- WHAT: Toggle the sidebar; `reveal` selects the current file in the tree.
-- WHY : The plugin maps no key of its own; <leader>e is the only map it needs.
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<CR>", { desc = "Toggle file explorer" })
