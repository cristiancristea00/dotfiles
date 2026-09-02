# ==============================================================================
# config.fish — fish shell entry point
# ==============================================================================
#
# WHAT THIS FILE IS
#   The last file fish sources at startup. It is deliberately almost empty:
#   configuration lives in conf.d/ and functions/ instead, so that adding or
#   removing a piece of behaviour is a single-file operation.
#
# LOAD ORDER (this trips people up — conf.d runs BEFORE this file)
#   1. fish's own share/config.fish
#   2. Vendor conf.d snippets (installed by Homebrew packages)
#   3. ~/.config/fish/conf.d/*.fish   <- sourced in ASCII sort order, hence the
#                                        00-/10-/20-/30- numeric prefixes
#   4. ~/.config/fish/config.fish     <- you are here
#   Functions in functions/ are NOT sourced at startup; fish autoloads
#   <name>.fish the first time <name> is called. That keeps startup fast and
#   means the file name MUST match the function name inside it.
#
# WHERE THINGS LIVE
#   conf.d/00-path.fish         PATH / Homebrew environment
#   conf.d/10-environment.fish  exported environment variables
#   conf.d/20-options.fish      shell options + shared option variables
#   conf.d/30-prompt.fish       prompt (oh-my-posh)
#   functions/*.fish            one autoloaded function per file
#
# MACHINE-LOCAL ADDITIONS
#   Anything specific to one machine or employer goes in an uncommitted
#   conf.d/99-work.fish, which fish sources like any other snippet. Because
#   this package is stowed with --no-folding, ~/.config/fish/conf.d/ is a real
#   directory where that file can sit beside the symlinks. See the README.
# ==============================================================================

# Nothing to do here — everything is in conf.d/ and functions/.
# Put genuinely last-word overrides below this line if you ever need them.
