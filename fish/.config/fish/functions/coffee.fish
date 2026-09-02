# WHAT: Full Homebrew maintenance pass: refresh the formula index, upgrade
#       everything (--greedy also upgrades casks that auto-update themselves),
#       remove now-unused dependencies, then delete every cached download.
# WHY : Named for how long it takes. `--prune=all` reclaims the most disk space
#       at the cost of re-downloading if you later reinstall.
# HOW : Just `coffee`. Preview first with `brew outdated --greedy`.
function coffee --description 'Update, upgrade and clean Homebrew'
    brew update && brew upgrade --greedy && brew autoremove && brew cleanup --prune=all
end
