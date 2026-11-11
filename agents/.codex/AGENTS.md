<!--
AGENTS.md: global instructions for Claude Code, Codex, and Antigravity, stowed
from agents/ in the dotfiles repository as ~/.claude/CLAUDE.md,
~/.codex/AGENTS.md, and ~/.gemini/AGENTS.md; agents/README.md documents it.
The per-language rules live in languages/*.md beside this file.
Claude Code and Antigravity treat an unquoted `@` path as an import or file
reference: keep every `@` in backticks and use no imports.
-->

# Global instructions

These apply in every repository, and the user's messages override any of
them. A project's instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`),
contributing guide, and formatter and linter configuration override the Code
and Languages sections, the language files, and the commit message format;
the other rules here apply regardless.

## Working with the user

* Before any task that changes files, however small, ask one round of
  questions about the requirements, scope, and design choices that the request
  and the code leave open, and wait for the answers. The user prefers answering
  questions to correcting a wrong guess. If nothing is open, state how you read
  the task and ask for confirmation.
* Look facts up in the code, its documentation, or on the web instead of asking
  about them. Check APIs, flags, and versions against current official
  documentation rather than memory.
* Once the questions are answered, work to the end without further check-ins
  unless a new open choice appears.
* In a run where no one can answer, such as `claude -p`, `codex exec`,
  `agy -p`, or CI, make no changes and end with the questions.
* Use subagents whenever they help, including for parallel research and for
  reviewing your own work. Give them your own model and reasoning effort.
* In a Claude Fable session, act only as the orchestrator: ask the questions,
  plan, brief agents, read files to brief them and to check their output, and
  commit. Give all research and every edit, however small, to Opus agents one
  reasoning effort level above yours, up to `xhigh`: `medium` gives `high`, and
  `high`, `xhigh`, or `max` gives `xhigh`. Review their work yourself instead
  of giving the review to another agent.

## Writing

* Write comments, documentation, commit messages, and replies in plain, direct
  prose. State each fact once, in literal words, without metaphor, flourish,
  rhetorical framing, or filler. Figurative wording makes the reader decode it
  and carries meanings the writer did not choose.
* Use British English with the Oxford comma: colour, initialise, "a, b, and c".
  Identifiers, flags, and keys keep their own spelling.
* Keep replies short and lead with the result.

## Code

* Change only what the task needs. Leave unrelated code as it is, and mention
  problems you notice in it instead of fixing them.
* Write the lines you add or change in the modern, idiomatic form of the
  language, using the newest features the project's maximum supported version
  allows, even where the surrounding code uses older patterns.
* Read that version from the build configuration: `CMAKE_CXX_STANDARD` or
  `cxx_std_*` in CMake, `requires-python` in `pyproject.toml`, `edition` and
  `rust-version` in `Cargo.toml`, `swift-tools-version` in `Package.swift`,
  `SWIFT_VERSION` in an Xcode project. If the project pins none, ask which
  version to target.
* Name identifiers in full words: `buffer`, not `buf`; `index`, not `i`;
  `Element`, not `T`. Keep an abbreviation only where it is better known than
  its expansion, such as `pid`, `ppid`, `id`, or `url`.
* Use no Hungarian notation and no prefix or suffix that marks scope or type:
  no `m`, `m_`, `g_`, `s_`, `k`, `p`, or leading or trailing `_`. Keep an
  underscore only where the language or its tools act on it: Python's
  `_internal`, `__mangled`, and `__dunder__` names, Dart's `_private` names,
  Rust's `_unused` bindings, and a trailing `_` that avoids a keyword, as in
  `class_`.
* Name enum cases `PascalCase` in every language except Swift, whose cases
  stay lowerCamelCase: `FileState::Idle`. Put the enum's name in front of the
  values of an unscoped enum, as in C and Objective-C: `FileStateIdle`,
  `BDFileStateIdle`.
* Identifiers you add follow the naming rules here and in the language files
  even where the surrounding code uses another scheme. Only the sources the
  opening paragraph names override them.
* Put braces around every `if`, `else`, `for`, `while`, and `do` body, even a
  single statement, in every language where they are optional, whatever its
  style guide allows. A one-statement body may stay on the condition's line:
  `if (done) { return; }`.
* In every language where a mistyped `=` in a condition still compiles, put
  the constant on the left of `==` and `!=`: `nullptr == pointer`,
  `0U == count`. A function call stays on the left: `Read(buffer) == -1`.
* In every language with a `final` modifier, mark as `final`, wherever the
  language allows it, every variable, field, and parameter that is not
  reassigned, every class not designed as a base class, and every method or
  override not meant to be overridden again.
* Group related values in a named struct, not a pair or tuple, in every
  return type, parameter, field, and container element you define. Unpack a
  pair or tuple that a library returns as soon as you receive it:
  `auto const& [key, value]`, `for (key, value) in dictionary`.
* Use blank lines to make code easier to read. Inside a function, put one
  after each group of statements that does one step and after each group of
  declarations, one before and after each multi-line `if`, loop, or `switch`,
  and one before a `return` that follows other statements. Never put two
  blank lines in a row.
* Where the project sets no style, follow that language's file, then the
  matching [Google style guide](https://google.github.io/styleguide/). Run the
  project's formatter on the files you change.
* Comments explain why the code is written this way: a constraint, a
  trade-off, or a failure it prevents. Do not restate what the code does, and
  do not add comments to code you did not change.
* Doc comments on public APIs state the contract a caller needs: purpose,
  parameters, return value, errors, and preconditions, in as few words as that
  takes.
* Log important events through the project's logger, not with `print`,
  `printf`, `std::cout`, or `NSLog`. Without one, use the platform's logger:
  Python's `logging`, `os_log` or `Logger` on Apple platforms, and `syslog`
  elsewhere. Log errors and failed operations at error level, recoverable
  problems and fallbacks at warning, start, stop, and state changes at info,
  and diagnostic values at debug. Never log secrets, credentials, or personal
  data.
* Give every atomic operation an explicit memory order: acquire for loads,
  release for stores, and acquire-release for read-modify-write operations
  such as exchange, fetch-and-add, and compare-and-exchange, whose failure
  order is acquire. Apply this to every atomic operation you write, and to a
  sequentially consistent one, written or by default, on a line you change.
  Use relaxed only for a counter or statistic that no other memory access
  depends on, and sequential consistency only where a store must stay
  ordered before a later load of another atomic or all threads must agree on
  one order of operations, as in Dekker's algorithm. Explain either
  exception in a comment.

## Commits

* Commit each finished change without being asked. Never push, and never amend
  or rebase commits that existed before the task.

```text
<scope>: <Imperative summary>

<Body>

Fixes PROJ-123
Related to PROJ-456
```

* The scope is required: one word naming the component, module, or directory
  changed, or `treewide` for a change across the whole project. There is no
  type prefix.
* The summary is in the imperative mood, starts with a capital letter, and has
  no trailing period. No line, subject or body, exceeds 80 characters.
* For a feature, the body says what the feature does and why it is needed, not
  how it is implemented.
* For a fix or an improvement, the body states the bug or request, its root
  cause, and how the change resolves it, not a list of the edits.
* The body may have several paragraphs, and a bullet list where the content is
  a set of parallel items.
* End with one line per related issue: `Fixes PROJ-123` for an issue the
  commit resolves, `Related to PROJ-123` for one it only touches. Ask for the
  key when the task has an issue you do not know; omit the lines when there is
  none.
* Add `Signed-off-by` only when the project requires it.

## Languages

* Write new code in C++; use C only to change existing C code or where the
  target requires it.
* Write new code in Swift; use Objective-C or Objective-C++ only to change
  existing code in those languages or where Swift cannot be used.
* C++ and C, Swift and Objective-C, Rust, and Python each have a language
  file. Before you write or review code in one of these languages, read its
  file unless its rules are already in your context:
  * C++ and C: `~/.codex/languages/cpp.md`
  * Swift, Objective-C, and Objective-C++: `~/.codex/languages/swift.md`
  * Rust: `~/.codex/languages/rust.md`
  * Python: `~/.codex/languages/python.md`
