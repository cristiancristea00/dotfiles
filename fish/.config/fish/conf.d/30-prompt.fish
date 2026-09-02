# ==============================================================================
# conf.d/30-prompt.fish — prompt
# ==============================================================================

# --- oh-my-posh ------------------------------------------------------------------
# WHAT: Initialise the oh-my-posh prompt, using the bundled multiverse-neon
#       theme.
# WHY : The guards matter as much as the command:
#         * `status is-interactive` — a prompt is meaningless in a script, and
#           initialising one there wastes time on every non-interactive fish
#           invocation.
#         * Apple Terminal is excluded because it cannot render the Nerd Font
#           powerline glyphs the theme uses; you would get boxes.
#         * Zed's integrated terminal is excluded because Zed draws its own
#           prompt decorations. NOTE: The file zed/.config/zed/settings.json
#           sets terminal.shell.program = fish, which is what makes $TERM_PROGRAM
#           equal "zed" here — the two files are coupled.
# HOW : Swap the theme by changing the filename; list the bundled ones with
#         ls (brew --prefix oh-my-posh)/themes/
#       Remove this whole block to fall back to fish's own (fast, plain) prompt.
if status is-interactive
    and type --query oh-my-posh
    and test "$TERM_PROGRAM" != Apple_Terminal
    and test "$TERM_PROGRAM" != zed
    oh-my-posh init fish --config "$(brew --prefix oh-my-posh)/themes/multiverse-neon.omp.json" | source
end
