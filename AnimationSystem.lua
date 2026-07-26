--[[
    VoidUI - Animation System
    Modern animation system with tweens, ripple effects,
    glow effects, and micro-animations for premium feel.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Core = require(script.Parent.core.VoidCore)

local AnimationSystem = {
    _enabled = true,
    _speed = 1.0,
    _quality = "Balanced",
    _glowCache = {},
    _ripplePool = {},
}

-- ============================================================
-- Settings
-- ============================================================

function AnimationSystem:SetEnabled(enabled)
    self._enabled = enabled
end

function AnimationSystem:IsEnabled()
    return self._enabled
end

function AnimationSystem:SetSpeed(speed)
    self._speed = speed
end

function AnimationSystem:GetSpeed()
    return self._speed
end

function AnimationSystem:SetQuality(quality)
    self._quality = quality
end

function AnimationSystem:GetQuality()
    return self._quality
end

-- Calculate adjusted duration based on speed and quality
local function getAdjustedDuration(duration)
    if not AnimationSystem._enabled then return 0 end
    
    local multiplier = AnimationSystem._speed
    if AnimationSystem._quality == "Fast" then
        multiplier = multiplier * 0.7
    elseif AnimationSystem._quality == "Smooth" then
        multiplier = multiplier * 1.3
    end
    
    return duration * multiplier
end

-- ============================================================
-- Tween Helpers
-- ============================================================

-- Basic tween
function AnimationSystem:Tween(object, properties, duration, style, direction)
    if not self._enabled then
        for prop, value in pairs(properties) do
            object[prop] = value
        end
        return nil
    end
    
    local adjDuration = getAdjustedDuration(duration)
    local tweenInfo = TweenInfo.new(
        adjDuration,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Smooth tween (slow in, slow out)
function AnimationSystem:Smooth(object, properties, duration)
    return self:Tween(object, properties, duration, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
end

-- Quick tween (snappy)
function AnimationSystem:Quick(object, properties, duration)
    return self:Tween(object, properties, duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- Slide in
function AnimationSystem:SlideIn(object, target, from)
    if not self._enabled then
        object.Position = target
        return
    end
    
    if from then
        object.Position = from
    end
    self:Tween(object, {Position = target}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

-- Fade in
function AnimationSystem:FadeIn(object, duration)
    if not self._enabled then
        object.Visible = true
        return
    end
    
    object.Visible = true
    local orig = {}
    for _, child in ipairs(object:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") or child:IsA("ImageLabel") then
            orig[child] = child.BackgroundTransparency
            child.BackgroundTransparency = 1
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                orig[child] = child.TextTransparency
                child.TextTransparency = 1
            end
        end
    end
    -- Simplified fade
    self:Tween(object, {BackgroundTransparency = 0}, duration or 0.3)
end

-- Fade out
function AnimationSystem:FadeOut(object, duration, callback)
    if not self._enabled then
        object.Visible = false
        if callback then callback() end
        return
    end
    local tween = self:Tween(object, {BackgroundTransparency = 1}, duration or 0.3)
    if callback then
        tween.Completed:Connect(callback)
    end
end

-- ============================================================
-- Ripple Effect
-- ============================================================
function AnimationSystem:CreateRipple(frame, position, color, size)
    if not self._enabled then return end
    
    -- Recycle from pool if available
    local ripple
    if #self._ripplePool > 0 then
        ripple = table.remove(self._ripplePool)
        ripple.Visible = true
    else
        ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.ZIndex = 100
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
    end
    
    ripple.Parent = frame
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Set initial position and size
    ripple.Position = UDim2.new(0, position.X, 0, position.Y)
    local startSize = UDim2.fromOffset(0, 0)
    ripple.Size = startSize
    
    -- Calculate max distance for ripple
    local frameSize = frame.AbsoluteSize
    local maxDim = math.max(frameSize.X, frameSize.Y)
    local endSize = UDim2.fromOffset(maxDim * 2, maxDim * 2)
    
    -- Initial state
    ripple.BackgroundTransparency = 0.6
    
    -- Animate
    local sizeTween = TweenService:Create(ripple, 
        TweenInfo.new(getAdjustedDuration(0.5), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = endSize, BackgroundTransparency = 1})
    sizeTween:Play()
    
    sizeTween.Completed:Connect(function()
        ripple.Visible = false
        ripple.Parent = nil
        -- Return to pool if pool is not too large
        if #self._ripplePool < 20 then
            table.insert(self._ripplePool, ripple)
        else
            ripple:Destroy()
        end
    end)
end

-- ============================================================
-- Glow Effect
-- ============================================================
function AnimationSystem:CreateGlow(object, color, intensity, radius)
    if not self._enabled then return nil end
    
    intensity = intensity or 1
    radius = radius or 20
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or Color3.fromRGB(120, 110, 240)
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(22, 22, 282, 282)
    glow.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    glow.ZIndex = object.ZIndex - 1
    glow.Size = UDim2.new(1, radius * 2, 1, radius * 2)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Parent = object
    
    -- Fade in
    self:Tween(glow, {ImageTransparency = 1 - (intensity * 0.6)}, 0.3)
    
    return {
        instance = glow,
        SetIntensity = function(self, newIntensity)
            local target = 1 - (newIntensity * 0.6)
            AnimationSystem:Tween(self.instance, {ImageTransparency = target}, 0.2)
        end,
        SetColor = function(self, newColor)
            self.instance.ImageColor3 = newColor
        end,
        Destroy = function(self)
            AnimationSystem:Tween(self.instance, {ImageTransparency = 1}, 0.3)
            task.delay(0.3, function()
                self.instance:Destroy()
            end)
        end,
    }
end

-- ============================================================
-- Hover Effect
-- ============================================================
function AnimationSystem:AddHover(object, properties, duration)
    local original = {}
    for prop, _ in pairs(properties) do
        original[prop] = object[prop]
    end
    
    local hover = false
    
    object.MouseEnter:Connect(function()
        if not self._enabled then return end
        hover = true
        self:Tween(object, properties, duration or 0.2)
    end)
    
    object.MouseLeave:Connect(function()
        if not self._enabled then return end
        hover = false
        self:Tween(object, original, duration or 0.2)
    end)
end

-- ============================================================
-- Press Effect
-- ============================================================
function AnimationSystem:AddPress(object, scale)
    scale = scale or 0.97
    
    object.MouseButton1Down:Connect(function()
        if not self._enabled then return end
        self:Tween(object, {Size = object.Size * UDim2.fromScale(scale, scale)}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)
    
    object.MouseButton1Up:Connect(function()
        if not self._enabled then return end
        self:Tween(object, {Size = object.Size / UDim2.fromScale(scale, scale)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

-- ============================================================
-- Pulse Animation
-- ============================================================
function AnimationSystem:Pulse(object, scale, duration, repeatCount)
    if not self._enabled then return end
    
    local originalSize = object.Size
    repeatCount = repeatCount or -1
    
    local tweenInfo = TweenInfo.new(
        getAdjustedDuration(duration or 1),
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        repeatCount,
        true
    )
    
    local tween = TweenService:Create(object, tweenInfo, {Size = originalSize * UDim2.fromScale(scale or 1.05, scale or 1.05)})
    tween:Play()
    return tween
end

-- ============================================================
-- Shake Animation
-- ============================================================
function AnimationSystem:Shake(object, intensity, duration)
    if not self._enabled then return end
    
    local originalPosition = object.Position
    intensity = intensity or 4
    duration = duration or 0.5
    
    local elapsed = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed >= duration then
            object.Position = originalPosition
            connection:Disconnect()
            return
        end
        local decay = 1 - (elapsed / duration)
        local offsetX = (math.random() - 0.5) * intensity * decay
        local offsetY = (math.random() - 0.5) * intensity * decay
        object.Position = originalPosition + UDim2.fromOffset(offsetX, offsetY)
    end)
    
    return function()
        if connection then
            object.Position = originalPosition
            connection:Disconnect()
        end
    end
end

-- ============================================================
-- Loading Spinner (rotating)
-- ============================================================
function AnimationSystem:StartSpinner(object, speed)
    if not self._enabled then return end
    
    speed = speed or 1
    local rotation = 0
    
    local connection = RunService.RenderStepped:Connect(function(dt)
        rotation = (rotation + (360 * speed * dt)) % 360
        object.Rotation = rotation
    end)
    
    return function()
        connection:Disconnect()
    end
end

-- ============================================================
-- Spring-like bounce
-- ============================================================
function AnimationSystem:Bounce(object, targetPosition, height)
    if not self._enabled then
        object.Position = targetPosition
        return
    end
    
    local original = object.Position
    
    self:Tween(object, {
        Position = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, targetPosition.Y.Scale, targetPosition.Y.Offset - (height or 20))
    }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.2, function()
        self:Tween(object, {Position = targetPosition}, 0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    end)
end

-- ============================================================
-- Sweep effect (gradient sweep across)
-- ============================================================
function AnimationSystem:Sweep(object, duration)
    if not self._enabled then return end
    
    local sweepFrame = Instance.new("Frame")
    sweepFrame.Name = "Sweep"
    sweepFrame.BackgroundTransparency = 1
    sweepFrame.Size = UDim2.new(0.4, 0, 1, 0)
    sweepFrame.Position = UDim2.new(-0.4, 0, 0, 0)
    sweepFrame.ZIndex = object.ZIndex + 1
    sweepFrame.ClipsDescendants = false
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(
        Color3.new(1, 1, 1),
        Color3.new(0.5, 0.5, 0.5)
    )
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 1),
    })
    gradient.Rotation = 20
    gradient.Parent = sweepFrame
    
    sweepFrame.Parent = object
    
    self:Tween(sweepFrame, {Position = UDim2.new(1, 0, 0, 0)}, duration or 0.6)
    
    task.delay((duration or 0.6) + 0.1, function()
        sweepFrame:Destroy()
    end)
end

return AnimationSystem
