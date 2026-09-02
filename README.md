# dotfiles

Configuration for a macOS development setup: **Ghostty** running **fish**,
**Neovim** (terminal and via **Neovide**), **Zed**, **Git**, **bat** and
**tlrc**. Deployed with GNU **stow**.

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

# 1. Everything external: fonts, stow, language servers, formatters, apps.
brew bundle --file Brewfile

# 2. Back up whatever is already in place — stow refuses to overwrite real
#    files, and these are the paths it will claim.
BACKUP=~/.dotfiles-backup-$(date +%Y%m%d-%H%M%S); mkdir -p "$BACKUP"
mv ~/.gitconfig ~/.gitignore_global "$BACKUP"/ 2>/dev/null
for d in nvim neovide bat ghostty; do mv ~/.config/$d "$BACKUP"/ 2>/dev/null; done
for f in fish/config.fish zed/settings.json git/ignore; do
  [ -e ~/.config/$f ] && { mkdir -p "$BACKUP/$(dirname $f)"; mv ~/.config/$f "$BACKUP/$f"; }
done

# 3. Link it all into place. Two commands — see "The stow model" below.
stow --target="$HOME" --dir="$PWD" bat ghostty neovide nvim tlrc
stow --no-folding --target="$HOME" --dir="$PWD" fish git zed

# 4. First Neovim launch installs plugins and compiles parsers.
nvim
```

Preview any stow operation without touching the disk by adding `-n -v`.

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
| [`tlrc/`](tlrc/README.md)       | `~/Library/Application Support/tlrc/` | `tldr` client — note the non-XDG path                    |
| [`zed/`](zed/README.md)         | `~/.config/zed/`                      | GUI editor, configured as a normal (non-modal) editor    |

Root files — `Brewfile` (every dependency), `CLAUDE.md` (conventions for AI
agents working here), `.gitignore` — are not packages and are never stowed.

---

## The stow model

A stow package mirrors the path its contents occupy under `$HOME`. So
`bat/.config/bat/config` becomes `~/.config/bat/config`, and tlrc's odd
`Library/Application Support/…` path needs no special handling — it is just
what that file's real location is.

Two invocations, because the packages want different linking strategies:

**Folded** — `bat ghostty neovide nvim tlrc`. Stow links the whole directory,
so `~/.config/nvim` *is* a symlink to this repo. New files appear live with no
restow, and `nvim-pack-lock.json` — which `vim.pack` writes into the config
directory — lands in the repo where it belongs.

**`--no-folding`** — `fish git zed`. Stow creates real directories and links
each file individually. Required because these applications write runtime
state beside their config (`fish_variables`, Zed's `conversations/`, whatever
`git config --global` appends), which must stay out of the repo. It is also
what makes local overlays possible:

| Local file (uncommitted)             | Purpose                                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------------------------- |
| `~/.config/fish/conf.d/99-work.fish` | Machine- or employer-specific shell helpers; fish auto-sources it like any other snippet |
| `~/.config/git/config.work`          | Committed here, but the same mechanism applies — see [git/README](git/README.md)         |

After adding a **new file** to a `--no-folding` package, re-link it:

```sh
stow -R --no-folding --target="$HOME" --dir="$PWD" fish
```

`stow -D <pkg>` removes a package's links; `-R` is delete-then-stow.

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

Fallbacks, in order: **JetBrains Mono** (terminals only — the same typeface
without the patched icons), **Fira Code**, **Source Code Pro**, **IBM Plex
Mono**. Size is **14** everywhere; Zed's `ui_font_size` stays 16 because it
sizes UI chrome, not code.

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

Every tool follows the macOS system appearance, so the whole stack flips
together:

| Tool    | Mechanism                                                       |
| ------- | --------------------------------------------------------------- |
| Ghostty | `theme = light:TokyoNight Day,dark:TokyoNight Night`            |
| Zed     | `"theme": { "mode": "system", … }` — Ayu Light / Ayu Dark       |
| bat     | `--theme=auto:system` — Catppuccin Latte / Mocha                |
| Neovide | `theme = "auto"`                                                |
| tlrc    | Palette **names**, which resolve through the terminal's colours |
| Neovim  | Its built-in default colorscheme, which follows `background`    |

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
* **tlrc** ignores `$XDG_CONFIG_HOME` on macOS.
* **Zed** may rewrite `settings.json` (and strip its comments) when you change
  a setting through its UI. Edit the repo file, then `stow -R … zed`.
* **`.stow-local-ignore` replaces** stow's default ignore list rather than
  adding to it, so the defaults have to be restated alongside any addition.

---

## Verifying a change

```sh
ghostty +validate-config                              # Ghostty
git config --file git/.config/git/config --list       # Git
fish --no-execute fish/.config/fish/**/*.fish         # fish
python3 -c "import tomllib,sys;tomllib.load(open(sys.argv[1],'rb'))" <file>   # TOML
nvim "+checkhealth vim.pack vim.lsp nvim-treesitter"  # Neovim
stow -n -v --target="$HOME" --dir="$PWD" <pkg>        # what stow would do
```
