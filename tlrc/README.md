# tlrc

[tlrc](https://github.com/tldr-pages/tlrc) is the official Rust client for
[tldr pages](https://tldr.sh) — community-written, example-first summaries of
commands. It installs the binary as **`tldr`**.

## Install

```sh
stow --target="$HOME" --dir="$HOME/work/dotfiles" tlrc
```

Installs `Library/Application Support/tlrc/config.toml` →
`~/Library/Application Support/tlrc/config.toml`.

Then populate the cache once: `tldr --update`.

## Why the path looks different

Every other package here lives under `.config/`. **tlrc does not honour
`$XDG_CONFIG_HOME` on macOS** — it reads
`~/Library/Application Support/tlrc/config.toml`, so this package mirrors that
path instead. Confirm on any machine with `tldr --config-path`.

## What's configured

| Setting                                       | Value             | Why                                                                                                              |
| --------------------------------------------- | ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| `compact`                                     | `true`            | Strips blank lines between examples so a page fits on screen                                                     |
| `option_style`                                | `long`            | `--recursive` explains itself, `-r` does not                                                                     |
| `auto_update` + `defer_auto_update`           | both `true`       | Refreshes the cache every two weeks, *after* printing — so a lookup is never blocked on the network              |
| `languages`                                   | `["en"]`          | Translated pages are far less complete; left empty, tlrc would also pull whatever `$LANG` implies                |
| `platform_title`, `show_hyphens`, `edit_link` | `false`           | Noise on a Mac, where the answer is nearly always "osx" or "common"                                              |
| `[style.*]`                                   | palette **names** | Named colours resolve through the terminal palette, so styling follows Ghostty's light/dark switch automatically |

## Recipes

### See every available option
`tldr --gen-config` prints the complete default configuration. After upgrading
tlrc, diff against it to spot new keys:

```sh
tldr --gen-config | diff - "$(tldr --config-path)"
```

### Read a page for a command
`tldr tar` · `tldr --list` shows everything cached · `tldr --update` refreshes now.
