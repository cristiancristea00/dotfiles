--[[===========================================================================
  after/lsp/jsonls.lua — JSON and JSONC (vscode-json-language-server)
  ============================================================================

  Merged over nvim-lspconfig's jsonls defaults (plugins/lsp.lua explains the
  after/ prefix).

  Its config already declares `filetypes = { "json", "jsonc" }`, so this file
  wires no filetypes. Which paths get the `jsonc` filetype, and why that
  choice reaches the server at all, is set out in lua/languages.lua.
===========================================================================]]--

return {
    -- WHAT: Whether the server advertises document formatting to the client.
    -- WHY : Off. The nvim-lspconfig default is true, and <leader>F runs
    --       `lsp_format = "fallback"` (plugins/conform.lua), so a filetype
    --       with no conform formatter falls through to the server's. Here that
    --       would reflow the files this repo hand-annotates, whose layout is
    --       fixed: one array entry per line, and a blank line before each
    --       documented block. Declaring no formatter in lua/languages.lua is
    --       not enough on its own for the same reason.
    -- HOW : Set it true to get <leader>F formatting back, at the cost of that
    --       layout.
    init_options = { provideFormatter = false }, -- nvim-lspconfig default: true

    -- NOTE: Schema validation is inactive because nothing supplies a schema,
    --       and only a local schema can be supplied. The catalogue lookup
    --       VS Code performs belongs to its client extension rather than to
    --       this binary: the strings `schemastore` and `catalog.json` occur in
    --       json-language-features/client and nowhere in the server that
    --       vscode-langservers-extracted ships. A schema named by URL does not
    --       work either. Measured with the form below at LSP log level TRACE:
    --       the map does reach the server, inside
    --       `workspace/didChangeConfiguration`, but with an `https://` URL no
    --       diagnostic follows and the server issues no request for the schema
    --       at all, so there is nothing for the client to answer. Why it does
    --       not ask was not established. A `file://` URL does validate. This
    --       is where jsonls differs from after/lsp/yamlls.lua, which only has
    --       to turn yaml-language-server's own schemaStore fetch on.
    -- HOW : Name a local schema to get validation, e.g.:
    --       settings = {
    --           json = {
    --               schemas = {
    --                   {
    --                       fileMatch = { "*.webmanifest" },
    --                       url = "file:///path/to/web-manifest.json",
    --                   },
    --               },
    --           },
    --       },
    --       Vendor the schema file to use one from schemastore.org; the URL
    --       form will not work.
}
