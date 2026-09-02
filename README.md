# dotfiles

Configuration for a **macOS and Linux** development setup: **Ghostty** running
**fish**, **Neovim** (terminal and via **Neovide**), **Zed**, **Git**, **bat**
and **tlrc**. Installed by one script, deployed with GNU **stow**.

Two things make this repo what it is:

* **Everything is documented in place.** Every option in every file says what
  it does, why that value was chosen, and how to change it. The files are the
  documentation; these READMEs are the index and the reasoning that spans more
  than one of them.
* **Built-in machinery first.** Neovim uses its native `vim.pack` and LSP APIs
  rather than plugin managers; Git uses `includeIf` rather than a wrapper
  script; fish uses `conf.d` autoloading rather than one monolithic file.

---

## Install

```sh
git clone <this-repo> ~/work/dotfiles
cd ~/work/dotfiles
./install.sh
```

That is the whole thing. The script detects your platform, installs Homebrew if
it is missing, applies the `Brewfile`, backs up anything already in the way,
links every package with stow, selects the per-OS config variants, bootstraps
Neovim, and offers to make fish your login shell.

| Option           | Effect                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `--dry-run`      | Print every action, change nothing                                     |
| `--cli-only`     | Skip the GUI apps (Ghostty, Zed, Neovide) — for servers and containers |
| `--packages a,b` | Only handle the named packages                                         |
| `--uninstall`    | Remove the symlinks, leave the software installed                      |
| `--yes`          | Never prompt; implied when stdin is not a terminal                     |

Run `./install.sh --dry-run` first if you want to see exactly what it will do.

### What still needs you

* **Fonts on Linux.** Homebrew installs fonts through casks, which are
  macOS-only, and distro font packaging is too inconsistent to automate
  safely. The script prints the list; install them and run `fc-cache -fv`.
* **Ghostty and Zed on some distros.** Both are cask-only, so on Linux the
  script uses your package manager. Ghostty is packaged for Arch and Ubuntu
  26.04+ and needs a COPR on Fedora; Zed is packaged only for Arch. Where
  there is no package, the script points you at the upstream download rather
  than piping a remote script into your shell.
* **This repo's own git identity.** It lives at `~/work/`, where the committed
  `includeIf` would apply the work identity, so it is overridden per-repo.
  That override is not version-controlled — see [git/README](git/README.md).

---

---

## Packages

| Package                         | Installs to                           | What it is                                               |
| ------------------------------- | ------------------------------------- | -------------------------------------------------------- |
| [`bat/`](bat/README.md)         | `~/.config/bat/`                      | `cat` with syntax highlighting; also the `$MANPAGER`     |
| [`fish/`](fish/README.md)       | `~/.config/fish/`                     | The shell: PATH, environment, prompt, functions          |
| [`ghostty/`](ghostty/README.md) | `~/.config/ghostty/`                  | Terminal emulator                                        |
| [`git/`](git/README.md)         | `~/.config/git/`                      | Global Git config, with work/personal identity switching |
| [`neovide/`](neovide/README.md) | `~/.config/neovide/`                  | Neovim's GUI: window and startup font                    |
| [`nvim/`](nvim/README.md)       | `~/.config/nvim/`                     | The editor: LSP, treesitter, plugins, keymaps            |
| [`tlrc/`](tlrc/README.md) | `~/.config/tlrc/` | `tldr` client — macOS gets a bridge symlink, see below |
| [`zed/`](zed/README.md)         | `~/.config/zed/`                      | GUI editor, configured as a normal (non-modal) editor    |

Root files — `install.sh`, `Brewfile` (every dependency), `CLAUDE.md`
(conventions for AI agents working here), `.gitignore` — are not packages and
are never stowed.

---

## The stow model

A stow package mirrors the path its contents occupy under `$HOME`. So
`bat/.config/bat/config` becomes `~/.config/bat/config`, and tlrc's odd
`Library/Application Support/…` path needs no special handling — it is just
what that file's real location is.

Two invocations, because the packages want different linking strategies:

**Folded** — `neovide nvim tlrc`. Stow links the whole directory, so
`~/.config/nvim` *is* a symlink to this repo. New files appear live with no
restow, and `nvim-pack-lock.json` — which `vim.pack` writes into the config
directory — lands in the repo where it belongs.

**`--no-folding`** — `bat fish ghostty git zed`. Stow creates real directories
and links each file individually. The rule: **a directory must stay real if
anything machine-local has to live in it.** Two kinds qualify:

* Applications that write runtime state beside their config — `fish_variables`,
  Zed's `conversations/`, whatever `git config --global` appends. None of that
  belongs in the repo.
* Directories that hold one of the **per-OS selector symlinks** described
  below — `bat` and `ghostty`. A folded directory is a symlink into the repo,
  so a selector created inside it would land in version control.

The no-fold directories are also what make local overlays possible:

| Local file (uncommitted)             | Purpose                                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------------------------- |
| `~/.config/fish/conf.d/99-work.fish` | Machine- or employer-specific shell helpers; fish auto-sources it like any other snippet |
| `~/.config/git/config.work`          | Committed here, but the same mechanism applies — see [git/README](git/README.md)         |

After adding a **new file** to a `--no-folding` package, re-link it:

```sh
stow -R --no-folding --target="$HOME" --dir="$PWD" fish
```

`stow -D <pkg>` removes a package's links; `-R` is delete-then-stow.

### Per-OS configuration

Three formats have no conditionals but need different values per platform, so
`install.sh` creates three symlinks that stow cannot express:

| Link                                             | Points at                           | Why                                                                                                                        |
| ------------------------------------------------ | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `~/.config/bat/config`                           | `config.darwin` \| `config.linux`   | `--theme=auto:system` reads the macOS appearance and is **macOS-only**; Linux uses `--theme=auto`, which asks the terminal |
| `~/.config/ghostty/os.conf`                      | `os-darwin.conf` \| `os-linux.conf` | macOS binds ⌘; on Linux `super` is the Windows key, which desktops grab, so it binds Ctrl+Shift                            |
| `~/Library/Application Support/tlrc/config.toml` | `~/.config/tlrc/config.toml`        | tlrc reads XDG on Linux but Application Support on macOS; the bridge means one file serves both                            |

Everything else branches at runtime instead: fish probes all three Homebrew
prefixes, Neovim checks `vim.uv.os_uname().sysname`, and the Brewfile uses
`OS.mac?` / `OS.linux?`.

---

## The font stack

One typeface family everywhere, in two builds, with a shared fallback chain.
The rule: **the Nerd Font build goes wherever icons are drawn.**

| Surface                   | Primary font                   | Ligatures |
| ------------------------- | ------------------------------ | --------- |
| Ghostty                   | `JetBrainsMono Nerd Font Mono` | off       |
| Neovide / Neovim          | `JetBrainsMono Nerd Font Mono` | on        |
| Zed — editor pane         | `JetBrains Mono`               | on        |
| Zed — integrated terminal | `JetBrainsMono Nerd Font Mono` | off       |

Fallbacks, in order: **FiraCode Nerd Font Mono** (a second icon-carrying build,
so icons survive one more step down the chain), then **JetBrains Mono**
(terminals only — the same typeface without the patched icons), **Fira Code**,
**Source Code Pro**, **IBM Plex Mono**. Size is **14** everywhere; Zed's
`ui_font_size` stays 16 because it sizes UI chrome, not code.

On **Linux the fonts are not installed for you** — they are Homebrew casks,
which do not exist there. Install them by hand and run `fc-cache -fv`; until
then Neovim's icons render as boxes.

Why the **Mono** build: its icon glyphs occupy exactly one cell, so Neovim's
statusline, file tree and diagnostic gutter never break column alignment. The
plain Nerd Font build draws icons at double width.

Why ligatures split: editors fuse `!=` and `->` because they are pleasant to
read in code; terminals do not, because logs, diffs and hex output must show
exactly the characters that are there. **Consequence:** Neovim has ligatures in
Neovide but not in a Ghostty terminal.

Where ligatures are on, they are enabled for **every family in the chain**, not
only the primary — Fira Code is a ligature-first typeface and would otherwise
render flat whenever it was the font actually supplying a glyph.

Changing the font means changing it in four places: `ghostty/`,
`zed/` (twice — buffer and terminal), `neovide/`, and Neovim's `guifont`.

---

## Light and dark

On **macOS** every tool follows the system appearance, so the whole stack flips
together:

| Tool    | Mechanism                                                       |
| ------- | --------------------------------------------------------------- |
| Ghostty | `theme = light:TokyoNight Day,dark:TokyoNight Night`            |
| Zed     | `"theme": { "mode": "system", … }` — Ayu Light / Ayu Dark       |
| bat     | `--theme=auto:system` — Catppuccin Latte / Mocha                |
| Neovide | `theme = "auto"`                                                |
| tlrc    | Palette **names**, which resolve through the terminal's colours |
| Neovim  | Its built-in default colorscheme, which follows `background`    |

On **Linux it is one step less direct, and worth knowing about.** Ghostty, Zed
and Neovide read the desktop's colour-scheme preference through the XDG portal,
so they still switch with the system. bat cannot: `auto:system` is documented as
macOS-only, so the Linux variant uses `--theme=auto`, which infers light or dark
from the **terminal's background colour** instead. In practice that still tracks
your theme — Ghostty repaints its background when the desktop flips, and bat
picks that up — but it is inference rather than a direct signal, and a terminal
that does not report its background will get it wrong.

---

## Conventions

Every configuration file opens with a header block naming the file, saying
what it is, where its authority begins and ends, and listing the traps of its
format. Individual settings are then annotated:

```
# WHAT: What this option does.
# WHY : Why this value, usually naming the rejected alternative.
# HOW : The concrete edit or command to change it.
```

`WHAT` is mandatory, `WHY` nearly always present, `HOW` where it helps. Every
sentence starts with a capital; where that would mean capitalising a
lowercase-by-convention tool name or a literal value, the sentence is rephrased
to lead with a real word instead. Every file is indented with **4 spaces**,
never tabs.

Deliberately-disabled settings stay in the file, commented out with their
reasoning intact, under a "documented extension points (inactive)" heading —
nothing is silently omitted.

Commits follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/),
scoped to the package they touch — `feat(ghostty): …`, `chore: …`. The full
vocabulary and the trailer format are in [git/README.md](git/README.md).

---

## Format traps worth knowing

Each of these cost a debugging cycle and is documented in the file it affects:

* **Ghostty** has no trailing comments — everything after `=` is the value, so
  `key = true  # note` sets the value to `true  # note` and the key is rejected.
* **Neovide** (TOML) binds every bare key to the nearest `[table]` above it.
  Keys placed after `[font]` silently became `font.*` and did nothing.
* **Neovide's `[font.features]` is keyed per family**, and a family with no
  entry gets no features — so every font in the fallback chain needs its own
  line, not just the primary. Zed's `buffer_font_features`, by contrast,
  applies to the whole stack at once.
* **bat**'s config lines are shell-style arguments, so values with spaces must
  be quoted: `--theme-dark="Catppuccin Mocha"`.
* **tlrc** ignores `$XDG_CONFIG_HOME` **on macOS only** — on Linux it honours
  it normally. The repo ships the XDG path and bridges the macOS one.
* **A Brewfile is Ruby**, which is what lets `OS.mac?` guard the casks — but
  Homebrew sanitises its environment and passes through only `HOMEBREW_*`
  variables. A plain `DOTFILES_CLI_ONLY` would be stripped before the file is
  read, so the guard would silently do nothing.
* **Ghostty's `config-file` include must come last**, because later values win;
  the `?` prefix makes it optional so a missing file is not an error. Verify
  what actually resolved with `ghostty +show-config`, not just
  `+validate-config` — the latter only checks syntax.
* **bat's `--theme=auto:system` is macOS-only.** It does not error on Linux, it
  just quietly stops following the desktop.
* **Zed** may rewrite `settings.json` (and strip its comments) when you change
  a setting through its UI. Edit the repo file, then `stow -R … zed`.
* **`.stow-local-ignore` replaces** stow's default ignore list rather than
  adding to it, so the defaults have to be restated alongside any addition.

---

## Verifying a change

```sh
./install.sh --dry-run                                # what the installer would do
shellcheck install.sh                                 # the installer itself
ghostty +validate-config                              # Ghostty syntax
ghostty +show-config | grep macos-option-as-alt       # Ghostty resolved values
git config --file git/.config/git/config --list       # Git
fish --no-execute fish/.config/fish/**/*.fish         # fish
python3 -c "import tomllib,sys;tomllib.load(open(sys.argv[1],'rb'))" <file>   # TOML
nvim "+checkhealth vim.pack vim.lsp nvim-treesitter"  # Neovim
stow -n -v --target="$HOME" --dir="$PWD" <pkg>        # what stow would do
ruby -c Brewfile                                      # Brewfile is Ruby
```

On Linux additionally check the clipboard provider, which macOS gets for free:

```sh
nvim "+checkhealth vim.provider"
```
