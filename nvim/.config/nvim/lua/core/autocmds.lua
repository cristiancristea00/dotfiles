--[[===========================================================================
  core/autocmds.lua — plugin-independent autocommands
  ============================================================================

  Each autocmd has its own augroup with `clear = true`, so re-sourcing this
  file replaces the handlers instead of adding duplicates.
===========================================================================]]--

local augroup = function(name)
    return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end

-- Highlight yanked text ---------------------------------------------------------
-- WHAT: Flash the region that was just yanked.
-- WHY : Confirms what went into the register. Off by default.
-- HOW : `timeout` is the flash duration in ms.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("yank_highlight"),
    desc = "Flash yanked region",
    callback = function()
        vim.hl.on_yank({ timeout = 150 })
    end,
})

-- Restore cursor position --------------------------------------------------------
-- WHAT: Reopening a file jumps to where the cursor was last time (the `"`
--       mark).
-- WHY : Git commit and rebase buffers are excluded: they are new messages each
--       time and start at the top.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("restore_cursor"),
    desc = "Jump to last cursor position when reopening a file",
    callback = function(ev)
        local ft = vim.bo[ev.buf].filetype
        if ft == "gitcommit" or ft == "gitrebase" then
            return
        end
        local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Rebalance splits on resize -------------------------------------------------------
-- WHAT: When the terminal or Neovide window changes size, equalise all splits.
-- WHY : Without it, a resize shrinks the splits unevenly and can leave one a
--       few columns wide.
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup("resize_splits"),
    desc = "Equalize window sizes after the UI is resized",
    callback = function()
        vim.cmd("wincmd =")
    end,
})

-- Column guides in real files only ------------------------------------------------
-- WHAT: Limit the column guides set in core/options.lua to file buffers.
-- WHY : 'colorcolumn' is window-local, so the global value would also apply in
--       `:help`, `:terminal`, quickfix, and the neo-tree sidebar. Every
--       scratch, help, terminal, and plugin buffer sets a non-empty 'buftype'
--       and a real file's is "", so one test covers them all.
-- NOTE: The branch assigns in both directions: a window that showed `:help`
--       gets its guides back when a file is opened in it. It reads
--       vim.go.colorcolumn rather than repeating the list, so the columns are
--       written only in core/options.lua.
-- NOTE: The write must go through nvim_set_option_value with scope = "local".
--       `vim.wo[0].colorcolumn = ""` behaves like `:set` for this option and
--       clears the global value too, which would empty the value this reads.
vim.api.nvim_create_autocmd({ "BufWinEnter", "TermOpen" }, {
    group = augroup("colorcolumn_files_only"),
    desc = "Show the column guides in real files only",
    callback = function(ev)
        local guides = vim.bo[ev.buf].buftype == "" and vim.go.colorcolumn or ""
        vim.api.nvim_set_option_value("colorcolumn", guides, { scope = "local", win = 0 })
    end,
})

-- Quick-close utility buffers -------------------------------------------------------
-- WHAT: Plain `q` closes help, quickfix, and other read-only utility windows.
-- WHY : Matches what fzf-lua, neo-tree, and gitsigns previews do. `q` keeps
--       its normal meaning (record a macro) in file buffers.
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    desc = "Close utility windows with q",
    pattern = { "help", "qf", "man", "checkhealth", "query" },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, desc = "Close window" })
    end,
})
