# WHAT: Show the code signature of a binary, app bundle or framework.
# WHY : --verbose=2 is the level that prints the signing authority chain and
#       the Team ID, which is what you actually want to check.
# HOW : `signed /Applications/Ghostty.app`
function signed --description 'Display a code signature (codesign)'
    codesign --display --verbose=2 $argv
end
