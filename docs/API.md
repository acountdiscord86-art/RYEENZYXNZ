# RYEENZYXNZ API

## Window

```lua
local Window = RYEENZYXNZ:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "LIQUID GLASS UI LIBRARY",
    Size = UDim2.fromOffset(920, 600),
    AutoScale = true,
})
```

Methods:
- `Window:CreateTab(options)`
- `Window:SelectTab(tab)`
- `Window:Notify(options)`
- `Window:Destroy()`

## Tab

```lua
local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
})
```

## Section

```lua
local Section = Tab:Section({
    Title = "Visual Settings",
    Box = true,
})
```

## Components

### Button
`Section:Button({Title = "Button", Callback = function() end})`

### Toggle
`Section:Toggle({Title = "Toggle", Default = false, Callback = function(value) end})`

### Slider
`Section:Slider({Title = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(value) end})`

### Dropdown
`Section:Dropdown({Title = "Mode", Values = {"A", "B"}, Default = "A", Callback = function(value) end})`

### Input
`Section:Input({Title = "Name", Placeholder = "Enter...", Callback = function(value) end})`

### Paragraph
`Section:Paragraph({Title = "Title", Desc = "Description"})`

### Divider
`Section:Divider()`

## Notifications

```lua
Window:Notify({
    Title = "RYEENZYXNZ",
    Content = "Loaded successfully!",
    Duration = 3,
})
```

## Config

```lua
local Config = RYEENZYXNZ:CreateConfig("default")
Config:Set("Speed", 50)
Config:Save()
Config:Load()
```

Filesystem config requires executor APIs such as `writefile`, `readfile`, `isfile`, `isfolder`, and `makefolder`.
