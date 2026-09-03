--[[===========================================================================
  plugins/indent.lua — indent-blankline (indentation guides)
  ============================================================================

  Draws a thin vertical line per indentation level. The plugin's Lua module
  is named "ibl".
===========================================================================]]--

require("ibl").setup({
    -- WHAT: The guide character.
    -- WHY : "▏" is the thinnest left-aligned bar in JetBrainsMono Nerd Font;
    --       the default "▎" is heavier.
    indent = { char = "▏" },

    -- WHAT: Highlight the current code block's guide, using treesitter.
    -- WHY : Off, so only the indentation levels are drawn; the default is on.
    scope = { enabled = false },

    -- WHAT: Filetypes that get no guides.
    -- WHY : The list merges with the plugin's defaults (indent_blankline.txt:
    --       "List values get merged with the default list value"), which already
    --       cover help, man, checkhealth, gitcommit, lspinfo, and the empty
    --       filetype; neo-tree is the one addition, and the rest are repeats.
    exclude = { filetypes = { "help", "man", "checkhealth", "neo-tree" } },
})
