--[[===========================================================================
  core/keymaps.lua — plugin-independent keymaps
  ============================================================================

  Only mappings that work in a bare Neovim live here. Plugin actions are
  mapped in the plugin's own module: <leader>f* in plugins/fzf.lua, <leader>e
  in plugins/neotree.lua, <leader>g* in plugins/gitsigns.lua, <leader>F in
  plugins/conform.lua, LSP keys in plugins/lsp.lua, and the ⌘ maps in
  core/neovide.lua.

  Every mapping has a `desc`, which :map and fzf-lua's keymap picker
  (<leader>fk) display.
===========================================================================]]--

local map = vim.keymap.set

-- Clear search highlight ------------------------------------------------------
-- WHAT: <Esc> in normal mode clears the current search highlight; hlsearch
--       stays on for the next search.
-- WHY : Keeps match highlighting without turning `hlsearch` off globally.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation -----------------------------------------------------------
-- WHAT: Move between split windows with Ctrl and the home-row directions.
-- WHY : One key instead of the default two-key <C-w>h/j/k/l.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing -------------------------------------------------------------
-- WHAT: Ctrl and the arrow keys grow or shrink the current window by two
--       lines or columns.
-- WHY : Neovim has no default resize keys beyond the <C-w> family.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Stay in visual mode while indenting ------------------------------------------
-- WHAT: After indenting a visual selection with < or >, re-select it.
-- WHY : The default drops the selection after one shift, so repeating it
--       needs `gv` first.
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

-- Move selected lines ----------------------------------------------------------
-- WHAT: Alt-j and Alt-k move the visual selection down or up, re-indenting it
--       (`=gv` keeps the selection and fixes indentation).
-- WHY : In Neovide the left Option key acts as Alt (core/neovide.lua); in a
--       terminal the terminal must send Option as Meta (Ghostty's
--       os-darwin.conf does).
map("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Diagnostics list -------------------------------------------------------------
-- WHAT: Put every diagnostic of the current buffer into the location list.
-- WHY : Neovim's built-ins (]d, [d, <C-w>d; see core/diagnostics.lua) move
--       between diagnostics one at a time; the list shows them together.
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

-- Terminal --------------------------------------------------------------------
-- WHAT: Double <Esc> leaves terminal-insert mode.
-- WHY : The default is <C-\><C-n>. A single <Esc> is left alone so TUI
--       programs inside the terminal still receive it.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
