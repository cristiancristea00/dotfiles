# ==============================================================================
# conf.d/30-prompt.fish — prompt
# ==============================================================================

# --- oh-my-posh ------------------------------------------------------------------
# WHAT: Initialise the oh-my-posh prompt with the bundled Catppuccin theme.
# WHY : The guards:
#         * `status is-interactive`: scripts have no prompt, and init costs
#           startup time.
#         * `type --query brew`: the theme path is resolved through
#           `brew --prefix`, so an oh-my-posh installed another way would pass
#           the first guard and then print `brew: command not found` on every
#           shell start, with no prompt.
#         * Apple Terminal is excluded because it cannot render the Nerd Font
#           powerline glyphs the theme uses; they show as boxes. The test is
#           inert on Linux, where $TERM_PROGRAM is never that value. Zed, VS
#           Code, and Cursor select the Nerd Font in their own settings files,
#           so their terminals are not excluded. VS Code and Cursor both report
#           $TERM_PROGRAM as "vscode", so a test for one applies to the other.
# NOTE: Bundled theme filenames end in `.omp.json`; `.json` points at nothing
#       and oh-my-posh fails on every interactive shell start.
# NOTE: oh-my-posh takes one config path and has no light/dark form, so the
#       prompt cannot follow the system appearance. `catppuccin.omp.json` is
#       its own Catppuccin-styled design; catppuccin_{latte,frappe,macchiato,
#       mocha}.omp.json each pin a flavour.
# HOW : Swap the theme by changing the filename; list them with
#         ls (brew --prefix oh-my-posh)/themes/
#       With oh-my-posh installed outside Homebrew, replace the `brew --prefix`
#       substitution with $POSH_THEMES_PATH. Remove the block for fish's own
#       prompt.
if status is-interactive
    and type --query oh-my-posh
    and type --query brew
    and test "$TERM_PROGRAM" != Apple_Terminal
    oh-my-posh init fish --config "$(brew --prefix oh-my-posh)/themes/catppuccin.omp.json" | source

    # --- Blank line before the prompt ---------------------------------------
    # WHAT: Wrap the fish_prompt oh-my-posh defined so every prompt is preceded
    #       by an empty line.
    # WHY : Command output would otherwise run straight into a two-line prompt.
    #       The theme's own `"newline": true` on its first block is not used
    #       because the theme file lives in the Homebrew prefix, and
    #       `brew upgrade` would revert the edit.
    # NOTE: oh-my-posh owns fish_prompt. A version that redefines it after init
    #       would drop this wrapper and the blank line with it; if that happens,
    #       ship a copy of the theme in this repo with `"newline": true` on its
    #       first block.
    # NOTE: The `--erase` is required: `functions --copy` fails if the
    #       destination exists, so a re-source would abort here. Erasing an
    #       absent function is a no-op. Init has just redefined fish_prompt, so
    #       the copy is always the original and can never nest.
    # HOW : Delete this block for the compact prompt. To put the blank line
    #       after the prompt, move the `echo` below the inner call.
    functions --erase __posh_wrapped_prompt
    functions --copy fish_prompt __posh_wrapped_prompt
    function fish_prompt --description 'oh-my-posh prompt, preceded by a blank line'
        echo ''
        __posh_wrapped_prompt
    end
end
