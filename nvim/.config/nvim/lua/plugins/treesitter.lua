--[[===========================================================================
  plugins/treesitter.lua — syntax highlighting, indentation, folding
  ============================================================================

  nvim-treesitter's "main" branch is a thin parser manager: it installs and
  updates compiled parsers, but ACTIVATION is explicit and per-buffer via the
  core API `vim.treesitter.start()` (:h treesitter). This file wires that up,
  driven entirely by lua/languages.lua — you should not need to edit this
  file to add a language.

  What each buffer of a configured filetype gets:
    * highlighting  — vim.treesitter.start()
    * indentation   — nvim-treesitter's indent module (experimental upstream)
    * folding       — vim.treesitter.foldexpr(); folds open by default
                      (foldlevel=99 in core/options.lua), toggle with za/zc/zM

  Useful commands:
    :InspectTree   -- show the syntax tree of the current buffer
    :Inspect       -- show highlight groups under the cursor
    :TSUpdate      -- recompile parsers (auto-run on plugin update, see
                      plugins/init.lua PackChanged hook)
    :checkhealth nvim-treesitter
===========================================================================]]--

local languages = require("languages")
local ts = require("nvim-treesitter")

-- Collect the union of parsers and filetypes from the language table ---------
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
    -- Filetype -> parser aliases (e.g. zsh reuses the bash parser). Must be
    -- registered before vim.treesitter.start() runs for such a buffer.
    for ft, parser in pairs(lang.parser_aliases or {}) do
        vim.treesitter.language.register(parser, ft)
    end
end

-- Install any missing parsers -------------------------------------------------
-- WHAT: Async download+compile into stdpath("data"); already-installed
--       parsers are skipped, so this is a cheap no-op on normal startups.
-- NOTE: On the very first launch, buffers opened before a parser finishes
--       compiling won't highlight — reopen the file (:e) once install
--       completes. Compiling REQUIRES the tree-sitter CLI (`brew install
--       tree-sitter-cli`, in the Brewfile) plus a C compiler (Xcode clang);
--       without the CLI every parser install fails with ENOENT.
ts.install(parsers)

-- Activate per buffer ----------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("cfg_treesitter", { clear = true }),
    desc = "Enable treesitter highlight/indent/folds for configured languages",
    pattern = filetypes,
    callback = function(ev)
        -- pcall: silently skip when the parser isn't compiled yet (first launch)
        -- instead of erroring on every buffer open.
        if not pcall(vim.treesitter.start, ev.buf) then
            return
        end

        -- Folding from the syntax tree, window-locally for this buffer.
        -- vim.wo[0][0] = "current window, this buffer only" (:h nvim_set_option_value)
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

        -- Treesitter-based indentation. Marked experimental upstream but already
        -- better than 'smartindent' for these languages; comment out this line if
        -- a language indents oddly (built-in indent rules take over).
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
