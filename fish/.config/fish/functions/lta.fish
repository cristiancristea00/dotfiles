# WHAT: Like `lt`, but includes dotfiles.
# WHY : `--all` is the only difference.
# HOW : `lta`, or `lta some/dir`.
function lta --description 'Directory tree including hidden files, 2 levels (eza)'
    eza $COMMON_OPTIONS_EZA --tree --level=2 --all $argv
end
