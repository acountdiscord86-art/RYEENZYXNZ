# RYEENZYXNZ Liquid Glass UI Library

An original Roblox Luau UI library based on the RYEENZYXNZ Liquid Glass design blueprint. It follows a modern script-hub component model similar in spirit to popular Roblox UI libraries, while using its own implementation and branding.

## Included

- Liquid Glass dark theme
- Responsive AutoScale
- Draggable window
- Sidebar tabs
- Sections
- Button
- Toggle
- Slider
- Dropdown
- Input
- Paragraph
- Divider
- Notifications
- Basic JSON config helper for executors that expose filesystem APIs
- Source version under `src/`
- Standalone `main.lua` for `loadstring`
- Full example under `examples/Example.lua`

## Quick usage

```lua
local RYEENZY = loadstring(game:HttpGet("YOUR_RAW_LIBRARY_URL/main.lua"))()

local Window = RYEENZY:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "LIQUID GLASS UI LIBRARY",
    AutoScale = true,
})

local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
})

local Section = Tab:Section({
    Title = "Visual Settings",
    Box = true,
})

Section:Toggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})
```

## Repository layout

```text
RYEENZYXNZ_UI_Library/
├── main.lua
├── README.md
├── LICENSE-NOTICE.md
├── src/
│   ├── Init.lua
│   ├── Theme.lua
│   └── Util.lua
├── examples/
│   └── Example.lua
└── docs/
    └── API.md
```

## Important

`main.lua` is the standalone loader target. The `src/` folder is the maintainable source version for development in Roblox Studio or a Luau build pipeline.

No screenshot is required for the UI itself. The library builds Roblox GUI instances at runtime. Optional images can be added later for logos/backgrounds.
