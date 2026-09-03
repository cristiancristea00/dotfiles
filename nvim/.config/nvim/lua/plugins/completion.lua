--[[===========================================================================
  plugins/completion.lua — blink.cmp (completion engine)
  ============================================================================

  blink.cmp (https://cmp.saghen.dev) provides the completion popup: LSP
  completions plus filesystem paths, snippets, and buffer words, with
  signature help. Chosen over nvim-cmp, which needs a plugin per source, and
  over the built-in vim.lsp.completion, which is LSP-only.

  KEYS (the "enter" preset plus the Tab overrides below):
    <CR>          accept the selected item
    <Tab>/<S-Tab> select next/previous item (or jump between snippet fields)
    <C-n>/<C-p>   select next/previous item
    <C-space>     open the menu / toggle documentation
    <C-e>         cancel
  Change the preset ("default" = C-y accept, "super-tab" = Tab accept) or any
  key below; see :h blink-cmp-config-keymap.
===========================================================================]]--

require("blink.cmp").setup({
    -- WHAT: Base keymap family plus per-key overrides.
    -- WHY : "enter" accepts with <CR>, as the GUI editors here do; blink's
    --       default preset accepts with <C-y>. Tab and S-Tab cycle the menu
    --       when it is open, jump between snippet fields inside a snippet,
    --       and otherwise insert indentation.
    keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },

    appearance = {
        -- WHAT: Glyph spacing for the single-cell ("Mono") Nerd Font builds.
        -- WHY : Every surface that renders Neovim uses a Mono build (see
        --       core/neovide.lua). With the plain build set this to "normal",
        --       or icons are spaced as if they were one cell wide.
        nerd_font_variant = "mono",
    },

    completion = {
        -- WHAT: Show documentation for the selected item after a delay.
        -- WHY : By default documentation appears only on <C-space>, and the
        --       delay defaults to 500 ms; 250 ms shows it while browsing without
        --       flashing on every keystroke.
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        -- WHAT: Ghost text previews the selected item inline.
        -- WHY : Off: the menu already shows the item, and the inline preview
        --       moves the text after the cursor.
        ghost_text = { enabled = false },
    },

    -- WHAT: Show the function-signature float while typing arguments.
    -- WHY : Marked experimental upstream and off by default; the alternative is
    --       <C-s> in insert mode from the built-in LSP defaults.
    signature = { enabled = true },

    -- WHAT: Completion sources, in priority order, for normal buffers.
    -- WHY : These are blink's defaults. Assigning the list replaces it, so
    --       adding a source means restating all four. Cmdline and search
    --       completion are built in and on by default.
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    -- WHAT: The fuzzy matcher implementation.
    -- WHY : The matcher is written in Rust; each tagged release ships a
    --       prebuilt binary that blink downloads on first run, which is why
    --       plugins/init.lua pins blink to release tags.
    --       "prefer_rust_with_warning", blink's default, uses the binary and
    --       falls back to the Lua matcher with a warning if the download
    --       fails; "prefer_rust" would fall back silently.
    fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- WHAT: Merge blink's client capabilities into every server config
--       (vim.lsp.config("*", …), :h lsp-config).
-- WHY : The capabilities announce snippet and autocompletion support, so
--       servers send richer completion items. It must run before servers
--       start, so plugins/init.lua loads this module before plugins/lsp.lua.
vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})
