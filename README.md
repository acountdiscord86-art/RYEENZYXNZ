# RYEENZYXNZ UI V3 — MacLib Edition

> **Premium Liquid Glass UI · MacLib-compatible API · Auto-Scale · All Devices**  
> Version `3.0.0` | 100% original Luau implementation

---

## What this is

RYEENZYXNZ UI V3 (MacLib Edition) is a full-featured Roblox UI library with:

- **MacLib-compatible API** — same method names and call signatures as MacLib
- **Original implementation** — no MacLib source code used; inspired by MacLib's public documentation only
- **Liquid Glass / Glassmorphism** dark aesthetic
- **Auto-scale** — dynamically scales to any viewport (PC, laptop, phone, tablet)
- **Full MacLib feature set** — all components, config system, notifications, dialogs, global settings

---

## Quick Start

```lua
local RUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = RUI:Window({
    Title   = "My Script",
    Subtitle = "v1.0",
    Keybind  = Enum.KeyCode.RightShift,
})

local TabGroup = Window:TabGroup()
local HomeTab  = TabGroup:Tab({ Name = "Home", Icon = "home" })
local Section  = HomeTab:Section({ Side = "Left" })

Section:Toggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end,
}, "AutoFarm")
```

---

## Loading

```lua
local RUI = loadstring(game:HttpGet("YOUR_URL"))()
```

### Global Methods

```lua
RUI:Window(opts)                  -- Create a window
RUI:SetFolder(folder)             -- Set config save folder
RUI:SaveConfig(path)              -- Save all flags globally
RUI:LoadConfig(path)              -- Load flags globally
RUI:RefreshConfigList()           -- Returns table of saved config names
RUI:LoadAutoLoadConfig()          -- Loads "autoload.json" config
RUI:SetLucideModule(module)       -- Attach Lucide icon module
RUI:AddIcons({ name = assetId })  -- Register custom icons
RUI:SetTheme({ KEY = Color3 })    -- Override theme colors
RUI:Demo()                        -- Spawn a demo window
```

---

## Window

```lua
local Window = RUI:Window({
    Title                  = "RYEENZYXNZ",
    Subtitle               = "Premium Liquid Glass",
    Size                   = UDim2.fromOffset(868, 650),
    DragStyle              = 1,      -- 1 = header drag, 2 = full window drag
    DisabledWindowControls = {},     -- table: "Exit", "Minimize"
    ShowUserInfo           = true,   -- shows LocalPlayer.Name in header
    Keybind                = Enum.KeyCode.RightShift,
    AcrylicBlur            = false,  -- BlurEffect (may be detected)
})
```

### Window Methods

```lua
Window:Unload()
Window:onUnloaded(function() end)

Window:SetState(bool)
Window:GetState() : bool

Window:SetNotificationsState(bool)
Window:GetNotificationsState() : bool

Window:SetAcrylicBlurState(bool)
Window:GetAcrylicBlurState() : bool

Window:SetUserInfoState(bool)
Window:GetUserInfoState() : bool

Window:SetKeybind(Enum.KeyCode)
Window:SetSize(UDim2)
Window:GetSize() : UDim2

Window:SetScale(number)   -- 1 = 100%, 1.5 = 150%
Window:GetScale() : number

Window:UpdateTitle(string)
Window:UpdateSubtitle(string)

Window:AddGlobalSetting({ Name, Default, Callback })  -- header pill toggle
Window:Notify({ Title, Description, Lifetime, Style, SizeX, Callback })
Window:Dialog({ Title, Description, Buttons = {{ Text, Accent, Callback }} })

Window:SetFolder(string)
Window:SaveConfig(name)
Window:LoadConfig(name)
Window:RefreshConfigList() : table
Window:LoadAutoLoadConfig()

Window.Settings : table
```

---

## Tab Group → Tab → Section

```lua
local TabGroup = Window:TabGroup()

local Tab = TabGroup:Tab({
    Name = "Home",
    Icon = "home",   -- Lucide name or custom icon key or rbxassetid://
})

local Section = Tab:Section({
    Side = "Left",  -- "Left" or "Right" (both append to the same scroll in V3)
})
```

---

## Components

### Toggle

```lua
local Toggle = Section:Toggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(value) end,
}, "FlagName")

Toggle:UpdateName("New Name")
Toggle:SetVisiblity(bool)
Toggle:UpdateState(bool)
Toggle:GetState() : bool
Toggle.State : bool
Toggle.IgnoreConfig = true  -- exclude from config save/load
```

---

### Slider

```lua
local Slider = Section:Slider({
    Name          = "Walk Speed",
    Default       = 16,
    Minimum       = 0,
    Maximum       = 500,
    DisplayMethod = "Value",   -- "Value", "Percent", "Degrees", "Round"
    Precision     = 0,         -- decimal places
    Callback      = function(value) end,
    onInputComplete = function(value) end,
}, "FlagName")

Slider:UpdateName("New Name")
Slider:SetVisiblity(bool)
Slider:UpdateValue(number)
Slider:GetValue() : number
Slider.Value : number
```

---

### Dropdown

```lua
local Dropdown = Section:Dropdown({
    Name     = "Mode",
    Options  = { "Easy", "Normal", "Hard" },
    Default  = 1,           -- index for single; table of names for multi
    Search   = false,       -- enable search box inside dropdown
    Multi    = false,       -- allow multiple selections
    Required = false,       -- prevent deselecting all (multi only)
    Callback = function(value) end,
    -- Single:  value = "Normal"
    -- Multi:   value = { Easy=true, Normal=false, Hard=true }
}, "FlagName")

Dropdown:UpdateName(string)
Dropdown:SetVisiblity(bool)
Dropdown:UpdateSelection(string | number | table)
Dropdown:InsertOptions(table)
Dropdown:RemoveOptions(table)
Dropdown:IsOption(string) : bool
Dropdown:GetOptions() : table
Dropdown:ClearOptions()
Dropdown.Value : string | table
```

---

### Input

```lua
local Input = Section:Input({
    Name        = "Player Name",
    Default     = "",
    Placeholder = "Enter value...",
    Callback    = function(value, enterPressed) end,
}, "FlagName")

Input:UpdateName(string)
Input:SetVisiblity(bool)
Input:SetValue(string)
Input:GetValue() : string
Input.Value : string
```

---

### Keybind

```lua
local Keybind = Section:Keybind({
    Name      = "Toggle Key",
    Default   = Enum.KeyCode.RightShift,
    Blacklist = { Enum.KeyCode.Escape },
    Callback  = function(key) end,   -- fired when key is pressed
    onBinded  = function(key) end,   -- fired when user rebinds
    onBindHeld = function(held, key) end,
}, "FlagName")

Keybind:UpdateName(string)
Keybind:SetVisiblity(bool)
Keybind:Unbind()
Keybind:Bind2(Enum.KeyCode)
Keybind:GetBind() : Enum.KeyCode
Keybind.Bind : Enum.KeyCode
```

> Click the key pill → press any key to rebind. Press `Escape` to cancel.

---

### Colorpicker

```lua
local Color = Section:Colorpicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(255, 0, 0),
    Alpha    = 0,   -- transparency 0–1
    Callback = function(color, alpha) end,
}, "FlagName")

Color:UpdateName(string)
Color:SetVisibility(bool)
Color:SetColor(Color3)
Color:SetAlpha(number)
Color.Color : Color3
Color.Alpha : number
```

Popup has R / G / B / A sliders, live preview bar, and Apply button.  
Callback fires only on Apply.

---

### Button

```lua
Section:Button({
    Name     = "Click Me",
    Icon     = "play",
    Callback = function() end,
})
```

---

### Header

```lua
Section:Header({ Name = "Section Title" })
```

---

### Paragraph

```lua
Section:Paragraph({
    Name    = "Title",
    Content = "Description text here.",
})
```

---

### Label

```lua
Section:Label({ Name = "Some text" })
```

---

### Sub Label

```lua
Section:SubLabel({ Name = "Smaller muted text" })
```

---

### Divider

```lua
Section:Divider()
```

---

### Spacer

```lua
Section:Spacer({ Size = 12 })  -- Size in pixels, default 12
```

---

## Notifications

```lua
Window:Notify({
    Title       = "RYEENZYXNZ",
    Description = "Hello, World!",
    Lifetime    = 5,
    Style       = "None",    -- "None", "Confirm", "Cancel"
    SizeX       = 300,       -- notification card width
    Callback    = function() end,
})
```

Notification methods:

```lua
local notif = Window:Notify({...})
notif:UpdateTitle(string)
notif:UpdateDescription(string)
notif:Resize(number)
notif:Cancel()
```

---

## Dialogs

```lua
Window:Dialog({
    Title       = "Confirm Action",
    Description = "Are you sure?",
    Buttons = {
        {
            Text     = "Yes",
            Accent   = true,
            Callback = function() end,
        },
        {
            Text     = "No",
            Callback = function() end,
        },
    },
})
```

---

## Global Settings

Small toggle pills placed in the window header bar.

```lua
Window:AddGlobalSetting({
    Name     = "Safe Mode",
    Default  = false,
    Callback = function(v) end,
})
```

---

## Config System

```lua
RUI:SetFolder("RYEENZYXNZ_V3")     -- set folder (default: "RYEENZYXNZ_V3")
Window:SaveConfig("legit")          -- saves to RYEENZYXNZ_V3/legit.json
Window:LoadConfig("legit")          -- loads and applies
Window:RefreshConfigList()          -- returns { "legit.json", "rage.json", ... }
Window:LoadAutoLoadConfig()         -- loads "autoload.json"
```

**Config-safe types:**

| Type          | Serialized as                          |
|---------------|----------------------------------------|
| boolean       | `true` / `false`                       |
| number        | number                                 |
| string        | string                                 |
| Color3        | `{ __t="Color3", R, G, B }`            |
| EnumItem      | `{ __t="Enum", N="KeyCodeName" }`      |
| table         | array (Multi Dropdown)                 |

Gracefully skips save/load if executor lacks `writefile`/`readfile` — no crash.

---

## Auto-Scale

The library uses `UIScale` bound to `CurrentCamera.ViewportSize`.

```
Scale = clamp( min(viewportX / 868, viewportY / 650), 0.55, 1.4 )
```

This means on a 1920×1080 desktop you get ~120% scale, on a 375×667 mobile you get ~55%.

Override manually:

```lua
Window:SetScale(1.2)  -- 120%
```

---

## Flags

Every component with a flag string auto-registers to `RUI.Flags`:

```lua
print(RUI.Flags.AutoFarm)       -- boolean
print(RUI.Flags.WalkSpeed)      -- number
print(RUI.Flags.FarmMode)       -- string
print(RUI.Flags.Weapons)        -- table
print(RUI.Flags.ToggleKey)      -- EnumItem
print(RUI.Flags.ESPColor)       -- Color3
```

Set `Toggle.IgnoreConfig = true` to exclude a flag from save/load.

---

## Icons

### Lucide

```lua
local Lucide = loadstring(game:HttpGet("LUCIDE_URL"))()
RUI:SetLucideModule(Lucide)
-- then use: Icon = "house", Icon = "settings", etc.
```

### Custom

```lua
RUI:AddIcons({
    home     = "rbxassetid://7734053495",
    settings = "rbxassetid://7734045186",
})
```

### Passthrough

```lua
Icon = "rbxassetid://123456"  -- used directly
```

---

## Theme

```lua
RUI:SetTheme({
    ACCENT    = Color3.fromRGB(255, 100, 100),
    BG        = Color3.fromRGB(5, 5, 10),
    TEXT      = Color3.fromRGB(255, 255, 255),
})
```

Call before `RUI:Window()` for full effect. All theme keys:

```
BG, SURFACE, ELEVATED, GLASS, PANEL,
TEXT, MUTED, DIM,
ACCENT, ACCENT_DIM, ACCENT_GLOW,
BORDER, BORDER_B,
SUCCESS, WARNING, ERROR,
TOGGLE_ON, TOGGLE_OFF, SLIDER_FILL,
SCROLL, NOTIF_BG, WHITE, BLACK
```

---

## Mobile Support

| Feature              | Support |
|----------------------|---------|
| Touch drag (header)  | ✅      |
| Touch drag (full)    | ✅ DragStyle=2 |
| Touch slider         | ✅      |
| Touch dropdown       | ✅      |
| Touch colorpicker    | ✅      |
| Touch keybind rebind | ⚠️ Keyboard only |
| Min tap target       | ✅ 40px |
| Auto layout scale    | ✅      |

---

## Differences from MacLib

| Feature | MacLib | RYEENZYXNZ V3 |
|---------|--------|----------------|
| Source | Closed-source | Original Luau |
| Sections Left/Right | Two-column | Single column (full width) |
| Colorpicker | HSV wheel | RGB+A sliders |
| AcrylicBlur | Platform-dependent | BlurEffect on camera |
| Global Settings | Full row | Header pill toggles |
| Auto-scale | Manual `:SetScale()` | Automatic + manual |
| Search bar | Not documented | Built into sidebar |

---

## Troubleshooting

**Window doesn't appear**
- Check executor console for errors.
- Ensure the URL is a raw `.lua` file link.

**Config not saving**
- Executor must support `writefile`, `readfile`, `isfile`, `makefolder`.
- Check console for `[RUI] writefile failed` warning.

**Icons not showing**
- Register via `RUI:AddIcons()` or attach Lucide with `RUI:SetLucideModule()`.

**Blank white area after a section**
- This is normal padding. Use `Section:Spacer({ Size = 0 })` to minimize.

**Keybind captured input in game**
- Add problematic keys to the `Blacklist` table.

---

## Credits

- **Design**: RYEENZYXNZ — Liquid Glass original
- **API reference**: MacLib documentation (brady-xyz.gitbook.io)
- **Implementation**: 100% custom Luau — no source copying

*RYEENZYXNZ UI V3 MacLib Edition — Built from scratch. Built different.*
