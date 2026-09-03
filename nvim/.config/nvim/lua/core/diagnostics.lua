--[[===========================================================================
  core/diagnostics.lua — how diagnostics (errors, warnings, hints) are shown
  ============================================================================

  Diagnostics are a core Neovim feature (:h vim.diagnostic) fed by LSP
  servers; this file shapes their presentation. Neovim's built-in keymaps
  (]d, [d, ]D, [D, <C-w>d; :h diagnostic-defaults) are listed in
  plugins/lsp.lua. This config adds <leader>q (core/keymaps.lua) and
  <leader>fd (plugins/fzf.lua).
===========================================================================]]--

vim.diagnostic.config({
    -- WHAT: Short diagnostic text at the end of the offending line.
    -- WHY : Shows the message without leaving the line. `source = "if_many"`
    --       prefixes the server's name only when several servers report into
    --       one buffer (ty and ruff on Python). `spacing` is the gap before the
    --       text; the default is 4. `current_line`, false by default, is left
    --       alone: true would annotate only the cursor line.
    virtual_text = {
        source = "if_many",
        spacing = 2,
    },

    -- WHAT: The alternative: full-width multi-line diagnostics below the line.
    -- WHY : Not enabled alongside virtual_text; both at once repeat the text.
    -- virtual_lines = { current_line = true },

    -- WHAT: Gutter symbols per severity, as Nerd Font glyphs.
    -- WHY : The default signs are the letters E, W, I, and H. The glyphs need
    --       the Nerd Font every surface here uses (see core/neovide.lua).
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },

    -- WHAT: Underline the offending range.
    -- WHY : The default; stated so the display is documented in one place.
    underline = true,

    -- WHAT: Sort several diagnostics on one line by severity.
    -- WHY : The sign and virtual text then show the worst problem. Off by
    --       default.
    severity_sort = true,

    -- WHAT: Do not refresh diagnostics while typing in insert mode.
    -- WHY : Half-typed code produces errors that disappear on the next
    --       keystroke. This is the default.
    update_in_insert = false,

    -- WHAT: The float opened by <C-w>d. `source = true` always names the
    --       server; `header = ""` removes the "Diagnostics:" title line.
    -- WHY : The border follows vim.o.winborder (core/options.lua), so none is
    --       set here.
    float = {
        source = true,
        header = "",
    },
})
