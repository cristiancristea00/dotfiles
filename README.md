# dotfiles

Configuration for a **macOS and Linux** development setup: **Ghostty** running
**fish**, **Neovim** (in the terminal and under **Neovide**), **Zed**,
**Visual Studio Code**, **Cursor**, **Git**, **bat**, and **tlrc**. One script
installs everything; GNU **stow** links it into place.

Two rules shape the repo:

* **Every setting is documented where it is set.** Each option states what it
  does, why it has this value, and how to change it. The config files are the
  documentation. The READMEs index them and hold the reasoning that spans more
  than one file.
* **Built-in mechanisms first.** Neovim uses `vim.pack` and the native LSP
  client rather than plugin managers, Git uses `includeIf` rather than a
  wrapper script, and fish uses `conf.d` autoloading rather than one
  monolithic file.

---

## Install

```sh
git clone <this-repo> ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

The script detects the platform, installs Homebrew if it is missing, applies
the `Brewfile`, backs up files that stow would collide with, links every
package, creates the per-OS selector symlinks, bootstraps Neovim, and offers
to make fish the login shell. `./install.sh --dry-run` prints every action
without changing anything.

| Option           | Effect                                                                                                |
| ---------------- | ----------------------------------------------------------------------------------------------------- |
| `--dry-run`      | Print every action, change nothing                                                                    |
| `--cli-only`     | Skip the GUI apps (Ghostty, Zed, Neovide, VS Code, Cursor) for servers and containers                 |
| `--packages a,b` | Handle only the named packages                                                                        |
| `--uninstall`    | Remove the symlinks, leave the software installed                                                     |
| `--yes`          | Answer yes to every prompt; required when stdin is not a terminal, where the script refuses to prompt |

### What the installer cannot do

* **Fonts on Linux.** Homebrew installs fonts through casks, which exist only
  on macOS. On Linux the installer fetches the Mono builds from a private Git
  LFS repository (about 70 MB of its 317 MB). If that repository is
  unreachable it prints the list of fonts to install by hand and continues.
* **Ghostty and Zed on Linux.** Both are cask-only, so the installer uses the
  system package manager. Ghostty is packaged for Arch and Ubuntu 26.04 or
  later and needs a COPR on Fedora; Zed is packaged only for Arch. Where no
  package exists the script prints the upstream download URL instead of
  piping a remote script into a shell.
* **`~/.gitconfig`.** Git reads it after `~/.config/git/config`, so any value
  in it wins. Remove or rename it. See [git/README](git/README.md).
* **Xcode's theme** must be selected by hand. See
  [Fetched themes](#fetched-themes).

The Git identity needs nothing: the committed `includeIf` applies the work
identity only under `~/work/`, so the personal identity applies here.

---

## Packages

| Package                         | Installs to           | What it is                                               |                                                          |
| ------------------------------- | --------------------- | -------------------------------------------------------- | -------------------------------------------------------- |
| [`bat/`](bat/README.md)         | `~/.config/bat/`      | `cat` with syntax highlighting; also the `$MANPAGER`     |                                                          |
| [`fish/`](fish/README.md)       | `~/.config/fish/`     | The shell: PATH, environment, prompt, functions          |                                                          |
| [`ghostty/`](ghostty/README.md) | `~/.config/ghostty/`  | Terminal emulator                                        |                                                          |
| [`git/`](git/README.md)         | `~/.config/git/`      | Global Git config, with work/personal identity switching |                                                          |
| [`neovide/`](neovide/README.md) | `~/.config/neovide/`  | Neovim's GUI: window and startup font                    |                                                          |
| [`nvim/`](nvim/README.md)       | `~/.config/nvim/`     | The editor: LSP, treesitter, plugins, keymaps            |                                                          |
| [`ruff/`](ruff/README.md)       | `~/.config/ruff/`     | Python lint and format rules, as a user-level fallback   |                                                          |
| [`tlrc/`](tlrc/README.md)       | `~/.config/tlrc/`     | `tldr` client; macOS gets a bridge symlink (see below)   |                                                          |
| [`vscode/`](vscode/README.md)   | `~/.config/Code/` \   | `~/Library/…/Code/`                                      | GUI editor. Holds the settings file **Cursor also uses** |
| [`zed/`](zed/README.md)         | `~/.config/zed/`      | GUI editor, configured as a non-modal editor             |                                                          |
| [`cursor/`](cursor/README.md)   | `~/.config/Cursor/` \ | `~/Library/…/Cursor/`                                    | Symlinks into `vscode/`, nothing else                    |

Root files are not packages and are never stowed: `install.sh`, `Brewfile`
(every dependency), `AGENTS.md` (conventions for AI coding agents, symlinked
as `CLAUDE.md` and `GEMINI.md`), `LICENSE`, and `.gitignore`.

---

## The stow model

A stow package mirrors the path its contents occupy under `$HOME`:
`bat/.config/bat/config` becomes `~/.config/bat/config`.

`install.sh` runs stow three times, because `--no-folding` and `--ignore` are
per-run flags and the packages need different combinations.

**Folded** (`nvim ruff tlrc`). Stow links the whole directory, so
`~/.config/nvim` is one symlink into the repo. New files appear without a
restow, and `nvim-pack-lock.json`, which `vim.pack` writes beside `init.lua`,
lands in the repo.

**`--no-folding`** (`bat fish ghostty git neovide zed`). Stow creates real directories
and links each file individually. A directory must stay real if anything
machine-local has to live in it:

* Runtime state the application writes beside its config: `fish_variables`,
  Zed's `conversations/`, whatever `git config --global` appends. None of it
  belongs in the repo.
* A per-OS selector symlink (`bat`, `ghostty`, `neovide`, `zed`; see below).
  In a folded directory the selector would be created inside the repo.

**`--no-folding --ignore`** (`vscode cursor`), in a third invocation. Both
editors read `~/.config` on Linux and `~/Library/Application Support` on
macOS, and the format has no conditionals, so each package ships both trees
and `--ignore` drops the one the platform does not read:

```sh
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$PWD" vscode cursor  # macOS
stow --no-folding --ignore='Library'  --target="$HOME" --dir="$PWD" vscode cursor  # Linux
```

This invocation must stay separate. Adding `vscode cursor` to the
`--no-folding` call above would apply `--ignore='\.config'` to fish, ghostty,
git, and zed and remove their entire trees.

The real directories are also where machine-local files go:

| Local file (uncommitted)             | Purpose                                                                             |
| ------------------------------------ | ----------------------------------------------------------------------------------- |
| `~/.config/fish/conf.d/99-work.fish` | Machine- or employer-specific shell helpers; fish sources it like any other snippet |
| `~/.config/git/config.work`          | Committed here, but the same mechanism applies; see [git/README](git/README.md)     |

After adding a **new file** to a `--no-folding` package, re-link it:

```sh
stow -R --no-folding --target="$HOME" --dir="$PWD" fish
```

`stow -D <pkg>` removes a package's links; `-R` is delete-then-stow.

### Per-OS configuration

Five formats have no conditionals but need different values per platform.
`install.sh` creates a symlink for each, which stow cannot express:

| Link                                             | Points at                    | Why                                                                                           |                                                                                                                        |
| ------------------------------------------------ | ---------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `~/.config/bat/config`                           | `config.darwin` \            | `config.linux`                                                                                | `--theme=auto:system` reads the macOS appearance and is macOS-only; Linux uses `--theme=auto`, which asks the terminal |
| `~/.config/ghostty/os.ghostty`                   | `os-darwin.ghostty` \        | `os-linux.ghostty`                                                                            | macOS binds ⌘; on Linux `super` is the Windows key, which desktops reserve, so it binds Ctrl+Shift                     |
| `~/.config/neovide/config.toml`                  | `config.darwin.toml` \       | `config.linux.toml`                                                                           | `frame = "transparent"` exists only on macOS, and off it Neovide discards the whole file rather than the one key       |
| `~/.config/zed/settings.json`                    | `settings.darwin.json` \     | `settings.linux.json`                                                                         | The terminal's shell is an absolute path and the Homebrew prefix differs; Zed has no per-platform keys                 |
| `~/Library/Application Support/tlrc/config.toml` | `~/.config/tlrc/config.toml` | tlrc reads XDG on Linux but Application Support on macOS; the bridge lets one file serve both |                                                                                                                        |

Each pair stays in sync apart from the settings that justify the split: the
theme flag for bat; the keybind modifier, the font weight, `font-size`, and
`command` for Ghostty; the frame style and the font size for Neovide; the
terminal's shell path for Zed. Add a new option to both files of a pair. The
Neovide and Zed variants mark theirs `PER-OS`, because those files are long
enough that a diff is the slower way to find them.

Zed's selector is two links deep — `settings.json` to `settings.<os>.json` to
the repo — and Zed's settings UI can replace either with a real file. If it
replaces the selector, edits stop reaching the repo silently; see
[Edit this file, not Zed's UI](zed/README.md).

Everything else branches at runtime: fish probes all three Homebrew prefixes,
Neovim checks `vim.uv.os_uname().sysname`, and the Brewfile uses `OS.mac?` and
`OS.linux?`.

---

## The font stack

One typeface family everywhere, in two builds, with a shared fallback chain.
The Nerd Font build goes wherever icons are drawn.

| Surface                    | Primary font                   | Ligatures |
| -------------------------- | ------------------------------ | --------- |
| Ghostty                    | `JetBrainsMono Nerd Font Mono` | on        |
| Neovide / Neovim           | `JetBrainsMono Nerd Font Mono` | on        |
| Zed, editor pane           | `JetBrains Mono`               | on        |
| Zed, integrated terminal   | `JetBrainsMono Nerd Font Mono` | on        |
| VS Code / Cursor, editor   | `JetBrains Mono`               | on        |
| VS Code / Cursor, terminal | `JetBrainsMono Nerd Font Mono` | on        |

Fallbacks, in order: `FiraCode Nerd Font Mono` (a second build with icons, so
icons survive one step down the chain), then `JetBrains Mono` (terminals only:
the same typeface without icons), `Fira Code`, `Source Code Pro`, `IBM Plex
Mono`.

**Size.** 14 on macOS. The Linux sizes come down, because macOS scales the
whole UI by the display's backing factor while the Linux desktop runs
unscaled, so there the point size has to absorb the difference:

| Surface                               | macOS | Linux |
| ------------------------------------- | ----- | ----- |
| Ghostty                               | 14    | 11    |
| Neovide / Neovim                      | 14    | 10    |
| Zed, editor and terminal              | 14    | 14    |
| VS Code / Cursor, editor and terminal | 14    | 14    |

Zed and VS Code hold one size for both platforms because their `settings.json`
files are shared across them and the format has no conditionals; VS Code's is
one real file behind four symlinks. Zed's `ui_font_size` is 16 because it sizes
UI text, not code.

**The Mono build.** Its icon glyphs occupy exactly one cell, so Neovim's
statusline, file tree, and diagnostic gutter keep their column alignment. The
plain Nerd Font build draws icons at double width.

**Ligatures.** On everywhere: `!=`, `->`, and `=>` fuse in the editors and in
the terminals alike, so Neovim renders the same text under Neovide and in
Ghostty. Two OpenType features carry them, `calt` (contextual alternates,
where JetBrains Mono and Fira Code put the coding ligatures) and `liga` (the
standard set), and each surface names both rather than relying on the font's
defaults. The terminal keys are separate from the editor keys in Zed and in VS
Code, so the two can be set apart again if command output ever needs the exact
characters. Ghostty, Zed, and VS Code apply the features to every family in
the chain; Neovide needs one entry per family, and Fira Code is a
ligature-first typeface that renders without them if its entry is missing.

**Weight.** The body text is heavier than Regular in Ghostty, by two different
mechanisms. On macOS `font-thicken = true` thickens the glyph strokes, which
compensates for macOS's thin rendering on non-Retina and scaled displays.
Thickening is a CoreText feature with no FreeType equivalent, so on Linux the
weight comes from the font: `font-style = SemiBold` and
`font-style-italic = SemiBold Italic`. Bold moves up with them, to
`font-style-bold = ExtraBold` and `font-style-bold-italic = ExtraBold Italic`,
because SemiBold against the family's Bold is one weight step and too little
for bold to register. All four live in the per-OS Ghostty files. The editors
are unaffected: only Ghostty renders at a weight other than the family's
Regular.

**Changing the font** means changing five tools. Ghostty keeps the family in
`config.ghostty` and the size in each of its two per-OS files:
[`ghostty/config.ghostty`](ghostty/.config/ghostty/config.ghostty),
[`os-darwin.ghostty`](ghostty/.config/ghostty/os-darwin.ghostty), and
[`os-linux.ghostty`](ghostty/.config/ghostty/os-linux.ghostty);
[`zed/settings.darwin.json`](zed/.config/zed/settings.darwin.json) and its
Linux twin (editor and terminal),
[`vscode/settings.json`](vscode/.config/Code/User/settings.json) (editor,
terminal, and eight further keys),
[`neovide/config.darwin.toml`](neovide/.config/neovide/config.darwin.toml)
and [`config.linux.toml`](neovide/.config/neovide/config.linux.toml), and
Neovim's `guifont` in
[`core/neovide.lua`](nvim/.config/nvim/lua/core/neovide.lua), which branches
on `vim.uv.os_uname().sysname` and so needs no second file.
VS Code does not inherit `editor.fontFamily` into CodeLens, inlay hints,
inline suggestions, the debug console, the SCM input, notebooks, or chat.
Those eight keys carry the same family and move with it.

On Linux the fonts come from the private repository described under
[What the installer cannot do](#what-the-installer-cannot-do), into
`~/.local/share/fonts`. Until they are installed, Neovim's icons render as
boxes.

---

## Light and dark

Everything visual uses **Catppuccin**: Latte (light) and Mocha (dark). On
macOS the tools that can follow the system appearance do:

| Tool             | Mechanism                                                                                |
| ---------------- | ---------------------------------------------------------------------------------------- |
| Ghostty          | `theme = light:Catppuccin Latte,dark:Catppuccin Mocha`                                   |
| Zed              | `"theme": { "mode": "system", … }`, Latte / Mocha                                        |
| VS Code / Cursor | `window.autoDetectColorScheme` + `preferredLight`/`DarkColorTheme`                       |
| bat              | `--theme=auto:system`, Latte / Mocha                                                     |
| Neovim           | `flavour = "auto"`, reading `background`                                                 |
| Neovide          | `vim.g.neovide_theme`, default `auto` (window chrome only); config.toml has no theme key |
| fish             | `fish_config theme choose catppuccin-mocha`; the theme carries both variants             |
| eza              | A fish handler points `$EZA_CONFIG_DIR` at a Latte or Mocha directory                    |
| delta            | A fish handler sets `$DELTA_FEATURES` to `catppuccin-latte` or `-mocha`                  |
| tlrc             | Palette names, which resolve through the terminal's colours                              |

The last four follow the **terminal**, not the OS. fish, eza, and delta read
fish's `$fish_terminal_color_theme`, which holds `light`, `dark`, or
`unknown` and updates when the terminal's background changes. tlrc's palette
names resolve through whatever colours the terminal uses. Reading the
terminal is why these four behave the same on Linux, which has no
`AppleInterfaceStyle`.

**delta** follows the appearance only in a shell that sets `$DELTA_FEATURES`,
which means fish. Elsewhere (a bash or zsh script, a GUI tool) delta detects
the background itself and uses its own `Monokai Extended` or `GitHub`. The
`[delta]` block in [`git/.config/git/config`](git/.config/git/config) sets no
`features` for this reason.

**fzf** is not themed. It draws with the terminal's ANSI colours, which
Ghostty sets to Catppuccin, so it follows light and dark already; the
Catppuccin fzf port would pin one flavour's hex values. See
[`20-options.fish`](fish/.config/fish/conf.d/20-options.fish).

Two tools cannot follow the appearance and are pinned to Mocha:

| Tool       | Why it is fixed                                         |
| ---------- | ------------------------------------------------------- |
| oh-my-posh | Takes a single config path; there is no light/dark form |
| Xcode      | One theme selection, stored in Xcode's own preferences  |

On **Linux**, Ghostty, Zed, and Neovide read the desktop's colour-scheme
preference through the XDG portal and still switch. bat cannot:
`auto:system` is macOS-only, so the Linux variant uses `--theme=auto`, which
infers light or dark from the terminal's background colour. Ghostty repaints
its background when the desktop switches, so the inference tracks.

### Fetched themes

Three tools read their theme from a file. `install.sh` downloads those files
rather than committing them:

| Destination                                              | From                                                    |
| -------------------------------------------------------- | ------------------------------------------------------- |
| `~/.config/git/catppuccin.gitconfig`                     | [catppuccin/delta](https://github.com/catppuccin/delta) |
| `~/.config/eza-{mocha,latte}/theme.yml`                  | [catppuccin/eza](https://github.com/catppuccin/eza)     |
| `~/Library/Developer/Xcode/UserData/FontAndColorThemes/` | [catppuccin/xcode](https://github.com/catppuccin/xcode) |

All three fail soft when the file is absent: Git ignores a missing
`include.path`, delta ignores a `features` name it cannot resolve, and eza
uses its built-in colours when `$EZA_CONFIG_DIR` holds no `theme.yml`. An
install without network leaves those three unthemed. Re-run `./install.sh`
to fetch or refresh them.

Xcode's theme is selected by hand in *Xcode → Settings → Themes*; that choice
lives in Xcode's own preferences. Xcode comes from the App Store, so it is
neither a stow package nor a Brewfile entry.

---

## The cursor

A **blinking block**, in every tool and every mode:

| Surface                    | Shape                             | Blink                                |
| -------------------------- | --------------------------------- | ------------------------------------ |
| Ghostty                    | `cursor-style = block`            | `cursor-style-blink = true`          |
| Neovim / Neovide           | `guicursor = a:block-…`           | in the same option                   |
| Zed, editor                | `cursor_shape`                    | `cursor_blink`                       |
| Zed, terminal              | `terminal.cursor_shape`           | `terminal.blinking = "on"`           |
| VS Code / Cursor, editor   | `editor.cursorStyle`              | `editor.cursorBlinking`              |
| VS Code / Cursor, terminal | `terminal.integrated.cursorStyle` | `terminal.integrated.cursorBlinking` |

Neovim's default varies the shape by mode (a vertical bar in insert, a
horizontal one in replace); `a:` sets every mode at once.

* **Neither editor's terminal inherits the editor cursor.** Zed and VS Code
  each have a second, independent pair of settings. Change one, change the
  other.
* **The unfocused cursor is hollow** in VS Code (`cursorStyleInactive:
  "outline"`) and Neovide (`neovide_cursor_unfocused_outline_width`). It stays
  block-shaped and is the only cue for which pane has keyboard focus.
* **Ghostty's `cursor-style-blink = true` differs from leaving it unset.** An
  explicit value makes Ghostty ignore DEC Mode 12, so a program cannot stop
  the blink. See [`ghostty/.config/ghostty/config.ghostty`](ghostty/.config/ghostty/config.ghostty).

---

## Column guides

Vertical lines at **80, 120, and 150**, in all three editors:

| Editor           | Setting                            |
| ---------------- | ---------------------------------- |
| Neovim / Neovide | `colorcolumn = "80,120,150"`       |
| Zed              | `wrap_guides` + `show_wrap_guides` |
| VS Code / Cursor | `editor.rulers`                    |

They are reference marks. Nothing wraps or reformats at any of them, and no
file type is exempt. Three columns cover the limits this setup works to
without choosing one: 80 is the C convention, 120 is ruff's `line-length`
here, and 150 is the point past which a line stops fitting a split pane.

* **Neovim needs an autocmd; the others do not.** `colorcolumn` is a window
  option, so the global value would also appear in `:help`, `:terminal`,
  quickfix, and the neo-tree sidebar.
  [`core/autocmds.lua`](nvim/.config/nvim/lua/core/autocmds.lua) limits it to
  buffers whose `buftype` is empty.
* **Only VS Code can colour rulers individually**, and it does not. Neovim
  and Zed each paint every column with one colour (`ColorColumn`,
  `editor.wrap_guide`), so a coloured ruler in one editor would make the
  three disagree. The `editor.rulers` block in
  [`vscode/settings.json`](vscode/.config/Code/User/settings.json) has the
  object syntax.

---

## Conventions

Every config file opens with a header block (what the file is, where its
authority ends, the traps of its format), and every setting carries a
`WHAT:` / `WHY :` / `HOW :` annotation. Files are indented with 4 spaces,
never tabs. Prose is British English with the Oxford comma. The full rules,
and the commit convention (Conventional Commits, scoped to the package), are
in [AGENTS.md](AGENTS.md).

---

## Format traps

Each of these is documented in full in the file it affects.

* **Ghostty** has no trailing comments: everything after `=` is the value,
  and a key with a comment appended is rejected
  ([`ghostty/config.ghostty`](ghostty/.config/ghostty/config.ghostty)).
* **Ghostty's `config-file` include must come last**, because later values
  win; `?` makes it optional. Check what resolved with `ghostty +show-config`,
  not only `+validate-config`, which checks syntax
  ([`ghostty/config.ghostty`](ghostty/.config/ghostty/config.ghostty)).
* **Ghostty truncates a config file at a comment or blank line ending on a
  2048-byte boundary**, applying nothing below it and reporting nothing
  ([`ghostty/config.ghostty`](ghostty/.config/ghostty/config.ghostty)).
* **Ghostty still reads the pre-1.3.0 `config` name.** Where both it and
  `config.ghostty` exist the two are loaded, the old name first, and
  repeatable keys append twice
  ([`ghostty/config.ghostty`](ghostty/.config/ghostty/config.ghostty)).
* **Neovide (TOML)** binds every bare key to the nearest `[table]` above it,
  so top-level keys must come before any table
  ([`neovide/config.darwin.toml`](neovide/.config/neovide/config.darwin.toml)
  and its Linux twin).
* **Neovide's `[font.features]` is keyed per family.** A family without an
  entry gets no features, so every font in the chain needs its own line.
  Zed's `buffer_font_features` applies to every family
  ([`neovide/config.darwin.toml`](neovide/.config/neovide/config.darwin.toml)
  and its Linux twin).
* **bat** config lines are shell-style arguments; quote values with spaces:
  `--theme-dark="Catppuccin Mocha"`
  ([`bat/config.darwin`](bat/.config/bat/config.darwin)).
* **bat's `--theme=auto:system` is macOS-only.** On Linux it does not error;
  it stops following the desktop
  ([`bat/config.linux`](bat/.config/bat/config.linux)).
* **tlrc ignores `$XDG_CONFIG_HOME` on macOS only**; Linux honours it
  ([`tlrc/config.toml`](tlrc/.config/tlrc/config.toml)).
* **A Brewfile is Ruby**, so `OS.mac?` can guard the casks.
  Homebrew passes through only `HOMEBREW_*` environment variables
  ([`Brewfile`](Brewfile)).
* **fish** universal variables (`set -U`) set from a startup file rewrite
  `fish_variables` on every shell start; use `set -g`
  ([`20-options.fish`](fish/.config/fish/conf.d/20-options.fish)).
* **Zed** may rewrite `settings.json` and strip its comments when a setting is
  changed through its UI ([zed/README](zed/README.md)).
* **VS Code** deletes every comment line above a setting when that setting is
  reset (bug #275792). Never add `window.zoomLevel`: the zoom shortcuts write
  it, so a later reset fires the bug
  ([`vscode/settings.json`](vscode/.config/Code/User/settings.json)).
* **`.stow-local-ignore` replaces** stow's default ignore list, so the defaults
  still wanted must be restated alongside any addition
  ([`fish/.stow-local-ignore`](fish/.stow-local-ignore)).

---

## Verifying a change

Run the check that matches what you touched. Ghostty, TOML, and JSONC accept
an unknown key without an error, so a typo shows up only here:

```sh
./install.sh --dry-run                                # what the installer would do
shellcheck install.sh                                 # the installer itself
/bin/bash -n install.sh                               # bash 3.2 syntax, on macOS
ghostty +validate-config                              # Ghostty syntax; silent means valid
ghostty +show-config | grep macos-option-as-alt       # Ghostty resolved values
LC_ALL=C awk 'FNR==1{n=0} {n+=length($0)+1} n%2048==0 {print FILENAME": "FNR}' \
    ghostty/.config/ghostty/*.ghostty                 # Ghostty 2048-byte boundary
git config --file git/.config/git/config --list       # Git
fish --no-execute fish/.config/fish/**/*.fish         # fish
python3 -c "import tomllib,sys;tomllib.load(open(sys.argv[1],'rb'))" <file>   # TOML
neovide --help | grep NEOVIDE_FRAME                   # Neovide really read it
nvim "+checkhealth vim.pack vim.lsp nvim-treesitter" +qa  # Neovim
stow -n -v --target="$HOME" --dir="$PWD" <pkg>        # what stow would do
ruby -c Brewfile                                      # Brewfile is Ruby
```

Ghostty 1.3.1 stops reading a config file at a comment or blank line ending
exactly on a 2048-byte boundary and applies nothing below it, without an error
and with `+validate-config` still exiting 0. A setting on the boundary is
unaffected. The `awk` line above prints any line that sits on one, comment or
not, which is the conservative check; silence means none does. Confirm the
tail of the file arrived as well, with
`ghostty +show-config | grep copy-on-select`.

The `settings.json` files for Zed, VS Code, and Cursor are JSONC. `json.load`
rejects their comments; strip them first or use a JSONC-tolerant parser.

Valid TOML is not enough for Neovide. An unknown key is ignored, but a known
key whose value the running build cannot parse fails the whole file: Neovide
prints one line to stderr, falls back to its built-in defaults, and launches
anyway, so every setting is lost at once. `neovide --help` prints the values it
did read as `[env: …]` defaults, which is how to tell the two apart — a key
missing from that output means the file was discarded, not that the key was
ignored.

Test Neovim against an empty XDG tree rather than the live config:

```sh
S=$(mktemp -d); mkdir -p "$S/config"
ln -s "$PWD/nvim/.config/nvim" "$S/config/nvim"
env XDG_CONFIG_HOME="$S/config" XDG_DATA_HOME="$S/data" \
    XDG_STATE_HOME="$S/state" XDG_CACHE_HOME="$S/cache" \
    nvim --headless "+lua print('ok')" +qa
```

On Linux also check the clipboard provider, which Neovim needs for
`clipboard=unnamedplus` and macOS has built in:

```sh
nvim "+checkhealth vim.provider"
```
