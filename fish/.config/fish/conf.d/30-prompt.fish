# ==============================================================================
# conf.d/30-prompt.fish — prompt
# ==============================================================================

# --- oh-my-posh ------------------------------------------------------------------
# WHAT: Initialise the oh-my-posh prompt, using the bundled Catppuccin theme.
# NOTE: Every bundled theme's filename ends `.omp.json`, not `.json` — the
#       shorter form points at nothing, and oh-my-posh then fails on every
#       interactive shell start. List what is actually there with
#         ls (brew --prefix oh-my-posh)/themes/
#       oh-my-posh takes ONE config path and has no light/dark form, so unlike
#       Ghostty, bat and Zed the prompt cannot follow the system appearance.
#       The flavour files (catppuccin_latte, _frappe, _macchiato, _mocha) pin a
#       single flavour; the plain `catppuccin.omp.json` used here is its own
#       Catppuccin-styled design rather than a flavour variant.
# WHY : The guards matter as much as the command:
#         * `status is-interactive` — a prompt is meaningless in a script, and
#           initialising one there wastes time on every non-interactive fish
#           invocation.
#         * `type --query brew` is not redundant with the oh-my-posh check: the
#           theme path below is resolved through `brew --prefix`, so a machine
#           with oh-my-posh installed some other way (its own installer, `go
#           install`, a distro package) would pass the first guard and then
#           fail inside the command substitution — printing `brew: command not
#           found` on every single interactive shell start, with no prompt.
#         * Apple Terminal is excluded because it cannot render the Nerd Font
#           powerline glyphs the theme uses; you would get boxes. The check is
#           inert on Linux, where $TERM_PROGRAM is never that value.
#           No other terminal is excluded. An earlier version also skipped Zed,
#           on the theory that Zed decorates its own prompt; it does not, and
#           the result was a plain fish prompt in one terminal and oh-my-posh
#           in every other. Zed, VS Code and Cursor all ship the Nerd Font that
#           the theme needs, configured in their own settings files, so the
#           prompt renders correctly in all three. Beware if you add a test
#           here: VS Code AND Cursor both report $TERM_PROGRAM as "vscode", so
#           a test written for one silently applies to the other.
# HOW : Swap the theme by changing the filename; list the bundled ones with
#         ls (brew --prefix oh-my-posh)/themes/
#       For a flavour-matched prompt instead, use catppuccin_macchiato.omp.json.
#       If you ever install oh-my-posh outside Homebrew, replace the
#       `brew --prefix` substitution with $POSH_THEMES_PATH.
#       Remove this whole block to fall back to fish's own (fast, plain) prompt.
if status is-interactive
    and type --query oh-my-posh
    and type --query brew
    and test "$TERM_PROGRAM" != Apple_Terminal
    oh-my-posh init fish --config "$(brew --prefix oh-my-posh)/themes/catppuccin.omp.json" | source
end
