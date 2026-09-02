--[[===========================================================================
  plugins/fzf.lua — fzf-lua (fuzzy finding & searching)
  ============================================================================

  fzf-lua drives everything through the fzf binary (Brewfile), using your
  installed ripgrep for grepping and fd for file listing — so results honor
  .gitignore automatically.

  All pickers share the same keys inside the picker window:
    <CR> open   <C-v> vsplit   <C-s> split   <C-t> tab
    <C-q> send results to quickfix   <Tab> multi-select
  Every picker not mapped below is reachable via :FzfLua <Tab>.
===========================================================================]]--

local fzf = require("fzf-lua")

-- WHAT: Empty setup = fzf-lua's defaults, which are excellent (previews via
--       treesitter, icons via nvim-web-devicons). Add overrides here later,
--       e.g. `winopts = { height = 0.9 }` — see :h fzf-lua-setup-options.
fzf.setup({})

-- WHAT: Use the fzf picker for vim.ui.select(), so anything that asks you to
--       pick from a list (code actions via gra, etc.) gets fuzzy search too.
fzf.register_ui_select()

-- Keymaps: the <leader>f "find" family ----------------------------------------
-- Reorder/extend freely — each entry is independent.
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
