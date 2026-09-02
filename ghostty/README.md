# Ghostty

[Ghostty](https://ghostty.org) is the terminal emulator this setup runs in. It
launches your login shell, renders Neovim, and its theme follows the system
appearance. Runs on macOS and Linux.

## Install

`./install.sh` handles this. By hand:

```sh
stow --no-folding --target="$HOME" --dir="$HOME/work/dotfiles" ghostty
ln -sfn os-darwin.conf ~/.config/ghostty/os.conf   # or os-linux.conf
```

**`--no-folding` is required** so `~/.config/ghostty/` stays a real directory
and can hold that selector symlink.

Reload a running Ghostty with `⌘⇧,` (macOS) or `Ctrl+Shift+,` (Linux).

## What's configured

| Area       | Choice                                                                                                | Why                                                                                                                              |
| ---------- | ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Font       | `JetBrainsMono Nerd Font Mono` → `JetBrains Mono` → Fira Code → Source Code Pro → IBM Plex Mono, 14pt | The Mono build keeps Neovim's icons to one cell; the plain build leads the fallbacks so missing glyphs stay in the same typeface |
| Ligatures  | **off** (`-calt -liga`)                                                                               | This is a terminal: logs and diffs should show exact characters                                                                  |
| Theme      | `light:TokyoNight Day,dark:TokyoNight Night`                                                          | Follows macOS, matching Zed, bat and Neovide                                                                                     |
| Option key | `macos-option-as-alt = left`                                                                          | Makes Neovim's `<M-j>` / `<M-k>` work; right Option still composes é/ß                                                           |
| Window     | 100×30 cells, 8/6pt padding, 0.95 opacity + blur                                                      | Breathing room; the translucency is a deliberate difference from Neovide, which stays opaque                                     |
| Shell      | `/opt/homebrew/bin/fish --login --interactive`                                                        | Setting `command` defeats automatic shell integration, so `shell-integration = fish` is stated explicitly right after            |

## Per-OS files

Keybinds and the macOS-only keys live in a sibling file that `install.sh`
selects, pulled in by `config-file = ?os.conf` at the bottom of `config`:

| File             | Contains                                                    |
| ---------------- | ----------------------------------------------------------- |
| `os-darwin.conf` | `macos-option-as-alt`, `font-thicken`, and ⌘-based keybinds |
| `os-linux.conf`  | Ctrl+Shift keybinds, plus documented GTK extension points   |

The keybinds cannot be shared: macOS uses ⌘ (`super`), but on Linux `super` is
the Windows key, which desktop environments claim globally — GNOME opens the
Activities Overview on it. Those bindings would register and then never fire,
which is worse than not setting them. Linux therefore uses Ctrl+Shift, matching
every other Linux terminal.

The `?` prefix makes the include optional, so Ghostty starts cleanly before
`install.sh` has created the link. It is the **last** line because later values
win.

## Gotchas

* **There are no trailing comments.** Everything after `=` is the value, so
  `font-thicken = true  # default: false` sets the value to the literal string
  `true  # default: false` and the key is rejected. Annotations go on their own
  lines.
* **Unknown keys are ignored silently.** Always run `ghostty +validate-config`
  after editing.
* **`+validate-config` only checks syntax.** To prove the per-OS include
  actually loaded, check a resolved value:
  `ghostty +show-config | grep macos-option-as-alt`.
* `background-blur` works on macOS and on Linux compositors that implement it
  (KWin, Hyprland); under plain GNOME/Mutter it simply has no effect.

## Recipes

### Turn ligatures back on
Delete the two `font-feature` lines.

### Change the theme
`ghostty +list-themes` lists 400+. Keep the `light:…,dark:…` form to stay in
step with the rest of the stack.

### Inspect defaults
`ghostty +show-config --default` prints every key and its default;
`ghostty +list-keybinds --default` does the same for bindings.
