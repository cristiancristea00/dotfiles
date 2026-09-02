# ==============================================================================
# conf.d/10-environment.fish — exported environment variables
# ==============================================================================

# --- Editor -------------------------------------------------------------------
# WHAT: The editor other programs launch (git commit messages, `crontab -e`,
#       anything honouring $EDITOR).
# WHY : Matches core.editor in the git config, so there is one answer to
#       "which editor opens?" no matter who asks. VISUAL is the variant
#       programs prefer when they know a full-screen editor is usable.
set -gx EDITOR nvim
set -gx VISUAL nvim

# --- Homebrew ------------------------------------------------------------------
# WHAT: Suppress Homebrew's "hints" (the tips printed after most commands).
# WHY : They repeat endlessly once you know them.
set -gx HOMEBREW_NO_ENV_HINTS 1

# --- Man pages -----------------------------------------------------------------
# WHAT: Render man pages through bat for syntax highlighting and paging.
# WHY : `col -bx` strips the backspace-overstrike sequences groff emits for
#       bold/underline, which would otherwise show as literal garbage; `-p`
#       keeps bat's decorations off so the page still looks like a man page.
#       MANROFFOPT=-c is required alongside it — without it groff re-inserts
#       the overstrikes and the output is mangled.
# HOW : Unset both to get the plain `less` experience back.
set -gx MANPAGER "sh -c 'col -bx | bat --language man --plain'"
set -gx MANROFFOPT -c
