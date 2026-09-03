--[[===========================================================================
  after/lsp/yamlls.lua — YAML (yaml-language-server)
  ============================================================================

  Merged over nvim-lspconfig's yamlls defaults (plugins/lsp.lua explains the
  after/ prefix).
===========================================================================]]--

return {
    settings = {
        -- WHAT: Red Hat's usage telemetry.
        -- WHY : Off, the same choice as redhat.telemetry.enabled in
        --       vscode/.config/Code/User/settings.json.
        redhat = { telemetry = { enabled = false } },

        yaml = {
            -- WHAT: Fetch JSON schemas from schemastore.org, matched by file
            --       name (.github/workflows/*.yml gets the GitHub Actions
            --       schema, docker-compose.yml its schema).
            -- WHY : Schema-aware completion and validation without a plugin.
            --       nvim-lspconfig sets neither key; both values are
            --       yaml-language-server's own defaults (its README), stated so
            --       the schema source is documented. The `schemas` map below is
            --       the manual alternative, one entry per file pattern.
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },

            -- WHAT: Map additional schemas to file patterns by hand, e.g.:
            -- schemas = {
            --   ["https://json.schemastore.org/gitlab-ci.json"] = ".gitlab-ci.yml",
            -- },

            -- WHAT: The server's built-in formatter.
            -- WHY : Off. Both nvim-lspconfig's yamlls config and the server's
            --       README default it to on; <leader>F uses yamlfmt
            --       (lua/languages.lua, Brewfile) instead.
            format = { enable = false },
        },
    },
}
