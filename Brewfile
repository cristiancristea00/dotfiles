# ==============================================================================
# Brewfile — every external dependency of these dotfiles
# ==============================================================================
#
# Install or update everything with:
#
#     brew bundle --file ~/work/dotfiles/Brewfile
#
# or just run ./install.sh, which does this and everything around it.
#
# `brew bundle` is idempotent — already-installed entries are skipped — so
# re-running after adding a line is always safe. To find what is installed but
# NOT listed here:
#
#     brew bundle cleanup --file ~/work/dotfiles/Brewfile
#
# ── A BREWFILE IS RUBY ────────────────────────────────────────────────────────
#   That is what makes one file serve both platforms. `OS.mac?` and `OS.linux?`
#   are provided by Homebrew, and any entry can carry a trailing condition:
#
#       brew "gnupg" if OS.mac?
#
#   This matters because **casks are macOS-only**. Homebrew on Linux installs
#   formulae only, so every cask below is guarded — without the guard,
#   `brew bundle` fails on Linux at the first one.
#
#   `ENV["HOMEBREW_DOTFILES_CLI_ONLY"]` is set by `./install.sh --cli-only` and
#   skips the GUI applications, which is what you want on a server or in a
#   container.
#
#   THE HOMEBREW_ PREFIX IS MANDATORY. Homebrew sanitises its environment and
#   passes through only variables named HOMEBREW_*. A plain DOTFILES_CLI_ONLY
#   is silently stripped before this file is evaluated, so the guard would read
#   as nil and every GUI app would install anyway — with no error to tell you.
#
# ── NOT LISTED HERE ───────────────────────────────────────────────────────────
#   * clangd       — Xcode on macOS; an LLVM package on Linux (often versioned
#                    as clangd-18, with `clangd` via update-alternatives)
#   * sourcekit-lsp — Xcode on macOS; the swift.org toolchain on Linux
#   * rust-analyzer, rustfmt — rustup (see fish/conf.d/00-path.fish)
#   * fish_indent  — ships with fish itself
#   * Fonts on Linux — casks cannot install them and distro packaging is
#                    inconsistent, so install.sh prints the list and you install
#                    them by hand. See the root README's font matrix.
# ==============================================================================

# --- Fonts (macOS only: these are casks) ---------------------------------------
# The font stack used by every tool here, in fallback order. The two Nerd builds
# carry the icon glyphs Neovim draws; the rest are per-glyph fallbacks.
# See the root README for which surface uses which build.
cask "font-jetbrains-mono-nerd-font" if OS.mac?
cask "font-fira-code-nerd-font"      if OS.mac?
cask "font-fira-code"                if OS.mac?
cask "font-source-code-pro"          if OS.mac?
cask "font-ibm-plex-mono"            if OS.mac?

# --- Applications ------------------------------------------------------------------
# macOS gets all three as casks. On Linux, Neovide has a real formula so brew
# still handles it; Ghostty and Zed are cask-only, so install.sh installs them
# through the distribution's package manager instead.
cask "ghostty"     if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # terminal    -> ghostty/
cask "zed"         if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # GUI editor  -> zed/
cask "neovide-app" if OS.mac? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"]   # Neovim GUI  -> neovide/
brew "neovide"     if OS.linux? && !ENV["HOMEBREW_DOTFILES_CLI_ONLY"] # same, as a formula

# --- Dotfiles management -------------------------------------------------------------
# GNU stow creates the symlinks from this repo into $HOME. Required to install
# any of these configs — see the root README.
brew "stow"

# --- Shell and core CLI ---------------------------------------------------------------
brew "fish"          # the shell              -> fish/
brew "oh-my-posh"    # prompt                 -> fish/conf.d/30-prompt.fish
brew "eza"           # ls replacement         -> fish/functions/{ll,la,lt,lta}.fish
brew "bat"           # cat + syntax colour    -> bat/  (also $MANPAGER)
brew "fd"            # find replacement       -> fish/functions/{ff,fx,fd}.fish, fzf-lua
brew "ripgrep"       # grep replacement       -> fzf-lua live grep
brew "fzf"           # fuzzy matcher          -> fzf-lua
brew "tlrc"          # tldr client (installs the `tldr` binary) -> tlrc/

# --- Linux-only runtime dependencies ---------------------------------------------------
# WHAT: Clipboard providers for Neovim's `clipboard=unnamedplus`.
# WHY : macOS ships pbcopy/pbpaste, so Neovim finds a provider for free. Linux
#       has no built-in equivalent: without one of these, every yank silently
#       stops reaching the system clipboard and `:checkhealth vim.provider`
#       reports "No clipboard tool found". Both are installed because the right
#       one depends on the session — wl-clipboard for Wayland (the default on
#       current GNOME and KDE), xclip for X11 — and Neovim picks at runtime.
brew "wl-clipboard" if OS.linux?
brew "xclip"        if OS.linux?

# --- Git -----------------------------------------------------------------------------
brew "git-delta"     # diff pager             -> git/config [delta]
brew "gnupg"         # commit/tag signing     -> git/config [gpg]

# WHAT: Git Large File Storage.
# WHY : Required to clone the private font repository install.sh pulls from on
#       Linux — without it a clone yields text pointers where the fonts should
#       be. It is also what makes the [filter "lfs"] block in git/config work;
#       that block sets required = true, so a missing binary is a loud error
#       rather than silently committing pointer files.
brew "git-lfs"

# --- Neovim --------------------------------------------------------------------------
brew "neovim"        # the editor (config requires >= 0.12)

# REQUIRED for syntax highlighting: nvim-treesitter (main branch) compiles every
# parser via `tree-sitter build`. Without this CLI, no parser installs.
# (The similarly named "tree-sitter" formula is only the C library.)
brew "tree-sitter-cli"

# --- Language servers ------------------------------------------------------------------
# One per language entry in nvim/.config/nvim/lua/languages.lua.
brew "ty"                    # Python: type checking + IDE features (Astral)
brew "ruff"                  # Python: linting/formatting + LSP
brew "taplo"                 # TOML
brew "yaml-language-server"  # YAML (with schemastore.org schemas)
brew "marksman"              # Markdown
brew "bash-language-server"  # sh/bash
brew "fish-lsp"              # fish

# --- Formatters and linters ---------------------------------------------------------------
# Used by <leader>F in Neovim via conform.nvim. If one is missing, formatting
# falls back to the language server.
brew "clang-format"  # C/C++/ObjC — reads each project's .clang-format
brew "shfmt"         # shell scripts
brew "yamlfmt"       # YAML
brew "shellcheck"    # not a formatter: bash-language-server surfaces its lints

# WHAT: Apple's official Swift formatter.
# WHY : macOS-only here. It also ships inside Xcode, and on Linux Swift comes
#       from the swift.org toolchain, which bundles its own — so installing it
#       through brew there would be a second, possibly mismatched copy.
brew "swift-format" if OS.mac?
