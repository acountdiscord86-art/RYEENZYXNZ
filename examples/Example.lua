--[[
    RYNZYEXZ UI Library
    Complete component showcase
    Raw URL: https://raw.githubusercontent.com/acountdiscord86-art/RYNZYEXZ/main/main.lua
]]

local RYNZYEXZ = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/refs/heads/main/main.lua"
))()

local Window = RYNZYEXZ:CreateWindow({
    Name = "RYNZYEXZ",
    BrandSubtitle = "memek boreup" .. RYNZYEXZ.Version,
    Size = UDim2.fromOffset(760, 520),
    ToggleKey = Enum.KeyCode.RightControl,
    LoadingAnimation = true,
    LoadingText = "RYNZYEXZ",
    LoadingSubtitle = "UI LIBRARY",
    LoadingFooter = "RYNZYEXZ",
    ReplaceExisting = true,
})

-- MAIN ----------------------------------------------------------------------
local Main = Window:AddTab({
    Name = "Main",
    Icon = "home",
    Subtitle = "Basic components",
})
local General = Main:AddSubTab("General")

General:AddSection("Buttons & Toggles")

General:AddButton({
    Name = "Test Notification",
    Primary = true,
    Callback = function()
        Window:Notify({
            Title = "RYNZYEXZ",
            Content = "Button berhasil ditekan.",
            Type = "success",
            Duration = 3,
        })
    end,
})

local SpeedToggle = General:AddToggle({
    Name = "Speed Boost",
    Description = "Contoh toggle dengan Flag.",
    Default = false,
    Flag = "SpeedBoost",
    Callback = function(enabled)
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = enabled and 50 or 16
        end
    end,
})

General:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = "",
    Flag = "WalkSpeed",
    Callback = function(value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = value end
    end,
})

General:AddKeybind({
    Name = "Toggle UI",
    Description = "Tekan tombol untuk hide/show UI.",
    Default = Enum.KeyCode.RightControl,
    Flag = "UIToggle",
    OnPress = function()
        Window:ToggleUI()
    end,
})

General:AddDivider()
General:AddSection("Inputs")

General:AddInput({
    Name = "Player Name",
    Description = "Contoh TextBox.",
    Placeholder = "Masukkan nama player...",
    Flag = "PlayerName",
    Callback = function(text)
        print("Player Name:", text)
    end,
})

General:AddDropdown({
    Name = "Mode",
    Description = "Single selection dropdown.",
    Options = { "Default", "Fast", "Smooth", "Extreme" },
    Default = "Default",
    Searchable = true,
    Flag = "Mode",
    Callback = function(value)
        print("Mode:", value)
    end,
})

General:AddMultiDropdown({
    Name = "Features",
    Description = "Multiple selection dropdown.",
    Options = { "ESP", "Fly", "Speed", "Jump", "Noclip" },
    Default = { "ESP" },
    Searchable = true,
    Flag = "Features",
    Callback = function(values)
        print("Selected:", table.concat(values, ", "))
    end,
})

General:AddColorPicker({
    Name = "Accent Color",
    Description = "Color picker example.",
    Default = Color3.fromRGB(120, 80, 255),
    Flag = "AccentColor",
    Callback = function(color)
        print("Color:", color)
    end,
})

General:AddParagraph({
    Title = "RYNZYEXZ",
    Text = "Semua komponen di contoh ini dibuat langsung dengan Roblox Instance. Tidak membutuhkan screenshot UI sebagai background.",
})

-- VISUALS -------------------------------------------------------------------
local Visuals = Window:AddTab({
    Name = "Visuals",
    Icon = "eye",
    Subtitle = "Dropdown, color and sliders",
})
local VisualSub = Visuals:AddSubTab("Visual Settings")

VisualSub:AddSection("Appearance")
VisualSub:AddSlider({
    Name = "Transparency",
    Min = 0,
    Max = 100,
    Default = 20,
    Suffix = "%",
    Flag = "Transparency",
    Callback = function(value)
        print("Transparency:", value)
    end,
})

VisualSub:AddDropdown({
    Name = "ESP Mode",
    Options = { "Box", "Highlight", "Name", "Off" },
    Default = "Highlight",
    Searchable = true,
    Flag = "ESPMode",
    Callback = function(mode)
        print("ESP Mode:", mode)
    end,
})

VisualSub:AddMultiDropdown({
    Name = "ESP Targets",
    Options = { "Players", "NPCs", "Items", "Vehicles" },
    Default = { "Players" },
    Flag = "ESPTargets",
    Callback = function(list)
        print("Targets:", table.concat(list, ", "))
    end,
})

VisualSub:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(167, 200, 244),
    Flag = "ESPColor",
    Callback = function(color)
        print("ESP Color:", color)
    end,
})

-- SETTINGS ------------------------------------------------------------------
local Settings = Window:AddTab({
    Name = "Settings",
    Icon = "settings",
    Subtitle = "Themes and configs",
})
local SettingsSub = Settings:AddSubTab("Settings")

SettingsSub:AddSection("Theme")
SettingsSub:AddDropdown({
    Name = "Theme",
    Options = { "Dark", "Light", "OLED" },
    Default = "Dark",
    Flag = "Theme",
    Callback = function(theme)
        if RYNZYEXZ:SetTheme(theme) then
            Window:Notify({
                Title = "Theme",
                Content = "Theme switched to " .. theme,
                Type = "info",
                Duration = 2,
            })
        end
    end,
})

SettingsSub:AddSection("Config")
SettingsSub:AddButton({
    Name = "Save Config",
    Primary = true,
    Callback = function()
        local ok = RYNZYEXZ:SaveConfig("example")
        Window:Notify({
            Title = "Config",
            Content = ok and "Config saved." or "Save failed. Filesystem API may be unavailable.",
            Type = ok and "success" or "error",
            Duration = 3,
        })
    end,
})

SettingsSub:AddButton({
    Name = "Load Config",
    Callback = function()
        local ok = RYNZYEXZ:LoadConfig("example")
        Window:Notify({
            Title = "Config",
            Content = ok and "Config loaded." or "No config found.",
            Type = ok and "success" or "warning",
            Duration = 3,
        })
    end,
})

SettingsSub:AddButton({
    Name = "Reset Config",
    Callback = function()
        local ok = RYNZYEXZ:DeleteConfig("example")
        Window:Notify({
            Title = "Config",
            Content = ok and "Config deleted." or "No config deleted.",
            Type = ok and "success" or "warning",
            Duration = 3,
        })
    end,
})

SettingsSub:AddParagraph({
    Title = "About",
    Text = "RYNZYEXZ is a standalone Roblox UI library with Liquid Glass styling, tabs, subtabs, sliders, dropdowns, multi-dropdowns, inputs, keybinds, color pickers, notifications, themes and config persistence.",
})
SettingsSub:AddLabel({ Text = "Version: " .. RYNZYEXZ.Version })

-- Optional auto-load --------------------------------------------------------
pcall(function()
    RYNZYEXZ:LoadConfig("example")
end)

Window:Notify({
    Title = "RYNZYEXZ",
    Content = "Example loaded. RightControl toggles the UI.",
    Type = "info",
    Duration = 5,
})
