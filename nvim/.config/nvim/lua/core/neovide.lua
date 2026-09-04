--[[===========================================================================
  core/neovide.lua — font and everything Neovide-specific
  ============================================================================

  Neovide reads its behaviour from `vim.g.neovide_*` variables (:h neovide,
  https://neovide.dev/configuration.html) and sets `vim.g.neovide = true`,
  which this file uses as a guard so terminal Neovim skips the GUI-only parts.

  This file is one half of the Neovide setup: runtime behaviour (animations,
  macOS cmd-key bindings, live zoom). Process- and window-level settings that
  must exist before Neovim starts live in neovide/.config/neovide/config.toml,
  whose header describes the split.

  Animations are kept but shortened. Every value carries Neovide's default.
===========================================================================]]--

-- Font ------------------------------------------------------------------------
-- WHAT: The GUI font, "<family>:h<size>", for all text Neovide renders. The
--       remaining families are per-glyph fallbacks, comma-separated.
-- WHY : Set unconditionally because terminals ignore 'guifont', so a TUI is
--       unaffected. The Nerd Font Mono build supplies the icons the
--       statusline, file tree, and diagnostic gutter draw, at one cell each;
--       see ../../../../../README.md § The font stack.
-- HOW : Change the size after :h (e.g. :h16); ⌘= / ⌘- / ⌘0 zoom live (below).
--       Keep family and size equal to the [font] section in
--       neovide/config.toml, which covers the frames before this file runs.
vim.o.guifont = "JetBrainsMono Nerd Font Mono,FiraCode Nerd Font Mono,Fira Code,Source Code Pro,IBM Plex Mono:h14"

-- Everything below only applies inside Neovide --------------------------------
if not vim.g.neovide then
    return
end

-- WHAT: Whether this is macOS, used by the blur below and the ⌘ bindings at
--       the bottom of the file.
-- WHY : Declared once here rather than tested twice.
local is_macos = vim.uv.os_uname().sysname == "Darwin"

-- Cursor animation ---------------------------------------------------------------
-- WHAT: How long, in seconds, the cursor takes to reach its new position, and
--       how far the cursor block stretches while moving.
-- WHY : The defaults (0.150 and 1.0) lag behind fast navigation. 0.04 and 0.3
--       keep the movement visible and finish in about two frames at 60 Hz.
-- HOW : Set length to 0 to disable cursor animation.
vim.g.neovide_cursor_animation_length = 0.04 -- Neovide default: 0.150
vim.g.neovide_cursor_trail_size = 0.3 -- Neovide default: 1.0

-- WHAT: Animate the cursor in insert mode and on the command line.
-- WHY : Insert mode keeps the default. The command line is turned off because
--       the cursor moves on every keystroke of a `:` command.
vim.g.neovide_cursor_animate_in_insert_mode = true -- Neovide default: true
vim.g.neovide_cursor_animate_command_line = false -- Neovide default: true

-- NOTE: The cursor's shape and blink come from `guicursor` in
--       core/options.lua, which Neovide renders directly. Two related Neovide
--       variables stay at their defaults: neovide_cursor_smooth_blink (fade the
--       blink) and neovide_cursor_unfocused_outline_width (the hollow cursor
--       drawn when the window is unfocused, the same choice as VS Code's
--       cursorStyleInactive).

-- WHAT: Particle effects emitted by the cursor ("railgun", "torpedo",
--       "pixiedust", "sonicboom", "ripple", "wireframe").
-- WHY : Off, the default.
vim.g.neovide_cursor_vfx_mode = "" -- Neovide default: "" (off)

-- Scroll and window animation --------------------------------------------------------
-- WHAT: Duration of the smooth-scroll effect and of window position changes
--       (splits opening and closing, resizes).
-- WHY : About half the defaults: the direction and distance of a scroll stay
--       visible without delaying the viewport.
vim.g.neovide_scroll_animation_length = 0.15 -- Neovide default: 0.3
vim.g.neovide_position_animation_length = 0.10 -- Neovide default: 0.15

-- Transparency and blur ----------------------------------------------------------
-- WHAT: `neovide_opacity` below 1.0 makes the window translucent;
--       `neovide_window_blurred` blurs whatever shows through it.
-- WHY : The same pair of values as `background-opacity` and
--       `background-blur` in ghostty/config.ghostty, so the editor and the
--       terminal sit at the same depth on the desktop.
-- NOTE: The blur is macOS-only and Neovide ignores the variable elsewhere,
--       hence the guard. Its strength follows the opacity value, so the two
--       are changed together.
-- HOW : Set the opacity to 1.0 for an opaque window; the blur then has
--       nothing to show through and can go.
vim.g.neovide_opacity = 0.95 -- Neovide default: 1.0
if is_macos then
    vim.g.neovide_window_blurred = true -- Neovide default: false
end

-- Quality of life ---------------------------------------------------------------
-- WHAT: Hide the mouse pointer while typing; it reappears on movement.
-- WHY : Matches mouse-hide-while-typing in ghostty/config.ghostty. Off by default.
vim.g.neovide_hide_mouse_when_typing = true -- Neovide default: false

-- WHAT: Reopen with the window size and position of the last session.
-- WHY : The default. Stated because `maximized = true` in
--       neovide/config.toml would take priority over the remembered size at
--       startup (Neovide's src/window/mod.rs, determine_window_size).
vim.g.neovide_remember_window_size = true -- Neovide default: true

-- WHAT: Ask before closing the window with unsaved changes.
-- WHY : Covers the ⌘Q and close-button path the way vim.o.confirm covers :q.
--       The default.
vim.g.neovide_confirm_quit = true -- Neovide default: true

-- Platform split ------------------------------------------------------------------
-- WHAT: Everything below differs per operating system, so it branches here.
-- WHY : `<D-…>` is Neovim's Command/Super modifier: ⌘ on macOS, the Windows
--       key on Linux, which GNOME and KDE reserve, so those mappings would
--       register and never fire there. The Linux Ghostty config
--       (ghostty/os-linux.ghostty) makes the same choice.
local map = vim.keymap.set

-- WHAT: Scale the UI by a factor, clamped between 0.5 and 3.0 so a held key
--       cannot make the window unusable. Neovide multiplies the guifont size
--       by this factor rather than rewriting 'guifont'.
-- WHY : Defined once and bound to different keys per platform below.
local function zoom(delta)
    return function()
        local factor = (vim.g.neovide_scale_factor or 1.0) * delta
        vim.g.neovide_scale_factor = math.min(3.0, math.max(0.5, factor))
    end
end

if is_macos then
    -- macOS keyboard -----------------------------------------------------------
    -- WHAT: Make the left Option key act as Meta/Alt, so the <M-j> and <M-k>
    --       maps work, while the right Option key keeps composing macOS special
    --       characters (é, ß, …).
    -- WHY : On Linux, Alt is already Meta, and this variable is never read.
    --       Matches macos-option-as-alt in ghostty/os-darwin.ghostty.
    -- HOW : Values: "none" (default), "only_left", "only_right", "both".
    vim.g.neovide_input_macos_option_key_is_meta = "only_left" -- Neovide default: "none"

    -- ⌘-key mappings -----------------------------------------------------------
    -- WHAT: Standard macOS shortcuts. Neovide delivers the Command key as the
    --       <D-...> modifier; terminals never see it.
    -- WHY : With clipboard=unnamedplus (core/options.lua) plain y and p already
    --       use the system clipboard; these cover the modes where y and p do
    --       not apply (insert, command-line, terminal) and the standard keys.
    map("v", "<D-c>", '"+y', { desc = "Copy selection (⌘C)" })
    map({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste (⌘V)" })
    map("i", "<D-v>", "<C-r><C-o>+", { desc = "Paste (⌘V)" }) -- <C-o>: paste literally, no autoindent
    map("c", "<D-v>", "<C-r>+", { desc = "Paste into command line (⌘V)" })
    map("t", "<D-v>", '<C-\\><C-n>"+pa', { desc = "Paste into terminal (⌘V)" })
    map("n", "<D-s>", "<cmd>write<CR>", { desc = "Save (⌘S)" })
    map("n", "<D-a>", "ggVG", { desc = "Select all (⌘A)" })

    -- WHAT: ⌘= and ⌘- scale the UI by 10%; ⌘0 resets.
    -- WHY : Neovide has no zoom keys of its own; the scale factor is the
    --       documented way to zoom without changing 'guifont'.
    map("n", "<D-=>", zoom(1.1), { desc = "Zoom in (⌘=)" })
    map("n", "<D-->", zoom(1 / 1.1), { desc = "Zoom out (⌘-)" })
    map("n", "<D-0>", function()
        vim.g.neovide_scale_factor = 1.0
    end, { desc = "Reset zoom (⌘0)" })
else
    -- Linux keyboard -----------------------------------------------------------
    -- WHAT: The same actions on Ctrl+Shift, the Linux terminal convention.
    -- WHY : Plain Ctrl+key is taken: Ctrl+C is SIGINT, Ctrl+V is Vim's visual
    --       block mode, Ctrl+A increments a number. Super is not used because
    --       desktop environments intercept it (see the platform split above).
    -- NOTE: Ctrl+Shift+key is distinguishable from Ctrl+key in a GUI such as
    --       Neovide, but generally not in a terminal; this file runs only
    --       under Neovide.
    map("v", "<C-S-c>", '"+y', { desc = "Copy selection (Ctrl+Shift+C)" })
    map({ "n", "v" }, "<C-S-v>", '"+p', { desc = "Paste (Ctrl+Shift+V)" })
    map("i", "<C-S-v>", "<C-r><C-o>+", { desc = "Paste (Ctrl+Shift+V)" })
    map("c", "<C-S-v>", "<C-r>+", { desc = "Paste into command line (Ctrl+Shift+V)" })
    map("t", "<C-S-v>", '<C-\\><C-n>"+pa', { desc = "Paste into terminal (Ctrl+Shift+V)" })
    map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save (Ctrl+S)" })
    map("n", "<C-S-a>", "ggVG", { desc = "Select all (Ctrl+Shift+A)" })

    -- WHAT: Ctrl+Shift+= and Ctrl+Shift+- scale the UI by 10%; Ctrl+Shift+0
    --       resets.
    -- WHY : As for the ⌘ zoom keys above.
    map("n", "<C-S-=>", zoom(1.1), { desc = "Zoom in (Ctrl+Shift+=)" })
    map("n", "<C-S-->", zoom(1 / 1.1), { desc = "Zoom out (Ctrl+Shift+-)" })
    map("n", "<C-S-0>", function()
        vim.g.neovide_scale_factor = 1.0
    end, { desc = "Reset zoom (Ctrl+Shift+0)" })
end
