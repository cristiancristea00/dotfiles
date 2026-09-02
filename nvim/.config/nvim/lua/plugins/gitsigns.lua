--[[===========================================================================
  plugins/gitsigns.lua — gitsigns (git integration)
  ============================================================================

  Shows changed/added/removed lines in the sign column, and provides hunk-
  level actions (stage, reset, preview, blame). This is the whole git story
  of this config by choice — commits/rebases happen in the terminal.

  The statusline branch component (plugins/statusline.lua) reads git data
  independently; gitsigns covers the buffer-level view.
===========================================================================]]--

local gitsigns = require("gitsigns")

gitsigns.setup({
    -- WHAT: The gutter glyphs. Defaults are subtle bars; kept explicit here so
    --       they're easy to restyle.
    signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },

    -- WHAT: Ghost-text blame ("author, time • message") at the end of the
    --       current line. OFF by default — toggle with <leader>gB below.
    current_line_blame = false,
    current_line_blame_opts = { delay = 500 },

    -- WHAT: Buffer-local keymaps, created only when gitsigns actually attaches
    --       (i.e. the file is inside a git repo) — the idiomatic gitsigns setup.
    on_attach = function(bufnr)
        local function bufmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation between hunks (falls back to normal ]c/[c in diff mode).
        bufmap("n", "]h", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gitsigns.nav_hunk("next")
            end
        end, "Next git hunk")
        bufmap("n", "[h", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev")
            end
        end, "Previous git hunk")

        -- Hunk actions: the <leader>g "git" family.
        bufmap("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk (again to unstage)")
        bufmap("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
        bufmap("v", "<leader>gs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected lines")
        bufmap("v", "<leader>gr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selected lines")
        bufmap("n", "<leader>gS", gitsigns.stage_buffer, "Stage whole buffer")
        bufmap("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk diff")
        bufmap("n", "<leader>gb", function()
            gitsigns.blame_line({ full = true })
        end, "Blame line (full commit)")
        bufmap("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle inline blame")
        bufmap("n", "<leader>gd", gitsigns.diffthis, "Diff buffer against index")
    end,
})
