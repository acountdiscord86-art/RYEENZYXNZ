# RYNZYEXZ API Reference

## Library

### `RYNZYEXZ:CreateWindow(options)`
Creates a window and returns a Window object.

Common options:

| Option | Type | Purpose |
|---|---|---|
| `Name` | string | Window title |
| `BrandSubtitle` | string | Subtitle |
| `Size` | UDim2 | Base window size |
| `Position` | UDim2 | Initial position |
| `ToggleKey` | KeyCode | Global UI toggle key |
| `Logo` | string | Image asset id |
| `LogoZoom` | number | Logo zoom |
| `GuiName` | string | ScreenGui name |
| `DisplayOrder` | number | Display priority |
| `Mobile` | boolean | Force mobile mode |
| `Parent` | Instance | Optional GUI parent |
| `ReplaceExisting` | boolean | Replace same-named GUI |
| `LoadingAnimation` | boolean | Enable loading animation |
| `LoadingText` | string | Loading title |
| `LoadingSubtitle` | string | Loading subtitle |
| `LoadingFooter` | string | Loading footer |

### `RYNZYEXZ:SetTheme(theme)`
Applies a built-in theme name or a compatible custom theme table.

### `RYNZYEXZ:GetTheme()`
Returns the active theme name.

### `RYNZYEXZ:GetIcons()`
Returns the built-in icon map.

### `RYNZYEXZ:GetIcon(name)`
Returns an icon asset id by name.

### `RYNZYEXZ:GetFlag(flag, default)`
Reads a registered component value.

### `RYNZYEXZ:SetFlag(flag, value)`
Writes a registered component value.

### `RYNZYEXZ:GetConfig()`
Returns current registered flag values.

### `RYNZYEXZ:LoadConfigData(data)`
Loads values from a Lua table produced by the config format.

### `RYNZYEXZ:SaveConfig(name)`
Saves the current config to the configured folder when filesystem APIs are available.

### `RYNZYEXZ:LoadConfig(name)`
Loads a saved config.

### `RYNZYEXZ:ListConfigs()`
Returns available config names when supported by the runtime.

### `RYNZYEXZ:DeleteConfig(name)`
Deletes a config when supported.

### `RYNZYEXZ:Notify(options)`
Creates a library notification.

### `RYNZYEXZ:Notification(options)`
Alias for `Notify`.

## Window

- `Window:AddTab(options)`
- `Window:SetVisible(boolean)`
- `Window:Toggle()`
- `Window:SetUIVisible(boolean)`
- `Window:ToggleUI()`
- `Window:SetProfileVisible(boolean)`
- `Window:ToggleProfile()`
- `Window:SetLogo(assetId)`
- `Window:Notify(options)`
- `Window:Destroy()`

## Tab

- `Tab:AddSubTab(name)`

## SubTab

- `SubTab:AddSection(nameOrOptions)`
- `SubTab:AddButton(options)`
- `SubTab:AddToggle(options)`
- `SubTab:AddSlider(options)`
- `SubTab:AddDropdown(options)`
- `SubTab:AddMultiDropdown(options)`
- `SubTab:AddInput(options)`
- `SubTab:AddKeybind(options)`
- `SubTab:AddColorPicker(options)`
- `SubTab:AddParagraph(options)`
- `SubTab:AddLabel(options)`
- `SubTab:AddDivider()`

## Component options

### Button

```lua
{
    Name = "Button",
    Primary = false,
    Callback = function() end,
}
```

### Toggle

```lua
{
    Name = "Toggle",
    Description = "Optional description",
    Default = false,
    Flag = "MyToggle",
    Callback = function(value) end,
}
```

### Slider

```lua
{
    Name = "Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Flag = "MySlider",
    Callback = function(value) end,
}
```

### Dropdown

```lua
{
    Name = "Dropdown",
    Options = { "A", "B", "C" },
    Default = "A",
    Searchable = true,
    MaxVisible = 5,
    Flag = "MyDropdown",
    Callback = function(value) end,
}
```

### MultiDropdown

```lua
{
    Name = "Multi",
    Options = { "A", "B", "C" },
    Default = { "A" },
    Searchable = true,
    MaxVisible = 5,
    Flag = "MyMulti",
    Callback = function(values) end,
}
```

### Input

```lua
{
    Name = "Input",
    Description = "Optional",
    Default = "",
    Placeholder = "Type...",
    Flag = "MyInput",
    Callback = function(text, enterPressed) end,
}
```

### Keybind

```lua
{
    Name = "Keybind",
    Default = Enum.KeyCode.F,
    Flag = "MyKey",
    OnPress = function(key) end,
}
```

### ColorPicker

```lua
{
    Name = "Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "MyColor",
    Callback = function(color) end,
}
```
