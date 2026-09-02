# WHAT: Tree view, two levels deep.
# WHY : Two levels is the depth that stays readable in a terminal; deeper trees
#       scroll off the screen faster than they inform.
# HOW : `lt`, or override the depth: `lt --level=4`.
function lt --description 'Directory tree, 2 levels (eza)'
    eza $COMMON_OPTIONS_EZA --tree --level=2 $argv
end
