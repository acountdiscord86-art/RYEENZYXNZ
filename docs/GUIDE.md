# RYNZYEXZ Guide

## 1. Load the library

Remote:

```lua
local RYNZYEXZ = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/acountdiscord86-art/RYNZYEXZ/main/main.lua"
))()
```

Local filesystem:

```lua
local RYNZYEXZ = loadstring(readfile("RYNZYEXZ/main.lua"))()
```

## 2. Create a window

```lua
local Window = RYNZYEXZ:CreateWindow({
    Name = "RYNZYEXZ",
    BrandSubtitle = "My Script Hub",
    Size = UDim2.fromOffset(760, 520),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "RYNZYEXZ",
    LoadingSubtitle = "LOADING",
    LoadingFooter = "RYNZYEXZ",
})
```

Useful options include `Logo`, `LogoZoom`, `Position`, `GuiName`, `DisplayOrder`, `Mobile`, `Parent`, and `ReplaceExisting`.

## 3. Add tabs and subtabs

```lua
local Tab = Window:AddTab({
    Name = "Main",
    Icon = "home",
    Subtitle = "Main features",
})

local Sub = Tab:AddSubTab("General")
```

## 4. Sections

```lua
Sub:AddSection("Player")
```

## 5. Button

```lua
Sub:AddButton({
    Name = "Test",
    Primary = true,
    Callback = function()
        print("clicked")
    end,
})
```

## 6. Toggle

```lua
Sub:AddToggle({
    Name = "Enabled",
    Description = "Enable the feature",
    Default = false,
    Flag = "Enabled",
    Callback = function(value)
        print(value)
    end,
})
```

## 7. Slider

```lua
Sub:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 200,
    Default = 50,
    Suffix = "",
    Flag = "Speed",
    Callback = function(value)
        print(value)
    end,
})
```

## 8. Dropdown

```lua
Sub:AddDropdown({
    Name = "Mode",
    Options = { "Default", "Fast", "Smooth" },
    Default = "Default",
    Searchable = true,
    Flag = "Mode",
    Callback = function(value)
        print(value)
    end,
})
```

## 9. MultiDropdown

```lua
Sub:AddMultiDropdown({
    Name = "Targets",
    Options = { "Players", "NPCs", "Items" },
    Default = { "Players" },
    Flag = "Targets",
    Callback = function(values)
        print(table.concat(values, ", "))
    end,
})
```

## 10. Input

```lua
Sub:AddInput({
    Name = "Username",
    Placeholder = "Type here...",
    Default = "",
    Flag = "Username",
    Callback = function(text, enterPressed)
        print(text, enterPressed)
    end,
})
```

## 11. Keybind

```lua
Sub:AddKeybind({
    Name = "Toggle Feature",
    Default = Enum.KeyCode.F,
    Flag = "FeatureKey",
    OnPress = function(key)
        print("Pressed", key.Name)
    end,
})
```

`Window:ToggleUI()` can be used to hide/show the interface.

## 12. ColorPicker

```lua
Sub:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(120, 80, 255),
    Flag = "ESPColor",
    Callback = function(color)
        print(color)
    end,
})
```

## 13. Text components

```lua
Sub:AddLabel({ Text = "Small label" })

Sub:AddParagraph({
    Title = "Information",
    Text = "Longer explanatory text goes here.",
})

Sub:AddDivider()
```

## 14. Notifications

```lua
Window:Notify({
    Title = "Success",
    Content = "Action completed.",
    Type = "success",
    Duration = 3,
})
```

Typical notification types are `success`, `info`, `warning`, and `error`.

## 15. Themes

```lua
RYNZYEXZ:SetTheme("Dark")
RYNZYEXZ:SetTheme("Light")
RYNZYEXZ:SetTheme("OLED")

print(RYNZYEXZ:GetTheme())
```

A custom theme table is also accepted by `SetTheme` when it contains valid Color3 values for the library's theme keys.

## 16. Flags

Flags let your script read and write component state.

```lua
local speed = RYNZYEXZ:GetFlag("Speed", 16)
RYNZYEXZ:SetFlag("Speed", 100)
```

Only components created with a `Flag` are registered for this system.

## 17. Configs

The config system stores registered flags as JSON when the environment provides compatible filesystem APIs.

```lua
RYNZYEXZ:SaveConfig("myhub")
RYNZYEXZ:LoadConfig("myhub")
RYNZYEXZ:DeleteConfig("myhub")

local configs = RYNZYEXZ:ListConfigs()
```

Config folder:

```text
RYNZYEXZ/configs/
```

The library safely checks for filesystem functions before attempting file operations.

## 18. Window control

```lua
Window:SetVisible(true)
Window:SetVisible(false)
Window:Toggle()
Window:SetUIVisible(true)
Window:ToggleUI()
Window:SetLogo("rbxassetid://123456789")
Window:Destroy()
```

## 19. Icons

The library has built-in icon-name mapping.

```lua
Icon = "home"
Icon = "settings"
Icon = "eye"
Icon = "player"
Icon = "swords"
Icon = "bolt"
Icon = "save"
```

You can inspect the map:

```lua
local icons = RYNZYEXZ:GetIcons()
print(RYNZYEXZ:GetIcon("home"))
```

## 20. Mobile / responsive behavior

The library detects touch-only devices automatically. You can force behavior:

```lua
Mobile = true
```

or

```lua
Mobile = false
```

The `Size` option controls the base window size; the library handles the final UI scaling for supported screen sizes.

## 21. Recommended script structure

```text
MyHub.lua
│
├── load RYNZYEXZ
├── CreateWindow
├── Main tab
│   ├── Player
│   └── Movement
├── Visuals tab
│   ├── ESP
│   └── Colors
├── World tab
└── Settings tab
    ├── Theme
    └── Config
```

Keep gameplay logic in separate functions and let callbacks only enable/disable or update that logic.

## 22. Troubleshooting

### UI does not appear

Check that the loader URL points to the correct repository, branch, and file name. Also check the executor output for errors.

### Config does not save

The current environment may not expose the required filesystem APIs. Config persistence is optional and should not be assumed in every runtime.

### A dropdown is empty

Make sure `Options` is a table containing at least one value.

### Keybind does nothing

Use a valid `Enum.KeyCode` and provide `OnPress`.

### Theme name fails

Use one of the built-in names present in the current library. `GetTheme()` returns the active theme name.
