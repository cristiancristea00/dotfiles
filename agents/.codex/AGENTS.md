<!--
AGENTS.md: global instructions for Claude Code, Codex, and Antigravity, stowed
from agents/ in the dotfiles repository as ~/.claude/CLAUDE.md,
~/.codex/AGENTS.md, and ~/.gemini/AGENTS.md; agents/README.md documents it.
Claude Code and Antigravity treat an unquoted `@` path as an import or file
reference: keep every `@` in backticks and use no imports.
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
* In a run where no one can answer, such as `claude -p`, `codex exec`,
  `agy -p`, or CI, make no changes and end with the questions.
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
* Name identifiers in full words: `buffer`, not `buf`; `index`, not `i`;
  `Element`, not `T`. Keep an abbreviation only where it is better known than
  its expansion, such as `pid`, `ppid`, `id`, or `url`.
* Use no Hungarian notation and no prefix or suffix that marks scope or type:
  no `m`, `m_`, `g_`, `s_`, `k`, `p`, or leading or trailing `_`. Keep an
  underscore only where the language or its tools act on it: Python's
  `_internal`, `__mangled`, and `__dunder__` names, Dart's `_private` names,
  Rust's `_unused` bindings, and a trailing `_` that avoids a keyword, as in
  `class_`.
* Identifiers you add follow the naming rules here and under Languages even
  where the surrounding code uses another scheme. Only the sources the opening
  paragraph names override them.
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
* Use blank lines to make code easier to read. Inside a function, put one
  after each group of statements that does one step and after each group of
  declarations, one before and after each multi-line `if`, loop, or `switch`,
  and one before a `return` that follows other statements. Never put two
  blank lines in a row.
* Where the project sets no style, follow the language guides below, then the
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
  project follows. The naming, `const`, initialisation, `auto`, `noexcept`,
  and `override` rules below replace those of both guides.
* Name types `PascalCase`: classes, structs, unions, enums, `enum class`
  types, type aliases, concepts, and template parameters.
* Name constants, enumerators, and macros `UPPER_CASE`. A constant is a
  `constexpr` variable or a `const` variable at namespace scope or with
  `static` storage; a `const` local or parameter is a variable.
* Name free functions, including `static` ones, and static member functions
  `PascalCase`; name non-static member functions `camelCase`. Every function
  in C is therefore `PascalCase`.
* Name variables, parameters, and data members `camelCase`, and namespaces
  `snake_case`.
* Keep code `const`-correct. Make every variable, pointer or reference
  target, and member function `const` when it is not modified. Data members
  of copyable or movable types and by-value return types are the exception,
  because `const` there stops the object from being moved or assigned.
* Never remove `const` with `const_cast` or a C-style cast, except to pass an
  argument to a C API that lacks `const` and does not write through it. Use
  `mutable` only for state that does not change the object's observable
  value, such as a mutex or a cache.
* Write `const` after what it qualifies: `int const`, `std::string const&`,
  `char const* const`. The `constexpr` and `static` specifiers stay before the
  type.
* Initialise every C++ variable, data member, and `auto` declaration with
  braces instead of `=`: `auto count{0U}`, `auto name{GetName()}`. Write the
  value even when it is zero, and leave the braces empty only for a class
  type: `std::string name{}`. Use parentheses only where braces would select
  an `std::initializer_list` constructor: `std::vector<int> values(10, 0)`.
* Declare a C++ variable `auto` whenever its initialiser determines the type,
  as in the examples above. Keep the type on the left when the initialiser
  does not determine it: `std::string name{}`.
* Declare every C++ function and lambda with `auto` and a trailing return
  type, `void` included: `auto Run() -> void`, `[](int value) -> int { … }`.
  Constructors, destructors, and conversion operators have no return type.
* Give every integer and floating-point literal the upper-case suffix of its
  type: `0U`, `0L`, `0UL`, `0ULL`, `1.0F`, and `0UZ` from C++23. A literal of
  type `int` or `double` has none. In C++, use the standard-library literals
  where a library type is meant: `"text"s`, `"text"sv`, `100ms`.
* Make a function `consteval` when its result is only ever needed at compile
  time, and `constexpr` when it can also run at run time. Make every variable
  whose value is known at compile time `constexpr`. In C, `constexpr` applies
  to objects only and needs C23.
* Mark a C++ function `noexcept` when it cannot throw, or when the only
  exception it can throw is `std::bad_alloc`, from which the program does not
  recover. Destructors, move operations, and `swap` are always `noexcept`. A
  template whose throwing depends on its arguments uses a conditional
  `noexcept(…)`.
* Mark every C++ function that returns a value `[[nodiscard]]`, operators
  included. Apply `[[noreturn]]`, `[[fallthrough]]`, `[[maybe_unused]]`, and
  `[[no_unique_address]]` wherever they fit, `[[likely]]` and `[[unlikely]]`
  on every branch whose frequency is known, such as an error path, and
  `[[deprecated]]` only when deprecating. Do not use `[[assume]]`: a false
  assumption is undefined behaviour.
* Write every overriding function with `override` and never with `virtual`.
  Add `final` after `override` when the function must not be overridden
  again: `auto draw() -> void override final;`.

### Swift, Objective-C, and Objective-C++

* Write new code in Swift; use Objective-C or Objective-C++ only to change
  existing code in those languages or where Swift cannot be used.
* Swift follows the
  [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
  and the [Google Swift Style Guide](https://google.github.io/swift/).
  The `.init(…)` and `self.` rules below replace that guide's.
* Write Swift initialisers, enum cases, and static members without the type
  name: `.init(path: path)`, `.timeout`, and `case .timeout:`, not
  `FileMonitor(path: path)` or `DispatchTimeoutResult.timeout`. Where the
  context does not give the type, add a type annotation:
  `let monitor: FileMonitor = .init(path: path)`. Where the type has a static
  member for the value, use it instead of `.init()`: `.now`, `.zero`,
  `.infinity`, and the shared `.default`, `.main`, `.standard`, and `.current`
  instances, as in `let start: Date = .now`.
* Refer to every instance member with `self.` and every type member with
  `Self.`, in classes, structs, enums, actors, and their extensions:
  `self.path`, `self.reload()`, `Self.defaultPath`.
* Objective-C follows the
  [Google Objective-C Style Guide](https://google.github.io/styleguide/objcguide.html).
* Write Objective-C and Objective-C++ with ARC, properties and dot syntax,
  literals and subscripting (`@[]`, `@{}`, `@()`, `array[0]`), lightweight
  generics (`NSArray<NSString *> *`), nullability annotations,
  `instancetype`, `NS_ENUM`, `NS_OPTIONS`, and `@import` modules.
* Where an implementation uses a property's instance variable directly,
  write `@synthesize lastChangeTimes;`, never
  `@synthesize lastChangeTimes = _lastChangeTimes;`.
* Give classes, protocols, and exported functions the project's two- or
  three-letter prefix, which prevents name collisions in a language without
  namespaces. Name constants `UPPER_CASE`, without `k`.
* Leave one blank line after the line that opens an `@interface`,
  `@implementation`, or `@protocol`, and one before its `@end`.
* Order the declarations in an `@interface` and an `@implementation` as
  properties, initialisers followed by `dealloc`, class methods including
  factory methods, and instance methods, with one blank line between groups.

### Rust

* Follow the [Rust Style Guide](https://doc.rust-lang.org/style-guide/).

### Python

* Follow [PEP 8](https://peps.python.org/pep-0008/) and the
  [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html),
  including its docstring format (`Args:`, `Returns:`, `Raises:`).
* Annotate every parameter, return value, module-level and class attribute,
  and each local variable whose type the checker cannot infer. Leave no errors
  from the project's type checker.
* Apply the `final` rule under Code with `typing.Final` on variables and
  attributes and `@typing.final` on classes and methods. Parameters cannot be
  `Final`.
