# ==============================================================================
# conf.d/25-theme.fish — colours that follow the terminal's light/dark theme
# ==============================================================================
#
# WHAT THIS FILE IS
#   The Catppuccin surfaces the shell owns: fish's own syntax highlighting,
#   eza's listing theme, and delta's flavour. All three follow the terminal's
#   appearance. See ../../../../README.md § Light and dark.
#
# THE SIGNAL
#   $fish_terminal_color_theme is a read-only fish variable holding `light`,
#   `dark`, or `unknown` (the terminal did not report its background; Ghostty
#   reports it). It is empty until the first interactive prompt is shown, so
#   anything reading it must run from an --on-variable handler. Each handler is
#   also called once by hand below. The variable updates when the terminal's
#   theme changes, so the handlers re-run without a shell restart. On
#   `unknown`, fish and eza use the dark flavour, the stack's default. delta is
#   left to detect the background itself.
# ==============================================================================

# WHAT: Guard everything here on an interactive shell.
# WHY : Scripts have no use for colours, and the theme command below costs
#       startup time.
if status is-interactive

    # --- fish's own syntax highlighting -----------------------------------------
    # WHAT: Load the Catppuccin theme for fish's command-line colours (command
    #       names, errors, quotes, autosuggestions, the completion pager).
    # WHY : Since fish 4.4 the Catppuccin themes ship with fish, so nothing is
    #       installed or fetched. Each theme file carries a light and a dark
    #       variant; fish applies the one matching $fish_terminal_color_theme
    #       and re-applies it when that changes, so naming the mocha theme also
    #       selects Latte.
    # NOTE: `theme choose` loads the theme into this session. `fish_config theme
    #       save` would write the colours into universal variables, which is
    #       machine state outside the repo (see conf.d/20-options.fish). Never
    #       use `save`.
    # HOW : Other flavours: catppuccin-frappe, catppuccin-macchiato. Append
    #       --color-theme=dark or --color-theme=light to pin one appearance.
    #       `fish_config theme list` and `fish_config theme demo` show them.
    fish_config theme choose catppuccin-mocha

    # --- eza -----------------------------------------------------------------
    # WHAT: Point $EZA_CONFIG_DIR at the directory holding the theme.yml for the
    #       current appearance.
    # WHY : eza reads one file, $EZA_CONFIG_DIR/theme.yml, and has no light/dark
    #       form, so two directories and this handler give it one. install.sh
    #       fetches both from catppuccin/eza; they are not committed (see
    #       ../../../../README.md § Fetched themes). If they are missing, eza
    #       uses its built-in colours.
    # NOTE: The handler must be defined here, not in functions/: autoloaded
    #       functions load lazily, so an --on-variable handler there never
    #       registers.
    # HOW : Change the accent by fetching a different variant in install.sh (the
    #       port offers fourteen). Delete this block and the two directories to
    #       return eza to its own colours.
    function __eza_theme --on-variable fish_terminal_color_theme \
        --description 'Point eza at the theme matching the terminal appearance'
        switch "$fish_terminal_color_theme"
            case light
                set -gx EZA_CONFIG_DIR "$HOME/.config/eza-latte"
            case '*'
                # `dark` and `unknown`: the dark flavour, the stack's default.
                set -gx EZA_CONFIG_DIR "$HOME/.config/eza-mocha"
        end
    end

    # WHAT: Run the handler once at startup.
    # WHY : Handlers fire only on a change, and the variable is still empty here,
    #       so eza would have no theme until the appearance was toggled.
    __eza_theme

    # --- delta ---------------------------------------------------------------
    # WHAT: Name delta's Catppuccin flavour through $DELTA_FEATURES.
    # WHY : The delta pager takes one value for its feature set, with no
    #       light/dark form, so the shell chooses. The variable replaces any `features` line in
    #       the git config, so ../../../../git/.config/git/config sets none; the
    #       `[delta]` block there documents the mechanism and delta's fallback.
    #       The flavour names come from ~/.config/git/catppuccin.gitconfig,
    #       which install.sh fetches.
    # NOTE: On `unknown` this erases the variable instead of falling back to
    #       Mocha as eza does: delta can detect the background itself and eza
    #       cannot. Erasing removes the variable from the environment child
    #       processes see; an empty value would not.
    # HOW : To pin one flavour, replace the switch with
    #       `set -gx DELTA_FEATURES catppuccin-mocha`. To take delta out of this
    #       file, delete the block and set `features` in the git config.
    function __delta_theme --on-variable fish_terminal_color_theme \
        --description 'Point delta at the Catppuccin flavour matching the terminal'
        switch "$fish_terminal_color_theme"
            case light
                set -gx DELTA_FEATURES catppuccin-latte
            case dark
                set -gx DELTA_FEATURES catppuccin-mocha
            case '*'
                # `unknown`, and the empty value before the first prompt. `set -e`
                # on an unset variable returns 4; nothing checks the status.
                set -e DELTA_FEATURES
        end
    end

    # WHAT: Run the handler once at startup.
    # WHY : The variable is empty here, so this takes the '*' branch and leaves
    #       $DELTA_FEATURES unset rather than inherited from the parent process.
    __delta_theme

end
