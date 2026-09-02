# ==============================================================================
# Brewfile — every external dependency of these dotfiles
# ==============================================================================
#
# Install or update everything with:
#
#     brew bundle --file ~/work/dotfiles/Brewfile
#
# `brew bundle` is idempotent — already-installed entries are skipped — so
# re-running after adding a line is always safe. To find what is installed but
# NOT listed here:
#
#     brew bundle cleanup --file ~/work/dotfiles/Brewfile
#
# NOT listed here, because they are managed by other toolchains:
#   * clangd, sourcekit-lsp   — ship with Xcode
#   * rust-analyzer, rustfmt  — ship with rustup (see fish/conf.d/00-path.fish)
#   * fish_indent             — ships with fish itself
# ==============================================================================

# --- Fonts ----------------------------------------------------------------------
# The font stack used by every tool here, in fallback order. The Nerd Font build
# carries the icon glyphs Neovim draws; the other three are per-glyph fallbacks.
# See the root README for which surface uses which build.
cask "font-jetbrains-mono-nerd-font"
cask "font-fira-code"
cask "font-source-code-pro"
cask "font-ibm-plex-mono"

# --- Applications ------------------------------------------------------------------
cask "ghostty"       # terminal emulator      -> ghostty/
cask "zed"           # GUI editor             -> zed/
cask "neovide-app"   # Neovim GUI             -> neovide/

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

# --- Git -----------------------------------------------------------------------------
brew "git-delta"     # diff pager             -> git/config [delta]
brew "gnupg"         # commit/tag signing     -> git/config [gpg]

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
brew "swift-format"  # Swift — Apple's official formatter (also ships inside
                     # Xcode; the formula keeps it on PATH independently of
                     # which Xcode is selected)
brew "shfmt"         # shell scripts
brew "yamlfmt"       # YAML
brew "shellcheck"    # not a formatter: bash-language-server surfaces its lints
