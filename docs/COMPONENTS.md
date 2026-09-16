# RYNZYEXZ Components

This page is a compact copy/paste reference.

## Button

```lua
Sub:AddButton({
    Name = "Execute",
    Primary = true,
    Callback = function()
        print("execute")
    end,
})
```

## Toggle

```lua
Sub:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        print(state)
    end,
})
```

## Slider

```lua
Sub:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 250,
    Default = 50,
    Flag = "Speed",
    Callback = function(value)
        print(value)
    end,
})
```

## Dropdown

```lua
Sub:AddDropdown({
    Name = "Mode",
    Options = {"Normal", "Fast", "Ultra"},
    Default = "Normal",
    Searchable = true,
    Callback = function(value)
        print(value)
    end,
})
```

## MultiDropdown

```lua
Sub:AddMultiDropdown({
    Name = "ESP",
    Options = {"Players", "NPCs", "Items"},
    Default = {"Players"},
    Callback = function(values)
        print(table.concat(values, ", "))
    end,
})
```

## Input

```lua
Sub:AddInput({
    Name = "Target",
    Placeholder = "Username",
    Callback = function(value)
        print(value)
    end,
})
```

## Keybind

```lua
Sub:AddKeybind({
    Name = "Feature Key",
    Default = Enum.KeyCode.Q,
    OnPress = function(key)
        print("Pressed", key.Name)
    end,
})
```

## ColorPicker

```lua
Sub:AddColorPicker({
    Name = "Highlight",
    Default = Color3.fromRGB(100, 150, 255),
    Callback = function(color)
        print(color)
    end,
})
```

## Paragraph / Label / Divider

```lua
Sub:AddParagraph({
    Title = "Information",
    Text = "Description text.",
})

Sub:AddLabel({ Text = "Status: Ready" })
Sub:AddDivider()
```
