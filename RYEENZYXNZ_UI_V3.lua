--[[
    ██████╗ ██╗   ██╗███████╗███████╗███╗   ██╗███████╗██╗   ██╗██╗  ██╗███╗   ██╗███████╗
    ██╔══██╗╚██╗ ██╔╝██╔════╝██╔════╝████╗  ██║╚══███╔╝╚██╗ ██╔╝╚██╗██╔╝████╗  ██║╚══███╔╝
    ██████╔╝ ╚████╔╝ █████╗  █████╗  ██╔██╗ ██║  ███╔╝  ╚████╔╝  ╚███╔╝ ██╔██╗ ██║  ███╔╝
    ██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══╝  ██║╚██╗██║ ███╔╝   ╚██╔╝   ██╔██╗ ██║╚██╗██║ ███╔╝
    ██║  ██║   ██║   ███████╗███████╗██║ ╚████║███████╗   ██║   ██╔╝ ██╗██║ ╚████║███████╗
    ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝

    RYEENZYXNZ UI V3
    Version: 3.0.0
    Design: Premium Liquid Glass / Glassmorphism
    Author: RYEENZYXNZ
    License: MIT

    Custom implementation — not derived from WindUI source code.
    All visuals, animations, and component logic written from scratch.
]]

local RYEENZYXNZ_UI = {}
RYEENZYXNZ_UI.__index = RYEENZYXNZ_UI
RYEENZYXNZ_UI.Version = "3.1.0"
RYEENZYXNZ_UI.Name = "RYEENZYXNZ UI"

-- ─────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer  = Players.LocalPlayer
local Mouse        = LocalPlayer:GetMouse()
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────
-- INTERNAL STATE
-- ─────────────────────────────────────────────
local _LucideModule    = nil
local _CustomIcons     = {}
local _ActiveWindows   = {}

-- ─────────────────────────────────────────────
-- DEFAULT THEME  (Liquid Glass Dark)
-- ─────────────────────────────────────────────
local DefaultTheme = {
    Background         = Color3.fromRGB(8,   8,  12),
    Surface            = Color3.fromRGB(16,  16,  22),
    SurfaceElevated    = Color3.fromRGB(22,  22,  32),
    SurfaceGlass       = Color3.fromRGB(18,  18,  26),
    Text               = Color3.fromRGB(240, 240, 255),
    TextMuted          = Color3.fromRGB(140, 140, 165),
    TextDim            = Color3.fromRGB(80,  80, 110),
    Accent             = Color3.fromRGB(124, 104, 255),
    AccentSoft         = Color3.fromRGB(80,  64, 180),
    AccentGlow         = Color3.fromRGB(100, 80, 220),
    Border             = Color3.fromRGB(40,  40,  60),
    BorderBright       = Color3.fromRGB(60,  60,  90),
    Success            = Color3.fromRGB(80,  220, 140),
    Warning            = Color3.fromRGB(255, 190,  60),
    Error              = Color3.fromRGB(255,  80,  80),
    SliderFill         = Color3.fromRGB(124, 104, 255),
    ToggleOn           = Color3.fromRGB(124, 104, 255),
    ToggleOff          = Color3.fromRGB(45,  45,  65),
    ScrollBar          = Color3.fromRGB(60,  60,  90),
    Overlay            = Color3.fromRGB(0,    0,   0),
    NotificationBg     = Color3.fromRGB(20,  20,  30),
}

local CurrentTheme = table.clone(DefaultTheme)

-- ─────────────────────────────────────────────
-- TWEEN HELPERS
-- ─────────────────────────────────────────────
local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function TweenFast(obj, props)
    return Tween(obj, props, 0.15)
end

local function Spring(obj, props, duration)
    -- Roblox TweenService has no Enum.EasingStyle.Spring.
    -- Use Back for a spring-like overshoot without invalid enum access.
    local info = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ─────────────────────────────────────────────
-- UI CREATION HELPERS
-- ─────────────────────────────────────────────
local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if parent then obj.Parent = parent end
    return obj
end

local function MakeCorner(radius, parent)
    return Make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function MakePadding(t, b, l, r, parent)
    return Make("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, parent)
end

local function MakeStroke(thickness, color, transparency, parent)
    return Make("UIStroke", {
        Thickness    = thickness    or 1,
        Color        = color        or CurrentTheme.Border,
        Transparency = transparency or 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function MakeListLayout(direction, padding, halign, valign, parent)
    return Make("UIListLayout", {
        FillDirection       = direction or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, padding or 6),
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = valign or Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
    }, parent)
end

local function AutoSize(frame, axis)
    frame.AutomaticSize = axis or Enum.AutomaticSize.Y
end

local function SizeToContent(scroll)
    local list = scroll:FindFirstChildOfClass("UIListLayout")
    if list then
        local function update()
            scroll.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 16)
        end
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
        update()
    end
end

-- ─────────────────────────────────────────────
-- ICON RESOLVER
-- ─────────────────────────────────────────────
local function ResolveIcon(iconName)
    if not iconName or iconName == "" then return nil end

    -- rbxassetid:// passthrough
    if type(iconName) == "string" and iconName:match("^rbxassetid://") then
        return iconName
    end

    -- Custom icon table
    if _CustomIcons[iconName] then
        return _CustomIcons[iconName]
    end

    -- Lucide module
    if _LucideModule and type(_LucideModule) == "table" then
        local ok, result = pcall(function()
            return _LucideModule:GetAsset(iconName, 24)
        end)
        if ok and result then
            return result
        end
        -- Fallback: try index directly
        if _LucideModule[iconName] then
            return _LucideModule[iconName]
        end
    end

    return nil
end

local function ApplyIcon(imageLabel, iconName, size)
    local resolved = ResolveIcon(iconName)
    if resolved then
        imageLabel.Image = resolved
        imageLabel.Visible = true
    else
        imageLabel.Visible = false
    end
    if size then
        imageLabel.Size = UDim2.fromOffset(size, size)
    end
end

-- ─────────────────────────────────────────────
-- DRAG LOGIC
-- ─────────────────────────────────────────────
local function MakeDraggable(handle, target)
    local dragging = false
    local dragStart, startPos
    local connections = {}

    local function onInputBegan(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
        end
    end

    local function onInputChanged(input)
        local t = input.UserInputType
        if dragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            target.Position = newPos
        end
    end

    local function onInputEnded(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
        end
    end

    table.insert(connections, handle.InputBegan:Connect(onInputBegan))
    table.insert(connections, UserInputService.InputChanged:Connect(onInputChanged))
    table.insert(connections, UserInputService.InputEnded:Connect(onInputEnded))
    return connections
end

-- ─────────────────────────────────────────────
-- CONFIG UTILITIES
-- ─────────────────────────────────────────────
local function ConfigEncode(value)
    local t = typeof(value)
    if t == "Color3" then
        return { __type = "Color3", R = value.R, G = value.G, B = value.B }
    elseif t == "EnumItem" then
        return { __type = "EnumItem", EnumType = tostring(value.EnumType), Name = value.Name }
    elseif t == "UDim2" then
        return {
            __type = "UDim2",
            XS = value.X.Scale, XO = value.X.Offset,
            YS = value.Y.Scale, YO = value.Y.Offset
        }
    elseif t == "BrickColor" then
        return { __type = "BrickColor", Number = value.Number }
    elseif t == "Vector2" then
        return { __type = "Vector2", X = value.X, Y = value.Y }
    elseif t == "Vector3" then
        return { __type = "Vector3", X = value.X, Y = value.Y, Z = value.Z }
    elseif type(value) == "table" then
        local out = {}
        for k, v in pairs(value) do
            local safeKey = (type(k) == "string" or type(k) == "number") and k or tostring(k)
            out[safeKey] = ConfigEncode(v)
        end
        return out
    end
    return value
end

local function ConfigDecode(value)
    if type(value) ~= "table" then
        return value
    end
    if value.__type == "Color3" then
        return Color3.new(
            tonumber(value.R) or 0,
            tonumber(value.G) or 0,
            tonumber(value.B) or 0
        )
    elseif value.__type == "EnumItem" then
        local enumName = tostring(value.EnumType or "")
        local enumType = enumName:match("Enum%.(.+)")
        if enumType and Enum[enumType] then
            local ok, result = pcall(function()
                return Enum[enumType][value.Name]
            end)
            if ok and result then return result end
        end
        return value.Name
    elseif value.__type == "UDim2" then
        return UDim2.new(
            tonumber(value.XS) or 0, tonumber(value.XO) or 0,
            tonumber(value.YS) or 0, tonumber(value.YO) or 0
        )
    elseif value.__type == "BrickColor" then
        local ok, result = pcall(BrickColor.new, value.Number)
        return ok and result or BrickColor.new("Medium stone grey")
    elseif value.__type == "Vector2" then
        return Vector2.new(tonumber(value.X) or 0, tonumber(value.Y) or 0)
    elseif value.__type == "Vector3" then
        return Vector3.new(tonumber(value.X) or 0, tonumber(value.Y) or 0, tonumber(value.Z) or 0)
    end
    local out = {}
    for k, v in pairs(value) do
        out[k] = ConfigDecode(v)
    end
    return out
end

local function SafeWriteFile(path, content)
    if writefile then
        local ok, err = pcall(writefile, path, content)
        if not ok then
            warn("[RYEENZYXNZ UI] writefile failed:", err)
        end
        return ok
    end
    return false
end

local function SafeReadFile(path)
    if isfile and readfile then
        if not isfile(path) then return nil end
        local ok, content = pcall(readfile, path)
        if ok then return content end
    end
    return nil
end

local function SafeDeleteFile(path)
    if isfile and delfile then
        if isfile(path) then
            pcall(delfile, path)
        end
    end
end

local function EnsureFolder(folder)
    if isfolder and makefolder then
        if not isfolder(folder) then
            pcall(makefolder, folder)
        end
    end
end

-- ─────────────────────────────────────────────
-- NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────
local NotificationContainer = nil
local NotificationQueue     = {}

local function EnsureNotificationContainer()
    if NotificationContainer and NotificationContainer.Parent then return end

    local gui = Make("ScreenGui", {
        Name           = "RYEENZYXNZ_Notifications",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
    })

    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then gui.Parent = PlayerGui end

    NotificationContainer = Make("Frame", {
        Name            = "Container",
        Size            = UDim2.new(0, 320, 1, 0),
        Position        = UDim2.new(1, -330, 0, 0),
        BackgroundTransparency = 1,
        AnchorPoint     = Vector2.new(0, 0),
    }, gui)

    MakeListLayout(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom, NotificationContainer)
    Make("UIPadding", {
        PaddingBottom = UDim.new(0, 16),
        PaddingRight  = UDim.new(0, 0),
        PaddingTop    = UDim.new(0, 16),
    }, NotificationContainer)
end

local function ShowNotification(opts)
    EnsureNotificationContainer()
    opts = opts or {}

    local title    = opts.Title    or "RYEENZYXNZ UI"
    local content  = opts.Content  or ""
    local duration = opts.Duration or 4
    local icon     = opts.Icon

    local card = Make("Frame", {
        Name            = "Notification",
        Size            = UDim2.new(1, 0, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundColor3 = CurrentTheme.NotificationBg,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
    }, NotificationContainer)
    MakeCorner(12, card)
    MakeStroke(1, CurrentTheme.Accent, 0.5, card)

    -- glow line top
    Make("Frame", {
        Size  = UDim2.new(1, 0, 0, 2),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, card)

    local inner = Make("Frame", {
        Size            = UDim2.new(1, 0, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, card)
    MakePadding(12, 12, 14, 14, inner)
    MakeListLayout(Enum.FillDirection.Vertical, 4, nil, nil, inner)

    -- title row
    local titleRow = Make("Frame", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        AutomaticSize   = Enum.AutomaticSize.Y,
    }, inner)
    MakeListLayout(Enum.FillDirection.Horizontal, 6, nil, Enum.VerticalAlignment.Center, titleRow)

    if icon then
        local iconImg = Make("ImageLabel", {
            Size   = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            ImageColor3 = CurrentTheme.Accent,
        }, titleRow)
        ApplyIcon(iconImg, icon, 16)
    end

    Make("TextLabel", {
        Size            = UDim2.new(1, 0, 0, 20),
        AutomaticSize   = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = CurrentTheme.Text,
        TextSize        = 13,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
    }, titleRow)

    Make("TextLabel", {
        Size            = UDim2.new(1, 0, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text            = content,
        TextColor3      = CurrentTheme.TextMuted,
        TextSize        = 12,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextWrapped     = true,
    }, inner)

    -- progress bar
    local barBg = Make("Frame", {
        Size            = UDim2.new(1, -28, 0, 3),
        Position        = UDim2.new(0, 14, 1, -7),
        BackgroundColor3 = CurrentTheme.Border,
        BackgroundTransparency = 0.3,
    }, card)
    MakeCorner(4, barBg)

    local barFill = Make("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Accent,
    }, barBg)
    MakeCorner(4, barFill)

    -- Animate in
    card.Position = UDim2.new(1, 20, 0, 0)
    Spring(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.5)

    -- Progress drain
    Tween(barFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if card and card.Parent then
            Tween(card, { Position = UDim2.new(1, 20, 0, 0) }, 0.3)
            task.delay(0.35, function()
                if card and card.Parent then
                    card:Destroy()
                end
            end)
        end
    end)
end

-- ─────────────────────────────────────────────
-- SEARCH SYSTEM
-- ─────────────────────────────────────────────
-- Each component registers itself with the search index.
-- Search filters visible state without destroying component state.

-- ─────────────────────────────────────────────
-- WINDOW FACTORY
-- ─────────────────────────────────────────────
function RYEENZYXNZ_UI:CreateWindow(opts)
    opts = opts or {}

    local title      = opts.Title                        or "RYEENZYXNZ"
    local subtitle   = opts.Subtitle                     or "Premium Liquid Glass"
    local logo       = opts.Logo
    local bgImage    = opts.BackgroundImage
    local bgTrans    = opts.BackgroundImageTransparency   or 0.5
    local bgOverlay  = opts.BackgroundOverlayTransparency or 0.3
    local winSize    = opts.Size                          or UDim2.fromOffset(760, 500)
    local configDir  = opts.ConfigFolder                  or "RYEENZYXNZ_UI"
    local configName = opts.ConfigName                    or "default"
    local toggleKey  = opts.ToggleKey                    or Enum.KeyCode.RightShift

    if opts.LucideModule then
        _LucideModule = opts.LucideModule
    end

    local Window          = {}
    Window.Flags          = {}
    Window._components    = {}
    Window._connections   = {}
    Window._tabs          = {}
    Window._activeTab     = nil
    Window._searchIndex   = {}  -- { { frame, title, tab } }
    Window._open          = true
    Window._destroyed     = false
    Window._notifications = true
    Window._userInfo      = true
    Window._minimized     = false
    Window.Settings       = {
        Title = title,
        Subtitle = subtitle,
        ToggleKey = toggleKey,
        Size = winSize,
    }

    -- ── ScreenGui ──────────────────────────────
    local ScreenGui = Make("ScreenGui", {
        Name           = "RYEENZYXNZ_UI_V3",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 100,
    })

    local guiOk = pcall(function() ScreenGui.Parent = CoreGui end)
    if not guiOk then ScreenGui.Parent = PlayerGui end

    -- ── Main Frame ─────────────────────────────
    local MainFrame = Make("Frame", {
        Name            = "MainFrame",
        Size            = winSize,
        Position        = UDim2.fromScale(0.5, 0.5),
        AnchorPoint     = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Background,
        ClipsDescendants = true,
    }, ScreenGui)
    MakeCorner(16, MainFrame)
    MakeStroke(1, CurrentTheme.BorderBright, 0.5, MainFrame)

    -- Background image
    if bgImage then
        local bgLabel = Make("ImageLabel", {
            Name            = "BackgroundImage",
            Size            = UDim2.fromScale(1, 1),
            Position        = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            Image           = bgImage,
            ImageTransparency = bgTrans,
            ScaleType       = Enum.ScaleType.Crop,
            ZIndex          = 0,
        }, MainFrame)

        -- Dark overlay
        Make("Frame", {
            Name            = "Overlay",
            Size            = UDim2.fromScale(1, 1),
            BackgroundColor3 = CurrentTheme.Overlay,
            BackgroundTransparency = bgOverlay,
            ZIndex          = 1,
            BorderSizePixel = 0,
        }, MainFrame)
    end

    -- Subtle top glow line
    Make("Frame", {
        Size             = UDim2.new(0.6, 0, 0, 1),
        Position         = UDim2.fromScale(0.2, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel  = 0,
        ZIndex           = 10,
    }, MainFrame)

    -- ── Header ─────────────────────────────────
    local Header = Make("Frame", {
        Name            = "Header",
        Size            = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.3,
        ZIndex          = 10,
    }, MainFrame)
    Make("Frame", {
        Size            = UDim2.new(1, 0, 0, 1),
        Position        = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = CurrentTheme.Border,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex          = 11,
    }, Header)

    local HeaderInner = Make("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex          = 12,
    }, Header)
    MakePadding(0, 0, 14, 14, HeaderInner)
    Make("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 10),
    }, HeaderInner)

    -- Logo
    local LogoImg = Make("ImageLabel", {
        Name            = "Logo",
        Size            = UDim2.fromOffset(32, 32),
        BackgroundColor3 = CurrentTheme.SurfaceElevated,
        BackgroundTransparency = 0.5,
        Image           = logo or "",
        Visible         = logo ~= nil,
        ZIndex          = 13,
    }, HeaderInner)
    MakeCorner(8, LogoImg)

    -- Title block
    local TitleBlock = Make("Frame", {
        Name            = "TitleBlock",
        Size            = UDim2.new(0, 200, 1, 0),
        AutomaticSize   = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ZIndex          = 13,
    }, HeaderInner)
    MakeListLayout(Enum.FillDirection.Vertical, 0, nil, Enum.VerticalAlignment.Center, TitleBlock)

    Make("TextLabel", {
        Name            = "Title",
        Size            = UDim2.new(0, 0, 0, 20),
        AutomaticSize   = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = CurrentTheme.Text,
        TextSize        = 16,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 13,
    }, TitleBlock)

    if subtitle ~= "" then
        Make("TextLabel", {
            Name            = "Subtitle",
            Size            = UDim2.new(0, 0, 0, 14),
            AutomaticSize   = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text            = subtitle,
            TextColor3      = CurrentTheme.TextMuted,
            TextSize        = 11,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 13,
        }, TitleBlock)
    end

    -- Spacer
    Make("Frame", {
        Name            = "Spacer",
        Size            = UDim2.new(1, -400, 1, 0),
        BackgroundTransparency = 1,
        ZIndex          = 13,
    }, HeaderInner)

    -- Search Box
    local SearchBox = Make("Frame", {
        Name            = "SearchBox",
        Size            = UDim2.fromOffset(180, 32),
        BackgroundColor3 = CurrentTheme.SurfaceElevated,
        BackgroundTransparency = 0.3,
        ZIndex          = 13,
    }, HeaderInner)
    MakeCorner(8, SearchBox)
    MakeStroke(1, CurrentTheme.Border, 0.5, SearchBox)

    local SearchInner = Make("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex          = 14,
    }, SearchBox)
    MakePadding(0, 0, 8, 8, SearchInner)
    Make("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 6),
    }, SearchInner)

    local SearchIcon = Make("ImageLabel", {
        Size            = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Image           = "rbxassetid://3926305904",
        ImageColor3     = CurrentTheme.TextMuted,
        ZIndex          = 15,
    }, SearchInner)

    local SearchInput = Make("TextBox", {
        Name            = "SearchInput",
        Size            = UDim2.new(1, -22, 1, 0),
        BackgroundTransparency = 1,
        Text            = "",
        PlaceholderText = "Search components...",
        PlaceholderColor3 = CurrentTheme.TextDim,
        TextColor3      = CurrentTheme.Text,
        TextSize        = 12,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex          = 15,
    }, SearchInner)

    -- Header right buttons
    local BtnFrame = Make("Frame", {
        Name            = "HeaderButtons",
        Size            = UDim2.fromOffset(60, 32),
        BackgroundTransparency = 1,
        ZIndex          = 13,
    }, HeaderInner)
    Make("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 6),
    }, BtnFrame)

    local function MakeHeaderBtn(icon, color)
        local btn = Make("TextButton", {
            Size            = UDim2.fromOffset(28, 28),
            BackgroundColor3 = CurrentTheme.SurfaceElevated,
            BackgroundTransparency = 0.3,
            Text            = "",
            ZIndex          = 14,
        }, BtnFrame)
        MakeCorner(7, btn)

        local img = Make("ImageLabel", {
            Size            = UDim2.fromOffset(14, 14),
            Position        = UDim2.fromOffset(7, 7),
            BackgroundTransparency = 1,
            Image           = icon,
            ImageColor3     = color or CurrentTheme.TextMuted,
            ZIndex          = 15,
        }, btn)

        btn.MouseEnter:Connect(function()
            TweenFast(btn, { BackgroundTransparency = 0.1 })
        end)
        btn.MouseLeave:Connect(function()
            TweenFast(btn, { BackgroundTransparency = 0.3 })
        end)

        return btn, img
    end

    -- Minimize button
    local MinBtn = MakeHeaderBtn("rbxassetid://3926305904", CurrentTheme.TextMuted)
    local CloseBtn = MakeHeaderBtn("rbxassetid://3926305904", CurrentTheme.Error)

    -- ── Body ────────────────────────────────────
    local Body = Make("Frame", {
        Name            = "Body",
        Size            = UDim2.new(1, 0, 1, -52),
        Position        = UDim2.fromOffset(0, 52),
        BackgroundTransparency = 1,
        ZIndex          = 5,
    }, MainFrame)

    -- Sidebar
    local Sidebar = Make("ScrollingFrame", {
        Name            = "Sidebar",
        Size            = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize      = UDim2.fromOffset(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex          = 6,
    }, Body)

    Make("Frame", {
        Name            = "SidebarBorder",
        Size            = UDim2.new(0, 1, 1, 0),
        Position        = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = CurrentTheme.Border,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex          = 7,
    }, Sidebar)

    local SidebarList = Make("Frame", {
        Name            = "SidebarList",
        Size            = UDim2.new(1, 0, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex          = 7,
    }, Sidebar)
    MakePadding(12, 12, 10, 10, SidebarList)
    MakeListLayout(Enum.FillDirection.Vertical, 4, nil, nil, SidebarList)
    SizeToContent(Sidebar)

    -- Content area
    local ContentArea = Make("Frame", {
        Name            = "ContentArea",
        Size            = UDim2.new(1, -180, 1, 0),
        Position        = UDim2.fromOffset(180, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex          = 6,
    }, Body)

    -- Make header draggable
    for _, conn in ipairs(MakeDraggable(Header, MainFrame)) do table.insert(Window._connections, conn) end

    -- ── Minimize/Close logic ───────────────────
    local minimized = false

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Window._minimized = minimized
        if minimized then
            Tween(MainFrame, { Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 52) }, 0.3)
        else
            Tween(MainFrame, { Size = winSize }, 0.3)
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        if Window._destroyed then return end
        Tween(MainFrame, { Size = UDim2.fromOffset(0, 0), Position = UDim2.fromScale(0.5, 0.5) }, 0.3)
        task.delay(0.35, function()
            if not Window._destroyed then Window:Destroy() end
        end)
    end)

    -- Toggle key
    local toggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            Window:Toggle()
        end
    end)
    table.insert(Window._connections, toggleConn)

    -- ── SEARCH LOGIC ──────────────────────────
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower():gsub("^%s*(.-)%s*$", "%1")
        if query == "" then
            -- show all
            for _, entry in ipairs(Window._searchIndex) do
                if entry.frame and entry.frame.Parent then
                    entry.frame.Visible = true
                end
            end
        else
            for _, entry in ipairs(Window._searchIndex) do
                if entry.frame and entry.frame.Parent then
                    local match = entry.title:lower():find(query, 1, true) ~= nil
                    entry.frame.Visible = match
                end
            end
        end
    end)

    -- ── TAB SYSTEM ────────────────────────────
    function Window:CreateTab(tabOpts, icon)
        if type(tabOpts) == "string" then
            tabOpts = { Title = tabOpts, Icon = icon }
        else
            tabOpts = tabOpts or {}
        end
        local tabTitle = tabOpts.Title or tabOpts.Name or "Tab"
        local tabIcon  = tabOpts.Icon or tabOpts.Image

        -- Tab data
        local Tab = {}
        Tab._components = {}
        Tab._title      = tabTitle

        -- Sidebar button
        local TabBtn = Make("TextButton", {
            Name            = "TabBtn_" .. tabTitle,
            Size            = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = CurrentTheme.SurfaceElevated,
            BackgroundTransparency = 1,
            Text            = "",
            AutoButtonColor = false,
            ZIndex          = 8,
        }, SidebarList)
        MakeCorner(10, TabBtn)
        MakePadding(0, 0, 10, 10, TabBtn)

        local TabBtnInner = Make("Frame", {
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex          = 9,
        }, TabBtn)
        Make("UIListLayout", {
            FillDirection     = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding           = UDim.new(0, 8),
        }, TabBtnInner)

        local TabIconImg = Make("ImageLabel", {
            Size            = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            ImageColor3     = CurrentTheme.TextMuted,
            ZIndex          = 10,
        }, TabBtnInner)
        ApplyIcon(TabIconImg, tabIcon, 16)
        if not tabIcon then TabIconImg.Visible = false end

        local TabLabel = Make("TextLabel", {
            Size            = UDim2.new(1, 0, 1, 0),
            AutomaticSize   = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text            = tabTitle,
            TextColor3      = CurrentTheme.TextMuted,
            TextSize        = 13,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 10,
        }, TabBtnInner)

        -- Active indicator
        local ActiveBar = Make("Frame", {
            Name            = "ActiveBar",
            Size            = UDim2.new(0, 3, 0.6, 0),
            Position        = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = CurrentTheme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex          = 10,
        }, TabBtn)
        MakeCorner(4, ActiveBar)

        -- Scroll content
        local TabScroll = Make("ScrollingFrame", {
            Name            = "Content_" .. tabTitle,
            Size            = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.ScrollBar,
            CanvasSize      = UDim2.fromOffset(0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible         = false,
            ZIndex          = 7,
        }, ContentArea)

        local TabContent = Make("Frame", {
            Name            = "InnerContent",
            Size            = UDim2.new(1, 0, 0, 0),
            AutomaticSize   = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex          = 8,
        }, TabScroll)
        MakePadding(14, 14, 16, 16, TabContent)
        MakeListLayout(Enum.FillDirection.Vertical, 8, nil, nil, TabContent)
        SizeToContent(TabScroll)

        Tab._scroll  = TabScroll
        Tab._content = TabContent
        Tab._btn     = TabBtn

        local function Activate()
            -- Deactivate all tabs
            for _, t in ipairs(Window._tabs) do
                t._scroll.Visible = false
                TweenFast(t._btn, { BackgroundTransparency = 1 })
                if t._activeBar then
                    TweenFast(t._activeBar, { BackgroundTransparency = 1 })
                    TweenFast(t._iconImg, { ImageColor3 = CurrentTheme.TextMuted })
                    TweenFast(t._label, { TextColor3 = CurrentTheme.TextMuted })
                end
            end

            -- Activate this
            TabScroll.Visible = true
            TweenFast(TabBtn, { BackgroundTransparency = 0.7 })
            TweenFast(ActiveBar, { BackgroundTransparency = 0 })
            TweenFast(TabIconImg, { ImageColor3 = CurrentTheme.Accent })
            TweenFast(TabLabel, { TextColor3 = CurrentTheme.Text })
            Window._activeTab = Tab
        end

        Tab._activeBar = ActiveBar
        Tab._iconImg   = TabIconImg
        Tab._label     = TabLabel
        Tab.Activate   = Activate
        Tab.Select     = Activate
        Tab.Show       = Activate

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                TweenFast(TabBtn, { BackgroundTransparency = 0.85 })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                TweenFast(TabBtn, { BackgroundTransparency = 1 })
            end
        end)

        table.insert(Window._tabs, Tab)

        if #Window._tabs == 1 then
            Activate()
        end

        -- ── COMPONENT BUILDERS ─────────────────
        local function RegisterSearch(frame, componentTitle)
            table.insert(Window._searchIndex, {
                frame = frame,
                title = componentTitle or "",
                tab   = tabTitle,
            })
        end

        -- ── SECTION ───────────────────────────
        function Tab:CreateSection(sectionTitle)
            local container = Make("Frame", {
                Name            = "Section_" .. tostring(sectionTitle),
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
            }, TabContent)

            Make("TextLabel", {
                Size            = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text            = tostring(sectionTitle):upper(),
                TextColor3      = CurrentTheme.Accent,
                TextSize        = 10,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, container)

            Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = CurrentTheme.Border,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
            }, container)

            Make("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding       = UDim.new(0, 2),
            }, container)

            RegisterSearch(container, sectionTitle)
            return container
        end
        Tab.AddSection = Tab.CreateSection

        -- ── PARAGRAPH ─────────────────────────
        function Tab:CreateParagraph(pOpts)
            pOpts = pOpts or {}
            local card = Make("Frame", {
                Name            = "Paragraph",
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)
            MakePadding(12, 12, 14, 14, card)
            MakeListLayout(Enum.FillDirection.Vertical, 4, nil, nil, card)

            Make("TextLabel", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text            = pOpts.Title or "",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
            }, card)

            Make("TextLabel", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text            = pOpts.Content or "",
                TextColor3      = CurrentTheme.TextMuted,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
            }, card)

            RegisterSearch(card, pOpts.Title)
            return card
        end

        -- ── BUTTON ────────────────────────────
        function Tab:CreateButton(bOpts)
            bOpts = bOpts or {}
            local card = Make("TextButton", {
                Name            = "Button_" .. tostring(bOpts.Title),
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
                Text            = "",
                AutoButtonColor = false,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)

            local inner = Make("Frame", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, card)
            MakePadding(0, 0, 14, 14, inner)
            Make("UIListLayout", {
                FillDirection     = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding           = UDim.new(0, 8),
            }, inner)

            local iconImg = Make("ImageLabel", {
                Size            = UDim2.fromOffset(16, 16),
                BackgroundTransparency = 1,
                ImageColor3     = CurrentTheme.Accent,
            }, inner)
            ApplyIcon(iconImg, bOpts.Icon, 16)
            if not bOpts.Icon then iconImg.Visible = false end

            Make("TextLabel", {
                Size            = UDim2.new(1, 0, 1, 0),
                AutomaticSize   = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text            = bOpts.Title or "Button",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, inner)

            -- Right arrow indicator
            Make("TextLabel", {
                Size            = UDim2.fromOffset(20, 20),
                Position        = UDim2.new(1, -34, 0.5, -10),
                BackgroundTransparency = 1,
                Text            = "›",
                TextColor3      = CurrentTheme.TextMuted,
                TextSize        = 18,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Center,
            }, card)

            card.MouseEnter:Connect(function()
                TweenFast(card, { BackgroundTransparency = 0.2 })
            end)
            card.MouseLeave:Connect(function()
                TweenFast(card, { BackgroundTransparency = 0.4 })
            end)
            card.MouseButton1Down:Connect(function()
                TweenFast(card, { BackgroundTransparency = 0.1 })
            end)
            card.MouseButton1Up:Connect(function()
                TweenFast(card, { BackgroundTransparency = 0.2 })
            end)
            card.MouseButton1Click:Connect(function()
                if bOpts.Callback then
                    task.spawn(bOpts.Callback)
                end
            end)

            RegisterSearch(card, bOpts.Title)
            return card
        end

        -- ── TOGGLE ────────────────────────────
        function Tab:CreateToggle(tOpts)
            tOpts = tOpts or {}
            local flag     = tOpts.Flag
            local value    = tOpts.Default or false
            local callback = tOpts.Callback

            local card = Make("TextButton", {
                Name            = "Toggle_" .. tostring(tOpts.Title),
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
                Text            = "",
                AutoButtonColor = false,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)

            local inner = Make("Frame", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, card)
            MakePadding(0, 0, 14, 14, inner)

            Make("TextLabel", {
                Size            = UDim2.new(1, -56, 1, 0),
                BackgroundTransparency = 1,
                Text            = tOpts.Title or "Toggle",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, inner)

            -- Toggle track
            local Track = Make("Frame", {
                Name            = "Track",
                Size            = UDim2.fromOffset(44, 24),
                Position        = UDim2.new(1, -44, 0.5, -12),
                BackgroundColor3 = value and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff,
            }, card)
            MakeCorner(12, Track)

            local Knob = Make("Frame", {
                Name            = "Knob",
                Size            = UDim2.fromOffset(18, 18),
                Position        = value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            }, Track)
            MakeCorner(9, Knob)
            Make("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 240)),
                }),
                Rotation = 90,
            }, Knob)

            local function SetValue(v, silent)
                value = v
                if flag then Window.Flags[flag] = v end
                TweenFast(Track, { BackgroundColor3 = v and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff })
                TweenFast(Knob, { Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) })
                if not silent and callback then
                    task.spawn(callback, v)
                end
            end

            if flag then Window.Flags[flag] = value end

            card.MouseButton1Click:Connect(function()
                SetValue(not value)
            end)
            card.MouseEnter:Connect(function()
                TweenFast(card, { BackgroundTransparency = 0.2 })
            end)
            card.MouseLeave:Connect(function()
                TweenFast(card, { BackgroundTransparency = 0.4 })
            end)

            RegisterSearch(card, tOpts.Title)

            local Toggle = {}
            function Toggle:Set(v) SetValue(v) end
            function Toggle:Get() return value end
            Toggle._flag = flag
            Toggle._type = "Toggle"
            Toggle._getValue = function() return value end
            Toggle._setValue = SetValue

            if flag then
                Window._components[flag] = Toggle
            end

            return Toggle
        end

        -- ── SLIDER ────────────────────────────
        function Tab:CreateSlider(sOpts)
            sOpts = sOpts or {}
            local flag     = sOpts.Flag
            local minVal   = sOpts.Min     or 0
            local maxVal   = sOpts.Max     or 100
            local step     = sOpts.Step    or 1
            local value    = sOpts.Default or minVal
            local callback = sOpts.Callback

            local card = Make("Frame", {
                Name            = "Slider_" .. tostring(sOpts.Title),
                Size            = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)
            MakePadding(10, 10, 14, 14, card)
            MakeListLayout(Enum.FillDirection.Vertical, 8, nil, nil, card)

            -- Top row: title + value
            local topRow = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
            }, card)

            Make("TextLabel", {
                Size            = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = sOpts.Title or "Slider",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, topRow)

            local ValueLabel = Make("TextLabel", {
                Size            = UDim2.new(0.3, 0, 1, 0),
                Position        = UDim2.fromScale(0.7, 0),
                BackgroundTransparency = 1,
                Text            = tostring(value),
                TextColor3      = CurrentTheme.Accent,
                TextSize        = 13,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Right,
            }, topRow)

            -- Track
            local TrackBg = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 6),
                BackgroundColor3 = CurrentTheme.Border,
                BackgroundTransparency = 0.3,
            }, card)
            MakeCorner(4, TrackBg)

            local Fill = Make("Frame", {
                Size            = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = CurrentTheme.SliderFill,
            }, TrackBg)
            MakeCorner(4, Fill)
            Make("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, CurrentTheme.AccentGlow),
                    ColorSequenceKeypoint.new(1, CurrentTheme.Accent),
                }),
            }, Fill)

            -- Thumb
            local Thumb = Make("Frame", {
                Name            = "Thumb",
                Size            = UDim2.fromOffset(14, 14),
                AnchorPoint     = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex          = 2,
            }, TrackBg)
            MakeCorner(7, Thumb)
            MakeStroke(2, CurrentTheme.Accent, 0, Thumb)

            local function Round(n, s)
                if s == 0 then return n end
                return math.round(n / s) * s
            end

            local function UpdateSlider(v, silent)
                value = math.clamp(Round(v, step), minVal, maxVal)
                if flag then Window.Flags[flag] = value end
                local range = maxVal - minVal
                local pct = range == 0 and 0 or ((value - minVal) / range)
                TweenFast(Fill, { Size = UDim2.new(pct, 0, 1, 0) })
                Thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                ValueLabel.Text = tostring(value)
                if not silent and callback then
                    task.spawn(callback, value)
                end
            end

            UpdateSlider(value, true)

            local draggingSlider = false

            local function CalcValue(inputPos)
                local absPos  = TrackBg.AbsolutePosition
                local absSize = TrackBg.AbsoluteSize
                local relX    = math.clamp(inputPos.X - absPos.X, 0, absSize.X)
                local pct     = relX / absSize.X
                return minVal + pct * (maxVal - minVal)
            end

            TrackBg.InputBegan:Connect(function(input)
                local t = input.UserInputType
                if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                    draggingSlider = true
                    UpdateSlider(CalcValue(input.Position))
                end
            end)

            local sliderMove = UserInputService.InputChanged:Connect(function(input)
                if not draggingSlider then return end
                local t = input.UserInputType
                if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
                    UpdateSlider(CalcValue(input.Position))
                end
            end)

            local sliderEnd = UserInputService.InputEnded:Connect(function(input)
                local t = input.UserInputType
                if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            table.insert(Window._connections, sliderMove)
            table.insert(Window._connections, sliderEnd)

            RegisterSearch(card, sOpts.Title)

            local Slider = {}
            function Slider:Set(v) UpdateSlider(v) end
            function Slider:SetValue(v) UpdateSlider(v) end
            function Slider:Get() return value end
            function Slider:GetValue() return value end
            Slider._flag     = flag
            Slider._type     = "Slider"
            Slider._getValue = function() return value end
            Slider._setValue = UpdateSlider

            if flag then Window._components[flag] = Slider end

            return Slider
        end

        -- ── DROPDOWN ──────────────────────────
        function Tab:CreateDropdown(dOpts)
            dOpts = dOpts or {}
            local flag     = dOpts.Flag
            local values   = dOpts.Values   or {}
            local value    = dOpts.Default  or (values[1] or "")
            local callback = dOpts.Callback
            local isOpen   = false

            local card = Make("Frame", {
                Name            = "Dropdown_" .. tostring(dOpts.Title),
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
                ClipsDescendants = false,
                ZIndex          = 10,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)

            local Header2 = Make("TextButton", {
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text            = "",
                AutoButtonColor = false,
                ZIndex          = 11,
            }, card)
            MakePadding(0, 0, 14, 14, Header2)

            Make("TextLabel", {
                Size            = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = dOpts.Title or "Dropdown",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 12,
            }, Header2)

            local SelectedLabel = Make("TextLabel", {
                Size            = UDim2.new(0.35, 0, 1, 0),
                Position        = UDim2.fromScale(0.6, 0),
                BackgroundTransparency = 1,
                Text            = tostring(value),
                TextColor3      = CurrentTheme.Accent,
                TextSize        = 12,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 12,
            }, Header2)

            local Arrow = Make("TextLabel", {
                Size            = UDim2.fromOffset(16, 16),
                Position        = UDim2.new(1, -16, 0.5, -8),
                BackgroundTransparency = 1,
                Text            = "▾",
                TextColor3      = CurrentTheme.TextMuted,
                TextSize        = 14,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Center,
                ZIndex          = 12,
            }, card)

            -- Dropdown panel
            local Panel = Make("Frame", {
                Name            = "Panel",
                Size            = UDim2.new(1, 0, 0, 0),
                Position        = UDim2.fromOffset(0, 46),
                BackgroundColor3 = CurrentTheme.SurfaceElevated,
                BackgroundTransparency = 0.1,
                ClipsDescendants = true,
                Visible         = false,
                ZIndex          = 20,
            }, card)
            MakeCorner(10, Panel)
            MakeStroke(1, CurrentTheme.Border, 0.4, Panel)

            local PanelScroll = Make("ScrollingFrame", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = CurrentTheme.ScrollBar,
                CanvasSize      = UDim2.fromOffset(0, 0),
                ZIndex          = 21,
            }, Panel)

            local PanelList = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex          = 22,
            }, PanelScroll)
            MakePadding(4, 4, 4, 4, PanelList)
            MakeListLayout(Enum.FillDirection.Vertical, 2, nil, nil, PanelList)
            SizeToContent(PanelScroll)

            local optionBtns = {}

            local function SetValue(v, silent)
                value = v
                if flag then Window.Flags[flag] = v end
                SelectedLabel.Text = tostring(v)
                -- Update selection highlight
                for _, ob in pairs(optionBtns) do
                    local isSelected = ob._value == v
                    TweenFast(ob._frame, { BackgroundTransparency = isSelected and 0.6 or 1 })
                    ob._label.TextColor3 = isSelected and CurrentTheme.Accent or CurrentTheme.Text
                    ob._label.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
                end
                if not silent and callback then
                    task.spawn(callback, v)
                end
            end

            -- Build options
            for _, optVal in ipairs(values) do
                local optBtn = Make("TextButton", {
                    Size            = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = CurrentTheme.Accent,
                    BackgroundTransparency = 1,
                    Text            = "",
                    AutoButtonColor = false,
                    ZIndex          = 23,
                }, PanelList)
                MakeCorner(8, optBtn)
                MakePadding(0, 0, 10, 10, optBtn)

                local optLabel = Make("TextLabel", {
                    Size            = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text            = tostring(optVal),
                    TextColor3      = CurrentTheme.Text,
                    TextSize        = 12,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 24,
                }, optBtn)

                local entry = { _value = optVal, _frame = optBtn, _label = optLabel }
                table.insert(optionBtns, entry)

                optBtn.MouseEnter:Connect(function()
                    TweenFast(optBtn, { BackgroundTransparency = 0.7 })
                end)
                optBtn.MouseLeave:Connect(function()
                    local isSel = optVal == value
                    TweenFast(optBtn, { BackgroundTransparency = isSel and 0.6 or 1 })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    SetValue(optVal)
                    isOpen = false
                    TweenFast(Arrow, { Rotation = 0 })
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42) }, 0.2)
                    task.delay(0.2, function() Panel.Visible = false end)
                end)
            end

            SetValue(value, true)

            local function ToggleOpen()
                isOpen = not isOpen
                if isOpen then
                    local contentH = math.min(#values * 38 + 8, 180)
                    Panel.Visible = true
                    TweenFast(Arrow, { Rotation = 180 })
                    Tween(Panel, { Size = UDim2.new(1, 0, 0, contentH) }, 0.2)
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42 + contentH + 4) }, 0.2)
                else
                    TweenFast(Arrow, { Rotation = 0 })
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42) }, 0.2)
                    task.delay(0.2, function() Panel.Visible = false end)
                end
            end

            Header2.MouseButton1Click:Connect(ToggleOpen)

            RegisterSearch(card, dOpts.Title)

            if flag then Window.Flags[flag] = value end

            local Dropdown = {}
            function Dropdown:Set(v) SetValue(v) end
            function Dropdown:UpdateSelection(v) SetValue(v) end
            function Dropdown:Get() return value end
            Dropdown._flag     = flag
            Dropdown._type     = "Dropdown"
            Dropdown._getValue = function() return value end
            Dropdown._setValue = SetValue

            if flag then Window._components[flag] = Dropdown end

            return Dropdown
        end

        -- ── MULTI DROPDOWN ───────────────────
        function Tab:CreateMultiDropdown(mOpts)
            mOpts = mOpts or {}
            local flag     = mOpts.Flag
            local values   = mOpts.Values   or {}
            local selected = {}
            local callback = mOpts.Callback
            local isOpen   = false

            -- Initialize defaults
            if mOpts.Default then
                for _, v in ipairs(mOpts.Default) do
                    selected[v] = true
                end
            end

            local card = Make("Frame", {
                Name            = "MultiDropdown_" .. tostring(mOpts.Title),
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
                ClipsDescendants = false,
                ZIndex          = 10,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)

            local Header3 = Make("TextButton", {
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text            = "",
                AutoButtonColor = false,
                ZIndex          = 11,
            }, card)
            MakePadding(0, 0, 14, 14, Header3)

            Make("TextLabel", {
                Size            = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = mOpts.Title or "Multi Dropdown",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 12,
            }, Header3)

            local CountLabel = Make("TextLabel", {
                Size            = UDim2.new(0.45, 0, 1, 0),
                Position        = UDim2.fromScale(0.5, 0),
                BackgroundTransparency = 1,
                Text            = "0 selected",
                TextColor3      = CurrentTheme.Accent,
                TextSize        = 12,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 12,
            }, Header3)

            Make("TextLabel", {
                Size            = UDim2.fromOffset(16, 16),
                Position        = UDim2.new(1, -16, 0.5, -8),
                BackgroundTransparency = 1,
                Text            = "▾",
                TextColor3      = CurrentTheme.TextMuted,
                TextSize        = 14,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Center,
                ZIndex          = 12,
            }, card)

            local Panel2 = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                Position        = UDim2.fromOffset(0, 46),
                BackgroundColor3 = CurrentTheme.SurfaceElevated,
                BackgroundTransparency = 0.1,
                ClipsDescendants = true,
                Visible         = false,
                ZIndex          = 20,
            }, card)
            MakeCorner(10, Panel2)
            MakeStroke(1, CurrentTheme.Border, 0.4, Panel2)

            local P2Scroll = Make("ScrollingFrame", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = CurrentTheme.ScrollBar,
                CanvasSize      = UDim2.fromOffset(0, 0),
                ZIndex          = 21,
            }, Panel2)

            local P2List = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex          = 22,
            }, P2Scroll)
            MakePadding(4, 4, 4, 4, P2List)
            MakeListLayout(Enum.FillDirection.Vertical, 2, nil, nil, P2List)
            SizeToContent(P2Scroll)

            local function UpdateCount()
                local count = 0
                for _ in pairs(selected) do count += 1 end
                CountLabel.Text = count .. " selected"
                if flag then
                    local arr = {}
                    for k in pairs(selected) do table.insert(arr, k) end
                    Window.Flags[flag] = arr
                end
                if callback then
                    local arr = {}
                    for k in pairs(selected) do table.insert(arr, k) end
                    task.spawn(callback, arr)
                end
            end

            for _, optVal in ipairs(values) do
                local optBtn = Make("TextButton", {
                    Size            = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = CurrentTheme.Accent,
                    BackgroundTransparency = 1,
                    Text            = "",
                    AutoButtonColor = false,
                    ZIndex          = 23,
                }, P2List)
                MakeCorner(8, optBtn)
                MakePadding(0, 0, 10, 10, optBtn)

                local optRow = Make("Frame", {
                    Size            = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ZIndex          = 24,
                }, optBtn)
                Make("UIListLayout", {
                    FillDirection     = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding           = UDim.new(0, 8),
                }, optRow)

                -- Checkbox
                local CheckBox = Make("Frame", {
                    Size            = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = selected[optVal] and CurrentTheme.Accent or CurrentTheme.Border,
                    BackgroundTransparency = selected[optVal] and 0 or 0.3,
                    ZIndex          = 25,
                }, optRow)
                MakeCorner(4, CheckBox)
                MakeStroke(1, CurrentTheme.Accent, selected[optVal] and 0 or 0.5, CheckBox)

                Make("TextLabel", {
                    Size            = UDim2.fromOffset(10, 10),
                    Position        = UDim2.fromOffset(3, 3),
                    BackgroundTransparency = 1,
                    Text            = "✓",
                    TextColor3      = Color3.fromRGB(255, 255, 255),
                    TextSize        = 10,
                    Font            = Enum.Font.GothamBold,
                    TextTransparency = selected[optVal] and 0 or 1,
                    ZIndex          = 26,
                }, CheckBox)

                Make("TextLabel", {
                    Size            = UDim2.new(1, -24, 1, 0),
                    BackgroundTransparency = 1,
                    Text            = tostring(optVal),
                    TextColor3      = CurrentTheme.Text,
                    TextSize        = 12,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 24,
                }, optRow)

                optBtn.MouseButton1Click:Connect(function()
                    selected[optVal] = not selected[optVal]
                    local isSel = selected[optVal]
                    TweenFast(CheckBox, {
                        BackgroundColor3 = isSel and CurrentTheme.Accent or CurrentTheme.Border,
                        BackgroundTransparency = isSel and 0 or 0.3,
                    })
                    local check = CheckBox:FindFirstChildOfClass("TextLabel")
                    if check then
                        TweenFast(check, { TextTransparency = isSel and 0 or 1 })
                    end
                    UpdateCount()
                end)
            end

            UpdateCount()

            Header3.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local contentH = math.min(#values * 38 + 8, 180)
                    Panel2.Visible = true
                    Tween(Panel2, { Size = UDim2.new(1, 0, 0, contentH) }, 0.2)
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42 + contentH + 4) }, 0.2)
                else
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42) }, 0.2)
                    task.delay(0.2, function() Panel2.Visible = false end)
                end
            end)

            RegisterSearch(card, mOpts.Title)

            local Multi = {}
            function Multi:Set(arr)
                selected = {}
                if type(arr) == "table" then
                    for _, v in ipairs(arr) do selected[v] = true end
                end
                UpdateCount()
            end
            function Multi:UpdateSelection(arr) self:Set(arr) end
            function Multi:Get()
                local arr = {}
                for k in pairs(selected) do table.insert(arr, k) end
                return arr
            end
            Multi._flag     = flag
            Multi._type     = "MultiDropdown"
            Multi._getValue = function() return Multi:Get() end

            if flag then Window._components[flag] = Multi end

            return Multi
        end

        -- ── INPUT ─────────────────────────────
        function Tab:CreateInput(iOpts)
            iOpts = iOpts or {}
            local flag        = iOpts.Flag
            local value       = iOpts.Default or ""
            local callback    = iOpts.Callback

            local card = Make("Frame", {
                Name            = "Input_" .. tostring(iOpts.Title),
                Size            = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)
            MakePadding(10, 10, 14, 14, card)
            MakeListLayout(Enum.FillDirection.Vertical, 6, nil, nil, card)

            Make("TextLabel", {
                Size            = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text            = iOpts.Title or "Input",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, card)

            local InputBox = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = CurrentTheme.SurfaceElevated,
                BackgroundTransparency = 0.3,
            }, card)
            MakeCorner(8, InputBox)
            MakeStroke(1, CurrentTheme.Border, 0.4, InputBox)
            MakePadding(0, 0, 10, 10, InputBox)

            local InputField = Make("TextBox", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = value,
                PlaceholderText = iOpts.Placeholder or "Enter value...",
                PlaceholderColor3 = CurrentTheme.TextDim,
                TextColor3      = CurrentTheme.Text,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            }, InputBox)

            InputField.FocusLost:Connect(function(enterPressed)
                value = InputField.Text
                if flag then Window.Flags[flag] = value end
                if callback then
                    task.spawn(callback, value, enterPressed)
                end
            end)

            InputField.Focused:Connect(function()
                TweenFast(InputBox, { BackgroundTransparency = 0.1 })
            end)

            InputField.FocusLost:Connect(function()
                TweenFast(InputBox, { BackgroundTransparency = 0.3 })
            end)

            RegisterSearch(card, iOpts.Title)
            if flag then Window.Flags[flag] = value end

            local Input = {}
            function Input:Set(v)
                value = tostring(v)
                InputField.Text = value
                if flag then Window.Flags[flag] = value end
            end
            function Input:Get() return value end
            Input._flag     = flag
            Input._type     = "Input"
            Input._getValue = function() return value end

            if flag then Window._components[flag] = Input end

            return Input
        end

        -- ── KEYBIND ───────────────────────────
        function Tab:CreateKeybind(kOpts)
            kOpts = kOpts or {}
            local flag     = kOpts.Flag
            local value    = kOpts.Default or Enum.KeyCode.Unknown
            local callback = kOpts.Callback
            local listening = false

            if flag then Window.Flags[flag] = value end

            local card = Make("TextButton", {
                Name            = "Keybind_" .. tostring(kOpts.Title),
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
                Text            = "",
                AutoButtonColor = false,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)

            local inner = Make("Frame", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, card)
            MakePadding(0, 0, 14, 14, inner)

            Make("TextLabel", {
                Size            = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = kOpts.Title or "Keybind",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
            }, inner)

            local KeyPill = Make("Frame", {
                Name            = "KeyPill",
                Size            = UDim2.fromOffset(80, 26),
                Position        = UDim2.new(1, -80, 0.5, -13),
                BackgroundColor3 = CurrentTheme.SurfaceElevated,
                BackgroundTransparency = 0.3,
            }, card)
            MakeCorner(6, KeyPill)
            MakeStroke(1, CurrentTheme.Accent, 0.5, KeyPill)

            local KeyLabel = Make("TextLabel", {
                Size            = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text            = value.Name or "None",
                TextColor3      = CurrentTheme.Accent,
                TextSize        = 11,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Center,
            }, KeyPill)

            card.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                KeyLabel.Text = "..."
                TweenFast(KeyPill, { BackgroundTransparency = 0.1 })
            end)

            local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not listening then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if input.KeyCode == Enum.KeyCode.Escape then
                    listening = false
                    KeyLabel.Text = value.Name
                    TweenFast(KeyPill, { BackgroundTransparency = 0.3 })
                    return
                end
                value = input.KeyCode
                if flag then Window.Flags[flag] = value end
                listening = false
                KeyLabel.Text = value.Name
                TweenFast(KeyPill, { BackgroundTransparency = 0.3 })
                if callback then
                    task.spawn(callback, value)
                end
                if kOpts.onBinded then
                    task.spawn(kOpts.onBinded, value)
                end
            end)

            table.insert(Window._connections, keybindConn)

            RegisterSearch(card, kOpts.Title)

            local Keybind = {}
            function Keybind:Set(key)
                value = key
                if flag then Window.Flags[flag] = value end
                KeyLabel.Text = key.Name or tostring(key)
            end
            function Keybind:Get() return value end
            Keybind._flag     = flag
            Keybind._type     = "Keybind"
            Keybind._getValue = function() return value end

            if flag then Window._components[flag] = Keybind end

            return Keybind
        end

        -- ── COLOR PICKER ──────────────────────
        function Tab:CreateColorPicker(cpOpts)
            cpOpts = cpOpts or {}
            local flag     = cpOpts.Flag
            local value    = cpOpts.Default or Color3.fromRGB(124, 104, 255)
            local callback = cpOpts.Callback
            local isOpen   = false

            if flag then Window.Flags[flag] = value end

            local card = Make("Frame", {
                Name            = "ColorPicker_" .. tostring(cpOpts.Title),
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
                ClipsDescendants = false,
                ZIndex          = 10,
            }, TabContent)
            MakeCorner(10, card)
            MakeStroke(1, CurrentTheme.Border, 0.5, card)

            local HeaderBtn = Make("TextButton", {
                Size            = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text            = "",
                AutoButtonColor = false,
                ZIndex          = 11,
            }, card)
            MakePadding(0, 0, 14, 14, HeaderBtn)

            Make("TextLabel", {
                Size            = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = cpOpts.Title or "Color",
                TextColor3      = CurrentTheme.Text,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 12,
            }, HeaderBtn)

            -- Color preview swatch
            local Swatch = Make("Frame", {
                Name            = "Swatch",
                Size            = UDim2.fromOffset(28, 22),
                Position        = UDim2.new(1, -32, 0.5, -11),
                BackgroundColor3 = value,
                ZIndex          = 12,
            }, card)
            MakeCorner(6, Swatch)
            MakeStroke(1, CurrentTheme.Border, 0.3, Swatch)

            -- Picker popup
            local Popup = Make("Frame", {
                Name            = "Popup",
                Size            = UDim2.new(1, 0, 0, 0),
                Position        = UDim2.fromOffset(0, 46),
                BackgroundColor3 = CurrentTheme.SurfaceElevated,
                BackgroundTransparency = 0.1,
                ClipsDescendants = true,
                Visible         = false,
                ZIndex          = 20,
            }, card)
            MakeCorner(10, Popup)
            MakeStroke(1, CurrentTheme.Border, 0.4, Popup)

            local PopupInner = Make("Frame", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex          = 21,
            }, Popup)
            MakePadding(12, 12, 12, 12, PopupInner)
            MakeListLayout(Enum.FillDirection.Vertical, 8, nil, nil, PopupInner)

            -- R G B sliders
            local rVal = math.round(value.R * 255)
            local gVal = math.round(value.G * 255)
            local bVal = math.round(value.B * 255)

            local function MakeRGBSlider(label, initVal, color)
                local row = Make("Frame", {
                    Size            = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ZIndex          = 22,
                }, PopupInner)

                Make("TextLabel", {
                    Size            = UDim2.fromOffset(16, 28),
                    BackgroundTransparency = 1,
                    Text            = label,
                    TextColor3      = color,
                    TextSize        = 12,
                    Font            = Enum.Font.GothamBold,
                    TextXAlignment  = Enum.TextXAlignment.Center,
                    ZIndex          = 23,
                }, row)

                local sliderTrack = Make("Frame", {
                    Size            = UDim2.new(1, -56, 0, 6),
                    Position        = UDim2.new(0, 20, 0.5, -3),
                    BackgroundColor3 = CurrentTheme.Border,
                    BackgroundTransparency = 0.3,
                    ZIndex          = 23,
                }, row)
                MakeCorner(4, sliderTrack)

                local sliderFill = Make("Frame", {
                    Size            = UDim2.new(initVal/255, 0, 1, 0),
                    BackgroundColor3 = color,
                    ZIndex          = 24,
                }, sliderTrack)
                MakeCorner(4, sliderFill)

                local valLbl = Make("TextLabel", {
                    Size            = UDim2.fromOffset(32, 28),
                    Position        = UDim2.new(1, -32, 0, 0),
                    BackgroundTransparency = 1,
                    Text            = tostring(initVal),
                    TextColor3      = CurrentTheme.Text,
                    TextSize        = 11,
                    Font            = Enum.Font.GothamBold,
                    TextXAlignment  = Enum.TextXAlignment.Right,
                    ZIndex          = 23,
                }, row)

                local currentVal = initVal
                local draggingRGB = false

                sliderTrack.InputBegan:Connect(function(input)
                    local t = input.UserInputType
                    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                        draggingRGB = true
                        local absPos  = sliderTrack.AbsolutePosition
                        local absSize = sliderTrack.AbsoluteSize
                        local relX    = math.clamp(input.Position.X - absPos.X, 0, absSize.X)
                        currentVal    = math.round(relX / absSize.X * 255)
                        sliderFill.Size = UDim2.new(currentVal/255, 0, 1, 0)
                        valLbl.Text   = tostring(currentVal)
                    end
                end)

                local rgbMoveConn = UserInputService.InputChanged:Connect(function(input)
                    if not draggingRGB then return end
                    local t = input.UserInputType
                    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
                        local absPos  = sliderTrack.AbsolutePosition
                        local absSize = sliderTrack.AbsoluteSize
                        local relX    = math.clamp(input.Position.X - absPos.X, 0, absSize.X)
                        currentVal    = math.round(relX / absSize.X * 255)
                        sliderFill.Size = UDim2.new(currentVal/255, 0, 1, 0)
                        valLbl.Text   = tostring(currentVal)
                    end
                end)

                local rgbEndConn = UserInputService.InputEnded:Connect(function(input)
                    local t = input.UserInputType
                    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                        draggingRGB = false
                    end
                end)

                table.insert(Window._connections, rgbMoveConn)
                table.insert(Window._connections, rgbEndConn)

                return function() return currentVal end
            end

            local GetR = MakeRGBSlider("R", rVal, Color3.fromRGB(255, 80, 80))
            local GetG = MakeRGBSlider("G", gVal, Color3.fromRGB(80, 220, 80))
            local GetB = MakeRGBSlider("B", bVal, Color3.fromRGB(80, 140, 255))

            -- Preview bar
            local PreviewBar = Make("Frame", {
                Size            = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = value,
                ZIndex          = 22,
            }, PopupInner)
            MakeCorner(8, PreviewBar)

            -- Apply button
            local ApplyBtn = Make("TextButton", {
                Size            = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = CurrentTheme.Accent,
                BackgroundTransparency = 0.2,
                Text            = "Apply",
                TextColor3      = Color3.fromRGB(255, 255, 255),
                TextSize        = 12,
                Font            = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex          = 22,
            }, PopupInner)
            MakeCorner(8, ApplyBtn)

            -- Preview update (real-time)
            local previewConn = RunService.Heartbeat:Connect(function()
                if isOpen then
                    local previewColor = Color3.fromRGB(GetR(), GetG(), GetB())
                    PreviewBar.BackgroundColor3 = previewColor
                end
            end)
            table.insert(Window._connections, previewConn)

            ApplyBtn.MouseButton1Click:Connect(function()
                value = Color3.fromRGB(GetR(), GetG(), GetB())
                Swatch.BackgroundColor3 = value
                if flag then Window.Flags[flag] = value end
                if callback then task.spawn(callback, value) end
                isOpen = false
                Tween(card, { Size = UDim2.new(1, 0, 0, 42) }, 0.2)
                task.delay(0.2, function() Popup.Visible = false end)
            end)

            HeaderBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Popup.Visible = true
                    Tween(Popup, { Size = UDim2.new(1, 0, 0, 180) }, 0.25)
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42 + 180 + 4) }, 0.25)
                else
                    Tween(card, { Size = UDim2.new(1, 0, 0, 42) }, 0.2)
                    task.delay(0.2, function() Popup.Visible = false end)
                end
            end)

            RegisterSearch(card, cpOpts.Title)

            local ColorPicker = {}
            function ColorPicker:Set(c)
                if typeof(c) ~= "Color3" then return end
                value = c
                Swatch.BackgroundColor3 = c
                if flag then Window.Flags[flag] = value end
                if callback then task.spawn(callback, value) end
            end
            function ColorPicker:SetColor(c) self:Set(c) end
            function ColorPicker:Get() return value end
            function ColorPicker:GetColor() return value end
            ColorPicker._flag     = flag
            ColorPicker._type     = "ColorPicker"
            ColorPicker._getValue = function() return value end

            if flag then Window._components[flag] = ColorPicker end

            return ColorPicker
        end

        -- ── EXTRA MACLIB-STYLE ELEMENTS ───────────
        function Tab:CreateLabel(labelOpts)
            local textValue = type(labelOpts) == "string" and labelOpts or (labelOpts and (labelOpts.Text or labelOpts.Name)) or ""
            local label = Make("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text = tostring(textValue),
                TextColor3 = CurrentTheme.TextMuted,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, TabContent)
            RegisterSearch(label, textValue)
            local obj = {}
            function obj:Set(v) label.Text = tostring(v) end
            function obj:Get() return label.Text end
            function obj:Destroy() label:Destroy() end
            return obj
        end

        function Tab:CreateSubLabel(opts)
            local textValue = type(opts) == "string" and opts or (opts and (opts.Text or opts.Name)) or ""
            local label = self:CreateLabel(textValue)
            label._label = true
            return label
        end

        function Tab:CreateDivider()
            local divider = Make("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = CurrentTheme.Border,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
            }, TabContent)
            return { Destroy = function() divider:Destroy() end }
        end

        function Tab:CreateHeader(textValue)
            return self:CreateSection(textValue)
        end

        function Tab:CreateImage(opts)
            opts = type(opts) == "string" and { Image = opts } or (opts or {})
            local image = Make("ImageLabel", {
                Name = "Image",
                Size = opts.Size or UDim2.new(1, 0, 0, opts.Height or 140),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.35,
                Image = opts.Image or opts.Asset or "",
                ImageTransparency = opts.ImageTransparency or 0,
                ScaleType = opts.ScaleType or Enum.ScaleType.Crop,
            }, TabContent)
            MakeCorner(opts.CornerRadius or 10, image)
            if opts.Caption then
                Make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 1, -24),
                    BackgroundColor3 = Color3.new(0,0,0),
                    BackgroundTransparency = 0.35,
                    Text = tostring(opts.Caption),
                    TextColor3 = Color3.new(1,1,1),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                }, image)
            end
            return {
                SetImage = function(_, asset) image.Image = tostring(asset or "") end,
                Destroy = function() image:Destroy() end,
            }
        end

        function Tab:CreateProgressBar(opts)
            opts = opts or {}
            local minVal = opts.Min or 0
            local maxVal = opts.Max or 100
            local value = opts.Default or minVal
            local card = Make("Frame", {
                Name = "ProgressBar",
                Size = UDim2.new(1, 0, 0, 46),
                BackgroundColor3 = CurrentTheme.SurfaceGlass,
                BackgroundTransparency = 0.4,
            }, TabContent)
            MakeCorner(10, card)
            MakePadding(8, 8, 12, 12, card)
            local titleLabel = Make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
                Text = opts.Title or opts.Name or "Progress",
                TextColor3 = CurrentTheme.Text, TextSize = 12, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, card)
            local track = Make("Frame", {
                Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, 24),
                BackgroundColor3 = CurrentTheme.Border, BackgroundTransparency = 0.3,
            }, card)
            MakeCorner(4, track)
            local fill = Make("Frame", {
                Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = CurrentTheme.Accent
            }, track)
            MakeCorner(4, fill)
            local function set(v, animated)
                value = math.clamp(tonumber(v) or minVal, minVal, maxVal)
                local pct = maxVal == minVal and 0 or (value - minVal) / (maxVal - minVal)
                local props = { Size = UDim2.new(pct, 0, 1, 0) }
                if animated == false then fill.Size = props.Size else TweenFast(fill, props) end
                if opts.Callback then task.spawn(opts.Callback, value) end
            end
            set(value, false)
            local obj = {}
            function obj:Set(v, animated) set(v, animated) end
            function obj:Get() return value end
            function obj:Destroy() card:Destroy() end
            return obj
        end

        -- Aliases
        Tab.AddSection      = Tab.CreateSection
        Tab.AddParagraph    = Tab.CreateParagraph
        Tab.AddButton       = Tab.CreateButton
        Tab.AddToggle       = Tab.CreateToggle
        Tab.AddSlider       = Tab.CreateSlider
        Tab.AddDropdown     = Tab.CreateDropdown
        Tab.AddMultiDropdown = Tab.CreateMultiDropdown
        Tab.AddInput        = Tab.CreateInput
        Tab.AddKeybind      = Tab.CreateKeybind
        Tab.AddColorPicker  = Tab.CreateColorPicker
        Tab.CreateTextbox   = Tab.CreateInput
        Tab.AddTextbox      = Tab.CreateInput
        Tab.CreateLabel     = Tab.CreateLabel
        Tab.AddLabel        = Tab.CreateLabel
        Tab.CreateSubLabel  = Tab.CreateSubLabel
        Tab.AddSubLabel     = Tab.CreateSubLabel
        Tab.CreateDivider   = Tab.CreateDivider
        Tab.AddDivider      = Tab.CreateDivider
        Tab.CreateHeader    = Tab.CreateHeader
        Tab.AddHeader       = Tab.CreateHeader
        Tab.CreateImage     = Tab.CreateImage
        Tab.AddImage        = Tab.CreateImage
        Tab.CreateProgressBar = Tab.CreateProgressBar
        Tab.AddProgressBar    = Tab.CreateProgressBar
        Tab.Section         = Tab.CreateSection

        return Tab
    end

    -- ── MACLIB-STYLE WINDOW API ──────────────────
    function Window:Show()
        if self._destroyed then return end
        self._open = true
        MainFrame.Visible = true
        local target = self._minimized and UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 52) or winSize
        Spring(MainFrame, { Size = target }, 0.35)
    end

    function Window:Hide()
        if self._destroyed then return end
        self._open = false
        Tween(MainFrame, { Size = UDim2.fromOffset(0, 0) }, 0.25)
        task.delay(0.27, function()
            if not self._open and MainFrame.Parent then MainFrame.Visible = false end
        end)
    end

    function Window:Toggle()
        if self._open then self:Hide() else self:Show() end
    end

    function Window:IsOpen()
        return self._open and not self._destroyed
    end

    function Window:SetVisible(state)
        if state then self:Show() else self:Hide() end
    end

    function Window:GetVisible()
        return self:IsOpen()
    end

    function Window:SelectTab(tab)
        if type(tab) == "number" then
            local target = self._tabs[tab]
            if target then target:Select() end
        elseif type(tab) == "string" then
            for _, target in ipairs(self._tabs) do
                if target._title == tab then target:Select(); return target end
            end
        elseif type(tab) == "table" and tab.Select then
            tab:Select()
        end
    end

    function Window:SetTitle(newTitle)
        title = tostring(newTitle or "")
        local label = Header:FindFirstChild("TitleBlock") and Header.TitleBlock:FindFirstChild("Title")
        if label then label.Text = title end
        self.Settings = self.Settings or {}
        self.Settings.Title = title
    end

    function Window:SetSubtitle(newSubtitle)
        subtitle = tostring(newSubtitle or "")
        local block = Header:FindFirstChild("TitleBlock")
        if not block then return end
        local label = block:FindFirstChild("Subtitle")
        if subtitle == "" then
            if label then label.Visible = false end
        else
            if not label then
                label = Make("TextLabel", {
                    Name = "Subtitle",
                    Size = UDim2.new(0, 0, 0, 14),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Text = subtitle,
                    TextColor3 = CurrentTheme.TextMuted,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 13,
                }, block)
            else
                label.Visible = true
                label.Text = subtitle
            end
        end
    end

    function Window:SetLogo(asset)
        LogoImg.Image = tostring(asset or "")
        LogoImg.Visible = asset ~= nil and tostring(asset) ~= ""
    end

    function Window:SetBackgroundImage(asset, transparency, overlayTransparency)
        local image = MainFrame:FindFirstChild("BackgroundImage")
        local overlay = MainFrame:FindFirstChild("Overlay")
        if not asset or tostring(asset) == "" then
            if image then image.Visible = false end
            if overlay then overlay.Visible = false end
            return
        end
        if not image then
            image = Make("ImageLabel", {
                Name = "BackgroundImage",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = 0,
            }, MainFrame)
        end
        image.Visible = true
        image.Image = tostring(asset)
        image.ImageTransparency = transparency == nil and 0.5 or transparency
        if not overlay then
            overlay = Make("Frame", {
                Name = "Overlay",
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = CurrentTheme.Overlay,
                BorderSizePixel = 0,
                ZIndex = 1,
            }, MainFrame)
        end
        overlay.Visible = true
        overlay.BackgroundTransparency = overlayTransparency == nil and 0.3 or overlayTransparency
    end

    function Window:SetSize(size)
        if typeof(size) == "UDim2" then
            winSize = size
            if not self._minimized then MainFrame.Size = size end
        end
    end

    function Window:GetSize()
        return MainFrame.Size
    end

    function Window:SetNotificationsState(state)
        self._notifications = state == true
    end

    function Window:GetNotificationsState()
        return self._notifications
    end

    function Window:SetUserInfoState(state)
        self._userInfo = state == true
    end

    function Window:GetUserInfoState()
        return self._userInfo
    end

    function Window:GlobalSetting(opts)
        opts = opts or {}
        local state = opts.Default == true
        local setting = {}
        function setting:Set(v)
            state = v == true
            if opts.Callback then task.spawn(opts.Callback, state) end
        end
        function setting:Get() return state end
        if opts.Callback then task.spawn(opts.Callback, state) end
        return setting
    end

    function Window:Dialog(opts)
        opts = opts or {}
        local overlay = Make("TextButton", {
            Name = "DialogOverlay",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.45,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 200,
        }, ScreenGui)
        local dialog = Make("Frame", {
            Size = UDim2.fromOffset(360, 180),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = CurrentTheme.SurfaceElevated,
            BackgroundTransparency = 0.03,
            ZIndex = 201,
        }, overlay)
        MakeCorner(14, dialog)
        MakeStroke(1, CurrentTheme.BorderBright, 0.2, dialog)
        MakePadding(16, 16, 18, 18, dialog)
        MakeListLayout(Enum.FillDirection.Vertical, 8, nil, nil, dialog)
        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
            Text = opts.Title or "Confirm", TextColor3 = CurrentTheme.Text,
            TextSize = 16, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
        }, dialog)
        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 1,
            Text = opts.Description or "", TextColor3 = CurrentTheme.TextMuted,
            TextSize = 12, Font = Enum.Font.Gotham, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 202,
        }, dialog)
        local buttons = opts.Buttons or {{Name = "OK"}}
        local row = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 202
        }, dialog)
        local layout = Make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }, row)
        for _, b in ipairs(buttons) do
            local btn = Make("TextButton", {
                Size = UDim2.fromOffset(92, 30),
                BackgroundColor3 = CurrentTheme.Accent,
                BackgroundTransparency = 0.12,
                Text = tostring(b.Name or "OK"),
                TextColor3 = Color3.new(1,1,1),
                TextSize = 12, Font = Enum.Font.GothamBold,
                AutoButtonColor = false, ZIndex = 203,
            }, row)
            MakeCorner(8, btn)
            btn.MouseButton1Click:Connect(function()
                if b.Callback then task.spawn(b.Callback) end
                if overlay.Parent then overlay:Destroy() end
            end)
        end
        return { Close = function() if overlay.Parent then overlay:Destroy() end end }
    end

    -- ── WINDOW-LEVEL SHORTCUTS (delegate to active tab) ─
    local function assertActiveTab(name)
        if not Window._activeTab then
            warn("[RYEENZYXNZ UI] No tab created. Call CreateTab first before using " .. name)
            return false
        end
        return true
    end

    for _, method in ipairs({
        "CreateSection","AddSection","CreateParagraph","AddParagraph",
        "CreateButton","AddButton","CreateToggle","AddToggle",
        "CreateSlider","AddSlider","CreateDropdown","AddDropdown",
        "CreateMultiDropdown","AddMultiDropdown","CreateInput","AddInput",
        "CreateKeybind","AddKeybind","CreateColorPicker","AddColorPicker",
        "CreateTextbox","AddTextbox","CreateLabel","AddLabel","CreateSubLabel","AddSubLabel",
        "CreateDivider","AddDivider","CreateHeader","AddHeader","CreateImage","AddImage",
        "CreateProgressBar","AddProgressBar",
    }) do
        Window[method] = function(self, ...)
            if assertActiveTab(method) then
                return self._activeTab[method](self._activeTab, ...)
            end
        end
    end

    Window.Tab = Window.CreateTab
    Window.AddTab = Window.CreateTab
    Window.Section = function(self, title) return self:CreateSection(title) end

    -- ── NOTIFICATIONS ─────────────────────────
    function Window:Notify(opts)
        if self._notifications then ShowNotification(opts) end
    end

    -- ── CONFIG ────────────────────────────────
    function Window:SaveConfig(name)
        name = name or configName
        local data = {}
        for flag, comp in pairs(self._components) do
            if comp._getValue then
                local raw = comp._getValue()
                data[flag] = ConfigEncode(raw)
            end
        end
        local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
        if not ok then
            warn("[RYEENZYXNZ UI] Failed to encode config:", json)
            return
        end
        EnsureFolder(configDir)
        local path = configDir .. "/" .. name .. ".json"
        SafeWriteFile(path, json)
    end

    function Window:LoadConfig(name)
        name = name or configName
        local path = configDir .. "/" .. name .. ".json"
        local raw = SafeReadFile(path)
        if not raw then
            warn("[RYEENZYXNZ UI] Config not found:", path)
            return
        end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok then
            warn("[RYEENZYXNZ UI] Failed to decode config:", data)
            return
        end
        for flag, encoded in pairs(data) do
            local comp = self._components[flag]
            if comp and comp._setValue then
                local decoded
                if comp._type == "ColorPicker" then
                    decoded = ConfigDecode(encoded)
                elseif comp._type == "Keybind" then
                    if type(encoded) == "table" and encoded.__type == "EnumItem" then
                        local enumOk, enumVal = pcall(function()
                            return Enum.KeyCode[encoded.Name]
                        end)
                        decoded = enumOk and enumVal or Enum.KeyCode.Unknown
                    else
                        decoded = ConfigDecode(encoded)
                    end
                else
                    decoded = ConfigDecode(encoded)
                end
                pcall(comp._setValue, decoded, true)
            end
        end
    end

    function Window:GetConfigs()
        local result = {}
        if listfiles then
            local ok, files = pcall(listfiles, configDir)
            if ok and type(files) == "table" then
                for _, path in ipairs(files) do
                    local name = tostring(path):match("([^/\\]+)%.json$")
                    if name then table.insert(result, name) end
                end
            end
        end
        table.sort(result)
        return result
    end

    function Window:SetFolder(folder)
        if folder and tostring(folder) ~= "" then configDir = tostring(folder) end
        EnsureFolder(configDir)
    end

    function Window:SetConfig(name)
        if name and tostring(name) ~= "" then configName = tostring(name) end
    end

    function Window:GetConfig()
        return configName
    end

    function Window:DeleteConfig(name)
        name = name or configName
        local path = configDir .. "/" .. name .. ".json"
        SafeDeleteFile(path)
    end

    -- ── TOGGLE KEY ────────────────────────────
    function Window:SetToggleKey(key)
        if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
            toggleKey = key
            self.Settings.ToggleKey = key
        end
    end

    -- ── DESTROY ───────────────────────────────
    function Window:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        self._open = false
        for _, conn in ipairs(self._connections) do
            if conn then pcall(conn.Disconnect, conn) end
        end
        self._connections = {}
        if ScreenGui and ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end

    -- Open animation
    MainFrame.Size = UDim2.fromOffset(0, 0)
    Spring(MainFrame, { Size = winSize }, 0.5)

    table.insert(_ActiveWindows, Window)
    return Window
end

-- ─────────────────────────────────────────────
-- GLOBAL API
-- ─────────────────────────────────────────────
function RYEENZYXNZ_UI:SetLucideModule(module)
    _LucideModule = module
end

function RYEENZYXNZ_UI:AddIcons(iconTable)
    for name, asset in pairs(iconTable) do
        _CustomIcons[name] = asset
    end
end

function RYEENZYXNZ_UI:SetTheme(themeTable)
    for k, v in pairs(themeTable) do
        CurrentTheme[k] = v
    end
end

function RYEENZYXNZ_UI:Notify(opts)
    ShowNotification(opts)
end

return RYEENZYXNZ_UI
