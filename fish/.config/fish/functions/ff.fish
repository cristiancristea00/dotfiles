# WHAT: Find files only (no directories).
# NOTE: Uses `command fd`, not the `fd` function. The function would prepend
#       $COMMON_OPTIONS_FD a second time.
# HOW : `ff pattern`, e.g. `ff '\.lua$'`.
function ff --description 'Find files (fd)'
    command fd $COMMON_OPTIONS_FD --type file $argv
end
