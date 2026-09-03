--[[===========================================================================
  plugins/statusline.lua — lualine (statusline)
  ============================================================================

  Layout:

     ┌ left ──────────────────────────┐        ┌ right ─────────────┐
     │ MODE │ branch │ path/to/file  │ ...... │ line:col │ filetype │
     └─ a ──┴── b ───┴───── c ───────┘        └──── y ───┴──── z ───┘

  ── CUSTOMISE / REORDER / EXTEND ────────────────────────────────────────────
  The six lists below are the layout: a, b, c render left to right on the
  left; x, y, z on the right. Reorder by reordering list entries; add a
  component by inserting a name ("encoding", "progress", "diagnostics",
  "diff", "searchcount"; :h lualine-available-components) or a function that
  returns a string, e.g.:

      lualine_x = { function() return vim.fn.wordcount().words .. "w" end },

  Sections a and z get the boldest highlight, b and y medium, c and x plain.
===========================================================================]]--

require("lualine").setup({
    options = {
        -- WHAT: Colour source for the statusline.
        -- WHY : "auto" derives colours from the active colorscheme, so
        --       switching themes in lua/theme.lua restyles the statusline.
        theme = "auto",
        -- WHAT: One global statusline instead of one per window.
        -- WHY : The default is `vim.go.laststatus == 3`, already true through
        --       core/options.lua; stated so it survives a change to laststatus.
        globalstatus = true,
        -- WHAT: Separators between components and around sections.
        -- WHY : Empty strings give a flat statusline. lualine's defaults are the
        --       powerline glyphs U+E0B0/U+E0B2 (sections) and U+E0B1/U+E0B3
        --       (components), which need a Nerd Font.
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
    },

    -- WHAT: The six sections. lualine's default layout also shows diff and
    --       diagnostics in b, encoding, file format, and filetype in x, and
    --       progress in y.
    -- WHY : Mode, branch, path, position, and filetype are enough; diagnostics
    --       appear inline and in <leader>q instead.
    sections = {
        lualine_a = { "mode" }, -- current mode (NORMAL, INSERT, ...)
        lualine_b = { "branch" }, -- git branch, with lualine's icon; empty outside a repository
        lualine_c = {
            {
                "filename",
                path = 1, -- 0 = name only, 1 = relative path, 2 = absolute, 3 = absolute with ~
                symbols = { modified = "●", readonly = "󰌾", newfile = "[new]" }, -- state markers after the name
            },
        },
        lualine_x = {}, -- empty; the first slot to use when extending
        lualine_y = { "location" }, -- line:column
        lualine_z = { "filetype" }, -- filetype of the current file, with icon
    },

    -- WHAT: Statusline for unfocused windows, used only with laststatus = 2.
    -- WHY : With globalstatus there is one line and this is unused; kept so
    --       switching back to per-window statuslines works. These are
    --       lualine's defaults except `path = 1` (the default, 0, shows the
    --       name only).
    inactive_sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
    },
})
