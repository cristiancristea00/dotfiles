--[[===========================================================================
  after/lsp/sourcekit.lua — Swift (sourcekit-lsp, ships with Xcode)
  ============================================================================

  Merged on top of nvim-lspconfig's sourcekit defaults; the after/ prefix is
  what makes this override win (:h lsp-config-merge, see after/lsp/clangd.lua).

  sourcekit-lsp works out of the box for Swift packages (Package.swift) and
  Xcode projects that expose a build server (buildServer.json — see
  https://github.com/SolaWing/xcode-build-server for Xcode integration).
===========================================================================]]--

return {
    -- WHAT: Restrict sourcekit-lsp to Swift buffers only.
    -- WHY : Its default filetypes are { swift, objc, objcpp, c, cpp } — without
    --       this override BOTH sourcekit and clangd would attach to every
    --       C-family file, producing duplicate diagnostics/completions. The clangd
    --       (after/lsp/clangd.lua) is deliberately the C-family owner here;
    --       delete this line if you'd rather have sourcekit's take on ObjC too.
    filetypes = { "swift" },
}
