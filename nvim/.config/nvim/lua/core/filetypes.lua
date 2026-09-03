--[[===========================================================================
  core/filetypes.lua — filetype detection rules
  ============================================================================

  Neovim decides a buffer's filetype from its name, extension, or contents
  (:h vim.filetype.add), and the filetype drives highlighting, indentation,
  LSP attachment, and the treesitter activation in plugins/treesitter.lua.

  This module registers only the rules Neovim lacks. The rules live in
  lua/languages.lua, on the optional `extensions`, `filenames`, and
  `patterns` fields of a language entry, so a new language is one entry.
  Rules registered here take precedence over Neovim's built-in table.
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

-- Register the collected rules; empty tables are accepted, so there is no guard.
vim.filetype.add({
    extension = extension,
    filename = filename,
    pattern = pattern,
})
