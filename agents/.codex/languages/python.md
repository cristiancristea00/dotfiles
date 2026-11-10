---
paths:
  - "**/*.py"
  - "**/*.pyi"
trigger: glob
globs: "**/*.py, **/*.pyi"
description: "Python coding rules for writing and reviewing Python code."
---

<!--
python.md: Python rules from the global agent instructions, loaded only when
the agent works on Python files; agents/README.md documents the mechanism.
Claude Code reads only `paths`; Antigravity reads `trigger`, `globs`, and
`description` and silently drops the rule if `trigger` is missing or invalid.
Quote every glob that starts with `*`. Keep the frontmatter free of comments.
-->

# Python

* Follow [PEP 8](https://peps.python.org/pep-0008/) and the
  [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html),
  including its docstring format (`Args:`, `Returns:`, `Raises:`).
* Annotate every parameter, return value, module-level and class attribute,
  and each local variable whose type the checker cannot infer. Leave no errors
  from the project's type checker.
* Apply the `final` rule in the Code section of the global instructions with
  `typing.Final` on variables and attributes and `@typing.final` on classes
  and methods. Parameters cannot be `Final`.
* Write the named struct that the Code section of the global instructions
  asks for as a `@dataclasses.dataclass` or a `typing.NamedTuple`.
