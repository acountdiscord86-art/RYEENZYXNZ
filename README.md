# RYEENZYXNZ UI Library V3

A large, original Roblox UI framework focused on a premium Liquid Glass look and a broad script-hub style API.

## Raw URL

```lua
https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/main/main.lua
```

## Quick load

```lua
local RYEENZYXNZ = loadstring(game:HttpGet("https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/main/main.lua"))()
```

## Window

```lua
local Window = RYEENZYXNZ:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "Liquid Glass V3",
    AutoScale = true,
    Search = true,
    PremiumDefaults = true,
})
```

`PremiumDefaults` enables the floating open button, watermark and RightShift toggle.

## Components

Core sections include:

- Button
- Toggle
- Slider
- Dropdown
- MultiDropdown
- Input
- Keybind
- ColorPicker
- Paragraph
- Divider

V3 adds window-level helpers for cards, badges, progress indicators, status rows, action rows, labels, separators, state snapshots, control registration, search, notifications and state save/load.

## Lucide-style icons

Use readable Lucide names:

```lua
local Tab = Window:CreateTab({
    Title = "Visuals",
    Icon = "palette"
})
```

Custom mappings can be added:

```lua
RYEENZYXNZ:SetIcon("myicon", "rbxassetid://1234567890")
```

The icon layer accepts normalized Lucide-style names and custom Roblox image IDs.

## Control IDs

Controls can be registered automatically by giving them an `Id`:

```lua
local Toggle = Section:Toggle({
    Id = "ESP",
    Title = "ESP",
    Default = false,
    Callback = function(value)
        print("ESP", value)
    end
})
```

Then:

```lua
Window:SetControl("ESP", true)
local esp = Window:GetControl("ESP")
local state = Window:Snapshot()
Window:Restore(state)
```

## Open button

```lua
Window:SetOpenButtonIcon("menu")
Window:SetOpenButtonSize(UDim2.fromOffset(52, 52))
Window:SetOpenButtonPosition(UDim2.new(0, 64, 0.5, 0))
Window:ShowOpenButton(true)
```

## Notes

The UI is generated from Roblox instances at runtime. It does not require uploading a screenshot of the UI as an image asset. Optional icon images use Roblox asset IDs.

This project is an original implementation. It is not a copy of WindUI source code. It follows common UI-library conventions and provides a familiar script-hub API.
