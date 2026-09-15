local RYEENZYXNZ = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/main/main.lua"
))()

local Window = RYEENZYXNZ:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "Liquid Glass V3",
    AutoScale = true,
    Search = true,
    PremiumDefaults = true,
})

local Home = Window:CreateTab({
    Title = "Home",
    Icon = "home",
})

local Main = Home:Section({
    Title = "Main Controls",
})

Main:Button({
    Id = "TestButton",
    Title = "Test Button",
    Icon = "play",
    Callback = function()
        Window:NotifySuccess("RYEENZYXNZ", "Button works!")
    end,
})

local Enabled = Main:Toggle({
    Id = "Enabled",
    Title = "Enabled",
    Description = "Example toggle",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

local Speed = Main:Slider({
    Id = "Speed",
    Title = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Speed:", value)
    end,
})

Main:Dropdown({
    Id = "Mode",
    Title = "Mode",
    Values = {"Default", "Fast", "Smooth"},
    Default = "Default",
    Callback = function(value)
        print("Mode:", value)
    end,
})

Main:Keybind({
    Id = "ToggleKey",
    Title = "Toggle Key",
    Default = Enum.KeyCode.RightShift,
    OnPress = function()
        Window:Toggle()
    end,
})

local Settings = Window:CreateTab({
    Title = "Settings",
    Icon = "settings",
})

local Interface = Settings:Section({Title = "Interface"})
Interface:Button({Title = "Close UI", Icon = "x", Callback = function() Window:Close() end})
Interface:Button({Title = "Save State", Icon = "save", Callback = function() Window:SaveState("autosave") end})
Interface:Button({Title = "Load State", Icon = "refresh", Callback = function() Window:LoadState("autosave") end})

Window:SetWatermark("RYEENZYXNZ • V3")
