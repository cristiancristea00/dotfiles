# ==============================================================================
# Brewfile — every external dependency of these dotfiles
# ==============================================================================
#
# Install or update everything with `brew bundle --file ~/personal/dotfiles/Brewfile`,
# or run ./install.sh, which does this and the rest. `brew bundle` skips
# entries already installed. `brew bundle cleanup --file <this file>` lists
# what is installed but not declared here.
#
# A BREWFILE IS RUBY
#   `OS.mac?` and `OS.linux?` come from Homebrew, and any entry can carry a
#   trailing condition. Casks are macOS-only (Homebrew on Linux installs
#   formulae only), so every cask is guarded; without the guard `brew bundle`
#   fails on Linux at the first one.
#
#   `ENV["HOMEBREW_DOTFILES_CLI_ONLY"]` is set by `./install.sh --cli-only`
#   and skips the GUI applications. The HOMEBREW_ prefix is required: Homebrew
#   passes only HOMEBREW_* variables through to this file, so a plain
#   DOTFILES_CLI_ONLY would read as nil and every GUI app would install.
#
#   `ENV["HOMEBREW_DOTFILES_AI_TOOLS"]` is set by ./install.sh to the AI tool
#   ids chosen in its menu or with --ai-tools, space-separated, or to `none`.
#   Unset, as in a bare `brew bundle`, it selects every AI tool, so this file
#   still declares all of them and `brew bundle cleanup` does not list an
#   installed one for removal.
#
# NOT LISTED HERE
#   * clangd: Xcode on macOS; an LLVM package on Linux, often versioned as
#     clangd-18 with `clangd` through update-alternatives.
#   * sourcekit-lsp: Xcode on macOS; the swift.org toolchain on Linux.
#   * rust-analyzer and rustfmt: rustup (see fish/conf.d/00-path.fish).
#   * fish_indent: ships with fish.
#   * AI tools on Linux: every one is a cask, so install.sh installs the CLIs
#     with npm or the vendor's script and prints the desktop apps' download
#     pages (install.sh § 6c).
#   * Fonts on Linux: casks cannot install them, so install.sh fetches them
#     from a private repository (README.md § The font stack).
#
# Each line names what the package is and which config uses it, in the
# trailing comment.
# ==============================================================================

# --- Fonts (macOS only: these are casks) ---------------------------------------
# The font stack, in fallback order; the two Nerd builds carry the icons Neovim
# draws. README.md § The font stack says which surface uses which build.
cask "font-jetbrains-mono-nerd-font" if OS.mac? # primary font, Nerd build -> ghostty/, nvim/, neovide/, and the zed/, vscode/, cursor/ terminals
cask "font-fira-code-nerd-font"      if OS.mac? # first fallback, Nerd build  -> the same surfaces
cask "font-fira-code"                if OS.mac? # fallback                    -> every font stack, and the zed/ and vscode/ editor panes
cask "font-source-code-pro"          if OS.mac? # fallback                    -> every font stack
cask "font-ibm-plex-mono"            if OS.mac? # fallback                    -> every font stack

# --- Applications ------------------------------------------------------------------
# Every application this repo configures is declared here or, for the AI
# tools, under AI coding agents, so the Brewfile and the package list match.
# macOS gets all four below as casks. On Linux, Neovide has a formula. Ghostty
# and Zed are cask-only, so install.sh uses the distribution's package manager.
# Visual Studio Code is installed by hand: it needs Microsoft's apt or dnf
# repository (a signing key and a sources file), and install.sh adds no
# third-party system repository.
#     https://code.visualstudio.com/docs/setup/linux
cask "ghostty"            if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # terminal    -> ghostty/
cask "zed"                if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # GUI editor  -> zed/
cask "neovide-app"        if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # Neovim GUI  -> neovide/
cask "visual-studio-code" if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # GUI editor  -> vscode/
brew "neovide"     if OS.linux? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"] # Neovim GUI, as a formula -> neovide/

# --- Dotfiles management -------------------------------------------------------------
brew "stow"          # GNU stow links this repo into $HOME -> install.sh, README.md § The stow model

# --- Shell and core CLI ---------------------------------------------------------------
brew "fish"          # the shell                          -> fish/
brew "oh-my-posh"    # prompt                             -> fish/conf.d/30-prompt.fish
brew "eza"           # ls replacement                     -> fish/functions/{ll,la,lt,lta}.fish
brew "bat"           # cat with syntax highlighting       -> bat/, and $MANPAGER in fish/conf.d/10-environment.fish
brew "fd"            # find replacement                   -> fish/functions/{ff,fx,fd}.fish, fzf-lua
brew "ripgrep"       # grep replacement                   -> fzf-lua live grep
brew "fzf"           # fuzzy matcher                      -> fzf-lua
brew "tlrc"          # tldr client (the `tldr` binary)    -> tlrc/

# --- Linux-only runtime dependencies ---------------------------------------------------
# WHAT: Clipboard providers for Neovim's `clipboard=unnamedplus`.
# WHY : macOS ships pbcopy and pbpaste; Linux has no built-in equivalent, and
#       without one every yank stops reaching the system clipboard
#       (`:checkhealth vim.provider` reports "No clipboard tool found"). Both
#       are installed because the right one depends on the session, and
#       Neovim picks at runtime.
brew "wl-clipboard" if OS.linux? # Wayland, the default on current GNOME and KDE
brew "xclip"        if OS.linux? # X11

# --- AI coding agents ------------------------------------------------------------------
# WHAT: Each vendor's desktop app and CLI, installed only if selected in
#       install.sh's menu or with --ai-tools; the comment's first word is the
#       id. The agents read the agents/ instruction file.
# WHY : All are casks, so they are macOS-only here (see NOT LISTED HERE for
#       Linux). The desktop apps are also skipped by --cli-only; the CLIs are
#       not.
# HOW : The ids and their Linux install methods are in install.sh's
#       AI_TOOL_TABLE; a new tool needs a line there and one here.
ai_tools = ENV["HOMEBREW_DOTFILES_AI_TOOLS"]
ai_tool = ->(id) { ai_tools.nil? || ai_tools.split.include?(id) }
gui = !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]
cask "claude"          if OS.mac? && gui && ai_tool.("claude-desktop")  # claude-desktop: Claude Desktop          -> agents/
cask "claude-code"     if OS.mac? && ai_tool.("claude-cli")             # claude-cli: Claude Code, as `claude`     -> agents/ (~/.claude/CLAUDE.md)
cask "cursor"          if OS.mac? && gui && ai_tool.("cursor-app")      # cursor-app: the Cursor editor            -> cursor/
cask "cursor-cli"      if OS.mac? && ai_tool.("cursor-cli")             # cursor-cli: Cursor's agent, as `cursor-agent`
# NOTE: The codex-app id installs the chatgpt cask. OpenAI ships the Codex
#       desktop app inside ChatGPT, and the codex-app cask is deprecated.
cask "chatgpt"         if OS.mac? && gui && ai_tool.("codex-app")       # codex-app: the ChatGPT app, with Codex   -> agents/
cask "codex"           if OS.mac? && ai_tool.("codex-cli")              # codex-cli: OpenAI's Codex CLI            -> agents/ (~/.codex/AGENTS.md)
cask "antigravity"     if OS.mac? && gui && ai_tool.("antigravity-app") # antigravity-app: the Antigravity App     -> agents/
cask "antigravity-cli" if OS.mac? && ai_tool.("antigravity-cli")        # antigravity-cli: Google's agent, as `agy` -> agents/ (~/.gemini/AGENTS.md)
cask "antigravity-ide" if OS.mac? && gui && ai_tool.("antigravity-ide") # antigravity-ide: the Antigravity IDE    -> antigravity-ide/, agents/
# WHAT: Node.js, for npm.
# WHY : On Linux, install.sh installs the Claude Code and Codex CLIs with
#       `npm install -g`, the vendors' method there; Homebrew's node keeps the
#       global prefix writable without sudo. Nothing else here needs it.
brew "node" if OS.linux? && (ai_tool.("claude-cli") || ai_tool.("codex-cli")) # npm -> install.sh § 6c

# --- Git -----------------------------------------------------------------------------
brew "git-delta"     # diff pager               -> git/config [delta]
brew "gnupg"         # commit and tag signing   -> git/config [gpg]
# WHAT: Git Large File Storage.
# WHY : Required to clone the private font repository install.sh fetches from
#       on Linux; without it a clone yields text pointers instead of fonts.
#       The [filter "lfs"] block in git/config sets required = true, so a
#       missing binary is an error rather than a checkout of pointer files.
brew "git-lfs"       # large-file filters       -> git/config [filter "lfs"], install.sh fonts

# --- Neovim --------------------------------------------------------------------------
brew "neovim"        # the editor; the config needs 0.12 or later -> nvim/
# WHAT: The tree-sitter command-line tool.
# WHY : nvim-treesitter compiles every parser with `tree-sitter build`; without
#       the CLI no parser installs. The "tree-sitter" formula is the C library
#       only and does not provide it.
brew "tree-sitter-cli" # parser compiler -> nvim/lua/plugins/treesitter.lua

# --- Language servers ------------------------------------------------------------------
# One per language entry in nvim/.config/nvim/lua/languages.lua.
brew "ty"                    # Python type checking and IDE features (Astral) -> languages.lua, vscode extension astral-sh.ty
brew "ruff"                  # Python linting, formatting, and LSP           -> languages.lua, ruff/, vscode extension charliermarsh.ruff
brew "taplo"                 # TOML server and formatter                     -> languages.lua
# WHAT: The JSON language server, extracted from VS Code.
# WHY : The binary nvim-lspconfig's `lsp/jsonls.lua` invokes is
#       `vscode-json-language-server`, and this formula is what provides it.
#       Without it every .json and .jsonc buffer reports a server that cannot
#       start.
# NOTE: The formula carries four further servers from the same extraction:
#       HTML, CSS, ESLint, and Markdown. None is enabled, because
#       languages.lua declares no entry that names them; Markdown keeps
#       marksman, listed below.
brew "vscode-langservers-extracted" # JSON and JSONC server (VS Code's)      -> languages.lua, nvim/after/lsp/jsonls.lua
brew "yaml-language-server"  # YAML server, with schemastore.org schemas     -> languages.lua, nvim/after/lsp/yamlls.lua
brew "marksman"              # Markdown server: links and references         -> languages.lua
brew "bash-language-server"  # sh and bash server                            -> languages.lua
brew "fish-lsp"              # fish server                                   -> languages.lua
brew "neocmakelsp"           # CMake server; the same one Zed's `neocmake` extension uses -> languages.lua
brew "docker-language-server" # Dockerfile and Compose server (Docker's own)  -> languages.lua
brew "gopls"                 # Go server; needs the `go` toolchain below     -> languages.lua, vscode extension golang.go, zed
brew "ruby-lsp"              # Ruby server; also formats (pulls the ruby formula) -> languages.lua, zed `ruby` extension
# WHAT: The Zig language server.
# WHY : The zls server and the zig compiler are version-locked; zls's README: "When
#       upgrading Zig, make sure to update ZLS to keep them in sync." A
#       `brew upgrade` that moves one and not the other leaves zls unable to
#       start, and the symptom is a server that stops attaching with no error
#       naming the cause. Homebrew makes zig a dependency of zls, so they
#       install together. Check with `zig version` and `zls --version`.
brew "zls"                   # Zig server                                    -> languages.lua, zed `zig` extension
# NOTE: XML has no line here. Its server, lemminx, has no Homebrew formula, so
#       the Neovim XML entry is treesitter-only; Zed and VS Code bundle
#       lemminx in their extensions. See the XML entry in languages.lua.
# NOTE: RuboCop has no line either, and no line among the formatters below.
#       It is a gem, not a formula, so `brew search rubocop` finds nothing.
#       ruby-lsp serves formatting itself and delegates to whichever of
#       RuboCop, Standard, or Syntax Tree the project's own bundle carries,
#       which is the version the project pins; a Homebrew RuboCop would be a
#       second, unpinned one. See the Ruby entry in languages.lua.

# --- Language toolchains -------------------------------------------------------------------
# WHAT: The Go and Zig compilers.
# WHY : Rust comes from rustup and Swift from Xcode (see NOT LISTED HERE), but
#       Go and Zig have no version manager in this setup, and Homebrew carries
#       both. The gopls server runs the `go` command to resolve modules, and zls reads
#       the Zig standard library from the compiler's installation. Installing
#       zls pulls zig anyway; the line declares the compiler as a dependency
#       in its own right, so `brew bundle` reinstalls it if zls is removed.
brew "go"            # Go toolchain   -> gopls, goimports, staticcheck, delve
brew "zig"           # Zig toolchain  -> zls, `zig fmt`

# --- Formatters and linters ---------------------------------------------------------------
# Used by <leader>F in Neovim through conform.nvim; a missing one falls back to
# the language server.
brew "clang-format"  # C, C++, Objective-C; reads each project's .clang-format -> languages.lua
brew "shfmt"         # shell scripts                                          -> languages.lua
brew "yamlfmt"       # YAML                                                   -> languages.lua
brew "shellcheck"    # shell linter, surfaced by bash-language-server         -> languages.lua (bashls)
brew "goimports"     # Go: gofmt's rules plus import management               -> languages.lua
brew "staticcheck"   # Go linter; gopls can surface it, the Go extension offers it -> vscode extension golang.go
# NOTE: Zig needs no formatter line. The zigfmt entry in languages.lua runs
#       `zig fmt`, which ships inside the compiler above.

# --- Debuggers -----------------------------------------------------------------------------
# WHAT: The Go debugger.
# WHY : The `golang.go` extension in VS Code and Cursor otherwise offers to
#       `go install` it on the first debug session into ~/go/bin, which
#       fish/conf.d/00-path.fish puts on PATH, but that leaves an undeclared
#       tool on the machine. Nothing in this repo configures a debugger; Neovim
#       has no DAP setup.
brew "delve"         # Go debugger    -> vscode extension golang.go

# WHAT: Apple's Swift formatter.
# WHY : macOS-only. On Linux the swift.org toolchain bundles its own, so a
#       brew copy there would be a second, possibly mismatched one.
brew "swift-format" if OS.mac? # Swift formatter -> languages.lua
