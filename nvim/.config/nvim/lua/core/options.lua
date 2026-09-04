--[[===========================================================================
  core/options.lua — editor options
  ============================================================================

  `vim.o` is the scalar accessor for options (:h vim.o). List options take a
  comma-separated string through it; `vim.opt` offers a set-like API, but
  vim.o keeps this file uniform.

  Per-filetype overrides go in after/ftplugin/<filetype>.lua, e.g.
  after/ftplugin/yaml.lua containing `vim.bo.shiftwidth = 2`. Neovim sources
  it whenever a buffer of that filetype opens.
===========================================================================]]--

-- Line numbers ----------------------------------------------------------------
-- WHAT: `number` shows the absolute line number on the cursor line;
--       `relativenumber` shows distances (1, 2, 3, ...) on the other lines.
-- WHY : Relative numbers give the count for motions such as `5j`; the absolute
--       number on the current line gives the position in the file.
-- HOW : `vim.o.relativenumber = false` for absolute numbers everywhere.
vim.o.number = true
vim.o.relativenumber = true

-- Sign column -----------------------------------------------------------------
-- WHAT: The column left of the numbers where diagnostic and git signs appear.
-- WHY : "yes" reserves it permanently. The default, "auto", shifts the text
--       area right when the first sign appears.
-- HOW : "yes:2" reserves two cells; "number" merges signs into the number
--       column.
vim.o.signcolumn = "yes"

-- Cursor line -----------------------------------------------------------------
-- WHAT: Highlight the screen line the cursor is on.
-- WHY : Marks the cursor row in large windows. Off by default.
vim.o.cursorline = true

-- Cursor shape ----------------------------------------------------------------
-- WHAT: The cursor's shape and blink timing per mode. `a:` covers all modes.
-- WHY : A blinking block in every mode, like every other tool in the stack;
--       see ../../../../../README.md § The cursor. Neovim's default,
--       n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor,
--       varies the shape by mode (a bar in insert, a horizontal line in
--       replace).
-- NOTE: The `t:` entry is not redundant. Entries apply left to right, so it
--       overrides `a:` for terminal mode only, and it exists to keep the
--       `TermCursor` highlight group, which colours the :terminal cursor. A
--       bare `a:block` drops the group and the terminal cursor changes colour.
-- NOTE: A typo here is accepted without an error (`set guicursor=a:nonsense`
--       is reported back verbatim) and shows up as a cursor that never
--       changes. Check the applied value with `:set guicursor?`.
-- HOW : Neovide renders this option directly; in a terminal Neovim translates
--       it into DECSCUSR escapes, which Ghostty honours. For a steady cursor,
--       drop the three blink fields. `:set guicursor&` restores the default.
vim.o.guicursor = "a:block-blinkwait700-blinkoff400-blinkon250,"
    .. "t:block-blinkwait700-blinkoff400-blinkon250-TermCursor"

-- Indentation -----------------------------------------------------------------
-- WHAT: `expandtab` inserts spaces for <Tab>; `tabstop` is the display width
--       of a tab character; `shiftwidth` is the width of indent operations
--       (>>, <<, autoindent); `softtabstop = -1` makes <Tab> in insert mode
--       follow shiftwidth; `shiftround` snaps >> and << to a multiple of
--       shiftwidth; `breakindent` indents wrapped lines to match.
-- WHY : Four spaces suits the C-family, Rust, and Python mix here. Languages
--       with a two-space convention (YAML) are covered by Neovim's built-in
--       ftplugins or by .editorconfig, which Neovim reads natively and which
--       overrides these values; the header says where to add more.
-- HOW : Change the two `4`s.
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = -1
vim.o.shiftround = true
vim.o.breakindent = true

-- Line wrapping ---------------------------------------------------------------
-- WHAT: `wrap = false` lets long lines run off-screen. `linebreak` applies only
--       when wrap is on and breaks at word boundaries instead of mid-word.
-- WHY : Wrapped code lines are hard to scan, and lines kept within the column
--       guides rarely need horizontal scrolling. Neovim wraps by default.
-- HOW : Toggle per window with `:set wrap!`.
vim.o.wrap = false
vim.o.linebreak = true

-- Searching -------------------------------------------------------------------
-- WHAT: `ignorecase` plus `smartcase`: case-insensitive search unless the
--       pattern contains an uppercase letter. `inccommand = "split"` previews
--       :substitute in a split while typing.
-- WHY : Neovim's default search is case-sensitive. `hlsearch` stays at its
--       default (on); <Esc> in core/keymaps.lua clears the highlight instead.
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- Splits ----------------------------------------------------------------------
-- WHAT: Where new windows open relative to the current one.
-- WHY : Right and below match reading order and the other editors here. Vim's
--       default opens left and above.
vim.o.splitright = true
vim.o.splitbelow = true

-- Undo, swap ------------------------------------------------------------------
-- WHAT: `undofile` persists undo history to disk, so undo survives :q and
--       restarts. `swapfile = false` disables the .swp crash-recovery files.
-- WHY : Persistent undo recovers more than swap files do, and swap files
--       cause the "E325: ATTENTION" prompt after a crash or a second instance.
-- HOW : To get collision warnings back when editing the same file from two
--       instances, delete the swapfile line.
vim.o.undofile = true
vim.o.swapfile = false

-- System clipboard ------------------------------------------------------------
-- WHAT: Every yank, delete, and paste uses the system clipboard (the `+`
--       register).
-- WHY : Copy and paste work with other applications without a register
--       prefix. macOS has pbcopy and pbpaste built in; Linux needs
--       wl-clipboard or xclip (in the Brewfile), and `:checkhealth
--       vim.provider` reports which is found.
-- HOW : Set "" to keep Vim registers separate and use `"+y` / `"+p`. Neovide
--       also maps ⌘C / ⌘V (core/neovide.lua).
vim.o.clipboard = "unnamedplus"

-- Scrolling context -----------------------------------------------------------
-- WHAT: Minimum lines and columns kept visible around the cursor.
-- WHY : Keeps context in view near window edges. The default, 0, lets the
--       cursor sit on the last line.
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- Whitespace rendering ----------------------------------------------------------
-- WHAT: `list` renders invisible characters using `listchars`.
-- WHY : Shows tabs, trailing spaces, and non-breaking spaces, which are
--       otherwise invisible. Off by default.
-- HOW : `:set nolist` to hide; add `eol:↴` and others per :h 'listchars'.
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

-- Timing ----------------------------------------------------------------------
-- WHAT: `updatetime` is the idle delay in ms before CursorHold fires (gitsigns
--       uses it for blame). `timeoutlen` is how long Neovim waits for the next
--       key of a mapping.
-- WHY : 250 ms updatetime refreshes gutter and diagnostic displays promptly;
--       the default is 4000. 500 ms timeoutlen leaves time to finish a
--       <leader> chord; the default is 1000.
vim.o.updatetime = 250
vim.o.timeoutlen = 500

-- Mouse -----------------------------------------------------------------------
-- WHAT: Mouse support in all modes: click to move, drag to select, scroll,
--       resize splits by dragging separators.
-- WHY : The default is "nvi"; "a" adds the Command-line and remaining modes.
--       Set "" to disable the mouse.
vim.o.mouse = "a"

-- Status line and mode indicator --------------------------------------------------
-- WHAT: `laststatus = 3` draws one global statusline at the bottom instead of
--       one per window. `showmode = false` hides the built-in "-- INSERT --"
--       text.
-- WHY : One statusline takes less space with splits, and lualine
--       (plugins/statusline.lua) already shows the mode. The defaults are 2
--       and on.
-- HOW : `laststatus = 2` for the per-window statusline.
vim.o.laststatus = 3
vim.o.showmode = false

-- Confirm instead of fail -------------------------------------------------------
-- WHAT: Operations that would abort on unsaved changes (:q, :e, buffer
--       switches) ask "Save changes?" instead of failing with E37.
-- WHY : Saves retyping the command as `:q!` or `:wq`. Off by default.
vim.o.confirm = true

-- Default border for floating windows -------------------------------------------
-- WHAT: Global default border for floats (LSP hover, signature help, the
--       diagnostics float); Neovim 0.11 or later.
-- WHY : A border separates the float from the text behind it without
--       configuring each plugin. The default is no border.
-- HOW : Options: "single", "double", "rounded", "bold", "solid", "shadow",
--       "none", or a list of eight border characters.
vim.o.winborder = "rounded"

-- Folding ---------------------------------------------------------------------
-- WHAT: Open every file with all folds expanded. Fold ranges come from
--       plugins/treesitter.lua per filetype.
-- WHY : With a foldexpr set, the default foldlevel of 0 opens files fully
--       folded. Folds are opened by hand with `zc`, `za`, and `zM`.
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- True colour -----------------------------------------------------------------
-- WHAT: 24-bit RGB colours in the terminal.
-- WHY : Neovim detects this on modern terminals and Neovide always has it;
--       set so an unusual $TERM value does not turn it off.
vim.o.termguicolors = true

-- Column guides -----------------------------------------------------------------
-- WHAT: Vertical lines at the given columns, drawn with the ColorColumn
--       highlight group.
-- WHY : Three reference marks rather than one enforced limit; the same three
--       are set in Zed and VS Code. See ../../../../../README.md § Column
--       guides.
-- NOTE: The option is window-local, so this value is the default new windows
--       inherit. The autocmd in core/autocmds.lua limits it to real files
--       and reads this value back, so the columns are written only here.
-- HOW : A comma-separated list of columns; values relative to 'textwidth'
--       (`+1`, `-2`) also work. "" turns the guides off. All columns share
--       one highlight group, so `:hi ColorColumn` restyles them together.
vim.o.colorcolumn = "80,120,150"
