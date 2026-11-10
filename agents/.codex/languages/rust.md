---
paths:
  - "**/*.rs"
trigger: glob
globs: "**/*.rs"
description: "Rust coding rules for writing and reviewing Rust code."
---

<!--
rust.md: Rust rules from the global agent instructions, loaded only when the
agent works on Rust files; agents/README.md documents the mechanism. Claude
Code reads only `paths`; Antigravity reads `trigger`, `globs`, and
`description` and silently drops the rule if `trigger` is missing or invalid.
Quote every glob that starts with `*`. Keep the frontmatter free of comments.
-->

# Rust

* Follow the [Rust Style Guide](https://doc.rust-lang.org/style-guide/).
