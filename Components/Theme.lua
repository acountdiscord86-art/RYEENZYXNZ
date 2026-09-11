--[[
    RYEENZYXNZ UI V3 — Theme Module
    Standalone theme definitions.
    Used internally by the main library.
    Can also be required separately for external theme overrides.
]]

local Theme = {}

Theme.Default = {
    Background         = Color3.fromRGB(8,   8,  12),
    Surface            = Color3.fromRGB(16,  16,  22),
    SurfaceElevated    = Color3.fromRGB(22,  22,  32),
    SurfaceGlass       = Color3.fromRGB(18,  18,  26),
    Text               = Color3.fromRGB(240, 240, 255),
    TextMuted          = Color3.fromRGB(140, 140, 165),
    TextDim            = Color3.fromRGB(80,  80, 110),
    Accent             = Color3.fromRGB(124, 104, 255),
    AccentSoft         = Color3.fromRGB(80,  64, 180),
    AccentGlow         = Color3.fromRGB(100, 80, 220),
    Border             = Color3.fromRGB(40,  40,  60),
    BorderBright       = Color3.fromRGB(60,  60,  90),
    Success            = Color3.fromRGB(80,  220, 140),
    Warning            = Color3.fromRGB(255, 190,  60),
    Error              = Color3.fromRGB(255,  80,  80),
    SliderFill         = Color3.fromRGB(124, 104, 255),
    ToggleOn           = Color3.fromRGB(124, 104, 255),
    ToggleOff          = Color3.fromRGB(45,  45,  65),
    ScrollBar          = Color3.fromRGB(60,  60,  90),
    Overlay            = Color3.fromRGB(0,    0,   0),
    NotificationBg     = Color3.fromRGB(20,  20,  30),
}

-- Preset: Midnight Blue
Theme.MidnightBlue = {
    Background         = Color3.fromRGB(5,   8,  18),
    Surface            = Color3.fromRGB(10,  15,  30),
    SurfaceElevated    = Color3.fromRGB(15,  22,  42),
    SurfaceGlass       = Color3.fromRGB(12,  18,  34),
    Text               = Color3.fromRGB(230, 235, 255),
    TextMuted          = Color3.fromRGB(120, 135, 180),
    TextDim            = Color3.fromRGB(70,  85, 130),
    Accent             = Color3.fromRGB(80,  140, 255),
    AccentSoft         = Color3.fromRGB(50,  90, 200),
    AccentGlow         = Color3.fromRGB(60,  110, 230),
    Border             = Color3.fromRGB(25,  35,  70),
    BorderBright       = Color3.fromRGB(40,  60, 110),
    Success            = Color3.fromRGB(60,  210, 130),
    Warning            = Color3.fromRGB(255, 190,  60),
    Error              = Color3.fromRGB(255,  80,  80),
    SliderFill         = Color3.fromRGB(80,  140, 255),
    ToggleOn           = Color3.fromRGB(80,  140, 255),
    ToggleOff          = Color3.fromRGB(30,  40,  75),
    ScrollBar          = Color3.fromRGB(50,  70, 120),
    Overlay            = Color3.fromRGB(0,    0,   0),
    NotificationBg     = Color3.fromRGB(10,  15,  28),
}

-- Preset: Emerald
Theme.Emerald = {
    Background         = Color3.fromRGB(5,  12,  10),
    Surface            = Color3.fromRGB(10,  22,  18),
    SurfaceElevated    = Color3.fromRGB(14,  30,  24),
    SurfaceGlass       = Color3.fromRGB(12,  26,  20),
    Text               = Color3.fromRGB(220, 255, 240),
    TextMuted          = Color3.fromRGB(110, 170, 145),
    TextDim            = Color3.fromRGB(60, 110,  90),
    Accent             = Color3.fromRGB(50,  220, 140),
    AccentSoft         = Color3.fromRGB(30,  160, 100),
    AccentGlow         = Color3.fromRGB(40,  190, 120),
    Border             = Color3.fromRGB(20,  55,  40),
    BorderBright       = Color3.fromRGB(35,  85,  65),
    Success            = Color3.fromRGB(50,  220, 140),
    Warning            = Color3.fromRGB(255, 200,  60),
    Error              = Color3.fromRGB(255,  80,  80),
    SliderFill         = Color3.fromRGB(50,  220, 140),
    ToggleOn           = Color3.fromRGB(50,  220, 140),
    ToggleOff          = Color3.fromRGB(20,  55,  40),
    ScrollBar          = Color3.fromRGB(40,  90,  65),
    Overlay            = Color3.fromRGB(0,    0,   0),
    NotificationBg     = Color3.fromRGB(8,   18,  14),
}

-- Preset: Rose Gold
Theme.RoseGold = {
    Background         = Color3.fromRGB(14,  8,  10),
    Surface            = Color3.fromRGB(26,  14,  18),
    SurfaceElevated    = Color3.fromRGB(36,  20,  26),
    SurfaceGlass       = Color3.fromRGB(30,  16,  22),
    Text               = Color3.fromRGB(255, 235, 240),
    TextMuted          = Color3.fromRGB(190, 140, 155),
    TextDim            = Color3.fromRGB(130,  80,  95),
    Accent             = Color3.fromRGB(255, 140, 160),
    AccentSoft         = Color3.fromRGB(210,  90, 120),
    AccentGlow         = Color3.fromRGB(235, 110, 140),
    Border             = Color3.fromRGB(70,  30,  42),
    BorderBright       = Color3.fromRGB(110,  50,  68),
    Success            = Color3.fromRGB(80,  220, 140),
    Warning            = Color3.fromRGB(255, 200,  60),
    Error              = Color3.fromRGB(255,  70,  70),
    SliderFill         = Color3.fromRGB(255, 140, 160),
    ToggleOn           = Color3.fromRGB(255, 140, 160),
    ToggleOff          = Color3.fromRGB(70,  30,  42),
    ScrollBar          = Color3.fromRGB(120,  60,  80),
    Overlay            = Color3.fromRGB(0,    0,   0),
    NotificationBg     = Color3.fromRGB(20,  10,  14),
}

return Theme
