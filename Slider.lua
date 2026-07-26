--[[
    VoidUI - Slider Component
    Modern slider with smooth dragging, value display,
    min/max, and step options.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)
local UserInputService = game:GetService("UserInputService")

local Slider = setmetatable({}, {__index = Component})
Slider.__index = Slider

function Slider.new(options, parent)
    local self = Component.new("Slider")
    setmetatable(self, {__index = Slider})
    
    self.Config = Core.Utils.Merge({
        Name = "Slider",
        Text = "Slider",
        Min = 0,
        Max = 100,
        Default = 50,
        Step = 1,
        Suffix = "",
        Prefix = "",
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 40),
        Format = nil,
    }, options)
    
    self._value = self.Config.Default
    self._dragging = false
    
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    self:_applyValue(false)
    
    return self
end

function Slider:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 1,
    })
    self.Instance = container
    
    -- Layout
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    -- Label row
    local labelRow = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, container)
    self._labelRow = labelRow
    
    -- Label
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        ZIndex = 2,
    }, labelRow)
    self._label = label
    
    -- Value display
    local valueDisplay = Core.Create("TextLabel", {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = self:_formatValue(self._value),
        Font = theme.FontMono,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 2,
    }, labelRow)
    self._valueDisplay = valueDisplay
    
    -- Slider track container
    local trackContainer = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, container)
    self._trackContainer = trackContainer
    
    -- Center the track vertically
    local trackVerticalAlign = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromScale(0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, trackContainer)
    -- Override
    trackVerticalAlign:Destroy()
    
    -- Track background (full)
    local track = Core.Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -8, 0, 4),
        Position = UDim2.fromOffset(4, 7),
        BackgroundColor3 = theme.Component.Background,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, trackContainer)
    self._track = track
    
    -- Track corner (pill)
    local trackCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, track)
    
    -- Filled portion
    local filled = Core.Create("Frame", {
        Name = "Filled",
        Size = UDim2.fromScale(0.5, 1),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, track)
    self._filled = filled
    
    local filledCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, filled)
    
    -- Filled gradient
    local filledGradient = Core.Create("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentGradient),
        }),
    }, filled)
    self._filledGradient = filledGradient
    
    -- Knob
    local knob = Core.Create("Frame", {
        Name = "Knob",
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Text.OnAccent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, track)
    self._knob = knob
    
    local knobCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, knob)
    self._knobCorner = knobCorner
    
    local knobStroke = Core.Create("UIStroke", {
        Color = theme.Accent,
        Thickness = 2,
        Transparency = 0.5,
    }, knob)
    
    -- Drag handling
    local function updateValue(input)
        local trackSize = track.AbsoluteSize.X
        local trackPos = track.AbsolutePosition.X
        local relX = (input.Position.X - trackPos) / trackSize
        relX = math.max(0, math.min(1, relX))
        
        local raw = self.Config.Min + (self.Config.Max - self.Config.Min) * relX
        -- Apply step
        if self.Config.Step then
            raw = math.floor(raw / self.Config.Step + 0.5) * self.Config.Step
        end
        raw = math.max(self.Config.Min, math.min(self.Config.Max, raw))
        raw = Core.Utils.Round(raw, 2)
        
        self:SetValue(raw)
    end
    
    -- Drag handling
    local dragging = false
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            AnimationSystem:Tween(knob, {Size = UDim2.fromOffset(20, 20)}, 0.15)
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
            AnimationSystem:Tween(knob, {Size = UDim2.fromOffset(20, 20)}, 0.15)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                AnimationSystem:Tween(knob, {Size = UDim2.fromOffset(16, 16)}, 0.15)
            end
        end
    end)
end

function Slider:_formatValue(value)
    if self.Config.Format then
        return self.Config.Format(value)
    end
    return (self.Config.Prefix or "") .. tostring(value) .. (self.Config.Suffix or "")
end

function Slider:_applyValue(animate)
    local percent = (self._value - self.Config.Min) / (self.Config.Max - self.Config.Min)
    percent = math.max(0, math.min(1, percent))
    
    if animate then
        AnimationSystem:Tween(self._filled, {Size = UDim2.fromScale(percent, 1)}, 0.1)
    else
        self._filled.Size = UDim2.fromScale(percent, 1)
    end
    
    if self._valueDisplay then
        self._valueDisplay.Text = self:_formatValue(self._value)
    end
end

function Slider:SetValue(value, fireCallback)
    value = math.max(self.Config.Min, math.min(self.Config.Max, value))
    if self.Config.Step then
        value = math.floor(value / self.Config.Step + 0.5) * self.Config.Step
    end
    value = Core.Utils.Round(value, 2)
    
    if self._value == value then return end
    self._value = value
    self:_applyValue(true)
    self.OnChanged:Fire(value)
    if fireCallback ~= false and self.Config.Callback then
        task.spawn(self.Config.Callback, value)
    end
end

function Slider:GetValue()
    return self._value
end

function Slider:SetText(text)
    self.Config.Text = text
    if self._label then
        self._label.Text = text
    end
end

function Slider:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._valueDisplay then
        self._valueDisplay.Font = theme.FontMono
        self._valueDisplay.TextColor3 = theme.Text.Secondary
    end
    if self._track then
        self._track.BackgroundColor3 = theme.Component.Background
    end
    if self._filled then
        self._filled.BackgroundColor3 = theme.Accent
    end
    if self._filledGradient then
        self._filledGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentGradient),
        })
    end
    if self._knob then
        self._knob.BackgroundColor3 = theme.Text.OnAccent
    end
end

return Slider
