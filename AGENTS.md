# AGENTS.md

Guidance for AI coding agents working in this repository. Read
[README.md](README.md) for what the repo *is*; this file is about how to
change it without breaking its conventions.

**This file is the single source of truth.** Tool-specific entry points are
symlinks to it — currently `CLAUDE.md` and `GEMINI.md` — so each assistant
finds the guidance under the filename it looks for while there is only ever
one document to maintain. Edit `AGENTS.md`; never edit a symlink, and never
let them drift by replacing one with a real file. To support another tool,
add another symlink:

```sh
ln -s AGENTS.md <TOOLNAME>.md
```

## Documentation conventions — the contract

This repo's whole point is that **configuration is documented in place**. Any
edit that adds a setting without documenting it is incomplete.

Every file opens with a header block: the file's name and one-line purpose,
what the file is, where its authority begins and ends (especially when two
files govern one tool), and the traps of its format. Individual settings are
annotated:

```
# WHAT: What this option does.
# WHY : Why this value — name the rejected alternative and why it is worse.
# HOW : The concrete edit or command to change it.
```

Rules that matter:

* **Every sentence starts with a capital letter**, including the first word
  after `WHAT: `, `WHY : `, `HOW : ` and `NOTE: `. Where that word would be a
  canonically-lowercase tool name (`bat`, `delta`, `eza`, `clangd`, `fzf`), a
  literal value (`true`, `false`) or an identifier (`copy-on-select`,
  `vim.lsp.config`), **rephrase the sentence to lead with a real word** rather
  than capitalising the identifier — `The delta pager reformats…`, not
  `Delta is a pager…`. Do not capitalise after `e.g.`, `i.e.` or `etc.`.
* Note the space after `WHY` and `HOW` so the three colons align.
* Continuation lines indent to sit under the first character after `WHAT: `.
* `WHAT` is mandatory, `WHY` nearly always, `HOW` where it helps.
* A `WHY` that restates the `WHAT` is not a `WHY`. Cite the default, the
  alternative, or the failure it prevents.
* Record the default where the format allows it — on its own line for Ghostty
  (no trailing comments), inline for TOML and Lua.
* Never silently delete a setting. Comment it out with its reasoning under a
  "documented extension points (inactive)" heading.
* Cross-reference by relative path when two files are coupled, and say so in
  **both** files.
* Prose style: em-dashes for asides, sentence case in headings, inline code for
  every path, command, and key.
* **British English, and the Oxford comma.** Write `colour`, `behaviour`,
  `initialise`, `grey`, `honour`, `customise`; and `a, b, and c` rather than
  `a, b and c`.
  **This applies to PROSE ONLY, and the exception is the important half.**
  Identifiers keep whatever spelling their author gave them, because changing
  one breaks the config: `colorcolumn`, `colorscheme`, `termguicolors` and the
  `ColorColumn` highlight group are Vim's own names; `--color` and
  `--color-theme` are CLI flags; `color = "magenta"` in tlrc's config and
  `"color"` in VS Code's ruler objects are keys; `catalog.json` is a filename.
  Where a sentence would have to begin with such a word, rephrase it — the
  same rule already used for capitalising after `WHAT: `.
  Established computing terms are not Americanisms and stay as they are: a
  `dialog` box, a `program`, a schema `catalog`.
* **Indent every file with 4 spaces**, never tabs — Lua included, despite the
  2-space convention common in Neovim configs. The prose inside `--[[ … ]]--`
  header blocks keeps its own alignment and is not code indentation.

## Repo map

Each top-level directory is a **stow package whose contents mirror their path
under `$HOME`** — `bat/.config/bat/config` becomes `~/.config/bat/config`. When
adding a file, put it where it really lives; the path is the deployment
instruction.

Packages: `bat` `cursor` `fish` `ghostty` `git` `neovide` `nvim` `tlrc`
`vscode` `zed`. Root
files (`README.md`, `AGENTS.md` and its symlinks, `install.sh`, `Brewfile`,
`LICENSE`, `.gitignore`) are not packages and are never stowed. Each package has its own
`README.md`, which stow's default ignore list keeps out of `$HOME`.

Three linking strategies, and the distinction is load-bearing:

* **Folded** (`neovide nvim tlrc`) — the whole directory is one symlink. New
  files go live with no restow.
* **`--no-folding`** (`bat fish ghostty git zed`) — per-file symlinks, so the
  directory stays real. **Adding a file to one of these requires
  `stow -R --no-folding … <pkg>`**, or it simply will not appear.
* **`--no-folding --ignore=…`** (`vscode cursor`) — as above, plus a per-OS
  filter. Each package ships both a `.config/` and a `Library/` tree, and
  `--ignore` drops the one the platform does not read.

The rule for which group a package belongs to: **a directory must stay real if
anything machine-local has to live in it** — either runtime state the app
writes (fish, git, zed, and the editors' `globalStorage/` and `History/`) or one
of the per-OS selector symlinks below (bat, ghostty).

**The `--ignore` trap.** That third invocation must stay separate. `--ignore`
is a per-run flag, so merging `vscode cursor` into the `--no-folding` call
would apply `--ignore='\.config'` to **fish, ghostty, git, and zed** and erase
their entire trees. `install.sh` keeps the two lists apart for this reason, and
`backup_conflicts` takes a matching skip-prefix that must likewise never be
passed for the other packages.

One further consequence: `vscode/` holds the only real `settings.json`, and the
other three paths — one in `vscode/`, two in `cursor/` — are **committed
symlinks** (mode `120000`), the same mechanism as `CLAUDE.md`. Edit the real
file; never replace a link with a copy.

## Cross-platform

This repo targets macOS **and** Linux. Before changing anything platform-shaped,
know which of the three mechanisms applies:

1. **Runtime branching** — preferred wherever the format allows it. Neovim uses
   `vim.uv.os_uname().sysname == "Darwin"`; fish probes all three Homebrew
   prefixes (`/opt/homebrew`, `/usr/local`, `/home/linuxbrew/.linuxbrew`); the
   Brewfile uses `OS.mac?` / `OS.linux?`.
2. **Per-OS files plus a selector symlink** — for formats with no conditionals.
   `bat` ships `config.darwin`/`config.linux`, `ghostty` ships
   `os-darwin.conf`/`os-linux.conf`, and `install.sh` links the right one.
   **Both variants must be kept in sync except for the setting that justifies
   the split** — if you add an option, add it to both.
3. **A bridge symlink** — only `tlrc`, whose config path is XDG on Linux but
   `~/Library/Application Support` on macOS. The repo ships the XDG path and
   `install.sh` bridges macOS to it.

Things that are macOS-only and must stay guarded: the ⌘ (`<D-…>`) keymaps,
`macos-option-as-alt`, `font-thicken`, `system-native-tabs`, `codesign`, and
`--theme=auto:system`. Things Linux needs that macOS does not: a clipboard
provider (`wl-clipboard`/`xclip`) for `clipboard=unnamedplus`, and fonts
installed by hand because casks do not exist there.

Structural things worth knowing before editing:

* `nvim/.config/nvim/lua/languages.lua` is the spine of the Neovim config. One
  table entry per language drives treesitter parsers, LSP activation and
  formatter routing. Add a language there, not in three plugin files.
* `nvim/.config/nvim/after/lsp/*.lua` overrides nvim-lspconfig's defaults. The
  `after/` prefix is required — a plain `lsp/` loses the merge.
* **Not everything configured here is a stow package.** Three Catppuccin
  themes are *fetched* by `install.sh` into `$HOME` rather than committed —
  delta's `catppuccin.gitconfig`, eza's two `theme.yml` files, and Xcode's
  `.xccolortheme` pair. They are deliberately absent from the repo, and every
  consumer fails soft when they are: Git ignores a missing `include.path`,
  delta ignores an unresolvable `features` name, and eza falls back to its own
  colours. Do not "fix" a config that references one of these by adding the
  file to a package.
  Xcode is also the only configured application with no Brewfile entry — it
  comes from the App Store — and selecting its theme is a manual step in
  *Xcode → Settings → Themes* that the repo cannot perform.
* The font stack spans five packages and the fallback chain differs between
  editors and terminals. Consult the matrix in the root README before touching
  any font setting, and change all of them together. VS Code is the awkward
  one: it does not inherit `editor.fontFamily` into its CodeLens, inlay-hint,
  debug-console, SCM, notebook or chat surfaces, so eight further keys carry
  the same value and must move with it.
* `vscode/.config/Code/User/settings.json` is read by **both** VS Code and
  Cursor through symlinks. Never add `window.zoomLevel` to it — open VS Code
  bug #275792 deletes every comment line above a setting when it is reset, and
  this file is almost entirely comments. Settings Sync must also stay off; it
  is a second writer with no comment-preservation guarantee.

## Commit convention

Commits follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):
`<type>(<scope>): <description>`.

| Type       | Use for                                                            |
| ---------- | ------------------------------------------------------------------ |
| `feat`     | A package gaining a capability — a new tool config, a new setting  |
| `fix`      | Correcting broken behaviour: a dead key, a silently-ignored option |
| `docs`     | READMEs and this file, when no configuration changes               |
| `refactor` | Restructuring that changes no behaviour                            |
| `chore`    | Repo-wide maintenance: scaffolding, dependencies, gitignore        |

Rules:

* **Scope is the package directory** — `bat`, `cursor`, `fish`, `ghostty`,
  `git`, `neovide`, `nvim`, `tlrc`, `vscode`, `zed`. Omit it only for repo-wide
  changes, which are usually `chore`.
* **One package per commit.** A change spanning packages (a font-stack edit
  touching four files) is the exception, and its scope is omitted.
* Description in lower case, imperative mood, no trailing period.
* A body is expected for anything non-obvious: what changed, why that choice,
  and any format trap involved.
* **Every agent-authored commit carries a `Co-Authored-By` trailer** naming the
  assistant that wrote it, using whatever identity that tool publishes for the
  purpose. It records which commits were machine-assisted; the `Signed-off-by`
  line remains the human's.
* **Footers are one contiguous block** with no blank line between them, or git
  parses only the last paragraph as trailers:

  ```
  Co-Authored-By: <Assistant Name> <assistant-email>
  Signed-off-by: Cristian Cristea <cristiancristea00@gmail.com>
  ```

  Use `git commit -s` so the sign-off is derived from the configured identity
  rather than typed by hand.
* Commits are GPG-signed (`commit.gpgSign = true`), and this repository commits
  under the **personal** identity via a repo-local override — see
  [git/README.md](git/README.md).

## Safety rules

* **Never edit `~/.config/*` directly.** Those paths are symlinks into this
  repo; the repo is the source of truth. Editing the deployed copy either
  edits the repo through the link (confusing) or breaks the link (worse).
* **Never run `stow --adopt`.** It moves files from `$HOME` *into* the repo,
  silently overwriting the committed version with whatever was deployed.
* **Back up before deploying.** Stow refuses to overwrite real files, which is
  a feature — resolve conflicts by moving the target aside, never by forcing.
* **Machine-specific content goes in local overlays**, never in the repo:
  `~/.config/fish/conf.d/99-work.fish` for shell helpers,
  `~/.config/git/config.work` for Git identity. Both work because those
  packages are `--no-folding`.
* **`nvim-pack-lock.json` is committed on purpose.** It pins exact plugin
  revisions. Do not add it to `.gitignore`.
* **Commit your work.** The agent handles Git in this repository — finishing a
  change means committing it, following the Commit convention above. Do not
  leave the tree dirty and hand it back.
  - One package per commit, in the order the packages are listed in the repo
    map, so history reads consistently.
  - **Never `push`.** Committing is yours; publishing is the user's.
  - Never `--amend`, rebase or reset a commit the user already has — rewriting
    their history is a separate, explicit request. The one exception is
    correcting your own mistake in commits you created this session and have
    not handed over: a commit whose message does not match its contents is
    worse than the rewrite that fixes it. Say that you did it.
  - **Stage per package, and check what is staged before committing.** A
    `git mv` stages immediately, so a later `git add <other-package>` will
    sweep that rename into the wrong commit. `git diff --cached --name-only`
    is the check.
  - Signing is automatic (`commit.gpgSign = true`). If GPG cannot sign, stop
    and say so rather than committing unsigned with `--no-gpg-sign`.
* **`install.sh` must stay bash 3.2-compatible** — that is what macOS ships. No
  associative arrays, no `mapfile`, no `${var,,}`. Verify with
  `/bin/bash -n install.sh` on macOS, not just your Linux bash.
* **Nothing in `install.sh` may block on a password without a terminal.**
  `chsh` and `sudo` prompt on their own and cannot be fed an answer, so they
  are gated on `[ -t 0 ]`. `--yes` deliberately does not override that.
* **`confirm` never assumes consent.** It takes a per-call default (`yes` for
  backing files up, which destroys nothing; `no` for anything that changes the
  system) and, without a terminal, **refuses** rather than proceeding. Saying
  yes without a keyboard is what `--yes` is for. An earlier version returned
  yes on a non-tty, which meant piping the script silently displaced the
  user's configs.
* **An abort message must say what already happened.** By the time the backup
  prompt appears, the package manager has run. Claiming "nothing was changed"
  is worse than saying nothing.
* Verify before claiming success. Every format here fails *silently* on a bad
  key — see the checks below.

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
stow --target="$HOME" --dir="$PWD" neovide nvim tlrc
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

Validation — run the one matching what you touched:

```sh
shellcheck install.sh                                      # the installer
ghostty +validate-config                                   # silent = valid
ghostty +show-config | grep macos-option-as-alt            # RESOLVED value,
                                                           # proves the include loaded
ruby -c Brewfile                                           # a Brewfile is Ruby
git config --file git/.config/git/config --list
fish --no-execute <file.fish>
python3 -c "import tomllib,sys;tomllib.load(open(sys.argv[1],'rb'))" <file.toml>
nvim "+checkhealth vim.pack vim.lsp nvim-treesitter" +qa
```

The `settings.json` files for Zed, VS Code and Cursor are **JSONC** —
`json.load` will reject their comments; strip them first or use a
JSONC-tolerant parser.

For Neovim, test in a clean room rather than against the live config:

```sh
S=$(mktemp -d); mkdir -p "$S/config"
ln -s "$PWD/nvim/.config/nvim" "$S/config/nvim"
env XDG_CONFIG_HOME="$S/config" XDG_DATA_HOME="$S/data" \
    XDG_STATE_HOME="$S/state" XDG_CACHE_HOME="$S/cache" \
    nvim --headless "+lua print('ok')" +qa
```
