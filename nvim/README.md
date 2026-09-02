# Neovim + Neovide configuration

A modern Neovim (≥ 0.12) configuration built on **built-in machinery first**:
plugins are managed by Neovim's native [`vim.pack`](https://neovim.io/doc/user/pack.html)
(no plugin-manager plugin), language servers run through the native
`vim.lsp.config()` / `vim.lsp.enable()` API, and syntax comes from the
rewritten nvim-treesitter `main` branch. Tightly integrated with
[Neovide](https://neovide.dev), rendered in JetBrains Mono Nerd Font Mono.

Every option in every file is documented in place — *what it does, why this
value, how to change it*. This README covers installation, the map of the
config, and the common "how do I…" recipes.

---

## Installation

```sh
# 1. Back up anything already in place (Neovim's state in ~/.local is separate
#    and untouched).
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null

# 2. Install the dependencies: fonts, stow, language servers, formatters.
brew bundle --file ~/work/dotfiles/Brewfile

# 3. Symlink both halves of the setup into place with GNU stow.
stow --target="$HOME" --dir="$HOME/work/dotfiles" nvim neovide

# 4. First launch: vim.pack asks to install the plugins — answer y.
#    Treesitter parsers compile in the background; reopen files (:e) once done.
nvim

# 5. Sanity check.
nvim "+checkhealth vim.pack vim.lsp nvim-treesitter"
```

Then launch **Neovide** normally — it picks up this config and its
`vim.g.neovide_*` tuning automatically.

The Neovide integration has two halves:
`../neovide/.config/neovide/config.toml` handles process/window creation
(frame style, the font used before Neovim loads, vsync/sRGB), while
`lua/core/neovide.lua` handles runtime behaviour (animations, ⌘ keymaps,
zoom). Font family and size must be kept in sync across **both** — and, if you
change the font stack, across `../ghostty/` and `../zed/` too. The root
[README](../README.md) has the whole matrix.

> **Commit `nvim-pack-lock.json`** when it appears next to `init.lua`: it pins
> exact plugin versions, making this setup reproducible on a fresh machine.

---

## Map of the config

| Path                                    | Purpose                                                                      |
| --------------------------------------- | ---------------------------------------------------------------------------- |
| `.config/nvim/init.lua`                 | Entry point: leader keys + module load order                                 |
| `.config/nvim/lua/core/options.lua`     | Editor options (every one documented)                                        |
| `.config/nvim/lua/core/keymaps.lua`     | Plugin-independent keymaps                                                   |
| `.config/nvim/lua/core/autocmds.lua`    | Yank highlight, cursor restore, etc.                                         |
| `.config/nvim/lua/core/diagnostics.lua` | How errors/warnings are displayed                                            |
| `.config/nvim/lua/core/neovide.lua`     | Font + Neovide runtime settings + ⌘ keymaps                                  |
| `../neovide/`                           | Neovide process/window settings — see its own [README](../neovide/README.md) |
| `.config/nvim/lua/theme.lua`            | Colorscheme (single-variable switch)                                         |
| `.config/nvim/lua/languages.lua`        | **The language table — add/remove languages here**                           |
| `.config/nvim/lua/plugins/init.lua`     | Plugin declarations (`vim.pack`) + load order                                |
| `.config/nvim/lua/plugins/<name>.lua`   | One documented config module per plugin                                      |
| `.config/nvim/after/lsp/<server>.lua`   | Per-server LSP overrides (native `:h lsp-config-merge`)                      |
| `../Brewfile`                           | All external dependencies, for every tool in the repo                        |

**Plugins** (10): nvim-lspconfig (server config data), nvim-treesitter,
fzf-lua, neo-tree (+ plenary, nui, nvim-web-devicons), blink.cmp, lualine,
gitsigns, conform, indent-blankline.

---

## Recipes

### Add a language
1. Add an entry to `lua/languages.lua` (filetypes, parsers, servers,
   formatters — the file header documents each field).
2. Add its LSP server to the root `../Brewfile`, re-run `brew bundle`.
3. Restart Neovim. Done — parser installation, highlighting, LSP activation
   and formatting routing all derive from the table.

### Remove a language
Delete its entry from `lua/languages.lua`. Optionally
`:lua require("nvim-treesitter").uninstall({"<parser>"})` and remove the
server from the root `../Brewfile`.

### Add / remove a plugin
Three places, all in `lua/plugins/`: the spec in `init.lua`'s
`vim.pack.add()` list, a `<name>.lua` config module, and its `require` line.
Remove in reverse, then `:lua vim.pack.del({"<name>"})`. Update everything
with `:lua vim.pack.update()` (review buffer: `:write` applies, `:quit`
rejects).

### Change the theme
See `lua/theme.lua` — add the theme plugin spec, flip one variable. The
statusline follows automatically.

### Change font or font size
Four places across the repo, kept in sync — see the font matrix in the root
[README](../README.md). Within this package it is the `vim.o.guifont` line in
`.config/nvim/lua/core/neovide.lua`; its companion is the `[font]` section of
`../neovide/.config/neovide/config.toml`, which covers Neovide's first frames
before `init.lua` runs. Live zoom: `⌘=` / `⌘-` / `⌘0`.

### Reorder / extend the statusline
`lua/plugins/statusline.lua` — the six `lualine_a`–`z` lists *are* the layout.

### Per-project / per-filetype settings
Neovim honors `.editorconfig` natively. For editor-side overrides create
`.config/nvim/after/ftplugin/<filetype>.lua` (e.g. `vim.bo.shiftwidth = 2`
for YAML).

---

## Keymap reference

Leader = **Space**. `<leader>fk` fuzzy-searches this whole list at runtime.

### Find (fzf-lua)
| Key                 | Action                          |
| ------------------- | ------------------------------- |
| `<leader>ff` / `fg` | find files / live grep          |
| `<leader>fw`        | grep word under cursor          |
| `<leader>fb` / `fo` | buffers / recent files          |
| `<leader>fh` / `fk` | help topics / keymaps           |
| `<leader>fd` / `fD` | diagnostics: buffer / workspace |
| `<leader>fr`        | LSP references                  |
| `<leader>fs` / `fS` | LSP symbols: buffer / workspace |
| `<leader>fR`        | resume last picker              |

### LSP (buffer-local, when a server is attached)
| Key                   | Action                                              |
| --------------------- | --------------------------------------------------- |
| `K`                   | hover documentation *(built-in)*                    |
| `gd` / `gD`           | definition / declaration                            |
| `grn` / `gra`         | rename / code action *(built-in)*                   |
| `grr` / `gri` / `grt` | references / implementation / type def *(built-in)* |
| `gO`                  | document outline *(built-in)*                       |
| `<C-s>` (insert)      | signature help *(built-in)*                         |
| `<leader>ti`          | toggle inlay hints                                  |
| `<leader>ch`          | clangd: switch source/header                        |

### Git (gitsigns, buffer-local in repos)
| Key                 | Action                                   |
| ------------------- | ---------------------------------------- |
| `]h` / `[h`         | next / previous hunk                     |
| `<leader>gs` / `gr` | stage / reset hunk (also in visual mode) |
| `<leader>gS`        | stage buffer                             |
| `<leader>gp`        | preview hunk diff                        |
| `<leader>gb` / `gB` | blame line / toggle inline blame         |
| `<leader>gd`        | diff buffer against index                |

### Editing & UI
| Key                        | Action                                         |
| -------------------------- | ---------------------------------------------- |
| `<leader>e`                | toggle file explorer (neo-tree)                |
| `<leader>F`                | format buffer/selection (conform, manual only) |
| `<leader>q`                | buffer diagnostics → location list             |
| `]d` / `[d`, `<C-w>d`      | diagnostics: jump / float *(built-in)*         |
| `<Esc>`                    | clear search highlight                         |
| `<C-h/j/k/l>`              | move between windows                           |
| `<C-arrows>`               | resize window                                  |
| `<M-j>` / `<M-k>` (visual) | move selected lines                            |
| `<Esc><Esc>` (terminal)    | leave terminal mode                            |

### Completion (blink.cmp)
`<CR>` accept · `<Tab>`/`<S-Tab>` next/prev (or snippet fields) ·
`<C-space>` open menu/docs · `<C-e>` cancel

### Neovide (⌘)
`⌘C/⌘V` copy/paste · `⌘S` save · `⌘A` select all · `⌘=`/`⌘-`/`⌘0` zoom
(plain `y`/`p` also use the system clipboard — `clipboard=unnamedplus`)

---

## Known limitations

* **zsh** — no treesitter grammar or LSP exists for zsh anywhere; zsh buffers
  reuse the bash parser (~95% correct) and get no language server.
* **git filetypes** — treesitter highlighting only; there is no git LSP.
* **First launch** — files opened before their parser finishes compiling
  aren't highlighted until reopened (`:e`).
* **clangd** needs a `compile_commands.json` in the project for full accuracy
  (CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`).
* **Swift in Xcode projects** — sourcekit-lsp works out of the box for SwiftPM;
  Xcode projects need a build-server shim such as
  [xcode-build-server](https://github.com/SolaWing/xcode-build-server).

## Troubleshooting

`:checkhealth vim.pack` (plugins) · `:checkhealth vim.lsp` (servers) ·
`:checkhealth nvim-treesitter` (parsers) · `:ConformInfo` (formatters) ·
`:lua =vim.lsp.get_clients()` (what's attached) · logs at
`~/.local/state/nvim/lsp.log`.
