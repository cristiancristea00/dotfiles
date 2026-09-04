# AGENTS.md

Guidance for AI coding agents working in this repository. [README.md](README.md)
describes what the repo is; this file describes how to change it without
breaking its conventions.

This file is the single source of truth. `CLAUDE.md` and `GEMINI.md` are
symlinks to it, so each assistant finds the guidance under its own filename
and there is one document to maintain. Edit `AGENTS.md`; never edit a symlink,
and never replace one with a real file. To support another tool:

```sh
ln -s AGENTS.md <TOOLNAME>.md
```

## Documentation conventions

Configuration is documented in place. An edit that adds a setting without
documenting it is incomplete.

Every file opens with a header block: the file's name and one-line purpose,
what the file is, where its authority ends when two files govern one tool, and
the traps of its format. Each setting is annotated:

```text
# WHAT: What this option does.
# WHY : Why this value: the default, the rejected alternative, or the failure
#       it prevents.
# HOW : The concrete edit or command to change it.
```

Rules:

* **Every sentence starts with a capital letter**, including the first word
  after `WHAT:`, `WHY :`, `HOW :`, and `NOTE:`. Where that word would be a
  lowercase tool name (`bat`, `delta`, `eza`, `clangd`, `fzf`), a literal
  value (`true`, `false`), or an identifier (`copy-on-select`,
  `vim.lsp.config`), rephrase the sentence to lead with a real word: `The
  delta pager reformats…`, not `Delta is a pager…`. Do not capitalise after
  `e.g.`, `i.e.`, or `etc.`.
* The space after `WHY` and `HOW` aligns the three colons. Continuation lines
  indent to the first character after `WHAT:`.
* `WHAT` is mandatory, `WHY` nearly always, `HOW` where it helps.
* A `WHY` that restates the `WHAT` or the value is not a `WHY`. Cite the
  default, the alternative, or the failure the setting prevents.
* Record the default where the format allows it: on its own line for Ghostty,
  which has no trailing comments; inline for TOML, Lua, and JSONC.
* **List entries get one comment line each**: a keymap, a plugin spec, a
  Brewfile line, an ignore pattern, a language-table entry. The line says
  what the entry does and, where not obvious, why. Full `WHAT`/`WHY`/`HOW`
  blocks are for standalone settings and for entries with a non-obvious
  rationale.
* A setting turned off by choice is not deleted; it is commented out with its
  reasoning under a "documented extension points (inactive)" heading. A key
  the tool does not recognise, or one that has no effect on any platform this
  repo targets, is deleted, and the commit message says why.
* Cross-reference by relative path when two files are coupled, and say so in
  both files. Point at a root README section as `../README.md § Heading`
  (with the right number of `../`) in a config file, or as a Markdown link
  to the heading's anchor in a README.
* **Each fact has one home.** Setting-level facts live beside the setting.
  Topics that span packages (the font stack, light and dark, the cursor, the
  column guides, the stow model) live in the root README; package READMEs
  hold the package's file map, install steps, and pointers; this file holds
  agent rules. Other files state a fact in one sentence and point at the
  owner.
* **Prose states facts in plain words.** The standard is Anthropic's
  definition of the failure to avoid:

  > Mannered prose substitutes metaphor and flourish for direct statement.
  > Instead of "a parameter worth varying," the mannered writer produces "a
  > dial worth turning." Instead of "this point still matters," they write
  > "this point earns its keep." The phrases exist to display the writer,
  > not to convey the idea, and readers can tell. That is why mannered prose
  > irritates: it makes the reader work harder so the writer can perform. It
  > is also imprecise. Metaphors drag in connotations the writer did not
  > choose and cannot control. The fix is to say what you mean. When a
  > literal phrase is available, use it.

  In practice: no metaphor; no rhetorical framing ("Two things make this
  repo what it is", "X, not Y", "which is what makes"); no ALL-CAPS emphasis
  inside a sentence; no narrative of past states (git history has it; state
  the failure a setting prevents in the present tense); no evaluation
  ("pleasant", "for free", "worth knowing"); one sentence per fact; and each
  fact stated once per file. Em-dashes mark a genuine aside only. Headings
  are sentence case. Every path, command, and key is in inline code.
* **British English, and the Oxford comma.** Write `colour`, `behaviour`,
  `initialise`, `grey`, `honour`, `customise`, and `a, b, and c`. This applies
  to prose only. Identifiers keep their author's spelling, because changing
  one breaks the config: `colorcolumn`, `colorscheme`, `termguicolors`, and
  the `ColorColumn` highlight group are Vim's names; `--color` and
  `--color-theme` are CLI flags; `color = "magenta"` in tlrc's config and
  `"color"` in VS Code's ruler objects are keys; `catalog.json` is a filename.
  Where a sentence would begin with such a word, rephrase it. Established
  computing terms stay as they are: a `dialog` box, a `program`, a schema
  `catalog`.
* **Indent every file with 4 spaces**, never tabs, Lua included. The prose
  inside `--[[ … ]]--` header blocks keeps its own alignment.
* **A blank line separates annotated blocks.** In every format, one setting's
  `WHAT`/`WHY` block is separated from the next by a blank line, so the
  comments do not run together. In the JSONC settings files, arrays and
  objects are also expanded to one entry per line, which is what VS Code's own
  formatter produces; a blank line still goes before each block and before
  each `// --- Section ---` heading, but not between a `WHY` and the `NOTE` or
  `HOW` that continues the same block.

## Repo map

Each top-level directory is a stow package whose contents mirror their path
under `$HOME`: `bat/.config/bat/config` becomes `~/.config/bat/config`. A new
file goes where it lives when deployed.

Packages: `bat` `cursor` `fish` `ghostty` `git` `neovide` `nvim` `ruff`
`tlrc` `vscode` `zed`. Root files (`README.md`, `AGENTS.md` and its symlinks,
`install.sh`, `Brewfile`, `LICENSE`, `.gitignore`) are not packages and are
never stowed. Each package has a `README.md`, which stow's default ignore list
keeps out of `$HOME`.

The three stow invocations, and why a package is in one group rather than
another, are documented in [The stow model](README.md#the-stow-model). The
rules an agent must not break:

* A directory stays real (`--no-folding`) if anything machine-local has to
  live in it: runtime state the application writes, or a per-OS selector
  symlink. Adding a file to a `--no-folding` package needs
  `stow -R --no-folding … <pkg>`, or the file is not linked.
* The `vscode cursor` invocation must stay separate. `--ignore` is a per-run
  flag, so merging those two into the `--no-folding` call would apply
  `--ignore='\.config'` to fish, ghostty, git, and zed and remove their
  entire trees. `install.sh` keeps the two lists apart, and `backup_conflicts`
  takes a matching skip prefix that must never be passed for the other
  packages.
* `vscode/` holds the only real `settings.json`; the other three paths (one in
  `vscode/`, two in `cursor/`) are committed symlinks, mode `120000`, like
  `CLAUDE.md`. Edit the real file; never replace a link with a copy.

## Cross-platform

The repo targets macOS and Linux. Three mechanisms, described in
[Per-OS configuration](README.md#per-os-configuration):

1. **Runtime branching**, wherever the format allows it: Neovim checks
   `vim.uv.os_uname().sysname`, fish probes the three Homebrew prefixes, the
   Brewfile uses `OS.mac?` and `OS.linux?`.
2. **Per-OS files plus a selector symlink**, for formats with no conditionals:
   `bat` ships `config.darwin` and `config.linux`, `ghostty` ships
   `os-darwin.ghostty` and `os-linux.ghostty`, and `install.sh` links the
   right one.
   The two variants stay in sync except for the settings that justify the
   split; a new option goes in both.
3. **A bridge symlink**, for `tlrc` only, whose config path is XDG on Linux
   and `~/Library/Application Support` on macOS.

macOS-only, and guarded: the ⌘ (`<D-…>`) keymaps, `macos-option-as-alt`,
`font-thicken`, `system-native-tabs`, `codesign`, and `--theme=auto:system`.
Linux-only needs: a clipboard provider (`wl-clipboard` or `xclip`) for
`clipboard=unnamedplus`, and fonts fetched from a private repository, because
casks do not exist there.

Structure to know before editing:

* `nvim/.config/nvim/lua/languages.lua` is where languages are declared. One
  entry per language drives treesitter parsers, LSP activation, and formatter
  routing; add a language there, not in the plugin files.
* `nvim/.config/nvim/after/lsp/*.lua` overrides nvim-lspconfig's defaults. The
  `after/` prefix is required; a plain `lsp/` merges at the plugin's tier and
  loses.
* Three Catppuccin themes are fetched by `install.sh` into `$HOME` and not
  committed: delta's `catppuccin.gitconfig`, eza's two `theme.yml` files, and
  Xcode's `.xccolortheme` pair. Every consumer works without them. Do not add
  one of these files to a package to satisfy a config that references it. See
  [Fetched themes](README.md#fetched-themes).
* The font stack spans five files and differs between editors and terminals.
  Change all of them together; [The font stack](README.md#the-font-stack)
  lists them, and VS Code needs eight further keys for the same family.
* `vscode/.config/Code/User/settings.json` is read by VS Code and Cursor
  through symlinks. Never add `window.zoomLevel` to it: VS Code bug #275792
  deletes every comment line above a setting when that setting is reset, and
  the zoom shortcuts write this key. Settings Sync must stay off; it is a
  second writer whose merge is not documented to keep comments.

## Commit convention

Commits follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):
`<type>(<scope>): <description>`.

| Type       | Use for                                                          |
| ---------- | ---------------------------------------------------------------- |
| `feat`     | A package gaining a capability: a new tool config, a new setting |
| `fix`      | Correcting broken behaviour: a dead key, an ignored option       |
| `docs`     | READMEs, comments, and this file, when no configuration changes  |
| `refactor` | Restructuring that changes no behaviour                          |
| `chore`    | Repo-wide maintenance: scaffolding, dependencies, gitignore      |

Rules:

* **Scope is the package directory**: `bat`, `cursor`, `fish`, `ghostty`,
  `git`, `neovide`, `nvim`, `ruff`, `tlrc`, `vscode`, `zed`. Omit it only for
  repo-wide changes, which are usually `chore` or `docs`.
* **One package per commit.** A change spanning packages (a font-stack edit
  touching several files) is the exception, and its scope is omitted.
* Description in lower case, imperative mood, no trailing period.
* A body is expected for anything non-obvious: what changed, why that choice,
  any format trap involved, and the source a new `WHY` was checked against.
* **Every agent-authored commit carries a `Co-Authored-By` trailer** naming
  the assistant, with the identity that tool publishes for the purpose. It
  records which commits were machine-assisted; the `Signed-off-by` line stays
  the human's.
* **Footers are one contiguous block** with no blank line between them, or
  git parses only the last paragraph as trailers:

  ```git
  Co-Authored-By: <Assistant Name> <assistant-email>
  Signed-off-by: Cristian Cristea <cristiancristea00@gmail.com>
  ```

  Use `git commit -s` so the sign-off comes from the configured identity.
* Commits are GPG-signed (`commit.gpgSign = true`). This repository lives
  outside `~/work/`, so it commits under the personal identity; see
  [git/README.md](git/README.md).

## Safety rules

* **Never edit `~/.config/*` directly.** Those paths are symlinks into this
  repo, which is the source of truth. Editing the deployed copy either edits
  the repo through the link or breaks the link.
* **Never run `stow --adopt`.** It moves files from `$HOME` into the repo,
  overwriting the committed version with whatever was deployed.
* **Back up before deploying.** Stow refuses to overwrite real files; resolve
  a conflict by moving the target aside, never by forcing.
* **Machine-specific content goes in local overlays**, never in the repo:
  `~/.config/fish/conf.d/99-work.fish` for shell helpers,
  `~/.config/git/config.work` for the Git identity. Both work because those
  packages are `--no-folding`.
* **`nvim-pack-lock.json` is committed.** It pins plugin revisions. Do not add
  it to `.gitignore`.
* **Commit your work.** The agent handles Git in this repository: finishing a
  change means committing it under the convention above.
  * One package per commit, in the order the packages are listed in the repo
    map.
  * **Never `push`.** Publishing is the user's.
  * Never `--amend`, rebase, or reset a commit the user already has; rewriting
    their history is a separate, explicit request. The one exception is
    correcting your own mistake in a commit created this session and not yet
    handed over; say that you did it.
  * **Stage per package, and check what is staged before committing.** A
    `git mv` stages immediately, so a later `git add <other-package>` sweeps
    that rename into the wrong commit. `git diff --cached --name-only` is the
    check.
  * Signing is automatic (`commit.gpgSign = true`). If GPG cannot sign, stop
    and say so; do not commit with `--no-gpg-sign`.
* **`install.sh` must stay bash 3.2-compatible**, the version macOS ships:
  no associative arrays, no `mapfile`, no `${var,,}`. Verify with
  `/bin/bash -n install.sh` on macOS, not only with a Linux bash.
* **Nothing in `install.sh` may block on a password without a terminal.**
  `chsh` and `sudo` prompt on their own and cannot be fed an answer, so a step
  that reaches one is gated on `[ -t 0 ]`, and `--yes` does not override that.
  `set_login_shell` is the only step gated that way today. The `sudo` calls in
  `install_prerequisites` and `install_gui_apps_linux` are not, because a
  Linux package install cannot proceed without them at all; a new one belongs
  behind `confirm`, which refuses without a tty, rather than behind a bare
  `sudo`.
* **`confirm` never assumes consent.** It takes a per-call default (`yes` for
  backing files up, which destroys nothing; `no` for anything that changes
  the system) and, without a terminal, refuses. `--yes` is the way to say yes
  without a keyboard; a non-tty default of yes would let a piped run move
  the user's configs aside unasked.
* **An abort message must say what already happened.** By the time the backup
  prompt appears, the package manager has run, so "nothing was changed" would
  be false.
* **Verify before claiming success.** Ghostty, TOML, and JSONC accept an
  unknown key without an error. [Verifying a change](README.md#verifying-a-change)
  lists the check for each format, including the isolated Neovim test.

## Common commands

```sh
# Deploy everything (installs packages, links configs, bootstraps Neovim)
./install.sh
./install.sh --dry-run          # preview without changing anything
./install.sh --cli-only         # skip GUI apps (servers, containers)
./install.sh --packages nvim    # one package
./install.sh --uninstall        # remove the symlinks
./install.sh --yes              # required for non-interactive runs

# The three stow invocations install.sh runs, if you need them by hand
stow --target="$HOME" --dir="$PWD" neovide nvim ruff tlrc
stow --no-folding --target="$HOME" --dir="$PWD" bat fish ghostty git zed
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$PWD" vscode cursor  # macOS
stow --no-folding --ignore='Library'  --target="$HOME" --dir="$PWD" vscode cursor  # Linux

# Preview, re-link after adding files, remove
stow -n -v --target="$HOME" --dir="$PWD" <pkg>     # dry run
stow -R --no-folding --target="$HOME" --dir="$PWD" <pkg>
stow -D --target="$HOME" --dir="$PWD" <pkg>

# Dependencies
brew bundle --file Brewfile
```
