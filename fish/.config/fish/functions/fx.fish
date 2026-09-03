# WHAT: Find executable files.
# NOTE: Uses `command fd`, not the `fd` function, for the reason given in
#       ff.fish.
# HOW : `fx`, or `fx pattern` to narrow it down.
function fx --description 'Find executable files (fd)'
    command fd $COMMON_OPTIONS_FD --type executable $argv
end
