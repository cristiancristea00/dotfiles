# agents

One global instruction file and four language files for three AI coding
agents: Claude Code, Codex, and Antigravity. Each reads the global file as its
user-level instructions, in every repository. It sets the rules for asking
questions, prose, code, and commits. The language files hold the style rules
for C++ and C, Swift and Objective-C, Rust, and Python.

## Where the files live

| Path in this package             | Deployed as                        | Read by                     | What it is                                       |
| -------------------------------- | ---------------------------------- | --------------------------- | ------------------------------------------------ |
| `.codex/AGENTS.md`               | `~/.codex/AGENTS.md`               | Codex                       | The real global file                             |
| `.claude/CLAUDE.md`              | `~/.claude/CLAUDE.md`              | Claude Code                 | Committed symlink (mode `120000`) to the above   |
| `.gemini/AGENTS.md`              | `~/.gemini/AGENTS.md`              | Antigravity (App, IDE, CLI) | Committed symlink (mode `120000`) to the above   |
| `.codex/languages/*.md`          | `~/.codex/languages/*.md`          | Codex, by reference         | The real language files                          |
| `.claude/rules/*.md`             | `~/.claude/rules/*.md`             | Claude Code                 | Committed symlinks (mode `120000`) to the above  |
| `.gemini/config/rules/*.md`      | `~/.gemini/config/rules/*.md`      | Antigravity (App, IDE, CLI) | Committed symlinks (mode `120000`) to the above  |

Edit the files under `.codex/`, never a link.

The real global file sits under `.codex/` rather than at the package root
because stow links every file in a package. A root `AGENTS.md` would be
deployed as `~/AGENTS.md`, which Claude Code can read a second time as a
parent-directory `AGENTS.md`. The global file's two links follow the precedent
of `cursor/`, which links into `vscode/`.

Antigravity's global rules can be `~/.gemini/AGENTS.md` or
`~/.gemini/GEMINI.md`, both read by the App, the IDE, and the CLI; the CLI
alone also reads the same names under `~/.gemini/config/`. The link is
`AGENTS.md` for two reasons:

* It is the name the other tools use.
* `~/.gemini/GEMINI.md` stays free for machine-local rules, the same overlay
  mechanism as in [The stow model](../README.md#the-stow-model). Antigravity
  loads a real `~/.gemini/GEMINI.md` alongside the link, and nothing in it
  reaches the repo.

The package links one name only. Antigravity loads every global rule file it
finds, so a second link to the same file would risk loading it twice.

## Language files

Each language file enters the context only while the agent works in that
language, so a session's context holds only the rules for the languages it
works in. The global file's
Languages section lists the four files and tells the agent to read the right
one when its rules are not already in context. Each tool gets the files this
way:

* **Claude Code** loads `~/.claude/rules/<language>.md` when it reads, writes,
  or edits a file that matches the rule's `paths` frontmatter.
* **Antigravity** loads `~/.gemini/config/rules/<language>.md` when the agent
  works on a file that matches the rule's `globs`, because the rule's
  `trigger` is `glob`.
* **Codex** has no file-triggered instructions. It reads
  `~/.codex/languages/<language>.md` because the global file's list tells it
  to.

The list also covers the cases in which Claude Code or Antigravity does not
load a file on its own; the Traps section names them. A `.h` file matches both
the C++ and the Swift file, because it can be C, C++, or Objective-C.

The files live under `.codex/languages/` because Codex reads them by path,
and `~/.codex/rules/` holds Codex's command policy.

## Install

`./install.sh` handles this. By hand:

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" agents
```

`--no-folding` keeps `~/.claude`, `~/.codex`, and `~/.gemini` real
directories. All three hold credentials, sessions, and settings that do not
belong in the repo. See [The stow model](../README.md#the-stow-model).

A real `~/.codex/AGENTS.md` from before this package is moved to the
`~/.dotfiles-backup-*` directory by `install.sh`.

## Precedence

The global file's opening paragraph gives the order:

1. The user's messages override every rule.
2. A project's instruction files, contributing guide, and formatter and linter
   configuration override the Code and Languages sections, the language
   files, and the commit message format.
3. The other rules apply in every project.

The global file states this because the tools do not agree on an order:

| Tool        | Built-in order                                                                    |
| ----------- | --------------------------------------------------------------------------------- |
| Claude Code | None. A conflicting user-level and project rule may be followed either way        |
| Codex       | Places project files after the global file, so they win                           |
| Antigravity | Loads all rules together; on a conflict, the more specific directory's rule wins  |

## Length

The global file is about 170 lines, blank lines included. Each language file
is loaded only for its own files, so it does not add to that count.

* Claude Code warns when an instruction file passes about 200 lines.
* OpenAI reports that shorter instructions score higher in its coding-agent
  tests.
* Antigravity truncates each rule file past 24,000 bytes; the global file and
  each language file count separately. Global and always-on rules share a
  20,000-token budget.

A new rule earns its place only if an agent makes the mistake without it.

## Traps

* **`@` starts an import.** Claude Code imports any `@path` outside backticks.
  Antigravity pastes in a file named as `@[label](path)` and turns a bare
  `@filename` into a path reference. Keep every `@` in backticks, and use no
  imports.
* **Subagent model and effort are not enforced in Antigravity.** The file asks
  for subagents on the main agent's model and effort, except in a Claude Fable
  session, which delegates to Opus one effort level higher. Codex does this by
  default, and Claude Code sets them per call when its instructions ask.
  Antigravity sets a subagent's model only in that subagent's definition
  (`inherit`, `flash`, or `pro`, in `~/.gemini/config/agents/`), and has no
  per-subagent thinking level.
* **Agent co-author trailers are set outside this file.**
  * Claude Code adds its trailer from the `attribution` setting, which managed
    settings can fix.
  * Codex adds its trailer from a ChatGPT account setting. Codex injects that
    setting's text with an instruction to ignore any earlier rule on
    attribution.
  * Antigravity adds none.
  * The file therefore says nothing about agent trailers.
* **Unverified: Antigravity and committing.** Its documentation does not say
  whether it commits unasked, so it is not established that the file's "commit
  each finished change" rule is followed.
* **Unverified: the App and IDE through a symlink.** Only the CLI's loading of
  `~/.gemini/AGENTS.md` is tested here. If the App or IDE cannot quote the
  file, replace the link with a copy that `install.sh` writes.
* **Unverified: "+ Global" writes `~/.gemini/GEMINI.md`.** A user report says
  the IDE's "+ Global" button creates or edits that file. It is the local
  overlay, so such edits stay out of the repo.
* **The agents load this file twice in this repo.** While working on files
  under `agents/`, Claude Code also reads `agents/.claude/CLAUDE.md` as a
  nested project file, and Antigravity reads `agents/.codex/AGENTS.md` as a
  directory rule. The second copy is the same text and does no harm.
* **Claude Code has no user-level `AGENTS.md`.** It reads `AGENTS.md` only in a
  project, so `~/.claude/CLAUDE.md` is the only global path.
* **Cowork skips the symlinked `~/.claude/` files.** Cowork sessions in the
  Claude desktop app do not load this link or the symlinked rules in
  `~/.claude/rules/`. They also skip user-level imports that resolve outside
  the working directory. Claude Code in the terminal and in the desktop app's
  Code tab reads the links.
* **One frontmatter serves two tools.** Claude Code reads only `paths` and
  ignores the other keys. Antigravity reads `trigger`, `globs`, and
  `description`. Quote every glob that starts with `*`, and keep the
  frontmatter free of comments.
* **A frontmatter error fails silently, in opposite directions.** Claude Code
  loads a rule whose frontmatter does not parse in every session, as if it had
  no `paths`. Antigravity discards a rule whose `trigger` is missing or not a
  valid value.
* **Claude Code does not always load a language file.**
  * The `paths` patterns match only under the session's primary working
    directory.
  * Glob, Grep, and `find` do not load the rule; Read, Write, Edit, and a
    `cat` or `head` of one file do.
  * `/compact` drops a loaded rule until the next matching read.
  * A file created with Write may receive its rule only after the first
    write.
* **Unverified: Antigravity's glob trigger for global rules.** Its
  documentation describes `trigger: glob` for workspace rules and requires
  frontmatter for global ones, but does not say that a global rule is
  triggered by `globs`, or that it ignores the `paths` key.
* **Antigravity may ask before reading a language file by path.** Its agent
  needs approval to read outside the workspace, which affects only the list's
  fallback, not the glob-triggered rule.

## Verifying a change

```sh
git ls-files -s agents | grep -c 120000                 # 10 links
grep -nE '(^|[[:space:]])@' agents/.codex/AGENTS.md agents/.codex/languages/*.md   # empty: no unquoted @
readlink -f ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.gemini/AGENTS.md
readlink -f ~/.claude/rules/*.md ~/.gemini/config/rules/*.md ~/.codex/languages/*.md
```

In each tool:

* **Claude Code:** `/memory` lists `~/.claude/CLAUDE.md`. `/doctor
  prompt-audit` reports conflicts between instruction files. An
  `InstructionsLoaded` hook reports `load_reason: "path_glob_match"` when a
  language file loads.
* **Codex:** a new session can quote the "Global instructions" heading, and
  after it edits a `.py` file it can quote the "Python" heading.
* **Antigravity:** `agy -p` can quote the same headings; the CLI has no
  `/memory` command. In the App and the IDE, ask the agent for the first
  heading of its global rules, and for the "Python" heading after it opens a
  `.py` file.
