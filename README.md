# RYNZYEXZ

Modern Roblox UI library with a dark **Liquid Glass** aesthetic.

> This package is an original implementation. It is not a copy of another UI library's source code.

## Features

- Liquid Glass dark interface
- Responsive/mobile-aware layout
- Window dragging
- Tabs + subtabs
- Button
- Toggle
- Slider
- Dropdown
- MultiDropdown
- Input
- Keybind
- ColorPicker
- Paragraph
- Label
- Divider
- Notifications
- Dialogs
- Theme switching
- Flags
- JSON config save/load/delete/list
- Built-in icon name mapping
- Optional logo support
- Executor filesystem support when available
- Cleanup through `Window:Destroy()`

## Quick Start

```lua
local RYNZYEXZ = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/acountdiscord86-art/RYNZYEXZ/main/main.lua"
))()

local Window = RYNZYEXZ:CreateWindow({
    Name = "My Hub",
    BrandSubtitle = "Powered by RYNZYEXZ",
    Size = UDim2.fromOffset(700, 490),
    ToggleKey = Enum.KeyCode.RightControl,
})

local Tab = Window:AddTab({
    Name = "Main",
    Icon = "home",
})

local Sub = Tab:AddSubTab("General")
Sub:AddSection("Example")

Sub:AddButton({
    Name = "Hello",
    Callback = function()
        Window:Notify({
            Title = "RYNZYEXZ",
            Content = "Hello world!",
            Type = "success",
        })
    end,
})
```

## Local / Executor Loading

If your environment supports `readfile`, you can load the local library:

```lua
local RYNZYEXZ = loadstring(readfile("RYNZYEXZ/main.lua"))()
```

The exact folder path depends on your executor's filesystem.

## Files

```text
RYNZYEXZ/
├── main.lua
├── examples/
│   └── Example.lua
├── docs/
│   ├── GUIDE.md
│   ├── API.md
│   └── COMPONENTS.md
├── src/
│   └── README.md
├── LICENSE-NOTICE.md
├── CHANGELOG.md
└── README.md
```

## Important

The example URL assumes your GitHub repository is:

`acountdiscord86-art/RYNZYEXZ`

and the library file is at:

`main.lua`

If the repository or branch changes, update the URL in `examples/Example.lua` and your loader.

## Documentation

- [GUIDE.md](docs/GUIDE.md) — complete usage guide
- [API.md](docs/API.md) — method reference
- [COMPONENTS.md](docs/COMPONENTS.md) — component examples
- [CHANGELOG.md](CHANGELOG.md) — version history
- [LICENSE-NOTICE.md](LICENSE-NOTICE.md) — licensing note
