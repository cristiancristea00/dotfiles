#!/usr/bin/env bash
# ==============================================================================
# install.sh — take a fresh macOS or Linux machine from `git clone` to a
#              working environment
# ==============================================================================
#
# USAGE
#     ./install.sh [OPTIONS]
#
#     --dry-run            Show every action without changing anything.
#     --cli-only           Skip GUI applications (Ghostty, Zed, Neovide,
#                          Visual Studio Code, Cursor).
#     --packages a,b,c     Only handle the named stow packages.
#     --uninstall          Remove the symlinks this script created.
#     --yes, -y            Answer yes to every prompt. Required for
#                          non-interactive runs: without a terminal the script
#                          refuses prompts rather than assuming consent.
#     --help, -h           This message.
#
# WHAT IT DOES, IN ORDER
#     1. Detect OS, distribution, and package manager.
#     2. Install Homebrew's prerequisites (Linux only).
#     3. Install Homebrew if missing, and put it on PATH for this run.
#     4. `brew bundle` the repo's Brewfile.
#     5. Install GUI apps that Homebrew cannot provide (Linux only).
#     6. Back up anything in the way, then stow every package.
#     7. Create the per-OS selector symlinks that stow cannot express.
#     8. Bootstrap Neovim, install the editors' extensions, prime the tldr
#        cache, and offer to set fish as the login shell.
#     9. Print what happened and what needs restarting.
# ==============================================================================
#
# DESIGN
#   Bash 3.2. macOS ships bash 3.2, and `#!/usr/bin/env bash` finds it there,
#   so nothing from bash 4 or later is used: no associative arrays, no
#   `mapfile`, no `${var,,}`. Check with `/bin/bash -n install.sh` on macOS.
#
#   Idempotency. Re-running applies repo changes. A symlink that resolves into
#   this repo is the script's own and is replaced without a prompt; anything
#   else is the user's and is only ever moved to a backup, never deleted.
#   `is_ours` is the test.
#
#   Best effort after linking. Every step after the configuration is linked
#   (themes, extensions, the Neovim bootstrap, the tldr cache, the login shell)
#   warns on failure and continues, because the linked configuration is the
#   part only this script provides.
#
#   Prompts. `confirm` takes a per-call default and, without a terminal,
#   refuses; `--yes` answers yes without a keyboard. `chsh` and `sudo` prompt
#   on their own and cannot be fed an answer, so the login-shell step is gated
#   on `[ -t 0 ]` and `--yes` does not override that. The `sudo` calls in the
#   Linux package steps are not gated: those installs cannot proceed without
#   them, and the one that is optional sits behind `confirm`.
#
#   The stow model, the per-OS mechanisms, and the font stack are documented
#   in README.md; this file points at those sections rather than repeating
#   them.
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

# WHAT: The repository root, resolved from this script's own location.
# WHY : The script runs from any working directory
#       (`~/personal/dotfiles/install.sh` works as well as `./install.sh`).
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# WHAT: Packages stowed with directory folding: the whole directory becomes one
#       symlink into the repo.
# WHY : Correct when nothing else needs to live in that directory. `nvim` is
#       folded so that nvim-pack-lock.json, which vim.pack writes into the
#       config directory, lands in the repo. See README.md § The stow model.
PACKAGES_FOLD="nvim ruff tlrc"

# WHAT: Packages stowed with --no-folding: the directory stays real and each
#       file is linked individually.
# WHY : Required when a directory must hold machine-local state beside the
#       symlinks: runtime state the application writes (fish's fish_variables,
#       Zed's conversations/, the theme file install.sh fetches for delta), or
#       one of the OS selector symlinks created in step 7 (bat, ghostty,
#       neovide).
PACKAGES_NOFOLD="bat fish ghostty git neovide zed"

# WHAT: Packages stowed with --no-folding and a per-OS --ignore, in a third
#       invocation of their own.
# WHY : Visual Studio Code and Cursor read their settings from an XDG path on
#       Linux and from ~/Library/Application Support on macOS, and neither
#       format has a conditional, so each package ships both trees and
#       EDITOR_IGNORE filters out the wrong one at link time. --no-folding
#       because User/ also holds globalStorage/, History/, and
#       workspaceStorage/, all machine-local. The invocation is separate
#       because --ignore is a per-run flag; applied to PACKAGES_NOFOLD it would
#       remove the fish, ghostty, git, and zed trees.
PACKAGES_EDITOR="vscode cursor"

# WHAT: The regex that selects one of the two trees each editor package ships,
#       and the matching path prefix backup_conflicts skips.
# WHY : Stow's --ignore drops matching path elements, so ignoring the tree the
#       platform does not use leaves one deployed. The function
#       detect_platform sets both, because it is the only one that knows the
#       OS, and the two must agree: the walker must not check the undeployed
#       tree for conflicts.
EDITOR_IGNORE=""
EDITOR_SKIP_PREFIX=""

# WHAT: Fonts the configs reference, for the message printed when they cannot
#       be installed automatically.
# WHY : The "Mono" suffix on the two Nerd builds is not decoration: those are
#       the single-width builds the configs name, and FONT_SELECTION below
#       fetches exactly those files. Naming the plain builds here would send
#       the reader after the double-width ones, whose icons break the grid.
FONTS_NEEDED="JetBrainsMono Nerd Font Mono, FiraCode Nerd Font Mono, JetBrains Mono, Fira Code, Source Code Pro, IBM Plex Mono"

# WHAT: A private repository mirroring the fonts this setup uses, stored with
#       Git LFS.
# WHY : Homebrew installs fonts through casks, which are macOS-only, and Linux
#       distribution font packaging varies too much to script. On Linux the
#       fonts come from this repository; macOS gets the casks. README.md § The
#       font stack lists the families and where each is used.
# HOW : Access needs an SSH key belonging to the account that owns it. If the
#       probe fails (no key, no access, offline) the fonts step is skipped with
#       a message and the install continues.
FONTS_REPO="git@github.com:cristiancristea00/fonts.git"
FONTS_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-fonts"

# WHAT: Which directories to install, and which files from each.
# WHY : The repository is about 317 MB because the Nerd families ship every
#       width build, but the configs reference only the single-width "Mono"
#       ones. Fetching per file rather than per directory downloads about
#       70 MB. The four small families are taken whole.
# HOW : One "directory|glob" pair per line. Git LFS matches the glob and
#       downloads only the matching binaries.
FONT_SELECTION=$(cat <<'SELECTION'
JetBrains Mono Nerd|JetBrainsMonoNerdFontMono-*
Fira Code Nerd|FiraCodeNerdFontMono-*
JetBrains Mono|*
Fira Code|*
Source Code Pro|*
IBM Plex Mono|*
SELECTION
)

# ==============================================================================
# Options, populated by parse_args
# ==============================================================================
DRY_RUN=0
CLI_ONLY=0
UNINSTALL=0
ASSUME_YES=0
PACKAGES_REQUESTED=""

# Filled in by detect_platform.
OS=""
DISTRO=""
PKG_MANAGER=""
BACKUP_DIR=""

# ==============================================================================
# Output helpers
# ==============================================================================
# WHAT: Colour codes, emitted only when stdout is a terminal.
# WHY : A log file or CI transcript then holds no escape sequences.
if [ -t 1 ]; then
    C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
    C_BLUE=$'\033[34m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
else
    C_RESET=""; C_BOLD=""; C_DIM=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""
fi

step()  { printf '\n%s==> %s%s\n' "$C_BOLD$C_BLUE" "$*" "$C_RESET"; }
info()  { printf '    %s\n' "$*"; }
ok()    { printf '    %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf '    %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()   { printf '\n%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# WHAT: Echo a command in dry-run mode, otherwise run it.
# WHY : One wrapper keeps --dry-run in step with what the script does; there is
#       no second code path.
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '    %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
    else
        "$@"
    fi
}

# WHAT: Ask a yes/no question. The first argument is the default, `yes` or
#       `no`, which Enter selects and the [Y/n] / [y/N] hint shows. The rest
#       is the prompt.
# WHY : The default differs per question: backing files up destroys nothing,
#       so Enter accepts it; enabling a package repository or changing the
#       login shell does not happen on Enter.
# NOTE: Without a terminal on stdin this refuses rather than assuming yes. A
#       non-tty default of yes would let a piped run move the user's configs
#       aside unasked; `--yes` is the way to consent without a keyboard.
confirm() {
    local default="$1"
    shift

    if [ "$ASSUME_YES" -eq 1 ]; then
        return 0
    fi

    if [ ! -t 0 ]; then
        warn "No terminal to ask on: $*"
        warn "Re-run with --yes to answer yes to prompts like this one."
        return 1
    fi

    local hint reply
    if [ "$default" = "yes" ]; then hint="[Y/n]"; else hint="[y/N]"; fi
    printf '    %s %s ' "$*" "$hint" >&2
    read -r reply

    case "$reply" in
        [yY] | [yY][eE][sS]) return 0 ;;
        [nN] | [nN][oO]) return 1 ;;
        "") [ "$default" = "yes" ] && return 0 || return 1 ;;
        *) return 1 ;;
    esac
}

# WHAT: True if $1 is already provided by this repository.
# WHY : Anything that resolves into the repo was created by a previous run or
#       by stow and can be replaced; anything else is the user's file and is
#       backed up. This is the test the idempotency rule in the header rests
#       on.
# HOW : Two cases. A path belongs to the repo if it is a symlink into it (a
#       --no-folding package: ~/.config/bat/config.darwin) or if a parent
#       directory is (a folded package: ~/.config/nvim is one symlink, so
#       ~/.config/nvim/lua/theme.lua is a plain file reached through it).
#       Testing only for a leaf symlink would treat every file in a folded
#       package as the user's and back up the whole deployed config on each
#       run. `pwd -P` resolves symlinked parents, which covers the second
#       case.
is_ours() {
    local path="$1" resolved
    [ -e "$path" ] || [ -L "$path" ] || return 1

    if [ -L "$path" ]; then
        # Resolve the link target relative to the directory holding the link,
        # so the relative targets stow creates work.
        resolved="$(cd "$(dirname "$path")" 2>/dev/null \
            && cd "$(dirname "$(readlink "$path")")" 2>/dev/null && pwd -P)" || return 1
    else
        resolved="$(cd "$(dirname "$path")" 2>/dev/null && pwd -P)" || return 1
    fi

    case "$resolved/" in
        "$DOTFILES_DIR"/*) return 0 ;;
        *) return 1 ;;
    esac
}

# WHAT: Print the help text: the header's title, USAGE, and WHAT IT DOES
#       blocks.
# WHY : The header is the single copy of that text.
# NOTE: The line range must be updated when the header changes.
usage() { sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# ==============================================================================
# 1. Argument parsing
# ==============================================================================
# WHAT: Set the option variables above from the command line.
# NOTE: `--packages` takes its list as a separate argument or with `=`, so
#       both `--packages nvim` and `--packages=nvim` work.
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --dry-run)   DRY_RUN=1 ;;
            --cli-only)  CLI_ONLY=1 ;;
            --uninstall) UNINSTALL=1 ;;
            -y | --yes)  ASSUME_YES=1 ;;
            -h | --help) usage; exit 0 ;;
            --packages)
                shift
                [ $# -gt 0 ] || die "--packages needs a comma-separated list"
                # WHY: Commas become spaces, so the value has the same form as
                #      PACKAGES_FOLD and PACKAGES_NOFOLD.
                PACKAGES_REQUESTED="$(printf '%s' "$1" | tr ',' ' ')"
                ;;
            --packages=*)
                PACKAGES_REQUESTED="$(printf '%s' "${1#*=}" | tr ',' ' ')"
                ;;
            *) die "unknown option: $1 (try --help)" ;;
        esac
        shift
    done
}

# WHAT: Filter a package list down to what --packages asked for.
# WHY : Each group is filtered separately, so a selective run still stows each
#       package the way that package requires.
select_packages() {
    local candidates="$1" pkg want result=""
    [ -n "$PACKAGES_REQUESTED" ] || { printf '%s' "$candidates"; return; }
    for pkg in $candidates; do
        for want in $PACKAGES_REQUESTED; do
            [ "$pkg" = "$want" ] && result="$result $pkg"
        done
    done
    printf '%s' "${result# }"
}

# ==============================================================================
# 2. Platform detection
# ==============================================================================
# WHAT: Identify the OS, and on Linux the distribution and its package manager.
# WHY : Three things depend on it: Homebrew's prerequisites, the GUI
#       applications, and which per-OS config variant is linked. An
#       unrecognised distribution is not an error, because Homebrew works on
#       most of them.
detect_platform() {
    step "Detecting platform"

    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)  OS="linux" ;;
        *) die "unsupported operating system: $(uname -s). This setup targets macOS and Linux." ;;
    esac

    if [ "$OS" = "linux" ]; then
        # /etc/os-release is the systemd-era standard, present on every
        # mainstream distribution.
        if [ -r /etc/os-release ]; then
            # shellcheck disable=SC1091
            DISTRO="$(. /etc/os-release && printf '%s' "${ID:-unknown}")"
        else
            DISTRO="unknown"
        fi

        # WHY: Probing for the binary rather than trusting the distro ID also
        #      covers derivatives (Mint uses apt, Manjaro uses pacman).
        if   command -v apt-get >/dev/null 2>&1; then PKG_MANAGER="apt"
        elif command -v dnf     >/dev/null 2>&1; then PKG_MANAGER="dnf"
        elif command -v pacman  >/dev/null 2>&1; then PKG_MANAGER="pacman"
        else PKG_MANAGER="none"
        fi
    fi

    # WHY: macOS reads the editors' settings from Library/, so the .config tree
    #      is dropped there, and the reverse on Linux. The pattern is a regex
    #      matched against each path element, hence the escaped dot.
    if [ "$OS" = "macos" ]; then
        EDITOR_IGNORE='\.config'
        EDITOR_SKIP_PREFIX=".config/"
    else
        EDITOR_IGNORE='Library'
        EDITOR_SKIP_PREFIX="Library/"
    fi

    ok "OS: $OS${DISTRO:+ ($DISTRO)}"
    ok "Architecture: $(uname -m)"
    [ "$OS" = "linux" ] && ok "Package manager: $PKG_MANAGER"
    [ "$DRY_RUN" -eq 1 ] && warn "DRY RUN — nothing will be changed"
    return 0
}

# ==============================================================================
# 3. Homebrew prerequisites (Linux only)
# ==============================================================================
# WHAT: Install the compiler and utilities Homebrew needs before it runs.
# WHY : macOS gets these from the Command Line Tools, which Homebrew's own
#       installer handles. On Linux they must exist first. An unknown package
#       manager is a warning; the tools may already be present.
install_prerequisites() {
    [ "$OS" = "linux" ] || return 0
    command -v brew >/dev/null 2>&1 && return 0

    step "Installing Homebrew prerequisites"
    case "$PKG_MANAGER" in
        apt)
            run sudo apt-get update
            run sudo apt-get install -y build-essential procps curl file git
            ;;
        dnf)
            run sudo dnf group install -y development-tools
            run sudo dnf install -y procps-ng curl file git
            ;;
        pacman)
            run sudo pacman -Sy --needed --noconfirm base-devel procps-ng curl file git
            ;;
        *)
            warn "Unrecognised package manager; skipping prerequisites."
            warn "Homebrew needs: a C compiler, procps, curl, file, git."
            warn "Install them with your distribution's tools, then re-run."
            return 0
            ;;
    esac
    ok "Prerequisites installed"
}

# ==============================================================================
# 4. Homebrew
# ==============================================================================
# WHAT: Install Homebrew if absent, then put it on PATH for the rest of this run.
# WHY : The installer does not modify the running shell, so without evaluating
#       `brew shellenv` here every later step (brew bundle, stow, nvim) would
#       fail with "command not found" on a machine where Homebrew was just
#       installed.
install_homebrew() {
    step "Homebrew"

    if command -v brew >/dev/null 2>&1; then
        ok "Already installed: $(command -v brew)"
    else
        info "Installing Homebrew from the official installer…"
        run /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Probe every prefix Homebrew uses; fish/conf.d/00-path.fish probes the
    # first three, and the fourth is a per-user Linuxbrew install.
    local prefix
    for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
        if [ -x "$prefix/bin/brew" ]; then
            eval "$("$prefix/bin/brew" shellenv)"
            ok "Using $prefix"
            return 0
        fi
    done

    [ "$DRY_RUN" -eq 1 ] && return 0
    die "Homebrew is not on PATH after installation. Open a new shell and re-run."
}

# ==============================================================================
# 5. Brewfile
# ==============================================================================
# WHAT: Install everything the Brewfile declares.
# WHY : The Brewfile guards its own entries with OS.mac?, OS.linux?, and the
#       CLI-only variable, so one file and one command serve both platforms.
#       The variable must be HOMEBREW_-prefixed; the Brewfile header explains.
install_brewfile() {
    step "Installing packages from the Brewfile"
    [ -f "$DOTFILES_DIR/Brewfile" ] || die "No Brewfile at $DOTFILES_DIR"

    # WHY : A failed entry is not fatal. `brew bundle` fails the whole run if
    #       any single entry fails, and the common causes (a font already
    #       installed by hand that the cask refuses to adopt, a formula
    #       unavailable on this platform) should not stop the configuration
    #       from being linked. The failure is reported and `brew bundle check`
    #       lists what is missing.
    local bundle_status=0
    if [ "$CLI_ONLY" -eq 1 ]; then
        info "CLI-only: GUI applications will be skipped"
        run env HOMEBREW_DOTFILES_CLI_ONLY=1 \
            brew bundle install --file "$DOTFILES_DIR/Brewfile" || bundle_status=$?
    else
        run brew bundle install --file "$DOTFILES_DIR/Brewfile" || bundle_status=$?
    fi

    if [ "$bundle_status" -eq 0 ]; then
        ok "Brewfile applied"
    else
        warn "Some Brewfile entries failed to install (exit $bundle_status)."
        warn "Continuing — configuration will still be linked."
        warn "List what is missing with:"
        warn "  brew bundle check --verbose --file \"$DOTFILES_DIR/Brewfile\""
    fi
}

# ==============================================================================
# 6. GUI applications Homebrew cannot install (Linux only)
# ==============================================================================
# WHAT: Install Ghostty and Zed through the distribution's package manager.
# WHY : Both are Homebrew casks, and casks are macOS-only. Neovide has a
#       formula, so the Brewfile handled it.
# NOTE: Visual Studio Code and Cursor are casks too and are not handled here.
#       Code needs Microsoft's third-party apt or dnf repository and Cursor
#       ships only an AppImage; this script adds no system repository and
#       fetches no third-party package, which is also why it does not fetch
#       Ghostty's community .deb. Their configuration still deploys; the
#       Brewfile carries the download links. Every step here warns and
#       continues, because packaging varies between distributions.
install_gui_apps_linux() {
    [ "$OS" = "linux" ] || return 0
    [ "$CLI_ONLY" -eq 0 ] || return 0

    step "GUI applications"

    if command -v ghostty >/dev/null 2>&1; then
        ok "Ghostty already installed"
    else
        case "$PKG_MANAGER" in
            pacman) run sudo pacman -S --needed --noconfirm ghostty || warn "Ghostty install failed" ;;
            apt)
                # Ghostty entered the Ubuntu archive in 26.04. Older releases
                # need the community .deb, which this script does not fetch.
                if run sudo apt-get install -y ghostty; then
                    ok "Ghostty installed"
                else
                    warn "Ghostty is not in this release's archive (it landed in Ubuntu 26.04)."
                    warn "See https://ghostty.org/docs/install/binary for the community package."
                fi
                ;;
            dnf)
                info "Ghostty on Fedora comes from a COPR repository."
                if confirm no "Enable the scottames/ghostty COPR?"; then
                    # Sequential ifs, not `A && B || C`: with the latter, C also
                    # runs when A succeeds but B fails, so a failed install
                    # would be reported twice and a failed COPR not at all.
                    if run sudo dnf copr enable -y scottames/ghostty; then
                        run sudo dnf install -y ghostty || warn "Ghostty install failed"
                    else
                        warn "Could not enable the COPR; skipping Ghostty"
                    fi
                else
                    warn "Skipped Ghostty. See https://ghostty.org/docs/install/binary"
                fi
                ;;
            *) warn "Cannot install Ghostty automatically. See https://ghostty.org/docs/install/binary" ;;
        esac
    fi

    if command -v zed >/dev/null 2>&1; then
        ok "Zed already installed"
    else
        case "$PKG_MANAGER" in
            pacman) run sudo pacman -S --needed --noconfirm zed || warn "Zed install failed" ;;
            *)
                # Debian and Fedora have no official Zed package. The upstream
                # method is `curl … | sh`, which this script does not run:
                # piping a remote script into a shell is the user's decision.
                warn "Zed has no official package for $PKG_MANAGER."
                warn "Install it yourself from https://zed.dev/download (or Flathub: dev.zed.Zed)."
                ;;
        esac
    fi
}

# ==============================================================================
# 6b. Fonts from the private repository (Linux only)
# ==============================================================================
# WHAT: Install the font families the configs reference, from the private LFS
#       repository, into the user font directory.
# WHY : macOS gets fonts from Homebrew casks, which do not exist on Linux.
# NOTE: Every failure here is a warning. Without the fonts Neovim's icons
#       render as boxes; the rest of the install is unaffected.
install_fonts_linux() {
    [ "$OS" = "linux" ] || return 0

    step "Fonts"

    if ! command -v git-lfs >/dev/null 2>&1; then
        warn "git-lfs is not installed, so the font repository cannot be used."
        warn "Install these by hand instead: $FONTS_NEEDED"
        return 0
    fi

    # WHY : BatchMode stops ssh prompting for a passphrase or host key, which
    #       would hang the install. ConnectTimeout keeps an unreachable host
    #       from stalling the run; macOS has no `timeout` binary, so ssh does
    #       this itself.
    info "Checking access to the font repository…"
    if ! GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5' \
        git ls-remote "$FONTS_REPO" >/dev/null 2>&1; then
        warn "Cannot reach $FONTS_REPO"
        warn "It is private, so this usually means the SSH key on this machine"
        warn "does not belong to the account that owns it. Note that GitHub"
        warn "reports a missing repository rather than a permission error."
        warn "Install these by hand instead: $FONTS_NEEDED"
        return 0
    fi

    # WHY : GIT_LFS_SKIP_SMUDGE makes the clone fetch pointers only; without it
    #       the clone downloads every binary in the repository (317 MB) before
    #       anything can choose. `git lfs pull --include` below then downloads
    #       only the files that will be installed.
    if [ -d "$FONTS_CACHE/.git" ]; then
        info "Updating the font cache…"
        run git -C "$FONTS_CACHE" fetch --depth 1 origin main || warn "Font fetch failed"
        run git -C "$FONTS_CACHE" reset --hard origin/main || warn "Font reset failed"
    else
        info "Fetching the font repository (pointers only)…"
        run mkdir -p "$(dirname "$FONTS_CACHE")"
        if ! GIT_LFS_SKIP_SMUDGE=1 run git clone --depth 1 "$FONTS_REPO" "$FONTS_CACHE"; then
            warn "Could not clone the font repository."
            warn "Install these by hand instead: $FONTS_NEEDED"
            return 0
        fi
    fi

    [ "$DRY_RUN" -eq 1 ] && { info "Would install: $FONTS_NEEDED"; return 0; }

    # Build the --include list, then pull all matching binaries in one request.
    local dir glob includes=""
    while IFS='|' read -r dir glob; do
        [ -n "$dir" ] || continue
        includes="$includes,$dir/$glob"
    done <<SELECTION
$FONT_SELECTION
SELECTION
    includes="${includes#,}"

    info "Downloading the needed font files…"
    if ! git -C "$FONTS_CACHE" lfs pull --include "$includes"; then
        warn "Font download failed; skipping installation."
        return 0
    fi

    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    local installed=0
    while IFS='|' read -r dir glob; do
        [ -n "$dir" ] || continue
        # WHY : `find` rather than `cp dir/glob`: the directory names contain
        #       spaces and the shell would word-split the glob.
        local n
        n=$(find "$FONTS_CACHE/$dir" -maxdepth 1 -name "$glob" \
            \( -name '*.ttf' -o -name '*.otf' \) -exec cp {} "$font_dir/" \; -print 2>/dev/null | wc -l)
        installed=$((installed + n))
        info "  $dir: $n files"
    done <<SELECTION
$FONT_SELECTION
SELECTION

    if [ "$installed" -eq 0 ]; then
        warn "No font files were installed — the repository layout may have changed."
        return 0
    fi

    command -v fc-cache >/dev/null 2>&1 && run fc-cache -f "$font_dir"
    ok "Installed $installed font files to $font_dir"
}

# ==============================================================================
# 7. Backing up and stowing
# ==============================================================================
# WHAT: Walk every file the given packages would install and move the real
#       files in the way into a timestamped backup directory. The optional
#       second argument is a leading path fragment to skip.
# WHY : Stow refuses to overwrite anything it does not own, so on a machine
#       with existing configs it would do nothing. Moving conflicts aside
#       destroys nothing. Symlinks into this repo are skipped: they are from a
#       previous run, and backing them up would copy the deployed config on
#       every re-run.
# NOTE: The skip is for the editor packages only, whose undeployed tree must
#       not be treated as something to install (see EDITOR_IGNORE). Every other
#       package lives under .config/, so a .config/ skip on the general call
#       would disable conflict detection for bat, fish, ghostty, git, and zed.
backup_conflicts() {
    local packages="$1" skip="${2:-}" pkg src rel target conflicts=""

    for pkg in $packages; do
        [ -d "$DOTFILES_DIR/$pkg" ] || continue
        # `find -print` (not -print0) works here because these paths are the
        # repo's own and contain no newlines; they do contain spaces, hence
        # the quoting and IFS handling below.
        while IFS= read -r src; do
            rel="${src#"$DOTFILES_DIR/$pkg/"}"
            case "$rel" in
                README.md | .stow-local-ignore) continue ;;
                # The extension lists are inputs to this script, not files that
                # belong in $HOME; .stow-local-ignore keeps stow off them too.
                extensions*.txt) continue ;;
            esac
            # WHY: Skip the tree this platform does not deploy, if asked.
            [ -n "$skip" ] && case "$rel" in "$skip"*) continue ;; esac
            target="$HOME/$rel"
            # WHY: The -L test is needed as well as -e. A dangling symlink
            #      (from a repo that has since moved) fails -e, and without the
            #      second test it would be skipped here and then collide
            #      during stow.
            if { [ -e "$target" ] || [ -L "$target" ]; } && ! is_ours "$target"; then
                conflicts="$conflicts$target
"
            fi
        done <<EOF
$(find "$DOTFILES_DIR/$pkg" \( -type f -o -type l \) 2>/dev/null)
EOF
    done

    [ -n "$conflicts" ] || { ok "No conflicting files"; return 0; }

    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    warn "These existing files are in the way and would be moved to:"
    warn "  $BACKUP_DIR"
    # WHY : The list goes to stderr with the warning lines above and the
    #       question below; on stdout, redirection could interleave the three
    #       parts of one message out of order.
    printf '%s' "$conflicts" | sed 's|^|      |' >&2

    if ! confirm yes "Move them and continue?"; then
        # WHY : The message says what has already run. By the time this prompt
        #       appears the package manager has run, so "nothing was changed"
        #       would be false and the user would not know the machine's state.
        warn "Aborted before linking any configuration."
        warn "Already done, and not undone by this abort:"
        warn "  • Homebrew installed or updated"
        warn "  • packages from the Brewfile installed"
        [ "$OS" = "linux" ] && warn "  • GUI applications installed"
        warn "Nothing in \$HOME was moved. Re-run to continue from here."
        exit 1
    fi

    local f
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        rel="${f#"$HOME"/}"
        run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        run mv "$f" "$BACKUP_DIR/$rel"
    done <<EOF
$conflicts
EOF
    ok "Backed up to $BACKUP_DIR"
}

# WHAT: Remove folded symlinks left by a previous layout.
# WHY : A package stowed folded leaves ~/.config/<pkg> as a single symlink into
#       the repo, and stowing it with --no-folding afterwards conflicts,
#       because stow cannot turn a symlink into a real directory. The link is
#       the repo's own, so deleting it is safe.
unfold_stale_links() {
    local packages="$1" pkg dir
    # shellcheck disable=SC2086  # $packages is a space-separated list, split on the spaces
    for pkg in $packages; do
        dir="$HOME/.config/$pkg"
        if [ -L "$dir" ] && is_ours "$dir"; then
            info "Converting folded $dir to a real directory"
            run rm "$dir"
        fi
    done
}

# WHAT: Back up conflicts, then run the three stow invocations.
# WHY : --no-folding and --ignore are per-run flags, so each group is stowed
#       in its own call. The editor packages are checked for conflicts
#       separately, so their skip prefix cannot reach the other packages.
#       README.md § The stow model has the reasoning.
stow_packages() {
    command -v stow >/dev/null 2>&1 || {
        [ "$DRY_RUN" -eq 1 ] && { warn "stow not installed; skipping (dry run)"; return 0; }
        die "stow is not installed — the Brewfile step should have provided it"
    }

    local fold nofold editor
    fold="$(select_packages "$PACKAGES_FOLD")"
    nofold="$(select_packages "$PACKAGES_NOFOLD")"
    editor="$(select_packages "$PACKAGES_EDITOR")"

    step "Linking configuration"
    backup_conflicts "$fold $nofold"
    [ -n "$editor" ] && backup_conflicts "$editor" "$EDITOR_SKIP_PREFIX"
    unfold_stale_links "$nofold $editor"

    # The unquoted expansions below are intended: each list must split into
    # several arguments for stow. Package names are fixed identifiers defined at
    # the top of this file, so there is nothing to glob or mis-split.
    if [ -n "$fold" ]; then
        info "Folded:    $fold"
        # shellcheck disable=SC2086
        run stow --target="$HOME" --dir="$DOTFILES_DIR" $fold
    fi
    if [ -n "$nofold" ]; then
        info "No-fold:   $nofold"
        # shellcheck disable=SC2086
        run stow --no-folding --target="$HOME" --dir="$DOTFILES_DIR" $nofold
    fi
    if [ -n "$editor" ]; then
        info "Editors:   $editor (ignoring /$EDITOR_IGNORE/)"
        # shellcheck disable=SC2086
        run stow --no-folding --ignore="$EDITOR_IGNORE" \
            --target="$HOME" --dir="$DOTFILES_DIR" $editor
    fi
    ok "Packages linked"
}

# ==============================================================================
# 8. Per-OS selector symlinks
# ==============================================================================
# WHAT: The three links stow cannot express, because they depend on the OS.
# WHY : The bat and Ghostty config formats have no conditionals, so each ships
#       a .darwin and a .linux variant and this picks one. tlrc's config lives
#       at the XDG path, and macOS needs a bridge from the Application Support
#       location it reads. The links are recreated on every run, so a dry run
#       followed by a real run, or an OS change, ends in the same state. See
#       README.md § Per-OS configuration.
link_os_selectors() {
    local suffix
    if [ "$OS" = "macos" ]; then suffix="darwin"; else suffix="linux"; fi

    step "Selecting per-OS configuration ($suffix)"

    if [ -d "$HOME/.config/bat" ]; then
        run ln -sfn "config.$suffix" "$HOME/.config/bat/config"
        ok "bat → config.$suffix"
    fi

    if [ -d "$HOME/.config/ghostty" ]; then
        run ln -sfn "os-$suffix.ghostty" "$HOME/.config/ghostty/os.ghostty"
        ok "ghostty → os-$suffix.ghostty"
    fi

    # WHY: Neovide reads one config.toml and TOML has no conditionals, so the
    #      repo ships a variant per platform. A value the running build cannot
    #      parse — "transparent" for `frame` off macOS — discards the whole
    #      file rather than the key, so the wrong variant is not a partial
    #      config but none at all.
    if [ -d "$HOME/.config/neovide" ]; then
        run ln -sfn "config.$suffix.toml" "$HOME/.config/neovide/config.toml"
        ok "neovide → config.$suffix.toml"
    fi

    # WHY: The tlrc client resolves its config through the Rust `dirs` crate, which gives
    #      ~/.config on Linux and ~/Library/Application Support on macOS. The
    #      repo ships the XDG path; this bridges the macOS one.
    if [ "$OS" = "macos" ] && [ -f "$HOME/.config/tlrc/config.toml" ]; then
        run mkdir -p "$HOME/Library/Application Support/tlrc"
        run ln -sfn "$HOME/.config/tlrc/config.toml" \
            "$HOME/Library/Application Support/tlrc/config.toml"
        ok "tlrc → bridged to Application Support"
    fi
}

# ==============================================================================
# 9. Post-install steps
# ==============================================================================
# WHAT: Install the extensions listed in the editor packages' .txt files.
# WHY : Neither editor has a declarative equivalent of Zed's
#       auto_install_extensions, so the lists live in the repo and this feeds
#       them to each editor's CLI. The two editors resolve ids against
#       different galleries, so there are three lists;
#       vscode/README.md § Extensions explains and has the query that decides
#       where an id belongs.
# HOW : The `code` CLI reaches $PATH through the editor's "Shell Command:
#       Install 'code' command in PATH" palette action, so its absence is a
#       warning.
install_editor_extensions() {
    step "Installing editor extensions"

    local any=0
    # Each pair is "<cli>:<list> <list>…"; the lists are relative to the repo.
    install_extension_list "code"   "vscode/extensions.txt" "vscode/extensions-vscode.txt" && any=1
    install_extension_list "cursor" "vscode/extensions.txt" "cursor/extensions-cursor.txt" && any=1

    [ "$any" -eq 1 ] || info "Neither editor CLI is on \$PATH; nothing to do"
    return 0
}

# WHAT: Feed one editor's CLI the ids it does not already have.
# WHY : Split out so the two editors share the parsing and a failure in one
#       does not stop the other.
# NOTE: The installed set is read once, with --list-extensions, and each id is
#       checked against it in the shell. Calling --install-extension for every
#       id and letting --force make it a no-op costs about 0.76 s per id; the
#       two editors' lists add up to 73 install calls, about 55 s per install.
#       One --list-extensions call costs 0.22 s.
# NOTE: This step therefore does not upgrade an extension that is present.
#       That is safe because `extensions.autoUpdate` is "on" in
#       vscode/.config/Code/User/settings.json, so both editors update
#       themselves; with it off, extensions stay at their installed version.
install_extension_list() {
    local cli="$1" list path id lower installed
    local declared=0 present=0 added=0 failed=0
    shift

    command -v "$cli" >/dev/null 2>&1 || {
        warn "$cli is not on \$PATH; skipping its extensions"
        return 1
    }

    # WHY : The surrounding spaces are required. The test below is a substring
    #       match, and the repo declares both `ms-python.python` and
    #       `ms-python.vscode-python-envs`; without the padding the shorter id
    #       would match inside the longer one and a missing extension would
    #       never be installed.
    # WHY : Both sides are lower-cased because Marketplace ids are
    #       case-insensitive and displayed capitalised
    #       (`Catppuccin.catppuccin-vsc`) while both CLIs report them
    #       lowercase, so an id pasted from the Marketplace would otherwise
    #       never match. Every id here is lowercase today; the lower-casing
    #       guards a future paste. `tr` rather than ${var,,}: bash 3.2 has no
    #       case conversion.
    # NOTE: If --list-extensions fails, the set is empty, every id looks
    #       missing, and all of them are installed; reinstalling a present
    #       extension is harmless.
    installed=" $("$cli" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"

    for list in "$@"; do
        path="$DOTFILES_DIR/$list"
        [ -f "$path" ] || continue
        # WHY: The `|| true` is required. The grep command exits 1 when nothing
        #      matches, the normal state of a list that is entirely comments,
        #      and `set -e` would end the script there.
        while IFS= read -r id; do
            [ -n "$id" ] || continue
            declared=$((declared + 1))

            lower="$(printf '%s' "$id" | tr '[:upper:]' '[:lower:]')"
            case "$installed" in
                *" $lower "*)
                    present=$((present + 1))
                    continue
                    ;;
            esac

            if [ "$DRY_RUN" -eq 1 ]; then
                info "[dry-run] would install $id"
                added=$((added + 1))
                continue
            fi

            # --force suppresses prompts and makes a retry after a partial
            # failure idempotent.
            if "$cli" --install-extension "$id" --force >/dev/null 2>&1; then
                added=$((added + 1))
            else
                warn "$cli could not install $id"
                failed=$((failed + 1))
            fi
        done <<EOF
$(grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$path" 2>/dev/null || true)
EOF
    done

    if [ "$failed" -gt 0 ]; then
        warn "$cli: $declared declared, $present present, $added installed, $failed failed"
    elif [ "$added" -eq 0 ]; then
        ok "$cli: $declared declared, all present"
    else
        ok "$cli: $declared declared, $present present, $added installed"
    fi
    return 0
}

# WHAT: Download the Catppuccin themes for the tools whose port is a file
#       rather than a setting: delta, eza, and Xcode.
# WHY : The files are not committed; fetching keeps them current with upstream
#       at the cost of a network dependency, so every failure is a warning.
#       The other Catppuccin surfaces need nothing fetched: fish 4.4 or later
#       and bat ship the flavours, and Ghostty, Zed, VS Code, Cursor, and Neovim get
#       theirs from a bundled theme or an extension. README.md § Fetched themes
#       says what each consumer does when the file is absent.
# HOW : Re-run the installer to refresh them; each fetch overwrites.
install_catppuccin_themes() {
    step "Fetching Catppuccin themes"

    command -v curl >/dev/null 2>&1 || {
        warn "curl is not installed; skipping the fetched themes"
        return 0
    }

    local raw="https://raw.githubusercontent.com/catppuccin"

    fetch_theme "$raw/delta/main/catppuccin.gitconfig" \
        "$HOME/.config/git/catppuccin.gitconfig" "delta"

    # WHY: The eza tool reads its theme from $EZA_CONFIG_DIR/theme.yml, one directory per
    #      theme, so two directories let fish/.config/fish/conf.d/25-theme.fish
    #      point at one per appearance. The mauve accent matches
    #      catppuccin.accentColor in the editors.
    fetch_theme "$raw/eza/main/themes/mocha/catppuccin-mocha-mauve.yml" \
        "$HOME/.config/eza-mocha/theme.yml" "eza (mocha)"
    fetch_theme "$raw/eza/main/themes/latte/catppuccin-latte-mauve.yml" \
        "$HOME/.config/eza-latte/theme.yml" "eza (latte)"

    # WHY: macOS-only because Xcode is. The upstream filenames contain a space,
    #      which must be written as %20; curl does not encode it.
    if [ "$OS" = "macos" ]; then
        local xc="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
        fetch_theme "$raw/xcode/main/themes/Catppuccin%20Mocha.xccolortheme" \
            "$xc/Catppuccin Mocha.xccolortheme" "Xcode (mocha)"
        fetch_theme "$raw/xcode/main/themes/Catppuccin%20Latte.xccolortheme" \
            "$xc/Catppuccin Latte.xccolortheme" "Xcode (latte)"
        info "Select one in Xcode > Settings > Themes — that choice is Xcode's"
        info "own preference and is not something this repo can set."
    fi

    return 0
}

# WHAT: Download one file to one destination, creating the directory.
# WHY : One function gives every fetch the same handling: a temp file first,
#       so a failed or interrupted download never leaves a truncated theme in
#       place, and a warning rather than an error on failure.
fetch_theme() {
    local url="$1" dest="$2" label="$3" tmp

    if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry-run] fetch $label -> $dest"
        return 0
    fi

    tmp="$(mktemp)" || { warn "Could not create a temp file for $label"; return 0; }

    if curl -fsSL --max-time 30 "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mkdir -p "$(dirname "$dest")"
        mv "$tmp" "$dest"
        ok "$label"
    else
        rm -f "$tmp"
        warn "Could not fetch the $label theme; it will be unthemed"
    fi

    return 0
}

# WHAT: Run Neovim once with no UI so it installs plugins and compiles parsers.
# WHY : The vim.pack manager clones on first start and nvim-treesitter then
#       compiles about 22 parsers, so the first interactive launch would
#       otherwise wait minutes with partial highlighting.
bootstrap_neovim() {
    command -v nvim >/dev/null 2>&1 || { warn "nvim not found; skipping bootstrap"; return 0; }
    step "Bootstrapping Neovim (plugins and parsers)"
    info "This takes a few minutes on a fresh machine…"
    # WHY : The explicit wait. Starting Neovim makes vim.pack clone the
    #       plugins, but plugins/treesitter.lua calls install() without waiting
    #       so that an interactive session is never blocked; headless, Neovim
    #       would exit before a parser finished compiling. Collecting the
    #       parser list from languages.lua and waiting on the handle does the
    #       compiling here.
    # NOTE: Not fatal. A grammar that will not compile shows up in
    #       :checkhealth later.
    run nvim --headless "+lua
        local seen, parsers = {}, {}
        for _, lang in ipairs(require('languages')) do
            for _, p in ipairs(lang.parsers or {}) do
                if not seen[p] then seen[p] = true; parsers[#parsers + 1] = p end
            end
        end
        require('nvim-treesitter').install(parsers):wait(600000)
    " "+qa!" 2>/dev/null || warn "Neovim bootstrap reported errors; run :checkhealth to inspect"
    ok "Neovim ready"
}

# WHAT: Download the tldr page cache.
# WHY : The config defers auto-updates until after a page renders, so the first
#       lookup on a fresh machine would otherwise wait for the download.
prime_tldr_cache() {
    command -v tldr >/dev/null 2>&1 || return 0
    step "Priming the tldr cache"
    run tldr --update || warn "tldr cache update failed (offline?)"
    ok "tldr ready"
}

# WHAT: Offer to make fish the login shell.
# WHY : Everything in fish/ applies only to an interactive fish session, so
#       without this the shell config is installed but not used. The path is
#       resolved with `command -v` after Homebrew is on PATH, so it is the
#       brew-installed fish rather than a system one.
# NOTE: Never fatal. It needs a password, it edits a system file, and it can be
#       refused.
set_login_shell() {
    command -v fish >/dev/null 2>&1 || { warn "fish not found; skipping shell change"; return 0; }

    local fish_path current
    fish_path="$(command -v fish)"
    current="${SHELL:-}"

    if [ "$current" = "$fish_path" ]; then
        ok "fish is already the login shell"
        return 0
    fi

    step "Setting fish as the login shell"
    info "Current: ${current:-unknown}"
    info "New:     $fish_path"

    # WHY : The tty test. `chsh` prompts for the password itself, with no flag
    #       to supply one, so without a terminal the command would hang (under
    #       CI, a pipe, or an automation harness). `--yes` does not override
    #       this: consent for moving a file does not extend to an operation
    #       that then blocks on credentials nobody can supply.
    if [ ! -t 0 ]; then
        warn "Not running in a terminal, so the login shell was left alone."
        warn "chsh needs to prompt for your password. Change it yourself with:"
        warn "  chsh -s $fish_path"
        return 0
    fi

    if ! confirm no "Change the login shell? (needs your password)"; then
        warn "Skipped. Change it later with: chsh -s $fish_path"
        return 0
    fi

    # chsh refuses a shell not listed in /etc/shells, so that comes first. It is
    # also a password prompt, hence gated on the terminal above.
    if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
        info "Adding $fish_path to /etc/shells (needs sudo)"
        run sudo sh -c "printf '%s\n' '$fish_path' >> /etc/shells" \
            || { warn "Could not update /etc/shells; skipping shell change"; return 0; }
    fi

    if run chsh -s "$fish_path"; then
        ok "Login shell changed (takes effect in a new terminal)"
    else
        warn "chsh failed. Change it later with: chsh -s $fish_path"
    fi
}

# ==============================================================================
# 10. Uninstall
# ==============================================================================
# WHAT: Remove every symlink this script created, leaving software installed.
# WHY : Stow unstows its own packages but knows nothing about the four OS
#       selector links from step 8, which must be removed explicitly.
uninstall() {
    step "Removing symlinks"

    local link
    for link in "$HOME/.config/bat/config" \
        "$HOME/.config/ghostty/os.ghostty" \
        "$HOME/.config/neovide/config.toml" \
        "$HOME/Library/Application Support/tlrc/config.toml"; do
        if [ -L "$link" ]; then
            run rm "$link"
            ok "Removed $link"
        fi
    done

    # WHY: The fetched themes are real files this script created, not symlinks
    #      stow knows about. The eza directories hold nothing else, so they go
    #      too; the Xcode themes are removed individually because that
    #      directory is Xcode's and holds its own themes.
    local fetched
    for fetched in "$HOME/.config/git/catppuccin.gitconfig" \
        "$HOME/.config/eza-mocha/theme.yml" \
        "$HOME/.config/eza-latte/theme.yml" \
        "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/Catppuccin Mocha.xccolortheme" \
        "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/Catppuccin Latte.xccolortheme"; do
        if [ -f "$fetched" ]; then
            run rm "$fetched"
            ok "Removed $fetched"
        fi
    done
    for fetched in "$HOME/.config/eza-mocha" "$HOME/.config/eza-latte"; do
        [ -d "$fetched" ] && rmdir "$fetched" 2>/dev/null
    done
    true  # rmdir on a non-empty directory is expected and must not fail the run

    local fold nofold editor
    fold="$(select_packages "$PACKAGES_FOLD")"
    nofold="$(select_packages "$PACKAGES_NOFOLD")"
    editor="$(select_packages "$PACKAGES_EDITOR")"

    if command -v stow >/dev/null 2>&1; then
        # shellcheck disable=SC2086  # word splitting intended, as above
        [ -n "$fold" ] && run stow -D --target="$HOME" --dir="$DOTFILES_DIR" $fold
        # shellcheck disable=SC2086
        [ -n "$nofold" ] && run stow -D --no-folding --target="$HOME" --dir="$DOTFILES_DIR" $nofold
        # WHY: --ignore must match the install-time value, or stow tries to
        #      unlink the tree that was never deployed and reports it missing.
        # shellcheck disable=SC2086
        [ -n "$editor" ] && run stow -D --no-folding --ignore="$EDITOR_IGNORE" \
            --target="$HOME" --dir="$DOTFILES_DIR" $editor
        true  # the guarded commands above must not set the function's exit status
        ok "Packages unstowed"
    else
        warn "stow is not installed; only the selector links were removed"
    fi

    info ""
    info "Fonts installed from the font repository are left in place; they are"
    info "files, not symlinks. Remove them with:"
    info "    rm ~/.local/share/fonts/{JetBrainsMono,FiraCode,IBMPlexMono,SourceCodePro}* && fc-cache -f"
    info ""
    info "Installed software was left alone. To remove it too:"
    info "    brew bundle cleanup --file \"$DOTFILES_DIR/Brewfile\" --force"
    info "Backups from previous runs are in ~/.dotfiles-backup-*"
}

# ==============================================================================
# 11. Summary
# ==============================================================================
# WHAT: Print what to restart, where backups went, and how to verify.
print_summary() {
    step "Done"

    if [ "$DRY_RUN" -eq 1 ]; then
        info "This was a dry run; nothing was changed."
        info "Re-run without --dry-run to apply."
        return 0
    fi

    info "Restart these for the new configuration to take effect:"
    info "  • your terminal (or reload Ghostty with the reload-config binding)"
    info "  • any running Neovim, Neovide, Zed, Visual Studio Code or Cursor"
    [ -n "$BACKUP_DIR" ] && info "Displaced files were saved to: $BACKUP_DIR"

    if [ "$OS" = "linux" ]; then
        info ""
        info "Fonts come from $FONTS_REPO"
        info "If that step was skipped, install these by hand and run fc-cache -fv:"
        info "  $FONTS_NEEDED"
        info "Nerd Font builds: https://github.com/ryanoasis/nerd-fonts/releases"
    fi

    info ""
    info "Verify with:"
    info "  nvim \"+checkhealth vim.pack vim.lsp nvim-treesitter\""
    [ "$OS" = "linux" ] && info "  nvim \"+checkhealth vim.provider\"   # clipboard"
    command -v ghostty >/dev/null 2>&1 && info "  ghostty +validate-config"
    return 0
}

# ==============================================================================
# Main
# ==============================================================================
# WHAT: Run the steps in the order the header lists.
# WHY : The themes and the extensions run outside the dry-run guard because
#       both can preview cheaply: the themes print the five files they would
#       place, and the extension step reads each editor's installed set and
#       names what it would add. The Neovim bootstrap, the tldr cache, and the
#       login shell are slow or need a terminal and have nothing to show in a
#       dry run.
main() {
    parse_args "$@"

    printf '%s%s\n' "$C_BOLD" "dotfiles installer$C_RESET"
    printf '    %s%s%s\n' "$C_DIM" "$DOTFILES_DIR" "$C_RESET"

    detect_platform

    if [ "$UNINSTALL" -eq 1 ]; then
        uninstall
        return 0
    fi

    install_prerequisites
    install_homebrew
    install_brewfile
    install_gui_apps_linux
    install_fonts_linux
    stow_packages
    link_os_selectors
    install_catppuccin_themes
    install_editor_extensions

    if [ "$DRY_RUN" -eq 0 ]; then
        bootstrap_neovim
        prime_tldr_cache
        set_login_shell
    fi

    print_summary
}

main "$@"
