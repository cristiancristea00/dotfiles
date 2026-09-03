# Git

Global Git configuration, at Git's XDG location rather than `~/.gitconfig`,
with the identity switching automatically between personal and work by
directory.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" git
```

**`~/.gitconfig` must be removed (or renamed) first.** Git reads both files and
`~/.gitconfig` is read *later*, so anything in it overrides this config
entirely.

**`--no-folding` is required** so `~/.config/git/` stays a real directory —
tools that run `git config --global` then write there rather than into this
repo.

## Files

| File                      | Purpose                                                                       |
| ------------------------- | ----------------------------------------------------------------------------- |
| `.config/git/config`      | Everything: identity, delta, diff/merge, aliases, signing                     |
| `.config/git/config.work` | Work identity, applied under `~/work/` via `includeIf`                        |
| `.config/git/ignore`      | Global ignore patterns — Git's native XDG path, no `core.excludesFile` needed |
| `.config/git/catppuccin.gitconfig` | **Not in this repo.** Fetched by `install.sh` from [catppuccin/delta](https://github.com/catppuccin/delta); themes delta's chrome |

### The delta theme is in two halves

`syntax-theme` colours the **code** inside a diff. The `features` line colours
delta's own **chrome** — line-number columns, hunk and file headers, and the
backgrounds behind added and removed lines — and those definitions come from
the fetched `catppuccin.gitconfig`.

Both name Mocha, so `syntax-theme` looks redundant next to the feature. It is
not, for two reasons: options written directly in `[delta]` outrank ones
inherited from a feature, so it is the value that actually wins; and it is the
only half that survives when the fetch has not run, which keeps code correctly
coloured on a machine where just the chrome is plain. **Change both together.**

Both halves fail soft — Git ignores an `include.path` that does not exist, and
delta ignores a `features` name it cannot resolve, neither with any warning.
Re-run `./install.sh` to fetch the file.

## Identity switching

The personal identity is the default. `config` ends with:

```ini
[includeIf "gitdir:~/work/"]
    path = ~/.config/git/config.work
```

Includes are evaluated in order and the last value wins, so any repository
under `~/work/` picks up the work name, email and signing key. Verify:

```sh
cd ~/work/anything && git config --get user.email   # work
cd ~             && git config --get user.email     # personal
```

The trailing slash on `gitdir:~/work/` is what makes it match the directory's
contents. If `config.work` is ever missing, Git silently skips the include and
the personal identity applies everywhere.

> **`config.work` is committed.** The work email and public key fingerprint are
> therefore in the repository. A fingerprint is public by design; an email
> address is harvestable if this repo is published. The file documents how to
> make it local-only again.

## Commit convention

This repository's own history follows
[Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <description>

<body — what changed, why that choice, any trap involved>

Co-Authored-By: Claude <noreply@anthropic.com>
Signed-off-by: Cristian Cristea <cristiancristea00@gmail.com>
```

`feat` for a package gaining a capability, `fix` for corrected behaviour,
`docs` for documentation alone, `refactor` for behaviour-neutral restructuring,
`chore` for repo-wide maintenance. **The scope is the package directory**
(`bat`, `fish`, `nvim`, …) and is omitted for repo-wide changes.

Two details that are easy to get wrong: the footers must form **one contiguous
block** with no blank line between them, or Git parses only the last paragraph
as trailers; and `git commit -s` should generate the sign-off, so it always
matches the configured identity instead of being typed by hand.

> **This repository commits under the personal identity**, which since it moved
> to `~/personal/dotfiles` requires nothing at all: the `includeIf` matches only
> `~/work/`, so the personal `[user]` block applies by default.
>
> While it lived under `~/work/` it needed a repo-local override to escape that
> rule. The override is still present in `.git/config` and is now redundant —
> harmless, since it sets exactly the identity that would apply anyway. It can
> be cleared with:
>
> ```sh
> git config --local --unset user.email
> git config --local --unset user.signingKey
> ```
>
> Worth remembering if you ever move a personal project **into** `~/work/`:
> repo-local settings beat conditional includes, and because `.git/config` is
> not version-controlled, a fresh clone will not carry the override with it.

## The one gotcha

`commit.gpgSign` + `tag.gpgSign` + `gpg.minTrustLevel = fully` means **every**
commit and tag is signed, and Git **hard-fails** if the matching secret key is
missing or not ultimately trusted. On a fresh machine, import your key before
the first commit, or bypass once with:

```sh
git -c commit.gpgSign=false commit
```

## Destructive aliases

These discard work irreversibly and are commented as such in the config:

| Alias        | Does                                                                                                                                    |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| `fpush`      | `push --force` — overwrites the remote unconditionally. **Prefer `spush`** (`--force-with-lease`), which refuses if someone else pushed |
| `fpushall`   | The same for every branch at once                                                                                                       |
| `purge`      | `clean -fd` — deletes all untracked files. Preview with `git clean -nd`                                                                 |
| `obliterate` | `reset --hard` — throws away every uncommitted change                                                                                   |

## Improvements made here

`rerere` (records and replays conflict resolutions), `column.ui`,
`branch.sort = -committerdate`, `tag.sort = version:refname`, fsck-on-transfer
integrity checks, and the `spush` safe-force alias. The redundant
`blank-at-eol` / `trailing-space` overlap in `core.whitespace` was removed, and
the file's mixed tab/space indentation normalised.
