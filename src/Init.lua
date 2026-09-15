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

local Library = RYEENZYXNZ.new()

-- Compatibility aliases / convenience API.
Library.CreateWindow = function(self, options) return RYEENZYXNZ.CreateWindow(self, options) end
Library.Window = Library.CreateWindow
Library.Theme = Library.Theme
Library.Themes = Themes
Library.Icons = Lucide

return Library
