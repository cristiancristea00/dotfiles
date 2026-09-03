--[[===========================================================================
  plugins/fzf.lua — fzf-lua (fuzzy finding and searching)
  ============================================================================

  fzf-lua runs the fzf binary (Brewfile), with ripgrep for grepping and fd
  for file listing, so results follow .gitignore.

  Keys inside every picker:
    <CR> open   <C-v> vsplit   <C-s> split   <C-t> tab
    <C-q> send results to quickfix   <Tab> multi-select
  Pickers not mapped below are reachable through :FzfLua <Tab>.
===========================================================================]]--

local fzf = require("fzf-lua")

-- WHAT: Set up fzf-lua with its defaults.
-- WHY : The defaults already preview through treesitter and show icons from
--       nvim-web-devicons. Overrides go here, e.g. `winopts = { height = 0.9 }`
--       (:h fzf-lua-setup-options).
fzf.setup({})

-- WHAT: Use the fzf picker for vim.ui.select().
-- WHY : Anything that asks for a choice from a list (e.g. code actions on gra)
--       then gets fuzzy search instead of the built-in numbered prompt.
fzf.register_ui_select()

-- Keymaps: the <leader>f "find" family. Each entry is independent; the desc
-- names what it opens.
local map = vim.keymap.set
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Grep project (live)" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
map("n", "<leader>fb", fzf.buffers, { desc = "Find open buffers" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Find recent files" })
map("n", "<leader>fh", fzf.helptags, { desc = "Find help topics" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Find keymaps" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Find buffer diagnostics" })
map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Find workspace diagnostics" })
map("n", "<leader>fr", fzf.lsp_references, { desc = "Find references (LSP)" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Find symbols in buffer (LSP)" })
map("n", "<leader>fS", fzf.lsp_live_workspace_symbols, { desc = "Find symbols in workspace (LSP)" })
map("n", "<leader>fR", fzf.resume, { desc = "Resume last picker" })
