--[[===========================================================================
  after/lsp/ruff.lua — Python linting (ruff's built-in language server)
  ============================================================================

  Merged over nvim-lspconfig's ruff defaults. Ruff provides lint diagnostics,
  auto-fix code actions (gra on a diagnostic), and import sorting. Rule
  selection lives in each project's pyproject.toml or ruff.toml, not in the
  editor. ../../../../../ruff/.config/ruff/ruff.toml deploys to
  ~/.config/ruff/ruff.toml, which Ruff reads only for files in no configured
  project; a project's own configuration replaces it entirely.
===========================================================================]]--

return {
    -- WHAT: Disable ruff's hover so K is always answered by ty.
    -- WHY : Both servers attach to Python buffers. Ruff's hover has no type
    --       information, and whichever server answered first would win.
    on_attach = function(client, _bufnr)
        client.server_capabilities.hoverProvider = false
    end,
}
