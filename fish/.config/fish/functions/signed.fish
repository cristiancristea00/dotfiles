# WHAT: Show the code signature of a binary, app bundle, or framework.
# WHY : `--verbose=2` prints the signing authority chain and the Team ID.
# HOW : `signed /Applications/Ghostty.app`
# PLATFORM: macOS only. `codesign` is part of the macOS toolchain; ELF binaries
#       carry no Mach-O signature or Team ID. The guard leaves the function
#       undefined on Linux, so `signed` reports "unknown command" rather than
#       failing inside the function, and one file serves both platforms.
if test (uname -s) = Darwin
    function signed --description 'Display a code signature (codesign)'
        codesign --display --verbose=2 $argv
    end
end
