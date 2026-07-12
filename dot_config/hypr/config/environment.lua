-- Sourced Environment Variables (Translated from config/environment.conf)
-- =======================================================================

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "gtk3")
hl.env("TERMINAL", "ghostty")

-- === GPU Configuration (AMD Primary) ===
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")

-- Disable Atomic Modesetting to prevent page-flip lockups/loops
hl.env("AQ_NO_ATOMIC", "1")
