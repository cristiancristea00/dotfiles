# Antigravity IDE

[Antigravity IDE](https://antigravity.google/product/antigravity-ide) is
Google's editor built on Visual Studio Code. This package holds symlinks into
[`vscode/`](../vscode/README.md), where the shared configuration is
documented, plus this README and the Antigravity IDE extension list. This file
covers what is specific to Antigravity IDE. Its agent reads the global
instruction file in [`agents/`](../agents/README.md).

## Where the configuration lives

Every file here points at `../vscode/.config/Code/User/`, so one
`settings.json` serves VS Code, Cursor, and Antigravity IDE on both platforms.
The symlinks are committed as symlinks (git mode `120000`). Edit the real file
in `vscode/`, never a link. See
[One file, six paths](../vscode/README.md#one-file-six-paths).

| Platform | Path Antigravity IDE reads                                  |
| -------- | ----------------------------------------------------------- |
| macOS    | `~/Library/Application Support/Antigravity IDE/User/`       |
| Linux    | `~/.config/Antigravity IDE/User/`                           |

The directory name is the `nameShort` in
`Antigravity IDE.app/Contents/Resources/app/product.json`. Extensions live
apart from it, in `~/.antigravity-ide/extensions/`.

## Install

`./install.sh` handles this. Antigravity IDE is stowed together with `vscode`
and `cursor`, in one invocation, because all three need the same per-OS
`--ignore`:

```sh
# macOS
stow --no-folding --ignore='\.config' --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor antigravity-ide
# Linux
stow --no-folding --ignore='Library'  --target="$HOME" --dir="$HOME/personal/dotfiles" vscode cursor antigravity-ide
```

[The stow model](../README.md#the-stow-model) in the root README explains why
this invocation stays separate from the others. The application itself is one
of the AI tools `install.sh` offers; see [AI tools](../README.md#ai-tools).

## Extensions

[`extensions-antigravity-ide.txt`](extensions-antigravity-ide.txt) lists the
Antigravity IDE-only ids; [`../vscode/extensions.txt`](../vscode/extensions.txt)
lists the shared ones. Antigravity IDE resolves ids against Open VSX, declared
as `extensionsGallery` in its `product.json`. Open VSX serves every shared id
but none of Microsoft's licence-restricted extensions, so clangd and
basedpyright replace the C++ tools and Pylance. The IDE bundles its own
remote-SSH and dev-container extensions, so the `ms-vscode-remote.*` family
needs no substitute. `install.sh` feeds both lists to the `antigravity-ide`
CLI, which the cask puts on `$PATH`.

## Known gaps

* **The Linux path is not verified on Linux.** It follows the rule VS Code and
  Cursor use, `~/.config/<nameShort>/User/`.
* **On Linux the application is not installed.** Google ships it only as a
  `.tar.gz` archive; `install.sh` prints the download URL when it is selected.
