# Ghostty

[Ghostty](https://ghostty.org) is the terminal emulator this setup runs in. It
launches fish, renders Neovim, and its theme follows the macOS appearance.

## Install

```sh
stow --target="$HOME" --dir="$HOME/work/dotfiles" ghostty
```

Installs `.config/ghostty/config` → `~/.config/ghostty/config`.
Reload a running Ghostty with `⌘⇧,`.

## What's configured

| Area       | Choice                                                                                                | Why                                                                                                                              |
| ---------- | ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Font       | `JetBrainsMono Nerd Font Mono` → `JetBrains Mono` → Fira Code → Source Code Pro → IBM Plex Mono, 14pt | The Mono build keeps Neovim's icons to one cell; the plain build leads the fallbacks so missing glyphs stay in the same typeface |
| Ligatures  | **off** (`-calt -liga`)                                                                               | This is a terminal: logs and diffs should show exact characters                                                                  |
| Theme      | `light:TokyoNight Day,dark:TokyoNight Night`                                                          | Follows macOS, matching Zed, bat and Neovide                                                                                     |
| Option key | `macos-option-as-alt = left`                                                                          | Makes Neovim's `<M-j>` / `<M-k>` work; right Option still composes é/ß                                                           |
| Window     | 100×30 cells, 8/6pt padding, 0.95 opacity + blur                                                      | Breathing room; the translucency is a deliberate difference from Neovide, which stays opaque                                     |
| Shell      | `/opt/homebrew/bin/fish --login --interactive`                                                        | Setting `command` defeats automatic shell integration, so `shell-integration = fish` is stated explicitly right after            |

Split, tab and navigation keybinds mirror Ghostty's macOS defaults and are
listed explicitly in the config so it documents its own interface.

## Gotchas

* **There are no trailing comments.** Everything after `=` is the value, so
  `font-thicken = true  # default: false` sets the value to the literal string
  `true  # default: false` and the key is rejected. Annotations go on their own
  lines.
* **Unknown keys are ignored silently.** Always run `ghostty +validate-config`
  after editing.
* The Homebrew path in `command` is hardcoded (`/opt/homebrew/bin/fish`)
  because the config format has no conditionals — on an Intel Mac this becomes
  `/usr/local/bin/fish`.

## Recipes

### Turn ligatures back on
Delete the two `font-feature` lines.

### Change the theme
`ghostty +list-themes` lists 400+. Keep the `light:…,dark:…` form to stay in
step with the rest of the stack.

### Inspect defaults
`ghostty +show-config --default` prints every key and its default;
`ghostty +list-keybinds --default` does the same for bindings.
