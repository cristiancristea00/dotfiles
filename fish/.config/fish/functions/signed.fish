# WHAT: Show the code signature of a binary, app bundle or framework.
# WHY : --verbose=2 is the level that prints the signing authority chain and
#       the Team ID, which is what you actually want to check.
# HOW : `signed /Applications/Ghostty.app`
#
# PLATFORM: macOS only. `codesign` is part of the macOS/Xcode toolchain and has
#       no Linux equivalent — Mach-O code signatures and Team IDs are an Apple
#       concept, and ELF binaries do not carry them. The guard means that on
#       Linux the function is simply never defined, so `signed` reports
#       "unknown command" instead of failing confusingly inside the function.
#       Guarding here rather than deleting the file keeps one shell config for
#       both platforms.
if test (uname -s) = Darwin
    function signed --description 'Display a code signature (codesign)'
        codesign --display --verbose=2 $argv
    end
end
