# ==============================================================================
# conf.d/20-options.fish — shell options and shared option variables
# ==============================================================================

# --- Greeting -------------------------------------------------------------------
# WHAT: The message fish prints on every new interactive shell.
# WHY : Set to empty to suppress it — the default "Welcome to fish" banner adds
#       nothing after the first day.
set -g fish_greeting

# --- Prompt path length ------------------------------------------------------------
# WHAT: How many characters of each parent directory the prompt shows;
#       0 means "don't abbreviate, show full names".
# WHY : This was previously `set -U` (universal). Universal variables persist
#       to fish_variables and are meant to be set ONCE interactively — setting
#       one from a startup file rewrites that state file on every single shell
#       start. `set -g` is the correct scope for a config-driven value.
set -g fish_prompt_pwd_dir_length 0

# --- Shared option sets -------------------------------------------------------------
# WHAT: Flag sets shared by the listing/search functions in functions/.
# WHY : Defined here (a startup file) rather than inside each function so the
#       flags are stated once. The autoloaded functions in functions/ read
#       these globals at call time — if you rename a variable here, update
#       functions/{ll,la,lt,lta}.fish or functions/{ff,fd,fx}.fish to match.
# HOW : `eza --help` / `fd --help` document every flag. --no-filesize,
#       --no-time and --no-git keep the listing narrow; drop them to see more.
set -g COMMON_OPTIONS_EZA --absolute=off --classify=never --long --colour=always \
    --icons=always --no-quotes --sort=name --group-directories-last --header \
    --octal-permissions --no-filesize --no-time --no-git

# --hidden includes dotfiles, --follow follows symlinks, --prune skips
# descending into ignored directories.
set -g COMMON_OPTIONS_FD --hidden --color always --follow --prune

# --- Documented extension points (inactive) --------------------------------------------
# WHAT: The fzf shell integration — Ctrl-T (file picker), Ctrl-R (history search),
#       Alt-C (cd into a subdirectory).
# WHY : Left off because Neovim already owns fuzzy finding here and the
#       bindings override fish's own Ctrl-R history search. Uncomment to try.
# fzf --fish | source
