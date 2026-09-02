# WHAT: Like `ll`, but includes dotfiles.
# HOW : `la`, or `la some/dir`.
function la --description 'Long directory listing including hidden files (eza)'
    eza $COMMON_OPTIONS_EZA --all $argv
end
