# WHAT: Homebrew maintenance: refresh the index, upgrade everything, remove
#       unused dependencies, and delete every cached download.
# WHY : `--prune=all` reclaims the most disk space; a later reinstall
#       re-downloads.
# PLATFORM: `--greedy` (also upgrade casks that update themselves) is passed
#       only on macOS. Linux Homebrew has no casks, so there the flag is
#       accepted but does nothing.
# HOW : `coffee`. Preview with `brew outdated` (`--greedy` on macOS).
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
