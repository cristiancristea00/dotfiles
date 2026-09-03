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
-- WHAT: Restrict the column guides set in core/options.lua to real files.
-- WHY : The 'colorcolumn' option is window-local, so the global value lands in
--       every window — including `:help`, `:terminal`, quickfix and the
--       neo-tree sidebar. Four vertical bars over a help page or a running
--       shell say nothing about line length.
--       Testing 'buftype' rather than listing filetypes is what makes one
--       check cover all of them: every scratch, help, terminal, and plugin
--       buffer sets a non-empty buftype, while a real file's is always "".
-- NOTE: The branch assigns in BOTH directions on purpose. Only clearing would
--       be a one-way trip — a window that had shown `:help` would keep its
--       guides empty when a real file was opened in it again.
-- NOTE: It reads vim.go.colorcolumn (the global default) rather than repeating
--       the column list, so core/options.lua stays the only place the columns
--       are written. Change them there and this follows.
-- NOTE: The write MUST go through nvim_set_option_value with scope = "local".
--       The obvious `vim.wo[0].colorcolumn = ""` looks equivalent and is not:
--       for this option it behaves like `:set` rather than `:setlocal` and
--       clears the GLOBAL value too, which would destroy the very thing the
--       line above reads back. The first version of this autocmd did exactly
--       that and quietly stopped restoring the guides after the first help
--       page. Verified: vim.wo[0] leaves vim.go empty, scope = "local" does
--       not.
vim.api.nvim_create_autocmd({ "BufWinEnter", "TermOpen" }, {
    group = augroup("colorcolumn_files_only"),
    desc = "Show the column guides in real files only",
    callback = function(ev)
        local guides = vim.bo[ev.buf].buftype == "" and vim.go.colorcolumn or ""
        vim.api.nvim_set_option_value("colorcolumn", guides, { scope = "local", win = 0 })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    desc = "Close utility windows with q",
    pattern = { "help", "qf", "man", "checkhealth", "query" },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, desc = "Close window" })
    end,
})
