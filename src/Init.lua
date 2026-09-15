local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Theme = require(script.Theme)
local Util = require(script.Util)

local LocalPlayer = Players.LocalPlayer
local RYEENZY = {}
RYEENZY.Version = "1.0.0"
RYEENZY.Theme = Theme
RYEENZY._windows = {}

local function resolveParent()
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(function() fn(table.unpack(args, 1, args.n)) end)
    end)
end

function RYEENZY:AddTheme(name, data)
    local copy = {}
    for k, v in pairs(Theme) do copy[k] = v end
    for k, v in pairs(data or {}) do copy[k] = v end
    copy.Name = name
    self.Theme = copy
    return copy
end

function RYEENZY:SetTheme(data)
    if type(data) == "string" and self.Themes and self.Themes[data] then
        self.Theme = self.Themes[data]
    elseif type(data) == "table" then
        for k, v in pairs(data) do self.Theme[k] = v end
    end
    for _, window in ipairs(self._windows) do
        if window.ApplyTheme then window:ApplyTheme() end
    end
end

RYEENZY.Themes = { LiquidGlass = Theme }

local WindowMethods = {}
local TabMethods = {}
local SectionMethods = {}

function RYEENZY:CreateWindow(options)
    options = options or {}
    local T = self.Theme
    local gui = Instance.new("ScreenGui")
    gui.Name = "RYEENZYXNZ_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = resolveParent()

    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = gui

    local root = Util.new("Frame", {
        Name = "Window",
        Size = options.Size or UDim2.fromOffset(920, 600),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Background,
        BackgroundTransparency = T.Transparency,
        BorderSizePixel = 0,
        Parent = gui,
    })
    Util.corner(root, T.CornerRadius)
    local rootStroke = Util.stroke(root, T.Stroke, 0.25, 1)

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Surface2), ColorSequenceKeypoint.new(1, T.Background)})
    gradient.Rotation = 35
    gradient.Transparency = NumberSequence.new(0.15)
    gradient.Parent = root

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = root

    local top = Util.new("Frame", {
        Name = "Topbar", Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, Parent = root
    })

    local logo = Util.new("Frame", {Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(12, 10), BackgroundColor3 = T.Accent, Parent = top})
    Util.corner(logo, 11)
    local logoText = Util.text(logo, "R", 21, Color3.new(1,1,1), true)
    logoText.TextXAlignment = Enum.TextXAlignment.Center

    local title = Util.text(top, options.Title or "RYEENZYXNZ", 16, T.Text, true)
    title.Position = UDim2.fromOffset(60, 7); title.Size = UDim2.fromOffset(240, 24)
    local subtitle = Util.text(top, options.Subtitle or "LIQUID GLASS UI LIBRARY", 10, T.SubText, false)
    subtitle.Position = UDim2.fromOffset(61, 29); subtitle.Size = UDim2.fromOffset(260, 18)

    local search = Instance.new("TextBox")
    search.Name = "Search"
    search.PlaceholderText = "Search features..."
    search.Text = ""
    search.ClearTextOnFocus = false
    search.TextColor3 = T.Text
    search.PlaceholderColor3 = T.Muted
    search.TextSize = 13
    search.Font = Enum.Font.Gotham
    search.BackgroundColor3 = T.Surface2
    search.BackgroundTransparency = 0.2
    search.Size = UDim2.new(0, 310, 0, 34)
    search.Position = UDim2.new(0.5, -155, 0, 12)
    search.Parent = top
    Util.corner(search, 10); Util.stroke(search, T.Stroke, 0.55, 1)
    Util.padding(search, 10)

    local close = Instance.new("TextButton")
    close.Text = "×"; close.TextSize = 25; close.Font = Enum.Font.Gotham
    close.TextColor3 = T.Text; close.BackgroundTransparency = 1
    close.Size = UDim2.fromOffset(42, 42); close.Position = UDim2.new(1, -50, 0, 8); close.Parent = top
    close.MouseButton1Click:Connect(function() gui.Enabled = false end)

    local sidebar = Util.new("Frame", {
        Name = "Sidebar", Position = UDim2.fromOffset(10, 64), Size = UDim2.new(0, 185, 1, -74),
        BackgroundColor3 = T.Surface, BackgroundTransparency = 0.18, Parent = root
    })
    Util.corner(sidebar, 11); Util.stroke(sidebar, T.Stroke, 0.65, 1); Util.padding(sidebar, 10)
    local sideList = Util.list(sidebar, 6)

    local content = Util.new("ScrollingFrame", {
        Name = "Content", Position = UDim2.fromOffset(205, 64), Size = UDim2.new(1, -215, 1, -74),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = root
    })
    Util.padding(content, 4)
    local contentList = Util.list(content, 10)

    local window = {
        Gui = gui, Root = root, Sidebar = sidebar, Content = content, Tabs = {}, CurrentTab = nil,
        Options = options, Scale = scale, Search = search,
    }
    table.insert(self._windows, window)
    setmetatable(window, {__index = WindowMethods})

    function window:ApplyTheme()
        local nT = RYEENZY.Theme
        root.BackgroundColor3 = nT.Background
        rootStroke.Color = nT.Stroke
    end

    -- drag
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- responsive scaling
    local function updateScale()
        if options.AutoScale == false then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local v = cam.ViewportSize
        local factor = math.min(v.X / 1100, v.Y / 720)
        scale.Scale = math.clamp(factor, 0.65, 1)
    end
    if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
    updateScale()

    function window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local button = Instance.new("TextButton")
        button.Text = ""; button.AutoButtonColor = false
        button.Size = UDim2.new(1, 0, 0, 40)
        button.BackgroundColor3 = T.Surface2; button.BackgroundTransparency = 1
        button.Parent = sidebar
        Util.corner(button, 10)
        local icon = Util.text(button, tabOptions.Icon and "◆" or "•", 14, T.SubText, true)
        icon.Size = UDim2.fromOffset(28, 40); icon.Position = UDim2.fromOffset(8, 0); icon.TextXAlignment = Enum.TextXAlignment.Center
        local txt = Util.text(button, tabOptions.Name or "Tab", 13, T.Text, true)
        txt.Position = UDim2.fromOffset(40, 0); txt.Size = UDim2.new(1, -45, 1, 0)

        local page = Util.new("Frame", {Name = tabOptions.Name or "Tab", Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false, Parent = content})
        local pageList = Util.list(page, 10)
        pageList.HorizontalAlignment = Enum.HorizontalAlignment.Left
        local tab = {Window = window, Button = button, Page = page, Options = tabOptions}
        setmetatable(tab, {__index = TabMethods})
        table.insert(window.Tabs, tab)
        button.MouseButton1Click:Connect(function() window:SelectTab(tab) end)
        if not window.CurrentTab then window:SelectTab(tab) end
        return tab
    end

    function window:SelectTab(tab)
        for _, t in ipairs(self.Tabs) do
            t.Page.Visible = t == tab
            t.Button.BackgroundTransparency = t == tab and 0 or 1
            t.Button.BackgroundColor3 = T.Accent
        end
        self.CurrentTab = tab
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(search.Text)
        for _, tab in ipairs(window.Tabs) do
            for _, child in ipairs(tab.Page:GetDescendants()) do
                if child:IsA("TextLabel") and child:GetAttribute("RYEENZYSearchText") then
                    local parent = child.Parent
                    local hay = string.lower(child:GetAttribute("RYEENZYSearchText"))
                    if q == "" then
                        parent.Visible = true
                    else
                        parent.Visible = string.find(hay, q, 1, true) ~= nil
                    end
                end
            end
        end
    end)

    function window:Notify(data)
        return RYEENZY:Notify(data)
    end

    function window:Destroy()
        gui:Destroy()
    end

    return window
end

function TabMethods:Section(options)
    options = options or {}
    local T = RYEENZY.Theme
    local frame = Util.new("Frame", {
        Name = options.Title or "Section", Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Surface,
        BackgroundTransparency = options.Box == false and 1 or 0.2, Parent = self.Page
    })
    Util.corner(frame, T.CornerRadius); Util.stroke(frame, T.Stroke, 0.65, 1); Util.padding(frame, 12)
    local title = Util.text(frame, options.Title or "Section", options.TextSize or 15, T.Text, true)
    title.Size = UDim2.new(1, 0, 0, 26)
    if options.Icon then title.Text = "◆  " .. title.Text end
    local body = Util.new("Frame", {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = frame})
    local list = Util.list(body, 8)
    local section = {Tab = self, Frame = frame, Body = body, List = list}
    setmetatable(section, {__index = SectionMethods})
    return section
end

function TabMethods:Button(options) return self:Section({Title = options.Title or "Button", Box = true}):Button(options) end
function TabMethods:Toggle(options) return self:Section({Title = "", Box = true}):Toggle(options) end
function TabMethods:Slider(options) return self:Section({Title = "", Box = true}):Slider(options) end
function TabMethods:Dropdown(options) return self:Section({Title = "", Box = true}):Dropdown(options) end
function TabMethods:Input(options) return self:Section({Title = "", Box = true}):Input(options) end
function TabMethods:Keybind(options) return self:Section({Title = "", Box = true}):Keybind(options) end
function TabMethods:Colorpicker(options) return self:Section({Title = "", Box = true}):Colorpicker(options) end
function TabMethods:Paragraph(options) return self:Section({Title = options.Title or "", Box = true}):Paragraph(options) end
function TabMethods:Divider() local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,1); f.BackgroundColor3=RYEENZY.Theme.Stroke; f.BorderSizePixel=0; f.Parent=self.Page; return f end

function SectionMethods:Paragraph(options)
    local T = RYEENZY.Theme
    local box = Util.new("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = T.Surface2, BackgroundTransparency = 0.25, Parent = self.Body})
    Util.corner(box, 10); Util.stroke(box, T.Stroke, 0.75, 1); Util.padding(box, 8)
    local t = Util.text(box, options.Title or "", options.TextSize or 14, T.Text, true); t.Size = UDim2.new(1, 0, 0, 20)
    local d = Util.text(box, options.Desc or "", 12, T.SubText, false); d.Position = UDim2.fromOffset(0, 20); d.Size = UDim2.new(1, 0, 0, 28)
    box:SetAttribute("RYEENZYSearchText", (options.Title or "") .. " " .. (options.Desc or "")); t:SetAttribute("RYEENZYSearchText", box:GetAttribute("RYEENZYSearchText"))
    return box
end

function SectionMethods:Button(options)
    local T = RYEENZY.Theme
    local b = Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=options.Title or "Button"; b.TextColor3=T.Text; b.TextSize=13; b.Font=Enum.Font.GothamSemibold
    b.Size=UDim2.new(1,0,0,40); b.BackgroundColor3=options.Color or T.Accent; b.Parent=self.Body
    Util.corner(b,10); Util.stroke(b,T.Stroke,0.45,1)
    Util.bindHover(b, b.BackgroundColor3, T.Accent2)
    b.MouseButton1Click:Connect(function() safeCall(options.Callback) end)
    b:SetAttribute("RYEENZYSearchText", options.Title or "Button")
    return {Instance=b, Set=function(_, text) b.Text=text end}
end

function SectionMethods:Toggle(options)
    local T=RYEENZY.Theme; local state=options.Default or options.Value or false
    local row=Util.new("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Surface2,BackgroundTransparency=.25,Parent=self.Body}); Util.corner(row,10); Util.stroke(row,T.Stroke,.78,1)
    local title=Util.text(row,options.Title or "Toggle",13,T.Text,true); title.Position=UDim2.fromOffset(12,4); title.Size=UDim2.new(1,-70,0,22)
    local desc=Util.text(row,options.Desc or "",11,T.SubText,false); desc.Position=UDim2.fromOffset(12,24); desc.Size=UDim2.new(1,-80,0,18)
    local hit=Instance.new("TextButton"); hit.Text=""; hit.AutoButtonColor=false; hit.Size=UDim2.fromOffset(44,24); hit.Position=UDim2.new(1,-56,.5,-12); hit.BackgroundColor3=T.Muted; hit.Parent=row; Util.corner(hit,12)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(18,18); knob.Position=UDim2.fromOffset(3,3); knob.BackgroundColor3=Color3.new(1,1,1); knob.Parent=hit; Util.corner(knob,9)
    local function set(v, silent) state=v and true or false; Util.tween(hit,TweenInfo.new(.16),{BackgroundColor3=state and T.Accent or T.Muted}); Util.tween(knob,TweenInfo.new(.16,Enum.EasingStyle.Quad),{Position=state and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)}); if not silent then safeCall(options.Callback,state) end end
    hit.MouseButton1Click:Connect(function() set(not state) end); set(state,true)
    row:SetAttribute("RYEENZYSearchText",options.Title or "Toggle"); title:SetAttribute("RYEENZYSearchText",options.Title or "Toggle")
    return {Get=function() return state end, Set=set, Instance=row}
end

function SectionMethods:Slider(options)
    local T=RYEENZY.Theme; local min=options.Min or 0; local max=options.Max or 100; local value=options.Default or options.Value or min
    local row=Util.new("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.Surface2,BackgroundTransparency=.25,Parent=self.Body}); Util.corner(row,10); Util.stroke(row,T.Stroke,.78,1)
    local title=Util.text(row,options.Title or "Slider",13,T.Text,true); title.Position=UDim2.fromOffset(12,5); title.Size=UDim2.new(1,-80,0,20)
    local val=Util.text(row,tostring(value),12,T.SubText,false); val.Position=UDim2.new(1,-62,0,5); val.Size=UDim2.fromOffset(50,20); val.TextXAlignment=Enum.TextXAlignment.Right
    local bar=Util.new("Frame",{Size=UDim2.new(1,-24,0,6),Position=UDim2.fromOffset(12,38),BackgroundColor3=T.Muted,Parent=row}); Util.corner(bar,3)
    local fill=Util.new("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,Parent=bar}); Util.corner(fill,3)
    local dragging=false
    local function set(v,silent) value=math.clamp(v,min,max); local a=(value-min)/(max-min); fill.Size=UDim2.new(a,0,1,0); val.Text=options.Rounding==0 and tostring(math.floor(value)) or string.format("%.2f",value); if not silent then safeCall(options.Callback,value) end end
    local function fromX(x) local a=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); set(min+(max-min)*a) end
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; fromX(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    set(value,true); row:SetAttribute("RYEENZYSearchText",options.Title or "Slider"); title:SetAttribute("RYEENZYSearchText",options.Title or "Slider")
    return {Get=function() return value end, Set=set, Instance=row}
end

function SectionMethods:Dropdown(options)
    local T=RYEENZY.Theme; local values=options.Values or options.Options or {}; local current=options.Default or options.Value or values[1]
    local row=Util.new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.Surface2,BackgroundTransparency=.25,Parent=self.Body}); Util.corner(row,10); Util.stroke(row,T.Stroke,.78,1)
    local title=Util.text(row,options.Title or "Dropdown",13,T.Text,true); title.Position=UDim2.fromOffset(12,0); title.Size=UDim2.new(.5,0,1,0)
    local btn=Instance.new("TextButton"); btn.Text=tostring(current or "Select"); btn.TextColor3=T.Text; btn.TextSize=12; btn.Font=Enum.Font.Gotham; btn.AutoButtonColor=false; btn.BackgroundColor3=T.Surface; btn.Size=UDim2.new(.48,-8,0,32); btn.Position=UDim2.new(.52,0,0,6); btn.Parent=row; Util.corner(btn,8)
    local open=false; local menu
    local function rebuild()
        if menu then menu:Destroy() end
        menu=Util.new("Frame",{Size=UDim2.new(.48,-8,0,math.min(180,#values*30+8)),Position=UDim2.new(.52,0,0,42),BackgroundColor3=T.Surface,Parent=row}); Util.corner(menu,8); Util.stroke(menu,T.Stroke,.5,1); Util.padding(menu,4); Util.list(menu,3)
        for _,v in ipairs(values) do local b=Instance.new("TextButton"); b.Text=tostring(v); b.TextColor3=T.Text; b.TextSize=12; b.Font=Enum.Font.Gotham; b.BackgroundColor3=T.Surface2; b.AutoButtonColor=false; b.Size=UDim2.new(1,0,0,26); b.Parent=menu; Util.corner(b,7); b.MouseButton1Click:Connect(function() current=v; btn.Text=tostring(v); open=false; menu.Visible=false; safeCall(options.Callback,v) end) end
    end
    btn.MouseButton1Click:Connect(function() open=not open; if open then rebuild() end; if menu then menu.Visible=open end end)
    row:SetAttribute("RYEENZYSearchText",options.Title or "Dropdown"); title:SetAttribute("RYEENZYSearchText",options.Title or "Dropdown")
    return {Get=function() return current end, Select=function(_,v) current=v; btn.Text=tostring(v); safeCall(options.Callback,v) end, Instance=row}
end

function SectionMethods:Input(options)
    local T=RYEENZY.Theme
    local box=Instance.new("TextBox"); box.PlaceholderText=options.Placeholder or "Enter text..."; box.Text=options.Value or ""; box.ClearTextOnFocus=false; box.TextColor3=T.Text; box.PlaceholderColor3=T.Muted; box.TextSize=13; box.Font=Enum.Font.Gotham; box.BackgroundColor3=T.Surface2; box.BackgroundTransparency=.2; box.Size=UDim2.new(1,0,0,42); box.Parent=self.Body; Util.corner(box,10); Util.stroke(box,T.Stroke,.7,1); Util.padding(box,12)
    box.FocusLost:Connect(function() safeCall(options.Callback,box.Text) end)
    box:SetAttribute("RYEENZYSearchText",options.Title or "Input")
    return {Get=function() return box.Text end, Set=function(_,v) box.Text=tostring(v) end, Instance=box}
end

function SectionMethods:Keybind(options)
    local T=RYEENZY.Theme; local key=options.Default or options.Key or Enum.KeyCode.RightShift; local listening=false
    local row=Util.new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.Surface2,BackgroundTransparency=.25,Parent=self.Body}); Util.corner(row,10); Util.stroke(row,T.Stroke,.78,1)
    local title=Util.text(row,options.Title or "Keybind",13,T.Text,true); title.Position=UDim2.fromOffset(12,0); title.Size=UDim2.new(.55,0,1,0)
    local b=Instance.new("TextButton"); b.Text=key.Name or tostring(key); b.TextColor3=T.Text; b.TextSize=12; b.Font=Enum.Font.GothamSemibold; b.AutoButtonColor=false; b.BackgroundColor3=T.Surface; b.Size=UDim2.new(.35,0,0,30); b.Position=UDim2.new(.62,0,0,7); b.Parent=row; Util.corner(b,8)
    b.MouseButton1Click:Connect(function() listening=true; b.Text="Press key..." end)
    UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if listening and input.UserInputType==Enum.UserInputType.Keyboard then key=input.KeyCode; listening=false; b.Text=key.Name; safeCall(options.Callback,key) elseif input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==key then safeCall(options.Changed,key) end
    end)
    row:SetAttribute("RYEENZYSearchText",options.Title or "Keybind"); title:SetAttribute("RYEENZYSearchText",options.Title or "Keybind")
    return {Get=function() return key end, Set=function(_,v) key=v; b.Text=v.Name end, Instance=row}
end

function SectionMethods:Colorpicker(options)
    local T=RYEENZY.Theme; local color=options.Default or options.Color or T.Accent
    local row=Util.new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.Surface2,BackgroundTransparency=.25,Parent=self.Body}); Util.corner(row,10); Util.stroke(row,T.Stroke,.78,1)
    local title=Util.text(row,options.Title or "Color",13,T.Text,true); title.Position=UDim2.fromOffset(12,0); title.Size=UDim2.new(1,-70,1,0)
    local sw=Instance.new("TextButton"); sw.Text=""; sw.BackgroundColor3=color; sw.Size=UDim2.fromOffset(34,26); sw.Position=UDim2.new(1,-46,0,9); sw.Parent=row; Util.corner(sw,8)
    sw.MouseButton1Click:Connect(function() safeCall(options.Callback,color) end)
    row:SetAttribute("RYEENZYSearchText",options.Title or "Colorpicker"); title:SetAttribute("RYEENZYSearchText",options.Title or "Colorpicker")
    return {Get=function() return color end, Set=function(_,v) color=v; sw.BackgroundColor3=v; safeCall(options.Callback,v) end, Instance=row}
end

function RYEENZY:Notify(options)
    options=options or {}; local T=self.Theme
    local gui=Instance.new("ScreenGui"); gui.Name="RYEENZYXNZ_Notifications"; gui.ResetOnSpawn=false; gui.Parent=resolveParent()
    local holder=Instance.new("Frame"); holder.AnchorPoint=Vector2.new(1,1); holder.Position=UDim2.new(1,-18,1,-18); holder.Size=UDim2.fromOffset(330,300); holder.BackgroundTransparency=1; holder.Parent=gui; Util.list(holder,8)
    local card=Util.new("Frame",{Size=UDim2.new(1,0,0,66),BackgroundColor3=T.Surface,BackgroundTransparency=.08,Parent=holder}); Util.corner(card,12); Util.stroke(card,T.Stroke,.55,1); Util.padding(card,10)
    local t=Util.text(card,options.Title or "RYEENZYXNZ",14,T.Text,true); t.Size=UDim2.new(1,-10,0,22)
    local c=Util.text(card,options.Content or "",12,T.SubText,false); c.Position=UDim2.fromOffset(0,24); c.Size=UDim2.new(1,-10,0,32); c.TextWrapped=true
    task.delay(options.Duration or 3,function() if card.Parent then Util.tween(card,TweenInfo.new(.2),{BackgroundTransparency=1}); task.wait(.22); card:Destroy(); if #holder:GetChildren()==1 then gui:Destroy() end end end)
    return card
end

function RYEENZY:CreateConfig(name)
    name=name or "default"
    local path="RYEENZYXNZ/"..name..".json"
    local config={}
    function config:Set(k,v) config[k]=v end
    function config:Get(k,d) local v=config[k]; if v==nil then return d end; return v end
    function config:Save()
        if type(writefile)~="function" then return false,"writefile unavailable" end
        if type(isfolder)=="function" and not isfolder("RYEENZYXNZ") and type(makefolder)=="function" then makefolder("RYEENZYXNZ") end
        writefile(path,HttpService:JSONEncode(config)); return true
    end
    function config:Load()
        if type(isfile)~="function" or type(readfile)~="function" or not isfile(path) then return false end
        local ok,data=pcall(HttpService.JSONDecode,HttpService,readfile(path)); if not ok then return false end
        for k,v in pairs(data) do config[k]=v end; return true
    end
    return config
end

return RYEENZY
