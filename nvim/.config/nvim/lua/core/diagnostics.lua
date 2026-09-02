--[[===========================================================================
  core/diagnostics.lua — how diagnostics (errors/warnings/hints) are displayed
  ============================================================================

  Diagnostics are a core Neovim feature (:h vim.diagnostic) fed by LSP servers;
  this file only shapes their presentation, so it lives in core/ and works the
  moment any server attaches.

  Built-in keymaps you already have (no config needed, :h diagnostic-defaults):
    ]d / [d      jump to next / previous diagnostic
    ]D / [D      jump to the last / first diagnostic in the buffer
    <C-w>d       open the floating window with the full diagnostic text
  Plus from this config:
    <leader>q    dump buffer diagnostics into the location list (core/keymaps)
    <leader>fd   fuzzy-pick diagnostics via fzf-lua (plugins/fzf.lua)
===========================================================================]]--

vim.diagnostic.config({
    -- WHAT: Short diagnostic text at the end of the offending line.
    -- WHY : Immediate feedback without leaving the line; `current_line = false`
    --       shows it for all lines (set true to only annotate the cursor line
    --       if you find it noisy). `source = "if_many"` prefixes the producing
    --       server's name only when several servers report into one buffer
    --       (e.g. ty + ruff on Python).
    virtual_text = {
        source = "if_many",
        spacing = 2,
    },

    -- ALTERNATIVE: full-width multi-line diagnostics rendered below the line.
    -- Mutually exclusive with virtual_text in practice (both = clutter).
    -- virtual_lines = { current_line = true },

    -- WHAT: Gutter symbols per severity, using Nerd Font glyphs (JetBrainsMono
    --       Nerd Font is this config's font — see core/neovide.lua / Brewfile).
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },

    -- WHAT: Underline the offending range.
    underline = true,

    -- WHAT: Sort multiple diagnostics on one line by severity, so the sign and
    --       virtual text show the worst problem first.
    severity_sort = true,

    -- WHAT: Don't churn diagnostics mid-typing; refresh on InsertLeave.
    -- WHY : Half-typed code is always "wrong"; updating live is distracting.
    update_in_insert = false,

    -- WHAT: The float opened by <C-w>d. Border style follows vim.o.winborder
    --       (core/options.lua); `source = true` always names the server there.
    float = {
        source = true,
        header = "",
    },
})
