---
paths:
  - "**/*.swift"
  - "**/*.m"
  - "**/*.mm"
  - "**/*.h"
trigger: glob
globs: "**/*.swift, **/*.m, **/*.mm, **/*.h"
description: "Swift, Objective-C, and Objective-C++ coding rules."
---

<!--
swift.md: Swift, Objective-C, and Objective-C++ rules from the global agent
instructions, loaded only when the agent works on files in those languages;
agents/README.md documents the mechanism. Claude Code reads only `paths`;
Antigravity reads `trigger`, `globs`, and `description` and silently drops the
rule if `trigger` is missing or invalid. Quote every glob that starts with
`*`. Keep the frontmatter free of comments.
-->

# Swift, Objective-C, and Objective-C++

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
