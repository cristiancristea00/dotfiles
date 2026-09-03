# ==============================================================================
# conf.d/25-theme.fish — colours that follow the terminal's light/dark theme
# ==============================================================================
#
# WHAT THIS FILE IS
#   The two Catppuccin surfaces the shell itself owns: fish's own syntax
#   highlighting, and the theme eza uses for its listings. Both follow the
#   terminal's appearance rather than being pinned to one flavour.
#
# THE SIGNAL BOTH USE
#   $fish_terminal_color_theme is a READ-ONLY fish variable holding `light`,
#   `dark`, or `unknown` when the terminal will not report its background. Two
#   properties of it shape everything below:
#     1. It is only populated ONCE THE FIRST INTERACTIVE PROMPT IS SHOWN, so
#        reading it directly at the top of this file yields an empty string.
#        Anything depending on it must run from an --on-variable handler.
#     2. It updates live when the terminal's theme changes, which is what makes
#        the colours flip with the system appearance and no shell restart.
#
#   Ghostty reports its background, so this works there. A terminal that does
#   not answer leaves the value `unknown`, and both settings below fall back to
#   the dark flavour — matching the rest of the stack's default.
# ==============================================================================

# WHAT: Guard everything here on an interactive shell.
# WHY : Colours are meaningless in a script, and the theme command below costs
#       time that a non-interactive fish invocation should not pay.
if status is-interactive

    # --- fish's own syntax highlighting -----------------------------------------
    # WHAT: Load the Catppuccin theme for fish's command-line colours — command
    #       names, errors, quotes, autosuggestions, the completion pager.
    # WHY : Since fish 4.4 the Catppuccin flavours ship WITH fish, so unlike
    #       every other tool here this needs nothing installed or fetched. List
    #       what is available with `fish_config theme list`.
    #       Naming the mocha theme also selects Latte automatically: each
    #       Catppuccin theme file carries a light and a dark variant, and fish
    #       applies the one matching $fish_terminal_color_theme, re-applying it
    #       whenever that changes. So this single line covers both appearances.
    # NOTE: `theme choose` loads the theme INTO THIS SESSION only. That is the
    #       property that makes it correct here — the alternative,
    #       `fish_config theme save`, writes the colours into fish's universal
    #       variables, which is machine state this repo deliberately keeps out
    #       of version control. Never use `save`.
    # HOW : Swap the flavour by changing the name: catppuccin-frappe,
    #       catppuccin-macchiato, catppuccin-mocha. To ignore the terminal and
    #       pin one appearance, append --color-theme=dark or --color-theme=light.
    #       Preview any of them with `fish_config theme demo`.
    fish_config theme choose catppuccin-mocha

    # --- eza -----------------------------------------------------------------
    # WHAT: Point $EZA_CONFIG_DIR at the directory holding the theme.yml for the
    #       current appearance.
    # WHY : The eza tool reads its theme from ONE file, $EZA_CONFIG_DIR/theme.yml,
    #       and has no light/dark form of its own. Two directories, each with its
    #       own theme.yml, plus this handler is what gives it one anyway.
    #       Both are written by install.sh, which fetches them from
    #       catppuccin/eza — they are not committed to this repo. If they are
    #       missing, eza falls back to its built-in colours and nothing breaks.
    # NOTE: This must be a handler, and it must be defined HERE rather than in
    #       functions/. Autoloaded functions are lazy, so an --on-variable
    #       handler placed there would never register and would never fire.
    # HOW : Change the accent by re-fetching a different variant in install.sh;
    #       the upstream port offers fourteen. Delete this block and the two
    #       directories to return eza to its own colours.
    function __eza_theme --on-variable fish_terminal_color_theme \
        --description 'Point eza at the theme matching the terminal appearance'
        switch "$fish_terminal_color_theme"
            case light
                set -gx EZA_CONFIG_DIR "$HOME/.config/eza-latte"
            case '*'
                # Covers `dark` and `unknown`. A terminal that will not report
                # its background gets the dark flavour, which is this stack's
                # default everywhere else.
                set -gx EZA_CONFIG_DIR "$HOME/.config/eza-mocha"
        end
    end

    # WHY: The handler only fires on a CHANGE, and the variable is still empty
    #      at this point in startup, so without this call eza would have no
    #      theme at all until the appearance was toggled once.
    __eza_theme

end
