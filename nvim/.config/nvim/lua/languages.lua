--[[===========================================================================
  languages.lua — THE language table
  ============================================================================

  Single source of truth for language support. Every entry here drives:

    * treesitter parser installation + syntax highlighting, indentation and
      folding                        (consumed by lua/plugins/treesitter.lua)
    * LSP server activation          (consumed by lua/plugins/lsp.lua)
    * manual formatting (<leader>F)  (consumed by lua/plugins/conform.lua)

  ── ADD A LANGUAGE ──────────────────────────────────────────────────────────
    1. Append an entry below (all fields except `name`/`filetypes` optional).
    2. Install its LSP server binary (add it to the Brewfile and `brew bundle`,
       or any way you like — it just has to be on $PATH).
    3. If nvim-lspconfig has no config for the server (it has ~400, check
       https://github.com/neovim/nvim-lspconfig/tree/master/lsp), define one
       in this config's own after/lsp/<server>.lua.
    4. Restart Neovim. The treesitter parser compiles automatically on first
       start (needs the tree-sitter CLI + a C compiler — both in the Brewfile).

  ── REMOVE A LANGUAGE ───────────────────────────────────────────────────────
    Delete (or comment out) its entry. Optionally uninstall the server binary
    and `:lua require("nvim-treesitter").uninstall({"<parser>"})`.

  ── ENTRY FIELDS ────────────────────────────────────────────────────────────
    name           A label for humans; not used programmatically.
    filetypes      Neovim filetypes this entry covers (:h filetype). Used to
                   attach treesitter highlighting/indent/folds and to route
                   formatters. Find a file's filetype with :set ft?
    parsers        Treesitter parser names to install. Usually — but not
                   always — equal to the filetype (see git below). Available
                   parsers: :lua =require("nvim-treesitter").get_available()
    parser_aliases Map of filetype -> parser for filetypes that should reuse
                   another language's parser (e.g. zsh -> bash).
    servers        LSP servers to enable, by nvim-lspconfig config name (file
                   name in its lsp/ dir). Which filetypes a server attaches to
                   is defined by the server's own config, not by this entry.
    formatters     conform.nvim formatter names, run in order by <leader>F
                   (names: https://github.com/stevearc/conform.nvim#formatters
                   or :h conform-formatters). The binaries are optional —
                   missing ones fall back to LSP formatting.
    extensions     Optional map of file extension -> filetype, for files
                   Neovim does not already recognise. Consumed by
                   lua/core/filetypes.lua via vim.filetype.add().
    filenames      Optional map of exact file name -> filetype, same consumer.
    patterns       Optional map of Lua pattern (matched against the full path)
                   -> filetype, same consumer. Use for rotated or
                   directory-scoped files.
===========================================================================]]--

return {
    {
        name = "C / C++ / Objective-C / Objective-C++",
        filetypes = { "c", "cpp", "objc", "objcpp" },
        parsers = { "c", "cpp", "objc" }, -- objcpp highlights fine via the cpp/objc parsers
        servers = { "clangd" }, -- Apple's clangd from Xcode; see after/lsp/clangd.lua
        formatters = { "clang_format" }, -- reads the project's .clang-format
    },
    {
        name = "CMake",
        -- Sits next to C/C++ because it is that stack's build system: the
        -- CMakeLists.txt beside the sources above.
        filetypes = { "cmake" },
        parsers = { "cmake" },
        -- neocmakelsp, not cmake-language-server. Both exist as formulae and
        -- both have nvim-lspconfig entries, but Zed's `neocmake` extension
        -- drives the same binary, so the two editors report identical
        -- diagnostics on the same file. It is also a single Rust binary rather
        -- than a Python package.
        servers = { "neocmake" }, -- brew install neocmakelsp
        -- neocmakelsp formats through the LSP (textDocument/formatting), so
        -- <leader>F works without a separate conform formatter.
        formatters = {},
    },
    {
        name = "Swift",
        filetypes = { "swift" },
        parsers = { "swift" },
        servers = { "sourcekit" }, -- ships with Xcode; restricted to Swift in after/lsp/sourcekit.lua
        formatters = { "swift_format" }, -- Apple's swift-format: in the Brewfile, and
                                                                          -- also bundled with the Xcode toolchain
    },
    {
        name = "Rust",
        filetypes = { "rust" },
        parsers = { "rust" },
        servers = { "rust_analyzer" }, -- installed via rustup
        formatters = { "rustfmt" },
    },
    {
        name = "Python",
        filetypes = { "python" },
        parsers = { "python" },
        -- ty: type checking + completion/hover/rename (Astral, see after/lsp/ty.lua).
        -- ruff: linting + import organization, hover disabled (see after/lsp/ruff.lua).
        servers = { "ty", "ruff" },
        formatters = { "ruff_format" }, -- add "ruff_organize_imports" before it to also sort imports
    },
    {
        name = "TOML",
        filetypes = { "toml" },
        parsers = { "toml" },
        servers = { "taplo" },
        formatters = { "taplo" },
    },
    {
        name = "YAML",
        filetypes = { "yaml" },
        parsers = { "yaml" },
        servers = { "yamlls" }, -- schemastore.org schemas enabled in after/lsp/yamlls.lua
        formatters = { "yamlfmt" },
    },
    {
        name = "XML",
        filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
        parsers = { "xml" }, -- one parser covers all five filetypes
        -- EMPTY, and this is the one place Neovim is behind the GUI editors.
        -- The only XML server nvim-lspconfig knows is lemminx, and lemminx has
        -- NO Homebrew formula — `brew search lemminx` finds nothing. Every
        -- other dependency in this repo comes from the Brewfile, and a
        -- hand-downloaded Java binary would be the only exception.
        -- Consequence: highlighting, indent and folds work; completion,
        -- validation against a schema and formatting do not. Zed (the `xml`
        -- extension) and VS Code (redhat.vscode-xml, which embeds lemminx)
        -- both have the full experience.
        -- To close the gap yourself: install lemminx from
        -- https://github.com/eclipse-lemminx/lemminx/releases onto $PATH, then
        -- change this to { "lemminx" }. Nothing else needs touching.
        servers = {},
        formatters = {},
    },
    {
        name = "Dockerfile",
        filetypes = { "dockerfile" },
        parsers = { "dockerfile" },
        -- docker-language-server (Docker's own Go binary), not the older
        -- dockerls, which needs docker-langserver from an npm package.
        -- Worth knowing: this server's filetypes are `dockerfile` and
        -- `yaml.docker-compose` — it deliberately does NOT claim plain `yaml`,
        -- so it cannot fight yamlls over an ordinary YAML file. Compose files
        -- only get it once Neovim resolves them to the compound filetype.
        servers = { "docker_language_server" }, -- brew install docker-language-server
        -- The server formats through the LSP, and there is no separate
        -- Dockerfile formatter worth installing.
        formatters = {},
    },
    {
        name = "Markdown",
        filetypes = { "markdown" },
        parsers = { "markdown", "markdown_inline" }, -- inline parser handles emphasis/links/code spans
        servers = { "marksman" }, -- link/reference completion, rename across files
        formatters = {}, -- markdown is usually formatted by hand; add "prettier" if you install it
    },
    {
        name = "Git files",
        filetypes = { "gitcommit", "gitconfig", "gitrebase", "gitattributes", "gitignore" },
        parsers = { "gitcommit", "git_config", "git_rebase", "gitattributes", "gitignore", "diff" },
        servers = {}, -- no mainstream git LSP exists; treesitter highlighting only
        formatters = {},
    },
    {
        name = "Shell (sh / bash / zsh)",
        filetypes = { "sh", "bash", "zsh" },
        parsers = { "bash" },
        -- No treesitter grammar or LSP exists for zsh. The alias below reuses the
        -- bash parser for zsh buffers — highlighting is ~95% right, the odd
        -- zsh-ism may render oddly. bash-language-server intentionally attaches
        -- only to sh/bash (its diagnostics would be wrong for zsh).
        parser_aliases = { zsh = "bash" },
        servers = { "bashls" }, -- + shellcheck/shfmt integration if installed (Brewfile)
        formatters = { "shfmt" },
    },
    {
        name = "Fish",
        filetypes = { "fish" },
        parsers = { "fish" },
        servers = { "fish_lsp" },
        formatters = { "fish_indent" }, -- ships with fish itself
    },
    {
        name = "Log files",
        filetypes = { "log" },
        -- Neovim ships syntax/log.vim, which highlights timestamps, log levels
        -- (ERROR/WARN/INFO), quoted strings and IP addresses — but it never gets
        -- a chance to run, because Neovim gives a plain *.log file NO filetype at
        -- all. Its built-in `detect.log` only recognises Vim's own upstream*.log
        -- development files. The three rules below fix that.
        extensions = { log = "log", LOG = "log", Log = "log" },
        -- Rotated logs: app.log.1, app.log.20260902 …
        patterns = {
            [".*%.log%.%d+"] = "log",
            -- Anything under a log directory, which is usually extensionless
            -- (system.log, install.log, wifi.log …).
            [".*/[Ll]ogs?/.*"] = "log",
            ["/var/log/.*"] = "log",
        },
        -- No treesitter grammar: nvim-treesitter's registry has no generic `log`
        -- parser (only `sflog`, for Salesforce). Vim's regex syntax file is the
        -- whole highlighting story here, and it needs no installation.
        parsers = {},
        -- No language server exists for a format this loose, and nothing to
        -- format either — logs are read, not written.
        servers = {},
        formatters = {},
    },
    {
        name = "Neovim config support (Lua, Vimscript, :help)",
        -- Not requested as a "language", but keeps editing THIS config and
        -- reading :help pleasant. Remove if you never touch Lua.
        filetypes = { "lua", "vim", "help", "query" },
        parsers = { "lua", "vim", "vimdoc", "query" },
        parser_aliases = { help = "vimdoc" },
        servers = {}, -- add "lua_ls" (brew install lua-language-server) for full Lua IDE support
        formatters = {}, -- add "stylua" if you install it
    },
}
