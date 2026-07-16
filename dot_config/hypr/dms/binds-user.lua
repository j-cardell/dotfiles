-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + E")
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.unbind("SUPER + SHIFT + T")
hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.window.float({ action = "toggle" }), { description = "Float/unfloat window" })
