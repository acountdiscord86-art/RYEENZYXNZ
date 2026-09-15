-- RYEENZYXNZ Liquid Glass UI Library - Example
-- Executor/loadstring example.

local RYEENZY = loadstring(game:HttpGet("YOUR_RAW_LIBRARY_URL/main.lua"))()

local Window = RYEENZY:CreateWindow({
    Title = "RYEENZYXNZ",
    Subtitle = "LIQUID GLASS UI LIBRARY",
    AutoScale = true,
    Size = UDim2.fromOffset(920, 600),
})

local Main = Window:CreateTab({Name = "Home", Icon = "home"})
local Visuals = Window:CreateTab({Name = "Visuals", Icon = "eye"})
local Player = Window:CreateTab({Name = "Player", Icon = "user"})
local Settings = Window:CreateTab({Name = "Settings", Icon = "settings"})

local MainSection = Main:Section({
    Title = "Visual Settings",
    Box = true,
})

MainSection:Paragraph({
    Title = "Welcome Back, RYEENZYXNZ 👑",
    Desc = "Modern Liquid Glass components for your Roblox script.",
})

MainSection:Button({
    Title = "Test Notification",
    Callback = function()
        Window:Notify({
            Title = "RYEENZYXNZ",
            Content = "Liquid Glass UI loaded successfully!",
            Duration = 3,
        })
    end,
})

MainSection:Toggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(state)
        print("FPS Boost:", state)
    end,
})

MainSection:Slider({
    Title = "Brightness",
    Min = 0,
    Max = 100,
    Default = 70,
    Callback = function(value)
        print("Brightness:", value)
    end,
})

MainSection:Dropdown({
    Title = "Graphics Quality",
    Values = {"Low", "Medium", "High"},
    Default = "High",
    Callback = function(value)
        print("Graphics:", value)
    end,
})

MainSection:Input({
    Title = "Player Name",
    Placeholder = "Enter player name...",
    Callback = function(value)
        print("Input:", value)
    end,
})

local Config = RYEENZY:CreateConfig("default")
Config:Set("Brightness", 70)
Config:Set("Graphics", "High")
-- Config:Save() -- enable if your executor provides writefile/readfile/isfile/isfolder/makefolder

Window:Notify({
    Title = "RYEENZYXNZ",
    Content = "UI loaded successfully.",
    Duration = 3,
})
