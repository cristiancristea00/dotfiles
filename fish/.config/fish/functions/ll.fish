# WHAT: Long listing of the current (or given) directory, via eza.
# WHY : eza replaces ls with icons and colour. The shared flags are
#       $COMMON_OPTIONS_EZA from conf.d/20-options.fish.
# HOW : `ll`, or `ll some/dir`. Extra eza flags can be appended: `ll -r`.
function ll --description 'Long directory listing (eza)'
    eza $COMMON_OPTIONS_EZA $argv
end
