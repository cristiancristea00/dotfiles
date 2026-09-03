--[[===========================================================================
  core/options.lua — editor options
  ============================================================================

  Every option below is documented as:
    WHAT it does, WHY this value was chosen, and (where useful) HOW to change
    or override it.

  `vim.o` is the modern scalar accessor for options (:h vim.o). For options
  that are lists Neovim accepts a comma-string via vim.o; `vim.opt` would give
  a set-like API but vim.o keeps this file uniform and is the idiom the core
  docs use.

  Per-filetype overrides: don't edit this file for one language. Instead
  create after/ftplugin/<filetype>.lua in this config directory, e.g.
  after/ftplugin/yaml.lua containing `vim.bo.shiftwidth = 2`. Neovim sources
  it automatically whenever a buffer of that filetype opens.
===========================================================================]]--

-- Line numbers ----------------------------------------------------------------
-- WHAT: `number` shows the absolute line number on the cursor line;
--       `relativenumber` shows distances (1, 2, 3, ...) on all other lines.
-- WHY : Relative numbers make motions like `5j` / `12k` instant to read off,
--       while the absolute number on the current line keeps orientation.
-- HOW : Disable relative numbers with `vim.o.relativenumber = false`.
vim.o.number = true
vim.o.relativenumber = true

-- Sign column -----------------------------------------------------------------
-- WHAT: The column left of the numbers where diagnostics/git signs appear.
-- WHY : "yes" reserves it permanently; the default "auto" makes the whole
--       text area shift right the moment the first sign appears — jarring.
-- HOW : "yes:2" would reserve two cells; "number" merges signs into the
--       number column.
vim.o.signcolumn = "yes"

-- Cursor line -----------------------------------------------------------------
-- WHAT: Highlights the screen line the cursor is on.
-- WHY : Cheap visual anchor, especially in large windows; themes style it
--       subtly.
vim.o.cursorline = true

-- Cursor shape ----------------------------------------------------------------
-- WHAT: The cursor's shape and blink timing, per mode. `a:` means ALL modes.
-- WHY : A blinking block everywhere, which is the stack-wide choice — Ghostty,
--       Zed and both VS Code editors draw the same thing. Neovim is the only
--       tool that needed changing: its default is
--         n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor
--       so INSERT mode was a thin vertical bar and REPLACE a horizontal one.
--       Nothing else in the stack changes shape by mode, so neither should
--       this.
-- NOTE: The `t:` entry looks redundant next to `a:` and is not — do not
--       "simplify" it away. Entries are applied left to right, so the later
--       `t:` overrides `a:` for terminal mode only, and it exists purely to
--       keep the `TermCursor` highlight group. That group is what colours the
--       :terminal cursor; a bare `a:block` silently drops it and the terminal
--       cursor changes colour.
-- NOTE: This option FAILS SILENTLY. `set guicursor=a:nonsense` is accepted
--       without an error and reported back verbatim, so a typo here shows up
--       as a cursor that never changes rather than as a message. Check the
--       applied value with `:set guicursor?` rather than assuming.
-- HOW : Where this actually lands depends on the front end. Neovide renders
--       this option directly. In a terminal, Neovim translates it into
--       DECSCUSR escapes, which is why it agrees with Ghostty's own
--       `cursor-style` / `cursor-style-blink` rather than fighting it.
--       For a steady cursor, drop the three blink fields. To go back to
--       per-mode shapes, `:set guicursor&` restores the default above.
vim.o.guicursor = "a:block-blinkwait700-blinkoff400-blinkon250,"
    .. "t:block-blinkwait700-blinkoff400-blinkon250-TermCursor"

-- Indentation -----------------------------------------------------------------
-- WHAT: `expandtab` inserts spaces when you press <Tab>; `tabstop` is how wide
--       a real tab character displays; `shiftwidth` is the width used by
--       indent operations (>>, <<, autoindent); `softtabstop = -1` makes <Tab>
--       in insert mode follow shiftwidth; `shiftround` snaps >>/<< to a
--       multiple of shiftwidth; `breakindent` visually indents wrapped lines.
-- WHY : 4-space indentation is a sane global default for the C-family /
--       Rust / Python mix here. Languages with strong 2-space conventions
--       (YAML, ...) should be overridden per-filetype (see header) — many are
--       already handled by Neovim's built-in ftplugins or by editorconfig
--       (Neovim honors .editorconfig files natively, and project settings win).
-- HOW : Change the two `4`s; everything else follows.
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = -1
vim.o.shiftround = true
vim.o.breakindent = true

-- Line wrapping ---------------------------------------------------------------
-- WHAT: `wrap = false` lets long lines run off-screen instead of wrapping.
-- WHY : Wrapped code lines are hard to scan; horizontal scroll is rare with
--       sensible line lengths. `linebreak` only matters when wrap is toggled
--       on (e.g. for prose): it wraps at word boundaries instead of mid-word.
-- HOW : Toggle per window at runtime with `:set wrap!`.
vim.o.wrap = false
vim.o.linebreak = true

-- Searching -------------------------------------------------------------------
-- WHAT: `ignorecase` + `smartcase` = case-insensitive search unless the
--       pattern contains an uppercase letter. `inccommand = "split"` live-
--       previews :substitute (and friends) in a split while you type.
-- WHY : Smart-case is the least-surprise behaviour. Highlighting all search
--       matches (hlsearch) is Neovim's default and is kept — <Esc> is mapped in
--       core/keymaps.lua to clear the highlight instead of disabling the
--       feature entirely.
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- Splits ----------------------------------------------------------------------
-- WHAT: Where new windows open relative to the current one.
-- WHY : Right/below matches reading order and every other editor's behaviour;
--       Vim's default (left/above) surprises everyone.
vim.o.splitright = true
vim.o.splitbelow = true

-- Undo, swap ------------------------------------------------------------------
-- WHAT: `undofile` persists undo history to disk (undo survives :q and
--       restarts). `swapfile = false` disables the .swp crash-recovery files.
-- WHY : Persistent undo is strictly better than swap for recovering work, and
--       swap files mostly manifest as the annoying "E325 ATTENTION" prompt
--       after a crash or a second nvim instance.
-- HOW : If you edit the same files from multiple Neovim instances and want
--       collision warnings back, delete the swapfile line.
vim.o.undofile = true
vim.o.swapfile = false

-- System clipboard ------------------------------------------------------------
-- WHAT: Makes every yank/delete/paste use the macOS system clipboard (the
--       `+` register) by default.
-- WHY : Requested: seamless copy/paste with other applications. On macOS this
--       uses pbcopy/pbpaste — no extra tooling required, works in terminal
--       Neovim and Neovide alike.
-- HOW : If you'd rather keep Vim registers separate and copy explicitly, set
--       this to "" and use `"+y` / `"+p` (Neovide additionally maps Cmd+C/V —
--       see core/neovide.lua).
vim.o.clipboard = "unnamedplus"

-- Scrolling context -----------------------------------------------------------
-- WHAT: Minimum lines/columns kept visible around the cursor.
-- WHY : Keeps context in view when moving near window edges; 8 is a common
--       sweet spot (0 = cursor may sit on the very last line).
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- Whitespace rendering ----------------------------------------------------------
-- WHAT: `list` renders invisible characters using `listchars`.
-- WHY : Surfaces stray tabs, trailing spaces, and non-breaking spaces — the
--       usual invisible suspects in code review — without being noisy.
-- HOW : `:set nolist` to hide; add `eol:↴` etc. to taste (:h 'listchars').
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

-- Timing ----------------------------------------------------------------------
-- WHAT: `updatetime` is the idle delay (ms) before CursorHold fires and swap/
--       diagnostic-style features refresh (gitsigns uses it for blame).
--       `timeoutlen` is how long Neovim waits for the next key of a mapping.
-- WHY : 250ms updatetime keeps gutter/diagnostic UX snappy (default 4000 feels
--       dead). 500ms timeoutlen is enough to finish typing <leader> chords
--       without the default 1000ms lag on prefix keys.
vim.o.updatetime = 250
vim.o.timeoutlen = 500

-- Mouse -----------------------------------------------------------------------
-- WHAT: Enables mouse support in all modes (click to move, drag to select,
--       scroll, resize splits by dragging separators).
-- WHY : Essential in a GUI like Neovide; "a" (all modes) is Neovim's default,
--       set explicitly here so it is documented and easy to disable ("").
vim.o.mouse = "a"

-- Status line & mode indicator --------------------------------------------------
-- WHAT: `laststatus = 3` draws ONE global statusline at the very bottom
--       instead of one per window. `showmode = false` hides the built-in
--       "-- INSERT --" text.
-- WHY : A single statusline is cleaner with splits, and lualine (see
--       plugins/statusline.lua) already displays the mode — showing it twice
--       is noise.
-- HOW : Use `laststatus = 2` for the classic per-window statusline.
vim.o.laststatus = 3
vim.o.showmode = false

-- Confirm instead of fail -------------------------------------------------------
-- WHAT: Operations that would abort due to unsaved changes (:q, :e, buffer
--       switches) ask "Save changes?" instead of erroring with E37.
-- WHY : Friendlier than memorizing `:q!` vs `:wq` in the moment.
vim.o.confirm = true

-- Default border for floating windows -------------------------------------------
-- WHAT: Neovim 0.11+ global default border for floats (LSP hover, signature
--       help, diagnostics float, etc.).
-- WHY : Rounded borders make floats readable on any background without
--       configuring each plugin separately.
-- HOW : Options: "single", "double", "rounded", "solid", "shadow", "none".
vim.o.winborder = "rounded"

-- Folding ---------------------------------------------------------------------
-- WHAT: Folding is configured per-filetype by plugins/treesitter.lua (fold
--       ranges come from the syntax tree). These globals just ensure files
--       open with all folds expanded.
-- WHY : Starting fully folded (the default with an aggressive foldexpr) is
--       disorienting; folds should be opt-in via `zc`/`za`/`zM`.
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- True colour -----------------------------------------------------------------
-- WHAT: 24-bit RGB colours in the terminal.
-- WHY : Neovim auto-detects this on modern terminals (and Neovide always has
--       it); set explicitly for predictability on odd $TERM values.
vim.o.termguicolors = true

-- Column guides -----------------------------------------------------------------
-- WHAT: Vertical lines at the given columns, drawn with the ColorColumn
--       highlight group.
-- WHY : Four reference marks rather than one enforced limit. This REVERSES an
--       earlier decision to leave the option off, whose reasoning was that
--       line-length conventions differ per project (Rust 100, Python/ruff 88,
--       kernel C 80) and formatters enforce them anyway. That was an argument
--       against picking a SINGLE number, and it does not carry over: at four
--       columns none of them claims to be the limit, so whichever one a given
--       project cares about is already on screen.
--       The same four are set in Zed and in both VS Code editors, so a file
--       looks the same wherever it is opened.
-- NOTE: This option is WINDOW-local, and setting it here only supplies the
--       default that new windows inherit. On its own that puts all four lines
--       across `:help` pages, `:terminal` buffers and the file tree, which is
--       noise — core/autocmds.lua narrows it to real files. The two belong
--       together: changing the columns here is enough, because that autocmd
--       reads this value back rather than repeating it.
-- HOW : A comma-separated list of columns. Values may also be relative to
--       'textwidth' (`+1`, `-2`), which is unused here since these are
--       absolute. Set to "" to turn the guides off.
--       Every column shares ONE highlight group, so they cannot be coloured
--       individually — `:hi ColorColumn` restyles all four at once.
vim.o.colorcolumn = "80,120,150,200"
