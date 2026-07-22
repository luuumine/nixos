-- Basic actions
hl.bind(MAINMOD .. " + Q", hl.dsp.window.close())
hl.bind(MAINMOD .. " + M", hl.dsp.exit())
hl.bind(MAINMOD .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(MAINMOD .. " + F", hl.dsp.window.fullscreen())

-- Apps
hl.bind(MAINMOD .. " + SPACE", hl.dsp.global("quickshell:openLauncher"))
hl.bind(MAINMOD .. " + N ", hl.dsp.global("quickshell:toggleMenu"))
hl.bind(MAINMOD .. " + RETURN", hl.dsp.exec_cmd(TERMINAL))
hl.bind(MAINMOD .. " + B", hl.dsp.exec_cmd(BROWSER))

-- Move/Resize window with mouse (bindm equivalents)
-- LMB (272) to move
hl.bind(MAINMOD .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
-- RMB (273) to resize
hl.bind(MAINMOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move focus with MAINMOD + vim keys
hl.bind(MAINMOD .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(MAINMOD .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(MAINMOD .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(MAINMOD .. " + L", hl.dsp.focus({ direction = "right" }))

-- Switch workspaces with MAINMOD + [0-9]
hl.bind(MAINMOD .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(MAINMOD .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(MAINMOD .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(MAINMOD .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(MAINMOD .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(MAINMOD .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(MAINMOD .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(MAINMOD .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(MAINMOD .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(MAINMOD .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with MAINMOD + SHIFT + [0-9]
hl.bind(MAINMOD .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(MAINMOD .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(MAINMOD .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(MAINMOD .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(MAINMOD .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(MAINMOD .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(MAINMOD .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(MAINMOD .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(MAINMOD .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(MAINMOD .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Switch monitors (bindd equivalents with description flags)
hl.bind(MAINMOD .. " + bracketright", hl.dsp.workspace.move({ monitor = "+1" }),
  { description = "Move workspace to next monitor" })
hl.bind(MAINMOD .. " + bracketleft", hl.dsp.workspace.move({ monitor = "-1" }),
  { description = "Move workspace to previous monitor" })

-- Special workspace
hl.bind(MAINMOD .. " + S", hl.dsp.workspace.toggle_special( "magic" ))
hl.bind(MAINMOD .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Multimedia keys (bindel -> repeating = true, locked = true)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true, locked = true })

-- Media player control (bindl -> locked = true)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshots (hyprshot)
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"), { description = "Screenshot monitor" })
hl.bind(MAINMOD .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"), { description = "Screenshot window" })
hl.bind(MAINMOD .. " + R", hl.dsp.exec_cmd("hyprshot -m region"), { description = "Screenshot region" })
