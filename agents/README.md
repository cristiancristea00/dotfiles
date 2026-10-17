# agents

One instruction file for three AI coding agents: Claude Code, Codex, and
Gemini CLI. Each reads it as its global, user-level instructions, in every
repository. It sets the rules for asking questions, prose, code, commits, and
the language style guides.

## Where the file lives

| Path in this package | Deployed as            | Read by     | What it is                                     |
| -------------------- | ---------------------- | ----------- | ---------------------------------------------- |
| `.codex/AGENTS.md`   | `~/.codex/AGENTS.md`   | Codex       | The real file                                  |
| `.claude/CLAUDE.md`  | `~/.claude/CLAUDE.md`  | Claude Code | Committed symlink (mode `120000`) to the above |
| `.gemini/GEMINI.md`  | `~/.gemini/GEMINI.md`  | Gemini CLI  | Committed symlink (mode `120000`) to the above |

Edit `.codex/AGENTS.md`, never a link.

The real file sits under `.codex/` rather than at the package root because
stow links every file in a package. A root `AGENTS.md` would be deployed as
`~/AGENTS.md`, which Claude Code can read a second time as a parent-directory
`AGENTS.md`. The two links follow the precedent of `cursor/`, which links into
`vscode/`.

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

The file's opening paragraph gives the order:

1. The user's messages override every rule.
2. A project's instruction files, contributing guide, and formatter and linter
   configuration override the Code and Languages sections and the commit
   message format.
3. The other rules apply in every project.

The file states this because the tools do not agree on an order:

| Tool        | Built-in order                                                                                                       |
| ----------- | -------------------------------------------------------------------------------------------------------------------- |
| Claude Code | None. A conflicting user-level and project rule may be followed either way                                           |
| Codex       | Places project files after the global file, so they win                                                              |
| Gemini CLI  | Its system prompt ranks project context over global context. Its core safety mandates cannot be overridden by either |

## Length

The file is about 130 lines, blank lines included.

* Claude Code warns when an instruction file passes about 200 lines.
* OpenAI reports that shorter instructions score higher in its coding-agent
  tests.

A new rule earns its place only if an agent makes the mistake without it.

## Traps

* **Gemini treats `@` as an import.** Gemini CLI reads any `@word` preceded by
  whitespace and outside backticks as a file import. It also rejects imports
  from a global file that is a symlink into another directory. Keep every `@`
  in backticks, and use no imports.
* **Gemini saves memories into this file.** Gemini's `save_memory` tool appends
  to `~/.gemini/GEMINI.md`, which is a link to the shared file. A saved memory
  therefore appears as a diff here and reaches Claude Code and Codex too.
  Review such a diff before committing it.
* **Gemini reads only `GEMINI.md` by default.** A project's `AGENTS.md` is
  ignored unless that project sets `context.fileName` in its
  `.gemini/settings.json`.
* **Subagent model and effort are not enforced in Gemini.** The file asks for
  subagents on the main agent's model and effort. Codex does this by default,
  and Claude Code sets them per call when its instructions ask. Gemini's
  delegation tool takes no model or thinking level, and its
  `codebase_investigator` agent uses a fixed Flash model. Only
  `agents.overrides` in `~/.gemini/settings.json` changes that.
* **Unverified: Gemini and committing.** Gemini's built-in prompt says never to
  commit unless asked. It is not established whether the global file's
  "commit each finished change" rule overrides that.
* **Agent co-author trailers are set outside this file.**
  * Claude Code adds its trailer from the `attribution` setting, which managed
    settings can fix.
  * Codex adds its trailer from a ChatGPT account setting. Codex injects that
    setting's text with an instruction to ignore any earlier rule on
    attribution.
  * The file therefore says nothing about agent trailers.
* **Claude Code loads the link twice in this repo.** While it works on files
  under `agents/`, Claude Code also reads `agents/.claude/CLAUDE.md` as a
  nested project file. The second copy is the same text and does no harm.
* **Claude Code has no user-level `AGENTS.md`.** It reads `AGENTS.md` only in a
  project, so `~/.claude/CLAUDE.md` is the only global path.
* **Cowork skips a symlinked `~/.claude/CLAUDE.md`.** Cowork sessions in the
  Claude desktop app do not load this link. They also skip user-level imports
  that resolve outside the working directory. Claude Code in the terminal and
  in the desktop app's Code tab reads the link.

## Documented extension points (inactive)

* **A Gemini `settings.json`.** Stowing `~/.gemini/settings.json` with the
  following would make Gemini read project `AGENTS.md` files too:

  ```json
  { "context": { "fileName": ["GEMINI.md", "AGENTS.md"] } }
  ```

  With it, the shared file would be linked as `~/.gemini/AGENTS.md`. Gemini
  writes saved memories to the first name in the list, so they would go to a
  local `~/.gemini/GEMINI.md` instead of the repo. The same file could carry
  `agents.overrides` for subagent models. It is not used because Gemini also
  writes `settings.json` itself (the authentication choice, `/settings`
  changes), and through the link those writes would land in the repo.

## Verifying a change

```sh
git ls-files -s agents                                  # both links are mode 120000
grep -nE '(^|[[:space:]])@' agents/.codex/AGENTS.md     # empty: no unquoted @
readlink -f ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.gemini/GEMINI.md
```

In each tool:

* **Claude Code:** `/memory` lists `~/.claude/CLAUDE.md`. `/doctor
  prompt-audit` reports conflicts between instruction files.
* **Codex:** a new session can quote the "Global instructions" heading.
* **Gemini CLI:** `/memory show` prints the file.
