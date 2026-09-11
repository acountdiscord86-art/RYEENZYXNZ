--[[
    RYEENZYXNZ UI V3 — EXAMPLE
    Demonstrates every component and API.
    Replace URL below with your actual raw GitHub / paste link.
]]

-- ─────────────────────────────────────────────────────────────
-- LOAD LIBRARY
-- ─────────────────────────────────────────────────────────────
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/acountdiscord86-art/RYEENZYXNZ/refs/heads/main/RYEENZYXNZ_UI_V3.lua"))()

-- ─────────────────────────────────────────────────────────────
-- OPTIONAL: LUCIDE MODULE
-- If you have a Lucide module hosted, load it here:
-- local Lucide = loadstring(game:HttpGet("LUCIDE_URL"))()
-- UI:SetLucideModule(Lucide)
-- ─────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────
-- OPTIONAL: CUSTOM ICONS
-- ─────────────────────────────────────────────────────────────
UI:AddIcons({
    home      = "rbxassetid://7734053495",
    settings  = "rbxassetid://7734045186",
    play      = "rbxassetid://7734046701",
    star      = "rbxassetid://7734043713",
})

-- ─────────────────────────────────────────────────────────────
-- OPTIONAL: CUSTOM THEME
-- ─────────────────────────────────────────────────────────────
-- UI:SetTheme({
--     Accent = Color3.fromRGB(255, 100, 100),
-- })

-- ─────────────────────────────────────────────────────────────
-- CREATE WINDOW
-- ─────────────────────────────────────────────────────────────
local Window = UI:CreateWindow({
    Title                       = "RYEENZYXNZ",
    Subtitle                    = "Premium Liquid Glass v3",
    Logo                        = "rbxassetid://7734053495",       -- replace with your logo
    BackgroundImage             = "rbxassetid://6580198993",       -- replace with your bg
    BackgroundImageTransparency = 0.55,
    BackgroundOverlayTransparency = 0.32,
    Size                        = UDim2.fromOffset(780, 520),
    ConfigFolder                = "RYEENZYXNZ",
    ConfigName                  = "default",
    ToggleKey                   = Enum.KeyCode.RightShift,
})

-- ─────────────────────────────────────────────────────────────
-- TAB 1 — HOME
-- ─────────────────────────────────────────────────────────────
local Home = Window:CreateTab({
    Title = "Home",
    Icon  = "home",
})

-- SECTION
Home:CreateSection("Dashboard")

-- PARAGRAPH
Home:CreateParagraph({
    Title   = "Welcome to RYEENZYXNZ UI V3",
    Content = "A premium Liquid Glass UI library built from scratch in Luau. "
           .. "Supports PC, mobile, config system, and Lucide icons.",
})

-- BUTTON
Home:CreateButton({
    Title    = "Print Hello",
    Icon     = "play",
    Callback = function()
        print("[RYEENZYXNZ] Hello from Button!")
        Window:Notify({
            Title   = "Button Clicked",
            Content = "Hello from RYEENZYXNZ UI V3!",
            Duration = 3,
        })
    end,
})

-- TOGGLE
local AutoFarmToggle = Home:CreateToggle({
    Title    = "Auto Farm",
    Flag     = "AutoFarm",
    Default  = false,
    Callback = function(value)
        print("[RYEENZYXNZ] Auto Farm:", value)
    end,
})

-- SLIDER
local SpeedSlider = Home:CreateSlider({
    Title    = "Walk Speed",
    Flag     = "WalkSpeed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Step     = 1,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end,
})

local JumpSlider = Home:CreateSlider({
    Title    = "Jump Power",
    Flag     = "JumpPower",
    Min      = 7,
    Max      = 200,
    Default  = 50,
    Step     = 1,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end,
})

-- SECTION 2
Home:CreateSection("Targeting")

-- DROPDOWN
local ModeDropdown = Home:CreateDropdown({
    Title    = "Farm Mode",
    Flag     = "FarmMode",
    Values   = { "Passive", "Aggressive", "Stealth", "Custom" },
    Default  = "Passive",
    Callback = function(value)
        print("[RYEENZYXNZ] Farm Mode:", value)
    end,
})

-- MULTI DROPDOWN
local FeaturesMulti = Home:CreateMultiDropdown({
    Title    = "Active Features",
    Flag     = "ActiveFeatures",
    Values   = { "ESP", "Aimbot", "Auto Farm", "Auto Collect", "Notifications" },
    Default  = { "ESP", "Notifications" },
    Callback = function(values)
        print("[RYEENZYXNZ] Features:", table.concat(values, ", "))
    end,
})

-- ─────────────────────────────────────────────────────────────
-- TAB 2 — SETTINGS
-- ─────────────────────────────────────────────────────────────
local Settings = Window:CreateTab({
    Title = "Settings",
    Icon  = "settings",
})

-- SECTION
Settings:CreateSection("Player")

-- INPUT
local PlayerInput = Settings:CreateInput({
    Title       = "Target Player",
    Flag        = "TargetPlayer",
    Placeholder = "Enter player name...",
    Callback    = function(value, enterPressed)
        print("[RYEENZYXNZ] Target Player:", value, "| Enter:", enterPressed)
    end,
})

-- KEYBIND
local MenuKeybind = Settings:CreateKeybind({
    Title    = "Toggle Menu Key",
    Flag     = "MenuKey",
    Default  = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("[RYEENZYXNZ] New key:", key.Name)
        Window:SetToggleKey(key)
    end,
})

-- SECTION
Settings:CreateSection("Visual")

-- COLOR PICKER
local AccentColor = Settings:CreateColorPicker({
    Title    = "Accent Color",
    Flag     = "AccentColor",
    Default  = Color3.fromRGB(124, 104, 255),
    Callback = function(color)
        print(string.format(
            "[RYEENZYXNZ] Accent: RGB(%d, %d, %d)",
            math.round(color.R * 255),
            math.round(color.G * 255),
            math.round(color.B * 255)
        ))
    end,
})

local ESPColor = Settings:CreateColorPicker({
    Title    = "ESP Color",
    Flag     = "ESPColor",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(color)
        print("[RYEENZYXNZ] ESP Color changed")
    end,
})

-- SECTION
Settings:CreateSection("Toggles")

local NotifToggle = Settings:CreateToggle({
    Title    = "Show Notifications",
    Flag     = "ShowNotif",
    Default  = true,
    Callback = function(value)
        print("[RYEENZYXNZ] Notifications:", value)
    end,
})

local DebugToggle = Settings:CreateToggle({
    Title    = "Debug Mode",
    Flag     = "DebugMode",
    Default  = false,
    Callback = function(value)
        print("[RYEENZYXNZ] Debug:", value)
    end,
})

-- FOV Slider
local FOVSlider = Settings:CreateSlider({
    Title    = "Field of View",
    Flag     = "FOV",
    Min      = 10,
    Max      = 120,
    Default  = 70,
    Step     = 5,
    Callback = function(value)
        print("[RYEENZYXNZ] FOV:", value)
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = value end
    end,
})

-- ─────────────────────────────────────────────────────────────
-- TAB 3 — CONFIG
-- ─────────────────────────────────────────────────────────────
local ConfigTab = Window:CreateTab({
    Title = "Config",
    Icon  = "star",
})

ConfigTab:CreateSection("Configuration")

ConfigTab:CreateParagraph({
    Title   = "Config System",
    Content = "Save and load your settings. Configs are stored in the executor's "
           .. "workspace folder under 'RYEENZYXNZ/'. "
           .. "Supported: Toggle, Slider, Dropdown, MultiDropdown, Input, Keybind, ColorPicker.",
})

ConfigTab:CreateButton({
    Title    = "Save Config",
    Icon     = "star",
    Callback = function()
        Window:SaveConfig("default")
        Window:Notify({
            Title    = "Config Saved",
            Content  = "Configuration saved to 'RYEENZYXNZ/default.json'",
            Duration = 3,
        })
        print("[RYEENZYXNZ] Config saved.")
    end,
})

ConfigTab:CreateButton({
    Title    = "Load Config",
    Icon     = "play",
    Callback = function()
        Window:LoadConfig("default")
        Window:Notify({
            Title    = "Config Loaded",
            Content  = "Configuration loaded from 'RYEENZYXNZ/default.json'",
            Duration = 3,
        })
        print("[RYEENZYXNZ] Config loaded.")
    end,
})

ConfigTab:CreateButton({
    Title    = "Delete Config",
    Icon     = "home",
    Callback = function()
        Window:DeleteConfig("default")
        Window:Notify({
            Title    = "Config Deleted",
            Content  = "Configuration 'RYEENZYXNZ/default.json' deleted.",
            Duration = 3,
        })
        print("[RYEENZYXNZ] Config deleted.")
    end,
})

ConfigTab:CreateSection("Flags Debug")

ConfigTab:CreateButton({
    Title    = "Print All Flags",
    Callback = function()
        print("[RYEENZYXNZ] === FLAGS ===")
        for flag, value in pairs(Window.Flags) do
            print(string.format("  %s = %s", tostring(flag), tostring(value)))
        end
        print("[RYEENZYXNZ] === END ===")
    end,
})

-- ─────────────────────────────────────────────────────────────
-- PROGRAMMATIC API DEMO (runs on load)
-- ─────────────────────────────────────────────────────────────
task.spawn(function()
    task.wait(1)

    -- Test programmatic setters
    SpeedSlider:Set(50)
    AutoFarmToggle:Set(true)
    ModeDropdown:Set("Aggressive")
    FeaturesMulti:Set({ "ESP", "Auto Farm", "Notifications" })
    PlayerInput:Set("RYEENZYXNZ")

    task.wait(0.5)

    -- Welcome notification
    Window:Notify({
        Title    = "RYEENZYXNZ UI V3",
        Content  = "Successfully loaded! Press RightShift to toggle.",
        Duration = 5,
    })
end)
