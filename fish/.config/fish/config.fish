# ==============================================================================
# config.fish — fish shell entry point
# ==============================================================================
#
# WHAT THIS FILE IS
#   The last file fish sources at startup. Configuration lives in conf.d/ and
#   functions/, one file per concern, so this file stays empty.
#
# LOAD ORDER
#   1. fish's own share/config.fish
#   2. Vendor conf.d snippets (installed by Homebrew packages)
#   3. ~/.config/fish/conf.d/*.fish, in ASCII order (hence the 00-/10-/20-/30-
#      prefixes)
#   4. ~/.config/fish/config.fish (this file)
#   Functions in functions/ are not sourced at startup. fish autoloads
#   <name>.fish the first time <name> is called, so the file name must match
#   the function name inside it.
#
# MACHINE-LOCAL ADDITIONS
#   Machine- or employer-specific configuration goes in an uncommitted
#   conf.d/99-work.fish. The package is stowed with --no-folding, so
#   ~/.config/fish/conf.d/ is a real directory that can hold it. See
#   ../../../README.md § The stow model.
# ==============================================================================

# Everything is in conf.d/ and functions/; ../../README.md maps the files.
# Overrides that must run last go below this line.
