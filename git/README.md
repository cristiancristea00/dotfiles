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

| File                               | Purpose                                                                                                                                                     |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.config/git/config`               | Identity, delta, diff and merge, aliases, signing                                                                                                           |
| `.config/git/config.work`          | Work identity, applied under `~/work/` through `includeIf`                                                                                                  |
| `.config/git/ignore`               | Global ignore patterns                                                                                                                                      |
| `.config/git/catppuccin.gitconfig` | Not in this repo. Fetched by `install.sh` from [catppuccin/delta](https://github.com/catppuccin/delta); see [Fetched themes](../README.md#fetched-themes) |

## delta's theme

`[delta]` sets neither `features` nor `syntax-theme`. The flavour comes from
`$DELTA_FEATURES`, which
[`25-theme.fish`](../fish/.config/fish/conf.d/25-theme.fish) sets from the
terminal's background; where nothing sets the variable, delta detects the
background itself. The
`[delta]` block in [`config`](.config/git/config) documents the mechanism, the
fallback, and why `syntax-theme` must stay unset.

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

| Alias        | Does                                                                                                                                 |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| `fpush`      | `push --force`: overwrites the remote unconditionally. Prefer `spush` (`--force-with-lease`), which refuses if someone else pushed |
| `fpushall`   | The same for every branch at once                                                                                                    |
| `purge`      | `clean --quiet --force -d`: deletes all untracked files and directories. Preview with `git clean -nd`                                |
| `obliterate` | `reset --hard`: discards every uncommitted change                                                                                    |
