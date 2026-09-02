# Neovide

[Neovide](https://neovide.dev) is the GPU-accelerated GUI for Neovim. Its
configuration has **two halves** and this package is only one of them.

## Install

```sh
stow --target="$HOME" --dir="$HOME/personal/dotfiles" neovide
```

Installs `.config/neovide/config.toml` → `~/.config/neovide/config.toml`.

## The two halves

| Where                                        | Controls                                                                                             |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `neovide/.config/neovide/config.toml` (here) | Process and window creation: frame style, the font used before Neovim loads, vsync/sRGB, native tabs |
| `nvim/.config/nvim/lua/core/neovide.lua`     | Runtime behaviour: animations, macOS ⌘ keybindings, live zoom (`vim.g.neovide_*`)                    |

Settings precedence: command-line flags > this file > environment > defaults.

## What's configured

| Setting              | Value                                                              | Why                                                                                                                        |
| -------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `fork`               | `true`                                                             | Launching from a shell returns the prompt immediately                                                                      |
| `frame`              | `transparent`                                                      | Seamless titlebar; matches Ghostty's default `macos-titlebar-style`                                                        |
| `title-hidden`       | `false`                                                            | The title labels each native tab                                                                                           |
| `system-native-tabs` | `true`                                                             | Real macOS tabs — separate from Neovim's own `:tabnew` tabpages                                                            |
| `srgb`               | `false`                                                            | The default on **both** macOS and Linux (`neovide --help` confirms); enabling it made colours diverge from every other app |
| `theme`              | `auto`                                                             | Follows macOS, like Ghostty, Zed and bat                                                                                   |
| Font                 | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, **ligatures on** | Mono build keeps Neovim's icons to one cell; ligatures because this is an editor                                           |
| `box-drawing`        | `native`                                                           | Draws `│ ─ ┌` geometrically so borders join without hairline gaps                                                          |

## Two traps this file has fallen into

1. **TOML table order.** Every bare `key = value` belongs to the most recent
   `[table]` header above it. A previous version had `idle`,
   `system-native-tabs` and `mode` sitting below `[font]`, so they parsed as
   `font.idle`, `font.system-native-tabs` and `font.mode` — **all three
   silently did nothing**, and `mode` had lost its `[box-drawing]` table
   entirely. Top-level keys must come first, before any table header.
2. **Unknown keys are ignored.** Neovide never errors on a typo'd or misplaced
   key; the setting simply has no effect. Verify structure with:
   ```sh
   python3 -c "import tomllib;print(tomllib.load(open('$HOME/.config/neovide/config.toml','rb')))"
   ```

## Why this file is not split per OS

Unlike `bat` and `ghostty`, Neovide ships **one** config for both platforms.
Its macOS-only keys (`system-native-tabs`, `title-hidden`, `frame =
"transparent"`) are inert on Linux rather than harmful, and `srgb = false` is
the default on both — so duplicating a heavily documented file to vary one
setting would cost more than it buys. The per-OS behaviour is annotated inline
instead.

The one open question is what `frame = "transparent"` does on Linux: it refers
to the macOS titlebar, and the expected fallback is a normal frame. If it
misbehaves on your desktop, set `frame = "full"`.

## Font sync

The `[font]` section exists to prevent a wrong-font flash at startup. Once
`init.lua` runs, Neovim's own `guifont` takes over for the session — so family
and size must be kept in step with `nvim/.config/nvim/lua/core/neovide.lua`.

## Consequence worth knowing

Ligatures are **on** here but **off** in Ghostty, so Neovim shows fused `!=`
and `->` in Neovide and literal characters in a terminal. That is the
deliberate editor/terminal split described in the root README.
