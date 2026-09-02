# WHAT: Full Homebrew maintenance pass: refresh the formula index, upgrade
#       everything, remove now-unused dependencies, then delete every cached
#       download.
# WHY : Named for how long it takes. `--prune=all` reclaims the most disk space
#       at the cost of re-downloading if you later reinstall.
#
# PLATFORM: `--greedy` is added only on macOS. It tells `brew upgrade` to also
#       upgrade casks that normally update themselves — and casks do not exist
#       on Linux, where Homebrew installs formulae only. Passing it there is
#       accepted but meaningless, so the flag is omitted to keep the command
#       honest about what it does.
# HOW : Just `coffee`. Preview first with `brew outdated` (add `--greedy` on
#       macOS to include self-updating casks).
function coffee --description 'Update, upgrade and clean Homebrew'
    if not type --query brew
        echo "coffee: Homebrew is not installed on this machine." >&2
        return 1
    end

    brew update; or return 1

    if test (uname -s) = Darwin
        brew upgrade --greedy; or return 1
    else
        brew upgrade; or return 1
    end

    brew autoremove; and brew cleanup --prune=all
end
