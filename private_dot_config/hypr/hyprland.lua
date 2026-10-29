-- Hyprland config (Lua). Loaded instead of hyprland.conf while this file exists.
-- Session is started through uwsm: environment variables live in ~/.config/uwsm/env*,
-- daemons (hyprpaper, hypridle, kanshi, ...) are systemd user services.
--
-- "⚠ VERIFY" marks syntax not confirmed against example/hyprland.lua.

------------------------------------------------------------------------------------------
-- Colors (catppuccin mocha)
------------------------------------------------------------------------------------------
local mauve    = "rgb(cba6f7)"
local peach    = "rgb(fab387)"
local text     = "rgb(cdd6f4)"
local overlay0 = "rgb(6c7086)"
local overlay2 = "rgb(9399b2)"

------------------------------------------------------------------------------------------
-- Programs
------------------------------------------------------------------------------------------
local mainMod = "SUPER"

-- Launch through uwsm so every app gets its own systemd scope.
local function app(cmd) return "uwsm app -- " .. cmd end

local fileManager = app("dolphin")
local menu        = [[rofi -modi drun,combi -show drun -combi-modi window,drun,run -run-command "uwsm app -- {cmd}"]]

------------------------------------------------------------------------------------------
-- Monitors
------------------------------------------------------------------------------------------
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })

-- The laptop's own HDMI port (projectors, hotel TVs, ...) always mirrors the panel.
-- HDMI-A-1 is the only HDMI connector on this machine and the dock never uses it --
-- the desk screens arrive as Thunderbolt DP/MST heads -- so matching on the connector
-- is safe without guessing EDIDs. kanshi can't express mirroring but leaves it alone
-- (verified 2026-09-09 with its `fallback` profile).
-- Debugging: mirrored heads only show up in `hyprctl monitors all`.
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

------------------------------------------------------------------------------------------
-- General settings
------------------------------------------------------------------------------------------
hl.config({
    xwayland = { force_zero_scaling = true },

    general = {
        layout      = "dwindle",
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,
        col = { active_border = mauve, inactive_border = overlay0 },
        resize_on_border = true,
        allow_tearing    = false,
    },

    group = {
        col = {
            border_active          = mauve,
            border_inactive        = overlay0,
            border_locked_active   = peach,
            border_locked_inactive = overlay0,
        },
        groupbar = {
            enabled              = true,
            render_titles        = true,
            font_family          = "JetBrainsMono Nerd Font",
            font_size            = 14,
            font_weight_active   = "bold",
            font_weight_inactive = "normal",
            text_color           = text,
            height               = 16,
            indicator_height     = 0,
            gradients            = true,
            gaps_in              = 0,
            stacked              = false,
            col = {
                active          = mauve,
                inactive        = overlay0,
                locked_active   = peach,
                locked_inactive = overlay0,
            },
        },
    },

    decoration = {
        rounding = 0,
        shadow   = { enabled = true, range = 4, render_power = 3, color = overlay2 },
        blur     = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },

    animations = { enabled = true },

    misc = {
        on_focus_under_fullscreen = 1,
    },

    input = {
        kb_layout    = "gb",
        kb_variant   = "extd",
        follow_mouse = 1,
        touchpad     = { natural_scroll = false },
    },
})

------------------------------------------------------------------------------------------
-- Animations
------------------------------------------------------------------------------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

-- { leaf, speed, bezier, style }
local animations = {
    { "global",        1,    "default" },
    { "border",        5.39, "easeOutQuint" },
    { "windows",       4.79, "easeOutQuint" },
    { "windowsIn",     4.1,  "easeOutQuint", "popin 87%" },
    { "windowsOut",    1.49, "linear",       "popin 87%" },
    { "fadeIn",        1.73, "almostLinear" },
    { "fadeOut",       1.46, "almostLinear" },
    { "fade",          3.03, "quick" },
    { "layers",        3.81, "easeOutQuint" },
    { "layersIn",      4,    "easeOutQuint", "fade" },
    { "layersOut",     1.5,  "linear",       "fade" },
    { "fadeLayersIn",  1.79, "almostLinear" },
    { "fadeLayersOut", 1.39, "almostLinear" },
    { "workspaces",    1.94, "almostLinear", "fade" },
    { "workspacesIn",  1.21, "almostLinear", "fade" },
    { "workspacesOut", 1.94, "almostLinear", "fade" },
    { "zoomFactor",    7,    "quick" },
}
for _, a in ipairs(animations) do
    hl.animation({ leaf = a[1], enabled = true, speed = a[2], bezier = a[3], style = a[4] })
end

------------------------------------------------------------------------------------------
-- Input devices & gestures
------------------------------------------------------------------------------------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

------------------------------------------------------------------------------------------
-- Autostart (everything else runs as a systemd user service or via XDG autostart)
------------------------------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("[workspace special:TTY silent] " .. app("kitty"))
    hl.exec_cmd("[workspace special:VAR silent] " .. app("keepassxc"))
    hl.exec_cmd("[workspace special:VAR silent] " .. app("signal-desktop"))
    hl.exec_cmd(app("ashell"))
    hl.exec_cmd(app("clipse -listen"))
end)

------------------------------------------------------------------------------------------
-- Keybindings
------------------------------------------------------------------------------------------
-- Session
hl.bind("CTRL + ALT + Delete",       hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + L",           hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload && { pkill -x ashell; " .. app("ashell") .. "; }"))
hl.bind(mainMod .. " + SHIFT + K",   hl.dsp.exec_cmd("$HOME/.config/kmonad/cycle-mods"),
    { description = "cycle keyboard mod modes (normal -> strict -> off)" })

-- Launchers
hl.bind(mainMod .. " + E",     hl.dsp.exec_cmd(fileManager))
hl.bind("ALT + Space",         hl.dsp.exec_cmd("pkill rofi || " .. menu))
hl.bind(mainMod .. " + V",     hl.dsp.exec_cmd([[pkill -f "^kitty.*--class clipse" || ]] .. app("kitty --class clipse -e clipse")))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd([[pkill -f "^kitty.*--class of" || ]] .. app("kitty --override close_on_child_death=yes --class of -e fish -c of")))
hl.bind("PRINT",               hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- Windows
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("ALT + tab", hl.dsp.window.cycle_next({ direction = "next" }), { description = "cycle next window" })
hl.bind("ALT + tab", hl.dsp.window.bring_to_top(),                    { description = "bring active to top" })

-- Focus / swap / move, per arrow key
local monitorDir = { left = "l", right = "r", up = "u", down = "d" }
for dir, m in pairs(monitorDir) do
    hl.bind(mainMod .. " + " .. dir,                hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. dir,        hl.dsp.window.swap({ direction = dir }))
    hl.bind(mainMod .. " + ALT + " .. dir,          hl.dsp.window.move({ direction = dir, group_aware = true })) -- into/out of group
    hl.bind(mainMod .. " + CTRL + " .. dir,         hl.dsp.workspace.move({ monitor = m }))                       -- workspace -> monitor
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. dir, hl.dsp.window.move({ monitor = m }))                          -- window -> monitor
end

-- Groups
hl.bind(mainMod .. " + G",           hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab",         hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())

-- Workspaces
for ws = 1, 9 do
    hl.bind(mainMod .. " + " .. ws,         hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" })) -- ⚠ VERIFY
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" })) -- ⚠ VERIFY

-- Special workspaces
hl.bind(mainMod .. " + J",              hl.dsp.workspace.toggle_special("VAR"))
hl.bind(mainMod .. " + SHIFT + J",      hl.dsp.window.move({ workspace = "special:VAR" }))
hl.bind(mainMod .. " + Return",         hl.dsp.workspace.toggle_special("TTY"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.window.move({ workspace = "special:TTY" }))

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness (work on lock screen, repeat when held)
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        media)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      media)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                     media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                     media)

-- Media player (work on lock screen)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------------------------------------------------------------------------------
-- Window rules
------------------------------------------------------------------------------------------
hl.window_rule({
    name = "special-var-maximize",
    match = { workspace = "name:special:VAR" },
    maximize = true,
    no_anim = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "clipse",
    match = { class = "(clipse)" },
    float = true,
    size = { 622, 652 }, -- ⚠ VERIFY size format
    no_anim = true,
})

hl.window_rule({
    name = "of",
    match = { class = "(of)" },
    float = true,
    size = { 960, 600 }, -- ⚠ VERIFY size format
    no_anim = true,
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

------------------------------------------------------------------------------------------
-- Layer rules
------------------------------------------------------------------------------------------
hl.layer_rule({
    name = "rofi-no-anim",
    match = { namespace = "^rofi$" }, -- ⚠ VERIFY namespace key
    no_anim = true,
})

------------------------------------------------------------------------------------------
-- Workspace rules
------------------------------------------------------------------------------------------
hl.workspace_rule({ workspace = "special:TTY", persistent = true })
hl.workspace_rule({ workspace = "special:VAR", persistent = true })
