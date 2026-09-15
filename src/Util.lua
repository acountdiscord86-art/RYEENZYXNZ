local Util = {}

function Util.new(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

function Util.corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

function Util.stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

function Util.padding(parent, px)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.PaddingLeft = UDim.new(0, px)
    p.PaddingRight = UDim.new(0, px)
    p.Parent = parent
    return p
end

function Util.list(parent, padding, horizontal)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    l.VerticalAlignment = Enum.VerticalAlignment.Top
    l.Parent = parent
    return l
end

function Util.tween(obj, info, props)
    local TweenService = game:GetService("TweenService")
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Util.bindHover(button, normal, hover)
    button.MouseEnter:Connect(function()
        Util.tween(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = hover})
    end)
    button.MouseLeave:Connect(function()
        Util.tween(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = normal})
    end)
end

function Util.text(parent, text, size, color, bold)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color
    label.TextSize = size or 14
    label.Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

return Util
