--[[===========================================================================
  plugins/completion.lua — blink.cmp (completion engine)
  ============================================================================

  blink.cmp (https://cmp.saghen.dev) provides the completion popup: LSP
  completions plus filesystem paths, snippets, and buffer words, with
  signature help. Chosen over nvim-cmp (faster, zero source-plugins needed)
  and over the built-in vim.lsp.completion (which is LSP-only).

  KEYS (from the "enter" preset + the explicit Tab overrides below):
    <CR>          accept the selected item
    <Tab>/<S-Tab> select next/previous item (or jump between snippet fields)
    <C-n>/<C-p>   select next/previous item
    <C-space>     open the menu / toggle documentation
    <C-e>         cancel
  Change the preset ("default" = C-y accept, "super-tab" = Tab accept) or any
  individual key below; see :h blink-cmp-config-keymap.
===========================================================================]]--

require("blink.cmp").setup({
    -- WHAT: Base keymap family; "enter" = accept with <CR>, the IDE-style
    --       muscle memory. Individual keys can be overridden per-key.
    keymap = {
        preset = "enter",
        -- Tab/S-Tab cycle the menu; inside a snippet they jump between fields;
        -- otherwise Tab falls through and inserts indentation as normal.
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },

    appearance = {
        -- WHAT: Glyph spacing tuned for the single-cell ("Mono") Nerd Font
        --       builds, as opposed to the plain build whose icons are drawn at
        --       double width.
        -- WHY : Correct for this setup: every surface that renders Neovim uses
        --       "JetBrainsMono Nerd Font Mono" (see core/neovide.lua's guifont and
        --       ghostty/config). Set this to "normal" if you ever switch to the
        --       non-Mono build, or icons will be spaced as if they were narrower
        --       than they are.
        nerd_font_variant = "mono",
    },

    completion = {
        -- WHAT: Show documentation for the selected item automatically after a
        --       short delay (default requires pressing <C-space>).
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        -- WHAT: Ghost text previews the selected item inline, virtual-text style.
        -- WHY : Off — visually noisy combined with the menu itself.
        ghost_text = { enabled = false },
    },

    -- WHAT: Show the function-signature float while typing arguments.
    -- WHY : Marked experimental upstream but works well; the alternative is
    --       pressing <C-s> in insert mode (built-in LSP default).
    signature = { enabled = true },

    -- WHAT: Completion sources, in priority order, for normal buffers.
    --       Cmdline/search completion is built in and enabled by default.
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    -- WHAT: The fuzzy matcher. blink's matcher is written in Rust; each tagged
    --       release ships a prebuilt binary that blink downloads on first run
    --       (this is why plugins/init.lua pins blink to release tags).
    --       "prefer_rust_with_warning" = use the binary, and if the download
    --       ever fails, fall back to the pure-Lua matcher with a warning
    --       instead of breaking completion.
    fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- Advertise blink's extra client capabilities to every LSP server ------------
-- WHAT: A wildcard vim.lsp.config("*", ...) merges into all server configs
--       (:h lsp-config).
--       blink's capabilities announce e.g. snippet and autocompletion support
--       so servers send richer completion items.
-- NOTE: Must run before servers start; plugins/init.lua therefore loads this
--       module before plugins/lsp.lua.
vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})
