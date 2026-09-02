# bat

[bat](https://github.com/sharkdp/bat) is `cat` with syntax highlighting, Git
integration and paging. This package configures it to follow the macOS light/
dark appearance like the rest of the stack.

## Install

```sh
stow --target="$HOME" --dir="$HOME/work/dotfiles" bat
```

Installs `.config/bat/config` → `~/.config/bat/config`.

## What's configured

| Setting                          | Value                    | Why                                                                                           |
| -------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------- |
| `--theme`                        | `auto:system`            | Reads the macOS appearance and picks the light or dark theme below                            |
| `--theme-dark` / `--theme-light` | Catppuccin Mocha / Latte | A matched pair designed for switching                                                         |
| `--style`                        | `numbers,changes,header` | Line numbers, Git gutter marks, filename — without the full box grid                          |
| `--italic-text`                  | `always`                 | Ghostty renders real italics; comments read better                                            |
| `--tabs`                         | `4`                      | Matches Neovim's `shiftwidth` and Zed's `tab_size`                                            |
| `--map-syntax`                   | 3 rules                  | Forces INI highlighting for the extension-less `ghostty/config` and `git/config` in this repo |

## Where else bat is used

`fish/.config/fish/conf.d/10-environment.fish` routes `$MANPAGER` through bat,
so these settings shape `man` output too.

## Gotchas

* **Each line is a command-line argument**, not a `key = value` pair.
* **Values containing spaces must be quoted.** `--theme-dark=Catppuccin Mocha`
  is split into two arguments and bat then tries to open a file called
  `Mocha`. Write `--theme-dark="Catppuccin Mocha"`.

## Recipes

### Match the terminal palette exactly
Replace the three theme lines with `--theme="ansi"`. bat then uses only the
terminal's 16 colours, so it matches Ghostty's theme perfectly and flips with
it — at the cost of flatter highlighting.

### Browse themes
`bat --list-themes` previews every bundled theme against a sample file.
