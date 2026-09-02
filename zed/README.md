# Zed

[Zed](https://zed.dev) is the GUI editor used alongside Neovim. It is
configured as a **normal, non-modal editor** — deliberately not vim-like.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" zed
```

**`--no-folding` is required** so `~/.config/zed/` stays a real directory —
Zed writes `conversations/`, `themes/` and `prompts/` there, none of which
belong in this repo.

## Edit this file, not Zed's UI

`settings.json` is a symlink into this repo. Changing a setting through Zed's
settings UI rewrites the file, which may replace the symlink with a real file
and strip the comments. If that happens:

```sh
stow -R --no-folding --target="$HOME" --dir="$HOME/personal/dotfiles" zed
```

The file is **JSONC** — JSON with `//` comments — which is what makes it
self-documenting.

## What's configured

| Area             | Choice                                                              | Why                                                                                    |
| ---------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Editor font      | `JetBrains Mono` + fallbacks, 14pt, **ligatures on**                | Plain build: Zed has its own UI icons, so the Nerd build buys nothing in the code pane |
| Terminal font    | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, **ligatures off** | Neovim runs in here and draws icon glyphs; command output should show exact characters |
| Theme            | `system` → Catppuccin Latte / Catppuccin Macchiato                  | Follows macOS, like the rest of the stack                                              |
| Icon theme       | `system` → Catppuccin Latte / Catppuccin Macchiato                  | Same object form as the theme — VS Code's equivalent cannot do this                    |
| Indentation      | 4 spaces, no hard tabs                                              | Matches Neovim's `expandtab` + `shiftwidth = 4`                                        |
| `format_on_save` | `off`                                                               | Matches Neovim, where formatting is a manual `<leader>F`                               |
| Inlay hints      | on                                                                  | Unlike Neovim, where they sit behind a `<leader>ti` toggle                             |
| Minimap          | `auto`                                                              | Shown only when a file is long enough to be worth it                                   |
| Panels           | navigation left, agent right                                        | The two never compete for the same space                                               |
| Telemetry        | off                                                                 | —                                                                                      |

Not enabled, by explicit choice: `vim_mode` and `relative_line_numbers`.

## Extensions

Zed is the only editor here that can install its own extensions declaratively:
`auto_install_extensions` in `settings.json` is the whole mechanism, so a fresh
machine needs nothing done by hand. Visual Studio Code and Cursor have no
equivalent, which is why they carry separate `.txt` lists — see
[`../vscode/README.md`](../vscode/README.md).

Nine are declared, and the ids are exactly the directory names under
`~/Library/Application Support/Zed/extensions/installed`:

| Extension | Provides |
| --- | --- |
| `catppuccin` | The four flavour themes the `theme` block names |
| `catppuccin-icons` | The four icon themes the `icon_theme` block names |
| `dockerfile` | Dockerfile grammar + `docker-language-server` |
| `neocmake` | CMake grammar + `neocmakelsp` |
| `xml` | XML grammar |
| `toml` | TOML grammar |
| `swift` | Swift grammar + `sourcekit-lsp` |
| `package-swift-lsp` | `Package.swift` manifests specifically |
| `git-firefly` | `.gitconfig`, `.gitattributes`, rebase todos, commit messages |

The five language extensions are the counterpart of entries in
[`../nvim/.config/nvim/lua/languages.lua`](../nvim/.config/nvim/lua/languages.lua),
which was brought to match. Zed covers C, Rust, Python and Markdown built in,
so those need no declaration.

## Known gaps

* **XML gets a language server here but not in Neovim.** This extension and VS
  Code's `redhat.vscode-xml` both bundle lemminx; `nvim-lspconfig` can use
  lemminx too, but it has no Homebrew formula, so Neovim's XML entry is
  treesitter-only. The asymmetry is deliberate and documented in both places.
* `.m` / `.mm` are mapped to **C++** because Zed has no first-class
  Objective-C support. Neovim handles them properly as `objc` / `objcpp` via
  clangd, so the same file gets better treatment there.
* On **Linux, Zed is not installed by Homebrew** — it is a cask, and casks are
  macOS-only. `install.sh` uses your package manager, which has Zed only on
  Arch; elsewhere it points you at <https://zed.dev/download>.
* `agent_servers`, `edit_predictions` and `proxy` from the previous live
  settings were **not** carried over. Zed has no include mechanism, so unlike
  fish and git there is no local-overlay escape hatch — re-add them here if you
  want them back.

## Recipes

### Per-language overrides
```jsonc
"languages": { "Rust": { "tab_size": 2, "format_on_save": "on" } }
```

### Full settings reference
<https://zed.dev/docs/configuring-zed>
