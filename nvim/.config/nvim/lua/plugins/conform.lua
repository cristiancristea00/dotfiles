--[[===========================================================================
  plugins/conform.lua — conform.nvim (code formatting, MANUAL ONLY)
  ============================================================================

  Formatting runs ONLY when you press <leader>F — never on save, by explicit
  choice (shared codebases with inconsistent styles shouldn't be reformatted
  by accident). To later enable format-on-save, add to this file:

      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(ev)
          require("conform").format({ bufnr = ev.buf, lsp_format = "fallback" })
        end,
      })

  WHICH formatter runs per filetype comes from the `formatters` field in
  lua/languages.lua. The formatter BINARIES are optional extras (Brewfile
  installs clang-format, shfmt, yamlfmt; rustfmt/ruff/taplo/swift-format/
  fish_indent come with their toolchains): if a binary is missing, <leader>F
  falls back to the LSP server's formatter, and :ConformInfo explains what
  ran or didn't.
===========================================================================]]--

-- Build conform's formatters_by_ft map from the language table ----------------
local formatters_by_ft = {}
for _, lang in ipairs(require("languages")) do
    if lang.formatters and #lang.formatters > 0 then
        for _, ft in ipairs(lang.filetypes) do
            formatters_by_ft[ft] = lang.formatters
        end
    end
end

require("conform").setup({
    formatters_by_ft = formatters_by_ft,
    -- WHAT: Explicitly no format_on_save / format_after_save keys — that's what
    --       keeps conform manual-only.
})

-- WHAT: Format the whole buffer, or just the selection in visual mode.
--       Capital F: <leader>f* is the fuzzy-finder family (plugins/fzf.lua);
--       a lowercase <leader>f mapping would add a timeout pause to all of it.
vim.keymap.set({ "n", "v" }, "<leader>F", function()
    require("conform").format({ async = true, lsp_format = "fallback" }, function(err)
        if err then
            vim.notify("Format failed: " .. err, vim.log.levels.WARN)
        end
    end)
end, { desc = "Format buffer/selection" })
