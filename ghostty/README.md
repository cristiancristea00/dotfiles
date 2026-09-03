# Ghostty

[Ghostty](https://ghostty.org) is the terminal emulator. It starts the login
shell, renders Neovim, and follows the system appearance. Runs on macOS and
Linux.

## Install

`./install.sh` handles this. By hand:

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" ghostty
ln -sfn os-darwin.conf ~/.config/ghostty/os.conf   # or os-linux.conf
```

Stow's `--no-folding` keeps `~/.config/ghostty/` a real directory for the
selector symlink. See [The stow model](../README.md#the-stow-model) and
[Per-OS configuration](../README.md#per-os-configuration) in the root README.

Reload a running Ghostty with `⌘⇧,` (macOS) or `Ctrl+Shift+,` (Linux).

## What's configured

| Area               | Choice                                                                                                                   | Why                                                                                                           |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| Font               | `JetBrainsMono Nerd Font Mono` → `FiraCode Nerd Font Mono` → `JetBrains Mono` → Fira Code → Source Code Pro → IBM Plex Mono, 14pt | The Mono build keeps Neovim's icons to one cell; see [The font stack](../README.md#the-font-stack)     |
| Ligatures          | off (`-calt -liga`)                                                                                                      | Logs and diffs must show the exact characters                                                                 |
| Theme              | `light:Catppuccin Latte,dark:Catppuccin Mocha`                                                                           | Follows the system appearance with the rest of the stack; see [Light and dark](../README.md#light-and-dark)   |
| Window             | 100×30 cells, 8/6pt padding, 0.95 opacity with blur                                                                      | Neovide stays opaque; this is the one translucent surface                                                     |
| Cursor             | Blinking block                                                                                                           | Same as every other tool; see [The cursor](../README.md#the-cursor)                                           |
| Shell              | `command` unset, `shell-integration = detect`                                                                            | The login shell starts on every platform; an absolute path breaks where fish lives elsewhere                  |
| Option key (macOS) | `macos-option-as-alt = left`                                                                                             | Neovim's `<M-j>` / `<M-k>` work; the right Option key still composes é and ß                                  |

## Per-OS files

`config-file = ?os.conf` at the bottom of `config` includes the file
`install.sh` links:

| File             | Contains                                                    |
| ---------------- | ----------------------------------------------------------- |
| `os-darwin.conf` | `macos-option-as-alt`, `font-thicken`, and ⌘-based keybinds |
| `os-linux.conf`  | Ctrl+Shift keybinds, plus GTK extension points              |

Binding `super` on Linux registers but never fires, because desktops reserve
it; [`os-linux.conf`](.config/ghostty/os-linux.conf) has the reasoning.

## Gotchas

* **No trailing comments.** Everything after `=` is the value, and a key with
  a comment appended is rejected. Annotations go on their own line; see the
  header of [`config`](.config/ghostty/config).
* **Unknown keys are ignored.** `ghostty +validate-config` checks syntax;
  `ghostty +show-config | grep macos-option-as-alt` confirms the per-OS include
  loaded.
* **`background-blur`** is supported on macOS and KDE Plasma; under GNOME's
  Mutter it has no effect.

## Recipes

* **Ligatures back on.** Delete the two `font-feature` lines.
* **Change the theme.** `ghostty +list-themes` lists the bundled themes. Keep
  the `light:…,dark:…` form to follow the appearance.
* **Inspect defaults.** `ghostty +show-config --default` prints every key and
  its default; `ghostty +list-keybinds --default` does the same for bindings.
