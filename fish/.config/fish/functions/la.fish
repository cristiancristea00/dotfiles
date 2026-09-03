# WHAT: Like `ll`, but includes dotfiles.
# WHY : `--all` is the only difference; the shared flags are $COMMON_OPTIONS_EZA
#       from conf.d/20-options.fish.
# HOW : `la`, or `la some/dir`.
function la --description 'Long directory listing including hidden files (eza)'
    eza $COMMON_OPTIONS_EZA --all $argv
end
