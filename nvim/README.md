# Neovim + Neovide configuration

A Neovim (0.12 or later) configuration on built-in mechanisms: plugins
through the native [`vim.pack`](https://neovim.io/doc/user/pack.html) rather
than a plugin manager, language servers through the native `vim.lsp.config()`
and `vim.lsp.enable()` API, and syntax from the nvim-treesitter `main` branch.
It runs in the terminal and under [Neovide](https://neovide.dev), in
`JetBrainsMono Nerd Font Mono`.

Every option is documented in its file. This README covers installation, the
map of the config, recipes, the keymap reference, and known limitations.

---

## Installation

```sh
# The repo installer does all of this: dependencies, backups, symlinks, and a
# headless first run that installs the plugins and compiles every parser.
cd ~/personal/dotfiles && ./install.sh

# Or this package alone, by hand:
stow --target="$HOME" --dir="$HOME/personal/dotfiles" nvim neovide
nvim   # first launch: vim.pack asks to install the plugins; answer y

# Check:
nvim "+checkhealth vim.pack vim.lsp nvim-treesitter"
```

Neovide reads this config and its `vim.g.neovide_*` settings when launched.
The Neovide setup has two halves: `../neovide/.config/neovide/config.<os>.toml`
handles process and window creation, `lua/core/neovide.lua` runtime behaviour;
the config header describes the split. Font family and size must match
across both, and across the other tools listed in
[The font stack](../README.md#the-font-stack).

`nvim-pack-lock.json`, committed next to `init.lua`, pins the plugin versions
a fresh machine installs.

---

## Map of the config

| Path                                    | Purpose                                                                     |
| --------------------------------------- | --------------------------------------------------------------------------- |
| `.config/nvim/init.lua`                 | Entry point: leader keys and module load order                              |
| `.config/nvim/lua/core/options.lua`     | Editor options                                                              |
| `.config/nvim/lua/core/keymaps.lua`     | Plugin-independent keymaps                                                  |
| `.config/nvim/lua/core/autocmds.lua`    | Yank highlight, cursor restore, column guides, `q` to close utility windows |
| `.config/nvim/lua/core/diagnostics.lua` | How errors and warnings are displayed                                       |
| `.config/nvim/lua/core/filetypes.lua`   | Filetype detection rules, from the language table                           |
| `.config/nvim/lua/core/neovide.lua`     | Font, Neovide runtime settings, ⌘ keymaps                                   |
| `../neovide/`                           | Neovide process and window settings; see its [README](../neovide/README.md) |
| `.config/nvim/lua/theme.lua`            | Colorscheme                                                                 |
| `.config/nvim/lua/languages.lua`        | The language table: add or remove languages here                            |
| `.config/nvim/lua/plugins/init.lua`     | Plugin declarations (`vim.pack`) and load order                             |
| `.config/nvim/lua/plugins/<name>.lua`   | One configuration module per plugin                                         |
| `.config/nvim/after/lsp/<server>.lua`   | Per-server LSP overrides (`:h lsp-config-merge`)                            |
| `../Brewfile`                           | External dependencies for every tool in the repo                            |

Plugins (10): catppuccin (declared in `lua/theme.lua`), nvim-lspconfig
(server config data), nvim-treesitter, fzf-lua, neo-tree (with plenary, nui,
nvim-web-devicons), blink.cmp, lualine, gitsigns, conform, indent-blankline.

---

## Recipes

* **Add a language.** Add an entry to `lua/languages.lua` (the header
  documents each field), add its server to `../Brewfile` and run
  `brew bundle`, then restart Neovim. Parser installation, highlighting, LSP
  activation, and formatter routing all come from the table.
* **Remove a language.** Delete its entry. Optionally run
  `:lua require("nvim-treesitter").uninstall({"<parser>"})` and remove the
  server from `../Brewfile`.
* **Add or remove a plugin.** Three places in `lua/plugins/`: the spec in
  `init.lua`'s `vim.pack.add()` list, a `<name>.lua` module, and its `require`
  line. Remove in reverse, then `:lua vim.pack.del({"<name>"})`. Update with
  `:lua vim.pack.update()`; in the review buffer `:write` applies and `:quit`
  rejects.
* **Change the theme.** `lua/theme.lua`: swap the plugin spec and change one
  variable. The statusline follows.
* **Change the font or size.** Five files across the repo, listed in
  [The font stack](../README.md#the-font-stack). In this package it is the
  `vim.o.guifont` line in `.config/nvim/lua/core/neovide.lua`; its companion
  is the `[font]` section of both `../neovide/.config/neovide/config.<os>.toml`
  files, which cover Neovide's first frames before `init.lua` runs. The
  `guifont` size branches on the platform; theirs is per file. Live zoom: `⌘=`, `⌘-`,
  `⌘0`.
* **Reorder or extend the statusline.** The six `lualine_a` to `lualine_z`
  lists in `lua/plugins/statusline.lua` are the layout.
* **Per-project or per-filetype settings.** Neovim honours `.editorconfig`
  natively. For editor-side overrides create
  `.config/nvim/after/ftplugin/<filetype>.lua` (e.g. `vim.bo.shiftwidth = 2`
  for YAML).

---

## Keymap reference

Leader is Space. `<leader>fk` fuzzy-searches this list at runtime.

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

### Git (gitsigns, buffer-local in repositories)

| Key                 | Action                                   |
| ------------------- | ---------------------------------------- |
| `]h` / `[h`         | next / previous hunk                     |
| `<leader>gs` / `gr` | stage / reset hunk (also in visual mode) |
| `<leader>gS`        | stage buffer                             |
| `<leader>gp`        | preview hunk diff                        |
| `<leader>gb` / `gB` | blame line / toggle inline blame         |
| `<leader>gd`        | diff buffer against index                |

### Editing and UI

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

`⌘C/⌘V` copy/paste · `⌘S` save · `⌘A` select all · `⌘=`/`⌘-`/`⌘0` zoom.
Plain `y`/`p` also use the system clipboard (`clipboard=unnamedplus`). On
Linux the same actions are on Ctrl+Shift.

---

## Known limitations

* **zsh.** No treesitter grammar or language server exists for zsh; zsh
  buffers reuse the bash parser and get no server.
* **git filetypes.** Treesitter highlighting only; there is no git server.
* **First launch.** Files opened before their parser finishes compiling are
  not highlighted until reopened (`:e`).
* **clangd** needs a `compile_commands.json` in the project for full accuracy
  (CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`).
* **Swift in Xcode projects.** sourcekit-lsp works for SwiftPM packages; Xcode
  projects need a build-server shim such as
  [xcode-build-server](https://github.com/SolaWing/xcode-build-server).
* **Linux needs a clipboard provider.** `clipboard=unnamedplus` relies on an
  external tool: macOS has pbcopy built in, Linux needs `wl-clipboard`
  (Wayland) or `xclip` (X11). Both are in the Brewfile under `OS.linux?`.
  Check with `:checkhealth vim.provider`.
* **clangd resolves per platform.** Apple's `/usr/bin/clangd` on macOS, plain
  `clangd` from `$PATH` elsewhere. Debian and Ubuntu ship it versioned
  (`clangd-18`) with the bare name through update-alternatives; install
  `clangd` or name the version in `after/lsp/clangd.lua`.
* **Swift and Objective-C on Linux.** The entries stay, but sourcekit-lsp
  exists only with the swift.org toolchain installed; without it the server
  does not start and nothing else is affected.
* **zls and the zig compiler are version-locked.** A `brew upgrade` that moves
  one and not the other leaves zls unable to start, and the symptom is a
  server that stops attaching with no error naming the cause. Compare
  `zig version` with `zls --version`. The Brewfile's zls entry has the
  details.
* **Go's language table entry is split in two.** `Go` covers the `go`
  filetype and carries `goimports`; `Go module and workspace files` covers
  `gomod`, `gosum`, `gowork`, and `gotmpl` with no formatter, because
  `plugins/conform.lua` maps a formatter onto every filetype in an entry and
  goimports would mangle a `go.mod`.
* **XML has no language server here.** The entry gives treesitter
  highlighting, indent, and folds, but no completion, schema validation, or
  formatting. The only XML server nvim-lspconfig knows is lemminx, which has
  no Homebrew formula; Zed and VS Code bundle it in their XML extensions. The
  XML entry in `lua/languages.lua` says how to add it.
* **Ruby formatting depends on the project.** `ruby-lsp` serves formatting by
  delegating to RuboCop, Standard, or Syntax Tree from the project's own
  bundle, so `<leader>F` does nothing in a Ruby project whose Gemfile has
  none of them. The Ruby entry carries no conform formatter for the same
  reason: RuboCop is a gem rather than a Homebrew formula, so a conform entry
  would call whatever version happened to be on `$PATH` instead of the one the
  project pins.
* **JSONC keeps JSON's trailing-comma rule.** No `jsonc` treesitter grammar
  exists, so `jsonc` buffers reuse the `json` parser, whose `extras` rule
  skips `//` and `/* */` comments but not a stray comma. A trailing comma is
  therefore a parse error for treesitter and a warning from `jsonls`; under
  the plain `json` filetype both the comma and every comment are errors.
* **JSON gets no schema validation.** Fetching a schema is the editor's side
  of the protocol, and `vim.lsp` does not implement it, so a schema named by
  `https://` URL produces nothing at all — no diagnostic and no request in the
  LSP log. The catalogue lookup VS Code performs lives in that editor's client
  extension rather than in the binary `vscode-langservers-extracted` installs.
  A `file://` URL does work; `after/lsp/jsonls.lua` carries the form and the
  measurement.
* **`<leader>F` does nothing in JSON and JSONC.** The files this repo keeps in
  the format are hand-annotated, and the server's formatter would reflow them,
  so `after/lsp/jsonls.lua` turns it off and the language table names no
  conform formatter. This is deliberate, not a missing binary.

## Troubleshooting

`:checkhealth vim.pack` (plugins) · `:checkhealth vim.lsp` (servers) ·
`:checkhealth nvim-treesitter` (parsers) · `:ConformInfo` (formatters) ·
`:lua =vim.lsp.get_clients()` (attached clients) · logs at
`~/.local/state/nvim/lsp.log`.
