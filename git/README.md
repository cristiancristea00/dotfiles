# Git

Global Git configuration at Git's XDG location, `~/.config/git/config`, with
the identity switching between personal and work by directory.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" git
```

`~/.gitconfig` must be removed or renamed first: Git reads it after this
file, so its values win. `--no-folding` keeps `~/.config/git/` a real
directory, so the fetched `catppuccin.gitconfig` can sit beside the symlinks.
Tools that run `git config --global` write through the `config` symlink into
the committed file; the LFS block in it arrived that way. See
[The stow model](../README.md#the-stow-model).

## Files

| File                                  | Purpose                                                                                                                                                   |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.config/git/config`                  | Identity, delta, diff and merge, aliases, signing                                                                                                         |
| `.config/git/config.work`             | Work identity, applied under `~/work/` through `includeIf`                                                                                                |
| `.config/git/ignore`                  | Global ignore patterns                                                                                                                                    |
| `.config/git/colours-mocha.gitconfig` | Log formats, ref-name colours, and graph colours in Catppuccin Mocha; included by `config`                                                                |
| `.config/git/colours-latte.gitconfig` | The same in Catppuccin Latte; added by `25-theme.fish` in a light terminal                                                                                |
| `.config/git/catppuccin.gitconfig`    | Not in this repo. Fetched by `install.sh` from [catppuccin/delta](https://github.com/catppuccin/delta); see [Fetched themes](../README.md#fetched-themes) |

## delta's theme

`[delta]` sets neither `features` nor `syntax-theme`. The flavour comes from
`$DELTA_FEATURES`, which
[`25-theme.fish`](../fish/.config/fish/conf.d/25-theme.fish) sets from the
terminal's background; where nothing sets the variable, delta detects the
background itself. The
`[delta]` block in [`config`](.config/git/config) documents the mechanism, the
fallback, and why `syntax-theme` must stay unset.

## Log colours

The `list` and `logs` formats, the ref-name colours, and the graph-lane
colours are in [`colours-mocha.gitconfig`](.config/git/colours-mocha.gitconfig)
and [`colours-latte.gitconfig`](.config/git/colours-latte.gitconfig), one per
Catppuccin flavour. The main `config` includes the Mocha file. In a light
terminal, [`25-theme.fish`](../fish/.config/fish/conf.d/25-theme.fish) adds
the Latte file through Git's environment config, whose values Git reads last.
The two files differ only in their hex values; their headers record the
contrast rule and the quoting trap. Check which file is in effect:

```sh
git config --show-origin --get pretty.list
```

## Identity switching

The personal identity is the default. An `includeIf` for `gitdir:~/work/`
near the end of `config` loads `config.work`, so repositories under `~/work/`
get the work email and signing key. Verify:

```sh
cd ~/work/anything && git config --get user.email   # work
cd ~             && git config --get user.email     # personal
```

This repository lives outside `~/work/`, so the personal identity applies to
it by default. `config.work` is committed; its header says how to make it
local-only.

## Signing

Every commit and tag is signed, and `gpg.minTrustLevel = fully` makes
verification reject keys that are not fully trusted. A fresh machine needs the
key imported before the first commit; bypass once with:

```sh
git -c commit.gpgSign=false commit
```

## Commit convention

This repository's history follows Conventional Commits, scoped to the package.
The types, the trailer block, and the sign-off rule are in
[AGENTS.md](../AGENTS.md#commit-convention).

## Destructive aliases

| Alias        | Does                                                                                                                               |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `fpush`      | `push --force`: overwrites the remote unconditionally. Prefer `spush` (`--force-with-lease`), which refuses if someone else pushed |
| `fpushall`   | The same for every branch at once                                                                                                  |
| `purge`      | `clean --quiet --force -d`: deletes all untracked files and directories. Preview with `git clean -nd`                              |
| `obliterate` | `reset --hard`: discards every uncommitted change                                                                                  |
