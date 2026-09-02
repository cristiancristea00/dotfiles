# Cursor

[Cursor](https://cursor.com) is an AI-first fork of Visual Studio Code. It is
**not configured here** — this package contains nothing but symlinks.

## Where the configuration actually lives

Every file in this package points at
[`../vscode/.config/Code/User/`](../vscode/README.md). One physical
`settings.json` serves both editors on both platforms, so there is no second
copy to drift. Read the [VS Code package README](../vscode/README.md) for what
is configured and why; this file only covers what is specific to Cursor.

The symlinks are committed as symlinks (git mode `120000`). Edit the real file
in `vscode/`, never a link.

## Install

Cursor is stowed **together with `vscode`**, in the same invocation, because
both need the same per-OS `--ignore`:

```sh
# macOS
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor
# Linux
stow --no-folding --ignore='Library'  --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor
```

## Cursor-specific things in the shared file

| Key | Note |
| --- | ---- |
| `cursor.general.globalCursorIgnoreList` | A denylist of paths Cursor must never send to a model — keys, PEM files, `.ssh/id_*`, credential JSON. Worth keeping accurate |
| `workbench.experimental.modernUI` | A **VS Code** key. Cursor forked before VS Code 1.129 and does not register it, so it is inert here |

Keys either editor does not recognise are simply ignored, which is what makes
the shared file work in both directions.

## Extensions

[`extensions-cursor.txt`](extensions-cursor.txt) holds Cursor-only ids;
[`../vscode/extensions.txt`](../vscode/extensions.txt) holds the shared ones.
The split exists because **Cursor resolves ids against
[Open VSX](https://open-vsx.org), not Microsoft's Marketplace**. Microsoft's
language extensions are licence-restricted off the Marketplace, so Anysphere
publishes forks (`anysphere.cpptools`, `anysphere.cursorpyright`) under its own
namespace. An id only installs where it is published.

## Known gaps

* Cursor's `cmd+i` → `composerMode.agent` binding from the previous live
  configuration was **not** carried over. It is a Cursor-only command, so it
  would be dead in VS Code, and Cursor already binds its agent by default.
* On Linux, Cursor ships only an AppImage and `install.sh` does not install it
  — see the VS Code README's *Known gaps*.
