# WHAT: Find files only (no directories).
# WHY : Uses `command fd`, NOT the `fd` function above. Calling the function
#       would prepend $COMMON_OPTIONS_FD a second time, so every flag was
#       passed twice — harmless to fd, but wrong. This is the fixed form,
#       matching how `fx` was already written.
# HOW : `ff pattern`, e.g. `ff '\.lua$'`.
function ff --description 'Find files (fd)'
    command fd $COMMON_OPTIONS_FD --type file $argv
end
