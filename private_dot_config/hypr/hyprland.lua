-- #######################################################################################
-- HYPRLAND CONFIG (Lua) — translated from hyprland.conf
--
-- The Lua config is opt-in: if this file exists it is loaded instead of hyprland.conf.
-- Delete or rename it to fall back to the old .conf.
--
-- Lines marked "⚠ VERIFY" use a dispatcher/keyword name that is NOT in the official
-- example config (example/hyprland.lua). The name follows the established pattern but
-- I couldn't confirm it — check against the wiki once and adjust if needed.
-- #######################################################################################

------------------------------------------------------------------------------------------
-- COLORS (catppuccin mocha — inlined; the old $... vars came from colors/mocha.conf,
-- which is hyprlang and can't be require()d. Only the ones actually used are defined.)
------------------------------------------------------------------------------------------
local mauve    = "rgb(cba6f7)"
local overlay0 = "rgb(6c7086)"
local overlay2 = "rgb(9399b2)"

------------------------------------------------------------------------------------------
-- PROGRAMS
------------------------------------------------------------------------------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -modi drun,combi -show drun -combi-modi window,drun,run"
local mainMod     = "SUPER"

------------------------------------------------------------------------------------------
-- ENVIRONMENT
------------------------------------------------------------------------------------------
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
-- Also set in ~/.config/environment.d/10-xdg.conf. Both are needed: this covers
-- processes Hyprland spawns, environment.d covers the systemd/D-Bus activated
-- ones (the xdg-desktop-portals). Without it in the portals' env the "Open With"
-- and app-chooser dialogs come up completely empty.
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("HYPRCURSOR_THEME", "GoogleDot-Black")
hl.env("HYPRCURSOR_SIZE", "24")

------------------------------------------------------------------------------------------
-- MONITORS
------------------------------------------------------------------------------------------
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })

-- Anything plugged into the laptop's own HDMI port -- a projector, a hotel TV,
-- someone else's monitor -- mirrors the panel instead of extending onto it.
--
-- HDMI-A-1 is the discriminator, not the EDID: it is the only HDMI connector on
-- this machine (see /sys/class/drm/card1-*) and the dock never uses it. All three
-- desk screens arrive over the Thunderbolt DP connectors as MST heads, so they
-- cannot collide with this rule no matter what they are called or who made them.
-- Matching on "not one of the four known displays" instead would mean guessing
-- EDID strings for screens that are not currently attached, and a wrong guess
-- mirrors the desk.
--
-- kanshi cannot express this itself -- wlr-output-management has no concept of
-- mirroring -- but it does not undo it either: a profile applied on top of a
-- mirrored head leaves mirrorOf alone (verified 2026-09-09 against kanshi's
-- `fallback` profile, which is what will match panel + projector). So the two
-- coexist: Hyprland decides this head is a mirror, kanshi keeps owning the rest.
--
-- Note when debugging: a mirrored head is hidden from `hyprctl monitors` and
-- only shows up under `hyprctl monitors all`.
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

------------------------------------------------------------------------------------------
-- LOOK AND FEEL / VARIABLES
------------------------------------------------------------------------------------------
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in  = 0,
        gaps_out = 0,
        border_size = 1,
        col = {
            active_border   = mauve,
            inactive_border = overlay0,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    
    group = {
        -- Border around the group (separate from general.col.*)
        col = {
            border_active          = mauve,
            border_inactive        = overlay0,
            border_locked_active   = "rgb(fab387)",  -- peach: locked groups stand out
            border_locked_inactive = overlay0,
        },

        groupbar = {
            enabled       = true,
            render_titles = true,           -- false = just thin coloured bars
            font_family   = "JetBrainsMono Nerd Font",             -- empty = misc.font_family
            font_size     = 14,
            font_weight_active   = "bold",
            font_weight_inactive = "normal",
            text_color    = "rgb(cdd6f4)",  -- catppuccin text

            height           = 16,          -- height of the title area
            indicator_height = 0,           -- coloured line under each tab
            gradients        = true,       -- true = filled tab backgrounds in col.*
            gaps_in          = 0,
	    stacked          = false,       -- true = tabs stacked vertically

            col = {
                active          = mauve,
                inactive        = overlay0,
                locked_active   = "rgb(fab387)",
                locked_inactive = overlay0,
            },
        },
    },

    decoration = {
        rounding = 0,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = true, range = 4, render_power = 3, color = overlay2 },
        blur   = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },

    animations = { enabled = true },

    master = { new_status = "master" },

    misc = {
        on_focus_under_fullscreen = 1,
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },

    input = {
        kb_layout  = "gb",
        kb_variant = "extd",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },
})

------------------------------------------------------------------------------------------
-- ANIMATION CURVES
------------------------------------------------------------------------------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

------------------------------------------------------------------------------------------
-- ANIMATIONS
------------------------------------------------------------------------------------------
hl.animation({ leaf = "global",        enabled = true, speed = 1,    bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

------------------------------------------------------------------------------------------
-- INPUT: gestures & per-device
------------------------------------------------------------------------------------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

------------------------------------------------------------------------------------------
-- AUTOSTART
------------------------------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("ashell")
    -- Started as a user unit rather than a bare process so its "applying
    -- profile" output lands in the journal; as an exec-once child it went to
    -- /dev/null, which is why display bugs left no trace. Started here rather
    -- than enabled because graphical-session.target never activates on this
    -- setup, and by now Hyprland has imported WAYLAND_DISPLAY into systemd.
    hl.exec_cmd("systemctl --user start kanshi.service")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- ⚠ VERIFY: exec with a rule prefix. Old syntax was
    -- exec-once = [workspace special:TTY silent] kitty. Keeping the prefix in the
    -- command string; if the Lua exec parser doesn't read it, use a per-app options table.
    hl.exec_cmd("[workspace special:TTY silent] kitty")
    hl.exec_cmd("[workspace special:VAR silent] keepassxc")
    hl.exec_cmd('[workspace special:VAR silent] signal-desktop --password-store="kwallet6"')

    hl.exec_cmd("clipse -listen") -- clipboard listener
end)

------------------------------------------------------------------------------------------
-- KEYBINDINGS
------------------------------------------------------------------------------------------
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd([[pkill -f "^kitty.*--class clipse" || kitty --class clipse -e 'clipse']]))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind("ALT + Space", hl.dsp.exec_cmd("pkill rofi || " .. menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd([[pkill -f "^kitty.*--class of" || kitty --override close_on_child_death=yes --class of -e fish -c of]]))
hl.bind("PRINT", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload && killall ashell && ashell"))

-- Cycle keyboard modifier modes: NORMAL -> STRICT (home row only) -> OFF
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("$HOME/.config/kmonad/cycle-mods"),
    { description = "cycle keyboard mod modes" })

-- Cycle windows; if floating bring to top
hl.bind("ALT + tab", hl.dsp.window.cycle_next({ direction = "next" }), { description = "cycle next window" })
hl.bind("ALT + tab", hl.dsp.window.bring_to_top(), { description = "bring active to top" })

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Swap windows
local dirs = { left = "l", right = "r", up = "u", down = "d" }
for dir, m in pairs(dirs) do
    hl.bind(mainMod .. " + SHIFT + " .. dir,        hl.dsp.window.swap({ direction = dir }))
    hl.bind(mainMod .. " + CTRL + " .. dir,         hl.dsp.workspace.move({ monitor = m }))  -- workspace -> monitor
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. dir, hl.dsp.window.move({ monitor = m }))     -- window -> monitor
    hl.bind(mainMod .. " + ALT + " .. dir,          hl.dsp.window.move({ direction = dir, group_aware = true })) -- into/out of group
end

hl.bind(mainMod .. " + G",           hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab",         hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())

-- Switch workspaces --
for ws = 1, 9 do
    hl.bind(mainMod .. " + " .. ws, hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- Special workspaces
hl.bind(mainMod .. " + J", hl.dsp.workspace.toggle_special("VAR"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ workspace = "special:VAR" }))
hl.bind(mainMod .. " + Return", hl.dsp.workspace.toggle_special("TTY"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.window.move({ workspace = "special:TTY" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" })) -- ⚠ VERIFY (relative workspace via scroll)
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" })) -- ⚠ VERIFY

-- Screen lock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys (locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                     { locked = true, repeating = true })

-- Media control (locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------------------------------------------------------------------------------
-- WINDOW RULES
------------------------------------------------------------------------------------------
-- Autostart maximize on special:VAR
hl.window_rule({
    name = "autostart",
    match = { workspace = "name:special:VAR" },
    maximize = true,
    no_anim = true,
})

-- Ignore maximize requests from apps
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "clipse",
    match = { class = "(clipse)" },
    float = true,
    size = { 622, 652 }, -- ⚠ VERIFY (size table format)
    no_anim = true,
})

hl.window_rule({
    name = "of",
    match = { class = "(of)" },
    float = true,
    size = { 960, 600 }, -- ⚠ VERIFY
    no_anim = true,
})

-- Fix XWayland dragging issues
hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

------------------------------------------------------------------------------------------
-- LAYER RULES
------------------------------------------------------------------------------------------
-- Disable animations for rofi (layer rules match by namespace, not class)
hl.layer_rule({
    name = "rofi-no-anim",
    match = { namespace = "^rofi$" }, -- ⚠ VERIFY (was match:class in .conf; layers use namespace)
    no_anim = true,
})
------------------------------------------------------------------------------------------
-- WORKSPACE RULES
------------------------------------------------------------------------------------------
hl.workspace_rule({ workspace = "special:TTY", persistent = true })
hl.workspace_rule({ workspace = "special:VAR", persistent = true })
