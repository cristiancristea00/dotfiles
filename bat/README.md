# bat

[bat](https://github.com/sharkdp/bat) is `cat` with syntax highlighting, Git
integration, and paging. It follows the system light/dark appearance with the
rest of the stack and serves as `$MANPAGER`.

## Install

`./install.sh` handles this. By hand:

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" bat
ln -sfn config.darwin ~/.config/bat/config     # or config.linux
```

`--no-folding` keeps `~/.config/bat/` a real directory, so the selector
symlink lives outside the repo. See [The stow model](../README.md#the-stow-model)
and [Per-OS configuration](../README.md#per-os-configuration) in the root
README.

## What's configured

| Setting                          | Value                                  | Why                                                                                            |
| -------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `--theme`                        | `auto:system` (macOS) / `auto` (Linux) | Picks the light or dark theme below from the OS appearance or the terminal background          |
| `--theme-dark` / `--theme-light` | Catppuccin Mocha / Latte               | The two flavours used across the stack                                                         |
| `--style`                        | `numbers,changes,header,grid`          | Line numbers, Git gutter marks, filename header, and the grid that separates them              |
| `--italic-text`                  | `always`                               | Ghostty renders real italics; bat's default is `never`                                         |
| `--tabs`                         | `4`                                    | Matches Neovim's `shiftwidth` and Zed's `tab_size`                                             |
| `--map-syntax`                   | 3 rules                                | INI for the three `.ghostty` files; bat's Git Config syntax for `git/config` and `config.work` |

## Two files

`config.darwin` and `config.linux` differ only in the theme line.
`--theme=auto:system` reads the macOS appearance and is macOS-only;
`--theme=auto` reads the terminal's background. `install.sh` links
`~/.config/bat/config` at the right one. Add a new option to both files.

## Where else bat is used

[`10-environment.fish`](../fish/.config/fish/conf.d/10-environment.fish)
routes `$MANPAGER` through bat, so the theme and text settings apply to `man`
output too. That command passes `--plain --language man`, which overrides
`--style` and the syntax mappings.

## Format

Each line is one command-line argument, not a `key = value` pair. A value
with spaces must be quoted; the header of
[`config.darwin`](.config/bat/config.darwin) has the example.

## Recipes

* **Match the terminal palette exactly.** Replace the three theme lines with
  `--theme="ansi"`. bat then uses the terminal's 16 colours and follows its
  light/dark: an exact Ghostty match with flatter highlighting.
* **Browse themes.** `bat --list-themes` previews every bundled theme.
