--[[
    RYEENZYXNZ UI V3 — Animations Module
    Reusable tween helpers and preset animations.
]]

local TweenService = game:GetService("TweenService")

local Animations = {}

-- ─── Core Tween ────────────────────────────────────────────────
function Animations.Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Animations.Spring(obj, props, duration)
    -- Roblox has no Enum.EasingStyle.Spring; Back provides a safe overshoot.
    local info = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Animations.Fast(obj, props)
    return Animations.Tween(obj, props, 0.15)
end

function Animations.Slow(obj, props)
    return Animations.Tween(obj, props, 0.5)
end

function Animations.Linear(obj, props, duration)
    local info = TweenInfo.new(duration or 1, Enum.EasingStyle.Linear)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ─── Preset: Fade In ───────────────────────────────────────────
function Animations.FadeIn(obj, duration)
    obj.BackgroundTransparency = 1
    return Animations.Tween(obj, { BackgroundTransparency = 0 }, duration or 0.3)
end

function Animations.FadeOut(obj, duration, callback)
    local t = Animations.Tween(obj, { BackgroundTransparency = 1 }, duration or 0.3)
    if callback then
        t.Completed:Connect(callback)
    end
    return t
end

-- ─── Preset: Slide Open (vertical) ─────────────────────────────
function Animations.SlideOpen(frame, targetHeight, duration)
    frame.ClipsDescendants = true
    frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0)
    frame.Visible = true
    return Animations.Tween(
        frame,
        { Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, targetHeight) },
        duration or 0.25
    )
end

function Animations.SlideClose(frame, duration, callback)
    local t = Animations.Tween(
        frame,
        { Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0) },
        duration or 0.2
    )
    t.Completed:Connect(function()
        frame.Visible = false
        if callback then callback() end
    end)
    return t
end

-- ─── Preset: Pop (scale bounce) ────────────────────────────────
-- Note: uses UIScale if present, otherwise direct size.
function Animations.Pop(frame, duration)
    local scale = frame:FindFirstChildOfClass("UIScale")
    if scale then
        scale.Scale = 0.85
        return Animations.Spring(scale, { Scale = 1 }, duration or 0.4)
    end
    local origSize = frame.Size
    frame.Size = UDim2.new(
        origSize.X.Scale, origSize.X.Offset * 0.85,
        origSize.Y.Scale, origSize.Y.Offset * 0.85
    )
    return Animations.Spring(frame, { Size = origSize }, duration or 0.4)
end

-- ─── Preset: Pulse glow (for notifications, accent elements) ───
function Animations.Pulse(obj, targetColor, originalColor, duration)
    duration = duration or 0.6
    Animations.Tween(obj, { BackgroundColor3 = targetColor }, duration / 2)
    task.delay(duration / 2, function()
        Animations.Tween(obj, { BackgroundColor3 = originalColor }, duration / 2)
    end)
end

-- ─── Preset: Shake (for error feedback) ─────────────────────────
function Animations.Shake(obj, intensity, times)
    intensity = intensity or 4
    times     = times     or 4
    local origPos = obj.Position
    local count   = 0

    local function doShake()
        if count >= times * 2 then
            obj.Position = origPos
            return
        end
        local dir = (count % 2 == 0) and intensity or -intensity
        Animations.Tween(
            obj,
            { Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + dir, origPos.Y.Scale, origPos.Y.Offset) },
            0.05,
            Enum.EasingStyle.Linear
        )
        count += 1
        task.delay(0.05, doShake)
    end

    doShake()
end

-- ─── Button hover helpers ───────────────────────────────────────
function Animations.ButtonHover(btn, hoverTransparency, normalTransparency)
    hoverTransparency  = hoverTransparency  or 0.15
    normalTransparency = normalTransparency or 0.4

    btn.MouseEnter:Connect(function()
        Animations.Fast(btn, { BackgroundTransparency = hoverTransparency })
    end)
    btn.MouseLeave:Connect(function()
        Animations.Fast(btn, { BackgroundTransparency = normalTransparency })
    end)
    btn.MouseButton1Down:Connect(function()
        Animations.Fast(btn, { BackgroundTransparency = 0.05 })
    end)
    btn.MouseButton1Up:Connect(function()
        Animations.Fast(btn, { BackgroundTransparency = hoverTransparency })
    end)
end

return Animations
