# Ruff

[Ruff](https://docs.astral.sh/ruff/) is the Python linter and formatter every
editor here uses. This package supplies its user-level configuration.

## Install

```sh
stow --target="$HOME" --dir="$HOME/personal/dotfiles" ruff
```

The package is folded: nothing machine-local lives in `~/.config/ruff/`.
Ruff's cache goes to `.ruff_cache` inside each project.

## What user-level means

Ruff does not merge configuration files. It uses the first configuration found
walking up from the file being checked and ignores every parent; this file
applies only when that search finds nothing. No Ruff setting can impose
anything on a project that has its own configuration.

| Situation                                                    | What applies                     |
| ------------------------------------------------------------ | -------------------------------- |
| Project has a `pyproject.toml`, `ruff.toml`, or `.ruff.toml` | That file; this one is ignored   |
| A loose script, or a project with no Ruff configuration      | This file                        |
| `ruff check --isolated`                                      | Neither: Ruff's built-in defaults |

The header of [`ruff.toml`](.config/ruff/ruff.toml) explains why the file is
named `ruff.toml` and why the path is the same on macOS and Linux.

## What's configured

| Setting        | Value       | Why                                                                   |
| -------------- | ----------- | --------------------------------------------------------------------- |
| `line-length`  | 120         | One of the four column guides every editor here draws; the default is 88 |
| `indent-width` | 4           | The repo-wide 4-space rule                                            |
| `quote-style`  | `single`    | The default is double                                                 |
| `line-ending`  | `lf`        | Never CRLF, whatever the platform                                     |
| `fix`          | `true`      | `ruff check` rewrites files; see below                                |
| `preview`      | `true`      | Unstable rules on; see below                                          |
| `select`       | 31 families | A broad selection; projects silence what does not fit                 |

Three settings need a note:

* **`fix = true` makes `ruff check` rewrite files.** Every editor here formats
  only on `<leader>F`, so this is the only tool here that edits when run. Only
  fixes Ruff marks safe are applied; `--unsafe-fixes` is not enabled.
* **`preview = true` enables unstable rules.** About a fifth of the selected
  rules are preview-only (`DOC` entirely, large parts of `E`, `RUF`, `FURB`,
  and `PLR`), so without it they would do nothing. A `brew upgrade ruff` can
  then change what lints with no change here.
* **`CPY` requires a copyright notice in every file.**

## Who reads it

The `ruff` CLI, the Ruff language server Neovim attaches through
[`after/lsp/ruff.lua`](../nvim/.config/nvim/after/lsp/ruff.lua), and
`charliermarsh.ruff` in Visual Studio Code and Cursor. All run the same binary.

## Verifying it is read

Ruff falls back to its defaults without a message when the file is not found.
Compare:

```sh
cd /tmp                                  # somewhere with no project config
ruff check --show-settings . | grep -E '^(linter\.line_length|formatter\.quote_style)'
ruff check --isolated --show-settings . | grep '^linter\.line_length'   # 88, the default
```

If the first shows `linter.line_length = 120` and the second `88`, the file
is being read.
