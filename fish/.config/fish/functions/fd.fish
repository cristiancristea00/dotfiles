# WHAT: Wraps the `fd` binary so every invocation gets the shared default flags
#       from conf.d/20-options.fish ($COMMON_OPTIONS_FD).
# WHY : `command fd` is essential here — a bare `fd` would call THIS function
#       and recurse forever.
# HOW : Bypass the defaults entirely at any time with `command fd ...`.
function fd --description 'fd with shared default options'
    command fd $COMMON_OPTIONS_FD $argv
end
