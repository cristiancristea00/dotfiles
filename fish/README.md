# fish

[fish](https://fishshell.com) is the interactive shell. Configuration is split
into auto-sourced snippets under `conf.d/` and autoloaded functions under
`functions/`, one file per concern.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" fish
```

`--no-folding` keeps `~/.config/fish/` a real directory, so fish can write
`fish_variables` and other tools can add `conf.d/` snippets without either
landing in the repo. See [The stow model](../README.md#the-stow-model).

## Layout and load order

`conf.d/*.fish` is sourced in ASCII order before `config.fish`, hence the
numeric prefixes. Functions are not sourced at startup: fish autoloads
`functions/<name>.fish` on first call, so the file name must match the
function name inside it.

| Path                         | Purpose                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| `conf.d/00-path.fish`        | Homebrew (`brew shellenv`, probing all three prefixes), Rust (`~/.cargo/env.fish`), user bin directories |
| `conf.d/10-environment.fish` | `EDITOR`/`VISUAL`, `MANPAGER` through bat, Homebrew hints off                                           |
| `conf.d/20-options.fish`     | Greeting, prompt path length, the shared `$COMMON_OPTIONS_*` flag sets, and why fzf is unthemed         |
| `conf.d/25-theme.fish`       | Catppuccin for fish, eza, and delta, following the terminal's appearance                                |
| `conf.d/30-prompt.fish`      | oh-my-posh, guarded on interactivity, Homebrew, and terminal type                                       |
| `config.fish`                | Empty; documents the load order                                                                         |
| `functions/`                 | `ll` `la` `lt` `lta` (eza) · `ff` `fx` `fd` (fd) · `coffee` · `signed`                                  |

## Machine-local additions

Machine- or employer-specific helpers go in an uncommitted
`~/.config/fish/conf.d/99-work.fish`, which fish sources like any other
snippet. [The stow model](../README.md#the-stow-model) describes local
overlays.

## Platform differences

| Piece                        | Behaviour                                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `conf.d/00-path.fish`        | Probes `/opt/homebrew`, `/usr/local`, and `/home/linuxbrew/.linuxbrew`, so one file covers Apple Silicon, Intel Mac, and Linux |
| `conf.d/10-environment.fish` | `$MANPAGER` is guarded on `col`, which Debian and Ubuntu ship in `bsdextrautils` and minimal images lack                   |
| `conf.d/30-prompt.fish`      | Guarded on `brew` as well as `oh-my-posh`, because the theme path is resolved through `brew --prefix`                      |
| `functions/signed.fish`      | Defined only on macOS; `codesign` has no Linux equivalent                                                                 |
| `functions/coffee.fish`      | Passes `--greedy` only on macOS; the flag concerns casks, which Linux Homebrew lacks                                       |

## Gotchas

* `functions/fd.fish` shadows the `fd` binary to apply default flags. A bare
  `fd` inside it would recurse, so it calls `command fd`; `ff` and `fx` do the
  same, because calling the function would apply the flags twice.
* The functions read `$COMMON_OPTIONS_EZA` and `$COMMON_OPTIONS_FD` from
  `conf.d/20-options.fish`. Renaming a variable without updating the functions
  breaks them.
* Every variable has global scope, never universal (`set -U`). Universal
  variables persist to `fish_variables` outside the repo;
  `conf.d/20-options.fish` has the details.
* rustup installs its own `conf.d/rustup.fish`, redundant with `00-path.fish`
  and safe to delete.

## Recipes

* **Add a function.** Create `functions/<name>.fish` containing
  `function <name> … end`, then run `stow -R --no-folding … fish` to link the
  new file.
* **Change the prompt.** Edit the theme filename in `conf.d/30-prompt.fish`;
  `ls (brew --prefix oh-my-posh)/themes/` lists the bundled ones. Delete the
  block for fish's own prompt.
* **Enable fzf key bindings.** Uncomment `fzf --fish | source` in
  `conf.d/20-options.fish`. It replaces fish's own `Ctrl-R` history search.
* **Change the colour flavour.** Edit `fish_config theme choose
  catppuccin-mocha` in `conf.d/25-theme.fish`. Each Catppuccin theme carries a
  light and a dark variant, so naming a dark flavour also selects Latte. The
  same file holds the eza and delta handlers and explains why `theme save` is
  never used. [Light and dark](../README.md#light-and-dark) in the root README
  covers how the rest of the stack follows the appearance, and
  [git/README](../git/README.md) what delta does outside fish.
