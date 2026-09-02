# bat

[bat](https://github.com/sharkdp/bat) is `cat` with syntax highlighting, Git
integration and paging. This package configures it to follow the system light/
dark appearance like the rest of the stack.

## Install

`./install.sh` handles this. By hand:

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" bat
ln -sfn config.darwin ~/.config/bat/config     # or config.linux
```

**`--no-folding` is required**, because `~/.config/bat/` has to stay a real
directory to hold that selector symlink — a folded directory is a symlink into
the repo, so the selector would land in version control.

## What's configured

| Setting                          | Value                    | Why                                                                                           |
| -------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------- |
| `--theme`                        | `auto:system`            | Reads the macOS appearance and picks the light or dark theme below                            |
| `--theme-dark` / `--theme-light` | Catppuccin Mocha / Latte | A matched pair designed for switching                                                         |
| `--style`                        | `numbers,changes,header` | Line numbers, Git gutter marks, filename — without the full box grid                          |
| `--italic-text`                  | `always`                 | Ghostty renders real italics; comments read better                                            |
| `--tabs`                         | `4`                      | Matches Neovim's `shiftwidth` and Zed's `tab_size`                                            |
| `--map-syntax`                   | 3 rules                  | Forces INI highlighting for the extension-less `ghostty/config` and `git/config` in this repo |

## Two files, one difference

bat's config format has no conditionals, and `--theme=auto:system` — which
reads the OS-wide light/dark preference — is documented as **macOS-only**. So
the package ships two variants and `install.sh` links `~/.config/bat/config` at
the right one:

| File            | Theme setting         | Detects light/dark from          |
| --------------- | --------------------- | -------------------------------- |
| `config.darwin` | `--theme=auto:system` | the macOS appearance setting     |
| `config.linux`  | `--theme=auto`        | the terminal's background colour |

Both work; the Linux one is one step removed, inferring from the terminal
rather than being told by the desktop. **Everything except the theme block is
identical — keep it that way.** Adding an option means adding it to both.

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
