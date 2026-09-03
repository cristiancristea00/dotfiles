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
vim.o.guifont = "JetBrainsMono Nerd Font Mono,FiraCode Nerd Font Mono,Fira Code,Source Code Pro,IBM Plex Mono:h14"

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

-- NOTE: Nothing here sets the cursor's SHAPE or whether it blinks. Neovide
--       renders `guicursor` directly, so both come from core/options.lua,
--       which asks for a blinking block in every mode. Everything in this
--       section tunes how the cursor MOVES, not what it looks like.
--       Two related Neovide knobs, deliberately left at their defaults:
--         vim.g.neovide_cursor_smooth_blink            -- fade the blink in
--                                                      -- and out instead of a
--                                                      -- hard on/off
--         vim.g.neovide_cursor_unfocused_outline_width -- the hollow cursor
--                                                      -- drawn when the window
--                                                      -- is not focused, which
--                                                      -- is the same choice
--                                                      -- made for VS Code's
--                                                      -- terminal.integrated.
--                                                      -- cursorStyleInactive

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

-- Platform split ------------------------------------------------------------------
-- WHAT: Everything below differs per operating system, so it branches here.
-- WHY : Neovide runs on macOS and Linux, and the modifier conventions are not
--       merely different — the wrong one is actively harmful. `<D-…>` is
--       Neovim's Command/Super modifier: on macOS it is ⌘, exactly right; on
--       Linux it is the Windows key, which GNOME and KDE grab system-wide, so
--       those mappings would register and then never fire. Guarding is what
--       keeps the config honest about what it actually does on each platform.
local is_macos = vim.uv.os_uname().sysname == "Darwin"
local map = vim.keymap.set

-- WHAT: Scale the UI by a factor, clamped so a runaway key repeat cannot make
--       the window unusable. Neovide multiplies the guifont size by this
--       rather than rewriting 'guifont'.
-- WHY : Defined once and bound to different keys per platform below.
local function zoom(delta)
    return function()
        local factor = (vim.g.neovide_scale_factor or 1.0) * delta
        vim.g.neovide_scale_factor = math.min(3.0, math.max(0.5, factor))
    end
end

if is_macos then
    -- macOS keyboard -----------------------------------------------------------
    -- WHAT: Make the LEFT Option key act as Meta/Alt (so <M-j>/<M-k> line-move
    --       maps work) while the RIGHT Option key keeps composing macOS special
    --       characters (é, ß, …).
    -- WHY : macOS-only. On Linux, Alt is already Meta, so nothing is needed —
    --       and this variable is simply never read there.
    -- HOW : Values: "none" (default), "only_left", "only_right", "both".
    vim.g.neovide_input_macos_option_key_is_meta = "only_left" -- Neovide default: "none"

    -- ⌘-key mappings -----------------------------------------------------------
    -- WHAT: Standard macOS shortcuts. Neovide delivers the Command key as the
    --       <D-...> modifier; terminals never see it, so these live here.
    -- NOTE: With clipboard=unnamedplus (core/options.lua) plain y/p already use
    --       the system clipboard — these exist for muscle memory and for the
    --       modes where y/p don't apply (insert, command-line, terminal).
    map("v", "<D-c>", '"+y', { desc = "Copy selection (⌘C)" })
    map({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste (⌘V)" })
    map("i", "<D-v>", "<C-r><C-o>+", { desc = "Paste (⌘V)" }) -- <C-o>: paste literally, don't autoindent
    map("c", "<D-v>", "<C-r>+", { desc = "Paste into command line (⌘V)" })
    map("t", "<D-v>", '<C-\\><C-n>"+pa', { desc = "Paste into terminal (⌘V)" })
    map("n", "<D-s>", "<cmd>write<CR>", { desc = "Save (⌘S)" })
    map("n", "<D-a>", "ggVG", { desc = "Select all (⌘A)" })

    -- WHAT: ⌘= / ⌘- scale the UI by ±10%, ⌘0 resets.
    map("n", "<D-=>", zoom(1.1), { desc = "Zoom in (⌘=)" })
    map("n", "<D-->", zoom(1 / 1.1), { desc = "Zoom out (⌘-)" })
    map("n", "<D-0>", function()
        vim.g.neovide_scale_factor = 1.0
    end, { desc = "Reset zoom (⌘0)" })
else
    -- Linux keyboard -----------------------------------------------------------
    -- WHAT: The same actions on Ctrl+Shift, the Linux terminal convention.
    -- WHY : Plain Ctrl+key is unavailable — Ctrl+C is SIGINT, Ctrl+V is Vim's
    --       VISUAL BLOCK (which must not be shadowed), Ctrl+A increments a
    --       number. Adding Shift frees the whole set, and matches what every
    --       Linux terminal already uses for copy and paste.
    --       Super was deliberately NOT used, even though Neovide would deliver
    --       it as <D-…>: desktop environments intercept it globally. This
    --       mirrors the same choice in ghostty/os-linux.conf, so the two
    --       agree.
    -- NOTE: These need a GUI that can distinguish Ctrl+Shift+key from
    --       Ctrl+key, which Neovide can and a terminal generally cannot — and
    --       this whole file only runs under Neovide anyway.
    map("v", "<C-S-c>", '"+y', { desc = "Copy selection (Ctrl+Shift+C)" })
    map({ "n", "v" }, "<C-S-v>", '"+p', { desc = "Paste (Ctrl+Shift+V)" })
    map("i", "<C-S-v>", "<C-r><C-o>+", { desc = "Paste (Ctrl+Shift+V)" })
    map("c", "<C-S-v>", "<C-r>+", { desc = "Paste into command line (Ctrl+Shift+V)" })
    map("t", "<C-S-v>", '<C-\\><C-n>"+pa', { desc = "Paste into terminal (Ctrl+Shift+V)" })
    map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save (Ctrl+S)" })
    map("n", "<C-S-a>", "ggVG", { desc = "Select all (Ctrl+Shift+A)" })

    -- WHAT: Ctrl+Shift+= / Ctrl+Shift+- scale the UI by ±10%, Ctrl+Shift+0 resets.
    map("n", "<C-S-=>", zoom(1.1), { desc = "Zoom in (Ctrl+Shift+=)" })
    map("n", "<C-S-->", zoom(1 / 1.1), { desc = "Zoom out (Ctrl+Shift+-)" })
    map("n", "<C-S-0>", function()
        vim.g.neovide_scale_factor = 1.0
    end, { desc = "Reset zoom (Ctrl+Shift+0)" })
end
