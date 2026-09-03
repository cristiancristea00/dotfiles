--[[===========================================================================
  plugins/conform.lua — conform.nvim (code formatting, manual only)
  ============================================================================

  Formatting runs only on <leader>F, never on save, so a shared codebase with
  its own style is not reformatted by accident. To enable format-on-save,
  add to this file:

      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(ev)
          require("conform").format({ bufnr = ev.buf, lsp_format = "fallback" })
        end,
      })

  Which formatter runs per filetype comes from the `formatters` field in
  lua/languages.lua. The binaries are optional: the Brewfile installs
  clang-format, shfmt, and yamlfmt, and rustfmt, ruff, taplo, swift-format,
  and fish_indent come with their toolchains. When a binary is missing,
  <leader>F falls back to the LSP server's formatter. :ConformInfo lists the
  configured formatters, whether each binary is found, and the log path.
===========================================================================]]--

-- WHAT: Build conform's filetype -> formatters map from the language table.
-- WHY : Every filetype in an entry gets the entry's formatters, which is why
--       lua/languages.lua keeps Go module files in a separate entry.
local formatters_by_ft = {}
for _, lang in ipairs(require("languages")) do
    if lang.formatters and #lang.formatters > 0 then
        for _, ft in ipairs(lang.filetypes) do
            formatters_by_ft[ft] = lang.formatters
        end
    end
end

require("conform").setup({
    -- WHAT: The map built above. No format_on_save or format_after_save key is
    --       set, which keeps formatting manual.
    formatters_by_ft = formatters_by_ft,
})

-- WHAT: Format the whole buffer, or the selection in visual mode.
-- WHY : Capital F because <leader>f* is the fuzzy-finder family
--       (plugins/fzf.lua); a lowercase <leader>f would add a timeout pause to
--       every one of those maps. `lsp_format = "fallback"` uses the server
--       when no conform formatter is configured or its binary is missing.
vim.keymap.set({ "n", "v" }, "<leader>F", function()
    require("conform").format({ async = true, lsp_format = "fallback" }, function(err)
        if err then
            vim.notify("Format failed: " .. err, vim.log.levels.WARN)
        end
    end)
end, { desc = "Format buffer/selection" })
