# tlrc

[tlrc](https://github.com/tldr-pages/tlrc) is the official Rust client for
[tldr pages](https://tldr.sh), community-written, example-first summaries of
commands. It installs the binary as `tldr`.

## Install

`./install.sh` handles this. By hand:

```sh
stow --target="$HOME" --dir="$HOME/personal/dotfiles" tlrc
# macOS only: bridge the path tlrc reads there
mkdir -p "$HOME/Library/Application Support/tlrc"
ln -sfn "$HOME/.config/tlrc/config.toml" \
        "$HOME/Library/Application Support/tlrc/config.toml"
```

Then populate the cache once: `tldr --update`.

## One file, two paths

tlrc reads `~/.config/tlrc/config.toml` on Linux (honouring
`$XDG_CONFIG_HOME`) but `~/Library/Application Support/tlrc/config.toml` on
macOS. The package ships the XDG path and `install.sh` symlinks the macOS
location at it; `tldr --config-path` prints the path in use. See
[Per-OS configuration](../README.md#per-os-configuration) in the root README.
The header of [`config.toml`](.config/tlrc/config.toml) has the alternative
that was rejected and the reason the cache directory is left unset.

## What's configured

| Setting                                       | Value         | Why                                                                                                    |
| --------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------ |
| `defer_auto_update`                           | `true`        | The two-weekly cache refresh runs after printing the page, so a routine lookup never waits on the network |
| `languages`                                   | `["en"]`      | Left empty, tlrc would also download the languages `$LANG` implies; translated pages are less complete  |
| `option_style`                                | `long`        | `--recursive` explains itself, `-r` does not                                                           |
| `platform_title`, `show_hyphens`, `edit_link` | `false`       | The defaults; the platform is the machine's own, and the descriptions already read as a list           |
| `[style.*]`                                   | palette names | Named colours resolve through the terminal palette, so styling follows Ghostty's light/dark switch     |

Everything else in the file equals tlrc's default. The cache directory and
the style booleans left at `false` are not written, so `--gen-config` shows
them as differences.

## Recipes

* **See every available option.** `tldr --gen-config` prints the complete
  default configuration. After upgrading tlrc, diff against it to find new
  keys: `tldr --gen-config | diff - "$(tldr --config-path)"`.
* **Read a page.** `tldr tar`. `tldr --list` shows everything cached;
  `tldr --update` refreshes now.
