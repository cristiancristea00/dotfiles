# ==============================================================================
# conf.d/00-path.fish — PATH and toolchain environments
# ==============================================================================
#
# Runs first (00- prefix) because every later file assumes these tools are on
# PATH. Within the file, Homebrew comes first so that the toolchains after it
# can shadow Homebrew's copies.
# ==============================================================================

# --- Homebrew -----------------------------------------------------------------
# WHAT: Locate Homebrew and load its environment with `brew shellenv`.
# WHY : `shellenv` sets PATH, MANPATH, INFOPATH, and HOMEBREW_PREFIX together.
#       Prepending /opt/homebrew/bin by hand sets only PATH. It also works
#       only on Apple Silicon. The three prefixes are every location Homebrew
#       uses:
#         /opt/homebrew              Apple Silicon macOS
#         /usr/local                 Intel macOS
#         /home/linuxbrew/.linuxbrew Linux (the default shared prefix)
#       The first match wins; no machine has two. If none matches, `brew
#       shellenv` never runs and every Homebrew-installed tool is off PATH.
# HOW : See what it applies with: brew shellenv fish
for __brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew
    if test -x $__brew_prefix/bin/brew
        $__brew_prefix/bin/brew shellenv fish | source
        break
    end
end
set -e __brew_prefix

# --- Rust / cargo ----------------------------------------------------------------
# WHAT: Put ~/.cargo/bin on PATH: cargo, rustc, rustfmt, clippy, and
#       cargo-installed binaries such as rust-analyzer. The Neovim config
#       expects rust-analyzer on PATH.
# WHY : Sourcing rustup's generated env.fish rather than hardcoding the path
#       keeps working if rustup changes its layout or CARGO_HOME moves. The
#       file prepends the directory, so a rustup toolchain shadows a system
#       rustc.
# HOW : rustup writes ~/.cargo/env.fish at install time. Without rustup the
#       file is absent and the block is skipped. Install with:
#           brew install rustup && rustup-init
# NOTE: rustup also installs ~/.config/fish/conf.d/rustup.fish, which does the
#       same thing. It can be deleted; env.fish guards against prepending twice.
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# --- Extra user bin directories -------------------------------------------------
# WHAT: Directories of user-installed executables, prepended to PATH.
# WHY : No package manager this file knows about adds them:
#         ~/.local/bin       the XDG standard: pipx, `uv tool`, `pip --user`
#         ~/bin              personal scripts
#         ~/go/bin           `go install` target
#         ~/.bun/bin         Bun
#         ~/.npm-global/bin  npm with a user prefix
#         ~/.deno/bin        Deno
# HOW : Add a directory to the list; it is on PATH in the next shell.
# NOTE: Earlier entries win. A directory that does not exist is skipped.
#       `--path` edits PATH itself rather than $fish_user_paths, and never
#       touches universal scope; `--global` states the scope. Without `--path`,
#       fish_add_path defaults to a universal $fish_user_paths when no global
#       one exists, which persists to fish_variables (see
#       conf.d/20-options.fish).
for __extra_bin in ~/.local/bin ~/bin ~/go/bin ~/.bun/bin ~/.npm-global/bin ~/.deno/bin
    fish_add_path --global --path $__extra_bin
end
set -e __extra_bin
