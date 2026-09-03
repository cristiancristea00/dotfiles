# Ruff

[Ruff](https://docs.astral.sh/ruff/) is the Python linter and formatter used by
every editor here. This package supplies its **user-level** configuration.

## Install

```sh
stow --target="$HOME" --dir="$HOME/personal/dotfiles" ruff
```

Folded — the whole directory becomes one symlink, because nothing
machine-local lives in `~/.config/ruff/`. Ruff's cache goes to `.ruff_cache`
inside each project, not here.

## What "user-level" means, and does not

Ruff **does not merge configuration files.** It walks up from the file being
checked, uses the first configuration it finds, and ignores every parent. Only
when that search finds nothing does it fall back to this one.

| Situation                                                   | What applies                                    |
| ----------------------------------------------------------- | ----------------------------------------------- |
| Project has a `pyproject.toml`, `ruff.toml` or `.ruff.toml` | That file, **and this one is ignored entirely** |
| A loose script, or a project with no Ruff configuration     | This file                                       |
| `ruff check --isolated`                                     | Neither — Ruff's built-in defaults              |

So this cannot impose a house style on a project that has its own opinions, and
no Ruff setting would let it. It decides what happens to Python that nobody has
configured.

## Why this path and this filename

Both come from `find_user_settings_toml` in Ruff's source
([`crates/ruff_workspace/src/pyproject.rs`](https://github.com/astral-sh/ruff/blob/main/crates/ruff_workspace/src/pyproject.rs)):

```rust
let strategy = etcetera::base_strategy::choose_base_strategy()?;
let config_dir = strategy.config_dir().join("ruff");
for filename in [".ruff.toml", "ruff.toml", "pyproject.toml"] { … }
```

Two things follow that the published documentation does not tell you:

* **`ruff.toml` is accepted.** The docs name only
  `${config_dir}/ruff/pyproject.toml`, which would have meant renaming this
  file and nesting every setting under `[tool.ruff]`. The source searches three
  names, most specific first, so a `.ruff.toml` dropped in beside this one
  would win.
* **The path is `~/.config/ruff/` on macOS as well as Linux.** It is the *base*
  strategy, which is XDG everywhere. The *native* strategy — which would put
  this under `~/Library/Application Support` on macOS — is not used anywhere in
  Ruff. This package therefore needs none of the per-OS machinery that
  [`tlrc/`](../tlrc/README.md) does, which is the one place in this repo where
  that distinction genuinely bites.

## What's configured

| Setting        | Value       | Why                                                                             |
| -------------- | ----------- | ------------------------------------------------------------------------------- |
| `line-length`  | 120         | Not Ruff's default of 88. One of the four column guides every editor here draws |
| `indent-width` | 4           | The repo-wide 4-space rule                                                      |
| `quote-style`  | `single`    | Not Ruff's default of double                                                    |
| `line-ending`  | `lf`        | Never CRLF, whatever the platform                                               |
| `fix`          | `true`      | `ruff check` rewrites files — see below                                         |
| `preview`      | `true`      | Unstable rules on — see below                                                   |
| `select`       | 31 families | Broad by design; easier to silence a rule than to discover one                  |

Three of those look like mistakes against the rest of this setup and are not:

* **`fix = true` makes `ruff check` rewrite your files.** Every editor here has
  format-on-save off and formatting behind an explicit `<leader>F`, so this is
  the one tool that edits on invocation. Only fixes Ruff considers safe are
  applied; `--unsafe-fixes` is not enabled.
* **`preview = true` enables unstable rules.** Whole families are preview-only
  — `DOC` entirely, parts of `FURB` and `PLR` — so without it roughly a third
  of the selection would silently do nothing. The cost is that `brew upgrade
  ruff` can change what lints with nothing here changing.
* **`CPY` requires a copyright notice in every file.** Unusual in personal
  projects, and deliberate.

## Who reads it

All of them, because they run the same binary: the `ruff` CLI, the Ruff
language server Neovim attaches through
[`../nvim/.config/nvim/after/lsp/ruff.lua`](../nvim/.config/nvim/after/lsp/ruff.lua),
and `charliermarsh.ruff` in Visual Studio Code and Cursor.

## Verifying it is actually being read

Presence is not proof — Ruff falls back silently. Compare all three:

```sh
cd /tmp                                  # somewhere with no project config
ruff check --show-settings . | grep -E '^(line-length|.*quote-style)'
ruff check --isolated --show-settings . | grep '^line-length'   # 88, the default
```

If the first shows `line-length = 120` and the second `88`, this file is being
found. If both say 88, it is not.
