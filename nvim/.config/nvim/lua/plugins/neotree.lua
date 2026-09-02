--[[===========================================================================
  plugins/neotree.lua — neo-tree (file explorer sidebar)
  ============================================================================

  IDE-style file tree with git status and Nerd Font icons. Depends on
  plenary.nvim + nui.nvim + nvim-web-devicons (declared in plugins/init.lua).

  Inside the tree (defaults worth knowing — press ? in the tree for all):
    <CR> open        a  add file (trailing / = dir)   d  delete
    r    rename      x/c/p cut/copy/paste             H  toggle hidden files
    P    preview     /  filter                        R  refresh
===========================================================================]]--

require("neo-tree").setup({
    -- WHAT: If the tree is the last window left (e.g. after :q in the only file
    --       window), close it too instead of leaving a stranded sidebar.
    close_if_last_window = true,

    filesystem = {
        -- WHAT: Keep the tree in sync with the buffer you're editing.
        follow_current_file = { enabled = true },
        -- WHAT: Watch the filesystem (libuv) and refresh automatically when files
        --       change outside Neovim (git checkout, build output, ...).
        use_libuv_file_watcher = true,
        filtered_items = {
            -- WHAT: Show dotfiles/gitignored entries greyed-out rather than hiding
            --       them completely — this IS a dotfiles repo, after all. `H`
            --       still toggles full visibility.
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },

    window = {
        -- WHAT: Sidebar position and width. `position = "right"` / `"float"` also work.
        position = "left",
        width = 34,
    },
})

-- WHAT: Toggle the sidebar; `reveal` selects the current file in the tree.
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<CR>", { desc = "Toggle file explorer" })
