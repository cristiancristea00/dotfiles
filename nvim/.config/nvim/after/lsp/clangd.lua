--[[===========================================================================
  lsp/clangd.lua — C / C++ / Objective-C / Objective-C++
  ============================================================================

  Files in after/lsp/ are Neovim's per-server config format (:h lsp-config):
  the returned table is merged over nvim-lspconfig's defaults for the same
  server, so only the differences live here. The header of plugins/lsp.lua
  explains why the after/ prefix is required.

  clangd needs to know how each file is compiled: generate a
  compile_commands.json in the project root. CMake writes it with
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON; Makefile projects can use `bear -- make`;
  Xcode projects need a wrapper such as xcode-build-server. Without it clangd
  guesses the flags, and Objective-C and C++ features may fail.
===========================================================================]]--

return {
    -- WHAT: How to launch clangd, resolved per platform at load time.
    -- WHY : macOS uses Apple's clangd from Xcode (/usr/bin/clangd), which
    --       understands Apple SDKs, frameworks, and Objective-C. Elsewhere the
    --       executable is looked up on $PATH: Linux distributions install
    --       clangd from an LLVM package, often versioned (/usr/bin/clangd-18)
    --       with the bare name provided through update-alternatives. The macOS
    --       path there would fail with ENOENT and leave C and C++ without a
    --       server.
    -- HOW : To use a different build, change the first element: Homebrew LLVM
    --       is at "/opt/homebrew/opt/llvm/bin/clangd" (brew install llvm); on
    --       Debian or Ubuntu name the version, e.g. "clangd-18".
    cmd = {
        vim.uv.os_uname().sysname == "Darwin" and "/usr/bin/clangd" or "clangd",
        -- Index the whole project in the background, for references and rename.
        "--background-index",
        -- Run clang-tidy checks, configured per project in .clang-tidy.
        "--clang-tidy",
        -- Completion shows the full function signature, not only the name.
        "--completion-style=detailed",
        -- When completing a symbol from a header not yet included, insert the
        -- #include too, and mark completions that would.
        "--header-insertion=iwyu",
    },

    -- NOTE: `filetypes` is not overridden: nvim-lspconfig's default covers c,
    --       c.doxygen, cpp, cpp.doxygen, objc, objcpp, and cuda. The sourcekit
    --       server is restricted to Swift
    --       in after/lsp/sourcekit.lua, so only clangd attaches to C-family
    --       files.
}
