# tlrc

[tlrc](https://github.com/tldr-pages/tlrc) is the official Rust client for
[tldr pages](https://tldr.sh) — community-written, example-first summaries of
commands. It installs the binary as **`tldr`**.

## Install

`./install.sh` handles this. By hand:

```sh
stow --target="$HOME" --dir="$HOME/work/dotfiles" tlrc
# macOS only — bridge the path tlrc actually reads there:
mkdir -p "$HOME/Library/Application Support/tlrc"
ln -sfn "$HOME/.config/tlrc/config.toml" \
        "$HOME/Library/Application Support/tlrc/config.toml"
```

Then populate the cache once: `tldr --update`.

## One file, two paths

tlrc resolves its config through the Rust `dirs` crate, so the location differs:

| Platform | Path                                                      |
| -------- | --------------------------------------------------------- |
| Linux    | `~/.config/tlrc/config.toml` (honours `$XDG_CONFIG_HOME`) |
| macOS    | `~/Library/Application Support/tlrc/config.toml`          |

The package ships **only the portable XDG path**, and on macOS `install.sh`
symlinks the Application Support location at it. One file to edit, and it works
from any shell — unlike the `TLRC_CONFIG` environment variable, which would
only apply to shells that export it.

Confirm the location on any machine with `tldr --config-path`.

The cache directory is deliberately **not** set, so tlrc picks its own
per-platform default (`~/Library/Caches/tlrc` on macOS, `~/.cache/tlrc` on
Linux). Hardcoding the macOS path would create a stray `~/Library` on Linux.

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
