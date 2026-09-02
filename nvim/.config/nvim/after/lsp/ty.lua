--[[===========================================================================
  after/lsp/ty.lua — Python type checking & IDE features (ty, by Astral)
  ============================================================================

  Merged on top of nvim-lspconfig's ty defaults, which already define
  cmd = { "ty", "server" } and Python root detection (ty.toml/pyproject.toml/
  .git/...). Nothing needs overriding today — this file exists as the
  documented place for ty settings as they stabilize (ty is pre-1.0; run
  `ty --help` / see https://docs.astral.sh/ty for current options).

  ty handles types/completion/hover/rename; ruff (after/lsp/ruff.lua) runs alongside
  it for lint diagnostics — the division of labor Astral designed them for.
  Per-project configuration belongs in the project's pyproject.toml under
  [tool.ty], not here.
===========================================================================]]--

return {
    -- Example (uncomment to change how strictly untyped code is checked):
    -- settings = {
    --   ty = { experimental = {} },
    -- },
}
