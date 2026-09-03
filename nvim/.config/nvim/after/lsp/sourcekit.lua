--[[===========================================================================
  after/lsp/sourcekit.lua — Swift (sourcekit-lsp, ships with Xcode)
  ============================================================================

  Merged over nvim-lspconfig's sourcekit defaults (plugins/lsp.lua explains
  the after/ prefix). The server works for Swift packages (Package.swift)
  and for Xcode projects that expose a build server (buildServer.json; see
  https://github.com/SolaWing/xcode-build-server).
===========================================================================]]--

return {
    -- WHAT: Restrict sourcekit-lsp to Swift buffers.
    -- WHY : Its default filetypes are swift, objc, objcpp, c, and cpp, so
    --       without this both sourcekit and clangd would attach to every
    --       C-family file and report every diagnostic twice. clangd
    --       (after/lsp/clangd.lua) handles the C family here; delete this line
    --       to let sourcekit handle Objective-C as well.
    filetypes = { "swift" },
}
