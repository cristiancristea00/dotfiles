# WHAT: Wrap the fd binary so every call gets $COMMON_OPTIONS_FD from
#       conf.d/20-options.fish.
# NOTE: `command fd` is required. A bare `fd` would call this function and
#       recurse.
# HOW : Bypass the defaults with `command fd ...`.
function fd --description 'fd with shared default options'
    command fd $COMMON_OPTIONS_FD $argv
end
