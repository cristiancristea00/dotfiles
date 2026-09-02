--[[===========================================================================
  core/autocmds.lua — plugin-independent autocommands
  ============================================================================

  Each autocmd lives in its own augroup (`clear = true`) so re-sourcing this
  file never stacks duplicate handlers — the standard idiom for reloadable
  configs.
===========================================================================]]--

local augroup = function(name)
    return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end

-- Highlight yanked text ---------------------------------------------------------
-- WHAT: Briefly flashes the region you just yanked.
-- WHY : Instant visual confirmation of what landed in the register — one of
--       those "can't live without it once seen" touches.
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
--       mark), like every IDE does.
-- WHY : Excluded for git commit/rebase buffers — those are new messages each
--       time and should always start at the top.
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
-- WHAT: When the terminal window / Neovide window changes size, re-equalize
--       all splits so none collapses into a sliver.
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup("resize_splits"),
    desc = "Equalize window sizes after the UI is resized",
    callback = function()
        vim.cmd("wincmd =")
    end,
})

-- Quick-close utility buffers -------------------------------------------------------
-- WHAT: Press plain `q` to close help, quickfix, and other read-only utility
--       windows instead of :q.
-- WHY : These buffers are throwaway; `q` matches what plugin UIs (fzf-lua,
--       neo-tree, gitsigns previews) already do. `q` keeps its normal meaning
--       (record macro) in real file buffers.
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    desc = "Close utility windows with q",
    pattern = { "help", "qf", "man", "checkhealth", "query" },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, desc = "Close window" })
    end,
})
