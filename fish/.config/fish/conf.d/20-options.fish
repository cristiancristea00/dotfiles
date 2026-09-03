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

# WHAT: The Catppuccin theme for fzf (github.com/catppuccin/fzf), which sets
#       $FZF_DEFAULT_OPTS to a list of --color flags.
# WHY : Deliberately NOT applied, and worth stating because every other tool in
#       this setup is themed. Applying it would make fzf look worse, not better:
#         * Left to itself, fzf draws with the terminal's ANSI colours, which
#           Ghostty's Catppuccin theme already sets. So fzf is Catppuccin today
#           AND follows light/dark for free.
#         * The port hardcodes hex values for one flavour, which would pin it
#           and lose that.
#         * Inside Neovim it would change nothing anyway — fzf-lua derives its
#           colours from the active colorscheme, which is Catppuccin.
#       With the shell integration above off, the only thing left for it to
#       affect is a bare `… | fzf` typed by hand.
# NOTE: If you ever do apply it, translate the snippet. Upstream uses
#       `set -Ux`, which writes to fish's UNIVERSAL variables — machine state
#       that survives outside this repo and cannot be undone by removing a
#       line here. Use `set -gx` instead, the same trap documented for
#       fish_add_path in conf.d/00-path.fish.
