# dotfiles

Configuration for a **macOS and Linux** development setup: **Ghostty** running
**fish**, **Neovim** (terminal and via **Neovide**), **Zed**, **Visual Studio
Code**, **Cursor**, **Git**, **bat** and **tlrc**. Installed by one script, deployed with GNU **stow**.

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
git clone <this-repo> ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

That is the whole thing. The script detects your platform, installs Homebrew if
it is missing, applies the `Brewfile`, backs up anything already in the way,
links every package with stow, selects the per-OS config variants, bootstraps
Neovim, and offers to make fish your login shell.

| Option           | Effect                                                                                  |
| ---------------- | --------------------------------------------------------------------------------------- |
| `--dry-run`      | Print every action, change nothing                                                      |
| `--cli-only`     | Skip the GUI apps (Ghostty, Zed, Neovide, VS Code, Cursor) — for servers and containers |
| `--packages a,b` | Only handle the named packages                                                          |
| `--uninstall`    | Remove the symlinks, leave the software installed                                       |
| `--yes`          | Never prompt; implied when stdin is not a terminal                                      |

Run `./install.sh --dry-run` first if you want to see exactly what it will do.

### What still needs you

* **Fonts on Linux — usually nothing.** Homebrew installs fonts through casks,
  which are macOS-only, so on Linux the installer pulls them from a private
  Git LFS repository instead, fetching only the ~70 MB it will actually
  install rather than the whole 317 MB. If that repository is unreachable —
  no key, no access, offline — it prints the list for you to install by hand
  and carries on.
* **Ghostty and Zed on some distros.** Both are cask-only, so on Linux the
  script uses your package manager. Ghostty is packaged for Arch and Ubuntu
  26.04+ and needs a COPR on Fedora; Zed is packaged only for Arch. Where
  there is no package, the script points you at the upstream download rather
  than piping a remote script into your shell.
* **Nothing, for the git identity.** This repo used to live under `~/work/`,
  where the committed `includeIf` applies the work identity, and needed a
  per-repo override to escape it. It now lives outside that path, so the
  personal identity applies by default — see [git/README](git/README.md).

---

---

## Packages

| Package                         | Installs to                                  | What it is                                               |
| ------------------------------- | -------------------------------------------- | -------------------------------------------------------- |
| [`bat/`](bat/README.md)         | `~/.config/bat/`                             | `cat` with syntax highlighting; also the `$MANPAGER`     |
| [`fish/`](fish/README.md)       | `~/.config/fish/`                            | The shell: PATH, environment, prompt, functions          |
| [`ghostty/`](ghostty/README.md) | `~/.config/ghostty/`                         | Terminal emulator                                        |
| [`git/`](git/README.md)         | `~/.config/git/`                             | Global Git config, with work/personal identity switching |
| [`neovide/`](neovide/README.md) | `~/.config/neovide/`                         | Neovim's GUI: window and startup font                    |
| [`nvim/`](nvim/README.md)       | `~/.config/nvim/`                            | The editor: LSP, treesitter, plugins, keymaps            |
| [`tlrc/`](tlrc/README.md)       | `~/.config/tlrc/`                            | `tldr` client — macOS gets a bridge symlink, see below   |
| [`vscode/`](vscode/README.md)   | `~/.config/Code/` \| `~/Library/…/Code/`     | GUI editor. Holds the settings file **Cursor also uses** |
| [`zed/`](zed/README.md)         | `~/.config/zed/`                             | GUI editor, configured as a normal (non-modal) editor    |
| [`cursor/`](cursor/README.md)   | `~/.config/Cursor/` \| `~/Library/…/Cursor/` | Nothing but symlinks into `vscode/`                      |

Root files — `install.sh`, `Brewfile` (every dependency), `AGENTS.md`
(conventions for AI coding agents, symlinked as `CLAUDE.md` and `GEMINI.md`),
`LICENSE`, `.gitignore` — are not packages and are never stowed.

---

## The stow model

A stow package mirrors the path its contents occupy under `$HOME`. So
`bat/.config/bat/config` becomes `~/.config/bat/config`, and tlrc's odd
`Library/Application Support/…` path needs no special handling — it is just
what that file's real location is.

Three invocations, because the packages want different linking strategies
and because both `--no-folding` and `--ignore` are **per-run** flags rather
than per-package ones:

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

**`--no-folding` plus `--ignore`** — `vscode cursor`, in a third invocation of
their own. Both editors read their settings from `~/.config` on Linux but from
`~/Library/Application Support` on macOS, and the format has no conditional, so
each package ships **both** trees and `--ignore` drops the one this platform
does not use:

```sh
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$PWD" vscode cursor  # macOS
stow --no-folding --ignore='Library'  --target="$HOME" --dir="$PWD" vscode cursor  # Linux
```

Keeping this separate is not tidiness. Adding these two to the `--no-folding`
list above would apply `--ignore='\.config'` to **fish, ghostty, git and zed**
as well, and erase their entire trees.

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

| Surface                     | Primary font                   | Ligatures |
| --------------------------- | ------------------------------ | --------- |
| Ghostty                     | `JetBrainsMono Nerd Font Mono` | off       |
| Neovide / Neovim            | `JetBrainsMono Nerd Font Mono` | on        |
| Zed — editor pane           | `JetBrains Mono`               | on        |
| Zed — integrated terminal   | `JetBrainsMono Nerd Font Mono` | off       |
| VS Code / Cursor — editor   | `JetBrains Mono`               | on        |
| VS Code / Cursor — terminal | `JetBrainsMono Nerd Font Mono` | off       |

Fallbacks, in order: **FiraCode Nerd Font Mono** (a second icon-carrying build,
so icons survive one more step down the chain), then **JetBrains Mono**
(terminals only — the same typeface without the patched icons), **Fira Code**,
**Source Code Pro**, **IBM Plex Mono**. Size is **14** everywhere; Zed's
`ui_font_size` stays 16 because it sizes UI chrome, not code.

On **Linux the fonts come from a private repository** rather than Homebrew,
since casks do not exist there. `install.sh` fetches only the builds the
configs reference — the Mono ones — into `~/.local/share/fonts`. If it cannot
reach the repository it says so and moves on, and Neovim's icons render as
boxes until the fonts are installed some other way.

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

Changing the font means changing it in five places: `ghostty/`, `zed/` (twice
— buffer and terminal), `vscode/` (twice, and the eight further keys below),
`neovide/`, and Neovim's `guifont`.

VS Code needs the extra care: it does **not** inherit `editor.fontFamily` into
its other surfaces, so the CodeLens, inlay-hint, inline-suggestion, debug
console, SCM input, notebook and chat fonts each carry their own key. That is
product fragmentation, not preference — they are all set to the same family and
must move together.

---

## Light and dark

Everything visual uses **Catppuccin**, in the Latte (light) and Mocha
(dark) flavours. On **macOS** the tools that can follow the system appearance
all do, so the stack flips together:

| Tool             | Mechanism                                                                     |
| ---------------- | ----------------------------------------------------------------------------- |
| Ghostty          | `theme = light:Catppuccin Latte,dark:Catppuccin Mocha`                        |
| Zed              | `"theme": { "mode": "system", … }` — Latte / Mocha                            |
| VS Code / Cursor | `window.autoDetectColorScheme` + `preferredLight`/`DarkColorTheme`            |
| bat              | `--theme=auto:system` — Latte / Mocha                                         |
| Neovim           | `flavour = "auto"`, reading `background`                                      |
| Neovide          | `theme = "auto"` (window chrome only)                                         |
| fish             | `fish_config theme choose catppuccin-mocha` — the theme carries both variants |
| eza              | A fish handler points `$EZA_CONFIG_DIR` at a Latte or Mocha directory         |
| tlrc             | Palette **names**, which resolve through the terminal's colours               |

The last two follow the **terminal**, not the OS. Both key off fish's
read-only `$fish_terminal_color_theme`, which holds `light`, `dark` or
`unknown` and updates live when the terminal's background changes. That is
usually the same thing as the system appearance, and it is what makes these
two work identically on Linux, where there is no `AppleInterfaceStyle` to read.

Three tools **cannot** follow the appearance, and are pinned to Mocha:

| Tool       | Why it is fixed                                                     |
| ---------- | ------------------------------------------------------------------- |
| oh-my-posh | Takes a single config path; there is no light/dark form             |
| delta      | `syntax-theme` takes one value; no pair syntax, no system detection |
| Xcode      | One theme selection, stored in Xcode's own preferences              |

### Themes that are fetched, not committed

Three of these ship their theme as a *file* the tool reads, and those files are
downloaded by `install.sh` rather than kept in this repo:

| Destination                                              | From                                                    |
| -------------------------------------------------------- | ------------------------------------------------------- |
| `~/.config/git/catppuccin.gitconfig`                     | [catppuccin/delta](https://github.com/catppuccin/delta) |
| `~/.config/eza-{mocha,latte}/theme.yml`                  | [catppuccin/eza](https://github.com/catppuccin/eza)     |
| `~/Library/Developer/Xcode/UserData/FontAndColorThemes/` | [catppuccin/xcode](https://github.com/catppuccin/xcode) |

Every one of them **fails soft**. Git ignores an `include.path` that does not
exist, delta ignores a `features` name it cannot resolve, and eza falls back to
its built-in colours when `$EZA_CONFIG_DIR` holds no `theme.yml`. So an install
with no network leaves those three unthemed and nothing else affected. Re-run
`./install.sh` to fetch or refresh them.

**Xcode is the one thing here you must finish by hand.** The installer places
the theme files; selecting one is done in *Xcode → Settings → Themes*, and that
choice lives in Xcode's own preferences where this repo cannot reach it. Xcode
is also the only configured application that is neither a stow package nor a
Brewfile entry, because it comes from the App Store.

`fzf` is deliberately **not** themed, even though a port exists. Left alone it
draws with the terminal's ANSI colours, which Ghostty already sets to
Catppuccin — so it is themed *and* follows light/dark for free. The port
hardcodes one flavour's hex values, which would take that away. See
`fish/.config/fish/conf.d/20-options.fish` for the full reasoning.

`tlrc` is worth understanding: it sets no theme at all. Its styles are palette
*names* rather than hex, so it renders in whatever colours the terminal is
using — which, Ghostty being Catppuccin, means it is Catppuccin in both modes
for free. Hardcoding hex there would have *lost* that.

On **Linux it is one step less direct.** Ghostty, Zed and Neovide read the
desktop's colour-scheme preference through the XDG portal, so they still
switch. bat cannot: `auto:system` is documented as macOS-only, so the Linux
variant uses `--theme=auto`, which infers light or dark from the terminal's
background colour instead. In practice that still tracks — Ghostty repaints its
background when the desktop flips — but it is inference rather than a signal.

---

## The cursor

A **blinking block**, in every tool and every mode. Like the font stack, this
is only correct if all of it agrees, so the settings are listed together:

| Surface                     | Shape                             | Blink                                |
| --------------------------- | --------------------------------- | ------------------------------------ |
| Ghostty                     | `cursor-style = block`            | `cursor-style-blink = true`          |
| Neovim / Neovide            | `guicursor = a:block-…`           | in the same option                   |
| Zed — editor                | `cursor_shape`                    | `cursor_blink`                       |
| Zed — terminal              | `terminal.cursor_shape`           | `terminal.blinking = "on"`           |
| VS Code / Cursor — editor   | `editor.cursorStyle`              | `editor.cursorBlinking`              |
| VS Code / Cursor — terminal | `terminal.integrated.cursorStyle` | `terminal.integrated.cursorBlinking` |

Neovim was the only one that needed changing. Its default varies the shape by
mode — a vertical bar in insert, a horizontal one in replace — which nothing
else in the stack does. `a:` covers every mode at once.

Three details are easy to get wrong:

* **Neither editor's terminal inherits its editor cursor.** Zed and VS Code
  both have a second, independent pair of settings, which is why the same
  values appear twice in each file. Change one, change the other.
* **The unfocused cursor is deliberately hollow**, in VS Code
  (`cursorStyleInactive: "outline"`) and Neovide
  (`neovide_cursor_unfocused_outline_width`). It is still block-shaped, and it
  is the only cue left for which pane has keyboard focus.
* **Ghostty's `cursor-style-blink = true` is not the same as leaving it
  blank**, even though both blink. Unset, Ghostty also honours DEC Mode 12, so
  a program can switch blinking off; any explicit value makes it ignore Mode
  12. `DECSCUSR` still controls the shape either way, which is how Neovim asks
  for a block and gets one instead of fighting the terminal.

---

## Column guides

Vertical lines at **80, 120, 150 and 200**, in all three editors:

| Editor           | Setting                            |
| ---------------- | ---------------------------------- |
| Neovim / Neovide | `colorcolumn = "80,120,150,200"`   |
| Zed              | `wrap_guides` + `show_wrap_guides` |
| VS Code / Cursor | `editor.rulers`                    |

They are reference marks, not an enforced limit — nothing wraps or reformats at
any of them, and no file type is exempt. Four columns is what makes the fixed
list workable: with one number you would have to pick between Rust's 100,
ruff's 88 and C's 80, and with four the one a given project cares about is
already on screen.

Two asymmetries are worth knowing:

* **Neovim needs an autocmd, the others do not.** `colorcolumn` is a *window*
  option, so the global value lands in `:help`, `:terminal`, quickfix and the
  neo-tree sidebar as well. `nvim/.config/nvim/lua/core/autocmds.lua` narrows
  it to buffers whose `buftype` is empty — that one test covers every kind of
  non-file buffer at once. Zed and VS Code have no equivalent problem, their
  terminals not being editors.
* **Only VS Code can colour rulers individually**, via `{ "column": N,
  "color": … }`. It deliberately does not. Neovim paints every column with the
  single `ColorColumn` highlight group and Zed with the single
  `editor.wrap_guide` colour, so a coloured ruler in one editor would only make
  the three disagree.

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
