--[[===========================================================================
  plugins/indent.lua — indent-blankline (indentation guides)
  ============================================================================

  Draws a thin vertical line per indentation level — purely visual, most
  useful in deeply nested C++/Python. The plugin's Lua module is named "ibl".
===========================================================================]]--

require("ibl").setup({
    -- WHAT: The guide character. "▏" is the thinnest left-aligned bar in
    --       JetBrainsMono Nerd Font; the plugin default "▎" is heavier.
    indent = { char = "▏" },

    -- WHAT: "Scope" underlines/highlights the current code block's guide using
    --       treesitter. OFF to keep the display calm (lean-visuals choice) —
    --       flip to true for the highlighted-current-block effect.
    scope = { enabled = false },

    -- WHAT: No guides in non-code buffers.
    exclude = { filetypes = { "help", "man", "checkhealth", "neo-tree" } },
})
