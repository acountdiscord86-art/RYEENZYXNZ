--[[
    RYEENZYXNZ UI Library V2.0
    Original Liquid Glass Roblox UI framework
    Runtime-generated UI: no uploaded UI image required.

    Features:
      Window / draggable / responsive scaling / open-close floating button
      Sidebar tabs / sections / search
      Button / Toggle / Slider / Dropdown / MultiDropdown
      Input / Keybind / ColorPicker / Paragraph / Label / Divider
      Notifications / Dialog / Tooltips
      Theme system / Lucide-style icon name support
      Config save/load/delete using executor filesystem APIs when available
      Mobile-friendly touch sizing

    Example:
      local RYEENZYXNZ = loadstring(game:HttpGet("YOUR_RAW_MAIN_LUA_URL"))()
      local Window = RYEENZYXNZ:CreateWindow({Title="RYEENZYXNZ", Subtitle="Liquid Glass"})
]]

local RYEENZYXNZ = {}
RYEENZYXNZ.__index = RYEENZYXNZ
RYEENZYXNZ.Version = "2.0.0"
RYEENZYXNZ.Name = "RYEENZYXNZ"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function pick(parent, className, props)
    local o = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() o[k] = v end)
        end
    end
    o.Parent = parent
    return o
end

local function corner(parent, radius)
    return pick(parent, "UICorner", {CornerRadius = UDim.new(0, radius or 10)})
end

local function stroke(parent, color, transparency, thickness)
    return pick(parent, "UIStroke", {
        Color = color or Color3.fromRGB(255,255,255),
        Transparency = transparency == nil and 0.82 or transparency,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function padding(parent, l, r, t, b)
    return pick(parent, "UIPadding", {
        PaddingLeft = UDim.new(0,l or 0), PaddingRight = UDim.new(0,r or l or 0),
        PaddingTop = UDim.new(0,t or l or 0), PaddingBottom = UDim.new(0,b or t or l or 0),
    })
end

local function list(parent, direction, gap, sortOrder)
    return pick(parent, "UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, gap or 8),
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })
end

local function tween(obj, time, props, style, direction)
    local ok, tw = pcall(function()
        return TweenService:Create(obj, TweenInfo.new(time or .18, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
    end)
    if ok and tw then tw:Play() end
    return tw
end

local function clamp(n,a,b) return math.max(a, math.min(b,n)) end
local function lerp(a,b,t) return a + (b-a)*t end
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local function safeCallback(fn, ...)
    if type(fn) == "function" then
        local args = table.pack(...)
        task.spawn(function() pcall(function() fn(table.unpack(args,1,args.n)) end) end)
    end
end

local function isFileAPI()
    return type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function"
end

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for k,v in pairs(value) do out[k] = deepCopy(v) end
    return out
end

local Theme = {
    Background = rgb(7,10,18),
    Surface = rgb(14,18,29),
    Surface2 = rgb(20,25,39),
    Surface3 = rgb(27,33,51),
    Text = rgb(242,246,255),
    SubText = rgb(145,155,178),
    Muted = rgb(94,104,128),
    Accent = rgb(112,92,255),
    Accent2 = rgb(71,164,255),
    Success = rgb(67,211,145),
    Warning = rgb(255,184,77),
    Error = rgb(255,88,105),
    Glass = 0.13,
    Border = 0.76,
    Radius = 12,
}

local Themes = {
    Dark = deepCopy(Theme),
    Midnight = {
        Background=rgb(4,6,12),Surface=rgb(10,13,22),Surface2=rgb(16,20,32),Surface3=rgb(23,29,46),
        Text=rgb(245,247,255),SubText=rgb(142,151,175),Muted=rgb(88,98,122),Accent=rgb(92,112,255),Accent2=rgb(53,190,255),
        Success=rgb(67,211,145),Warning=rgb(255,184,77),Error=rgb(255,88,105),Glass=.12,Border=.78,Radius=12,
    },
    Violet = {
        Background=rgb(9,6,17),Surface=rgb(17,11,28),Surface2=rgb(26,17,42),Surface3=rgb(37,24,58),
        Text=rgb(248,245,255),SubText=rgb(165,151,185),Muted=rgb(108,91,128),Accent=rgb(170,92,255),Accent2=rgb(97,122,255),
        Success=rgb(74,214,151),Warning=rgb(255,184,77),Error=rgb(255,91,111),Glass=.13,Border=.76,Radius=13,
    },
}

-- Lucide-style icon name support. The library accepts a Lucide name and resolves it
-- to a Roblox image asset when available. Unknown names safely fall back to no icon.
local Lucide = {
    home="rbxassetid://10734950309", settings="rbxassetid://10734950387", user="rbxassetid://10747373176",
    users="rbxassetid://10747373214", search="rbxassetid://10747373294", menu="rbxassetid://10747373251",
    x="rbxassetid://10747373401", check="rbxassetid://10747373148", plus="rbxassetid://10734896211",
    minus="rbxassetid://10734896080", chevronright="rbxassetid://10734895356", chevrondown="rbxassetid://10734895142",
    chevronup="rbxassetid://10734895279", arrowleft="rbxassetid://10734894253", arrowright="rbxassetid://10734894448",
    play="rbxassetid://10734949036", pause="rbxassetid://10734948750", refresh="rbxassetid://10734950230",
    save="rbxassetid://10734950605", trash="rbxassetid://10734951713", copy="rbxassetid://10734903927",
    lock="rbxassetid://10734946122", unlock="rbxassetid://10734952035", eye="rbxassetid://10734917239",
    eyeoff="rbxassetid://10734917455", palette="rbxassetid://10734948438", monitor="rbxassetid://10734947642",
    smartphone="rbxassetid://10734951065", gamepad="rbxassetid://10734922267", globe="rbxassetid://10734924701",
    zap="rbxassetid://10734952272", star="rbxassetid://10734951226", heart="rbxassetid://10734926621",
    info="rbxassetid://10734942387", circlealert="rbxassetid://10734903962", bell="rbxassetid://10734892656",
    slidershorizontal="rbxassetid://10734950860", wrench="rbxassetid://10734952149", code="rbxassetid://10734905823",
    folder="rbxassetid://10734920479", file="rbxassetid://10734918359", keyboard="rbxassetid://10734945060",
    mouse="rbxassetid://10734947821", volume2="rbxassetid://10734951807", camera="rbxassetid://10734901672",
    sun="rbxassetid://10734951491", moon="rbxassetid://10734947590", cloud="rbxassetid://10734903365",
}

function RYEENZYXNZ:GetIcon(name)
    if type(name) ~= "string" then return "" end
    local key = string.lower(name):gsub("[^%w]", "")
    return Lucide[key] or (string.match(name,"^rbxassetid://") and name) or ""
end

function RYEENZYXNZ:SetIcon(name, assetId)
    Lucide[string.lower(name):gsub("[^%w]", "")] = assetId
end

local function icon(parent, name, size, transparency)
    local id = RYEENZYXNZ:GetIcon(name)
    local img = pick(parent, "ImageLabel", {
        BackgroundTransparency=1, Size=UDim2.fromOffset(size or 18,size or 18),
        Image=id, ImageTransparency=transparency or 0, ScaleType=Enum.ScaleType.Fit,
    })
    return img
end

function RYEENZYXNZ.new()
    local self = setmetatable({}, RYEENZYXNZ)
    self.Theme = deepCopy(Theme)
    self.Windows = {}
    self._connections = {}
    self._destroyed = false
    return self
end

function RYEENZYXNZ:SetTheme(theme)
    if type(theme)=="string" and Themes[theme] then self.Theme=deepCopy(Themes[theme])
    elseif type(theme)=="table" then
        for k,v in pairs(theme) do self.Theme[k]=v end
    end
    for _,window in ipairs(self.Windows) do
        if window.ApplyTheme then window:ApplyTheme() end
    end
end

function RYEENZYXNZ:RegisterTheme(name, data)
    if type(name)=="string" and type(data)=="table" then Themes[name]=deepCopy(data) end
end

function RYEENZYXNZ:Notify(data)
    local target = self.Windows[1]
    if target and target.Notify then return target:Notify(data) end
end

function RYEENZYXNZ:CreateWindow(options)
    options = options or {}
    local W = {}
    W.__index = W
    W.Library = self
    W.Title = options.Title or "RYEENZYXNZ"
    W.Subtitle = options.Subtitle or "Liquid Glass"
    W.Size = options.Size or UDim2.fromOffset(860,560)
    W.MinSize = options.MinSize or Vector2.new(520,360)
    W.AutoScale = options.AutoScale ~= false
    W.Opened = options.Opened ~= false
    W.SearchEnabled = options.Search ~= false
    W.Tabs = {}
    W.ActiveTab = nil
    W.Config = {}
    W._connections = {}
    W._layoutOrder = 0
    W._dragging = false
    W._dragInput = nil
    W._dragStart = nil
    W._startPos = nil

    table.insert(self.Windows, W)

    local gui = pick(CoreGui, "ScreenGui", {Name="RYEENZYXNZ_"..tostring(math.random(1000,9999)), ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    W.Gui = gui

    local scale = pick(gui, "UIScale", {Scale=1})
    W.Scale = scale

    local shadow = pick(gui, "Frame", {Name="Shadow", BackgroundColor3=rgb(0,0,0), BackgroundTransparency=.45, BorderSizePixel=0, Position=UDim2.new(.5,0,.5,10), AnchorPoint=Vector2.new(.5,.5), Size=W.Size + UDim2.fromOffset(22,22), ZIndex=0})
    corner(shadow, 18)
    W.Shadow = shadow

    local main = pick(gui, "Frame", {Name="Window", BackgroundColor3=self.Theme.Background, BackgroundTransparency=self.Theme.Glass, BorderSizePixel=0, Position=UDim2.fromScale(.5,.5), AnchorPoint=Vector2.new(.5,.5), Size=W.Size, ZIndex=2})
    corner(main, self.Theme.Radius+4); stroke(main, rgb(255,255,255), self.Theme.Border, 1)
    W.Main = main

    local grad = pick(main, "UIGradient", {Color=ColorSequence.new({ColorSequenceKeypoint.new(0,self.Theme.Surface),ColorSequenceKeypoint.new(1,self.Theme.Background)}), Rotation=135, Transparency=NumberSequence.new(0.08)})
    W.Gradient=grad

    local top = pick(main,"Frame",{Name="Topbar",BackgroundTransparency=1,Size=UDim2.new(1,0,0,68),ZIndex=4})
    padding(top,18,14,10,8)
    W.Topbar=top
    local title = pick(top,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-170,0,27),Font=Enum.Font.GothamBold,Text=W.Title,TextColor3=self.Theme.Text,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5})
    local subtitle = pick(top,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(1,27),Size=UDim2.new(1,-170,0,20),Font=Enum.Font.Gotham,Text=W.Subtitle,TextColor3=self.Theme.SubText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5})
    W.TitleLabel=title; W.SubtitleLabel=subtitle

    local controls = pick(top,"Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(138,44),ZIndex=6})
    local controlList=list(controls,Enum.FillDirection.Horizontal,7); controlList.HorizontalAlignment=Enum.HorizontalAlignment.Right; controlList.VerticalAlignment=Enum.VerticalAlignment.Center
    W.Controls=controls

    local searchBox
    if W.SearchEnabled then
        local holder=pick(main,"Frame",{BackgroundColor3=self.Theme.Surface2,BackgroundTransparency=.18,Position=UDim2.new(1,-330,0,78),Size=UDim2.fromOffset(310,36),ZIndex=5})
        corner(holder,10); stroke(holder,rgb(255,255,255),.88)
        icon(holder,"search",16,.15).Position=UDim2.fromOffset(12,10)
        searchBox=pick(holder,"TextBox",{BackgroundTransparency=1,Position=UDim2.fromOffset(36,0),Size=UDim2.new(1,-44,1,0),Font=Enum.Font.Gotham,PlaceholderText="Search...",PlaceholderColor3=self.Theme.Muted,Text="",TextColor3=self.Theme.Text,TextSize=12,ClearTextOnFocus=false,ZIndex=6})
        W.SearchBox=searchBox
    end

    local body=pick(main,"Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,72),Size=UDim2.new(1,-24,1,-84),ZIndex=3})
    W.Body=body

    local side=pick(body,"Frame",{BackgroundColor3=self.Theme.Surface,BackgroundTransparency=.22,Size=UDim2.fromOffset(182,1),ZIndex=4})
    corner(side,14); stroke(side,rgb(255,255,255),.9); padding(side,10,10,10,10)
    local sideScroll=pick(side,"ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),BorderSizePixel=0,CanvasSize=UDim2.new(),ScrollBarThickness=2,ScrollBarImageTransparency=.5,AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=5})
    list(sideScroll,Enum.FillDirection.Vertical,6)
    W.Side=side; W.SideScroll=sideScroll

    local content=pick(body,"Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(194,0),Size=UDim2.new(1,-194,1,0),ZIndex=3})
    local pages=pick(content,"Frame",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=4})
    W.Content=content; W.Pages=pages

    local function makeControlButton(asset, tooltip, callback)
        local b=pick(controls,"TextButton",{BackgroundColor3=self.Theme.Surface2,BackgroundTransparency=.16,Size=UDim2.fromOffset(40,36),Text="",AutoButtonColor=false,ZIndex=7})
        corner(b,10); stroke(b,rgb(255,255,255),.9)
        local im=icon(b,asset,17,.1); im.AnchorPoint=Vector2.new(.5,.5); im.Position=UDim2.fromScale(.5,.5)
        b.MouseEnter:Connect(function() tween(b,.12,{BackgroundTransparency=.02}) end)
        b.MouseLeave:Connect(function() tween(b,.12,{BackgroundTransparency=.16}) end)
        b.Activated:Connect(callback)
        b:SetAttribute("Tooltip",tooltip or "")
        return b
    end

    W.OpenButton=makeControlButton("chevronright","Collapse",function() W:SetOpen(false) end)
    local minBtn=makeControlButton("minus","Minimize",function() W:SetOpen(false) end)
    local closeBtn=makeControlButton("x","Close",function() W:Destroy() end)
    W.MinButton=minBtn; W.CloseButton=closeBtn

    local floating=pick(gui,"TextButton",{Name="OpenButton",BackgroundColor3=self.Theme.Surface2,BackgroundTransparency=.08,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,62,.5,0),Size=UDim2.fromOffset(48,48),Text="",AutoButtonColor=false,ZIndex=20,Visible=not W.Opened})
    corner(floating,15); stroke(floating,self.Theme.Accent,.35,1.2)
    local fi=icon(floating,"menu",20,0); fi.AnchorPoint=Vector2.new(.5,.5); fi.Position=UDim2.fromScale(.5,.5)
    W.Floating=floating
    floating.Activated:Connect(function() W:SetOpen(true) end)

    local function setDrag(input)
        local delta=input.Position-W._dragStart
        local pos=UDim2.new(W._startPos.X.Scale,W._startPos.X.Offset+delta.X,W._startPos.Y.Scale,W._startPos.Y.Offset+delta.Y)
        main.Position=pos; shadow.Position=pos+UDim2.fromOffset(0,10)
    end
    top.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            W._dragging=true; W._dragStart=input.Position; W._startPos=main.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then W._dragging=false end end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then W._dragInput=input end
    end)
    table.insert(W._connections,UserInputService.InputChanged:Connect(function(input)
        if input==W._dragInput and W._dragging then setDrag(input) end
    end))

    local function updateScale()
        if not W.AutoScale then return end
        local camera=workspace.CurrentCamera
        if not camera then return end
        local vp=camera.ViewportSize
        local baseW,baseH=W.Size.X.Offset,W.Size.Y.Offset
        local sx=(vp.X-28)/baseW
        local sy=(vp.Y-28)/baseH
        scale.Scale=clamp(math.min(sx,sy),.56,1)
        if vp.X < 650 then
            side.Size=UDim2.fromOffset(152,1)
            content.Position=UDim2.fromOffset(164,0); content.Size=UDim2.new(1,-164,1,0)
        else
            side.Size=UDim2.fromOffset(182,1)
            content.Position=UDim2.fromOffset(194,0); content.Size=UDim2.new(1,-194,1,0)
        end
    end
    table.insert(W._connections,workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale))
    task.defer(updateScale)

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            W:Search(searchBox.Text)
        end)
    end

    function W:ApplyTheme()
        local t=self.Library.Theme
        main.BackgroundColor3=t.Background; grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,t.Surface),ColorSequenceKeypoint.new(1,t.Background)})
        title.TextColor3=t.Text; subtitle.TextColor3=t.SubText
        side.BackgroundColor3=t.Surface; floating.BackgroundColor3=t.Surface2
        for _,tab in ipairs(self.Tabs) do tab:ApplyTheme() end
    end

    function W:SetOpen(value)
        self.Opened=value~=false
        if self.Opened then
            main.Visible=true; shadow.Visible=true; floating.Visible=false
            main.Size=UDim2.fromOffset(W.Size.X.Offset*.98,W.Size.Y.Offset*.98); shadow.Size=main.Size+UDim2.fromOffset(22,22)
            tween(main,.18,{Size=W.Size}); tween(shadow,.18,{Size=W.Size+UDim2.fromOffset(22,22)})
        else
            tween(main,.16,{Size=UDim2.fromOffset(10,10)}); tween(shadow,.16,{Size=UDim2.fromOffset(10,10)})
            task.delay(.17,function() if not self.Opened then main.Visible=false; shadow.Visible=false; floating.Visible=true end end)
        end
    end

    function W:Toggle()
        self:SetOpen(not self.Opened)
    end

    function W:CreateTab(tabOptions)
        tabOptions=tabOptions or {}
        local T={Window=self,Title=tabOptions.Title or "Tab",Icon=tabOptions.Icon or "home",Sections={},Items={},Visible=true}
        T.Page=pick(pages,"ScrollingFrame",{Name="Page_"..T.Title,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageTransparency=.55,Visible=false,ZIndex=5})
        padding(T.Page,3,6,4,12); T.Layout=list(T.Page,Enum.FillDirection.Vertical,10)
        local tabButton=pick(sideScroll,"TextButton",{BackgroundColor3=self.Theme.Surface2,BackgroundTransparency=.35,Size=UDim2.new(1,0,0,42),Text="",AutoButtonColor=false,ZIndex=6})
        corner(tabButton,10)
        local ic=icon(tabButton,T.Icon,18,.2); ic.Position=UDim2.fromOffset(12,12)
        local tl=pick(tabButton,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-48,1,0),Font=Enum.Font.GothamMedium,Text=T.Title,TextColor3=self.Theme.SubText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
        T.Button=tabButton; T.Label=tl; T.IconImage=ic
        tabButton.Activated:Connect(function() self:SelectTab(T) end)
        tabButton.MouseEnter:Connect(function() if self.ActiveTab~=T then tween(tabButton,.12,{BackgroundTransparency=.16}) end end)
        tabButton.MouseLeave:Connect(function() if self.ActiveTab~=T then tween(tabButton,.12,{BackgroundTransparency=.35}) end end)

        function T:ApplyTheme()
            local t=self.Window.Library.Theme
            self.Page.ScrollBarImageColor3=t.Accent
            self.Button.BackgroundColor3=t.Surface2; self.Label.TextColor3=(self.Window.ActiveTab==self and t.Text or t.SubText)
        end

        function T:Section(sectionOptions)
            sectionOptions=sectionOptions or {}
            local S={Tab=self,Title=sectionOptions.Title or "Section",Items={},Collapsed=sectionOptions.Collapsed==true}
            local card=pick(self.Page,"Frame",{BackgroundColor3=self.Window.Library.Theme.Surface,BackgroundTransparency=.2,Size=UDim2.new(1,-2,0,50),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=6})
            corner(card,13); stroke(card,rgb(255,255,255),.91)
            local header=pick(card,"TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,46),Text="",AutoButtonColor=false,ZIndex=7})
            local h=pick(header,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-60,1,0),Font=Enum.Font.GothamBold,Text=S.Title,TextColor3=self.Window.Library.Theme.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
            local arrow=icon(header,"chevrondown",16,.2); arrow.AnchorPoint=Vector2.new(1,.5); arrow.Position=UDim2.new(1,-14,.5,0)
            local holder=pick(card,"Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,46),Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=7})
            padding(holder,0,0,0,10); list(holder,Enum.FillDirection.Vertical,7)
            S.Card=card; S.Holder=holder; S.Header=header; S.Arrow=arrow
            table.insert(T.Sections,S)
            header.Activated:Connect(function()
                S.Collapsed=not S.Collapsed; holder.Visible=not S.Collapsed
                arrow.Rotation=S.Collapsed and -90 or 0
            end)

            local function itemFrame(height)
                local f=pick(holder,"Frame",{BackgroundColor3=self.Window.Library.Theme.Surface2,BackgroundTransparency=.22,Size=UDim2.new(1,0,0,height or 44),AutomaticSize=height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,ZIndex=8})
                corner(f,10); stroke(f,rgb(255,255,255),.94); padding(f,11,11,8,8)
                return f
            end

            function S:Button(o)
                o=o or {}; local f=itemFrame(46)
                local b=pick(f,"TextButton",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Text="",AutoButtonColor=false})
                local im=icon(f,o.Icon or "play",17,.18); im.Position=UDim2.fromOffset(1,14)
                local tx=pick(f,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(30,0),Size=UDim2.new(1,-36,1,0),Font=Enum.Font.GothamMedium,Text=o.Title or "Button",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                b.MouseEnter:Connect(function() tween(f,.12,{BackgroundTransparency=.04}) end); b.MouseLeave:Connect(function() tween(f,.12,{BackgroundTransparency=.22}) end)
                b.Activated:Connect(function() tween(f,.08,{Size=UDim2.new(1,-3,0,44)}); task.delay(.09,function() tween(f,.08,{Size=UDim2.new(1,0,0,46)}) end); safeCallback(o.Callback) end)
                return {Frame=f,Button=b}
            end

            function S:Toggle(o)
                o=o or {}; local state=o.Default==true; local f=itemFrame(50)
                local tx=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-72,0,22),Font=Enum.Font.GothamMedium,Text=o.Title or "Toggle",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local desc=pick(f,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,22),Size=UDim2.new(1,-72,0,18),Font=Enum.Font.Gotham,Text=o.Description or "",TextColor3=self.Tab.Window.Library.Theme.SubText,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left})
                local sw=pick(f,"TextButton",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,BackgroundTransparency=.05,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(48,26),Text="",AutoButtonColor=false}); corner(sw,13); stroke(sw,rgb(255,255,255),.9)
                local knob=pick(sw,"Frame",{BackgroundColor3=self.Tab.Window.Library.Theme.SubText,Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(3,3)}); corner(knob,10)
                local obj={Value=state,Frame=f,Toggle=sw}
                function obj:Set(v, silent) self.Value=v==true; tween(sw,.16,{BackgroundColor3=self.Value and self.Tab.Window.Library.Theme.Accent or self.Tab.Window.Library.Theme.Surface3}); tween(knob,.16,{Position=self.Value and UDim2.new(1,-23,0,3) or UDim2.fromOffset(3,3),BackgroundColor3=self.Value and rgb(255,255,255) or self.Tab.Window.Library.Theme.SubText}); if not silent then safeCallback(o.Callback,self.Value) end end
                sw.Activated:Connect(function() obj:Set(not obj.Value) end); obj:Set(state,true)
                return obj
            end

            function S:Slider(o)
                o=o or {}; local min=o.Min or 0; local max=o.Max or 100; local value=clamp(o.Default or min,min,max); local f=itemFrame(62)
                local label=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-75,0,20),Font=Enum.Font.GothamMedium,Text=o.Title or "Slider",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local valLabel=pick(f,"TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(70,20),Font=Enum.Font.GothamMedium,Text=tostring(value),TextColor3=self.Tab.Window.Library.Theme.Accent2,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right})
                local bar=pick(f,"Frame",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,Position=UDim2.fromOffset(0,34),Size=UDim2.new(1,0,0,7)}); corner(bar,4)
                local fill=pick(bar,"Frame",{BackgroundColor3=self.Tab.Window.Library.Theme.Accent,Size=UDim2.new(0,0,1,0)}); corner(fill,4)
                local knob=pick(bar,"Frame",{BackgroundColor3=rgb(255,255,255),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(13,13),ZIndex=3}); corner(knob,7)
                local dragging=false; local obj={Value=value,Frame=f,Bar=bar}
                local function setFromX(x,silent)
                    local p=clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1); local raw=lerp(min,max,p); local inc=o.Increment or .01; raw=math.floor(raw/inc+.5)*inc; raw=clamp(raw,min,max); obj.Value=raw; local pct=(raw-min)/(max-min==0 and 1 or max-min); fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,.5,0); valLabel.Text=tostring(raw); if not silent then safeCallback(o.Callback,raw) end
                end
                bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(i.Position.X) end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setFromX(i.Position.X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
                function obj:Set(v,silent) setFromX(bar.AbsolutePosition.X+bar.AbsoluteSize.X*((clamp(v,min,max)-min)/(max-min==0 and 1 or max-min)),silent) end
                task.defer(function() obj:Set(value,true) end)
                return obj
            end

            function S:Dropdown(o)
                o=o or {}; local values=o.Values or o.Options or {}; local selected=o.Default or values[1]; local open=false; local f=itemFrame(48)
                local label=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-160,1,0),Font=Enum.Font.GothamMedium,Text=o.Title or "Dropdown",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local select=pick(f,"TextButton",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,BackgroundTransparency=.08,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(150,30),Text="",AutoButtonColor=false}); corner(select,9)
                local current=pick(select,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-30,1,0),Font=Enum.Font.Gotham,Text=tostring(selected or "Select"),TextColor3=self.Tab.Window.Library.Theme.SubText,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left})
                local chev=icon(select,"chevrondown",14,.2); chev.AnchorPoint=Vector2.new(1,.5); chev.Position=UDim2.new(1,-8,.5,0)
                local menu=pick(f,"Frame",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface2,BackgroundTransparency=.02,Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,0),Visible=false,ZIndex=30}); corner(menu,10); stroke(menu,rgb(255,255,255),.86); padding(menu,7); local ml=list(menu,Enum.FillDirection.Vertical,4)
                local obj={Value=selected,Frame=f}
                local function rebuild()
                    for _,c in ipairs(menu:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for _,v in ipairs(values) do
                        local b=pick(menu,"TextButton",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,BackgroundTransparency=.35,Size=UDim2.new(1,0,0,32),Text=tostring(v),Font=Enum.Font.Gotham,TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=11,AutoButtonColor=false,ZIndex=31}); corner(b,8)
                        b.Activated:Connect(function() obj.Value=v; current.Text=tostring(v); open=false; menu.Visible=false; chev.Rotation=0; safeCallback(o.Callback,v) end)
                    end
                    menu.Size=UDim2.new(1,0,0,math.min(#values*36+14,230))
                end
                select.Activated:Connect(function() open=not open; if open then rebuild() end; menu.Visible=open; chev.Rotation=open and 180 or 0 end)
                function obj:Set(v,silent) obj.Value=v; current.Text=tostring(v); if not silent then safeCallback(o.Callback,v) end end
                return obj
            end

            function S:MultiDropdown(o)
                o=o or {}; local values=o.Values or o.Options or {}; local selected={}; for _,v in ipairs(o.Default or {}) do selected[v]=true end; local f=itemFrame(48)
                local label=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-160,1,0),Font=Enum.Font.GothamMedium,Text=o.Title or "Multi Dropdown",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local b=pick(f,"TextButton",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(150,30),Text="",AutoButtonColor=false}); corner(b,9)
                local text=pick(b,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-10,1,0),Font=Enum.Font.Gotham,Text="Select...",TextColor3=self.Tab.Window.Library.Theme.SubText,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left})
                local menu=pick(f,"Frame",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface2,Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,0),Visible=false,ZIndex=30}); corner(menu,10); padding(menu,7); list(menu,Enum.FillDirection.Vertical,4)
                local obj={Values=selected,Frame=f}
                local function updateText() local out={}; for _,v in ipairs(values) do if selected[v] then table.insert(out,tostring(v)) end end; text.Text=#out>0 and table.concat(out,", ") or "Select..." end
                for _,v in ipairs(values) do local x=pick(menu,"TextButton",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,BackgroundTransparency=.35,Size=UDim2.new(1,0,0,32),Text=tostring(v),Font=Enum.Font.Gotham,TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=11,AutoButtonColor=false,ZIndex=31}); corner(x,8); x.Activated:Connect(function() selected[v]=not selected[v]; x.BackgroundTransparency=selected[v] and .05 or .35; updateText(); safeCallback(o.Callback,deepCopy(selected)) end) end
                menu.Size=UDim2.new(1,0,0,math.min(#values*36+14,230)); b.Activated:Connect(function() menu.Visible=not menu.Visible end); updateText()
                function obj:Set(vals,silent) selected={}; for _,v in ipairs(vals or {}) do selected[v]=true end; updateText(); if not silent then safeCallback(o.Callback,deepCopy(selected)) end end
                return obj
            end

            function S:Input(o)
                o=o or {}; local f=itemFrame(50)
                local label=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(.35,0,1,0),Font=Enum.Font.GothamMedium,Text=o.Title or "Input",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local box=pick(f,"TextBox",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,BackgroundTransparency=.05,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.new(.62,0,0,32),Font=Enum.Font.Gotham,PlaceholderText=o.Placeholder or "Type here...",PlaceholderColor3=self.Tab.Window.Library.Theme.Muted,Text=o.Default or "",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=11,ClearTextOnFocus=o.ClearTextOnFocus==true})
                corner(box,9); padding(box,9)
                box.FocusLost:Connect(function(enter) if o.Callback then safeCallback(o.Callback,box.Text,enter) end end)
                return {Frame=f,Input=box,Get=function() return box.Text end,Set=function(_,v) box.Text=tostring(v or "") end}
            end

            function S:Keybind(o)
                o=o or {}; local current=o.Default or Enum.KeyCode.RightShift; local listening=false; local f=itemFrame(46)
                local label=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-110,1,0),Font=Enum.Font.GothamMedium,Text=o.Title or "Keybind",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local b=pick(f,"TextButton",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface3,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(96,30),Text=current.Name,Font=Enum.Font.GothamMedium,TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=10,AutoButtonColor=false}); corner(b,9)
                local obj={Key=current,Frame=f}
                b.Activated:Connect(function() listening=true; b.Text="Press key..." end)
                local c=UserInputService.InputBegan:Connect(function(input,gp)
                    if listening and input.UserInputType==Enum.UserInputType.Keyboard then current=input.KeyCode; obj.Key=current; listening=false; b.Text=current.Name; safeCallback(o.Callback,current) return end
                    if not gp and input.KeyCode==current then safeCallback(o.OnPress,current) end
                end)
                table.insert(W._connections,c)
                function obj:Set(key,silent) if typeof(key)=="EnumItem" then current=key; obj.Key=key; b.Text=key.Name; if not silent then safeCallback(o.Callback,key) end end end
                return obj
            end

            function S:ColorPicker(o)
                o=o or {}; local color=o.Default or self.Tab.Window.Library.Theme.Accent; local f=itemFrame(50)
                local label=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-60,1,0),Font=Enum.Font.GothamMedium,Text=o.Title or "Color",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
                local sw=pick(f,"TextButton",{BackgroundColor3=color,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(38,30),Text="",AutoButtonColor=false}); corner(sw,9); stroke(sw,rgb(255,255,255),.75)
                local obj={Color=color,Frame=f}
                local hue=0; local sat=0; local val=0; hue,sat,val=color:ToHSV()
                local popup=pick(f,"Frame",{BackgroundColor3=self.Tab.Window.Library.Theme.Surface2,Position=UDim2.new(1,-260,1,6),Size=UDim2.fromOffset(250,130),Visible=false,ZIndex=40}); corner(popup,12); stroke(popup,rgb(255,255,255),.86); padding(popup,10)
                local palette=pick(popup,"Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(1,0,0,82),ZIndex=41}); corner(palette,8)
                local huebar=pick(popup,"Frame",{BackgroundColor3=Color3.new(1,0,0),Position=UDim2.new(0,0,0,88),Size=UDim2.new(1,0,0,12),ZIndex=41}); corner(huebar,6)
                local pgrad=pick(palette,"UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))})})
                local objp=pick(palette,"Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(sat,1-val),Size=UDim2.fromOffset(10,10),ZIndex=45}); corner(objp,5); stroke(objp,Color3.new(0,0,0),.2)
                local hgrad=pick(huebar,"UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.17,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(.34,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(.51,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(.68,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(.85,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})})
                local function update() color=Color3.fromHSV(hue,sat,val); obj.Color=color; sw.BackgroundColor3=color; safeCallback(o.Callback,color) end
                sw.Activated:Connect(function() popup.Visible=not popup.Visible end)
                palette.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then local p=Vector2.new(i.Position.X-palette.AbsolutePosition.X,i.Position.Y-palette.AbsolutePosition.Y); sat=clamp(p.X/palette.AbsoluteSize.X,0,1); val=1-clamp(p.Y/palette.AbsoluteSize.Y,0,1); objp.Position=UDim2.fromScale(sat,1-val); update() end end)
                huebar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hue=clamp((i.Position.X-huebar.AbsolutePosition.X)/huebar.AbsoluteSize.X,0,1); update() end end)
                function obj:Set(c,silent) if typeof(c)=="Color3" then color=c; hue,sat,val=c:ToHSV(); obj.Color=c; sw.BackgroundColor3=c; objp.Position=UDim2.fromScale(sat,1-val); if not silent then safeCallback(o.Callback,c) end end end
                return obj
            end

            function S:Paragraph(o)
                o=o or {}; local f=itemFrame(nil); f.AutomaticSize=Enum.AutomaticSize.Y
                local title=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.GothamBold,Text=o.Title or "Information",TextColor3=self.Tab.Window.Library.Theme.Text,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left})
                local body=pick(f,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,25),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.Gotham,Text=o.Content or o.Description or "",TextColor3=self.Tab.Window.Library.Theme.SubText,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left})
                return {Frame=f,Title=title,Content=body}
            end

            function S:Label(text)
                local f=itemFrame(34); local l=pick(f,"TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Font=Enum.Font.Gotham,Text=tostring(text or ""),TextColor3=self.Tab.Window.Library.Theme.SubText,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left}); return l
            end

            function S:Divider()
                local f=pick(holder,"Frame",{BackgroundColor3=rgb(255,255,255),BackgroundTransparency=.92,Size=UDim2.new(1,0,0,1)}); return f
            end

            return S
        end

        table.insert(self.Tabs,T)
        if not self.ActiveTab then self:SelectTab(T) end
        return T
    end

    function W:SelectTab(tab)
        self.ActiveTab=tab
        for _,t in ipairs(self.Tabs) do
            t.Page.Visible=(t==tab)
            t.Button.BackgroundColor3=self.Library.Theme.Surface2
            t.Button.BackgroundTransparency=(t==tab and .02 or .35)
            t.Label.TextColor3=(t==tab and self.Library.Theme.Text or self.Library.Theme.SubText)
            t.IconImage.ImageTransparency=(t==tab and 0 or .2)
            if t==tab then tween(t.Button,.16,{BackgroundColor3=self.Library.Theme.Accent,BackgroundTransparency=.10}) end
        end
    end

    function W:Search(query)
        query=string.lower(query or "")
        for _,tab in ipairs(self.Tabs) do
            local matchTab=query=="" or string.find(string.lower(tab.Title),query,1,true)~=nil
            tab.Button.Visible=matchTab or query==""
            if tab.Page then
                for _,section in ipairs(tab.Sections) do
                    local smatch=query=="" or string.find(string.lower(section.Title),query,1,true)~=nil
                    section.Card.Visible=smatch or query==""
                end
            end
        end
    end

    function W:Notify(data)
        data=type(data)=="string" and {Title="Notification",Content=data} or (data or {})
        local holder=self.NotificationHolder
        if not holder then
            holder=pick(self.Gui,"Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-18),Size=UDim2.fromOffset(330,420),ZIndex=100,AutomaticSize=Enum.AutomaticSize.Y})
            padding(holder,0,0,0,0); list(holder,Enum.FillDirection.Vertical,8,Enum.SortOrder.LayoutOrder); holder.Layout.HorizontalAlignment=Enum.HorizontalAlignment.Right; holder.Layout.VerticalAlignment=Enum.VerticalAlignment.Bottom; self.NotificationHolder=holder
        end
        local n=pick(holder,"Frame",{BackgroundColor3=self.Library.Theme.Surface,BackgroundTransparency=.06,Size=UDim2.new(1,0,0,74),ZIndex=101,LayoutOrder=-os.clock()}); corner(n,12); stroke(n,self.Library.Theme.Accent,.65,1)
        local title=pick(n,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(14,10),Size=UDim2.new(1,-50,0,22),Font=Enum.Font.GothamBold,Text=data.Title or "Notification",TextColor3=self.Library.Theme.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102})
        local content=pick(n,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(14,32),Size=UDim2.new(1,-24,0,30),Font=Enum.Font.Gotham,Text=data.Content or data.Description or "",TextColor3=self.Library.Theme.SubText,TextSize=10,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102})
        local bar=pick(n,"Frame",{BackgroundColor3=data.Color or self.Library.Theme.Accent,Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(3,74),ZIndex=103}); corner(bar,2)
        n.Position=UDim2.new(1,40,0,0); tween(n,.22,{Position=UDim2.new(1,0,0,0)})
        task.delay(data.Duration or 3,function() if n.Parent then tween(n,.18,{Position=UDim2.new(1,40,0,0)}); task.wait(.2); n:Destroy() end end)
        return n
    end

    function W:Dialog(data)
        data=data or {}; local overlay=pick(self.Gui,"TextButton",{BackgroundColor3=rgb(0,0,0),BackgroundTransparency=.42,Size=UDim2.fromScale(1,1),Text="",ZIndex=200,AutoButtonColor=false})
        local box=pick(overlay,"Frame",{BackgroundColor3=self.Library.Theme.Surface,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(390,210),ZIndex=201}); corner(box,16); stroke(box,rgb(255,255,255),.82)
        padding(box,20,20,18,18)
        local title=pick(box,"TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),Font=Enum.Font.GothamBold,Text=data.Title or "Confirm",TextColor3=self.Library.Theme.Text,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202})
        local content=pick(box,"TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,34),Size=UDim2.new(1,0,0,80),Font=Enum.Font.Gotham,Text=data.Content or "Are you sure?",TextColor3=self.Library.Theme.SubText,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202})
        local yes=pick(box,"TextButton",{BackgroundColor3=self.Library.Theme.Accent,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,0,1,0),Size=UDim2.fromOffset(105,38),Text=data.ConfirmText or "Confirm",Font=Enum.Font.GothamBold,TextColor3=rgb(255,255,255),TextSize=11,AutoButtonColor=false,ZIndex=202}); corner(yes,10)
        local no=pick(box,"TextButton",{BackgroundColor3=self.Library.Theme.Surface3,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-114,1,0),Size=UDim2.fromOffset(105,38),Text=data.CancelText or "Cancel",Font=Enum.Font.GothamBold,TextColor3=self.Library.Theme.Text,TextSize=11,AutoButtonColor=false,ZIndex=202}); corner(no,10)
        yes.Activated:Connect(function() overlay:Destroy(); safeCallback(data.OnConfirm) end); no.Activated:Connect(function() overlay:Destroy(); safeCallback(data.OnCancel) end)
        return overlay
    end

    function W:SaveConfig(name, values)
        name=name or "default"; self.Config[name]=deepCopy(values or self.Config[name] or {})
        if not isFileAPI() then return false,"filesystem API unavailable" end
        local folder=(options.ConfigFolder or "RYEENZYXNZ")
        if type(isfolder)=="function" and type(makefolder)=="function" and not isfolder(folder) then pcall(makefolder,folder) end
        local path=folder.."/"..name..".json"
        local ok,encoded=pcall(HttpService.JSONEncode,HttpService,self.Config[name]); if not ok then return false,encoded end
        local w=pcall(writefile,path,encoded); return w,path
    end

    function W:LoadConfig(name)
        name=name or "default"; if self.Config[name] then return deepCopy(self.Config[name]) end
        if not isFileAPI() then return nil,"filesystem API unavailable" end
        local folder=(options.ConfigFolder or "RYEENZYXNZ"); local path=folder.."/"..name..".json"
        if not isfile(path) then return nil,"config not found" end
        local ok,data=pcall(readfile,path); if not ok then return nil,data end
        local ok2,obj=pcall(HttpService.JSONDecode,HttpService,data); if not ok2 then return nil,obj end
        self.Config[name]=obj; return deepCopy(obj)
    end

    function W:DeleteConfig(name)
        if not isFileAPI() or type(delfile)~="function" then return false,"delete API unavailable" end
        local path=(options.ConfigFolder or "RYEENZYXNZ").."/"..(name or "default")..".json"; if isfile(path) then delfile(path); return true end; return false
    end

    function W:GetConfig(name) return deepCopy(self.Config[name or "default"] or {}) end

    function W:Destroy()
        if self._destroyed then return end; self._destroyed=true
        for _,c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
        for _,t in ipairs(self.Tabs) do for _,s in ipairs(t.Sections) do end end
        if self.Gui then self.Gui:Destroy() end
        for i,v in ipairs(self.Library.Windows) do if v==self then table.remove(self.Library.Windows,i) break end end
    end

    -- Optional tooltip behavior for controls that have a Tooltip attribute.
    table.insert(W._connections,UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        -- Kept lightweight: custom tooltips can be added by consumers without global hooks.
    end))

    W:SetOpen(W.Opened)
    return W
end

function RYEENZYXNZ:Destroy()
    for _,w in ipairs(self.Windows) do pcall(function() w:Destroy() end) end
    self.Windows={}
end


-- ============================================================================
-- RYEENZYXNZ V3 LARGE-CLASS EXTENSION LAYER
-- ============================================================================
-- This layer intentionally keeps the public API broad and modular while
-- remaining executor-friendly. It decorates each Window with advanced helpers
-- without changing the core component implementation above.

local RYEENZYXNZ_Extension = {}
RYEENZYXNZ_Extension.__index = RYEENZYXNZ_Extension

local function extCreate(parent, className, props)
    return pick(parent, className, props)
end

local function extText(parent, text, position, size, font, color, textSize)
    return extCreate(parent, "TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        Position = position or UDim2.new(),
        Size = size or UDim2.new(1, 0, 0, 20),
        Font = font or Enum.Font.Gotham,
        TextColor3 = color or rgb(255,255,255),
        TextSize = textSize or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
end

local function extFrame(parent, size, color, transparency)
    local f = extCreate(parent, "Frame", {
        BackgroundColor3 = color or rgb(20,25,39),
        BackgroundTransparency = transparency == nil and .15 or transparency,
        BorderSizePixel = 0,
        Size = size or UDim2.new(1,0,0,40),
    })
    corner(f, 12)
    stroke(f, rgb(255,255,255), .92)
    return f
end

local function extButton(parent, title, iconName, callback, theme)
    local b = extCreate(parent, "TextButton", {
        BackgroundColor3 = theme.Surface3,
        BackgroundTransparency = .15,
        Size = UDim2.new(1,0,0,38),
        Text = "",
        AutoButtonColor = false,
    })
    corner(b, 10)
    stroke(b, rgb(255,255,255), .91)
    local im = icon(b, iconName or "plus", 16, .15)
    im.Position = UDim2.fromOffset(11,11)
    local tx = extText(b, title, UDim2.fromOffset(36,0), UDim2.new(1,-46,1,0), Enum.Font.GothamMedium, theme.Text, 11)
    b.MouseEnter:Connect(function() tween(b,.12,{BackgroundTransparency=.04}) end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundTransparency=.15}) end)
    b.Activated:Connect(function() safeCallback(callback) end)
    return {Frame=b, Button=b, Icon=im, Label=tx}
end

local function extNormalizeColor(c, fallback)
    if typeof(c) == "Color3" then return c end
    if type(c) == "table" then
        if c.R and c.G and c.B then return Color3.new(c.R,c.G,c.B) end
        if c[1] and c[2] and c[3] then return Color3.fromRGB(c[1],c[2],c[3]) end
    end
    return fallback or rgb(255,255,255)
end

function RYEENZYXNZ_Extension:_Attach(window)
    if window.__RYEENZYXNZ_V3 then return window end
    window.__RYEENZYXNZ_V3 = true
    window._V3 = {Registry={},Controls={},Pages={},Destroyers={}}
    local self = window
    local lib = self.Library

    function self:SetTitle(title, subtitle)
        self.Title = tostring(title or self.Title)
        if self.TitleLabel then self.TitleLabel.Text = self.Title end
        if subtitle ~= nil then
            self.Subtitle = tostring(subtitle)
            if self.SubtitleLabel then self.SubtitleLabel.Text = self.Subtitle end
        end
        return self
    end

    function self:SetSize(size)
        if typeof(size) ~= "UDim2" then return self end
        self.Size = size
        if self.Main then self.Main.Size = size end
        if self.Shadow then self.Shadow.Size = size + UDim2.fromOffset(22,22) end
        return self
    end

    function self:SetPosition(position)
        if typeof(position) == "UDim2" and self.Main then
            self.Main.Position = position
            if self.Shadow then self.Shadow.Position = UDim2.new(position.X.Scale,position.X.Offset,position.Y.Scale,position.Y.Offset+10) end
        end
        return self
    end

    function self:Center()
        return self:SetPosition(UDim2.fromScale(.5,.5))
    end

    function self:SetTransparency(value)
        local n = clamp(tonumber(value) or self.Library.Theme.Glass,0,1)
        if self.Main then self.Main.BackgroundTransparency=n end
        return self
    end

    function self:SetBackgroundColor(color)
        color=extNormalizeColor(color,self.Library.Theme.Background)
        if self.Main then self.Main.BackgroundColor3=color end
        return self
    end

    function self:SetAccent(color)
        local c=extNormalizeColor(color,self.Library.Theme.Accent)
        self.Library.Theme.Accent=c
        self.Library.Theme.Accent2=c
        if self.ApplyTheme then self:ApplyTheme() end
        return self
    end

    function self:Open() self:SetOpen(true); return self end
    function self:Close() self:SetOpen(false); return self end
    function self:IsOpen() return self.Opened==true end

    function self:AddPage(title, iconName)
        return self:CreateTab({Title=title,Icon=iconName or "file"})
    end

    function self:FindTab(title)
        local q=string.lower(tostring(title or ""))
        for _,t in ipairs(self.Tabs) do if string.lower(t.Title)==q then return t end end
        return nil
    end

    function self:RemoveTab(tabOrTitle)
        local target=tabOrTitle
        if type(target)=="string" then target=self:FindTab(target) end
        if not target then return false end
        for i,t in ipairs(self.Tabs) do
            if t==target then
                if t.Page then t.Page:Destroy() end
                if t.Button then t.Button:Destroy() end
                table.remove(self.Tabs,i)
                if self.ActiveTab==t then
                    self.ActiveTab=self.Tabs[1]
                    if self.ActiveTab then self:SelectTab(self.ActiveTab) end
                end
                return true
            end
        end
        return false
    end

    function self:CreateCard(parent, data)
        data=data or {}
        parent=parent or self.Content
        local card=extFrame(parent,data.Size or UDim2.new(1,-4,0,data.Height or 100),self.Library.Theme.Surface,data.Transparency or .14)
        if data.Title then extText(card,data.Title,UDim2.fromOffset(14,10),UDim2.new(1,-28,0,22),Enum.Font.GothamBold,self.Library.Theme.Text,13) end
        if data.Description then extText(card,data.Description,UDim2.fromOffset(14,34),UDim2.new(1,-28,0,38),Enum.Font.Gotham,self.Library.Theme.SubText,10) end
        if data.Icon then local im=icon(card,data.Icon,18,.12); im.Position=UDim2.new(1,-32,0,12) end
        return card
    end

    function self:CreateBadge(parent,text,color)
        local b=extCreate(parent,"TextLabel",{BackgroundColor3=color or self.Library.Theme.Accent,BackgroundTransparency=.08,Size=UDim2.fromOffset(math.max(48,#tostring(text or "")*7+18),24),Text=tostring(text or "Badge"),Font=Enum.Font.GothamBold,TextColor3=rgb(255,255,255),TextSize=9,TextXAlignment=Enum.TextXAlignment.Center})
        corner(b,12); return b
    end

    function self:CreateProgress(parent,value,maxValue)
        local holder=extFrame(parent,UDim2.new(1,-4,0,44),self.Library.Theme.Surface2,.18)
        local bar=extCreate(holder,"Frame",{BackgroundColor3=self.Library.Theme.Surface3,Position=UDim2.fromOffset(12,25),Size=UDim2.new(1,-24,0,7)})
        corner(bar,4)
        local fill=extCreate(bar,"Frame",{BackgroundColor3=self.Library.Theme.Accent,Size=UDim2.new(0,0,1,0)})
        corner(fill,4)
        local obj={Value=tonumber(value) or 0,Max=tonumber(maxValue) or 100,Frame=holder}
        function obj:Set(v)
            self.Value=clamp(tonumber(v) or 0,0,self.Max)
            local pct=self.Max==0 and 0 or self.Value/self.Max
            tween(fill,.18,{Size=UDim2.new(pct,0,1,0)})
        end
        obj:Set(obj.Value)
        return obj
    end

    function self:CreateStatus(parent,title,status,kind)
        local colors={Success=self.Library.Theme.Success,Warning=self.Library.Theme.Warning,Error=self.Library.Theme.Error,Info=self.Library.Theme.Accent2}
        local card=extFrame(parent,UDim2.new(1,-4,0,46),self.Library.Theme.Surface2,.17)
        local dot=extCreate(card,"Frame",{BackgroundColor3=colors[kind or "Info"] or self.Library.Theme.Accent2,Position=UDim2.fromOffset(12,17),Size=UDim2.fromOffset(12,12)})
        corner(dot,6)
        extText(card,title,UDim2.fromOffset(34,5),UDim2.new(.55,0,0,18),Enum.Font.GothamMedium,self.Library.Theme.Text,11)
        extText(card,status,UDim2.new(.55,0,0,5),UDim2.new(.42,-12,0,36),Enum.Font.Gotham,self.Library.Theme.SubText,10)
        return card
    end

    function self:CreateSeparator(parent,spacing)
        local holder=extCreate(parent,"Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,(spacing or 12)+1)})
        local line=extCreate(holder,"Frame",{BackgroundColor3=self.Library.Theme.Surface3,BackgroundTransparency=.15,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(1,-4,0,1)})
        return holder
    end

    function self:CreateLabel(parent,text,options)
        options=options or {}
        local label=extText(parent,text,options.Position,options.Size,options.Font or Enum.Font.Gotham,options.Color or self.Library.Theme.SubText,options.TextSize or 11)
        label.TextWrapped=options.Wrapped==true
        label.RichText=options.RichText==true
        return label
    end

    function self:CreateActionRow(parent,actions)
        local row=extCreate(parent,"Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)})
        local lay=list(row,Enum.FillDirection.Horizontal,7)
        lay.HorizontalAlignment=Enum.HorizontalAlignment.Right
        for _,a in ipairs(actions or {}) do
            local b=extCreate(row,"TextButton",{BackgroundColor3=a.Color or self.Library.Theme.Surface3,BackgroundTransparency=.12,Size=UDim2.fromOffset(a.Width or 90,34),Text=tostring(a.Title or "Action"),Font=Enum.Font.GothamMedium,TextColor3=self.Library.Theme.Text,TextSize=10,AutoButtonColor=false})
            corner(b,9); if a.Icon then local im=icon(b,a.Icon,14,.15); im.Position=UDim2.fromOffset(8,10); b.Text="   "..b.Text end
            b.Activated:Connect(function() safeCallback(a.Callback,self) end)
        end
        return row
    end

    function self:RegisterControl(id,control)
        if id and control then self._V3.Controls[tostring(id)]=control end
        return control
    end

    function self:GetControl(id)
        return self._V3.Controls[tostring(id)]
    end

    function self:SetControl(id,value,silent)
        local c=self:GetControl(id)
        if c and type(c.Set)=="function" then return c:Set(value,silent) end
        return false
    end

    function self:RegisterPage(id,page)
        if id and page then self._V3.Pages[tostring(id)]=page end
        return page
    end

    function self:GetPage(id) return self._V3.Pages[tostring(id)] end

    function self:EachControl(fn)
        if type(fn)~="function" then return end
        for id,c in pairs(self._V3.Controls) do safeCallback(fn,id,c) end
    end

    function self:ResetControls()
        self:EachControl(function(_,c)
            if c.Value~=nil and type(c.Set)=="function" then
                if type(c.Value)=="boolean" then c:Set(false,true) end
            end
        end)
    end

    function self:Snapshot()
        local out={}
        self:EachControl(function(id,c)
            if c.Value~=nil then out[id]=deepCopy(c.Value)
            elseif c.Key~=nil then out[id]=c.Key.Name end
        end)
        return out
    end

    function self:Restore(snapshot,silent)
        if type(snapshot)~="table" then return false end
        for id,value in pairs(snapshot) do self:SetControl(id,value,silent) end
        return true
    end

    function self:SearchControls(query)
        query=string.lower(tostring(query or ""))
        local matches={}
        self:EachControl(function(id,c)
            local title=c.Title or (c.Label and c.Label.Text) or id
            if query=="" or string.find(string.lower(tostring(title)),query,1,true) then table.insert(matches,{Id=id,Control=c}) end
        end)
        return matches
    end

    function self:NotifySuccess(title,content,duration)
        return self:Notify({Title=title or "Success",Content=content or "Completed",Duration=duration or 3,Color=self.Library.Theme.Success})
    end
    function self:NotifyWarning(title,content,duration)
        return self:Notify({Title=title or "Warning",Content=content or "Check your settings",Duration=duration or 3,Color=self.Library.Theme.Warning})
    end
    function self:NotifyError(title,content,duration)
        return self:Notify({Title=title or "Error",Content=content or "Something went wrong",Duration=duration or 4,Color=self.Library.Theme.Error})
    end
    function self:NotifyInfo(title,content,duration)
        return self:Notify({Title=title or "Info",Content=content or "Information",Duration=duration or 3,Color=self.Library.Theme.Accent2})
    end

    function self:Confirm(title,content,onConfirm,onCancel)
        return self:Dialog({Title=title,Content=content,OnConfirm=onConfirm,OnCancel=onCancel})
    end

    function self:SetWatermark(text)
        if self._V3.Watermark then self._V3.Watermark:Destroy() end
        local wm=extCreate(self.Gui,"TextLabel",{BackgroundColor3=self.Library.Theme.Surface,BackgroundTransparency=.18,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.fromOffset(math.max(120,#tostring(text or "")*7+22),26),Text=tostring(text or "RYEENZYXNZ"),Font=Enum.Font.GothamMedium,TextColor3=self.Library.Theme.SubText,TextSize=9,ZIndex=300})
        corner(wm,13); stroke(wm,rgb(255,255,255),.9); self._V3.Watermark=wm
        return wm
    end

    function self:SetHotkeyText(text)
        if not self._V3.Hotkey then
            self._V3.Hotkey=extCreate(self.Gui,"TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,6),Size=UDim2.fromOffset(200,18),Font=Enum.Font.Gotham,TextColor3=self.Library.Theme.Muted,TextSize=9,ZIndex=300})
        end
        self._V3.Hotkey.Text=tostring(text or "")
        return self._V3.Hotkey
    end

    function self:AttachKeybind(key)
        if self._V3.KeybindConnection then pcall(function() self._V3.KeybindConnection:Disconnect() end) end
        if typeof(key)~="EnumItem" then return self end
        self._V3.Keybind=key
        self._V3.KeybindConnection=UserInputService.InputBegan:Connect(function(input,gp)
            if not gp and input.KeyCode==self._V3.Keybind then self:Toggle() end
        end)
        table.insert(self._connections,self._V3.KeybindConnection)
        self:SetHotkeyText("Toggle: "..key.Name)
        return self
    end

    function self:SetOpenButtonIcon(iconName)
        if self.Floating then
            for _,child in ipairs(self.Floating:GetChildren()) do if child:IsA("ImageLabel") then child:Destroy() end end
            local im=icon(self.Floating,iconName or "menu",20,.05); im.AnchorPoint=Vector2.new(.5,.5); im.Position=UDim2.fromScale(.5,.5)
            self._V3.OpenIcon=im
        end
        return self
    end

    function self:SetOpenButtonText(text)
        if self.Floating then self.Floating.Text=tostring(text or "") end
        return self
    end

    function self:SetOpenButtonPosition(position)
        if typeof(position)=="UDim2" and self.Floating then self.Floating.Position=position end
        return self
    end

    function self:SetOpenButtonSize(size)
        if typeof(size)=="UDim2" and self.Floating then self.Floating.Size=size end
        return self
    end

    function self:ShowOpenButton(value)
        if self.Floating then self.Floating.Visible=value~=false end
        return self
    end

    function self:AnimateOpenButton()
        if not self.Floating then return self end
        local old=self.Floating.Size
        tween(self.Floating,.12,{Size=old+UDim2.fromOffset(5,5)})
        task.delay(.13,function() if self.Floating and self.Floating.Parent then tween(self.Floating,.12,{Size=old}) end end)
        return self
    end

    function self:ApplyV3Theme()
        if self.ApplyTheme then self:ApplyTheme() end
        local t=self.Library.Theme
        if self.Floating then self.Floating.BackgroundColor3=t.Surface2 end
        if self._V3.Watermark then self._V3.Watermark.BackgroundColor3=t.Surface end
        return self
    end

    function self:ExportState()
        return {Version="3.0.0",Title=self.Title,Subtitle=self.Subtitle,Opened=self.Opened,Controls=self:Snapshot()}
    end

    function self:ImportState(state)
        if type(state)~="table" then return false end
        if state.Controls then self:Restore(state.Controls,true) end
        return true
    end

    function self:SaveState(name)
        local state=self:ExportState()
        return self:SaveConfig(name or "state",state)
    end

    function self:LoadState(name)
        local state,err=self:LoadConfig(name or "state")
        if not state then return false,err end
        return self:ImportState(state)
    end

    function self:BuildSettingsTab()
        local tab=self:FindTab("Settings") or self:CreateTab({Title="Settings",Icon="settings"})
        local sec=tab:Section({Title="Interface"})
        sec:Button({Title="Close Window",Icon="x",Callback=function() self:Close() end})
        sec:Button({Title="Reset Controls",Icon="refresh",Callback=function() self:ResetControls() end})
        sec:Button({Title="Save State",Icon="save",Callback=function() self:SaveState("autosave") end})
        return tab
    end

    function self:InstallPremiumDefaults()
        self:SetOpenButtonIcon("menu")
        self:SetWatermark("RYEENZYXNZ • LIQUID GLASS")
        self:SetHotkeyText("RightShift • Toggle UI")
        self:AttachKeybind(Enum.KeyCode.RightShift)
        return self
    end

    return self
end

-- Large icon alias catalog. The names intentionally follow Lucide naming so
-- scripts can stay readable. Consumers can override any icon through SetIcon.
local LargeLucideAliases = {
    accessibility="user", activity="zap", airplay="monitor", alarmclock="bell", alarmclockcheck="bell",
    alarmclockminus="bell", alarmclockoff="bell", alarmclockplus="bell", album="file", aligncenter="menu",
    aligncenterhorizontal="menu", aligncentervertical="menu", alignendhorizontal="menu", alignendvertical="menu",
    alignhorizontaldistributecenter="menu", alignhorizontaldistributend="menu", alignhorizontaldistributestart="menu",
    alignhorizontaljustifycenter="menu", alignhorizontaljustifyend="menu", alignhorizontaljustifystart="menu",
    alignhorizontalspacearound="menu", alignhorizontalspacebetween="menu", alignjustify="menu", alignleft="menu",
    alignright="menu", alignstartvertical="menu", alignverticaldistributecenter="menu", alignverticaldistributend="menu",
    alignverticaldistributestart="menu", alignverticaljustifycenter="menu", alignverticaljustifyend="menu",
    alignverticaljustifystart="menu", alignverticalspacearound="menu", alignverticalspacebetween="menu", anchor="plus",
    angry="circlealert", annoyed="circlealert", archive="folder", archivex="folder", arrowbigdown="chevrondown",
    arrowbigleft="arrowleft", arrowbigright="arrowright", arrowbigup="chevronup", arrowdown="chevrondown",
    arrowdown01="chevrondown", arrowdown10="chevrondown", arrowdownaz="chevrondown", arrowdownnarrowwide="chevrondown",
    arrowdownwideNarrow="chevrondown", arrowleft01="arrowleft", arrowleftfromline="arrowleft", arrowleftright="menu",
    arrowright01="arrowright", arrowrightfromline="arrowright", arrowsupfromline="chevronup", arrowup="chevronup",
    arrowup01="chevronup", arrowupaz="chevronup", arrowupnarrowwide="chevronup", arrowupwideNarrow="chevronup",
    asterisk="star", atom="zap", badgecheck="check", badgealert="circlealert", badgecent="star", badgehelp="info",
    badgeinfo="info", badgeplus="plus", badges="star", ban="circlealert", banknote="file", barcode="code",
    baseline="menu", battery="zap", batterycharging="zap", batteryfull="zap", batterywarning="circlealert",
    beaker="zap", belloff="bell", bluetooth="zap", book="file", bookmark="star", box="folder", boxes="folder",
    brain="user", briefcase="folder", brush="palette", bug="wrench", building="monitor", bus="arrowright",
    cake="star", calculator="code", calendar="file", calendarcheck="check", calendarclock="bell", calendarcog="settings",
    calendarheart="heart", calendarminus="minus", calendaroff="x", calendarplus="plus", calendarsearch="search",
    calendarx="x", cameraoff="camera", car="arrowright", cast="monitor", chartarea="menu", chartbar="menu",
    chartline="menu", chartnetwork="menu", chartpie="menu", checkcheck="check", checkcircle="check", checkcircle2="check",
    chevrondown="chevrondown", chevronfirst="arrowleft", chevronlast="arrowright", chevronleft="arrowleft", chevronright="arrowright",
    chevronup="chevronup", circle="plus", circlecheck="check", circlecheckbig="check", circlechevronDown="chevrondown",
    circlechevronleft="arrowleft", circlechevronright="arrowright", circlechevronup="chevronup", circleellipsis="menu",
    circlehelp="info", circleminus="minus", circleoff="x", circlepause="pause", circleplay="play", circleplus="plus",
    circleuser="user", circleuserround="user", circlex="x", clipboard="file", clipboardcheck="check", clipboardcopy="copy",
    clipboardlist="file", clock="bell", cloudoff="cloud", cloudupload="cloud", code2="code", codexml="code", cog="settings",
    columns2="menu", columns3="menu", command="keyboard", compass="globe", component="box", copycheck="copy", copyleft="copy",
    copyright="copy", cpu="monitor", creditcard="file", crop="menu", crosshair="plus", database="folder", delete="trash",
    disc="play", discord="users", download="arrowright", downloadcloud="cloud", dribbble="star", droplet="cloud",
    edit="code", edit2="code", edit3="code", ellipsis="menu", ellipsisvertical="menu", equal="menu", eraser="trash",
    ethernetport="globe", externalLink="arrowright", eyeclosed="eyeoff", facebook="users", fastforward="play", feather="star",
    filearchive="file", fileaudio="file", filebadge="file", filecheck="check", filecode="code", filecog="settings", filediff="file",
    filedown="arrowright", fileheart="heart", fileimage="file", fileinput="file", filejson="code", filekey="lock", filelock="lock",
    fileminus="minus", filemusic="play", fileoutput="file", filepen="code", fileplus="plus", files="folder", fileSearch="search",
    fileSliders="slidershorizontal", fileSpreadsheet="file", fileStack="folder", fileSymlink="arrowright", fileTerminal="code",
    fileText="file", filetype="file", fileup="arrowright", filevideo="play", filevolume="volume2", filewarning="circlealert", filex="x",
    filter="slidershorizontal", filterx="x", flag="star", flame="zap", flashlight="zap", folderarchive="folder", foldercheck="folder",
    folderclock="folder", folderclosed="folder", foldercode="folder", foldercog="settings", folderdot="folder", folderdown="arrowright",
    foldergit="folder", foldergit2="folder", folderheart="heart", folderinput="folder", folderkanban="folder", folderkey="lock",
    folderlock="lock", folderminus="minus", folderopen="folder", folderpen="code", folderplus="plus", folderroot="folder", foldersearch="search",
    folders="folder", foldersymlink="arrowright", foldertree="folder", folderup="arrowright", folderx="x", footprints="user", forminput="file",
    forward="arrowright", frame="box", framer="box", fullscreen="monitor", gauge="slidershorizontal", gem="star", ghost="user", gift="star",
    gitbranch="code", gitcommit="code", gitcompare="code", gitfork="code", github="code", gitlab="code", gitmerge="code", gitpullrequest="code",
    glasswater="cloud", globe2="globe", goal="star", grab="mouse", graduationcap="star", grid2x2="menu", grid3x3="menu", grip="menu",
    gripvertical="menu", hammer="wrench", hand="user", harddrive="monitor", hash="code", headphones="volume2", heartpulse="heart", helpCircle="info",
    history="refresh", house="home", houseplus="home", image="file", inbox="folder", indent="menu", infoIcon="info", inspect="search", instagram="users",
    joystick="gamepad", key="lock", laptop="monitor", layers="menu", layoutdashboard="menu", layoutgrid="menu", layoutlist="menu", library="folder",
    lifeBuoy="heart", link="globe", link2="globe", list="menu", listcheck="check", listfilter="slidershorizontal", listordered="menu", listplus="plus",
    lockkeyhole="lock", logIn="arrowright", logOut="arrowright", mail="file", mailcheck="check", mailopen="file", map="globe", mapPin="globe",
    maximize="monitor", maximize2="monitor", megaphone="bell", menuIcon="menu", messageCircle="users", messageSquare="users", mic="volume2",
    micOff="volume2", minimize="minus", minimize2="minus", monitorCheck="monitor", monitorCog="settings", monitorDot="monitor", monitorOff="monitor",
    monitorPause="pause", monitorPlay="play", mousePointer="mouse", move="menu", music="play", navigation="arrowright", network="globe", notebook="file",
    package="folder", paintbrush="palette", panelleft="menu", panelright="menu", pauseCircle="pause", pen="code", pencil="code", personStanding="user",
    phone="users", pin="plus", plug="zap", plusCircle="plus", power="zap", powerOff="zap", printer="file", puzzle="box", qrCode="code", radio="volume2",
    redo="arrowright", redo2="arrowright", refreshCcw="refresh", refreshCw="refresh", repeat="refresh", replace="refresh", reply="arrowleft", rocket="zap",
    rotate3d="menu", rotateccw="arrowleft", rotatecw="arrowright", route="globe", rss="globe", ruler="menu", saveAll="save", scan="search", school="star",
    scissors="code", screenShare="monitor", scroll="file", searchCheck="search", searchCode="search", searchX="search", send="arrowright", server="monitor",
    shield="lock", shieldAlert="circlealert", shieldCheck="check", shieldClose="x", shieldOff="lock", shoppingBag="folder", shoppingCart="folder",
    sidebar="menu", signal="zap", signalHigh="zap", signalLow="zap", signalMedium="zap", signalZero="zap", slash="x", smartphoneNfc="smartphone", sparkles="star",
    speaker="volume2", square="plus", squarecheck="check", squarecode="code", squareellipsis="menu", squarelibrary="folder", squaremenu="menu", squareminus="minus",
    squaremousepointer="mouse", squarepause="pause", squarepen="code", squareplay="play", squareplus="plus", squarepower="zap", squareuser="user", squarex="x",
    staroff="star", stars="star", stepback="arrowleft", stepforward="arrowright", stopcircle="x", sunDim="sun", sunMedium="sun", sunrise="sun", sunset="sun",
    table="menu", tablet="monitor", tag="star", target="plus", terminal="code", text="file", textcursor="code", thumbsdown="x", thumbsup="check", timer="bell",
    toggleleft="minus", toggleright="plus", trash2="trash", treepalm="globe", trophy="star", truck="arrowright", tv="monitor", type="file", undo="arrowleft",
    upload="arrowright", uploadcloud="cloud", usercheck="user", usercog="settings", userminus="user", userplus="plus", usersround="users", userx="x",
    video="play", videooff="play", view="eye", volume="volume2", volume1="volume2", volumeoff="volume2", wallet="folder", wand="star", watch="bell",
    webhook="code", wifi="globe", wifiOff="globe", wrenchIcon="wrench", xcircle="x", xcircleIcon="x", xSquare="x", youtube="play", zoomin="plus", zoomout="minus",
}

for alias,target in pairs(LargeLucideAliases) do
    local id=Lucide[target]
    if id and not Lucide[alias] then Lucide[alias]=id end
end

local function attachControlRegistry(window)
    -- Wrap CreateTab once so every newly created tab/section can register controls.
    if window.__RYEENZYXNZ_REGISTRY_WRAPPED then return end
    window.__RYEENZYXNZ_REGISTRY_WRAPPED=true
    local original=window.CreateTab
    window.CreateTab=function(selfWindow,opts)
        local tab=original(selfWindow,opts)
        if not tab then return tab end
        local originalSection=tab.Section
        tab.Section=function(selfTab,sectionOpts)
            local section=originalSection(selfTab,sectionOpts)
            if not section then return section end
            local function wrap(name)
                local old=section[name]
                if type(old)~="function" then return end
                section[name]=function(selfSection,opts)
                    local obj=old(selfSection,opts)
                    if obj and type(opts)=="table" and opts.Id then
                        selfWindow:RegisterControl(opts.Id,obj)
                    end
                    if obj and type(opts)=="table" and opts.Title then obj.Title=opts.Title end
                    return obj
                end
            end
            for _,name in ipairs({"Button","Toggle","Slider","Dropdown","MultiDropdown","Input","Keybind","ColorPicker"}) do wrap(name) end
            return section
        end
        return tab
    end
end

local Library = RYEENZYXNZ.new()

-- Decorate every window produced by this instance with the V3 large-class API.
do
    local originalCreateWindow = Library.CreateWindow
    Library.CreateWindow = function(self, options)
        local window = originalCreateWindow(self, options)
        RYEENZYXNZ_Extension:_Attach(window)
        attachControlRegistry(window)
        if options and options.PremiumDefaults then window:InstallPremiumDefaults() end
        return window
    end
    Library.Window = Library.CreateWindow
end

-- Compatibility aliases / convenience API.
-- CreateWindow is already wrapped above.
Library.Theme = Library.Theme
Library.Themes = Themes
Library.Icons = Lucide

return Library
