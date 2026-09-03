--[[===========================================================================
  after/lsp/ruff.lua — Python linting (ruff's built-in language server)
  ============================================================================

  Merged on top of nvim-lspconfig's ruff defaults. Ruff provides lint
  diagnostics, auto-fix code actions (gra on a diagnostic), and import
  sorting. Rule selection belongs in each project's pyproject.toml /
  ruff.toml, not in the editor.

  There is a third place it can come from: ../../../../ruff/.config/ruff/ruff.toml
  in this repo deploys to ~/.config/ruff/ruff.toml, which Ruff reads for files
  belonging to no configured project. It is a FALLBACK and never merges — any
  project with its own configuration ignores it completely — so it changes
  nothing for a project that has opinions, and supplies the settings for loose
  scripts that do not.
===========================================================================]]--

return {
    -- WHAT: Disable ruff's hover so K is always answered by ty.
    -- WHY : Both servers attach to Python buffers; without this, hover results
    --       would race and ruff's (it has none of substance) could win.
    on_attach = function(client, _bufnr)
        client.server_capabilities.hoverProvider = false
    end,
}
