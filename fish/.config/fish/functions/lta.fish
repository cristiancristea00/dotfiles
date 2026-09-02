# WHAT: Like `lt`, but includes dotfiles.
function lta --description 'Directory tree including hidden files, 2 levels (eza)'
    eza $COMMON_OPTIONS_EZA --tree --level=2 --all $argv
end
