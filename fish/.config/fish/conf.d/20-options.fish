# ==============================================================================
# conf.d/20-options.fish — shell options and shared option variables
# ==============================================================================

# --- Greeting -------------------------------------------------------------------
# WHAT: The message fish prints on each new interactive shell.
# WHY : Empty suppresses the default "Welcome to fish" banner.
set -g fish_greeting

# --- Prompt path length ------------------------------------------------------------
# WHAT: Characters of each parent directory the prompt shows; 0 means full
#       names.
# WHY : Full names are unambiguous. The default, 1, shows only the initial of
#       each parent.
# NOTE: Every variable in this package has global scope (`set -g` or
#       `set -gx`), never universal (`set -U`). Universal variables persist to
#       fish_variables and are meant to be set once interactively. Set from a
#       startup file, they rewrite that state file on every shell start, and
#       they survive the line being removed. The same rule is why 25-theme.fish
#       uses `theme choose` rather than `theme save`; fish_add_path in
#       00-path.fish also defaults to universal scope.
set -g fish_prompt_pwd_dir_length 0

# --- Shared option sets -------------------------------------------------------------
# WHAT: Flag sets shared by the listing and search functions in functions/.
# WHY : Defined once here rather than in each function. The autoloaded
#       functions read these globals at call time, so renaming a variable
#       means updating functions/{ll,la,lt,lta}.fish or functions/{ff,fd,fx}.fish.
# HOW : `eza --help` and `fd --help` document every flag. --no-filesize,
#       --no-time, and --no-git keep the listing narrow; drop them to see more.
set -g COMMON_OPTIONS_EZA --absolute=off --classify=never --long --colour=always \
    --icons=always --no-quotes --sort=name --group-directories-last --header \
    --octal-permissions --no-filesize --no-time --no-git

# --hidden includes dotfiles, --follow follows symlinks, --prune skips
# descending into ignored directories.
set -g COMMON_OPTIONS_FD --hidden --color always --follow --prune

# --- Documented extension points (inactive) --------------------------------------------
# WHAT: The fzf shell integration: Ctrl-T (file picker), Ctrl-R (history
#       search), Alt-C (cd into a subdirectory).
# WHY : Off because Neovim owns fuzzy finding here, and the bindings replace
#       fish's own Ctrl-R history search.
# fzf --fish | source

# WHAT: The Catppuccin theme for fzf (github.com/catppuccin/fzf), a set of
#       --color flags in $FZF_DEFAULT_OPTS.
# WHY : Not applied. fzf draws with the terminal's ANSI colours, which
#       Ghostty's Catppuccin theme already sets, so fzf is Catppuccin and
#       follows light/dark as it is. The port hardcodes one flavour's hex
#       values and would pin it. Inside Neovim, fzf-lua takes its colours from
#       the colorscheme, so the port would change nothing there. With the
#       integration above off, only a bare `… | fzf` typed by hand is affected.
# NOTE: If you apply it, translate the snippet to `set -gx`; upstream uses
#       `set -Ux` (see the NOTE on fish_prompt_pwd_dir_length above).
