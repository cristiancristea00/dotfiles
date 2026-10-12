# WHAT: Show the code signature of a binary, app bundle, or framework.
# WHY : Level 3 prints the signing authority chain, the Team ID, and the
#       CDHash, the code directory hash that identifies one exact signed build.
#       Level 2 omits the CDHash. Level 4 adds only the minimum OS and SDK
#       versions and the executable segment layout.
# HOW : `signed /Applications/Ghostty.app`
# PLATFORM: macOS only. `codesign` is part of the macOS toolchain; ELF binaries
#       carry no Mach-O signature or Team ID. The guard leaves the function
#       undefined on Linux, so `signed` reports "unknown command" rather than
#       failing inside the function, and one file serves both platforms.
if test (uname -s) = Darwin
    function signed --description 'Display a code signature (codesign)'
        codesign --display --verbose=3 $argv
    end
end
