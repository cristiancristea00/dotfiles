# Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com) is configured here **and so
is [Cursor](../cursor/README.md)** — both editors read one physical
`settings.json`, which lives in this package. Cursor's package holds only
symlinks pointing back here.

Like Zed, and unlike Neovim, both are configured as **normal, non-modal
editors**. That is a choice, not an omission — see *Not enabled* below.

## Install

```sh
# macOS — deploys the Library/ tree, ignores .config/
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor

# Linux — the reverse
stow --no-folding --ignore='Library' --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor
```

`install.sh` picks the right form. Three flags, all load-bearing:

* **`--no-folding`** keeps `User/` a real directory. The editors write
  `globalStorage/`, `History/`, `workspaceStorage/` and `sync/` alongside the
  settings, none of which belong in this repo.
* **`--ignore`** selects one of the two trees each package ships, because these
  editors read their settings from `~/.config` on Linux but from
  `~/Library/Application Support` on macOS, and the format has no conditional.
* Running this **as its own invocation** is mandatory. `--ignore` is a per-run
  flag, so folding these packages into the repo's other `--no-folding` call
  would apply `--ignore='\.config'` to `fish`, `ghostty`, `git` and `zed` and
  erase their entire trees.

## One file, four paths

```
vscode/.config/Code/User/settings.json          ← the only real file
vscode/Library/…/Code/User/settings.json        → symlink to it
cursor/.config/Cursor/User/settings.json        → symlink to it
cursor/Library/…/Cursor/User/settings.json      → symlink to it
```

The three symlinks are committed as symlinks (git mode `120000`), the same
mechanism `CLAUDE.md` uses. Editing the real file changes what both editors
read on both platforms; there is no second copy to keep in sync.

Each editor simply ignores keys it does not recognise, which is what makes one
file viable: `cursor.*` keys are inert in VS Code, and
`workbench.experimental.modernUI` is inert in Cursor.

## Edit this file, not the settings UI

Both editors write to `settings.json` when you change something through their
UI. That is usually harmless, but two things are worth knowing:

* **Never set `window.zoomLevel`.** It is the trigger in open VS Code bug
  [#275792](https://github.com/microsoft/vscode/issues/275792), where resetting
  a setting deletes *every comment line directly above it* — precisely this
  file's shape. The header repeats this warning.
* **Settings Sync must stay off.** It is a second writer to this file with no
  guarantee that its merge preserves comments. The repo is the source of truth.

If the UI ever replaces the symlink with a real file, re-link:

```sh
stow -R --no-folding --ignore='\.config' --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor
```

## What's configured

| Area | Choice | Why |
| ---- | ------ | --- |
| Editor font | `JetBrains Mono` + fallbacks, 14pt, **ligatures on** | Plain build: both editors draw their own UI icons, so the Nerd build buys nothing in the code pane |
| Terminal font | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, **ligatures off** | The integrated terminal runs Neovim and the oh-my-posh prompt, both of which draw icon glyphs |
| Theme | `autoDetectColorScheme` → Catppuccin Latte / Macchiato | Follows the system appearance, like the rest of the stack |
| Indentation | 4 spaces, `detectIndentation` **off** | Matches Neovim's `expandtab` + `shiftwidth = 4`. Without the `off`, `tabSize` is only advisory |
| `formatOnSave` | `off` | Matches Neovim and Zed, where formatting is a manual `<leader>F` |
| Inlay hints | `"on"` | Matches Zed. Note the value is a string, not a boolean |
| Minimap | on, `autohide: "scroll"` | The closest equivalent to Zed's `auto` |
| Workbench | Modern UI **on** | VS Code's redesigned workbench; floating panels match how Zed and Ghostty separate surfaces |
| Telemetry | `"off"` + `redhat.telemetry.enabled: false` | The Red Hat extensions ask separately and ignore the global switch |
| Terminal shell | fish, on both `.osx` and `.linux` | Both keys are needed; each platform reads only its own |

Not enabled, by explicit choice: **`vscodevim.vim`**. Modal editing lives in
Neovim; these are the non-modal half of the setup, exactly as Zed is.

## Extensions

Neither editor has a declarative equivalent of Zed's
`auto_install_extensions` — nothing in `settings.json` can install an
extension, and `.vscode/extensions.json` is workspace-level *recommendations*
only. So the lists live here and `install.sh` feeds them to each editor's CLI:

| File | Goes to |
| ---- | ------- |
| [`extensions.txt`](extensions.txt) | both editors |
| [`extensions-vscode.txt`](extensions-vscode.txt) | VS Code only |
| [`../cursor/extensions-cursor.txt`](../cursor/extensions-cursor.txt) | Cursor only |

There are three lists rather than one because **the editors use different
registries**: VS Code resolves ids against Microsoft's Marketplace, Cursor
against [Open VSX](https://open-vsx.org). An id only installs where it is
published, and Microsoft's own extensions are licence-restricted off the
Marketplace — which is why Cursor ships `anysphere.cursorpyright` where VS Code
has `ms-python`. Only ids published in **both** belong in the shared list.

```sh
code   --install-extension <id> --force
cursor --install-extension <id> --force
```

`--force` makes it idempotent and upgrades in place. The `code` CLI reaches
`$PATH` through the palette action *Shell Command: Install 'code' command in
PATH*; `install.sh` warns rather than fails when it is missing.

## Known gaps

* **On Linux neither editor is installed automatically.** Both are Homebrew
  casks, and casks are macOS-only. Unlike Ghostty and Zed, `install.sh` does
  not fall back to your package manager: VS Code would need Microsoft's
  third-party apt/dnf repository (importing a signing key, writing a sources
  file) and Cursor ships only an AppImage. Adding a system repository
  unattended is out of scope for a dotfiles installer. The configuration still
  deploys — install the applications from
  [code.visualstudio.com](https://code.visualstudio.com/docs/setup/linux) and
  [cursor.com](https://cursor.com/downloads).
* **The Linux tree has never been executed.** No container runtime was
  available; the `--ignore='Library'` form is verified only by `stow -n -v`.
* **VS Code profiles are not modelled.** A stowed `settings.json` governs the
  Default profile only, and profiles cannot inherit settings — so four profiles
  that existed here were deleted and their extensions merged into Default.
  Creating a profile again puts it outside this repo's reach.
* `keybindings.json` is an **empty array**. Both editors' defaults are good;
  the file exists so a future binding is version-controlled from the start.

## Recipes

### Per-language overrides
```jsonc
"[python]": { "editor.tabSize": 4, "editor.formatOnSave": true }
```

### Settings reference
<https://code.visualstudio.com/docs/reference/default-settings>
