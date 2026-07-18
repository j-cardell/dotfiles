-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + E")
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.unbind("SUPER + SHIFT + T")
hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.window.float({ action = "toggle" }), { description = "Float/unfloat window" })

-- 1. Restore SUPER + J as Toggle Split
hl.unbind("SUPER + J")
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))

-- 2. Restore SUPER + K as Toggle Group
hl.unbind("SUPER + K")
hl.bind("SUPER + K", hl.dsp.group.toggle())

-- 3. Restore SUPER + L as Lock Screen
hl.unbind("SUPER + L")
hl.bind("SUPER + L", hl.dsp.exec_cmd("dms ipc call lock lock"))

-- 4. Map SUPER + H to Keybinds Cheat Sheet
hl.unbind("SUPER + H")
hl.bind("SUPER + H", hl.dsp.exec_cmd("dms ipc call keybinds toggle hyprland"))

-- 5. Map CTRL + Print to Satty screenshot tool (clipboard only)
hl.unbind("CTRL + Print")
hl.bind("CTRL + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename - --early-exit copy --actions-on-enter save-to-clipboard --copy-command wl-copy --initial-tool arrow'))





