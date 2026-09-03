--[[===========================================================================
  plugins/statusline.lua — lualine (statusline)
  ============================================================================

  Layout (requested spec):

     ┌ left ──────────────────────────┐        ┌ right ─────────────┐
     │ MODE │ branch │ path/to/file  │ ...... │ line:col │ filetype │
     └─ a ──┴── b ───┴───── c ───────┘        └──── y ───┴──── z ───┘

  ── CUSTOMISE / REORDER / EXTEND ────────────────────────────────────────────
  The six lists below ARE the layout: a/b/c render left-to-right on the left,
  x/y/z render left-to-right on the right. Reordering components = reordering
  list entries; adding one = inserting a string ("encoding", "progress",
  "diagnostics", "diff", "searchcount", ... — :h lualine-available-components)
  or any function returning a string, e.g.:

      lualine_x = { function() return vim.fn.wordcount().words .. "w" end },

  Sections a and z get the boldest highlight, b/y medium, c/x plain.
===========================================================================]]--

require("lualine").setup({
    options = {
        -- WHAT: "auto" derives colours from the active colorscheme — so switching
        --       themes in lua/theme.lua restyles the statusline automatically.
        theme = "auto",
        -- WHAT: One global statusline (matches laststatus=3 in core/options.lua).
        globalstatus = true,
        -- WHAT: Nerd Font powerline separators between/around sections. For a
        --       flat look set both to "".
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
    },

    sections = {
        -- LEFT ------------------------------------------------------------------
        lualine_a = { "mode" }, -- current mode (NORMAL/INSERT/...)
        lualine_b = { "branch" }, -- current git branch ( icon; empty outside repos)
        lualine_c = {
            {
                "filename",
                path = 1, -- 0=name only, 1=relative path, 2=absolute, 3=absolute ~-shortened
                symbols = { modified = "●", readonly = "󰌾", newfile = "[new]" },
            },
        },

        -- RIGHT -----------------------------------------------------------------
        lualine_x = {}, -- empty by design — first slot to claim when extending
        lualine_y = { "location" }, -- line:column
        lualine_z = { "filetype" }, -- language of the current file (with icon)
    },

    -- WHAT: Statusline for windows that don't have focus (only relevant with
    --       laststatus=2; with globalstatus there is a single line). Kept
    --       minimal-but-sane in case you switch back.
    inactive_sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
    },
})
