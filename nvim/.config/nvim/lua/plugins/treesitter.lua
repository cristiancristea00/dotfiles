--[[===========================================================================
  plugins/treesitter.lua — syntax highlighting, indentation, folding
  ============================================================================

  nvim-treesitter's `main` branch installs and updates compiled parsers;
  activation is per buffer through the core API `vim.treesitter.start()`
  (:h treesitter). This file wires that up from lua/languages.lua, so adding
  a language does not touch this file.

  Each buffer of a configured filetype gets:
    * highlighting  — vim.treesitter.start()
    * indentation   — nvim-treesitter's indent module (experimental upstream)
    * folding       — vim.treesitter.foldexpr(); folds open by default
                      (foldlevel = 99 in core/options.lua); za, zc, zM toggle

  Commands:
    :InspectTree   -- show the syntax tree of the current buffer
    :Inspect       -- show highlight groups under the cursor
    :TSUpdate      -- recompile parsers (run automatically on plugin update by
                      the PackChanged hook in plugins/init.lua)
    :checkhealth nvim-treesitter
===========================================================================]]--

local languages = require("languages")
local ts = require("nvim-treesitter")

-- WHAT: Collect the parsers and filetypes from the language table, once each,
--       and register the filetype -> parser aliases (zsh reuses bash).
-- WHY : Aliases must be registered before vim.treesitter.start() runs for
--       such a buffer, or the buffer has no parser.
local parsers, filetypes = {}, {}
local seen_parser, seen_ft = {}, {}
for _, lang in ipairs(languages) do
    for _, p in ipairs(lang.parsers or {}) do
        if not seen_parser[p] then
            seen_parser[p] = true
            table.insert(parsers, p)
        end
    end
    for _, ft in ipairs(lang.filetypes or {}) do
        if not seen_ft[ft] then
            seen_ft[ft] = true
            table.insert(filetypes, ft)
        end
    end
    for ft, parser in pairs(lang.parser_aliases or {}) do
        vim.treesitter.language.register(parser, ft)
    end
end

-- WHAT: Install missing parsers, asynchronously, into stdpath("data").
-- WHY : Installed parsers are skipped, so a normal startup does nothing.
--       Compiling needs the tree-sitter CLI (`brew install tree-sitter-cli`,
--       in the Brewfile) and a C compiler (Xcode's clang on macOS); without
--       the CLI every install fails with ENOENT. On the first launch, buffers
--       opened before a parser finishes compiling are not highlighted until
--       reopened (:e).
ts.install(parsers)

-- WHAT: Activate highlighting, folds, and indentation per buffer of a
--       configured filetype.
-- WHY : The `main` branch does not activate anything itself.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("cfg_treesitter", { clear = true }),
    desc = "Enable treesitter highlight/indent/folds for configured languages",
    pattern = filetypes,
    callback = function(ev)
        -- pcall: skip when the parser is not compiled yet (first launch)
        -- instead of erroring on every buffer open.
        if not pcall(vim.treesitter.start, ev.buf) then
            return
        end

        -- Folds from the syntax tree, for this window and buffer only:
        -- vim.wo[0][0] is "current window, this buffer" (:h nvim_set_option_value).
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

        -- Treesitter indentation. Experimental upstream; comment out this line
        -- if a language indents wrongly, and the built-in indent rules apply.
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
