--[[
    RYEENZYXNZ UI V3.1 — MAC STYLE DEMO
    One-line loader + complete feature showcase.

    Public GitHub:
    https://github.com/acountdiscord86-art/RYEENZYXNZ

    IMPORTANT:
    This example loads the main single-file library from the same repository.
]]

local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/refs/heads/main/RYEENZYXNZ_UI_V3.lua"
))()

-- Optional Lucide module:
-- local Lucide = require(path.to.LucideRoblox)
-- UI:SetLucideModule(Lucide)

UI:AddIcons({
    home = "rbxassetid://7734053495",
    settings = "rbxassetid://7734045186",
    play = "rbxassetid://7734046701",
    palette = "rbxassetid://7734043713",
})

local Window = UI:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "Mac-style Liquid Glass",
    Logo = "rbxassetid://7734053495",
    BackgroundImage = "rbxassetid://6580198993",
    BackgroundImageTransparency = 0.58,
    BackgroundOverlayTransparency = 0.30,
    Size = UDim2.fromOffset(868, 600),
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigFolder = "RYEENZYXNZ",
    ConfigName = "Default",
})

-- Window controls
Window:SetTitle("RYEENZYXNZ")
Window:SetSubtitle("V3.1 • Mac-style")
Window:SetToggleKey(Enum.KeyCode.RightControl)

local Main = Window:CreateTab({Title = "Demo", Icon = "home"})
local Settings = Window:CreateTab({Title = "Settings", Icon = "settings"})

Main:CreateHeader("CONTROLS")

Main:CreateParagraph({
    Title = "Welcome",
    Content = "RYEENZYXNZ V3.1 is a custom Luau UI library with Mac-style navigation, glass surfaces, responsive controls, mobile input and config persistence.",
})

Main:CreateButton({
    Title = "Show Notification",
    Callback = function()
        Window:Notify({
            Title = "RYEENZYXNZ",
            Description = "Everything is working.",
            Lifetime = 4,
        })
    end,
})

Main:CreateToggle({
    Title = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Toggle:", value)
    end,
})

Main:CreateSlider({
    Title = "Power",
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 50,
    Flag = "Power",
    Callback = function(value)
        print("Slider:", value)
    end,
})

local Dropdown = Main:CreateDropdown({
    Title = "Fruit",
    Values = {"Apple", "Banana", "Orange", "Grapes", "Mango"},
    Default = "Apple",
    Flag = "Fruit",
    Callback = function(value)
        print("Dropdown:", value)
    end,
})

local Multi = Main:CreateMultiDropdown({
    Title = "Features",
    Values = {"ESP", "Aimbot", "Speed", "Jump"},
    Default = {"ESP", "Speed"},
    Flag = "Features",
    Callback = function(values)
        print("Multi:", table.concat(values, ", "))
    end,
})

Main:CreateInput({
    Title = "Username",
    Placeholder = "Type something...",
    Default = "",
    Flag = "Username",
    Callback = function(text)
        print("Input:", text)
    end,
})

Main:CreateKeybind({
    Title = "Test Keybind",
    Default = Enum.KeyCode.F,
    Flag = "TestKey",
    Callback = function(key)
        print("Pressed:", key.Name)
    end,
    onBinded = function(key)
        print("Bound:", key.Name)
    end,
})

local Color = Main:CreateColorPicker({
    Title = "Accent Color",
    Default = Color3.fromRGB(124, 104, 255),
    Flag = "AccentColor",
    Callback = function(color)
        print("Color:", color)
    end,
})

Main:CreateDivider()
Main:CreateHeader("EXTRA")

Main:CreateLabel("Simple label / information line")
Main:CreateSubLabel("Secondary text for small notes.")

local Progress = Main:CreateProgressBar({
    Title = "Progress",
    Min = 0,
    Max = 100,
    Default = 65,
})

Main:CreateImage({
    Image = "rbxassetid://6580198993",
    Height = 120,
    Caption = "Background image component",
})

Main:CreateButton({
    Title = "Update Controls",
    Callback = function()
        Dropdown:UpdateSelection("Grapes")
        Multi:UpdateSelection({"Banana", "Mango"})
        Progress:Set(85, true)
        Color:SetColor(Color3.fromRGB(80, 200, 255))
    end,
})

Settings:CreateHeader("CONFIG")

Settings:CreateButton({
    Title = "Save Config",
    Callback = function()
        Window:SaveConfig("Default")
        Window:Notify({Title = "Config", Description = "Saved Default.", Lifetime = 3})
    end,
})

Settings:CreateButton({
    Title = "Load Config",
    Callback = function()
        Window:LoadConfig("Default")
        Window:Notify({Title = "Config", Description = "Loaded Default.", Lifetime = 3})
    end,
})

Settings:CreateButton({
    Title = "Delete Config",
    Callback = function()
        Window:DeleteConfig("Default")
        Window:Notify({Title = "Config", Description = "Deleted Default.", Lifetime = 3})
    end,
})

Settings:CreateButton({
    Title = "Open Dialog",
    Callback = function()
        Window:Dialog({
            Title = "RYEENZYXNZ",
            Description = "This is a Mac-style modal dialog.",
            Buttons = {
                {
                    Name = "Confirm",
                    Callback = function()
                        print("Confirmed")
                    end,
                },
                {Name = "Cancel"},
            },
        })
    end,
})

Settings:CreateHeader("WINDOW")

Settings:CreateButton({
    Title = "Toggle Window",
    Callback = function()
        Window:Toggle()
    end,
})

Settings:CreateButton({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end,
})

Window:Notify({
    Title = "RYEENZYXNZ",
    Description = "UI loaded successfully.",
    Lifetime = 5,
})
