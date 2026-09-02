--[[===========================================================================
  core/filetypes.lua — filetype detection rules
  ============================================================================

  Neovim decides a buffer's filetype from its name, extension or contents
  (:h vim.filetype.add). That decision is what drives everything else:
  syntax highlighting, indentation, LSP attachment and the treesitter
  activation in plugins/treesitter.lua.

  This module registers only the rules Neovim does NOT already provide. The
  rules themselves live in lua/languages.lua, on the optional `extensions`,
  `filenames` and `patterns` fields of a language entry, so that adding
  detection for a new language stays a one-entry edit like everything else.

  Precedence note: rules registered here are consulted BEFORE Neovim's
  built-in table, so an entry added below overrides the built-in answer for
  the same extension.
===========================================================================]]--

local extension, filename, pattern = {}, {}, {}

for _, lang in ipairs(require("languages")) do
    for ext, ft in pairs(lang.extensions or {}) do
        extension[ext] = ft
    end
    for name, ft in pairs(lang.filenames or {}) do
        filename[name] = ft
    end
    for pat, ft in pairs(lang.patterns or {}) do
        pattern[pat] = ft
    end
end

-- Registering empty tables is harmless, so this needs no guard.
vim.filetype.add({
    extension = extension,
    filename = filename,
    pattern = pattern,
})
