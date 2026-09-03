# Zed

[Zed](https://zed.dev) is the GUI editor used alongside Neovim. It is
configured as a non-modal editor; `vim_mode` is not enabled.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" zed
```

Stow's `--no-folding` keeps `~/.config/zed/` a real directory, because Zed
writes `conversations/`, `themes/`, and `prompts/` there. See
[The stow model](../README.md#the-stow-model).

## Edit this file, not Zed's UI

`settings.json` is a symlink into this repo. Changing a setting through Zed's
settings UI rewrites the file, which can replace the symlink with a real file
and strip the comments. If that happens:

```sh
stow -R --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" zed
```

The file is JSONC (JSON with `//` comments), so it can carry its own
documentation.

## What's configured

| Area             | Choice                                                          | Why                                                                                          |
| ---------------- | --------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Editor font      | `JetBrains Mono` + fallbacks, 14pt, ligatures on                | The plain build: Zed draws its own UI icons; see [The font stack](../README.md#the-font-stack) |
| Terminal font    | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, ligatures off | Neovim runs in here and draws icon glyphs; command output shows the exact characters          |
| Theme            | `system` → Catppuccin Latte / Catppuccin Mocha                  | Follows the system appearance; see [Light and dark](../README.md#light-and-dark)             |
| Icon theme       | `system` → Catppuccin Latte / Catppuccin Mocha                  | Same object form as the theme, so the icons follow the appearance                            |
| Indentation      | 4 spaces, no hard tabs                                          | Matches Neovim's `expandtab` + `shiftwidth = 4`                                              |
| `format_on_save` | `off`, the default                                              | Neovim (`<leader>F`) and VS Code also format only on request                                 |
| Inlay hints      | on                                                              | Matches VS Code; Neovim keeps them behind a `<leader>ti` toggle                              |
| Cursor           | blinking block, editor and terminal                             | Same as every other tool; see [The cursor](../README.md#the-cursor)                          |
| Minimap          | `auto`                                                          | Shown whenever the scrollbar is visible                                                      |
| Panels           | navigation left, agent right                                    | The two do not share one dock                                                                |
| Telemetry        | off                                                             | Both metrics and diagnostics                                                                 |

Not enabled: `vim_mode` and `relative_line_numbers`.

## Extensions

Zed is the only editor here that installs its own extensions declaratively:
`auto_install_extensions` in `settings.json` lists them, so a fresh machine
needs no manual step. Visual Studio Code and Cursor have no equivalent, which
is why they carry `.txt` lists; see [Extensions](../vscode/README.md#extensions).

Ten are declared. The ids are the directory names under
`~/Library/Application Support/Zed/extensions/installed`:

| Extension           | Provides                                                      |
| ------------------- | ------------------------------------------------------------- |
| `catppuccin`        | The four flavour themes the `theme` block names               |
| `catppuccin-icons`  | The four icon themes the `icon_theme` block names             |
| `dockerfile`        | Dockerfile grammar and `docker-language-server`               |
| `neocmake`          | CMake grammar and `neocmakelsp`                               |
| `xml`               | XML grammar                                                   |
| `zig`               | Zig grammar and `zls`                                         |
| `toml`              | TOML grammar                                                  |
| `swift`             | Swift grammar and `sourcekit-lsp`                             |
| `package-swift-lsp` | `Package.swift` manifests                                     |
| `git-firefly`       | `.gitconfig`, `.gitattributes`, rebase todos, commit messages |

Go needs no extension: Zed's documentation states that Go support is built
in, and the registry has no `go` entry. Zed does not bundle `gopls`, so it
uses the one on `$PATH`, which the Brewfile installs.

The language extensions are the counterpart of entries in
[`languages.lua`](../nvim/.config/nvim/lua/languages.lua). Zed covers C,
Rust, Python, and Markdown built in, so those need no declaration.

## Known gaps

* **XML has no language server here or in Neovim.** The `xml` extension is a
  grammar only, and lemminx, the server VS Code's `redhat.vscode-xml` bundles,
  has no Homebrew formula. The XML entry in `languages.lua` says how to add
  it to Neovim.
* **`.m` and `.mm` are mapped to C++** because Zed has no Objective-C
  support. Neovim handles them as `objc` and `objcpp` with clangd.
* **On Linux, Zed is not installed by Homebrew.** It is a cask, and casks are
  macOS-only. `install.sh` uses the system package manager, which has Zed only
  on Arch; elsewhere it prints <https://zed.dev/download>.
* **No local overlay.** Zed has no include mechanism, so unlike fish and git
  there is no uncommitted file for machine-specific settings; they go in this
  file.

## Recipes

* **Per-language overrides.**
  `"languages": { "Rust": { "tab_size": 2, "format_on_save": "on" } }`
* **Full settings reference.** <https://zed.dev/docs/configuring-zed>
