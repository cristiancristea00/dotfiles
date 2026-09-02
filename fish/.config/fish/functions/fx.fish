# WHAT: Find executable files.
# HOW : `fx`, or `fx pattern` to narrow it down.
function fx --description 'Find executable files (fd)'
    command fd $COMMON_OPTIONS_FD --type executable $argv
end
