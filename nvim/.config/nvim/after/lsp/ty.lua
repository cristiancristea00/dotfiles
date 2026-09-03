--[[===========================================================================
  after/lsp/ty.lua — Python type checking and IDE features (ty, by Astral)
  ============================================================================

  Merged over nvim-lspconfig's ty defaults, which set cmd = { "ty", "server" }
  and the root markers ty.toml, pyproject.toml, setup.py, setup.cfg,
  requirements.txt, and .git. Nothing is overridden yet; the file is the
  place for ty settings (ty is pre-1.0; `ty --help` and
  https://docs.astral.sh/ty list the current options). The ty server handles
  types, completion, hover, and rename; ruff (after/lsp/ruff.lua) handles
  lints. Per-project configuration goes in the project's pyproject.toml
  under [tool.ty].
===========================================================================]]--

return {
    -- Example (uncomment to change how strictly untyped code is checked):
    -- settings = {
    --   ty = { experimental = {} },
    -- },
}
