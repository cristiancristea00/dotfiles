# Cursor

[Cursor](https://cursor.com) is a fork of Visual Studio Code. This package
holds symlinks into [`vscode/`](../vscode/README.md), where the shared
configuration is documented, plus this README and the Cursor extension list.
This file covers what is specific to Cursor.

## Where the configuration lives

Every file here points at `../vscode/.config/Code/User/`, so one
`settings.json` serves both editors on both platforms. The symlinks are
committed as symlinks (git mode `120000`). Edit the real file in `vscode/`,
never a link. See [One file, four paths](../vscode/README.md#one-file-four-paths).

## Install

`./install.sh` handles this. Cursor is stowed together with `vscode`, in one
invocation, because both need the same per-OS `--ignore`:

```sh
# macOS
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor
# Linux
stow --no-folding --ignore='Library'  --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor
```

[The stow model](../README.md#the-stow-model) in the root README explains why
this invocation stays separate from the others.

## Cursor-specific keys in the shared file

| Key                                            | Note                                                                                       |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `cursor.general.globalCursorIgnoreList`        | Paths Cursor must never send to a model: keys, PEM files, `.ssh/id_*`, and credential JSON |
| `cursor.composer.shouldChimeAfterChatFinishes` | Play a sound when a long agent run finishes                                                |
| `workbench.experimental.modernUI`              | A VS Code key. Cursor forked before VS Code 1.129 and does not register it                 |

Each editor ignores keys it does not recognise.

## Extensions

[`extensions-cursor.txt`](extensions-cursor.txt) lists the Cursor-only ids;
[`../vscode/extensions.txt`](../vscode/extensions.txt) lists the shared ones.
Cursor resolves ids against its own gallery, `marketplace.cursorapi.com`.
That gallery does not serve Microsoft's licence-restricted extensions, so
those have substitutes published under the `anysphere.` namespace.
[`../vscode/extensions-vscode.txt`](../vscode/extensions-vscode.txt) records
which VS Code extension each substitute replaces. The gallery and the query
that checks it are documented under
[Extensions](../vscode/README.md#extensions) in the VS Code README.

## Known gaps

On Linux, Cursor ships only an AppImage and `install.sh` does not install it.
See [Known gaps](../vscode/README.md#known-gaps) in the VS Code README.
