---
paths:
  - "**/*.c"
  - "**/*.h"
  - "**/*.cc"
  - "**/*.cpp"
  - "**/*.cxx"
  - "**/*.hh"
  - "**/*.hpp"
  - "**/*.hxx"
  - "**/*.ipp"
  - "**/*.tpp"
  - "**/*.inl"
  - "**/*.ixx"
  - "**/*.cppm"
trigger: glob
globs: "**/*.c, **/*.h, **/*.cc, **/*.cpp, **/*.cxx, **/*.hh, **/*.hpp, **/*.hxx, **/*.ipp, **/*.tpp, **/*.inl, **/*.ixx, **/*.cppm"
description: "C++ and C coding rules for writing and reviewing C++ or C code."
---

<!--
cpp.md: C++ and C rules from the global agent instructions, loaded only when
the agent works on C++ or C files; agents/README.md documents the mechanism.
Claude Code reads only `paths`; Antigravity reads `trigger`, `globs`, and
`description` and silently drops the rule if `trigger` is missing or invalid.
Quote every glob that starts with `*`. Keep the frontmatter free of comments.
-->

# C++ and C

* Follow the
  [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
  and the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).
  Where they disagree, such as on exceptions and RTTI, ask which one the
  project follows. The naming, `const`, initialisation, `auto`, `noexcept`,
  and `override` rules below replace those of both guides.
* Name types `PascalCase`: classes, structs, unions, enums, `enum class`
  types, type aliases, concepts, and template parameters.
* Name constants and macros `UPPER_CASE`. A constant is a `constexpr`
  variable or a `const` variable at namespace scope or with `static` storage;
  a `const` local or parameter is a variable.
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
