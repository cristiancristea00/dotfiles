# ==============================================================================
# conf.d/10-environment.fish — exported environment variables
# ==============================================================================

# --- Editor -------------------------------------------------------------------
# WHAT: The editor other programs launch (git commit messages, `crontab -e`,
#       anything honouring $EDITOR). VISUAL is the variant programs prefer
#       when a full-screen editor is usable.
# WHY : Matches core.editor in ../../../../git/.config/git/config.
set -gx EDITOR nvim
set -gx VISUAL nvim

# --- Homebrew ------------------------------------------------------------------
# WHAT: Suppress the tips Homebrew prints after most commands.
# WHY : They repeat the same advice on every run.
set -gx HOMEBREW_NO_ENV_HINTS 1

# --- Man pages -----------------------------------------------------------------
# WHAT: Render man pages through bat.
# WHY : `col -bx` strips the backspace-overstrike sequences groff emits for
#       bold and underline, which would otherwise show as literal characters;
#       `--plain` keeps bat's frame off so the page still looks like a man
#       page. MANROFFOPT=-c is required with it, or groff re-inserts the
#       overstrikes.
# NOTE: Guarded on `col`. It lives in util-linux on most distributions, but
#       Debian and Ubuntu ship it in `bsdextrautils`. Minimal container images
#       lack it. Without the guard `man` would fail on those systems instead of
#       falling back. macOS always has it.
# HOW : Unset both for plain `less`. Garbled pages with stray ^H sequences mean
#       `col` is missing: install bsdextrautils (Debian/Ubuntu) or util-linux.
if command --query col
    set -gx MANPAGER "sh -c 'col -bx | bat --language man --plain'"
    set -gx MANROFFOPT -c
end
