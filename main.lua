-- RYEENZYXNZ Liquid Glass UI Library
-- Standalone entrypoint for executors/loadstring users.
-- For source development, see src/Init.lua.
-- This package is an original implementation inspired by modern Roblox UI-library patterns.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local T = {
    Name="LiquidGlass", Background=Color3.fromRGB(7,12,24), Surface=Color3.fromRGB(12,22,40), Surface2=Color3.fromRGB(18,32,56), Stroke=Color3.fromRGB(55,92,145), Accent=Color3.fromRGB(42,135,255), Accent2=Color3.fromRGB(115,70,255), Text=Color3.fromRGB(242,247,255), SubText=Color3.fromRGB(155,175,205), Muted=Color3.fromRGB(100,120,150), Success=Color3.fromRGB(50,220,145), Warning=Color3.fromRGB(255,190,70), Error=Color3.fromRGB(255,80,105), Transparency=.08, CornerRadius=12
}
local UI={Version="1.0.0",Theme=T,Themes={LiquidGlass=T},_windows={}}
local function parent() local ok,c=pcall(game.GetService,game,"CoreGui"); if ok and c then return c end return LocalPlayer:WaitForChild("PlayerGui") end
local function corner(p,r) local x=Instance.new("UICorner"); x.CornerRadius=UDim.new(0,r or 10); x.Parent=p end
local function stroke(p,c,tr) local x=Instance.new("UIStroke"); x.Color=c; x.Transparency=tr or .6; x.Parent=p end
local function label(p,txt,size,color,bold) local x=Instance.new("TextLabel"); x.BackgroundTransparency=1;x.Text=txt or "";x.TextSize=size or 14;x.TextColor3=color;x.Font=bold and Enum.Font.GothamSemibold or Enum.Font.Gotham;x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=p;return x end
local function list(p,g) local x=Instance.new("UIListLayout");x.Padding=UDim.new(0,g or 8);x.SortOrder=Enum.SortOrder.LayoutOrder;x.Parent=p;return x end
local function pad(p,n) local x=Instance.new("UIPadding");x.PaddingTop=UDim.new(0,n);x.PaddingBottom=UDim.new(0,n);x.PaddingLeft=UDim.new(0,n);x.PaddingRight=UDim.new(0,n);x.Parent=p end
local function tw(o,props,d) local t=TweenService:Create(o,TweenInfo.new(d or .15,Enum.EasingStyle.Quad),props);t:Play();return t end
local function call(f,...) if type(f)=="function" then local a=table.pack(...);task.spawn(function() pcall(function()f(table.unpack(a,1,a.n))end)end) end end

function UI:AddTheme(n,d) local c={};for k,v in pairs(T)do c[k]=v end;for k,v in pairs(d or {})do c[k]=v end;c.Name=n;self.Themes[n]=c;return c end
function UI:SetTheme(x) if type(x)=="string" and self.Themes[x] then T=self.Themes[x];self.Theme=T elseif type(x)=="table" then for k,v in pairs(x)do T[k]=v end end end

function UI:CreateWindow(o)
 o=o or {}; local gui=Instance.new("ScreenGui");gui.Name="RYEENZYXNZ_UI";gui.ResetOnSpawn=false;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.IgnoreGuiInset=true;gui.Parent=parent()
 local sc=Instance.new("UIScale");sc.Parent=gui
 local root=Instance.new("Frame");root.Size=o.Size or UDim2.fromOffset(920,600);root.Position=UDim2.fromScale(.5,.5);root.AnchorPoint=Vector2.new(.5,.5);root.BackgroundColor3=T.Background;root.BackgroundTransparency=T.Transparency;root.BorderSizePixel=0;root.Parent=gui;corner(root,T.CornerRadius);stroke(root,T.Stroke,.25)
 local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new(T.Surface2,T.Background);grad.Rotation=35;grad.Transparency=NumberSequence.new(.15);grad.Parent=root
 local top=Instance.new("Frame");top.Size=UDim2.new(1,0,0,58);top.BackgroundTransparency=1;top.Parent=root
 local logo=Instance.new("Frame");logo.Size=UDim2.fromOffset(38,38);logo.Position=UDim2.fromOffset(12,10);logo.BackgroundColor3=T.Accent;logo.Parent=top;corner(logo,11);local lr=label(logo,"R",21,Color3.new(1,1,1),true);lr.Size=UDim2.fromScale(1,1);lr.TextXAlignment=Enum.TextXAlignment.Center
 local tt=label(top,o.Title or "RYEENZYXNZ",16,T.Text,true);tt.Position=UDim2.fromOffset(60,7);tt.Size=UDim2.fromOffset(260,24)
 local st=label(top,o.Subtitle or "LIQUID GLASS UI LIBRARY",10,T.SubText);st.Position=UDim2.fromOffset(61,29);st.Size=UDim2.fromOffset(260,18)
 local search=Instance.new("TextBox");search.Size=UDim2.fromOffset(310,34);search.Position=UDim2.new(.5,-155,0,12);search.BackgroundColor3=T.Surface2;search.BackgroundTransparency=.2;search.PlaceholderText="Search features...";search.PlaceholderColor3=T.Muted;search.TextColor3=T.Text;search.TextSize=13;search.Font=Enum.Font.Gotham;search.ClearTextOnFocus=false;search.Parent=top;corner(search,10);stroke(search,T.Stroke,.55);pad(search,10)
 local close=Instance.new("TextButton");close.Text="×";close.TextSize=25;close.Font=Enum.Font.Gotham;close.TextColor3=T.Text;close.BackgroundTransparency=1;close.Size=UDim2.fromOffset(42,42);close.Position=UDim2.new(1,-50,0,8);close.Parent=top;close.MouseButton1Click:Connect(function()gui.Enabled=false end)
 local side=Instance.new("Frame");side.Position=UDim2.fromOffset(10,64);side.Size=UDim2.new(0,185,1,-74);side.BackgroundColor3=T.Surface;side.BackgroundTransparency=.18;side.Parent=root;corner(side,11);stroke(side,T.Stroke,.65);pad(side,10);list(side,6)
 local content=Instance.new("ScrollingFrame");content.Position=UDim2.fromOffset(205,64);content.Size=UDim2.new(1,-215,1,-74);content.BackgroundTransparency=1;content.BorderSizePixel=0;content.ScrollBarThickness=2;content.ScrollBarImageColor3=T.Accent;content.AutomaticCanvasSize=Enum.AutomaticSize.Y;content.Parent=root;pad(content,4);list(content,10)
 local win={Gui=gui,Root=root,Sidebar=side,Content=content,Tabs={},CurrentTab=nil,Scale=sc};table.insert(UI._windows,win)
 local dragging=false;local ds,ps
 top.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;ds=i.Position;ps=root.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dragging=false end end)end end)
 UserInputService.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-ds;root.Position=UDim2.new(ps.X.Scale,ps.X.Offset+d.X,ps.Y.Scale,ps.Y.Offset+d.Y)end end)
 local function scale()if o.AutoScale==false then return end;local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize;if v then sc.Scale=math.clamp(math.min(v.X/1100,v.Y/720),.65,1)end end
 if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(scale)end;scale()
 function win:SelectTab(t)for _,x in ipairs(self.Tabs)do x.Page.Visible=x==t;x.Button.BackgroundTransparency=x==t and 0 or 1;x.Button.BackgroundColor3=T.Accent end;self.CurrentTab=t end
 function win:CreateTab(a)
  a=a or {};local b=Instance.new("TextButton");b.Text="";b.AutoButtonColor=false;b.Size=UDim2.new(1,0,0,40);b.BackgroundColor3=T.Accent;b.BackgroundTransparency=1;b.Parent=side;corner(b,10)
  local ic=label(b,a.Icon and "◆" or "•",14,T.SubText,true);ic.Size=UDim2.fromOffset(28,40);ic.Position=UDim2.fromOffset(8,0);ic.TextXAlignment=Enum.TextXAlignment.Center
  local tx=label(b,a.Name or "Tab",13,T.Text,true);tx.Position=UDim2.fromOffset(40,0);tx.Size=UDim2.new(1,-45,1,0)
  local page=Instance.new("Frame");page.Name=a.Name or "Tab";page.Size=UDim2.new(1,0,0,0);page.AutomaticSize=Enum.AutomaticSize.Y;page.BackgroundTransparency=1;page.Visible=false;page.Parent=content;list(page,10)
  local tab={Window=win,Button=b,Page=page};table.insert(win.Tabs,tab);b.MouseButton1Click:Connect(function()win:SelectTab(tab)end);if not win.CurrentTab then win:SelectTab(tab)end
  function tab:Section(s)
   s=s or {};local f=Instance.new("Frame");f.Size=UDim2.new(1,0,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.BackgroundColor3=T.Surface;f.BackgroundTransparency=s.Box==false and 1 or .2;f.Parent=page;corner(f,T.CornerRadius);stroke(f,T.Stroke,.65);pad(f,12)
   local title=label(f,s.Title or "Section",s.TextSize or 15,T.Text,true);title.Size=UDim2.new(1,0,0,26)
   local body=Instance.new("Frame");body.Size=UDim2.new(1,0,0,0);body.Position=UDim2.fromOffset(0,30);body.AutomaticSize=Enum.AutomaticSize.Y;body.BackgroundTransparency=1;body.Parent=f;list(body,8)
   local sec={Body=body,Frame=f}
   function sec:Button(x)local bb=Instance.new("TextButton");bb.Text=x.Title or "Button";bb.TextColor3=T.Text;bb.TextSize=13;bb.Font=Enum.Font.GothamSemibold;bb.AutoButtonColor=false;bb.Size=UDim2.new(1,0,0,40);bb.BackgroundColor3=x.Color or T.Accent;bb.Parent=body;corner(bb,10);stroke(bb,T.Stroke,.45);bb.MouseButton1Click:Connect(function()call(x.Callback)end);return bb end
   function sec:Toggle(x)local state=x.Default or false;local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,48);r.BackgroundColor3=T.Surface2;r.BackgroundTransparency=.25;r.Parent=body;corner(r,10);stroke(r,T.Stroke,.78);local n=label(r,x.Title or "Toggle",13,T.Text,true);n.Position=UDim2.fromOffset(12,4);n.Size=UDim2.new(1,-70,0,22);local h=Instance.new("TextButton");h.Text="";h.Size=UDim2.fromOffset(44,24);h.Position=UDim2.new(1,-56,.5,-12);h.BackgroundColor3=T.Muted;h.AutoButtonColor=false;h.Parent=r;corner(h,12);local k=Instance.new("Frame");k.Size=UDim2.fromOffset(18,18);k.Position=UDim2.fromOffset(3,3);k.BackgroundColor3=Color3.new(1,1,1);k.Parent=h;corner(k,9);local function set(v,silent)state=not not v;tw(h,{BackgroundColor3=state and T.Accent or T.Muted});tw(k,{Position=state and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)});if not silent then call(x.Callback,state)end end;h.MouseButton1Click:Connect(function()set(not state)end);set(state,true);return{Get=function()return state end,Set=set,Instance=r}end
   function sec:Slider(x)local min=x.Min or 0;local max=x.Max or 100;local value=x.Default or min;local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,62);r.BackgroundColor3=T.Surface2;r.BackgroundTransparency=.25;r.Parent=body;corner(r,10);stroke(r,T.Stroke,.78);local n=label(r,x.Title or "Slider",13,T.Text,true);n.Position=UDim2.fromOffset(12,5);n.Size=UDim2.new(1,-70,0,20);local v=label(r,tostring(value),12,T.SubText);v.Position=UDim2.new(1,-62,0,5);v.Size=UDim2.fromOffset(50,20);v.TextXAlignment=Enum.TextXAlignment.Right;local bar=Instance.new("Frame");bar.Size=UDim2.new(1,-24,0,6);bar.Position=UDim2.fromOffset(12,38);bar.BackgroundColor3=T.Muted;bar.Parent=r;corner(bar,3);local fill=Instance.new("Frame");fill.BackgroundColor3=T.Accent;fill.Size=UDim2.new(0,0,1,0);fill.Parent=bar;corner(fill,3);local drag=false;local function set(z,silent)value=math.clamp(z,min,max);local a=(value-min)/(max-min);fill.Size=UDim2.new(a,0,1,0);v.Text=tostring(math.floor(value*100)/100);if not silent then call(x.Callback,value)end end;local function from(px)local a=math.clamp((px-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1);set(min+(max-min)*a)end;bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;from(i.Position.X)end end);UserInputService.InputChanged:Connect(function(i)if drag and i.UserInputType==Enum.UserInputType.MouseMovement then from(i.Position.X)end end);UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end);set(value,true);return{Get=function()return value end,Set=set,Instance=r}end
   function sec:Dropdown(x)local vals=x.Values or x.Options or {};local cur=x.Default or vals[1];local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,44);r.BackgroundColor3=T.Surface2;r.BackgroundTransparency=.25;r.Parent=body;corner(r,10);stroke(r,T.Stroke,.78);local n=label(r,x.Title or "Dropdown",13,T.Text,true);n.Position=UDim2.fromOffset(12,0);n.Size=UDim2.new(.5,0,1,0);local b=Instance.new("TextButton");b.Text=tostring(cur or "Select");b.TextColor3=T.Text;b.TextSize=12;b.Font=Enum.Font.Gotham;b.AutoButtonColor=false;b.BackgroundColor3=T.Surface;b.Size=UDim2.new(.48,-8,0,32);b.Position=UDim2.new(.52,0,0,6);b.Parent=r;corner(b,8);local menu;local function build()if menu then menu:Destroy()end;menu=Instance.new("Frame");menu.Size=UDim2.new(.48,-8,0,math.min(180,#vals*30+8));menu.Position=UDim2.new(.52,0,0,42);menu.BackgroundColor3=T.Surface;menu.Parent=r;corner(menu,8);stroke(menu,T.Stroke,.5);pad(menu,4);list(menu,3);for _,z in ipairs(vals)do local q=Instance.new("TextButton");q.Text=tostring(z);q.TextColor3=T.Text;q.TextSize=12;q.Font=Enum.Font.Gotham;q.AutoButtonColor=false;q.BackgroundColor3=T.Surface2;q.Size=UDim2.new(1,0,0,26);q.Parent=menu;corner(q,7);q.MouseButton1Click:Connect(function()cur=z;b.Text=tostring(z);menu:Destroy();menu=nil;call(x.Callback,z)end)end end;b.MouseButton1Click:Connect(function()if menu then menu:Destroy();menu=nil else build()end end);return{Get=function()return cur end,Select=function(_,z)cur=z;b.Text=tostring(z);call(x.Callback,z)end,Instance=r}end
   function sec:Input(x)local b=Instance.new("TextBox");b.PlaceholderText=x.Placeholder or "Enter text...";b.Text=x.Value or "";b.TextColor3=T.Text;b.PlaceholderColor3=T.Muted;b.TextSize=13;b.Font=Enum.Font.Gotham;b.BackgroundColor3=T.Surface2;b.Size=UDim2.new(1,0,0,42);b.Parent=body;corner(b,10);stroke(b,T.Stroke,.7);pad(b,12);b.FocusLost:Connect(function()call(x.Callback,b.Text)end);return{Get=function()return b.Text end,Set=function(_,z)b.Text=tostring(z)end,Instance=b}end
   function sec:Paragraph(x)local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,54);r.BackgroundColor3=T.Surface2;r.BackgroundTransparency=.25;r.Parent=body;corner(r,10);stroke(r,T.Stroke,.75);pad(r,8);local a=label(r,x.Title or "",x.TextSize or 14,T.Text,true);a.Size=UDim2.new(1,0,0,20);local d=label(r,x.Desc or "",12,T.SubText);d.Position=UDim2.fromOffset(0,20);d.Size=UDim2.new(1,0,0,28);return r end
   function sec:Divider()local d=Instance.new("Frame");d.Size=UDim2.new(1,0,0,1);d.BackgroundColor3=T.Stroke;d.BorderSizePixel=0;d.Parent=body;return d end
   return sec
  end
  return tab
 end
 function win:Notify(n)return UI:Notify(n)end
 function win:Destroy()gui:Destroy()end
 return win
end

function UI:Notify(o)o=o or {};local g=Instance.new("ScreenGui");g.Name="RYEENZYXNZ_Notifications";g.ResetOnSpawn=false;g.Parent=parent();local h=Instance.new("Frame");h.AnchorPoint=Vector2.new(1,1);h.Position=UDim2.new(1,-18,1,-18);h.Size=UDim2.fromOffset(330,300);h.BackgroundTransparency=1;h.Parent=g;list(h,8);local c=Instance.new("Frame");c.Size=UDim2.new(1,0,0,66);c.BackgroundColor3=T.Surface;c.Parent=h;corner(c,12);stroke(c,T.Stroke,.55);pad(c,10);local t=label(c,o.Title or "RYEENZYXNZ",14,T.Text,true);t.Size=UDim2.new(1,0,0,22);local d=label(c,o.Content or "",12,T.SubText);d.Position=UDim2.fromOffset(0,24);d.Size=UDim2.new(1,0,0,32);d.TextWrapped=true;task.delay(o.Duration or 3,function()if c.Parent then c:Destroy()end;if g.Parent then g:Destroy()end end);return c end
function UI:CreateConfig(name)local n=name or "default";local path="RYEENZYXNZ/"..n..".json";local c={};function c:Set(k,v)c[k]=v end;function c:Get(k,d)return c[k]==nil and d or c[k]end;function c:Save()if type(writefile)~="function"then return false,"writefile unavailable"end;if type(isfolder)=="function"and not isfolder("RYEENZYXNZ")and type(makefolder)=="function"then makefolder("RYEENZYXNZ")end;writefile(path,HttpService:JSONEncode(c));return true end;function c:Load()if type(isfile)~="function"or type(readfile)~="function"or not isfile(path)then return false end;local ok,d=pcall(HttpService.JSONDecode,HttpService,readfile(path));if not ok then return false end;for k,v in pairs(d)do c[k]=v end;return true end;return c end

return UI
