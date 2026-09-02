# Zed

[Zed](https://zed.dev) is the GUI editor used alongside Neovim. It is
configured as a **normal, non-modal editor** — deliberately not vim-like.

## Install

```sh
stow --no-folding --target="$HOME" --dir="$HOME/work/dotfiles" zed
```

**`--no-folding` is required** so `~/.config/zed/` stays a real directory —
Zed writes `conversations/`, `themes/` and `prompts/` there, none of which
belong in this repo.

## Edit this file, not Zed's UI

`settings.json` is a symlink into this repo. Changing a setting through Zed's
settings UI rewrites the file, which may replace the symlink with a real file
and strip the comments. If that happens:

```sh
stow -R --no-folding --target="$HOME" --dir="$HOME/work/dotfiles" zed
```

The file is **JSONC** — JSON with `//` comments — which is what makes it
self-documenting.

## What's configured

| Area             | Choice                                                              | Why                                                                                    |
| ---------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Editor font      | `JetBrains Mono` + fallbacks, 14pt, **ligatures on**                | Plain build: Zed has its own UI icons, so the Nerd build buys nothing in the code pane |
| Terminal font    | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, **ligatures off** | Neovim runs in here and draws icon glyphs; command output should show exact characters |
| Theme            | `system` → Ayu Light / Ayu Dark                                     | Follows macOS, like the rest of the stack                                              |
| Indentation      | 4 spaces, no hard tabs                                              | Matches Neovim's `expandtab` + `shiftwidth = 4`                                        |
| `format_on_save` | `off`                                                               | Matches Neovim, where formatting is a manual `<leader>F`                               |
| Inlay hints      | on                                                                  | Unlike Neovim, where they sit behind a `<leader>ti` toggle                             |
| Minimap          | `auto`                                                              | Shown only when a file is long enough to be worth it                                   |
| Panels           | navigation left, agent right                                        | The two never compete for the same space                                               |
| Telemetry        | off                                                                 | —                                                                                      |

Not enabled, by explicit choice: `vim_mode` and `relative_line_numbers`.

## Coupling worth knowing

`terminal.shell.program = "fish"` is what makes `$TERM_PROGRAM` equal `zed`
inside the shell, which `fish/.config/fish/conf.d/30-prompt.fish` uses to skip
oh-my-posh (Zed draws its own prompt decorations). Change one, check the other.

## Known gaps

* `.m` / `.mm` are mapped to **C++** because Zed has no first-class
  Objective-C support. Neovim handles them properly as `objc` / `objcpp` via
  clangd, so the same file gets better treatment there.
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
