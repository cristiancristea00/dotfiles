--[[===========================================================================
  core/neovide.lua — font + everything Neovide-specific
  ============================================================================

  Neovide reads its behavior from `vim.g.neovide_*` variables set anywhere in
  the config (:h neovide, https://neovide.dev/configuration.html). It also
  sets `vim.g.neovide = true`, which this file uses as a guard so terminal
  Neovim skips the GUI-only parts.

  NOTE: This file is one half of the Neovide setup. Process- and window-level
  settings that must exist BEFORE Neovim starts (window frame, startup font,
  vsync/sRGB, fork, native tabs) live in Neovide's own config file: the
  dotfiles repo's neovide/.config/neovide/config.toml, installed at
  ~/.config/neovide/config.toml. This file owns runtime behaviour:
  animations, macOS cmd-key bindings, live zoom.

  Tuning chosen here: "subtle & fast" — animations are kept (they carry real
  information about where the cursor/viewport went) but shortened so the
  editor never feels like it is waiting for an effect to finish. Every value
  is annotated with Neovide's own default so you can dial back toward stock
  behavior.
===========================================================================]]--

-- Font ------------------------------------------------------------------------
-- WHAT: The GUI font, "<family>:h<size>". Applies to *all* text Neovide
--       renders. The Nerd Font build of JetBrains Mono additionally contains
--       the icon glyphs used by the statusline, file explorer, and
--       diagnostics signs.
-- WHY : Set unconditionally (not just under Neovide) — terminals ignore
--       'guifont', so this is harmless in a TUI and means any other GUI would
--       pick it up too. Installed via the repo's Brewfile (cask
--       "font-jetbrains-mono-nerd-font").
--       The MONO build is deliberate: Neovim draws icon glyphs in the
--       statusline, file tree and diagnostic gutter, and the Mono build keeps
--       each of them to exactly one cell so columns stay aligned. The
--       remaining families are per-glyph fallbacks, comma-separated.
-- HOW : Change the size after :h (e.g. :h16). Live zoom: ⌘= / ⌘- / ⌘0 below.
--       KEEP IN SYNC with the [font] section in neovide/config.toml — that
--       file sets the same font for Neovide's first frames (before init.lua
--       runs); this option takes over for the rest of the session.
vim.o.guifont = "JetBrainsMono Nerd Font Mono,Fira Code,Source Code Pro,IBM Plex Mono:h14"

-- Everything below only applies inside Neovide --------------------------------
if not vim.g.neovide then
    return
end

-- Cursor animation ---------------------------------------------------------------
-- WHAT: How long (seconds) the cursor takes to glide to its new position, and
--       how much of a "trail" the cursor block stretches while moving.
-- WHY : Neovide defaults (length 0.150, trail 1.0) look springy but feel
--       laggy when navigating fast. 0.04/0.3 keeps the "where did the cursor
--       go" affordance while staying essentially instant.
-- HOW : Set length to 0 to disable cursor animation entirely.
vim.g.neovide_cursor_animation_length = 0.04 -- Neovide default: 0.150
vim.g.neovide_cursor_trail_size = 0.3 -- Neovide default: 1.0

-- WHAT: Animate the cursor inside insert mode / the command line too.
-- WHY : Insert-mode animation stays on (default) — with the short durations
--       above it reads as smooth, not sluggish. Command-line animation is
--       disabled: the cmdline cursor jumping around during `:` commands is
--       the one place the effect distracts.
vim.g.neovide_cursor_animate_in_insert_mode = true -- Neovide default: true
vim.g.neovide_cursor_animate_command_line = false -- Neovide default: true

-- WHAT: Particle effects emitted by the cursor ("railgun", "torpedo",
--       "pixiedust", "sonicboom", "ripple", "wireframe").
-- WHY : Off — pure visual noise for daily work. Fun to try once.
vim.g.neovide_cursor_vfx_mode = "" -- Neovide default: "" (off)

-- Scroll & window animation --------------------------------------------------------
-- WHAT: Duration of the smooth-scroll effect and of window position changes
--       (splits opening/closing, resizes).
-- WHY : Halved-ish from defaults: still communicates scroll direction and
--       distance, never makes you wait for the viewport.
vim.g.neovide_scroll_animation_length = 0.15 -- Neovide default: 0.3
vim.g.neovide_position_animation_length = 0.10 -- Neovide default: 0.15

-- Transparency / blur (kept opaque) --------------------------------------------------
-- WHAT: `neovide_opacity` < 1.0 makes the whole window translucent;
--       `neovide_window_blurred` adds a macOS background blur behind it.
-- WHY : Kept fully opaque for text crispness ("subtle & fast" choice).
--       Uncomment to taste:
-- vim.g.neovide_opacity = 0.95
-- vim.g.neovide_window_blurred = true

-- Quality of life ---------------------------------------------------------------
-- WHAT: Hide the mouse pointer while typing (reappears on move).
vim.g.neovide_hide_mouse_when_typing = true -- Neovide default: false

-- WHAT: Reopen with the same window size (and position) as last session.
vim.g.neovide_remember_window_size = true -- Neovide default: true

-- WHAT: Ask before closing the window with unsaved changes, mirroring
--       vim.o.confirm for the ⌘Q / close-button path.
vim.g.neovide_confirm_quit = true -- Neovide default: true

-- macOS keyboard ---------------------------------------------------------------
-- WHAT: Make the LEFT Option key act as Meta/Alt (so <M-j>/<M-k> line-move
--       maps work) while the RIGHT Option key keeps composing macOS special
--       characters (é, ß, …).
-- HOW : Values: "none" (default), "only_left", "only_right", "both".
vim.g.neovide_input_macos_option_key_is_meta = "only_left" -- Neovide default: "none"

-- ⌘-key mappings ----------------------------------------------------------------
-- WHAT: Standard macOS shortcuts. Neovide delivers the Command key as the
--       <D-...> modifier; terminals never see it, so these live here.
-- NOTE: With clipboard=unnamedplus (core/options.lua) plain y/p already use
--       the system clipboard — these exist for muscle memory and for the
--       modes where y/p don't apply (insert, command-line, terminal).
local map = vim.keymap.set
map("v", "<D-c>", '"+y', { desc = "Copy selection (⌘C)" })
map({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste (⌘V)" })
map("i", "<D-v>", "<C-r><C-o>+", { desc = "Paste (⌘V)" }) -- <C-o>: paste literally, don't autoindent
map("c", "<D-v>", "<C-r>+", { desc = "Paste into command line (⌘V)" })
map("t", "<D-v>", '<C-\\><C-n>"+pa', { desc = "Paste into terminal (⌘V)" })
map("n", "<D-s>", "<cmd>write<CR>", { desc = "Save (⌘S)" })
map("n", "<D-a>", "ggVG", { desc = "Select all (⌘A)" })

-- Live font zoom ------------------------------------------------------------------
-- WHAT: ⌘= / ⌘- scale the UI by ±10%, ⌘0 resets. Implemented via Neovide's
--       scale factor, which multiplies the guifont size without changing it.
local function zoom(delta)
    return function()
        local factor = (vim.g.neovide_scale_factor or 1.0) * delta
        -- Clamp so a runaway key repeat can't make the UI unusable.
        vim.g.neovide_scale_factor = math.min(3.0, math.max(0.5, factor))
    end
end
map("n", "<D-=>", zoom(1.1), { desc = "Zoom in (⌘=)" })
map("n", "<D-->", zoom(1 / 1.1), { desc = "Zoom out (⌘-)" })
map("n", "<D-0>", function()
    vim.g.neovide_scale_factor = 1.0
end, { desc = "Reset zoom (⌘0)" })
