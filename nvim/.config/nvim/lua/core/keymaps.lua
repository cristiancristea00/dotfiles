--[[===========================================================================
  core/keymaps.lua — plugin-independent keymaps
  ============================================================================

  Only mappings that work in a bare Neovim live here. Plugin-provided actions
  are mapped next to the plugin that provides them:

    plugins/fzf.lua         -- <leader>f* find/search pickers
    plugins/neotree.lua     -- <leader>e  file explorer
    plugins/gitsigns.lua    -- <leader>g* git hunks/blame, ]h / [h
    plugins/conform.lua     -- <leader>F  format buffer
    plugins/lsp.lua         -- LSP maps (on LspAttach) + list of built-ins
    core/neovide.lua        -- Cmd-key (⌘) GUI maps

  `vim.keymap.set(mode, lhs, rhs, opts)` is the modern API (:h vim.keymap.set).
  Every mapping gets a `desc` — it shows up in :map output and fzf-lua's
  keymap picker (<leader>fk), making the config self-documenting at runtime.
===========================================================================]]--

local map = vim.keymap.set

-- Clear search highlight ------------------------------------------------------
-- WHAT: <Esc> in normal mode clears the current search highlight (hlsearch
--       stays enabled for the *next* search).
-- WHY : Best of both worlds: matches light up while you care, one keypress
--       makes them go away. This is why hlsearch was not disabled globally.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation -----------------------------------------------------------
-- WHAT: Move between split windows with Ctrl + home-row directions instead of
--       the default <C-w>h/j/k/l two-key dance.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing -------------------------------------------------------------
-- WHAT: Ctrl + arrow keys grow/shrink the current window.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Stay in visual mode while indenting ------------------------------------------
-- WHAT: After indenting a visual selection with < or >, re-select it so you
--       can keep hitting the key. Vanilla behaviour drops the selection after
--       one shift.
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

-- Move selected lines ----------------------------------------------------------
-- WHAT: Alt-j / Alt-k move the visual selection down/up, re-indenting as it
--       goes (`=gv` keeps the selection and fixes indentation).
-- NOTE: In Neovide the LEFT Option key acts as Alt (see core/neovide.lua);
--       in a terminal this needs the terminal to send Option as Meta.
map("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Diagnostics list -------------------------------------------------------------
-- WHAT: Dump all diagnostics for the current buffer into the location list.
-- NOTE: Neovim built-ins already cover the rest: ]d / [d jump between
--       diagnostics, <C-w>d opens the floating detail window (:h diagnostic-
--       defaults). See core/diagnostics.lua.
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

-- Terminal --------------------------------------------------------------------
-- WHAT: Double-<Esc> leaves terminal-insert mode (the default <C-\><C-n> is
--       finger origami). A single <Esc> is left alone so TUI apps inside the
--       terminal (e.g. another vim) still receive it.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
