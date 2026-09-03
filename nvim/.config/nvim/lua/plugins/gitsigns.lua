--[[===========================================================================
  plugins/gitsigns.lua — gitsigns (git integration)
  ============================================================================

  Shows added, changed, and removed lines in the sign column and provides
  hunk-level actions (stage, reset, preview, blame). It is the only git
  plugin here; commits and rebases happen in the terminal. The statusline's
  branch component (plugins/statusline.lua) reads git data on its own.
===========================================================================]]--

local gitsigns = require("gitsigns")

gitsigns.setup({
    -- WHAT: The gutter glyphs per change type.
    -- WHY : These are gitsigns's defaults, stated so they can be restyled here.
    signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },

    -- WHAT: Blame text ("author, time - message") at the end of the current
    --       line, after `delay` ms.
    -- WHY : Off (the default); <leader>gB below toggles it. 500 ms is half the
    --       default delay of 1000.
    current_line_blame = false,
    current_line_blame_opts = { delay = 500 },

    -- WHAT: Buffer-local keymaps, created when gitsigns attaches (the file is
    --       in a git repository).
    -- WHY : The maps exist only where they work; outside a repository
    --       <leader>g* stays free.
    on_attach = function(bufnr)
        local function bufmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Hunk navigation; in diff mode the built-in ]c and [c are used instead.
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

        -- Hunk actions, the <leader>g "git" family; the desc names each one.
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
