# RYEENZYXNZ V2 API

## Window

```lua
local Window = RYEENZYXNZ:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "Liquid Glass",
    Size = UDim2.fromOffset(860, 560),
    AutoScale = true,
    Search = true,
})
```

Methods:

- `Window:CreateTab({Title, Icon})`
- `Window:SelectTab(tab)`
- `Window:SetOpen(boolean)`
- `Window:Toggle()`
- `Window:Search(text)`
- `Window:Notify({Title, Content, Duration, Color})`
- `Window:Dialog({Title, Content, OnConfirm, OnCancel})`
- `Window:SaveConfig(name, table)`
- `Window:LoadConfig(name)`
- `Window:DeleteConfig(name)`
- `Window:GetConfig(name)`
- `Window:Destroy()`

## Section components

### Button
`Section:Button({Title, Icon, Callback})`

### Toggle
`Section:Toggle({Title, Description, Default, Callback})`

Returns an object with `Value` and `:Set(boolean)`.

### Slider
`Section:Slider({Title, Min, Max, Default, Increment, Callback})`

Returns an object with `Value` and `:Set(number)`.

### Dropdown
`Section:Dropdown({Title, Values, Default, Callback})`

### MultiDropdown
`Section:MultiDropdown({Title, Values, Default, Callback})`

### Input
`Section:Input({Title, Placeholder, Default, Callback})`

### Keybind
`Section:Keybind({Title, Default, Callback, OnPress})`

### ColorPicker
`Section:ColorPicker({Title, Default, Callback})`

### Paragraph
`Section:Paragraph({Title, Content})`

### Label
`Section:Label("text")`

### Divider
`Section:Divider()`

## Icons

Use Lucide-style names:

`home`, `settings`, `search`, `bell`, `palette`, `monitor`, `smartphone`, `gamepad`, `globe`, `zap`, `star`, `heart`, `info`, `wrench`, `code`, `folder`, `keyboard`, `mouse`, `camera`, `sun`, `moon`, etc.

Custom mapping:

```lua
RYEENZYXNZ:SetIcon("custom", "rbxassetid://1234567890")
```
