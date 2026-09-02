--[[===========================================================================
  lsp/clangd.lua — C / C++ / Objective-C / Objective-C++
  ============================================================================

  Files in this after/lsp/ directory are Neovim's NATIVE per-server config
  format (:h lsp-config): the returned table is merged on top of
  nvim-lspconfig's defaults for the same server name, and only the
  differences live here. The `after/` prefix is what gives these files
  priority: plain lsp/ files from ALL runtimepath entries merge at the same
  tier (plugin wins by load order), while after/lsp/ is the documented tier
  for user overrides (:h lsp-config-merge).

  clangd needs to know how each file is compiled: generate a
  compile_commands.json in the project root (CMake:
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON; Xcode projects: xcpretty/xcodebuild
  wrappers or `xcode-build-server`). Without it, clangd guesses flags and
  ObjC/C++ features may misbehave.
===========================================================================]]--

return {
    -- WHAT: Pin Apple's clangd from Xcode (also reachable at /usr/bin/clangd)
    --       plus a few quality flags. Overriding `cmd` replaces the default
    --       entirely, so the flags are restated here.
    -- WHY : Apple's build understands Apple SDKs, frameworks and ObjC best —
    --       the priority for this machine. For newest-C++-standard work,
    --       switch the first element to Homebrew LLVM's clangd:
    --       "/opt/homebrew/opt/llvm/bin/clangd" (brew install llvm).
    cmd = {
        "/usr/bin/clangd",
        -- Index the whole project in the background => fast references/rename.
        "--background-index",
        -- Run clang-tidy checks (configured per-project via .clang-tidy).
        "--clang-tidy",
        -- Completion shows the full function signature, not just the name.
        "--completion-style=detailed",
        -- When completing a symbol from a not-yet-included header, insert the
        -- #include too, and mark completions that would do so.
        "--header-insertion=iwyu",
    },

    -- NOTE: `filetypes` is NOT overridden — nvim-lspconfig's default already
    -- covers c, cpp, objc, objcpp (and cuda). sourcekit-lsp is restricted to
    -- Swift in after/lsp/sourcekit.lua so the two never fight over C-family
    -- files.
}
