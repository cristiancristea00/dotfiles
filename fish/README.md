# fish

[fish](https://fishshell.com) is the interactive shell. This package is split
into small auto-sourced snippets and autoloaded functions, so adding or
removing a piece of behaviour is a single-file operation.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" fish
```

**`--no-folding` is required.** It links each file individually and leaves
`~/.config/fish/` a real directory, which is what lets fish keep writing
`fish_variables` and lets tools drop their own snippets into `conf.d/` without
any of it landing in this repo.

## Layout and load order

`conf.d/*.fish` is sourced in ASCII order **before** `config.fish` — hence the
numeric prefixes. Functions are not sourced at startup at all: fish autoloads
`functions/<name>.fish` the first time `<name>` is called, so **the file name
must match the function name inside it**.

| Path                         | Purpose                                                                          |
| ---------------------------- | -------------------------------------------------------------------------------- |
| `conf.d/00-path.fish`        | Homebrew (`brew shellenv`, probing both prefixes) and Rust (`~/.cargo/env.fish`) |
| `conf.d/10-environment.fish` | `EDITOR`/`VISUAL`, `MANPAGER` through bat, Homebrew hints off                    |
| `conf.d/20-options.fish`     | Greeting, prompt path length, and the shared `$COMMON_OPTIONS_*` flag sets       |
| `conf.d/25-theme.fish`       | Catppuccin for fish's own colours and for eza, following the terminal           |
| `conf.d/30-prompt.fish`      | oh-my-posh, guarded for interactivity and terminal type                          |
| `config.fish`                | Almost empty by design — documents the load order                                |
| `functions/`                 | `ll` `la` `lt` `lta` (eza) · `ff` `fx` `fd` (fd) · `coffee` · `signed`           |

## Machine-local additions

Anything specific to one machine or employer goes in an **uncommitted**
`~/.config/fish/conf.d/99-work.fish`. fish sources it like any other snippet,
and because this package is stowed with `--no-folding` that file sits happily
beside the symlinks. This is the sanctioned way to keep work-only helpers
(daemon load/unload wrappers, internal tooling) out of a shareable repo.

## Fixed here

* **`ff` applied its flags twice.** It called the `fd` *function*, which
  already prepends `$COMMON_OPTIONS_FD`. It now uses `command fd`, matching how
  `fx` was already written.
* **`fish_prompt_pwd_dir_length` was a universal variable** (`set -U`), so
  every shell start rewrote `fish_variables`. It is `set -g` now — the correct
  scope for a config-driven value.
* **PATH was hardcoded to `/opt/homebrew`.** It now probes all three Homebrew
  prefixes — `/opt/homebrew` (Apple Silicon), `/usr/local` (Intel) and
  `/home/linuxbrew/.linuxbrew` (Linux) — and uses `brew shellenv`, which also
  sets `MANPATH` and `INFOPATH`. This is the most load-bearing line in the
  shell config: if no prefix matches, every brew-installed tool falls off PATH.

## Platform differences

| Piece | Behaviour |
|---|---|
| `conf.d/00-path.fish` | Probes all three Homebrew prefixes, so one file covers Intel Mac, Apple Silicon and Linux |
| `conf.d/10-environment.fish` | `$MANPAGER` is guarded on `col`, which Debian/Ubuntu moved into `bsdextrautils` and minimal images often lack |
| `conf.d/30-prompt.fish` | Guarded on `brew` as well as `oh-my-posh` — the theme path is resolved via `brew --prefix`, so a non-Homebrew oh-my-posh would otherwise print an error on every shell start |
| `functions/signed.fish` | Defined **only on macOS**; `codesign` has no Linux equivalent, so on Linux the name simply does not exist |
| `functions/coffee.fish` | Drops `--greedy` off macOS — the flag only means anything for casks, which Linux Homebrew does not have |

## Gotchas

* `functions/fd.fish` shadows the `fd` binary to apply default flags. Anything
  that must bypass it uses `command fd` — including `ff` and `fx`. A bare `fd`
  inside that function would recurse forever.
* The functions read `$COMMON_OPTIONS_EZA` / `$COMMON_OPTIONS_FD`, which are
  set in `conf.d/20-options.fish`. Rename one and the functions break — the
  coupling is noted in both files.
* rustup installs its own `conf.d/rustup.fish`. It is redundant with
  `00-path.fish` (harmless — the sourced file guards against double-prepending)
  and can be deleted.

## Recipes

### Add a function
Create `functions/<name>.fish` containing `function <name> … end`. It is
autoloaded on first use; no restow needed only if the package was stowed with
folding — with `--no-folding`, run `stow -R --no-folding … fish` to link it.

### Change the prompt
Edit the theme filename in `conf.d/30-prompt.fish`. List the bundled ones with
`ls (brew --prefix oh-my-posh)/themes/`. Delete the block to fall back to
fish's own fast prompt.

### Enable fzf key bindings
Uncomment `fzf --fish | source` in `conf.d/20-options.fish`. Note it overrides
fish's own `Ctrl-R` history search.

### Change the colour flavour
Edit the one line in `conf.d/25-theme.fish`:

```fish
fish_config theme choose catppuccin-mocha
```

Naming a dark flavour also selects Latte automatically — each Catppuccin theme
carries a light and a dark variant, and fish applies the one matching
`$fish_terminal_color_theme`, re-applying it live whenever the terminal's
background changes. Append `--color-theme=dark` to pin one appearance. Preview
with `fish_config theme demo`, and list what is available with
`fish_config theme list` — since fish 4.4 the Catppuccin flavours ship with
fish, so nothing needs installing.

**Never use `fish_config theme save`.** It writes the colours into fish's
universal variables, which is machine state this repo keeps out of version
control and which a line removed here would not undo. `choose` loads into the
session, which is why it belongs in `conf.d`.

`eza` and `delta` ride on the same signal, each with its own `--on-variable`
handler in that file. The eza one points `$EZA_CONFIG_DIR` at
`~/.config/eza-latte` or `~/.config/eza-mocha`; the delta one sets
`$DELTA_FEATURES` to `catppuccin-latte` or `catppuccin-mocha`. Both depend on
files `install.sh` fetches rather than commits, and both fail soft if those are
missing. The handlers must live in `conf.d`; an autoloaded function in
`functions/` would never register the event.

The two differ in one place, deliberately. When the terminal will not report
its background, the eza handler falls back to Mocha, while the delta handler
**erases** `$DELTA_FEATURES` — because delta can query the terminal itself and
eza cannot, so handing the question over beats guessing. See
[`../git/README.md`](../git/README.md) for what delta then does.

`fzf` is deliberately left unthemed — see the reasoning in
`conf.d/20-options.fish`.
