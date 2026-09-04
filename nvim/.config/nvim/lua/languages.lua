--[[===========================================================================
  languages.lua — the language table
  ============================================================================

  One entry per language drives:

    * treesitter parser installation, highlighting, indentation, and folding
                                     (consumed by lua/plugins/treesitter.lua)
    * LSP server activation          (consumed by lua/plugins/lsp.lua)
    * manual formatting (<leader>F)  (consumed by lua/plugins/conform.lua)
    * filetype detection             (consumed by lua/core/filetypes.lua)

  ── ADD A LANGUAGE ──────────────────────────────────────────────────────────
    1. Append an entry below; every field except `name` and `filetypes` is
       optional.
    2. Install its LSP server binary (add it to the Brewfile and run
       `brew bundle`); it has to be on $PATH.
    3. If nvim-lspconfig has no config for the server (it has about 400; see
       https://github.com/neovim/nvim-lspconfig/tree/master/lsp), define one
       in after/lsp/<server>.lua.
    4. Restart Neovim. The treesitter parser compiles on first start, which
       needs the tree-sitter CLI and a C compiler (both in the Brewfile).

  ── REMOVE A LANGUAGE ───────────────────────────────────────────────────────
    Delete the entry. Optionally uninstall the server binary and run
    `:lua require("nvim-treesitter").uninstall({"<parser>"})`.

  ── ENTRY FIELDS ────────────────────────────────────────────────────────────
    name           A label for humans; not used programmatically.
    filetypes      Neovim filetypes this entry covers (:h filetype). Used to
                   attach treesitter and to route formatters. `:set ft?`
                   shows a buffer's filetype.
    parsers        Treesitter parsers to install. Usually equal to the
                   filetype, not always (see Git files below). Available:
                   :lua =require("nvim-treesitter").get_available()
    parser_aliases Map of filetype -> parser for filetypes that reuse another
                   language's parser (zsh -> bash).
    servers        LSP servers to enable, by nvim-lspconfig config name (the
                   file name in its lsp/ directory). Which filetypes a server
                   attaches to comes from the server's config, not this entry.
    formatters     conform.nvim formatter names, run in order by <leader>F
                   (:h conform-formatters). A missing binary falls back to LSP
                   formatting.
    extensions     Optional map of file extension -> filetype, for files
                   Neovim does not recognise. Consumed by lua/core/filetypes.lua.
    filenames      Optional map of exact file name -> filetype, same consumer.
    patterns       Optional map of Lua pattern (matched against the full path)
                   -> filetype, same consumer. For rotated or directory-scoped
                   files.
===========================================================================]]--

return {
    -- C-family: clangd for all four filetypes, clang-format for formatting.
    {
        name = "C / C++ / Objective-C / Objective-C++",
        filetypes = { "c", "cpp", "objc", "objcpp" },
        parsers = { "c", "cpp", "objc" }, -- objcpp is highlighted by the cpp and objc parsers
        servers = { "clangd" }, -- Apple's clangd from Xcode on macOS; see after/lsp/clangd.lua
        formatters = { "clang_format" }, -- reads the project's .clang-format
    },
    -- CMake, the C-family build system.
    {
        name = "CMake",
        filetypes = { "cmake" },
        parsers = { "cmake" },
        -- Preferred to cmake-language-server: both have formulae and
        -- nvim-lspconfig entries, but Zed's `neocmake` extension drives the
        -- same binary, so the two editors report identical diagnostics. It is
        -- a single Rust binary rather than a Python package.
        servers = { "neocmake" }, -- brew install neocmakelsp
        -- The server formats through the LSP, so <leader>F works without a
        -- conform formatter.
        formatters = {},
    },
    -- Swift: sourcekit-lsp from Xcode, restricted to Swift buffers.
    {
        name = "Swift",
        filetypes = { "swift" },
        parsers = { "swift" },
        servers = { "sourcekit" }, -- ships with Xcode; see after/lsp/sourcekit.lua
        -- Apple's swift-format, in the Brewfile and bundled with Xcode.
        formatters = { "swift_format" },
    },
    -- Rust: rust-analyzer and rustfmt, both installed by rustup.
    {
        name = "Rust",
        filetypes = { "rust" },
        parsers = { "rust" },
        servers = { "rust_analyzer" }, -- installed by rustup
        formatters = { "rustfmt" },
    },
    -- Go source files. Module files are a separate entry; see below.
    {
        name = "Go",
        filetypes = { "go" },
        parsers = { "go" },
        servers = { "gopls" }, -- brew install gopls; needs the `go` toolchain at runtime
        -- The goimports tool applies gofmt's layout and adds or removes import
        -- lines to match the file. Plain gofmt and the stricter gofumpt leave
        -- imports alone.
        formatters = { "goimports" },
    },
    -- Go module and workspace files: highlighting only.
    {
        name = "Go module and workspace files",
        -- Kept apart from the Go entry: plugins/conform.lua maps an entry's
        -- formatters onto every filetype in it, and goimports would mangle
        -- go.mod and go.sum.
        filetypes = { "gomod", "gosum", "gowork", "gotmpl" },
        parsers = { "gomod", "gosum", "gowork", "gotmpl" },
        -- The gopls server attaches to gomod, gowork, and gotmpl through its own
        -- filetype list, so enabling it in the Go entry covers them. It does not
        -- claim gosum.
        servers = {},
        formatters = {},
    },
    -- Zig: zls and `zig fmt`.
    {
        name = "Zig",
        -- The zls server also claims the `zir` filetype (Zig IR). It is not
        -- listed here because no `zir` treesitter parser exists and `zig fmt`
        -- cannot format it; zls attaches to .zir through its own config.
        filetypes = { "zig" },
        parsers = { "zig" },
        -- The zls server and the zig compiler are version-locked; the Brewfile's
        -- zls entry documents the trap.
        servers = { "zls" }, -- brew install zls (pulls zig as a dependency)
        -- The zigfmt formatter runs `zig fmt`, which ships with the compiler zls
        -- requires. Through conform it works when the server has not attached.
        formatters = { "zigfmt" },
    },
    -- Python: ty for types, completion, hover, and rename; ruff for lints.
    {
        name = "Python",
        filetypes = { "python" },
        parsers = { "python" },
        -- The ty server (Astral) and ruff run together; after/lsp/ruff.lua
        -- disables ruff's hover so K is answered by ty.
        servers = { "ty", "ruff" },
        formatters = { "ruff_format" }, -- add "ruff_organize_imports" before it to sort imports too
    },
    -- Ruby: ruby-lsp, which also formats.
    {
        name = "Ruby",
        filetypes = { "ruby" },
        parsers = { "ruby" },
        -- Shopify's ruby-lsp, not solargraph, which is the older server and
        -- the one Zed's `ruby` extension enables by default; Zed's settings
        -- name ruby-lsp explicitly so both editors use this one.
        servers = { "ruby_lsp" }, -- brew install ruby-lsp (pulls the ruby formula)
        -- No conform entry. The server formats through the LSP, delegating to
        -- RuboCop, Standard, or Syntax Tree from the project's own bundle,
        -- which is the version the project expects. A conform `rubocop` entry
        -- would call whatever `rubocop` is on $PATH instead, and RuboCop is a
        -- gem rather than a Homebrew formula, so the Brewfile cannot pin one.
        formatters = {},
    },
    -- TOML: taplo as server and formatter.
    {
        name = "TOML",
        filetypes = { "toml" },
        parsers = { "toml" },
        servers = { "taplo" },
        formatters = { "taplo" },
    },
    -- YAML: yaml-language-server with schemastore schemas, yamlfmt to format.
    {
        name = "YAML",
        filetypes = { "yaml" },
        parsers = { "yaml" },
        servers = { "yamlls" }, -- schemastore.org schemas enabled in after/lsp/yamlls.lua
        formatters = { "yamlfmt" },
    },
    -- XML family: treesitter only, no server.
    {
        name = "XML",
        filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
        parsers = { "xml" }, -- one parser covers all five filetypes
        -- The only XML server nvim-lspconfig knows is lemminx, a Java program
        -- with no Homebrew formula (`brew search lemminx` finds nothing); every
        -- other dependency here comes from the Brewfile. Highlighting, indent, and folds work; completion, schema
        -- validation, and formatting do not. To add it, install lemminx from
        -- https://github.com/eclipse-lemminx/lemminx/releases onto $PATH and
        -- set servers = { "lemminx" }.
        servers = {},
        formatters = {},
    },
    -- Dockerfile: Docker's own language server.
    {
        name = "Dockerfile",
        filetypes = { "dockerfile" },
        parsers = { "dockerfile" },
        -- Docker's docker-language-server (a Go binary), not dockerls, which
        -- needs docker-langserver from npm. Its filetypes are `dockerfile` and
        -- `yaml.docker-compose`, not plain `yaml`, so it does not overlap
        -- yamlls; compose files get it once Neovim resolves the compound
        -- filetype.
        servers = { "docker_language_server" }, -- brew install docker-language-server
        formatters = {}, -- the server formats through the LSP
    },
    -- Markdown: marksman for links and references.
    {
        name = "Markdown",
        filetypes = { "markdown" },
        parsers = { "markdown", "markdown_inline" }, -- the inline parser handles emphasis, links, code spans
        servers = { "marksman" }, -- link and reference completion, rename across files
        formatters = {}, -- add "prettier" if installed
    },
    -- Git files: treesitter highlighting only.
    {
        name = "Git files",
        filetypes = { "gitcommit", "gitconfig", "gitrebase", "gitattributes", "gitignore" },
        parsers = { "gitcommit", "git_config", "git_rebase", "gitattributes", "gitignore", "diff" },
        servers = {}, -- nvim-lspconfig has no git server; no mainstream one exists
        formatters = {},
    },
    -- Shell: bash parser for sh, bash, and zsh; bash-language-server for sh and bash.
    {
        name = "Shell (sh / bash / zsh)",
        filetypes = { "sh", "bash", "zsh" },
        parsers = { "bash" },
        -- No treesitter grammar or server exists for zsh. The alias reuses the
        -- bash parser, so zsh-only syntax may highlight wrongly.
        -- The bash-language-server attaches only to sh and bash; its diagnostics
        -- would be wrong for zsh.
        parser_aliases = { zsh = "bash" },
        servers = { "bashls" }, -- integrates shellcheck and shfmt when installed (Brewfile)
        formatters = { "shfmt" },
    },
    -- Fish: fish-lsp and fish's own formatter.
    {
        name = "Fish",
        filetypes = { "fish" },
        parsers = { "fish" },
        servers = { "fish_lsp" }, -- brew install fish-lsp
        formatters = { "fish_indent" }, -- ships with fish
    },
    -- Log files: Vim's syntax/log.vim, once the filetype is detected.
    {
        name = "Log files",
        filetypes = { "log" },
        -- Neovim ships syntax/log.vim but gives a plain *.log file no filetype;
        -- its built-in detection (detect.log) covers only Vim's own upstream*.log
        -- files.
        -- These rules supply the filetype.
        extensions = { log = "log", LOG = "log", Log = "log" },
        patterns = {
            [".*%.log%.%d+"] = "log", -- rotated logs: app.log.1, app.log.20260902
            [".*/[Ll]ogs?/.*"] = "log", -- anything under a log directory, usually extensionless
            ["/var/log/.*"] = "log",
        },
        -- No generic `log` parser exists in nvim-treesitter (only `sflog`, for
        -- Salesforce); the regex syntax file does the highlighting. No server
        -- or formatter exists for the format.
        parsers = {},
        servers = {},
        formatters = {},
    },
    -- Neovim's own languages, for editing this config and reading :help.
    {
        name = "Neovim config support (Lua, Vimscript, :help)",
        filetypes = { "lua", "vim", "help", "query" },
        parsers = { "lua", "vim", "vimdoc", "query" },
        parser_aliases = { help = "vimdoc" },
        servers = {}, -- add "lua_ls" (brew install lua-language-server) for Lua completion
        formatters = {}, -- add "stylua" if installed
    },
}
