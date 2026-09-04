# Neovide

[Neovide](https://neovide.dev) is the GPU-accelerated GUI for Neovim. Its
configuration has two halves; this package is one of them.

## Install

```sh
stow --target="$HOME" --dir="$HOME/personal/dotfiles" neovide
```

Installs `.config/neovide/config.toml` → `~/.config/neovide/config.toml`. The
package is folded: nothing machine-local lives in `~/.config/neovide/`.

## The two halves

| Where                                        | Controls                                                                                             |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `neovide/.config/neovide/config.toml` (here) | Process and window creation: frame style, the font used before Neovim loads, vsync/sRGB, native tabs |
| `nvim/.config/nvim/lua/core/neovide.lua`     | Runtime behaviour: animations, translucency and blur, macOS ⌘ keybindings, live zoom (`vim.g.neovide_*`) |

Settings precedence: command-line flags > this file > environment > defaults.

## What's configured

| Setting              | Value                                                          | Why                                                                                            |
| -------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `fork`               | `true`                                                         | Launching from a shell returns the prompt                                                      |
| `frame`              | `transparent`                                                  | Titlebar in the editor's background colour; matches Ghostty's default `macos-titlebar-style`   |
| `title-hidden`       | `false`                                                        | The title labels each native tab                                                               |
| `system-native-tabs` | `true`                                                         | macOS tabs, separate from Neovim's own `:tabnew` tabpages                                      |
| `srgb`               | `false`                                                        | The default on macOS and Linux; matches what Ghostty and Zed show                              |
| Font                 | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, ligatures on | Mono build keeps Neovim's icons to one cell; see [The font stack](../README.md#the-font-stack) |
| `box-drawing`        | `native`                                                       | Draws `│ ─ ┌` geometrically so borders join without gaps                                       |

The light/dark appearance of the window chrome is a Neovim global,
`vim.g.neovide_theme`, whose default `auto` follows the system; config.toml
has no `theme` key.

## One file for both platforms

Unlike `bat` and `ghostty`, Neovide ships one config for macOS and Linux. The
macOS-only keys (`system-native-tabs`, `title-hidden`, and the `transparent`
and `buttonless` frame values) have no effect on Linux, and `srgb = false` is
the default on both, so a second file would differ only in comments. If
`frame = "transparent"` misbehaves on a Linux desktop, set `frame = "full"`.

## Format

Every bare key binds to the nearest `[table]` above it, so top-level keys come
before any table. Unknown keys are ignored without an error. The config header
has the details; `neovide --help` shows the values read from the file. Check
the parsed structure with:

```sh
python3 -c "import tomllib;print(tomllib.load(open('$HOME/.config/neovide/config.toml','rb')))"
```

## Font sync

The `[font]` section prevents a wrong-font flash at startup: it covers the
frames before `init.lua` runs, after which Neovim's own `guifont` takes over.
Family and size must match `nvim/.config/nvim/lua/core/neovide.lua`. Ligatures
are on here and in Ghostty, so Neovim shows fused `!=` and `->` either way;
see [The font stack](../README.md#the-font-stack).
