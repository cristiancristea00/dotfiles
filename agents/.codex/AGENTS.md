<!--
AGENTS.md: global instructions for Claude Code, Codex, and Gemini CLI, stowed
from agents/ in the dotfiles repository as ~/.claude/CLAUDE.md,
~/.codex/AGENTS.md, and ~/.gemini/GEMINI.md; agents/README.md documents it.
Gemini CLI treats an unquoted `@` path as an import: keep every `@` in
backticks and use no imports.
-->

# Global instructions

These apply in every repository, and the user's messages override any of
them. A project's instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`),
contributing guide, and formatter and linter configuration override the Code
and Languages sections and the commit message format; the other rules here
apply regardless.

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
* In a run where no one can answer, such as `claude -p`, `codex exec`, or CI,
  make no changes and end with the questions.
* Use subagents whenever they help, including for parallel research and for
  reviewing your own work. Give them your own model and reasoning effort; a
  Claude Fable session gives them Opus at the same effort.

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
* Where the project sets no style, follow the language guides below, then the
  matching [Google style guide](https://google.github.io/styleguide/). Run the
  project's formatter on the files you change.
* Comments explain why the code is written this way: a constraint, a
  trade-off, or a failure it prevents. Do not restate what the code does, and
  do not add comments to code you did not change.
* Doc comments on public APIs state the contract a caller needs: purpose,
  parameters, return value, errors, and preconditions, in as few words as that
  takes.

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

### C++ and C

* Write new code in C++; use C only to change existing C code or where the
  target requires it.
* Follow the
  [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
  and the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).
  Where they disagree, such as on exceptions and RTTI, ask which one the
  project follows.

### Swift, Objective-C, and Objective-C++

* Write new code in Swift; use Objective-C or Objective-C++ only to change
  existing code in those languages or where Swift cannot be used.
* Swift follows the
  [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
  and the [Google Swift Style Guide](https://google.github.io/swift/).
* Objective-C follows the
  [Google Objective-C Style Guide](https://google.github.io/styleguide/objcguide.html).

### Rust

* Follow the [Rust Style Guide](https://doc.rust-lang.org/style-guide/).

### Python

* Follow [PEP 8](https://peps.python.org/pep-0008/) and the
  [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html),
  including its docstring format (`Args:`, `Returns:`, `Raises:`).
* Annotate every parameter, return value, module-level and class attribute,
  and each local variable whose type the checker cannot infer. Leave no errors
  from the project's type checker.
