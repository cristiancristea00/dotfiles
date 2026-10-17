# Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com),
[Cursor](../cursor/README.md), and
[Antigravity IDE](../antigravity-ide/README.md) are configured here: all three
editors read one `settings.json`, which lives in this package. The Cursor and
Antigravity IDE packages hold symlinks pointing back here.

Like Zed, and unlike Neovim, all three are configured as non-modal editors;
`vscodevim.vim` is not installed.

## Install

```sh
# From the repo root. macOS: deploys the Library/ tree, ignores .config/
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$PWD" vscode cursor antigravity-ide

# Linux: the reverse
stow --no-folding --ignore='Library' --target="$HOME" --dir="$PWD" vscode cursor antigravity-ide
```

`install.sh` picks the right form. Stow's `--no-folding` keeps `User/` a real
directory, because the editors write `globalStorage/`, `History/`,
`workspaceStorage/`, and `sync/` beside the settings. `--ignore` selects one of
the two trees each package ships, because the editors read `~/.config` on Linux
and `~/Library/Application Support` on macOS. The invocation must stay separate
from the repo's other stow calls; [The stow model](../README.md#the-stow-model)
explains why.

## One file, six paths

```text
vscode/.config/Code/User/settings.json                             ← the only real file
vscode/Library/…/Code/User/settings.json                           → symlink to it
cursor/.config/Cursor/User/settings.json                           → symlink to it
cursor/Library/…/Cursor/User/settings.json                         → symlink to it
antigravity-ide/.config/Antigravity IDE/User/settings.json         → symlink to it
antigravity-ide/Library/…/Antigravity IDE/User/settings.json       → symlink to it
```

The five symlinks are committed as symlinks (git mode `120000`), the same
mechanism `CLAUDE.md` uses. Editing the real file changes what all three
editors read on both platforms. Each editor ignores keys it does not
recognise, so `cursor.*` keys have no effect in VS Code and
`workbench.experimental.modernUI` has none in Cursor.

## Edit this file, not the settings UI

Each editor writes to `settings.json` when a setting is changed through its
UI. Two rules follow:

* **Never set `window.zoomLevel`.** Resetting a setting through the UI
  deletes every comment line directly above it (open VS Code bug
  [#275792](https://github.com/microsoft/vscode/issues/275792)), and the zoom
  shortcuts write this key without a visit to the UI. The settings header
  has the details.
* **Settings Sync must stay off.** It is a second writer to this file whose
  merge is not documented to keep comments. The repo is the source of truth.

If the UI replaces the symlink with a real file, re-link from the repo root:

```sh
stow -R --no-folding --ignore='\.config' --target="$HOME" --dir="$PWD" vscode cursor antigravity-ide
```

## What's configured

| Area           | Choice                                                                 | Why                                                                                                                  |
| -------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Editor font    | `JetBrains Mono` + fallbacks, 14pt, ligatures on                       | The plain build; both editors draw their own UI icons. See [The font stack](../README.md#the-font-stack)             |
| Terminal font  | `JetBrainsMono Nerd Font Mono` + fallbacks, 14pt, ligatures on         | The integrated terminal runs Neovim and the oh-my-posh prompt, which draw icon glyphs                                |
| Theme          | `autoDetectColorScheme` → Catppuccin Latte / Mocha                     | Follows the system appearance; see [Light and dark](../README.md#light-and-dark)                                     |
| Indentation    | 4 spaces, `detectIndentation` off                                      | Matches Neovim's `expandtab` + `shiftwidth = 4`; with detection on, `tabSize` holds only for files already using it  |
| `formatOnSave` | off                                                                    | Matches Neovim and Zed, where formatting is manual                                                                   |
| Inlay hints    | `"on"`                                                                 | Matches Zed. The value is a string, not a boolean                                                                    |
| Cursor         | blinking block, editor and terminal                                    | Same as every other tool; see [The cursor](../README.md#the-cursor)                                                  |
| Minimap        | on, `autohide: "scroll"`                                               | The closest equivalent to Zed's `auto`                                                                               |
| Workbench      | Modern UI on                                                           | VS Code's redesigned workbench; floating panels separate surfaces as Zed and Ghostty do                              |
| Telemetry      | `"off"` + `redhat.telemetry.enabled: false`                            | The Red Hat extensions have their own switch                                                                         |
| Terminal shell | fish, on both `.osx` and `.linux`, as an absolute path with a fallback | Each platform reads only its own key; a defined profile does not depend on VS Code discovering fish in `/etc/shells` |
| YAML schemas   | Detection off for six workflow globs                                   | `github.vscode-github-actions` owns workflow files; Gitea and Forgejo use the same format on unclaimed paths         |
| Lua            | `LuaJIT` runtime, `vim` global, Neovim's runtime on the library path   | Editing `nvim/` otherwise reports every `vim.*` call as an undefined global and completes nothing                    |
| Associations   | Zed's `settings*.json` opened as JSONC                                 | Both editors already claim their own settings and keybindings; the per-OS split gave Zed's a name neither list has   |

## Extensions

No editor here has a declarative equivalent of Zed's
`auto_install_extensions`: nothing in `settings.json` can install an extension,
and `.vscode/extensions.json` holds workspace recommendations only. The lists
live here and `install.sh` feeds them to each editor's CLI:

| File                                                                                                     | Goes to              |
| -------------------------------------------------------------------------------------------------------- | -------------------- |
| [`extensions.txt`](extensions.txt)                                                                       | all three editors    |
| [`extensions-vscode.txt`](extensions-vscode.txt)                                                         | VS Code only         |
| [`../cursor/extensions-cursor.txt`](../cursor/extensions-cursor.txt)                                     | Cursor only          |
| [`../antigravity-ide/extensions-antigravity-ide.txt`](../antigravity-ide/extensions-antigravity-ide.txt) | Antigravity IDE only |

There are four lists because the editors use different galleries. VS Code
resolves ids against Microsoft's Marketplace. Cursor resolves them against its
own gallery at `marketplace.cursorapi.com`, declared in
`Cursor.app/Contents/Resources/app/product.json`; it is not Open VSX. That
gallery mirrors most of the Marketplace, so `ms-python.python` and
`ms-vscode.cmake-tools` are in the shared list. It does not carry Microsoft's
licence-restricted extensions: Pylance, the C++ tools, and the
`ms-vscode-remote.*` family. Anysphere publishes forks of those under the
`anysphere.` namespace, declared in
[`extensions-cursor.txt`](../cursor/extensions-cursor.txt). Four
markdown-preview extensions have no counterpart and are absent from Cursor.

Antigravity IDE resolves ids against Open VSX, declared as `extensionsGallery`
in `Antigravity IDE.app/Contents/Resources/app/product.json`. Open VSX serves
every id in the shared list and none of the licence-restricted ones or the four
markdown-preview extras. Antigravity IDE bundles its own remote-SSH and
dev-container extensions; clangd and basedpyright replace the C++ tools and
Pylance, declared in
[`extensions-antigravity-ide.txt`](../antigravity-ide/extensions-antigravity-ide.txt).
An id belongs in the shared list only when all three galleries serve it.

Cursor's gallery answers which ids it serves; an id that comes back empty
belongs in `extensions-vscode.txt`:

```sh
curl -s -X POST \
  https://marketplace.cursorapi.com/_apis/public/gallery/extensionquery \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json;api-version=7.2-preview.1' \
  -d '{"filters":[{"criteria":[{"filterType":7,"value":"<publisher.name>"}]}],"flags":914}'
```

Open VSX answers with an HTTP status, and 200 means it serves the id:

```sh
curl -s -o /dev/null -w '%{http_code}\n' https://open-vsx.org/api/<publisher>/<name>
```

`install.sh` installs only what is missing: it reads each editor's installed
set with one `--list-extensions` call and skips every id already there.
Calling `--install-extension --force` for every id would reinstall or upgrade
each one at about 0.76 s per call, so the installer does not upgrade
extensions. That is safe because `extensions.autoUpdate` is `"on"` in
[`settings.json`](.config/Code/User/settings.json), so both editors update
themselves; turn it off and extensions stay at their installed version.
`--force` is still passed on the calls that run, so a retry after a partial
failure is idempotent. `./install.sh --dry-run` names the ids it would add.

The `code` CLI reaches `$PATH` through the palette action *Shell Command:
Install 'code' command in PATH*; `install.sh` warns rather than fails when it
is missing.

## Known gaps

* **On Linux no editor here is installed automatically.** All three are
  Homebrew casks, which are macOS-only. Unlike Ghostty and Zed, `install.sh`
  does not use the package manager for them: VS Code needs Microsoft's
  third-party apt or dnf repository (a signing key and a sources file), Cursor
  ships only an AppImage, and Antigravity IDE only a `.tar.gz` archive. The
  configuration still deploys. Install VS Code from
  [code.visualstudio.com](https://code.visualstudio.com/docs/setup/linux);
  for Cursor and Antigravity IDE, `install.sh` prints the download URL when
  the editor is selected in its AI-tools menu.
* **The Linux stow form is verified only with `stow -n -v`**, not by a run on
  Linux.
* **VS Code profiles are not modelled.** A stowed `settings.json` governs the
  Default profile only, and profiles cannot inherit settings. A profile
  created here is outside the repo's reach.
* **`keybindings.json` is an empty array.** Both editors' defaults are used;
  the file exists so a future binding is version-controlled from the start.

## Recipes

* **Per-language overrides.**
  `"[python]": { "editor.tabSize": 4, "editor.formatOnSave": true }`
* **Settings reference.**
  <https://code.visualstudio.com/docs/reference/default-settings>
