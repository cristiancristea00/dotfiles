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
#     1. Detect OS, distribution and package manager.
#     2. Install Homebrew's prerequisites (Linux only).
#     3. Install Homebrew if missing, and put it on PATH for this run.
#     4. `brew bundle` the repo's Brewfile.
#     5. Install GUI apps that Homebrew cannot provide (Linux only).
#     6. Back up anything in the way, then stow every package.
#     7. Create the per-OS selector symlinks that stow cannot express.
#     8. Bootstrap Neovim, install the editors' extensions, prime the tldr
#        cache, and set fish as the login shell.
#     9. Print what happened and what needs restarting.
#
# WHY BASH 3.2
#     macOS still ships bash 3.2 from 2007 and that is what `#!/usr/bin/env
#     bash` finds there. This script therefore avoids everything from bash 4+:
#     no associative arrays, no `mapfile`, no `${var,,}`. If you extend it,
#     keep to that — `bash --version` on macOS is the constraint, not your
#     Linux box.
#
# IDEMPOTENCY
#     Re-running is safe and is the intended way to apply repo changes. The
#     rule that makes it work: *a symlink pointing into this repo is ours*, so
#     it is replaced without ceremony. Only real files are ever backed up, and
#     they are only ever moved, never deleted.
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

# WHAT: The repository root, resolved from this script's own location.
# WHY : Makes the script runnable from anywhere (`~/personal/dotfiles/install.sh`
#       works as well as `./install.sh`) without depending on the caller's
#       working directory.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# WHAT: Packages stowed with directory folding — the whole directory becomes one
#       symlink into the repo.
# WHY : Correct when nothing else needs to live in that directory. `nvim` is
#       folded deliberately: vim.pack writes nvim-pack-lock.json into the config
#       directory, and folding is what lands it in the repo where it belongs.
PACKAGES_FOLD="neovide nvim tlrc"

# WHAT: Packages stowed with --no-folding — the directory stays real and each
#       file is linked individually.
# WHY : Required whenever a directory must hold machine-local state alongside
#       the symlinks. Two kinds qualify: apps that write next to their config
#       (fish's fish_variables, Zed's conversations/, whatever `git config
#       --global` appends), and directories that must hold one of the OS
#       selector symlinks created in step 7 (bat, ghostty).
PACKAGES_NOFOLD="bat fish ghostty git zed"

# WHAT: Packages stowed with --no-folding AND a per-OS --ignore, in a third
#       invocation of their own.
# WHY : Visual Studio Code and Cursor read their settings from an XDG path on
#       Linux but from ~/Library/Application Support on macOS, and neither
#       format has a conditional. Each package therefore ships BOTH trees and
#       the wrong one is filtered out at link time by EDITOR_IGNORE below.
#       The separate invocation is not stylistic: --ignore is a per-run flag,
#       so folding these into PACKAGES_NOFOLD would apply --ignore='\.config'
#       to fish, ghostty, git and zed as well and erase their entire trees.
#       --no-folding is required for the usual reason — User/ also holds
#       globalStorage/, History/ and workspaceStorage/, all machine-local.
PACKAGES_EDITOR="vscode cursor"

# WHAT: The regex that selects one of the two trees each editor package ships.
# WHY : Stow's --ignore drops matching path elements, so ignoring the tree the
#       platform does NOT use is what leaves exactly one deployed. The value is
#       set by detect_platform, which is the only place that knows the OS.
# NOTE: This is also the skip-prefix backup_conflicts uses, so that the walker
#       does not check the undeployed tree for conflicts. The two uses must
#       agree — see backup_conflicts and stow_packages.
EDITOR_IGNORE=""
EDITOR_SKIP_PREFIX=""

# WHAT: Fonts the configs reference, for the message printed when they cannot
#       be installed automatically.
FONTS_NEEDED="JetBrainsMono Nerd Font, FiraCode Nerd Font, JetBrains Mono, Fira Code, Source Code Pro, IBM Plex Mono"

# WHAT: A private repository mirroring the fonts this setup uses, stored with
#       Git LFS.
# WHY : Homebrew installs fonts through casks, which are macOS-only, and Linux
#       distribution font packaging is too inconsistent to script reliably. On
#       Linux this repository is the answer; macOS gets the casks instead.
# HOW : Access needs an SSH key belonging to the account that owns it. If the
#       probe fails for any reason — no key, no access, offline — the fonts
#       step is skipped with a message and the install continues.
FONTS_REPO="git@github.com:cristiancristea00/fonts.git"
FONTS_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-fonts"

# WHAT: Which directories to install, and which files from each.
# WHY : The repository is ~317 MB because the Nerd families ship every width
#       build, but the configs reference only the single-width "Mono" ones.
#       Fetching per FILE rather than per directory is the difference between
#       ~70 MB and the whole repository — the four small families are taken
#       whole because filtering them would save nothing.
# HOW : One "directory|glob" pair per line. The glob is matched by Git LFS,
#       which is what decides which binaries are downloaded at all.
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
# WHY : Keeps the output readable interactively without polluting a log file or
#       CI transcript with escape sequences.
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
# WHY : One wrapper means --dry-run cannot drift out of sync with what the
#       script really does — there is no second code path to keep correct.
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '    %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
    else
        "$@"
    fi
}

# WHAT: Ask a yes/no question. First argument is the default — `yes` or `no` —
#       which is what pressing Enter selects and what the [Y/n] / [y/N] hint
#       shows. The rest is the prompt.
# WHY : The default has to differ per question. Backing files up destroys
#       nothing and is the expected path, so Enter should accept it; enabling a
#       third-party package repository or changing your login shell should not
#       happen because you tapped Enter.
# NOTE: When stdin is not a terminal this REFUSES rather than assuming yes.
#       An earlier version returned yes, which meant piping the script into a
#       shell silently moved your existing configs aside — consent inferred
#       from the absence of a keyboard. `--yes` is how you say yes without one.
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
# WHY : The ownership test the whole idempotency story rests on. Anything that
#       resolves into the repo was created by a previous run (or by stow), so it
#       can be replaced silently. Anything else is the user's real file and is
#       treated as precious.
# HOW : Two cases, and missing the second one is a real trap. A file can belong
#       to the repo either because it IS a symlink into it (a --no-folding
#       package, e.g. ~/.config/bat/config.darwin), or because a PARENT
#       directory is (a folded package: ~/.config/nvim is one symlink, so
#       ~/.config/nvim/lua/theme.lua is a plain file reached through it).
#       Testing only for a leaf symlink would classify every file in a folded
#       package as a stranger and "back up" the entire deployed config on each
#       run. `pwd -P` resolves symlinked parents, which covers that case.
is_ours() {
    local path="$1" resolved
    [ -e "$path" ] || [ -L "$path" ] || return 1

    if [ -L "$path" ]; then
        # Resolve the link target relative to the directory holding the link,
        # so relative targets (which is what stow creates) work.
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

usage() { sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# ==============================================================================
# 1. Argument parsing
# ==============================================================================
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
                # WHY: commas to spaces, so the value slots into the same
                #      space-separated form as PACKAGES_FOLD/PACKAGES_NOFOLD.
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
# WHY : Keeps the fold/no-fold split intact under --packages: each group is
#       filtered separately, so a selective run still stows each package the
#       way that package requires.
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
# WHY : Only three things actually depend on this — Homebrew's prerequisites,
#       the GUI applications, and which per-OS config variant gets linked. The
#       script degrades rather than refusing on an unrecognised distribution,
#       because Homebrew itself works nearly everywhere.
detect_platform() {
    step "Detecting platform"

    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)  OS="linux" ;;
        *) die "unsupported operating system: $(uname -s). This setup targets macOS and Linux." ;;
    esac

    if [ "$OS" = "linux" ]; then
        # /etc/os-release is the systemd-era standard and is present on every
        # mainstream distribution.
        if [ -r /etc/os-release ]; then
            # shellcheck disable=SC1091
            DISTRO="$(. /etc/os-release && printf '%s' "${ID:-unknown}")"
        else
            DISTRO="unknown"
        fi

        # WHY: probe for the binary rather than trusting the distro ID, which
        #      covers derivatives (Mint→apt, Manjaro→pacman) for free.
        if   command -v apt-get >/dev/null 2>&1; then PKG_MANAGER="apt"
        elif command -v dnf     >/dev/null 2>&1; then PKG_MANAGER="dnf"
        elif command -v pacman  >/dev/null 2>&1; then PKG_MANAGER="pacman"
        else PKG_MANAGER="none"
        fi
    fi

    # WHY: macOS reads the editors' settings from Library/, so the .config tree
    #      is the one to drop, and the reverse holds on Linux. The pattern is a
    #      regex matched against each path element, hence the escaped dot.
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
# WHAT: Install the compiler and utilities Homebrew needs before it will run.
# WHY : macOS gets these from the Command Line Tools, which Homebrew's own
#       installer handles. On Linux they must exist first, and Homebrew fails
#       confusingly without them. An unknown package manager is a warning, not
#       an error — the user may well have the tools already.
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
# WHAT: Install Homebrew if absent, then make it usable for the rest of this run.
# WHY : `brew shellenv` is the critical second half. The installer does not
#       modify the running shell, so without evaluating it here every later step
#       — brew bundle, stow, nvim — would fail with "command not found" on a
#       machine where Homebrew was just installed.
install_homebrew() {
    step "Homebrew"

    if command -v brew >/dev/null 2>&1; then
        ok "Already installed: $(command -v brew)"
    else
        info "Installing Homebrew from the official installer…"
        run /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Probe every prefix Homebrew uses, mirroring fish/conf.d/00-path.fish.
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
# WHY : The Brewfile is Ruby and guards its own entries with OS.mac? / OS.linux?
#       and the CLI-only flag, so one file and one command serve both platforms.
# NOTE: The environment variable MUST be HOMEBREW_-prefixed. Homebrew sanitises
#       its environment and silently drops anything else, which would make
#       --cli-only appear to work while installing the GUI apps anyway.
install_brewfile() {
    step "Installing packages from the Brewfile"
    [ -f "$DOTFILES_DIR/Brewfile" ] || die "No Brewfile at $DOTFILES_DIR"

    # WHY NOT FATAL: `brew bundle` fails the whole run if any single entry
    #       fails, and the commonest cause is trivial — a font already installed
    #       by hand that the cask refuses to adopt, or a formula unavailable on
    #       this platform. None of that should stop the configuration from being
    #       linked, which is the part of this script only it can do. The failure
    #       is reported loudly and the run continues; `brew bundle check` at the
    #       end tells you exactly what is still missing.
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
# WHY : Both are Homebrew *casks*, and casks are macOS-only — on Linux brew
#       cannot provide them at all. Neovide is different: it has a real formula,
#       so the Brewfile already handled it.
# NOTE: Visual Studio Code and Cursor are casks too, and are NOT handled here.
#       Code needs Microsoft's third-party apt/dnf repository and Cursor ships
#       only an AppImage; adding a system repository unattended is out of scope
#       for this script, exactly as fetching Ghostty's community .deb is. Their
#       configuration still deploys — only the applications are manual. The
#       Brewfile records the same decision and carries the download links.
#       Every step here is best-effort and never fatal. Packaging for these two
#       varies a lot between distributions, and a missing terminal emulator
#       should not stop a dotfiles install that is otherwise fine.
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
                # Ghostty entered the official Ubuntu archive in 26.04. Older
                # releases need the community .deb, which is not something this
                # script should fetch on the user's behalf.
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
                # Debian/Fedora have no official Zed package. The upstream
                # method is `curl … | sh`, which this script deliberately does
                # not run for you — piping a remote script into a shell should
                # be your decision, not a side effect of installing dotfiles.
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
# WHY : macOS gets fonts from Homebrew casks, which do not exist on Linux. This
#       is the Linux equivalent, and the reason the repository exists.
# NOTE: Every failure here is a warning. A machine without the fonts renders
#       icons as boxes, which is cosmetic; it is not a reason to fail an
#       install that otherwise succeeded.
install_fonts_linux() {
    [ "$OS" = "linux" ] || return 0

    step "Fonts"

    if ! command -v git-lfs >/dev/null 2>&1; then
        warn "git-lfs is not installed, so the font repository cannot be used."
        warn "Install these by hand instead: $FONTS_NEEDED"
        return 0
    fi

    # WHY BatchMode: without it ssh prompts for a passphrase or host key and the
    #      install hangs. ConnectTimeout keeps an unreachable host from stalling
    #      the run. macOS has no `timeout` binary, so ssh must do this itself.
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

    # WHY GIT_LFS_SKIP_SMUDGE: without it the clone downloads every binary in
    #      the repository — 317 MB — before anything gets to choose. Skipping
    #      the smudge filter fetches only pointers, and `git lfs pull --include`
    #      below then downloads just the files that will be installed.
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
        # WHY the find: directory names contain spaces and the globs are matched
        #      by the shell, so a plain `cp dir/glob` would word-split.
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
# WHAT: Find real files that stow would collide with, and move them aside.
# WHY : Stow refuses to overwrite anything it does not own, which is the
#       behaviour we want — but on a machine with existing configs that means it
#       refuses to do anything at all. Moving conflicts into a timestamped
#       directory clears the way while destroying nothing.
#       Symlinks into this repo are skipped: those are ours from a previous run,
#       and backing them up would fill the backup with junk on every re-run.
# WHAT: Walk every file a package would install and back up whatever is in the
#       way. The optional second argument is a leading path fragment to skip.
# WHY : The skip is for the editor packages only, whose undeployed tree must not
#       be treated as something to install — see EDITOR_IGNORE. It must NEVER be
#       applied to the general call: every other package lives under .config/,
#       so a .config/ skip there would silently disable conflict detection for
#       bat, fish, ghostty, git and zed.
backup_conflicts() {
    local packages="$1" skip="${2:-}" pkg src rel target conflicts=""

    for pkg in $packages; do
        [ -d "$DOTFILES_DIR/$pkg" ] || continue
        # Walk every file the package would install. `find -print` (not -print0)
        # is safe here because these paths are ours and contain no newlines;
        # they do contain spaces, hence the quoting and IFS handling below.
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
            # WHY: The -L test is not redundant with -e. A DANGLING symlink —
            #      one left by a previous install from a repo that has since
            #      moved — fails -e, and without the second test it would be
            #      skipped here and then collide during stow.
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
    # WHY >&2: the list belongs with the warning lines above and the question
    #       below. Sending it to stdout instead let redirection interleave the
    #       three parts of one message out of order.
    printf '%s' "$conflicts" | sed 's|^|      |' >&2

    if ! confirm yes "Move them and continue?"; then
        # WHY THIS WORDING: an earlier version claimed "Nothing was changed",
        #       which was false — by the time this prompt appears the package
        #       manager has already run. Aborting here leaves a half-set-up
        #       machine, and saying so is the difference between a user who
        #       re-runs and one who wonders what state they are in.
        warn "Aborted before linking any configuration."
        warn "Already done and NOT undone by this abort:"
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
# WHY : A package that used to be folded leaves ~/.config/<pkg> as a single
#       symlink into the repo. Stowing it with --no-folding afterwards would
#       conflict, because stow cannot turn a symlink into a real directory. As
#       these links are ours, deleting them is safe and is what makes the
#       fold→no-fold migration invisible.
unfold_stale_links() {
    local packages="$1" pkg dir
    # shellcheck disable=SC2086  # deliberate: $packages is a space-separated list
    for pkg in $packages; do
        dir="$HOME/.config/$pkg"
        if [ -L "$dir" ] && is_ours "$dir"; then
            info "Converting folded $dir to a real directory"
            run rm "$dir"
        fi
    done
}

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
    # WHY: The editor packages are checked separately so the skip-prefix that
    #      hides their undeployed tree cannot reach the packages above.
    [ -n "$editor" ] && backup_conflicts "$editor" "$EDITOR_SKIP_PREFIX"
    unfold_stale_links "$nofold $editor"

    # Two invocations because folding is a per-run flag, not per-package.
    # The unquoted expansions below are deliberate: each list must split into
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
    # A third invocation, because --ignore is a per-run flag like --no-folding.
    # Applying it to the list above would erase the other packages' trees.
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
# WHY : bat and Ghostty have config formats with no conditionals, so each ships
#       a .darwin and a .linux variant and this picks one. tlrc needs the
#       opposite treatment: its config lives at the portable XDG path, and macOS
#       needs a bridge from the Application Support location it actually reads.
#       These are recreated on every run, which is how a --dry-run followed by a
#       real run, or an OS change, converges correctly.
link_os_selectors() {
    local suffix
    if [ "$OS" = "macos" ]; then suffix="darwin"; else suffix="linux"; fi

    step "Selecting per-OS configuration ($suffix)"

    if [ -d "$HOME/.config/bat" ]; then
        run ln -sfn "config.$suffix" "$HOME/.config/bat/config"
        ok "bat → config.$suffix"
    fi

    if [ -d "$HOME/.config/ghostty" ]; then
        run ln -sfn "os-$suffix.conf" "$HOME/.config/ghostty/os.conf"
        ok "ghostty → os-$suffix.conf"
    fi

    # WHY: tlrc resolves its config through the Rust `dirs` crate, which returns
    #      ~/.config on Linux but ~/Library/Application Support on macOS. The
    #      repo ships only the portable path; this bridges the macOS one so both
    #      platforms read the same file from any shell.
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
# WHAT: Run Neovim once with no UI so it installs plugins and compiles parsers.
# WHY : vim.pack clones on first start and nvim-treesitter then compiles ~22
#       parsers. Doing it here means the first real launch is instant instead of
#       a several-minute wait with half-broken highlighting.
# WHAT: Install the extensions listed in the editor packages' .txt files.
# WHY : Neither editor has a declarative equivalent of Zed's
#       auto_install_extensions — nothing in settings.json can install an
#       extension, and .vscode/extensions.json is workspace-level
#       *recommendations* only. Each editor's own CLI is the shipped mechanism,
#       so the lists live in the repo and this feeds them in.
#       The step is best-effort by design: a missing CLI, an unpublished id or
#       an offline machine must not fail an install whose real job — linking
#       configuration — has already succeeded.
# NOTE: The two editors resolve ids against DIFFERENT galleries. Visual Studio
#       Code uses Microsoft's Marketplace; Cursor uses its own gallery at
#       marketplace.cursorapi.com, which mirrors much of the Marketplace but
#       not Microsoft's licence-restricted extensions. An id only installs
#       where it is published. That is why there are three lists rather than
#       one; see vscode/extensions.txt for the full explanation and for the
#       query that decides which list an id belongs in.
# HOW : The `code` CLI appears on $PATH via the editor's "Shell Command:
#       Install 'code' command in PATH" palette action, which is why its
#       absence is a warning rather than an error.
install_editor_extensions() {
    step "Installing editor extensions"

    local any=0
    # Each pair is "<cli>:<list> <list>…"; the lists are relative to the repo.
    install_extension_list "code"   "vscode/extensions.txt" "vscode/extensions-vscode.txt" && any=1
    install_extension_list "cursor" "vscode/extensions.txt" "cursor/extensions-cursor.txt" && any=1

    [ "$any" -eq 1 ] || info "Neither editor CLI is on \$PATH; nothing to do"
    return 0
}

# WHAT: Feed one editor's CLI every id from the given lists.
# WHY : Split out so the two editors share the parsing, and so a failure in one
#       cannot stop the other.
install_extension_list() {
    local cli="$1" list path id failed=0 count=0
    shift

    command -v "$cli" >/dev/null 2>&1 || {
        warn "$cli is not on \$PATH; skipping its extensions"
        return 1
    }

    for list in "$@"; do
        path="$DOTFILES_DIR/$list"
        [ -f "$path" ] || continue
        # WHY: The `|| true` is load-bearing. grep exits 1 when nothing matches,
        #      which is the normal state of a list that is entirely comments,
        #      and `set -e` would end the script there.
        while IFS= read -r id; do
            [ -n "$id" ] || continue
            count=$((count + 1))
            # --force makes this idempotent and upgrades in place.
            run "$cli" --install-extension "$id" --force >/dev/null 2>&1 \
                || { warn "$cli could not install $id"; failed=$((failed + 1)); }
        done <<EOF
$(grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$path" 2>/dev/null || true)
EOF
    done

    if [ "$failed" -eq 0 ]; then
        ok "$cli: $count extensions"
    else
        warn "$cli: $((count - failed)) of $count installed, $failed failed"
    fi
    return 0
}

bootstrap_neovim() {
    command -v nvim >/dev/null 2>&1 || { warn "nvim not found; skipping bootstrap"; return 0; }
    step "Bootstrapping Neovim (plugins and parsers)"
    info "This takes a few minutes on a fresh machine…"
    # WHY THE EXPLICIT WAIT: starting Neovim is enough to make vim.pack clone
    #       the plugins, but plugins/treesitter.lua calls install() WITHOUT
    #       waiting — deliberately, so an interactive session is never blocked.
    #       Headless, that means Neovim would exit before a single parser
    #       finished compiling. Collecting the parser list from languages.lua
    #       and waiting on the handle is what actually does the work here.
    # NOTE: Not fatal. One grammar that will not compile should not fail an
    #       otherwise good install; :checkhealth will show it later.
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
# WHY : The config defers auto-updates until after a page renders, so the very
#       first lookup on a fresh machine would otherwise be the slow one.
prime_tldr_cache() {
    command -v tldr >/dev/null 2>&1 || return 0
    step "Priming the tldr cache"
    run tldr --update || warn "tldr cache update failed (offline?)"
    ok "tldr ready"
}

# WHAT: Make fish the login shell.
# WHY : Everything in fish/ only applies to an interactive fish session, so
#       without this the shell config is installed but never used.
#       Resolved with `command -v` *after* Homebrew is on PATH, so it finds the
#       brew-installed fish rather than a system one.
# NOTE: Never fatal. It needs a password, it touches a system file, and it can
#       legitimately be refused — none of which should fail the install.
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

    # WHY THE TTY TEST: `chsh` prompts for your password ITSELF, and there is
    #       no flag to feed it one. Without a terminal that prompt cannot be
    #       answered and the command hangs forever — which is exactly what
    #       happens if this runs under CI, a pipe, or an automation harness.
    #       `--yes` deliberately does NOT override this: assuming consent is
    #       reasonable for moving a file, not for an operation that will then
    #       block on credentials nobody can supply.
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

    # chsh refuses a shell that is not listed in /etc/shells, so that comes
    # first. Also a password prompt, hence also gated on the terminal above.
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
# WHY : Stow can unstow its own packages, but it knows nothing about the three
#       OS selector links from step 8 — those must be removed explicitly or they
#       are left dangling at paths stow will never look at again.
uninstall() {
    step "Removing symlinks"

    local link
    for link in "$HOME/.config/bat/config" \
        "$HOME/.config/ghostty/os.conf" \
        "$HOME/Library/Application Support/tlrc/config.toml"; do
        if [ -L "$link" ]; then
            run rm "$link"
            ok "Removed $link"
        fi
    done

    local fold nofold editor
    fold="$(select_packages "$PACKAGES_FOLD")"
    nofold="$(select_packages "$PACKAGES_NOFOLD")"
    editor="$(select_packages "$PACKAGES_EDITOR")"

    if command -v stow >/dev/null 2>&1; then
        # shellcheck disable=SC2086  # deliberate word splitting, as above
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
    info "Fonts installed from the font repository are left in place —"
    info "they are files, not symlinks. Remove them with:"
    info "    rm ~/.local/share/fonts/{JetBrainsMono,FiraCode,IBMPlexMono,SourceCodePro}* && fc-cache -f"
    info ""
    info "Installed software was left alone. To remove it too:"
    info "    brew bundle cleanup --file \"$DOTFILES_DIR/Brewfile\" --force"
    info "Backups from previous runs are in ~/.dotfiles-backup-*"
}

# ==============================================================================
# 11. Summary
# ==============================================================================
print_summary() {
    step "Done"

    if [ "$DRY_RUN" -eq 1 ]; then
        info "This was a dry run — nothing was changed."
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

    if [ "$DRY_RUN" -eq 0 ]; then
        bootstrap_neovim
        install_editor_extensions
        prime_tldr_cache
        set_login_shell
    fi

    print_summary
}

main "$@"
