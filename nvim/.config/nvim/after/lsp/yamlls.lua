--[[===========================================================================
  after/lsp/yamlls.lua — YAML (yaml-language-server)
  ============================================================================

  Merged on top of nvim-lspconfig's yamlls defaults.
===========================================================================]]--

return {
    settings = {
        -- WHAT: Red Hat telemetry ping — off.
        redhat = { telemetry = { enabled = false } },

        yaml = {
            -- WHAT: Pull JSON schemas from schemastore.org automatically, matched
            --       by file name (.github/workflows/*.yml gets the GitHub Actions
            --       schema, docker-compose.yml its schema, etc.).
            -- WHY : Schema-aware completion and validation is yamlls's killer
            --       feature; enabling the built-in catalog needs no extra plugin.
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },

            -- WHAT: Map additional schemas to file patterns manually, e.g.:
            -- schemas = {
            --   ["https://json.schemastore.org/gitlab-ci.json"] = ".gitlab-ci.yml",
            -- },

            -- WHAT: The yamlls built-in formatter — off; <leader>F uses yamlfmt instead
            --       (see lua/languages.lua / Brewfile).
            format = { enable = false },
        },
    },
}
