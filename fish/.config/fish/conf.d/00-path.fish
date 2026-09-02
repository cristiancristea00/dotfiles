# ==============================================================================
# conf.d/00-path.fish — PATH and toolchain environments
# ==============================================================================
#
# Runs first (00- prefix) because everything after it assumes these tools are
# on PATH. Order within the file matters too: Homebrew first, then toolchains
# that should be able to override Homebrew's copies.
# ==============================================================================

# --- Homebrew -----------------------------------------------------------------
# WHAT: Locate Homebrew and load its environment via `brew shellenv`.
# WHY : `shellenv` sets PATH, MANPATH, INFOPATH and HOMEBREW_PREFIX together
#       and always in the right order. The previous approach hardcoded
#       `set -x PATH /opt/homebrew/bin $PATH`, which set only PATH and broke
#       everywhere else. The three probed prefixes are every location Homebrew
#       uses:
#         /opt/homebrew              Apple Silicon macOS
#         /usr/local                 Intel macOS
#         /home/linuxbrew/.linuxbrew Linux (the default, shared prefix)
#       Order matters only in that the first match wins, and no machine has two.
# NOTE: This is the single most load-bearing line in the shell config. If no
#       prefix matches, `brew shellenv` never runs and every tool installed
#       through Homebrew — eza, fd, bat, oh-my-posh, every language server —
#       silently falls off PATH.
# HOW : To see exactly what it applies, run: brew shellenv fish
for __brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew
    if test -x $__brew_prefix/bin/brew
        $__brew_prefix/bin/brew shellenv fish | source
        break
    end
end
set -e __brew_prefix

# --- Rust / cargo ----------------------------------------------------------------
# WHAT: Put ~/.cargo/bin on PATH — cargo, rustc, rustfmt, clippy, and the
#       cargo-installed binaries (rust-analyzer, cargo-generate, …).
# WHY : Sourcing rustup's own generated env.fish rather than hardcoding the
#       path means rustup stays the authority: if it ever changes its layout
#       or CARGO_HOME moves, this keeps working. The file prepends the
#       directory, so a rustup toolchain deliberately shadows any
#       system-installed rustc.
#       This also matters outside the shell: the Neovim config expects
#       rust-analyzer on PATH, and it comes from exactly this directory.
# HOW : The rustup installer writes ~/.cargo/env.fish at install time. If you
#       have never run rustup on this machine the file is absent and the block
#       is skipped, so a Rust-less machine is fine. Install with:
#           brew install rustup && rustup-init
# NOTE: The rustup installer also drops a ~/.config/fish/conf.d/rustup.fish
#       doing the same thing. It is redundant with this block (env.fish guards
#       against double-prepending, so having both is harmless) and can be
#       deleted — this file covers it and is version-controlled.
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
