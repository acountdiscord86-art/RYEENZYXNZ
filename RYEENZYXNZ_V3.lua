--[[
╔══════════════════════════════════════════════════════════╗
║          RYEENZYXNZ UI  V3  —  MACLIB EDITION           ║
║  Version  : 3.0.0                                        ║
║  API Style: MacLib-compatible                            ║
║  Design   : Liquid Glass / Glassmorphism                 ║
║  Devices  : PC · Laptop · Android · iOS                  ║
║  Author   : RYEENZYXNZ                                   ║
╚══════════════════════════════════════════════════════════╝

Custom implementation — not derived from MacLib source code.
API structure inspired by MacLib docs; all visuals & logic original.

USAGE:
    local RUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

    local Window = RUI:Window({
        Title    = "My Script",
        Subtitle = "v1.0",
        Keybind  = Enum.KeyCode.RightShift,
    })

    local TabGroup = Window:TabGroup()
    local Tab      = TabGroup:Tab({ Name = "Home", Icon = "house" })
    local Section  = Tab:Section({ Side = "Left" })

    Section:Toggle({ Name = "Auto Farm", Default = false,
        Callback = function(v) print(v) end }, "AutoFarm")
]]

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local GuiService       = game:GetService("GuiService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════
-- INTERNAL GLOBALS
-- ════════════════════════════════════════════════════════
local RUI      = {}
RUI.__index    = RUI
RUI.Version    = "3.0.0"
RUI.Flags      = {}          -- global flag registry
RUI._folder    = "RYEENZYXNZ_V3"
RUI._icons     = {}
RUI._lucide    = nil

-- ════════════════════════════════════════════════════════
-- THEME  (Liquid Glass Dark — default)
-- ════════════════════════════════════════════════════════
local T = {
    -- surfaces
    BG          = Color3.fromRGB(9,   9,  14),
    SURFACE     = Color3.fromRGB(15,  15,  22),
    ELEVATED    = Color3.fromRGB(20,  20,  30),
    GLASS       = Color3.fromRGB(17,  17,  26),
    PANEL       = Color3.fromRGB(13,  13,  20),
    -- text
    TEXT        = Color3.fromRGB(238, 238, 255),
    MUTED       = Color3.fromRGB(130, 130, 158),
    DIM         = Color3.fromRGB(68,  68,  95),
    -- accent
    ACCENT      = Color3.fromRGB(120, 100, 255),
    ACCENT_DIM  = Color3.fromRGB(72,  56, 180),
    ACCENT_GLOW = Color3.fromRGB(96,  76, 220),
    -- utility
    BORDER      = Color3.fromRGB(36,  36,  55),
    BORDER_B    = Color3.fromRGB(55,  55,  82),
    SUCCESS     = Color3.fromRGB(72,  220, 130),
    WARNING     = Color3.fromRGB(255, 185,  55),
    ERROR       = Color3.fromRGB(255,  72,  72),
    -- states
    TOGGLE_ON   = Color3.fromRGB(120, 100, 255),
    TOGGLE_OFF  = Color3.fromRGB(40,  40,  60),
    SLIDER_FILL = Color3.fromRGB(120, 100, 255),
    SCROLL      = Color3.fromRGB(55,  55,  80),
    NOTIF_BG    = Color3.fromRGB(18,  18,  28),
    WHITE       = Color3.fromRGB(255, 255, 255),
    BLACK       = Color3.fromRGB(0,   0,   0),
}

-- ════════════════════════════════════════════════════════
-- TWEEN HELPERS
-- ════════════════════════════════════════════════════════
local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t or .22,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

local function twSpring(obj, props, t)
    return tw(obj, props, t or .45, Enum.EasingStyle.Spring, Enum.EasingDirection.Out)
end

local function twFast(obj, props) return tw(obj, props, .14) end
local function twLin(obj, props, t)
    return tw(obj, props, t or 1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
end

-- ════════════════════════════════════════════════════════
-- INSTANCE HELPERS
-- ════════════════════════════════════════════════════════
local function New(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if parent then o.Parent = parent end
    return o
end

local function Corner(r, p)
    return New("UICorner", { CornerRadius = UDim.new(0, r or 8) }, p)
end

local function Pad(t, b, l, r, p)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, p)
end

local function Stroke(thickness, color, trans, p)
    return New("UIStroke", {
        Thickness       = thickness or 1,
        Color           = color or T.BORDER,
        Transparency    = trans or .4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end

local function List(dir, gap, ha, va, p)
    return New("UIListLayout", {
        FillDirection       = dir  or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, gap or 6),
        HorizontalAlignment = ha  or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va  or Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
    }, p)
end

local function Gradient(colors, rot, p)
    local kps = {}
    for i, c in ipairs(colors) do
        kps[i] = ColorSequenceKeypoint.new((i-1)/(#colors-1), c)
    end
    return New("UIGradient", {
        Color    = ColorSequence.new(kps),
        Rotation = rot or 0,
    }, p)
end

local function SyncCanvas(scroll)
    local layout = scroll:FindFirstChildOfClass("UIListLayout")
    if not layout then return end
    local function upd()
        scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- ════════════════════════════════════════════════════════
-- ICON RESOLVER
-- ════════════════════════════════════════════════════════
local function ResolveIcon(name)
    if not name or name == "" then return nil end
    if type(name) == "string" and name:match("^rbxassetid://") then return name end
    if RUI._icons[name] then return RUI._icons[name] end
    if RUI._lucide then
        local ok, res = pcall(function() return RUI._lucide:GetAsset(name, 24) end)
        if ok and res then return res end
        if RUI._lucide[name] then return RUI._lucide[name] end
    end
    return nil
end

local function SetIcon(img, name, sz)
    local r = ResolveIcon(name)
    if r then img.Image = r img.Visible = true else img.Visible = false end
    if sz then img.Size = UDim2.fromOffset(sz, sz) end
end

-- ════════════════════════════════════════════════════════
-- AUTO-SCALE HELPER
-- Used for mobile/desktop responsiveness
-- ════════════════════════════════════════════════════════
local function GetUIScale()
    local vp = workspace.CurrentCamera.ViewportSize
    local base = Vector2.new(868, 650)
    -- clamp scale between 0.55 and 1.4
    local scale = math.clamp(math.min(vp.X / base.X, vp.Y / base.Y), 0.55, 1.4)
    return scale
end

local function ApplyAutoScale(uiScaleInstance)
    local function update()
        uiScaleInstance.Scale = GetUIScale()
    end
    update()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
end

-- ════════════════════════════════════════════════════════
-- DRAG SYSTEM (mouse + touch)
-- ════════════════════════════════════════════════════════
local function MakeDraggable(handle, target, connections)
    local dragging, dragStart, startPos = false, nil, nil

    local c1 = handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = target.Position
        end
    end)

    local c2 = UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = inp.Position - dragStart
        target.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)

    local c3 = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if connections then
        table.insert(connections, c1)
        table.insert(connections, c2)
        table.insert(connections, c3)
    end
end

-- ════════════════════════════════════════════════════════
-- CONFIG  (JSON + file API)
-- ════════════════════════════════════════════════════════
local CFG = {}

function CFG.Encode(v)
    local t = typeof(v)
    if t == "boolean" or t == "number" or t == "string" then return v end
    if t == "Color3"   then return { __t="Color3",   R=v.R, G=v.G, B=v.B } end
    if t == "EnumItem" then return { __t="Enum",     N=v.Name } end
    if t == "table" then
        local out = {}
        for k, val in pairs(v) do out[k] = CFG.Encode(val) end
        return out
    end
    return tostring(v)
end

function CFG.Decode(v)
    if type(v) ~= "table" then return v end
    if v.__t == "Color3" then return Color3.new(v.R or 0, v.G or 0, v.B or 0) end
    if v.__t == "Enum"   then return v.N end
    local out = {}
    for k, val in pairs(v) do out[k] = CFG.Decode(val) end
    return out
end

function CFG.Write(folder, name, data)
    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then warn("[RUI] JSONEncode failed:", json) return false end
    if isfolder and makefolder then
        if not isfolder(folder) then pcall(makefolder, folder) end
    end
    if writefile then
        local p = folder.."/"..name..".json"
        local ok2, err = pcall(writefile, p, json)
        if not ok2 then warn("[RUI] writefile failed:", err) end
        return ok2
    end
    return false
end

function CFG.Read(folder, name)
    local p = folder.."/"..name..".json"
    if not (isfile and isfile(p)) then return nil end
    local ok, raw = pcall(readfile, p)
    if not ok then return nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    return ok2 and data or nil
end

function CFG.Delete(folder, name)
    local p = folder.."/"..name..".json"
    if isfile and delfile and isfile(p) then pcall(delfile, p) end
end

function CFG.List(folder)
    if not (isfolder and listfiles) then return {} end
    if not isfolder(folder) then return {} end
    local out = {}
    local ok, files = pcall(listfiles, folder)
    if not ok then return {} end
    for _, f in ipairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name then table.insert(out, name..".json") end
    end
    return out
end

-- ════════════════════════════════════════════════════════
-- NOTIFICATION LAYER  (global, lives in CoreGui)
-- ════════════════════════════════════════════════════════
local NotifGui, NotifContainer

local function EnsureNotifLayer()
    if NotifContainer and NotifContainer.Parent then return end

    local gui = New("ScreenGui", {
        Name           = "RUI_Notifs",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 9999,
    })
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = PlayerGui end
    NotifGui = gui

    NotifContainer = New("Frame", {
        Name                 = "Container",
        Size                 = UDim2.new(0, 310, 1, -20),
        Position             = UDim2.new(1, -320, 0, 10),
        BackgroundTransparency = 1,
    }, gui)

    local ll = List(Enum.FillDirection.Vertical, 8,
        Enum.HorizontalAlignment.Right,
        Enum.VerticalAlignment.Bottom, NotifContainer)
    ll.LayoutOrder = 0
end

local function CreateNotif(opts, connections)
    EnsureNotifLayer()
    opts = opts or {}

    local title    = opts.Title       or "RYEENZYXNZ UI"
    local desc     = opts.Description or opts.Content or ""
    local lifetime = opts.Lifetime    or opts.Duration or 4
    local style    = opts.Style       -- "None","Confirm","Cancel"
    local callback = opts.Callback
    local sizeX    = opts.SizeX       or 300

    local card = New("Frame", {
        Name                 = "Notif",
        Size                 = UDim2.new(0, sizeX, 0, 0),
        AutomaticSize        = Enum.AutomaticSize.Y,
        BackgroundColor3     = T.NOTIF_BG,
        BackgroundTransparency = 0.05,
        ClipsDescendants     = false,
    }, NotifContainer)
    Corner(12, card)
    Stroke(1, T.ACCENT, .5, card)

    -- top accent glow line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = .2,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, card)

    local inner = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex           = 3,
    }, card)
    Pad(10, 12, 12, 12, inner)
    List(Enum.FillDirection.Vertical, 4, nil, nil, inner)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 4,
    }, inner)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = desc,
        TextColor3       = T.MUTED,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 4,
    }, inner)

    -- progress bar
    local barBg = New("Frame", {
        Size             = UDim2.new(1, -24, 0, 3),
        Position         = UDim2.new(0, 12, 1, -8),
        BackgroundColor3 = T.BORDER,
        BackgroundTransparency = .2,
        ZIndex           = 4,
    }, card)
    Corner(4, barBg)

    local barFill = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.ACCENT,
    }, barBg)
    Corner(4, barFill)

    -- action button
    local Notif = {}

    if style == "Confirm" or style == "Cancel" then
        local btnColor = style == "Confirm" and T.SUCCESS or T.ERROR
        local btnText  = style == "Confirm" and "✓" or "✕"

        local actionBtn = New("TextButton", {
            Size             = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = btnColor,
            BackgroundTransparency = .6,
            Text             = btnText,
            TextColor3       = T.WHITE,
            TextSize         = 14,
            Font             = Enum.Font.GothamBold,
            AutoButtonColor  = false,
            ZIndex           = 5,
        }, inner)
        Corner(8, actionBtn)

        actionBtn.MouseButton1Click:Connect(function()
            if callback then task.spawn(callback) end
            Notif:Cancel()
        end)
    end

    -- animate in
    card.Position = UDim2.new(1, 20, 0, 0)
    twSpring(card, { Position = UDim2.new(0, 0, 0, 0) }, .5)

    -- drain progress
    twLin(barFill, { Size = UDim2.new(0, 0, 1, 0) }, lifetime)

    local dismissed = false
    function Notif:Cancel()
        if dismissed then return end
        dismissed = true
        tw(card, { Position = UDim2.new(1, 20, 0, 0) }, .25)
        task.delay(.3, function()
            if card and card.Parent then card:Destroy() end
        end)
    end

    function Notif:UpdateTitle(s)     local lbl = inner:FindFirstChild("TextLabel") if lbl then lbl.Text = s end end
    function Notif:UpdateDescription(s) local lbls = inner:GetChildren() if lbls[2] and lbls[2]:IsA("TextLabel") then lbls[2].Text = s end end
    function Notif:Resize(x) card.Size = UDim2.new(0, x, 0, card.Size.Y.Offset) end

    task.delay(lifetime, function() Notif:Cancel() end)

    return Notif
end

-- ════════════════════════════════════════════════════════
-- DIALOG SYSTEM
-- ════════════════════════════════════════════════════════
local function CreateDialog(screenGui, opts, connections)
    opts = opts or {}
    local title   = opts.Title   or "Dialog"
    local desc    = opts.Description or ""
    local buttons = opts.Buttons or { { Text = "OK" } }

    -- overlay
    local overlay = New("Frame", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundColor3 = T.BLACK,
        BackgroundTransparency = .45,
        ZIndex           = 500,
    }, screenGui:FindFirstChildOfClass("Frame") or screenGui)

    local box = New("Frame", {
        Size             = UDim2.fromOffset(380, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Position         = UDim2.fromScale(.5, .5),
        AnchorPoint      = Vector2.new(.5, .5),
        BackgroundColor3 = T.ELEVATED,
        ZIndex           = 501,
    }, overlay)
    Corner(14, box)
    Stroke(1, T.BORDER_B, .3, box)
    Pad(20, 20, 20, 20, box)
    List(Enum.FillDirection.Vertical, 12, nil, nil, box)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.TEXT,
        TextSize         = 15,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 502,
    }, box)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = desc,
        TextColor3       = T.MUTED,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 502,
    }, box)

    local btnRow = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex           = 502,
    }, box)
    List(Enum.FillDirection.Horizontal, 8,
        Enum.HorizontalAlignment.Right,
        Enum.VerticalAlignment.Center, btnRow)

    for _, bOpt in ipairs(buttons) do
        local isAccent = bOpt.Accent or bOpt.Primary
        local b = New("TextButton", {
            Size             = UDim2.fromOffset(100, 34),
            BackgroundColor3 = isAccent and T.ACCENT or T.ELEVATED,
            BackgroundTransparency = isAccent and .2 or .5,
            Text             = bOpt.Text or "OK",
            TextColor3       = isAccent and T.WHITE or T.TEXT,
            TextSize         = 12,
            Font             = Enum.Font.GothamBold,
            AutoButtonColor  = false,
            ZIndex           = 503,
        }, btnRow)
        Corner(8, b)
        Stroke(1, isAccent and T.ACCENT or T.BORDER, .4, b)

        b.MouseButton1Click:Connect(function()
            if bOpt.Callback then task.spawn(bOpt.Callback) end
            overlay:Destroy()
        end)
    end

    overlay.BackgroundTransparency = 1
    tw(overlay, { BackgroundTransparency = .45 }, .2)

    box.Size = UDim2.fromOffset(380, 0)
    box.BackgroundTransparency = 1
    tw(box, { BackgroundTransparency = 0 }, .2)
end

-- ════════════════════════════════════════════════════════
-- GLOBAL SETTING (placed in header of window)
-- ════════════════════════════════════════════════════════
-- GlobalSetting is just a component that lives in the
-- header bar row rather than inside a tab section.

-- ════════════════════════════════════════════════════════
-- ─── COMPONENT BUILDERS (stateless factories) ───────────
-- ════════════════════════════════════════════════════════

-- returns a card frame with glass surface
local function GlassCard(parent, height)
    local card = New("Frame", {
        Name             = "Card",
        Size             = UDim2.new(1, 0, 0, height or 42),
        AutomaticSize    = height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
        ClipsDescendants = false,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)
    return card
end

local function HoverCard(card)
    if not card:IsA("GuiButton") then return end
    card.MouseEnter:Connect(function()    twFast(card, { BackgroundTransparency = .18 }) end)
    card.MouseLeave:Connect(function()    twFast(card, { BackgroundTransparency = .38 }) end)
    card.MouseButton1Down:Connect(function() twFast(card, { BackgroundTransparency = .08 }) end)
    card.MouseButton1Up:Connect(function()   twFast(card, { BackgroundTransparency = .18 }) end)
end

-- ─── TOGGLE ─────────────────────────────────────────────
local function BuildToggle(parent, opts, flag, window, connections)
    local value    = opts.Default  or false
    local callback = opts.Callback
    local name     = opts.Name     or "Toggle"

    local card = New("TextButton", {
        Name             = "Toggle_"..name,
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
        Text             = "",
        AutoButtonColor  = false,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)
    HoverCard(card)

    local inner = New("Frame", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, card)
    Pad(0, 0, 14, 14, inner)

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, inner)

    local track = New("Frame", {
        Name             = "Track",
        Size             = UDim2.fromOffset(42, 24),
        Position         = UDim2.new(1, -42, .5, -12),
        BackgroundColor3 = value and T.TOGGLE_ON or T.TOGGLE_OFF,
    }, card)
    Corner(12, track)

    local knob = New("Frame", {
        Size             = UDim2.fromOffset(18, 18),
        Position         = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = T.WHITE,
    }, track)
    Corner(9, knob)

    local elem = { State = value, IgnoreConfig = false }

    local function Apply(v, silent)
        value = v
        elem.State = v
        if flag then RUI.Flags[flag] = v end
        twFast(track, { BackgroundColor3 = v and T.TOGGLE_ON or T.TOGGLE_OFF })
        twFast(knob,  { Position = v and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) })
        if not silent and callback then task.spawn(callback, v) end
    end

    Apply(value, true)

    card.MouseButton1Click:Connect(function() Apply(not value) end)

    function elem:UpdateName(s)   nameLbl.Text = s end
    function elem:SetVisiblity(v) card.Visible = v end
    function elem:UpdateState(v)  Apply(v) end
    function elem:GetState()      return value end

    if flag then
        RUI.Flags[flag] = value
        if window._components then
            window._components[flag] = {
                _type     = "Toggle",
                _getValue = function() return value end,
                _setValue = function(v, s) Apply(v, s) end,
            }
        end
    end

    return elem
end

-- ─── SLIDER ─────────────────────────────────────────────
local function BuildSlider(parent, opts, flag, window, connections)
    local name     = opts.Name          or "Slider"
    local minVal   = opts.Minimum       or opts.Min or 0
    local maxVal   = opts.Maximum       or opts.Max or 100
    local value    = opts.Default       or minVal
    local prec     = opts.Precision     or 0
    local dispMeth = opts.DisplayMethod or "Value"
    local callback = opts.Callback
    local onInputComplete = opts.onInputComplete

    local card = New("Frame", {
        Name             = "Slider_"..name,
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)
    Pad(10, 10, 14, 14, card)
    List(Enum.FillDirection.Vertical, 8, nil, nil, card)

    -- label row
    local topRow = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
    }, card)

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(.65, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, topRow)

    local function FormatVal(v)
        local rounded = tonumber(string.format("%."..prec.."f", v))
        if dispMeth == "Percent" then return math.round(v).."%"
        elseif dispMeth == "Degrees" then return math.round(v).."°"
        elseif dispMeth == "Round" then return tostring(math.round(v))
        else return tostring(rounded) end
    end

    local valLbl = New("TextLabel", {
        Size             = UDim2.new(.35, 0, 1, 0),
        Position         = UDim2.fromScale(.65, 0),
        BackgroundTransparency = 1,
        Text             = FormatVal(value),
        TextColor3       = T.ACCENT,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Right,
    }, topRow)

    -- track
    local trackBg = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = T.BORDER,
        BackgroundTransparency = .25,
    }, card)
    Corner(4, trackBg)

    local fill = New("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.SLIDER_FILL,
    }, trackBg)
    Corner(4, fill)
    Gradient({ T.ACCENT_GLOW, T.ACCENT }, 0, fill)

    local thumb = New("Frame", {
        Name             = "Thumb",
        Size             = UDim2.fromOffset(14, 14),
        AnchorPoint      = Vector2.new(.5, .5),
        BackgroundColor3 = T.WHITE,
        ZIndex           = 2,
    }, trackBg)
    Corner(7, thumb)
    Stroke(2, T.ACCENT, 0, thumb)

    local elem = { Value = value, IgnoreConfig = false }
    local dragging = false

    local function ApplySlider(v, silent)
        v = math.clamp(tonumber(string.format("%."..prec.."f", v)), minVal, maxVal)
        value = v
        elem.Value = v
        if flag then RUI.Flags[flag] = v end
        local pct = (v - minVal) / (maxVal - minVal)
        twFast(fill, { Size = UDim2.new(pct, 0, 1, 0) })
        thumb.Position = UDim2.new(pct, 0, .5, 0)
        valLbl.Text = FormatVal(v)
        if not silent and callback then task.spawn(callback, v) end
    end

    ApplySlider(value, true)

    local function CalcFromInput(pos)
        local ab = trackBg.AbsolutePosition
        local sz = trackBg.AbsoluteSize
        local rel = math.clamp(pos.X - ab.X, 0, sz.X)
        return minVal + (rel / sz.X) * (maxVal - minVal)
    end

    local c1 = trackBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ApplySlider(CalcFromInput(inp.Position))
        end
    end)

    local c2 = UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            ApplySlider(CalcFromInput(inp.Position))
        end
    end)

    local c3 = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging and onInputComplete then
                task.spawn(onInputComplete, value)
            end
            dragging = false
        end
    end)

    table.insert(connections, c1)
    table.insert(connections, c2)
    table.insert(connections, c3)

    function elem:UpdateName(s)    nameLbl.Text = s end
    function elem:SetVisiblity(v)  card.Visible = v end
    function elem:UpdateValue(v)   ApplySlider(v) end
    function elem:GetValue()       return value end

    if flag then
        RUI.Flags[flag] = value
        if window._components then
            window._components[flag] = {
                _type     = "Slider",
                _getValue = function() return value end,
                _setValue = function(v, s) ApplySlider(v, s) end,
            }
        end
    end

    return elem
end

-- ─── DROPDOWN ───────────────────────────────────────────
local function BuildDropdown(parent, opts, flag, window, connections)
    local name     = opts.Name     or "Dropdown"
    local multi    = opts.Multi    or false
    local search   = opts.Search   or false
    local required = opts.Required or false
    local options  = opts.Options  or {}
    local callback = opts.Callback
    local isOpen   = false

    -- parse default
    local selected = {}
    if multi then
        local def = opts.Default or {}
        for _, v in ipairs(def) do selected[v] = true end
    else
        local def = opts.Default
        if type(def) == "number" then
            selected = options[def] or (options[1] or "")
        elseif type(def) == "string" then
            selected = def
        else
            selected = options[1] or ""
        end
    end

    local function GetDisplay()
        if multi then
            local count = 0
            for _ in pairs(selected) do count += 1 end
            return count.." selected"
        end
        return tostring(selected)
    end

    local card = New("Frame", {
        Name             = "Dropdown_"..name,
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
        ClipsDescendants = false,
        ZIndex           = 10,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)

    local hdrBtn = New("TextButton", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 11,
    }, card)
    Pad(0, 0, 14, 14, hdrBtn)

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(.55, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 12,
    }, hdrBtn)

    local valLbl = New("TextLabel", {
        Size             = UDim2.new(.35, 0, 1, 0),
        Position         = UDim2.fromScale(.55, 0),
        BackgroundTransparency = 1,
        Text             = GetDisplay(),
        TextColor3       = T.ACCENT,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 12,
    }, hdrBtn)

    local arrowLbl = New("TextLabel", {
        Size             = UDim2.fromOffset(16, 42),
        Position         = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Text             = "▾",
        TextColor3       = T.DIM,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 12,
    }, card)

    -- panel
    local panel = New("Frame", {
        Name             = "Panel",
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.fromOffset(0, 46),
        BackgroundColor3 = T.ELEVATED,
        BackgroundTransparency = .08,
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 30,
    }, card)
    Corner(10, panel)
    Stroke(1, T.BORDER, .35, panel)

    -- optional search bar inside panel
    local searchBox
    if search then
        local sBar = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            ZIndex           = 31,
        }, panel)
        Pad(4, 4, 8, 8, sBar)

        searchBox = New("TextBox", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = T.SURFACE,
            BackgroundTransparency = .3,
            Text             = "",
            PlaceholderText  = "Search...",
            PlaceholderColor3 = T.DIM,
            TextColor3       = T.TEXT,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            ZIndex           = 32,
        }, sBar)
        Corner(7, searchBox)
    end

    local panelScroll = New("ScrollingFrame", {
        Size             = UDim2.new(1, 0, 1, search and -38 or 0),
        Position         = UDim2.fromOffset(0, search and 38 or 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.SCROLL,
        CanvasSize       = UDim2.fromOffset(0, 0),
        ZIndex           = 31,
    }, panel)

    local panelList = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex           = 32,
    }, panelScroll)
    Pad(4, 4, 4, 4, panelList)
    List(Enum.FillDirection.Vertical, 2, nil, nil, panelList)
    SyncCanvas(panelScroll)

    local optBtns = {}

    local function UpdateFlag()
        if flag then
            if multi then
                local arr = {}
                for k, v in pairs(selected) do if v then table.insert(arr, k) end end
                RUI.Flags[flag] = arr
            else
                RUI.Flags[flag] = selected
            end
        end
        valLbl.Text = GetDisplay()
    end

    local function RebuildOptions(filter)
        for _, b in ipairs(optBtns) do if b.Parent then b:Destroy() end end
        optBtns = {}
        filter = filter and filter:lower():gsub("^%s*(.-)%s*$","%1") or ""

        for _, optVal in ipairs(options) do
            if filter ~= "" and not tostring(optVal):lower():find(filter, 1, true) then
                continue
            end

            local optBtn = New("TextButton", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = T.ACCENT,
                BackgroundTransparency = 1,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 33,
            }, panelList)
            Corner(8, optBtn)
            Pad(0, 0, 10, 10, optBtn)

            local row = New("Frame", {
                Size             = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ZIndex           = 34,
            }, optBtn)
            List(Enum.FillDirection.Horizontal, 7,
                Enum.HorizontalAlignment.Left,
                Enum.VerticalAlignment.Center, row)

            local checkbox
            if multi then
                checkbox = New("Frame", {
                    Size             = UDim2.fromOffset(14, 14),
                    BackgroundColor3 = selected[optVal] and T.ACCENT or T.BORDER,
                    BackgroundTransparency = selected[optVal] and 0 or .3,
                    ZIndex           = 35,
                }, row)
                Corner(4, checkbox)
                Stroke(1, T.ACCENT, selected[optVal] and 0 or .5, checkbox)

                local ck = New("TextLabel", {
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text             = "✓",
                    TextColor3       = T.WHITE,
                    TextSize         = 9,
                    Font             = Enum.Font.GothamBold,
                    TextXAlignment   = Enum.TextXAlignment.Center,
                    TextTransparency = selected[optVal] and 0 or 1,
                    ZIndex           = 36,
                }, checkbox)
                checkbox._ckLbl = ck
            end

            local isSingle = not multi and optVal == selected
            local optLbl = New("TextLabel", {
                Size             = UDim2.new(1, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text             = tostring(optVal),
                TextColor3       = isSingle and T.ACCENT or T.TEXT,
                TextSize         = 12,
                Font             = isSingle and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 34,
            }, row)

            if isSingle then
                twFast(optBtn, { BackgroundTransparency = .85 })
            end

            optBtn.MouseEnter:Connect(function()
                twFast(optBtn, { BackgroundTransparency = .7 })
            end)
            optBtn.MouseLeave:Connect(function()
                local sel = multi and selected[optVal] or (optVal == selected)
                twFast(optBtn, { BackgroundTransparency = sel and .85 or 1 })
            end)

            optBtn.MouseButton1Click:Connect(function()
                if multi then
                    if required then
                        local count = 0
                        for _, v in pairs(selected) do if v then count += 1 end end
                        if count == 1 and selected[optVal] then return end
                    end
                    selected[optVal] = not selected[optVal]
                    local on = selected[optVal]
                    if checkbox then
                        twFast(checkbox, {
                            BackgroundColor3     = on and T.ACCENT or T.BORDER,
                            BackgroundTransparency = on and 0 or .3,
                        })
                        twFast(checkbox._ckLbl, { TextTransparency = on and 0 or 1 })
                    end
                    if callback then
                        local copy = {}
                        for k, v in pairs(selected) do copy[k] = v end
                        task.spawn(callback, copy)
                    end
                else
                    selected = optVal
                    -- refresh all
                    for _, ob in ipairs(optBtns) do
                        local lbl = ob:FindFirstChildOfClass("Frame")
                            and ob:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
                        if lbl then
                            local sel2 = lbl.Text == tostring(optVal)
                            lbl.TextColor3 = sel2 and T.ACCENT or T.TEXT
                            lbl.Font = sel2 and Enum.Font.GothamBold or Enum.Font.Gotham
                        end
                        twFast(ob, { BackgroundTransparency = (ob == optBtn) and .85 or 1 })
                    end
                    if callback then task.spawn(callback, optVal) end
                    -- close
                    hdrBtn:FireEvent("MouseButton1Click")
                end
                UpdateFlag()
            end)

            table.insert(optBtns, optBtn)
        end
        SyncCanvas(panelScroll)
    end

    RebuildOptions()
    UpdateFlag()

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            RebuildOptions(searchBox.Text)
        end)
    end

    local function TogglePanel()
        isOpen = not isOpen
        if isOpen then
            local h = math.min(#options * 38 + (search and 42 or 0) + 8, 200)
            panel.Visible = true
            twFast(arrowLbl, { Rotation = 180 })
            tw(panel, { Size = UDim2.new(1, 0, 0, h) }, .2)
            tw(card, { Size = UDim2.new(1, 0, 0, 42 + h + 4) }, .2)
        else
            twFast(arrowLbl, { Rotation = 0 })
            tw(card, { Size = UDim2.new(1, 0, 0, 42) }, .2)
            task.delay(.22, function() panel.Visible = false end)
        end
    end

    hdrBtn.MouseButton1Click:Connect(TogglePanel)

    local elem = {
        Value        = selected,
        IgnoreConfig = false,
        _optBtns     = optBtns,
    }

    function elem:UpdateName(s)      nameLbl.Text = s end
    function elem:SetVisiblity(v)    card.Visible = v end
    function elem:IsOption(s)
        for _, o in ipairs(options) do if o == s then return true end end
        return false
    end
    function elem:GetOptions()
        local t = {}
        for _, o in ipairs(options) do t[o] = multi and (selected[o] or false) or (selected == o) end
        return t
    end
    function elem:InsertOptions(arr)
        for _, v in ipairs(arr) do table.insert(options, v) end
        RebuildOptions()
    end
    function elem:RemoveOptions(arr)
        local rem = {}
        for _, v in ipairs(arr) do rem[v] = true end
        local new = {}
        for _, v in ipairs(options) do if not rem[v] then table.insert(new, v) end end
        options = new
        RebuildOptions()
    end
    function elem:ClearOptions() options = {} RebuildOptions() end
    function elem:UpdateSelection(v)
        if multi then
            selected = {}
            if type(v) == "table" then for _, k in ipairs(v) do selected[k] = true end end
        else
            selected = type(v) == "number" and (options[v] or "") or v
        end
        RebuildOptions()
        UpdateFlag()
    end

    if flag then
        UpdateFlag()
        if window._components then
            window._components[flag] = {
                _type     = "Dropdown",
                _getValue = function() return elem.Value end,
                _setValue = function(v, _) elem:UpdateSelection(v) end,
            }
        end
    end

    return elem
end

-- ─── INPUT ──────────────────────────────────────────────
local function BuildInput(parent, opts, flag, window, connections)
    local name     = opts.Name        or "Input"
    local value    = opts.Default     or ""
    local callback = opts.Callback

    local card = New("Frame", {
        Name             = "Input_"..name,
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)
    Pad(10, 10, 14, 14, card)
    List(Enum.FillDirection.Vertical, 6, nil, nil, card)

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, card)

    local boxBg = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = T.ELEVATED,
        BackgroundTransparency = .3,
    }, card)
    Corner(8, boxBg)
    Stroke(1, T.BORDER, .4, boxBg)
    Pad(0, 0, 10, 10, boxBg)

    local field = New("TextBox", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text             = value,
        PlaceholderText  = opts.Placeholder or "Enter value...",
        PlaceholderColor3 = T.DIM,
        TextColor3       = T.TEXT,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, boxBg)

    local elem = { Value = value, IgnoreConfig = false }

    field.Focused:Connect(function()    twFast(boxBg, { BackgroundTransparency = .1 }) end)
    field.FocusLost:Connect(function(enter)
        twFast(boxBg, { BackgroundTransparency = .3 })
        value = field.Text
        elem.Value = value
        if flag then RUI.Flags[flag] = value end
        if callback then task.spawn(callback, value, enter) end
    end)

    function elem:UpdateName(s)   nameLbl.Text = s end
    function elem:SetVisiblity(v) card.Visible = v end
    function elem:GetValue()      return value end
    function elem:SetValue(v)
        value = tostring(v)
        field.Text = value
        elem.Value = value
        if flag then RUI.Flags[flag] = value end
    end

    if flag then
        RUI.Flags[flag] = value
        if window._components then
            window._components[flag] = {
                _type     = "Input",
                _getValue = function() return value end,
                _setValue = function(v, _) elem:SetValue(v) end,
            }
        end
    end

    return elem
end

-- ─── KEYBIND ────────────────────────────────────────────
local function BuildKeybind(parent, opts, flag, window, connections)
    local name      = opts.Name      or "Keybind"
    local value     = opts.Default   or Enum.KeyCode.Unknown
    local blacklist = opts.Blacklist or {}
    local callback  = opts.Callback
    local onBinded  = opts.onBinded
    local onBindHeld = opts.onBindHeld
    local listening = false

    local blackSet = {}
    for _, k in ipairs(blacklist) do blackSet[k] = true end

    local card = New("TextButton", {
        Name             = "Keybind_"..name,
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
        Text             = "",
        AutoButtonColor  = false,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)
    HoverCard(card)
    Pad(0, 0, 14, 14, card)

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, card)

    local pill = New("Frame", {
        Name             = "KeyPill",
        Size             = UDim2.fromOffset(90, 26),
        Position         = UDim2.new(1, -90, .5, -13),
        BackgroundColor3 = T.ELEVATED,
        BackgroundTransparency = .3,
    }, card)
    Corner(6, pill)
    Stroke(1, T.ACCENT, .5, pill)

    local keyLbl = New("TextLabel", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text             = (value and value ~= Enum.KeyCode.Unknown) and value.Name or "None",
        TextColor3       = T.ACCENT,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
    }, pill)

    local elem = { Bind = value, IgnoreConfig = false }

    card.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        twFast(pill, { BackgroundTransparency = .1 })
    end)

    local kbConn = UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or not listening then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if inp.KeyCode == Enum.KeyCode.Escape then
            listening = false
            keyLbl.Text = elem.Bind and elem.Bind.Name or "None"
            twFast(pill, { BackgroundTransparency = .3 })
            return
        end
        if blackSet[inp.KeyCode] then return end

        value = inp.KeyCode
        elem.Bind = value
        if flag then RUI.Flags[flag] = value end
        keyLbl.Text = value.Name
        listening = false
        twFast(pill, { BackgroundTransparency = .3 })
        if onBinded then task.spawn(onBinded, value) end
    end)

    -- held detection
    local holdConn = UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or not elem.Bind then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if inp.KeyCode == elem.Bind then
            if callback then task.spawn(callback, elem.Bind) end
        end
    end)

    table.insert(connections, kbConn)
    table.insert(connections, holdConn)

    function elem:UpdateName(s)   nameLbl.Text = s end
    function elem:SetVisiblity(v) card.Visible = v end
    function elem:Unbind()
        value = nil
        elem.Bind = nil
        keyLbl.Text = "None"
        if flag then RUI.Flags[flag] = nil end
    end
    function elem:Bind2(k)
        value = k
        elem.Bind = k
        keyLbl.Text = k.Name
        if flag then RUI.Flags[flag] = k end
    end
    function elem:GetBind() return value end

    if flag then
        RUI.Flags[flag] = value
        if window._components then
            window._components[flag] = {
                _type     = "Keybind",
                _getValue = function() return value end,
                _setValue = function(v, _)
                    value = v
                    elem.Bind = v
                    keyLbl.Text = v and v.Name or "None"
                    if flag then RUI.Flags[flag] = v end
                end,
            }
        end
    end

    return elem
end

-- ─── COLORPICKER ────────────────────────────────────────
local function BuildColorpicker(parent, opts, flag, window, connections)
    local name     = opts.Name     or "Color"
    local value    = opts.Default  or Color3.fromRGB(255, 0, 0)
    local alpha    = opts.Alpha    or 0
    local callback = opts.Callback
    local isOpen   = false

    local card = New("Frame", {
        Name             = "ColorPicker_"..name,
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
        ClipsDescendants = false,
        ZIndex           = 10,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)

    local hdrBtn = New("TextButton", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 11,
    }, card)
    Pad(0, 0, 14, 14, hdrBtn)

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 12,
    }, hdrBtn)

    local swatch = New("Frame", {
        Name             = "Swatch",
        Size             = UDim2.fromOffset(28, 22),
        Position         = UDim2.new(1, -32, .5, -11),
        BackgroundColor3 = value,
        ZIndex           = 12,
    }, card)
    Corner(6, swatch)
    Stroke(1, T.BORDER, .3, swatch)

    -- popup
    local popup = New("Frame", {
        Name             = "Popup",
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.fromOffset(0, 46),
        BackgroundColor3 = T.ELEVATED,
        BackgroundTransparency = .08,
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 20,
    }, card)
    Corner(10, popup)
    Stroke(1, T.BORDER, .35, popup)

    local popInner = New("Frame", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex           = 21,
    }, popup)
    Pad(10, 10, 12, 12, popInner)
    List(Enum.FillDirection.Vertical, 8, nil, nil, popInner)

    local r = math.round(value.R * 255)
    local g = math.round(value.G * 255)
    local b = math.round(value.B * 255)
    local a = math.clamp(alpha, 0, 1)

    local sliders = {}

    local function MakeRGBRow(lbl, initVal, color)
        local row = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            ZIndex           = 22,
        }, popInner)
        List(Enum.FillDirection.Horizontal, 6,
            Enum.HorizontalAlignment.Left,
            Enum.VerticalAlignment.Center, row)

        New("TextLabel", {
            Size             = UDim2.fromOffset(14, 26),
            BackgroundTransparency = 1,
            Text             = lbl,
            TextColor3       = color,
            TextSize         = 11,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Center,
            ZIndex           = 23,
        }, row)

        local slTrack = New("Frame", {
            Size             = UDim2.new(1, -52, 0, 5),
            BackgroundColor3 = T.BORDER,
            BackgroundTransparency = .25,
            ZIndex           = 23,
        }, row)
        Corner(4, slTrack)

        local slFill = New("Frame", {
            Size             = UDim2.new(initVal/255, 0, 1, 0),
            BackgroundColor3 = color,
            ZIndex           = 24,
        }, slTrack)
        Corner(4, slFill)

        local valLbl2 = New("TextLabel", {
            Size             = UDim2.fromOffset(28, 26),
            BackgroundTransparency = 1,
            Text             = tostring(initVal),
            TextColor3       = T.TEXT,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Right,
            ZIndex           = 23,
        }, row)

        local cur = initVal
        local drag2 = false

        local function CalcRGB(pos)
            local ab = slTrack.AbsolutePosition
            local sz = slTrack.AbsoluteSize
            return math.clamp(math.round((pos.X - ab.X) / sz.X * 255), 0, 255)
        end

        local c1 = slTrack.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                drag2 = true
                cur = CalcRGB(inp.Position)
                slFill.Size = UDim2.new(cur/255, 0, 1, 0)
                valLbl2.Text = tostring(cur)
            end
        end)
        local c2 = UserInputService.InputChanged:Connect(function(inp)
            if not drag2 then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                cur = CalcRGB(inp.Position)
                slFill.Size = UDim2.new(cur/255, 0, 1, 0)
                valLbl2.Text = tostring(cur)
            end
        end)
        local c3 = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                drag2 = false
            end
        end)
        table.insert(connections, c1)
        table.insert(connections, c2)
        table.insert(connections, c3)

        return function() return cur end
    end

    local GetR = MakeRGBRow("R", r, Color3.fromRGB(255,80,80))
    local GetG = MakeRGBRow("G", g, Color3.fromRGB(80,210,80))
    local GetB = MakeRGBRow("B", b, Color3.fromRGB(80,140,255))

    -- alpha row
    local GetA
    do
        local row = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            ZIndex           = 22,
        }, popInner)
        List(Enum.FillDirection.Horizontal, 6,
            Enum.HorizontalAlignment.Left,
            Enum.VerticalAlignment.Center, row)

        New("TextLabel", {
            Size             = UDim2.fromOffset(14, 26),
            BackgroundTransparency = 1,
            Text             = "A",
            TextColor3       = T.MUTED,
            TextSize         = 11,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Center,
            ZIndex           = 23,
        }, row)

        local aTrack = New("Frame", {
            Size             = UDim2.new(1, -52, 0, 5),
            BackgroundColor3 = T.BORDER,
            BackgroundTransparency = .25,
            ZIndex           = 23,
        }, row)
        Corner(4, aTrack)

        local aFill = New("Frame", {
            Size             = UDim2.new(a, 0, 1, 0),
            BackgroundColor3 = T.MUTED,
            ZIndex           = 24,
        }, aTrack)
        Corner(4, aFill)

        local aLbl = New("TextLabel", {
            Size             = UDim2.fromOffset(28, 26),
            BackgroundTransparency = 1,
            Text             = string.format("%.2f", a),
            TextColor3       = T.TEXT,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Right,
            ZIndex           = 23,
        }, row)

        local cur = a
        local drag3 = false

        local function CalcA(pos)
            local ab = aTrack.AbsolutePosition
            local sz = aTrack.AbsoluteSize
            return math.clamp((pos.X - ab.X) / sz.X, 0, 1)
        end

        aTrack.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                drag3 = true
                cur = CalcA(inp.Position)
                aFill.Size = UDim2.new(cur, 0, 1, 0)
                aLbl.Text = string.format("%.2f", cur)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not drag3 then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                cur = CalcA(inp.Position)
                aFill.Size = UDim2.new(cur, 0, 1, 0)
                aLbl.Text = string.format("%.2f", cur)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                drag3 = false
            end
        end)

        GetA = function() return cur end
    end

    -- preview
    local preview = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = value,
        ZIndex           = 22,
    }, popInner)
    Corner(7, preview)

    -- live preview heartbeat
    local hbConn = RunService.Heartbeat:Connect(function()
        if isOpen then
            local c = Color3.fromRGB(GetR(), GetG(), GetB())
            preview.BackgroundColor3 = c
        end
    end)
    table.insert(connections, hbConn)

    -- apply button
    local applyBtn = New("TextButton", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = .25,
        Text             = "Apply",
        TextColor3       = T.WHITE,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
        ZIndex           = 22,
    }, popInner)
    Corner(8, applyBtn)

    local elem = { Color = value, Alpha = alpha, IgnoreConfig = false }

    applyBtn.MouseButton1Click:Connect(function()
        value = Color3.fromRGB(GetR(), GetG(), GetB())
        a = GetA()
        elem.Color = value
        elem.Alpha = a
        swatch.BackgroundColor3 = value
        if flag then RUI.Flags[flag] = value end
        if callback then task.spawn(callback, value, a) end
        isOpen = false
        tw(card, { Size = UDim2.new(1, 0, 0, 42) }, .2)
        task.delay(.22, function() popup.Visible = false end)
    end)

    hdrBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            popup.Visible = true
            tw(popup, { Size = UDim2.new(1, 0, 0, 200) }, .25)
            tw(card, { Size = UDim2.new(1, 0, 0, 42 + 200 + 4) }, .25)
        else
            tw(card, { Size = UDim2.new(1, 0, 0, 42) }, .2)
            task.delay(.22, function() popup.Visible = false end)
        end
    end)

    function elem:UpdateName(s)   nameLbl.Text = s end
    function elem:SetVisibility(v) card.Visible = v end
    function elem:SetColor(c)
        value = c
        elem.Color = c
        swatch.BackgroundColor3 = c
        if flag then RUI.Flags[flag] = c end
    end
    function elem:SetAlpha(v)
        a = v
        elem.Alpha = v
    end

    if flag then
        RUI.Flags[flag] = value
        if window._components then
            window._components[flag] = {
                _type     = "Colorpicker",
                _getValue = function() return value end,
                _setValue = function(v, _) elem:SetColor(v) end,
            }
        end
    end

    return elem
end

-- ─── SIMPLE ELEMENTS ────────────────────────────────────
local function BuildButton(parent, opts, connections)
    local name     = opts.Name     or "Button"
    local callback = opts.Callback

    local card = New("TextButton", {
        Name             = "Btn_"..name,
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.GLASS,
        BackgroundTransparency = .38,
        Text             = "",
        AutoButtonColor  = false,
    }, parent)
    Corner(10, card)
    Stroke(1, T.BORDER, .45, card)
    HoverCard(card)
    Pad(0, 0, 14, 14, card)

    local row = New("Frame", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, card)
    List(Enum.FillDirection.Horizontal, 8,
        Enum.HorizontalAlignment.Left,
        Enum.VerticalAlignment.Center, row)

    if opts.Icon then
        local img = New("ImageLabel", {
            Size             = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            ImageColor3      = T.ACCENT,
        }, row)
        SetIcon(img, opts.Icon, 16)
    end

    local nameLbl = New("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, row)

    New("TextLabel", {
        Size             = UDim2.fromOffset(16, 42),
        Position         = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Text             = "›",
        TextColor3       = T.DIM,
        TextSize         = 18,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
    }, card)

    card.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)

    local elem = {}
    function elem:UpdateName(s)   nameLbl.Text = s end
    function elem:SetVisiblity(v) card.Visible = v end
    return elem
end

local function BuildHeader(parent, opts)
    local text = opts.Name or opts.Text or ""
    local lbl = New("TextLabel", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text             = text:upper(),
        TextColor3       = T.ACCENT,
        TextSize         = 10,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LetterSpacing    = 2,
    }, parent)
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.BORDER,
        BackgroundTransparency = .35,
        BorderSizePixel  = 0,
    }, parent)
    local elem = {}
    function elem:UpdateName(s) lbl.Text = s:upper() end
    function elem:SetVisiblity(v) lbl.Visible = v end
    return elem
end

local function BuildParagraph(parent, opts)
    local card = GlassCard(parent)
    card.AutomaticSize = Enum.AutomaticSize.Y
    Pad(10, 10, 14, 14, card)
    List(Enum.FillDirection.Vertical, 4, nil, nil, card)

    local tLbl = New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = opts.Name or opts.Title or "",
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, card)

    local cLbl = New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = opts.Content or opts.Description or "",
        TextColor3       = T.MUTED,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, card)

    local elem = {}
    function elem:SetVisiblity(v) card.Visible = v end
    function elem:UpdateTitle(s)   tLbl.Text = s end
    function elem:UpdateContent(s) cLbl.Text = s end
    return elem
end

local function BuildLabel(parent, opts)
    local lbl = New("TextLabel", {
        Name             = "Label",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = opts.Name or opts.Text or "",
        TextColor3       = T.TEXT,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, parent)
    local elem = {}
    function elem:SetVisiblity(v) lbl.Visible = v end
    function elem:UpdateText(s)   lbl.Text = s end
    return elem
end

local function BuildSubLabel(parent, opts)
    local lbl = New("TextLabel", {
        Name             = "SubLabel",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = opts.Name or opts.Text or "",
        TextColor3       = T.MUTED,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, parent)
    local elem = {}
    function elem:SetVisiblity(v) lbl.Visible = v end
    function elem:UpdateText(s)   lbl.Text = s end
    return elem
end

local function BuildDivider(parent)
    return New("Frame", {
        Name             = "Divider",
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.BORDER,
        BackgroundTransparency = .3,
        BorderSizePixel  = 0,
    }, parent)
end

local function BuildSpacer(parent, opts)
    return New("Frame", {
        Name             = "Spacer",
        Size             = UDim2.new(1, 0, 0, opts and opts.Size or 12),
        BackgroundTransparency = 1,
    }, parent)
end

-- ════════════════════════════════════════════════════════
-- SECTION FACTORY
-- ════════════════════════════════════════════════════════
local function MakeSection(container, window, connections)
    local Section = {}

    -- ── build all components ──
    function Section:Toggle(opts, flag)
        return BuildToggle(container, opts, flag, window, connections)
    end
    function Section:Slider(opts, flag)
        return BuildSlider(container, opts, flag, window, connections)
    end
    function Section:Dropdown(opts, flag)
        return BuildDropdown(container, opts, flag, window, connections)
    end
    function Section:Input(opts, flag)
        return BuildInput(container, opts, flag, window, connections)
    end
    function Section:Keybind(opts, flag)
        return BuildKeybind(container, opts, flag, window, connections)
    end
    function Section:Colorpicker(opts, flag)
        return BuildColorpicker(container, opts, flag, window, connections)
    end
    function Section:Button(opts)
        return BuildButton(container, opts, connections)
    end
    function Section:Header(opts)
        return BuildHeader(container, opts)
    end
    function Section:Paragraph(opts)
        return BuildParagraph(container, opts)
    end
    function Section:Label(opts)
        return BuildLabel(container, opts)
    end
    function Section:SubLabel(opts)
        return BuildSubLabel(container, opts)
    end
    function Section:Divider()
        return BuildDivider(container)
    end
    function Section:Spacer(opts)
        return BuildSpacer(container, opts)
    end

    return Section
end

-- ════════════════════════════════════════════════════════
-- TAB FACTORY
-- ════════════════════════════════════════════════════════
local function MakeTab(sidebarList, contentArea, window, connections)
    local Tab = {}

    function Tab:Section(opts)
        opts = opts or {}
        local side = opts.Side or "Left"

        local scroll = New("ScrollingFrame", {
            Name             = "SectionScroll_"..tostring(math.random(1e6)),
            Size             = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.SCROLL,
            CanvasSize       = UDim2.fromOffset(0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible          = false,
            ZIndex           = 5,
        }, contentArea)

        local inner = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex           = 6,
        }, scroll)
        Pad(12, 14, 14, 14, inner)
        List(Enum.FillDirection.Vertical, 7, nil, nil, inner)
        SyncCanvas(scroll)

        -- Register as the tab's content frame
        if not Tab._scroll then
            Tab._scroll = scroll
            Tab._inner  = inner
            scroll.Visible = (#window._tabs == 0)
        end

        return MakeSection(inner, window, connections)
    end

    return Tab
end

-- ════════════════════════════════════════════════════════
-- WINDOW FACTORY
-- ════════════════════════════════════════════════════════
function RUI:Window(opts)
    opts = opts or {}

    local title      = opts.Title    or "RYEENZYXNZ"
    local subtitle   = opts.Subtitle or "Liquid Glass"
    local winSize    = opts.Size     or UDim2.fromOffset(868, 650)
    local dragStyle  = opts.DragStyle or 1   -- 1=header-only, 2=full
    local disabled   = opts.DisabledWindowControls or {}
    local showUser   = opts.ShowUserInfo ~= false
    local toggleKey  = opts.Keybind  or Enum.KeyCode.RightShift
    local acrylicBlur = opts.AcrylicBlur or false

    local disabledSet = {}
    for _, v in ipairs(disabled) do disabledSet[v] = true end

    local Window = {
        _components = {},
        _tabs       = {},
        _connections= {},
        _open       = true,
        Settings    = opts,
    }

    -- ── ScreenGui ──────────────────────────────────────
    local ScreenGui = New("ScreenGui", {
        Name             = "RYEENZYXNZ_V3_"..tostring(math.random(1e5)),
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 150,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

    -- ── UIScale for auto-scale ──────────────────────────
    local uiScale = New("UIScale", { Scale = 1 }, ScreenGui)
    ApplyAutoScale(uiScale)

    -- ── Main Frame ─────────────────────────────────────
    local Main = New("Frame", {
        Name             = "Main",
        Size             = winSize,
        Position         = UDim2.fromScale(.5, .5),
        AnchorPoint      = Vector2.new(.5, .5),
        BackgroundColor3 = T.BG,
        ClipsDescendants = true,
    }, ScreenGui)
    Corner(16, Main)
    Stroke(1, T.BORDER_B, .4, Main)

    -- acrylic look via UIBlur (if supported)
    if acrylicBlur then
        local blur = New("BlurEffect", { Size = 8 }, workspace.CurrentCamera)
        table.insert(Window._connections,
            RunService.RenderStepped:Connect(function()
                blur.Enabled = Window._open
            end))
        table.insert(Window._connections,
            Main.AncestryChanged:Connect(function()
                if not Main.Parent then blur:Destroy() end
            end))
    end

    -- top glow
    New("Frame", {
        Size             = UDim2.new(.65, 0, 0, 1),
        Position         = UDim2.new(.175, 0, 0, 0),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = .3,
        BorderSizePixel  = 0,
        ZIndex           = 20,
    }, Main)

    -- ── HEADER ─────────────────────────────────────────
    local Header = New("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = T.SURFACE,
        BackgroundTransparency = .35,
        ZIndex           = 15,
    }, Main)
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.BORDER,
        BackgroundTransparency = .3,
        BorderSizePixel  = 0,
        ZIndex           = 16,
    }, Header)

    local HeaderInner = New("Frame", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex           = 17,
    }, Header)
    Pad(0, 0, 14, 14, HeaderInner)
    List(Enum.FillDirection.Horizontal, 10,
        Enum.HorizontalAlignment.Left,
        Enum.VerticalAlignment.Center, HeaderInner)

    -- Logo space
    local LogoFrame = New("Frame", {
        Size             = UDim2.fromOffset(32, 32),
        BackgroundColor3 = T.ELEVATED,
        BackgroundTransparency = .5,
        ZIndex           = 18,
    }, HeaderInner)
    Corner(8, LogoFrame)

    New("TextLabel", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text             = title:sub(1, 1):upper(),
        TextColor3       = T.ACCENT,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 19,
    }, LogoFrame)

    -- Title block
    local TitleBlock = New("Frame", {
        Size             = UDim2.new(0, 200, 1, 0),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ZIndex           = 18,
    }, HeaderInner)
    List(Enum.FillDirection.Vertical, 0, nil,
        Enum.VerticalAlignment.Center, TitleBlock)

    local titleLbl = New("TextLabel", {
        Size             = UDim2.new(0, 0, 0, 20),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.TEXT,
        TextSize         = 15,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 19,
    }, TitleBlock)

    local subtitleLbl = New("TextLabel", {
        Size             = UDim2.new(0, 0, 0, 14),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text             = subtitle,
        TextColor3       = T.MUTED,
        TextSize         = 10,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 19,
    }, TitleBlock)

    -- Spacer
    New("Frame", {
        Size             = UDim2.new(1, -560, 1, 0),
        BackgroundTransparency = 1,
        ZIndex           = 18,
    }, HeaderInner)

    -- User info
    if showUser then
        local userInfo = New("TextLabel", {
            Size             = UDim2.new(0, 0, 0, 18),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text             = LocalPlayer.Name,
            TextColor3       = T.MUTED,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 18,
        }, HeaderInner)
    end

    -- Header control buttons
    local function MakeHBtn(label, color, zIndex)
        local btn = New("TextButton", {
            Size             = UDim2.fromOffset(28, 28),
            BackgroundColor3 = T.ELEVATED,
            BackgroundTransparency = .3,
            Text             = label,
            TextColor3       = color or T.MUTED,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            AutoButtonColor  = false,
            ZIndex           = zIndex or 18,
        }, HeaderInner)
        Corner(7, btn)
        btn.MouseEnter:Connect(function()
            twFast(btn, { BackgroundTransparency = .1 })
        end)
        btn.MouseLeave:Connect(function()
            twFast(btn, { BackgroundTransparency = .3 })
        end)
        return btn
    end

    local minimized = false
    if not disabledSet["Minimize"] then
        local minBtn = MakeHBtn("─", T.MUTED)
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                tw(Main, { Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 54) }, .3)
            else
                tw(Main, { Size = winSize }, .3)
            end
        end)
    end

    if not disabledSet["Exit"] then
        local exitBtn = MakeHBtn("✕", T.ERROR)
        exitBtn.MouseButton1Click:Connect(function()
            Window:Unload()
        end)
    end

    -- drag
    if dragStyle == 2 then
        MakeDraggable(Main, Main, Window._connections)
    else
        MakeDraggable(Header, Main, Window._connections)
    end

    -- ── BODY ───────────────────────────────────────────
    local Body = New("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, 0, 1, -54),
        Position         = UDim2.fromOffset(0, 54),
        BackgroundTransparency = 1,
        ZIndex           = 5,
    }, Main)

    -- ── SIDEBAR ────────────────────────────────────────
    local Sidebar = New("ScrollingFrame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = T.PANEL,
        BackgroundTransparency = .5,
        BorderSizePixel  = 0,
        ScrollBarThickness = 0,
        CanvasSize       = UDim2.fromOffset(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex           = 6,
    }, Body)

    New("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.BORDER,
        BackgroundTransparency = .3,
        BorderSizePixel  = 0,
        ZIndex           = 7,
    }, Sidebar)

    local SidebarList = New("Frame", {
        Name             = "SidebarList",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex           = 7,
    }, Sidebar)
    Pad(12, 12, 10, 10, SidebarList)
    List(Enum.FillDirection.Vertical, 3, nil, nil, SidebarList)
    SyncCanvas(Sidebar)

    -- sidebar search box
    local SidebarSearch = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.ELEVATED,
        BackgroundTransparency = .3,
        ZIndex           = 8,
    }, SidebarList)
    Corner(9, SidebarSearch)
    Stroke(1, T.BORDER, .4, SidebarSearch)
    Pad(0, 0, 8, 8, SidebarSearch)

    List(Enum.FillDirection.Horizontal, 5,
        Enum.HorizontalAlignment.Left,
        Enum.VerticalAlignment.Center, SidebarSearch)

    New("TextLabel", {
        Size             = UDim2.fromOffset(14, 20),
        BackgroundTransparency = 1,
        Text             = "⌕",
        TextColor3       = T.MUTED,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 9,
    }, SidebarSearch)

    local SearchField = New("TextBox", {
        Size             = UDim2.new(1, -22, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        PlaceholderText  = "Search...",
        PlaceholderColor3 = T.DIM,
        TextColor3       = T.TEXT,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 9,
    }, SidebarSearch)

    -- ── CONTENT AREA ───────────────────────────────────
    local ContentArea = New("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -200, 1, 0),
        Position         = UDim2.fromOffset(200, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 6,
    }, Body)

    -- ── SEARCH LOGIC ───────────────────────────────────
    local searchIndex = {}  -- { frame, title }

    local function RegisterSearch(frame, title)
        table.insert(searchIndex, { frame = frame, title = title or "" })
    end

    SearchField:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchField.Text:lower():gsub("^%s*(.-)%s*$", "%1")
        for _, e in ipairs(searchIndex) do
            if e.frame and e.frame.Parent then
                e.frame.Visible = q == "" or e.title:lower():find(q, 1, true) ~= nil
            end
        end
    end)

    -- ── GLOBAL SETTINGS (Header extras) ────────────────
    function Window:AddGlobalSetting(opts)
        -- mounts a small component (Toggle/Dropdown) into the header row
        -- for simplicity, a toggle pill
        if not opts then return end
        local gpill = New("TextButton", {
            Size             = UDim2.fromOffset(100, 28),
            BackgroundColor3 = T.ELEVATED,
            BackgroundTransparency = .3,
            Text             = opts.Name or "Setting",
            TextColor3       = T.TEXT,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            AutoButtonColor  = false,
            ZIndex           = 18,
        }, HeaderInner)
        Corner(7, gpill)
        Stroke(1, T.BORDER, .4, gpill)

        local state = opts.Default or false
        local function ApplyGlobal(v)
            state = v
            twFast(gpill, {
                BackgroundColor3 = v and T.ACCENT_DIM or T.ELEVATED,
                BackgroundTransparency = v and .2 or .3,
            })
            gpill.TextColor3 = v and T.WHITE or T.TEXT
            if opts.Callback then task.spawn(opts.Callback, v) end
        end
        ApplyGlobal(state)

        gpill.MouseButton1Click:Connect(function()
            ApplyGlobal(not state)
        end)
    end

    -- ── TAB GROUP ──────────────────────────────────────
    function Window:TabGroup()
        local TabGroup = {}
        local tabs = {}
        local activeTab = nil

        -- separator label
        local sepLbl = New("TextLabel", {
            Name             = "TabGroupSep",
            Size             = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text             = "NAVIGATION",
            TextColor3       = T.DIM,
            TextSize         = 9,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LetterSpacing    = 2,
            ZIndex           = 8,
        }, SidebarList)
        Pad(6, 0, 4, 0, sepLbl)

        function TabGroup:Tab(tabOpts)
            tabOpts = tabOpts or {}
            local tabName = tabOpts.Name  or ("Tab "..tostring(#tabs + 1))
            local tabIcon = tabOpts.Icon

            local Tab = {}
            Tab._scroll = nil

            -- sidebar button
            local tabBtn = New("TextButton", {
                Name             = "TabBtn_"..tabName,
                Size             = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = T.ELEVATED,
                BackgroundTransparency = 1,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 8,
            }, SidebarList)
            Corner(10, tabBtn)
            Pad(0, 0, 10, 10, tabBtn)

            local btnRow = New("Frame", {
                Size             = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ZIndex           = 9,
            }, tabBtn)
            List(Enum.FillDirection.Horizontal, 8,
                Enum.HorizontalAlignment.Left,
                Enum.VerticalAlignment.Center, btnRow)

            -- active bar
            local activeBar = New("Frame", {
                Name             = "ActiveBar",
                Size             = UDim2.new(0, 3, .55, 0),
                Position         = UDim2.new(0, 0, .225, 0),
                BackgroundColor3 = T.ACCENT,
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                ZIndex           = 10,
            }, tabBtn)
            Corner(3, activeBar)

            -- icon
            local iconImg = New("ImageLabel", {
                Size             = UDim2.fromOffset(16, 16),
                BackgroundTransparency = 1,
                ImageColor3      = T.MUTED,
                ZIndex           = 10,
            }, btnRow)
            SetIcon(iconImg, tabIcon, 16)
            if not tabIcon then iconImg.Visible = false end

            local tabLbl = New("TextLabel", {
                Size             = UDim2.new(1, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text             = tabName,
                TextColor3       = T.MUTED,
                TextSize         = 13,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 10,
            }, btnRow)

            local function Activate()
                -- deactivate all
                for _, t in ipairs(tabs) do
                    if t._scroll then t._scroll.Visible = false end
                    twFast(t._btn,      { BackgroundTransparency = 1 })
                    twFast(t._activeBar,{ BackgroundTransparency = 1 })
                    twFast(t._iconImg,  { ImageColor3 = T.MUTED })
                    twFast(t._label,    { TextColor3  = T.MUTED })
                    t._label.Font = Enum.Font.Gotham
                end
                -- activate this
                if Tab._scroll then Tab._scroll.Visible = true end
                twFast(tabBtn,    { BackgroundTransparency = .75 })
                twFast(activeBar, { BackgroundTransparency = 0 })
                twFast(iconImg,   { ImageColor3 = T.ACCENT })
                twFast(tabLbl,    { TextColor3  = T.TEXT })
                tabLbl.Font = Enum.Font.GothamBold
                activeTab = Tab
            end

            Tab._btn       = tabBtn
            Tab._activeBar = activeBar
            Tab._iconImg   = iconImg
            Tab._label     = tabLbl
            Tab.Activate   = Activate

            tabBtn.MouseButton1Click:Connect(Activate)
            tabBtn.MouseEnter:Connect(function()
                if activeTab ~= Tab then twFast(tabBtn, { BackgroundTransparency = .88 }) end
            end)
            tabBtn.MouseLeave:Connect(function()
                if activeTab ~= Tab then twFast(tabBtn, { BackgroundTransparency = 1 }) end
            end)

            -- Tab:Section builds the scroll frame lazily
            local origSection = Tab.Section or nil

            function Tab:Section(secOpts)
                secOpts = secOpts or {}
                local scroll = New("ScrollingFrame", {
                    Name             = "Scroll_"..tabName.."_"..tostring(#tabs+1),
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = T.SCROLL,
                    CanvasSize       = UDim2.fromOffset(0, 0),
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Visible          = false,
                    ZIndex           = 7,
                }, ContentArea)
                scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    -- keep scroll visible when tab is active
                end)

                local inner = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ZIndex           = 8,
                }, scroll)
                Pad(14, 16, 16, 16, inner)
                List(Enum.FillDirection.Vertical, 8, nil, nil, inner)
                SyncCanvas(scroll)

                -- first Section of a tab owns the scroll
                if not Tab._scroll then
                    Tab._scroll = scroll
                    Tab._inner  = inner
                    if activeTab == Tab or activeTab == nil then
                        scroll.Visible = true
                    end
                else
                    -- additional sections: use the same scroll but split into columns
                    -- for MacLib's Left/Right behavior, we just append to inner
                    -- (full two-column layout omitted; single column is fully functional)
                end

                local section = MakeSection(inner, Window, Window._connections)

                -- wrap component builders to also register in search
                local origBuilders = {
                    "Toggle","Slider","Dropdown","Input","Keybind","Colorpicker",
                    "Button","Header","Paragraph","Label","SubLabel","Divider","Spacer"
                }
                for _, bname in ipairs(origBuilders) do
                    local orig = section[bname]
                    if orig then
                        section[bname] = function(self, opts2, flag)
                            local result = orig(self, opts2, flag)
                            if opts2 and (opts2.Name or opts2.Title) then
                                -- register last added child for search
                                local lastChild = inner:GetChildren()[#inner:GetChildren()]
                                if lastChild then
                                    RegisterSearch(lastChild, opts2.Name or opts2.Title or "")
                                end
                            end
                            return result
                        end
                    end
                end

                return section
            end

            table.insert(tabs, Tab)
            table.insert(Window._tabs, Tab)

            if #tabs == 1 then
                Activate()
            end

            return Tab
        end

        return TabGroup
    end

    -- ── NOTIFICATIONS ──────────────────────────────────
    function Window:Notify(opts)
        return CreateNotif(opts, Window._connections)
    end

    -- ── DIALOG ─────────────────────────────────────────
    function Window:Dialog(opts)
        CreateDialog(ScreenGui, opts, Window._connections)
    end

    -- ── CONFIG API ─────────────────────────────────────
    local folder = RUI._folder

    function Window:SetFolder(f)
        folder = f
        RUI._folder = f
    end

    function Window:SaveConfig(name)
        name = name or "default"
        local data = {}
        for flag, comp in pairs(Window._components) do
            if comp._getValue then
                data[flag] = CFG.Encode(comp._getValue())
            end
        end
        CFG.Write(folder, name, data)
    end

    function Window:LoadConfig(name)
        name = name or "default"
        local data = CFG.Read(folder, name)
        if not data then
            warn("[RUI] Config not found:", folder.."/"..name..".json")
            return
        end
        for flag, raw in pairs(data) do
            local comp = Window._components[flag]
            if comp and comp._setValue then
                local decoded = CFG.Decode(raw)
                if comp._type == "Keybind" and type(decoded) == "string" then
                    local ok, kc = pcall(function() return Enum.KeyCode[decoded] end)
                    decoded = ok and kc or Enum.KeyCode.Unknown
                elseif comp._type == "Colorpicker" and type(decoded) == "table" then
                    decoded = Color3.new(decoded.R or 0, decoded.G or 0, decoded.B or 0)
                end
                pcall(comp._setValue, decoded, true)
            end
        end
    end

    function Window:RefreshConfigList()
        return CFG.List(folder)
    end

    function Window:LoadAutoLoadConfig()
        self:LoadConfig("autoload")
    end

    -- ── WINDOW CONTROLS ────────────────────────────────
    function Window:Unload()
        -- fire onUnloaded
        if self._onUnloaded then pcall(self._onUnloaded) end
        -- disconnect
        for _, c in ipairs(self._connections) do
            if c then pcall(c.Disconnect, c) end
        end
        self._connections = {}
        tw(Main, { Size = UDim2.fromOffset(0, 0) }, .3)
        task.delay(.35, function()
            if ScreenGui and ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end)
    end

    function Window:onUnloaded(fn)
        self._onUnloaded = fn
    end

    function Window:SetState(visible)
        Window._open = visible
        if visible then
            Main.Visible = true
            twSpring(Main, { Size = winSize }, .5)
        else
            tw(Main, { Size = UDim2.fromOffset(0, 0) }, .3)
            task.delay(.35, function() Main.Visible = false end)
        end
    end

    function Window:GetState() return Window._open end

    function Window:SetNotificationsState(v) NotifContainer.Visible = v end
    function Window:GetNotificationsState()  return NotifContainer and NotifContainer.Visible end

    function Window:SetAcrylicBlurState(v)
        -- toggles blur if it was created
        for _, c in ipairs(workspace.CurrentCamera:GetChildren()) do
            if c:IsA("BlurEffect") then c.Enabled = v end
        end
    end
    function Window:GetAcrylicBlurState() return acrylicBlur end

    function Window:SetUserInfoState(v)
        -- find user info label in header
        for _, c in ipairs(HeaderInner:GetChildren()) do
            if c:IsA("TextLabel") and c.Text == LocalPlayer.Name then
                c.Visible = v
            end
        end
    end
    function Window:GetUserInfoState() return showUser end

    function Window:SetKeybind(key) toggleKey = key end

    function Window:SetSize(s)
        winSize = s
        Main.Size = s
    end
    function Window:GetSize() return Main.Size end

    function Window:SetScale(s)
        uiScale.Scale = s
    end
    function Window:GetScale() return uiScale.Scale end

    function Window:UpdateTitle(s)    titleLbl.Text    = s end
    function Window:UpdateSubtitle(s) subtitleLbl.Text = s end

    -- toggle key listener
    local tkConn = UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == toggleKey then
            Window:SetState(not Window._open)
        end
    end)
    table.insert(Window._connections, tkConn)

    -- open animation
    Main.Size = UDim2.fromOffset(0, 0)
    twSpring(Main, { Size = winSize }, .55)

    return Window
end

-- ════════════════════════════════════════════════════════
-- GLOBAL API METHODS
-- ════════════════════════════════════════════════════════
function RUI:SetFolder(f) self._folder = f end

function RUI:SaveConfig(path)
    local data = {}
    for flag, _ in pairs(self.Flags) do
        data[flag] = CFG.Encode(self.Flags[flag])
    end
    CFG.Write(self._folder, path or "default", data)
end

function RUI:LoadConfig(path)
    local data = CFG.Read(self._folder, path or "default")
    if data then
        for k, v in pairs(data) do
            self.Flags[k] = CFG.Decode(v)
        end
    end
end

function RUI:RefreshConfigList()
    return CFG.List(self._folder)
end

function RUI:LoadAutoLoadConfig()
    self:LoadConfig("autoload")
end

function RUI:SetLucideModule(m)
    self._lucide = m
end

function RUI:AddIcons(tbl)
    for k, v in pairs(tbl) do self._icons[k] = v end
end

function RUI:SetTheme(tbl)
    for k, v in pairs(tbl) do T[k] = v end
end

function RUI:Demo()
    local W = self:Window({
        Title    = "RYEENZYXNZ UI V3",
        Subtitle = "Demo Window",
        Keybind  = Enum.KeyCode.RightShift,
    })
    local TG = W:TabGroup()

    local HomeTab = TG:Tab({ Name = "Home", Icon = "home" })
    local HS = HomeTab:Section({ Side = "Left" })
    HS:Paragraph({ Name = "Welcome", Content = "RYEENZYXNZ UI V3 — Demo. All components shown below." })
    HS:Toggle({ Name = "Auto Farm", Default = false, Callback = function(v) W:Notify({ Title="Toggle", Description="Auto Farm: "..tostring(v) }) end }, "DemoToggle")
    HS:Slider({ Name = "Walk Speed", Default = 16, Minimum = 0, Maximum = 250, DisplayMethod = "Value", Callback = function(v) W:Notify({ Title="Slider", Description="Speed: "..v }) end }, "DemoSlider")
    HS:Button({ Name = "Click Me", Callback = function() W:Notify({ Title="Button", Description="Clicked!" }) end })
    HS:Dropdown({ Name = "Mode", Options={"Easy","Normal","Hard"}, Default=1, Callback = function(v) print("Mode:", v) end }, "DemoDD")
    HS:Input({ Name = "Name", Placeholder = "Enter your name..." }, "DemoInput")

    local SettingsTab = TG:Tab({ Name = "Settings", Icon = "settings" })
    local SS = SettingsTab:Section({ Side = "Left" })
    SS:Keybind({ Name = "Toggle Key", Default = Enum.KeyCode.RightShift }, "DemoKey")
    SS:Colorpicker({ Name = "Accent", Default = Color3.fromRGB(120,100,255) }, "DemoColor")
    SS:Divider()
    SS:Label({ Name = "Version: 3.0.0" })

    W:Notify({ Title = "RYEENZYXNZ UI V3", Description = "Demo loaded successfully!", Lifetime = 4 })
    return W
end

return RUI
