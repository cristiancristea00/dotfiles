# WHAT: Long listing of the current (or given) directory, via eza.
# WHY : The eza tool replaces ls with icons, colour and better defaults. The shared flag
#       set lives in conf.d/20-options.fish as $COMMON_OPTIONS_EZA.
# HOW : `ll`, or `ll some/dir`. Any extra eza flag can be appended: `ll -r`.
function ll --description 'Long directory listing (eza)'
    eza $COMMON_OPTIONS_EZA $argv
end
