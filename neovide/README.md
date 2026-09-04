# Neovide

[Neovide](https://neovide.dev) is the GPU-accelerated GUI for Neovim. Its
configuration has two halves; this package is one of them.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" neovide
```

Installs both `.config/neovide/config.darwin.toml` and `config.linux.toml`
into `~/.config/neovide/`, and `install.sh` links one of them as
`config.toml`, which is the name Neovide reads. The package is `--no-folding`
so that selector link lands in `$HOME` rather than inside the repo; see
[The stow model](../README.md#the-stow-model). Adding a file to the package
needs a restow, `stow -R --no-folding …`, or it is not linked.

## The two halves

| Where                                                       | Controls                                                                                                 |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `neovide/.config/neovide/config.{darwin,linux}.toml` (here) | Process and window creation: frame style, the font used before Neovim loads, vsync/sRGB, native tabs     |
| `nvim/.config/nvim/lua/core/neovide.lua`                    | Runtime behaviour: animations, translucency and blur, macOS ⌘ keybindings, live zoom (`vim.g.neovide_*`) |

Settings precedence: command-line flags > this file > environment > defaults.

## What's configured

| Setting              | Value                                                          | Why                                                                                            |
| -------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `fork`               | `true`                                                         | Launching from a shell returns the prompt                                                      |
| `frame`              | `transparent` on macOS, `full` on Linux                        | Titlebar in the editor's background colour; matches Ghostty's default `macos-titlebar-style`   |
| `title-hidden`       | `false`                                                        | The title labels each native tab                                                               |
| `system-native-tabs` | `true`                                                         | macOS tabs, separate from Neovim's own `:tabnew` tabpages                                      |
| `srgb`               | `false`                                                        | The default on macOS and Linux; matches what Ghostty and Zed show                              |
| Font                 | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, ligatures on | Mono build keeps Neovim's icons to one cell; see [The font stack](../README.md#the-font-stack) |
| `box-drawing`        | `native`                                                       | Draws `│ ─ ┌` geometrically so borders join without gaps                                       |

The light/dark appearance of the window chrome is a Neovim global,
`vim.g.neovide_theme`, whose default `auto` follows the system; config.toml
has no `theme` key.

## One file per platform

Neovide ships a variant per platform, like `bat` and `ghostty`, and
`install.sh` links one as `config.toml`. The two differ in the settings marked
`PER-OS`: `frame` and the font size. Add any new option to both.

The split is not a tidiness measure. `title-hidden` and `system-native-tabs`
are macOS-only but are plain booleans, so they parse anywhere and simply do
nothing on Linux. `frame` is different: Neovide gates its `transparent` and
`buttonless` variants behind a compile-time target check, so off macOS they do
not exist to parse into, and a value the build cannot deserialise fails the
whole config struct rather than the one key. Neovide prints one line to
stderr, falls back to its built-in defaults, and launches anyway — so a shared
file carrying `frame = "transparent"` would cost Linux the font stack, `vsync`,
`srgb`, `idle`, `fork`, and `box-drawing` too, silently.

`NEOVIDE_FRAME` is not a way around it. Environment variables are parsed by
the command-line layer, which on Linux rejects the value and exits before a
window appears.

## Format

Every bare key binds to the nearest `[table]` above it, so top-level keys come
before any table. An unknown key is ignored without an error; a known key with
a value Neovide cannot parse discards the entire file. The config header has
the details. Valid TOML is necessary but not sufficient, so check both:

```sh
python3 -c "import tomllib;print(tomllib.load(open('$HOME/.config/neovide/config.toml','rb')))"
neovide --help | grep NEOVIDE_FRAME     # a missing `env:` line means discarded
```

## Font sync

The `[font]` section prevents a wrong-font flash at startup: it covers the
frames before `init.lua` runs, after which Neovim's own `guifont` takes over.
Family and size must match `nvim/.config/nvim/lua/core/neovide.lua`. Ligatures
are on here and in Ghostty, so Neovim shows fused `!=` and `->` either way;
see [The font stack](../README.md#the-font-stack).
