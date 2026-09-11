# RYEENZYXNZ UI V3.1

> **Premium Liquid Glass / Glassmorphism UI Library for Roblox**  
> Version `3.1.0` — Written 100% in Luau from scratch.

---

## Introduction

RYEENZYXNZ UI V3 is a custom-built, production-grade UI library for Roblox exploit scripts and Luau environments. It features a **Liquid Glass / Glassmorphism** dark aesthetic, smooth animations, full config system, mobile support, Lucide icon integration, and a clean modular API.

> **This is a completely original implementation.** It is not derived from, nor does it copy source code from WindUI, Rayfield, or any other existing library. Other libraries were used only as conceptual references for API design.

---

## Features

- **Liquid Glass dark theme** — translucent surfaces, soft glow, rounded corners
- **Draggable window** — mouse and touch
- **Tab system** — sidebar with icons, active states, smooth transitions
- **Full component set** — Button, Toggle, Slider, Dropdown, Multi Dropdown, Input/Textbox, Keybind, ColorPicker, Label, SubLabel, Header, Divider, Image, ProgressBar, Paragraph, Section
- **Search bar** — realtime search across all components without destroying state
- **Notifications** — animated, auto-dismiss, multiple simultaneous
- **Config system** — save/load/delete via file or in-memory fallback
- **Flag system** — `Window.Flags.FlagName` for any flagged component
- **Lucide icon support** — via module or custom icon table
- **Background image** — with independent transparency and dark overlay
- **Logo support** — rounded, header-integrated
- **Theme system** — full color override via `UI:SetTheme({})`
- **Mobile support** — touch drag, touch slider, touch-friendly tap targets
- **Memory safe** — tracked input connections are disconnected on `Window:Destroy()`
- **Mac-style window API** — Show/Hide/Toggle, SelectTab, SetTitle, SetSubtitle, SetLogo, SetBackgroundImage, SetSize, Dialog, GlobalSetting
- **4 built-in theme presets** — Default, Midnight Blue, Emerald, Rose Gold

---

## Mac-style compatibility

The V3.1 API is intentionally compatible with common MacLib-style concepts while keeping its own implementation and visual identity. The reference Maclib demo exposes window settings, tabs, sections, button/input/slider/toggle/keybind/colorpicker controls, single/multi dropdowns, dialogs, notifications and config loading. citeturn3view0

RYEENZYXNZ V3.1 provides those core interaction patterns plus mobile/touch support, Lucide integration, background images, progress bars and a glass theme.

## File Structure

```
RYEENZYXNZ_UI_V3/
├── RYEENZYXNZ_UI_V3.lua          ← Single-file loadstring version (main)
├── RYEENZYXNZ_UI_V3_EXAMPLE.lua  ← Full runnable example
├── README.md                      ← This file
└── Components/
    ├── Theme.lua                  ← Theme presets
    ├── Animations.lua             ← Tween / animation helpers
    └── Utilities.lua              ← General utilities
```

---

## Installation

### Loadstring (recommended)

```lua
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/main/RYEENZYXNZ_UI_V3/RYEENZYXNZ_UI_V3.lua"
))()
```

Upload `RYEENZYXNZ_UI_V3.lua` to GitHub (public repo), copy the raw URL, and use it above.

---

## Quick Start

```lua
local UI = loadstring(game:HttpGet("YOUR_URL"))()

local Window = UI:CreateWindow({
    Title    = "My Script",
    Subtitle = "Premium v3",
})

local Home = Window:CreateTab({ Title = "Home", Icon = "home" })

Home:CreateButton({
    Title    = "Click Me",
    Callback = function()
        print("Clicked!")
    end,
})
```

---

## Window API

```lua
local Window = UI:CreateWindow({
    Title                        = "RYEENZYXNZ",        -- Header title
    Subtitle                     = "Premium Liquid Glass", -- Header subtitle
    Logo                         = "rbxassetid://123",   -- Optional logo asset
    BackgroundImage              = "rbxassetid://456",   -- Optional bg image
    BackgroundImageTransparency  = 0.5,                  -- 0 = opaque, 1 = invisible
    BackgroundOverlayTransparency = 0.3,                 -- Dark overlay on top of bg
    Size                         = UDim2.fromOffset(780, 520),
    ConfigFolder                 = "RYEENZYXNZ",         -- Folder for config files
    ConfigName                   = "default",            -- Default config name
    ToggleKey                    = Enum.KeyCode.RightShift,
})

Window:SetToggleKey(Enum.KeyCode.Insert)
Window:Destroy()
Window:Notify({ Title = "Hello", Content = "World", Duration = 4 })
Window:SaveConfig("myconfig")
Window:LoadConfig("myconfig")
Window:DeleteConfig("myconfig")

-- Access flags
print(Window.Flags.AutoFarm)
print(Window.Flags.WalkSpeed)
```

---

## Tab API

```lua
local Tab = Window:CreateTab({
    Title = "Home",
    Icon  = "house",   -- Lucide icon name or custom icon key
})
```

All component methods are available on the **Tab** object, and also forwarded to `Window` for convenience (delegates to the active tab).

---

## Components

### Section

Groups components visually.

```lua
Tab:CreateSection("My Section")
-- alias:
Tab:AddSection("My Section")
```

---

### Paragraph

Displays a title + body text block.

```lua
Tab:CreateParagraph({
    Title   = "Info",
    Content = "Some descriptive text here.",
})
```

---

### Button

```lua
Tab:CreateButton({
    Title    = "Click Me",
    Icon     = "mouse-pointer",    -- optional
    Callback = function()
        print("clicked")
    end,
})
```

---

### Toggle

```lua
local Toggle = Tab:CreateToggle({
    Title    = "Auto Farm",
    Flag     = "AutoFarm",
    Default  = false,
    Callback = function(value)
        print(value) -- true / false
    end,
})

Toggle:Set(true)
Toggle:Get()   -- returns boolean
```

---

### Slider

```lua
local Slider = Tab:CreateSlider({
    Title    = "Walk Speed",
    Flag     = "WalkSpeed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Step     = 1,         -- rounding step (0 = no rounding)
    Callback = function(value)
        print(value)
    end,
})

Slider:Set(100)
Slider:Get()   -- returns number
```

Touch and mouse drag both supported.

---

### Dropdown

```lua
local Dropdown = Tab:CreateDropdown({
    Title    = "Mode",
    Flag     = "Mode",
    Values   = { "Easy", "Normal", "Hard" },
    Default  = "Normal",
    Callback = function(value)
        print(value)
    end,
})

Dropdown:Set("Hard")
Dropdown:Get()   -- returns string
```

Animated open/close, scrollable list, touch-friendly.

---

### Multi Dropdown

```lua
local Multi = Tab:CreateMultiDropdown({
    Title    = "Features",
    Flag     = "Features",
    Values   = { "ESP", "Aimbot", "Auto Farm" },
    Default  = { "ESP" },
    Callback = function(values)
        -- values is a table of selected strings
        print(table.concat(values, ", "))
    end,
})

Multi:Set({ "ESP", "Aimbot" })
Multi:Get()   -- returns table of selected strings
```

Checkbox-style multi-select with animated check marks.

---

### Input

```lua
local Input = Tab:CreateInput({
    Title       = "Player Name",
    Flag        = "PlayerName",
    Placeholder = "Enter player name...",
    Callback    = function(value, enterPressed)
        print(value, enterPressed)
    end,
})

Input:Set("RYEENZYXNZ")
Input:Get()   -- returns string
```

Callback fires on `FocusLost`.

---

### Keybind

```lua
local Keybind = Tab:CreateKeybind({
    Title    = "Menu Toggle",
    Flag     = "MenuKey",
    Default  = Enum.KeyCode.RightShift,
    Callback = function(key)
        print(key.Name)
    end,
})

Keybind:Set(Enum.KeyCode.Insert)
Keybind:Get()   -- returns EnumItem (KeyCode)
```

Click the pill → press any key to bind. Press `Escape` to cancel.

---

### Color Picker

```lua
local Color = Tab:CreateColorPicker({
    Title    = "ESP Color",
    Flag     = "ESPColor",
    Default  = Color3.fromRGB(124, 104, 255),
    Callback = function(color)
        print(color.R, color.G, color.B)
    end,
})

Color:Set(Color3.fromRGB(255, 0, 0))
Color:Get()   -- returns Color3
```

Popup with R/G/B sliders, live preview bar, and Apply button. Callback fires on Apply.

---

## Lucide Icons

```lua
-- Load before creating window
local Lucide = loadstring(game:HttpGet("LUCIDE_MODULE_URL"))()
UI:SetLucideModule(Lucide)

-- Or pass directly to window
local Window = UI:CreateWindow({
    LucideModule = Lucide,
    ...
})
```

Usage in components: `Icon = "house"`, `Icon = "settings"`, etc.

Internally calls `Lucide:GetAsset(name, 24)`. Falls back gracefully if icon not found.

---

## Custom Icons

```lua
UI:AddIcons({
    home     = "rbxassetid://7734053495",
    settings = "rbxassetid://7734045186",
})
```

Use `Icon = "home"` anywhere icons are supported.

---

## Logo

```lua
UI:CreateWindow({
    Logo = "rbxassetid://YOUR_LOGO_ID",
    ...
})
```

Displayed in the header, rounded corners, proper scaling.

---

## Background Image

```lua
UI:CreateWindow({
    BackgroundImage              = "rbxassetid://YOUR_BG_ID",
    BackgroundImageTransparency  = 0.55,
    BackgroundOverlayTransparency = 0.32,
    ...
})
```

Background uses `ScaleType = Crop`. Dark overlay applied on top to keep text readable.

---

## Config System

Configs are stored as JSON files in your executor's workspace.

```lua
Window:SaveConfig("myconfig")     -- saves to RYEENZYXNZ/myconfig.json
Window:LoadConfig("myconfig")     -- loads and applies flags
Window:DeleteConfig("myconfig")   -- deletes the file
```

**Supported flag types:**

| Type          | Stored as                        |
|---------------|----------------------------------|
| `boolean`     | `true` / `false`                 |
| `number`      | number                           |
| `string`      | string                           |
| `Color3`      | `{ __type="Color3", R, G, B }`   |
| `EnumItem`    | `{ __type="EnumItem", Name="" }` |
| `table`       | array (Multi Dropdown)           |

If the executor does not support `writefile`/`readfile`, a warning is printed and the operation is skipped gracefully — **no crash**.

---

## Flags

Every component with a `Flag = "Name"` property registers to `Window.Flags`:

```lua
print(Window.Flags.AutoFarm)    -- true/false
print(Window.Flags.WalkSpeed)   -- number
print(Window.Flags.Mode)        -- string
print(Window.Flags.Features)    -- table
print(Window.Flags.MenuKey)     -- EnumItem
print(Window.Flags.AccentColor) -- Color3
```

Flags update in real time as the user interacts with components.

---

## Theme System

```lua
UI:SetTheme({
    Background      = Color3.fromRGB(5, 5, 10),
    Accent          = Color3.fromRGB(255, 100, 100),
    Text            = Color3.fromRGB(255, 255, 255),
    -- any subset of theme keys
})
```

Must be called **before** `CreateWindow` to take full effect.

**Built-in presets** (in `Components/Theme.lua`):

```lua
local Theme = require("Components/Theme")

UI:SetTheme(Theme.MidnightBlue)
UI:SetTheme(Theme.Emerald)
UI:SetTheme(Theme.RoseGold)
UI:SetTheme(Theme.Default)   -- reset
```

**All theme keys:**

```
Background, Surface, SurfaceElevated, SurfaceGlass,
Text, TextMuted, TextDim,
Accent, AccentSoft, AccentGlow,
Border, BorderBright,
Success, Warning, Error,
SliderFill, ToggleOn, ToggleOff,
ScrollBar, Overlay, NotificationBg
```

---

## Notifications

```lua
Window:Notify({
    Title    = "RYEENZYXNZ UI",
    Content  = "Script loaded successfully!",
    Duration = 4,      -- seconds
    Icon     = "bell", -- optional icon name
})
```

Notifications:
- Appear in the bottom-right corner
- Animate in with a spring
- Show a draining progress bar
- Auto-dismiss after `Duration` seconds
- Multiple can appear simultaneously

---

## Search

The search bar is built into the window header. Type anything to filter components by title in real time. Component **state is preserved** — hidden components retain their values.

---

## Mobile Support

| Feature        | Support |
|----------------|---------|
| Touch drag     | ✅      |
| Touch slider   | ✅      |
| Touch dropdown | ✅      |
| Touch keybind  | ⚠️ Keyboard only — keybind requires physical keyboard |
| Layout scaling | ✅      |
| Min tap size   | ✅ 38–42px minimum tap targets |

---

## Example

See `RYEENZYXNZ_UI_V3_EXAMPLE.lua` for a full runnable example covering all components.

---

## Troubleshooting

**White / blank screen on load**
- Ensure the URL points to the raw `.lua` file (not GitHub HTML view).
- Check executor console for errors.

**Config not saving**
- Ensure your executor supports `writefile`, `readfile`, `isfile`, `makefolder`.
- Check console for `[RYEENZYXNZ] writefile not available` warning.

**Icons not showing**
- Pass your Lucide module via `UI:SetLucideModule(Lucide)` before creating the window.
- Or register custom icons via `UI:AddIcons({ name = "rbxassetid://..." })`.

**Window not toggling**
- Default toggle key is `RightShift`. Change with `Window:SetToggleKey(Enum.KeyCode.Insert)`.

**Dropdown stays open when scrolling**
- Click elsewhere or click the dropdown header again to close.

**Slider unresponsive on mobile**
- Ensure no fullscreen GuiObject is blocking input. Use `ZIndex` correctly.

---

## Limitations

- **ColorPicker** uses RGB sliders only. HSV/hex input not included (extensible).
- **Keybind** on mobile requires a physical keyboard connected to the device.
- **Background image** requires a valid `rbxassetid://` — external URLs are not supported by Roblox `ImageLabel`.
- **Config** requires executor file API. In-memory fallback does not persist across sessions.
- **Lucide** integration depends on a compatible Lucide Roblox module with a `:GetAsset(name, size)` method.

---

## Credits

- **Design**: RYEENZYXNZ — original Liquid Glass concept
- **Implementation**: 100% custom Luau — zero source-code copying from external libraries
- **Inspiration**: Glassmorphism design trend, modern SaaS UI patterns
- **Icons**: Lucide (optional external module)

---

*RYEENZYXNZ UI V3 — Built different.*
