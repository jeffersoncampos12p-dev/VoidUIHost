--[[
    VoidUI | StatusIndicator Component
    A small dot indicator showing status (online, offline, busy, away, etc.)
    with optional text label and pulsing animation.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local StatusIndicator = {}
StatusIndicator.__index = StatusIndicator
setmetatable(StatusIndicator, { __index = Component })

local STATUS_COLORS = {
    Online = Color3.fromRGB(76, 175, 80),
    Offline = Color3.fromRGB(120, 120, 120),
    Busy = Color3.fromRGB(244, 67, 54),
    Away = Color3.fromRGB(255, 193, 7),
    Available = Color3.fromRGB(76, 175, 80),
    Invisible = Color3.fromRGB(80, 80, 80),
}

function StatusIndicator.new(config, voidUI)
    local self = Component.new("StatusIndicator")
    setmetatable(self, { __index = StatusIndicator })

    config = config or {}
    self._status = config.Status or "Online"
    self._text = config.Text or nil
    self._pulse = config.Pulse ~= nil and config.Pulse or true
    self._size = config.Size or 10

    self:_createUI()
    return self
end

function StatusIndicator:_createUI()
    local theme = Theme.Current()
    local dotColor = STATUS_COLORS[self._status] or STATUS_COLORS.Online

    self.Frame = Create("Frame", {
        Name = "StatusIndicator",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.XY,
        Parent = nil,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.Frame,
    })

    -- Dot container for pulse ring
    self.DotContainer = Create("Frame", {
        Name = "DotContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, self._size + 6, 0, self._size + 6),
        Parent = self.Frame,
    })

    -- Pulse ring
    self.PulseRing = Create("Frame", {
        Name = "PulseRing",
        BackgroundColor3 = dotColor,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.DotContainer,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.PulseRing })

    -- Main dot
    self.Dot = Create("Frame", {
        Name = "Dot",
        BackgroundColor3 = dotColor,
        Size = UDim2.new(0, self._size, 0, self._size),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.DotContainer,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Dot })

    -- White ring around dot
    local ring = Create("UIStroke", {
        Color = theme.Background.Main,
        Thickness = 2,
        Parent = self.Dot,
    })
    self.Ring = ring

    -- Text label (optional)
    if self._text then
        self.Label = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = self._text,
            TextColor3 = theme.Text.Secondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Frame,
        })
    end

    if self._pulse then
        self:_startPulse()
    end
end

function StatusIndicator:_startPulse()
    if self._pulseConn then self._pulseConn:Disconnect() end
    self._pulseConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.PulseRing then return end
        local t = tick()
        local alpha = (math.sin(t * 3) + 1) / 2 -- oscillate 0..1
        self.PulseRing.BackgroundTransparency = 0.5 + alpha * 0.5
        local scale = 1 + alpha * 0.4
        self.PulseRing.Size = UDim2.new(scale, 0, scale, 0)
    end)
end

function StatusIndicator:SetStatus(status)
    self._status = status
    local color = STATUS_COLORS[status] or STATUS_COLORS.Online
    if self.Dot then
        Anim.Tween(self.Dot, { BackgroundColor3 = color }, 0.2)
    end
    if self.PulseRing then
        self.PulseRing.BackgroundColor3 = color
    end
end

function StatusIndicator:SetText(text)
    self._text = text
    if self.Label then
        self.Label.Text = text
    else
        -- Create label if it didn't exist
        local theme = Theme.Current()
        self.Label = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = text,
            TextColor3 = theme.Text.Secondary,
            TextSize = 12,
            Parent = self.Frame,
        })
    end
end

function StatusIndicator:SetPulse(enabled)
    self._pulse = enabled
    if enabled then
        self:_startPulse()
    else
        if self._pulseConn then
            self._pulseConn:Disconnect()
            self._pulseConn = nil
        end
        if self.PulseRing then
            self.PulseRing.BackgroundTransparency = 1
        end
    end
end

function StatusIndicator:_applyThemeImpl(theme)
    if self.Ring then self.Ring.Color = theme.Background.Main end
    if self.Label then self.Label.TextColor3 = theme.Text.Secondary end
end

function StatusIndicator:Destroy()
    if self._pulseConn then
        self._pulseConn:Disconnect()
        self._pulseConn = nil
    end
    Component.Destroy(self)
end

return StatusIndicator
