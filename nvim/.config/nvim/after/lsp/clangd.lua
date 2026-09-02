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
  compile_commands.json in the project root. CMake does it with
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON on any platform; Makefile projects can use
  `bear -- make`; Xcode projects need a wrapper such as `xcode-build-server`.
  Without it, clangd guesses flags and ObjC/C++ features may misbehave.
===========================================================================]]--

return {
    -- WHAT: How to launch clangd, resolved per platform at load time.
    -- WHY : macOS pins Apple's clangd from Xcode (also reachable at
    --       /usr/bin/clangd) because that build understands Apple SDKs,
    --       frameworks and Objective-C best — the priority on a Mac.
    --       Everywhere else the executable is looked up on $PATH: Linux
    --       distributions install clangd from an LLVM package, often VERSIONED
    --       (/usr/bin/clangd-18) with the unsuffixed name provided through
    --       update-alternatives. Hardcoding the macOS path there would fail
    --       with ENOENT and leave C/C++ with no language server at all.
    -- HOW : To use a different build, change the first element. Homebrew LLVM
    --       is at "/opt/homebrew/opt/llvm/bin/clangd" (brew install llvm);
    --       on Debian/Ubuntu name the version explicitly, e.g. "clangd-18".
    cmd = {
        vim.uv.os_uname().sysname == "Darwin" and "/usr/bin/clangd" or "clangd",
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
