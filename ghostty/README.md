# Ghostty

[Ghostty](https://ghostty.org) is the terminal emulator. It runs the login
shell, renders Neovim, and follows the system appearance. Runs on macOS and
Linux.

## Install

`./install.sh` handles this. By hand:

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" ghostty
ln -sfn os-darwin.ghostty ~/.config/ghostty/os.ghostty   # or os-linux.ghostty
```

Stow's `--no-folding` keeps `~/.config/ghostty/` a real directory for the
selector symlink. See [The stow model](../README.md#the-stow-model) and
[Per-OS configuration](../README.md#per-os-configuration) in the root README.

Reload a running Ghostty with `⌘⇧,` (macOS) or `Ctrl+Shift+,` (Linux).

## What's configured

| Area               | Choice                                                                                                                            | Why                                                                                                                                       |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Font               | `JetBrainsMono Nerd Font Mono` → `FiraCode Nerd Font Mono` → `JetBrains Mono` → Fira Code → Source Code Pro → IBM Plex Mono, 14pt | The Mono build keeps Neovim's icons to one cell; see [The font stack](../README.md#the-font-stack)                                        |
| Ligatures          | on (`+calt +liga`)                                                                                                                | The same two features every other surface names; see [The font stack](../README.md#the-font-stack)                                        |
| Theme              | `light:Catppuccin Latte,dark:Catppuccin Mocha`, palette 16-255 generated                                                          | Follows the system appearance with the rest of the stack; see [Light and dark](../README.md#light-and-dark)                               |
| Window             | 100×30 cells, 10/8pt padding, 0.95 opacity with blur, unfocused splits at 0.5                                                     | The same 0.95 and blur Neovide uses, so the two sit at the same depth                                                                     |
| Titlebar           | Tab bar merged into it, on both platforms                                                                                         | Reclaims the row a separate tab bar takes                                                                                                 |
| Cursor             | Blinking block                                                                                                                    | Same as every other tool; see [The cursor](../README.md#the-cursor)                                                                       |
| Selection          | `copy-on-select = clipboard`                                                                                                      | Writes both clipboards, so middle-click and Ctrl+Shift+V see the same text                                                                |
| Shell              | `command` set per OS to the Homebrew fish, `shell-integration = fish`                                                             | One value for every launch route: unset, `$SHELL` wins for a CLI launch and the passwd entry for a desktop one. A bare name cannot be resolved inside the macOS `login` wrapper, so the path is absolute and lives in the per-OS files |
| SSH                | `ssh-env` and `ssh-terminfo`                                                                                                      | Installs Ghostty's terminfo on a remote host, falling back to `xterm-256color`                                                            |
| Bell               | `system` and `border` added                                                                                                       | An audible bell, and the only effect visible while the window has focus                                                                   |
| Notifications      | `notify-on-command-finish = unfocused`                                                                                            | A command finishing in an unfocused surface is the case worth interrupting                                                                |
| Quick terminal     | Centred, on ⌘\` (macOS) or Ctrl+\` (Linux)                                                                                        | Ghostty binds no key to it by default, so without the binding it is unreachable                                                           |
| Option key (macOS) | `macos-option-as-alt = left`                                                                                                      | Neovim's `<M-j>` / `<M-k>` work; the right Option key still composes é and ß                                                              |
| Automation (macOS) | `macos-applescript = false`, `macos-shortcuts = deny`                                                                             | Between them they let any script run commands in a terminal; nothing here scripts Ghostty                                                 |

## Per-OS files

`config-file = ?os.ghostty` at the bottom of `config.ghostty` includes the file
`install.sh` links. Values in the included file win over the whole of
`config.ghostty`, whatever line the `config-file` directive sits on.

| File                | Contains                                                                                                                              |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `os-darwin.ghostty` | `macos-option-as-alt`, `font-thicken`, `background-blur` as native glass, `macos-titlebar-style`, the two automation keys, ⌘ keybinds |
| `os-linux.ghostty`  | `font-style`, `gtk-titlebar-style`, Ctrl+Shift keybinds, GTK and quick-terminal extension points                                      |

Each macOS-only setting has a Linux counterpart where Ghostty provides one:
`font-thicken` pairs with `font-style = Medium`, and `macos-titlebar-style`
with `gtk-titlebar-style`. The four that have no counterpart —
`macos-option-as-alt`, `macos-applescript`, `macos-shortcuts`, and
`macos-dock-drop-behavior` — are listed as such at the bottom of
[`os-linux.ghostty`](.config/ghostty/os-linux.ghostty), so the pair reads without
diffing the files.

Binding `super` on Linux registers but never fires, because desktops reserve
it; [`os-linux.ghostty`](.config/ghostty/os-linux.ghostty) has the reasoning.

## Gotchas

* **No trailing comments.** Everything after `=` is the value, and a key with
  a comment appended is rejected. Annotations go on their own line; see the
  header of [`config.ghostty`](.config/ghostty/config.ghostty).
* **A bare `command` name cannot be resolved on macOS.** Ghostty starts the
  command through `/usr/bin/login` and `bash --noprofile`, which never runs
  `path_helper`, so the lookup sees only the PATH Ghostty was launched with.
  This is why `command` is an absolute path, and why it lives in the two
  per-OS files rather than here: the Homebrew prefix differs by platform. The
  reasoning is in the Shell section of
  [`config.ghostty`](.config/ghostty/config.ghostty).
* **Never prefix `command` with `direct:`.** That form skips the `bash -c
  "exec -l …"` wrapper, and with it the leading hyphen on `argv[0]` that makes
  fish a login shell, so `path_helper` no longer runs and `$PATH` is ordered
  differently. An unprefixed value is the `shell:` form and keeps it.
* **A comment or blank line ending on a 2048-byte boundary truncates the
  file.** Ghostty 1.3.1 stops reading there and applies nothing below it; a
  setting on the boundary is unaffected. Nothing is reported and
  `+validate-config` still exits 0, so a setting simply keeps its default.
  Editing a comment is enough to move a file onto the boundary; see
  [Verifying a change](../README.md#verifying-a-change) for the check.
* **The pre-1.3.0 `config` is still read.** Ghostty 1.3.0 moved to
  `config.ghostty`; where `~/.config/ghostty/config` also exists both are
  loaded, the old name first, and Ghostty logs "both config files … exist".
  A scalar takes the newer file's value, but repeatable keys append twice.
* **macOS reads a second location.** Anything in
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` is
  loaded after the XDG file and wins over this repo. While that file exists,
  `ghostty +edit-config` opens it rather than the config here.
* **Unknown keys are ignored.** `ghostty +validate-config` checks syntax;
  `ghostty +show-config | grep macos-option-as-alt` confirms the per-OS include
  loaded.
* **A wrong `font-style` name is silent too.** Ghostty falls back to the
  regular face, `+validate-config` still exits 0, and `+show-face` reports the
  family rather than the face, so the only check is by eye.
* **`background-blur`** is supported on macOS and KDE Plasma; under GNOME's
  Mutter it has no effect, and KWin ignores the intensity because Plasma has
  one global blur setting.
* **`global:` keybinds need permission.** macOS asks for accessibility access
  the first time one loads; Linux needs the XDG GlobalShortcuts portal, which
  wlroots compositors such as Sway have not implemented. Without it the quick
  terminal binding works only while Ghostty has focus.
* **`scrollback-limit` is bytes, not lines.** The 10 MB default holds far more
  than the tens of thousands of lines the number suggests.

## Recipes

* **Ligatures off** for command output. Set the two `font-feature` lines to
  `-calt` and `-liga`.
* **A heavier font on Linux.** `font-style = SemiBold` with
  `font-style-bold = ExtraBold` beside it, so bold stays distinguishable.
  `ghostty +list-fonts --family="JetBrainsMono Nerd Font Mono"` lists the faces
  a family advertises.
* **Change the theme.** `ghostty +list-themes` lists the bundled themes. Keep
  the `light:…,dark:…` form to follow the appearance.
* **Inspect defaults.** `ghostty +show-config --default` prints every key and
  its default; `ghostty +list-keybinds --default` does the same for bindings.
  Add `--docs` to either for the documentation above each key.
