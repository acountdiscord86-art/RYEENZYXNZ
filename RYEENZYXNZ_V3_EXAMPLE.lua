--[[
    RYEENZYXNZ UI V3 — MACLIB EDITION
    Full Example Script — shows EVERY component and API

    Replace URL with your actual raw GitHub link.
]]

-- ═══════════════════════════════════════════════════════
-- LOAD
-- ═══════════════════════════════════════════════════════
local RUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_NAME/RYEENZYXNZ_V3/main/RYEENZYXNZ_V3.lua"
))()

-- ═══════════════════════════════════════════════════════
-- OPTIONAL SETUP
-- ═══════════════════════════════════════════════════════

-- Custom icons (if no Lucide)
RUI:AddIcons({
    home     = "rbxassetid://7734053495",
    settings = "rbxassetid://7734045186",
    combat   = "rbxassetid://7734046701",
    config   = "rbxassetid://7734043713",
    info     = "rbxassetid://7734056171",
})

-- Optional: custom theme override
-- RUI:SetTheme({
--     ACCENT = Color3.fromRGB(255, 100, 100),
-- })

-- Optional: set save folder
RUI:SetFolder("RYEENZYXNZ_V3")

-- ═══════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════
local Window = RUI:Window({
    Title                  = "RYEENZYXNZ HUB",
    Subtitle               = "Premium Liquid Glass · V3",
    Size                   = UDim2.fromOffset(900, 660),
    DragStyle              = 1,
    DisabledWindowControls = {},
    ShowUserInfo           = true,
    Keybind                = Enum.KeyCode.RightShift,
    AcrylicBlur            = false,
})

-- Detect unload
Window:onUnloaded(function()
    print("[RYEENZYXNZ] Window closed.")
end)

-- ═══════════════════════════════════════════════════════
-- GLOBAL SETTINGS (header pills)
-- ═══════════════════════════════════════════════════════
Window:AddGlobalSetting({
    Name     = "Safe Mode",
    Default  = false,
    Callback = function(v)
        print("[RYEENZYXNZ] Safe Mode:", v)
    end,
})

-- ═══════════════════════════════════════════════════════
-- TAB GROUP
-- ═══════════════════════════════════════════════════════
local TabGroup = Window:TabGroup()

-- ═══════════════════════════════════════════════════════
-- TAB 1 — HOME
-- ═══════════════════════════════════════════════════════
local HomeTab = TabGroup:Tab({ Name = "Home", Icon = "home" })
local Home    = HomeTab:Section({ Side = "Left" })

Home:Header({ Name = "Dashboard" })

Home:Paragraph({
    Name    = "Welcome to RYEENZYXNZ V3",
    Content = "A premium Liquid Glass UI library with MacLib-compatible API. "
           .. "Auto-scales across PC, laptop, Android, and iOS.",
})

Home:Label({ Name = "Walkspeed is currently: 16" })
Home:SubLabel({ Name = "Last updated: just now" })

Home:Divider()
Home:Spacer({ Size = 4 })

Home:Header({ Name = "Toggles" })

local AutoFarmToggle = Home:Toggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(v)
        print("[RYEENZYXNZ] Auto Farm:", v)
        Window:Notify({
            Title       = "Auto Farm",
            Description = (v and "Enabled" or "Disabled") .. " Auto Farm",
            Lifetime    = 3,
        })
    end,
}, "AutoFarm")

local GodModeToggle = Home:Toggle({
    Name     = "God Mode",
    Default  = false,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = v and math.huge or 100
                hum.Health    = v and math.huge or 100
            end
        end
    end,
}, "GodMode")

local InfJumpToggle = Home:Toggle({
    Name     = "Infinite Jump",
    Default  = false,
    Callback = function(v)
        _G.InfiniteJump = v
    end,
}, "InfJump")

Home:Spacer({ Size = 4 })
Home:Header({ Name = "Movement" })

local SpeedSlider = Home:Slider({
    Name         = "Walk Speed",
    Default      = 16,
    Minimum      = 0,
    Maximum      = 500,
    DisplayMethod = "Value",
    Precision    = 0,
    Callback     = function(v)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end,
    onInputComplete = function(v)
        print("[RYEENZYXNZ] Speed set to:", v)
    end,
}, "WalkSpeed")

local JumpSlider = Home:Slider({
    Name          = "Jump Power",
    Default       = 50,
    Minimum       = 0,
    Maximum       = 500,
    DisplayMethod = "Value",
    Precision     = 0,
    Callback      = function(v)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end,
}, "JumpPower")

local FOVSlider = Home:Slider({
    Name          = "Field of View",
    Default       = 70,
    Minimum       = 10,
    Maximum       = 120,
    DisplayMethod = "Degrees",
    Precision     = 0,
    Callback      = function(v)
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = v end
    end,
}, "FOV")

Home:Spacer({ Size = 4 })
Home:Header({ Name = "Actions" })

Home:Button({
    Name     = "Teleport to Spawn",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(0, 5, 0) end
        end
        Window:Notify({
            Title       = "Teleport",
            Description = "Teleported to spawn",
            Lifetime    = 2,
        })
    end,
})

Home:Button({
    Name     = "Reset Character",
    Callback = function()
        local hum = game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end,
})

Home:Button({
    Name     = "Show Dialog",
    Callback = function()
        Window:Dialog({
            Title       = "Confirmation",
            Description = "Are you sure you want to reset everything to default?",
            Buttons     = {
                {
                    Text     = "Confirm",
                    Accent   = true,
                    Callback = function()
                        AutoFarmToggle:UpdateState(false)
                        GodModeToggle:UpdateState(false)
                        SpeedSlider:UpdateValue(16)
                        JumpSlider:UpdateValue(50)
                        print("[RYEENZYXNZ] Reset to defaults.")
                    end,
                },
                {
                    Text = "Cancel",
                    Callback = function()
                        print("[RYEENZYXNZ] Cancelled.")
                    end,
                },
            },
        })
    end,
})

-- ═══════════════════════════════════════════════════════
-- TAB 2 — COMBAT
-- ═══════════════════════════════════════════════════════
local CombatTab = TabGroup:Tab({ Name = "Combat", Icon = "combat" })
local Combat    = CombatTab:Section({ Side = "Left" })

Combat:Header({ Name = "Aim Assist" })

local AimbotToggle = Combat:Toggle({
    Name     = "Aimbot",
    Default  = false,
    Callback = function(v)
        print("[RYEENZYXNZ] Aimbot:", v)
    end,
}, "Aimbot")

local SilentAimToggle = Combat:Toggle({
    Name     = "Silent Aim",
    Default  = false,
    Callback = function(v)
        print("[RYEENZYXNZ] Silent Aim:", v)
    end,
}, "SilentAim")

local FOVCircleToggle = Combat:Toggle({
    Name     = "FOV Circle",
    Default  = false,
    Callback = function(v)
        print("[RYEENZYXNZ] FOV Circle:", v)
    end,
}, "FOVCircle")

Combat:Spacer({ Size = 4 })

local AimbotFOVSlider = Combat:Slider({
    Name          = "Aimbot FOV",
    Default       = 100,
    Minimum       = 10,
    Maximum       = 500,
    DisplayMethod = "Value",
    Precision     = 0,
    Callback      = function(v)
        print("[RYEENZYXNZ] Aimbot FOV:", v)
    end,
}, "AimbotFOV")

local SmoothSlider = Combat:Slider({
    Name          = "Smooth",
    Default       = 5,
    Minimum       = 1,
    Maximum       = 100,
    DisplayMethod = "Percent",
    Precision     = 0,
    Callback      = function(v)
        print("[RYEENZYXNZ] Smooth:", v)
    end,
}, "AimbotSmooth")

Combat:Spacer({ Size = 4 })
Combat:Header({ Name = "ESP" })

local ESPToggle = Combat:Toggle({
    Name     = "ESP",
    Default  = true,
    Callback = function(v)
        print("[RYEENZYXNZ] ESP:", v)
    end,
}, "ESP")

local ESPColor = Combat:Colorpicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(255, 80, 80),
    Alpha    = 0,
    Callback = function(color, alpha)
        local r = math.round(color.R * 255)
        local g = math.round(color.G * 255)
        local b = math.round(color.B * 255)
        print(string.format("[RYEENZYXNZ] ESP Color: RGB(%d, %d, %d) A:%.2f", r, g, b, alpha))
    end,
}, "ESPColor")

local TracerColor = Combat:Colorpicker({
    Name     = "Tracer Color",
    Default  = Color3.fromRGB(80, 255, 140),
    Alpha    = 0,
    Callback = function(color, alpha)
        print("[RYEENZYXNZ] Tracer Color changed")
    end,
}, "TracerColor")

Combat:Spacer({ Size = 4 })
Combat:Header({ Name = "Targeting" })

local TargetDropdown = Combat:Dropdown({
    Name     = "Target Part",
    Options  = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default  = 1,  -- "Head"
    Search   = false,
    Multi    = false,
    Required = true,
    Callback = function(v)
        print("[RYEENZYXNZ] Target Part:", v)
    end,
}, "TargetPart")

local TeamCheck = Combat:Toggle({
    Name     = "Team Check",
    Default  = true,
    Callback = function(v)
        print("[RYEENZYXNZ] Team Check:", v)
    end,
}, "TeamCheck")

local WeaponDropdown = Combat:Dropdown({
    Name     = "Allowed Weapons",
    Options  = { "AK-47", "M4A1", "Desert Eagle", "AWP", "MP5", "SPAS-12", "All" },
    Default  = { "All" },
    Search   = true,
    Multi    = true,
    Required = false,
    Callback = function(v)
        local selected = {}
        for name, state in pairs(v) do
            if state then table.insert(selected, name) end
        end
        print("[RYEENZYXNZ] Weapons:", table.concat(selected, ", "))
    end,
}, "AllowedWeapons")

-- ═══════════════════════════════════════════════════════
-- TAB 3 — SETTINGS
-- ═══════════════════════════════════════════════════════
local SettingsTab = TabGroup:Tab({ Name = "Settings", Icon = "settings" })
local Settings    = SettingsTab:Section({ Side = "Left" })

Settings:Header({ Name = "Player" })

local TargetInput = Settings:Input({
    Name        = "Target Player",
    Placeholder = "Enter player name...",
    Callback    = function(v, enterPressed)
        print("[RYEENZYXNZ] Target:", v, "| Enter:", enterPressed)
    end,
}, "TargetPlayer")

Settings:Spacer({ Size = 4 })
Settings:Header({ Name = "Keybinds" })

local ToggleKeybind = Settings:Keybind({
    Name     = "Toggle Menu",
    Default  = Enum.KeyCode.RightShift,
    Blacklist = { Enum.KeyCode.Return, Enum.KeyCode.Escape },
    Callback  = function(key)
        print("[RYEENZYXNZ] Triggered:", key.Name)
    end,
    onBinded  = function(key)
        Window:SetKeybind(key)
        Window:Notify({
            Title       = "Keybind Changed",
            Description = "Menu toggle set to: " .. key.Name,
            Lifetime    = 3,
        })
    end,
}, "ToggleKey")

local AimbotKeyBind = Settings:Keybind({
    Name    = "Aimbot Hold Key",
    Default = Enum.KeyCode.Q,
    Callback = function(key)
        print("[RYEENZYXNZ] Aimbot held:", key.Name)
    end,
    onBinded = function(key)
        print("[RYEENZYXNZ] Aimbot key set:", key.Name)
    end,
}, "AimbotKey")

Settings:Spacer({ Size = 4 })
Settings:Header({ Name = "Visual" })

local AccentPicker = Settings:Colorpicker({
    Name     = "Accent Color",
    Default  = Color3.fromRGB(120, 100, 255),
    Alpha    = 0,
    Callback = function(color, alpha)
        print("[RYEENZYXNZ] Accent changed")
    end,
}, "AccentColor")

local BgPicker = Settings:Colorpicker({
    Name     = "Background Tint",
    Default  = Color3.fromRGB(9, 9, 14),
    Alpha    = 0,
    Callback = function(color, alpha)
        print("[RYEENZYXNZ] BG tint changed")
    end,
}, "BgColor")

Settings:Spacer({ Size = 4 })
Settings:Header({ Name = "Notifications" })

local NotifToggle = Settings:Toggle({
    Name     = "Show Notifications",
    Default  = true,
    Callback = function(v)
        Window:SetNotificationsState(v)
    end,
}, "ShowNotif")

Settings:Spacer({ Size = 4 })
Settings:Header({ Name = "UI Scale (Manual)" })

local ScaleSlider = Settings:Slider({
    Name          = "UI Scale",
    Default       = 100,
    Minimum       = 55,
    Maximum       = 140,
    DisplayMethod = "Percent",
    Precision     = 0,
    Callback      = function(v)
        Window:SetScale(v / 100)
    end,
}, "UIScale")

-- ═══════════════════════════════════════════════════════
-- TAB 4 — CONFIG
-- ═══════════════════════════════════════════════════════
local ConfigTab = TabGroup:Tab({ Name = "Config", Icon = "config" })
local Config    = ConfigTab:Section({ Side = "Left" })

Config:Header({ Name = "Configuration" })

Config:Paragraph({
    Name    = "Config System",
    Content = "Saves/loads all flagged component values. Stored as JSON in the "
           .. "executor workspace under 'RYEENZYXNZ_V3/'. Supports Toggle, Slider, "
           .. "Dropdown, MultiDropdown, Input, Keybind, and Colorpicker.",
})

Config:Button({
    Name     = "Save Config",
    Callback = function()
        Window:SaveConfig("default")
        Window:Notify({
            Title       = "Saved",
            Description = "Config saved to RYEENZYXNZ_V3/default.json",
            Lifetime    = 3,
            Style       = "Confirm",
        })
    end,
})

Config:Button({
    Name     = "Load Config",
    Callback = function()
        Window:LoadConfig("default")
        Window:Notify({
            Title       = "Loaded",
            Description = "Config loaded from RYEENZYXNZ_V3/default.json",
            Lifetime    = 3,
            Style       = "Confirm",
        })
    end,
})

Config:Button({
    Name     = "Delete Config",
    Callback = function()
        Window:Dialog({
            Title       = "Delete Config",
            Description = "Delete 'default.json'? This cannot be undone.",
            Buttons = {
                {
                    Text     = "Delete",
                    Accent   = true,
                    Callback = function()
                        -- RUI:SetFolder already set above; call file delete directly
                        if isfile and delfile then
                            local p = "RYEENZYXNZ_V3/default.json"
                            if isfile(p) then delfile(p) end
                        end
                        Window:Notify({
                            Title       = "Deleted",
                            Description = "Config file removed",
                            Lifetime    = 3,
                            Style       = "Cancel",
                        })
                    end,
                },
                { Text = "Cancel" },
            },
        })
    end,
})

Config:Divider()

Config:Button({
    Name     = "List Saved Configs",
    Callback = function()
        local configs = Window:RefreshConfigList()
        if #configs == 0 then
            Window:Notify({
                Title       = "Config List",
                Description = "No configs saved yet.",
                Lifetime    = 3,
            })
        else
            Window:Notify({
                Title       = "Config List",
                Description = table.concat(configs, "\n"),
                Lifetime    = 5,
            })
        end
    end,
})

Config:Spacer({ Size = 4 })
Config:Header({ Name = "Flags Debug" })

Config:Button({
    Name     = "Print All Flags",
    Callback = function()
        print("[RYEENZYXNZ] ═══ FLAGS ═══")
        for flag, value in pairs(RUI.Flags) do
            local display = type(value) == "table"
                and "{ "..table.concat(
                    (function() local t={} for k,v in pairs(value) do if v then table.insert(t,k) end end return t end)(),
                    ", "
                ).." }"
                or tostring(value)
            print(string.format("  %-22s = %s", flag, display))
        end
        print("[RYEENZYXNZ] ═══════════")
    end,
})

-- ═══════════════════════════════════════════════════════
-- TAB 5 — INFO
-- ═══════════════════════════════════════════════════════
local InfoTab = TabGroup:Tab({ Name = "Info", Icon = "info" })
local Info    = InfoTab:Section({ Side = "Left" })

Info:Header({ Name = "Library Info" })

Info:Paragraph({
    Name    = "RYEENZYXNZ UI V3",
    Content = "Version 3.0.0 — MacLib Edition\n"
           .. "Custom implementation, not derived from MacLib source code.\n"
           .. "API design inspired by MacLib documentation.",
})

Info:Paragraph({
    Name    = "Auto Scale",
    Content = "The UI automatically scales to fit any screen resolution. "
           .. "It uses UIScale tied to the viewport size, clamped between "
           .. "55%% and 140%% of the base 868×650 design size.",
})

Info:Paragraph({
    Name    = "Mobile Support",
    Content = "Touch drag, touch sliders, touch dropdowns. "
           .. "All tap targets are minimum 40px tall. "
           .. "Keybinds require a physical keyboard.",
})

Info:Divider()
Info:Header({ Name = "Supported Components" })

local components = {
    "Window  :  Title, Subtitle, Size, DragStyle, Keybind, ShowUserInfo, AcrylicBlur",
    "TabGroup → Tab → Section",
    "Section  :  Toggle, Slider, Dropdown (Single + Multi + Search), Input",
    "Section  :  Keybind, Colorpicker (RGBA), Button, Header, Paragraph",
    "Section  :  Label, SubLabel, Divider, Spacer",
    "Window   :  Notify, Dialog, GlobalSetting",
    "Config   :  SaveConfig, LoadConfig, RefreshConfigList, LoadAutoLoadConfig",
    "Controls :  SetState, GetState, SetScale, SetSize, UpdateTitle, Unload",
}
for _, line in ipairs(components) do
    Info:Label({ Name = "• " .. line })
    Info:Spacer({ Size = 2 })
end

Info:Divider()
Info:SubLabel({
    Name = "Press RightShift to toggle the window at any time.",
})

-- ═══════════════════════════════════════════════════════
-- INFINITE JUMP (example of global connection)
-- ═══════════════════════════════════════════════════════
local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")

UIS.JumpRequest:Connect(function()
    if not _G.InfiniteJump then return end
    local char = Players.LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- ═══════════════════════════════════════════════════════
-- PROGRAMMATIC API DEMO (runs 1 second after load)
-- ═══════════════════════════════════════════════════════
task.spawn(function()
    task.wait(1)

    -- programmatic setters
    SpeedSlider:UpdateValue(80)
    AimbotFOVSlider:UpdateValue(150)
    TargetDropdown:UpdateSelection("Head")

    task.wait(.3)

    Window:Notify({
        Title       = "RYEENZYXNZ UI V3",
        Description = "Loaded successfully! Press RightShift to toggle.",
        Lifetime    = 5,
    })
end)
