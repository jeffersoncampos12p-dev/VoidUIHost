--[[
    VoidUI - Progress Bar Component
    Progress bar with smooth animation, optional label, and value display.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local ProgressBar = setmetatable({}, {__index = Component})
ProgressBar.__index = ProgressBar

function ProgressBar.new(options, parent)
    local self = Component.new("ProgressBar")
    setmetatable(self, {__index = ProgressBar})
    
    self.Config = Core.Utils.Merge({
        Name = "ProgressBar",
        Text = "Progress",
        Min = 0,
        Max = 100,
        Default = 0,
        ShowLabel = true,
        ShowValue = true,
        Size = UDim2.new(1, 0, 0, 36),
        Color = nil,
    }, options)
    
    self._value = self.Config.Default
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    self:_applyValue(false)
    
    return self
end

function ProgressBar:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 1,
    })
    self.Instance = container
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    -- Label and value
    if self.Config.ShowLabel then
        local labelRow = Core.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            ZIndex = 1,
        }, container)
        
        local label = Core.Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = self.Config.Text,
            Font = theme.Font,
            TextSize = theme.TextSize.Small,
            TextColor3 = theme.Text.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
        }, labelRow)
        self._label = label
        
        if self.Config.ShowValue then
            local valueText = Core.Create("TextLabel", {
                Size = UDim2.new(0, 50, 1, 0),
                Position = UDim2.new(1, -50, 0, 0),
                BackgroundTransparency = 1,
                Text = "0%",
                Font = theme.FontMono,
                TextSize = theme.TextSize.Small,
                TextColor3 = theme.Text.Secondary,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2,
            }, labelRow)
            self._valueText = valueText
        end
    end
    
    -- Track
    local track = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = theme.Component.Background,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, container)
    self._track = track
    
    local trackCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, track)
    self._trackCorner = trackCorner
    
    -- Fill
    local fill = Core.Create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = self.Config.Color or theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, track)
    self._fill = fill
    
    local fillCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, fill)
    
    -- Gradient
    local fillGradient = Core.Create("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentGradient),
        }),
    }, fill)
    self._fillGradient = fillGradient
end

function ProgressBar:_applyValue(animate)
    local percent = (self._value - self.Config.Min) / (self.Config.Max - self.Config.Min)
    percent = math.max(0, math.min(1, percent))
    
    if animate then
        AnimationSystem:Tween(self._fill, {Size = UDim2.fromScale(percent, 1)}, 0.3)
    else
        self._fill.Size = UDim2.fromScale(percent, 1)
    end
    
    if self._valueText then
        self._valueText.Text = tostring(math.floor(percent * 100)) .. "%"
    end
end

function ProgressBar:SetValue(value, fireCallback)
    value = math.max(self.Config.Min, math.min(self.Config.Max, value))
    self._value = value
    self:_applyValue(true)
    self.OnChanged:Fire(value)
end

function ProgressBar:GetValue()
    return self._value
end

function ProgressBar:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._valueText then
        self._valueText.Font = theme.FontMono
        self._valueText.TextColor3 = theme.Text.Secondary
    end
    if self._track then
        self._track.BackgroundColor3 = theme.Component.Background
    end
    if self._fill then
        self._fill.BackgroundColor3 = self.Config.Color or theme.Accent
    end
    if self._fillGradient then
        self._fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentGradient),
        })
    end
end

return ProgressBar
