hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user start hyprland-session.target")

  hl.exec_cmd(TERMINAL)
  hl.exec_cmd(BROWSER, { workspace = 2 })
  hl.exec_cmd(DISCORD)
end)
