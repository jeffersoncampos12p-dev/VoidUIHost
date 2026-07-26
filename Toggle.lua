--[[
    VoidUI - Toggle Component
    Modern iOS-style toggle switch with smooth animations,
    label, and callback support.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Toggle = setmetatable({}, {__index = Component})
Toggle.__index = Toggle

-- ============================================================
-- Toggle Factory
-- ============================================================
function Toggle.new(options, parent)
    local self = Component.new("Toggle")
    setmetatable(self, {__index = Toggle})
    
    self.Config = Core.Utils.Merge({
        Name = "Toggle",
        Text = "Toggle",
        Default = false,
        Callback = nil,
        Disabled = false,
        Size = UDim2.new(1, 0, 0, 32),
        Description = nil,
    }, options)
    
    self._parent = parent
    self._value = self.Config.Default
    self._disabled = self.Config.Disabled
    
    -- Toggle events
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    
    -- Initialize state
    self:_applyState(false)
    
    return self
end

-- ============================================================
-- UI Creation
-- ============================================================
function Toggle:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("TextButton", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    self.Instance = container
    self._button = container
    
    -- Layout
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    -- Label/Description container
    local labelContainer = Core.Create("Frame", {
        Size = UDim2.new(1, -52, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, container)
    self._labelContainer = labelContainer
    
    -- Vertical layout for label and description
    local labelLayout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, labelContainer)
    
    -- Label
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 2,
    }, labelContainer)
    self._label = label
    
    -- Description (optional)
    if self.Config.Description then
        local desc = Core.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = self.Config.Description,
            Font = theme.Font,
            TextSize = theme.TextSize.XS,
            TextColor3 = theme.Text.Tertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.Ellipsis,
            TextTransparency = 0.6,
            ZIndex = 2,
        }, labelContainer)
        self._desc = desc
    end
    
    -- Toggle switch background (the rail)
    local rail = Core.Create("Frame", {
        Name = "Rail",
        Size = UDim2.fromOffset(44, 24),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, container)
    self._rail = rail
    
    -- Rail corner (pill shape)
    local railCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, rail)
    self._railCorner = railCorner
    
    -- Rail stroke
    local railStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.7,
    }, rail)
    self._railStroke = railStroke
    
    -- Knob (the circle)
    local knob = Core.Create("Frame", {
        Name = "Knob",
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = theme.Text.Secondary,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, rail)
    self._knob = knob
    
    -- Knob corner
    local knobCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, knob)
    self._knobCorner = knobCorner
    
    -- Click handler
    container.MouseButton1Click:Connect(function()
        if self._disabled then return end
        self:SetValue(not self._value)
    end)
end

-- ============================================================
-- State Management
-- ============================================================
function Toggle:_applyState(animate)
    local theme = ThemeSystem:Current()
    local animation = animate ~= false
    
    if self._value then
        -- ON state
        if animation then
            AnimationSystem:Tween(self._rail, {BackgroundColor3 = theme.Accent, BackgroundTransparency = 0}, 0.2)
            AnimationSystem:Tween(self._knob, {Position = UDim2.fromOffset(23, 3), BackgroundColor3 = theme.Text.OnAccent}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self._rail.BackgroundColor3 = theme.Accent
            self._rail.BackgroundTransparency = 0
            self._knob.Position = UDim2.fromOffset(23, 3)
            self._knob.BackgroundColor3 = theme.Text.OnAccent
        end
    else
        -- OFF state
        if animation then
            AnimationSystem:Tween(self._rail, {BackgroundColor3 = theme.Component.Background, BackgroundTransparency = 0.3}, 0.2)
            AnimationSystem:Tween(self._knob, {Position = UDim2.fromOffset(3, 3), BackgroundColor3 = theme.Text.Secondary}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self._rail.BackgroundColor3 = theme.Component.Background
            self._rail.BackgroundTransparency = 0.3
            self._knob.Position = UDim2.fromOffset(3, 3)
            self._knob.BackgroundColor3 = theme.Text.Secondary
        end
    end
end

-- ============================================================
-- Setters / Getters
-- ============================================================
function Toggle:SetValue(value, fireCallback)
    if self._value == value then return end
    self._value = value
    self:_applyState()
    self.OnChanged:Fire(value)
    if fireCallback ~= false and self.Config.Callback then
        task.spawn(self.Config.Callback, value)
    end
end

function Toggle:GetValue()
    return self._value
end

function Toggle:SetText(text)
    self.Config.Text = text
    if self._label then
        self._label.Text = text
    end
end

function Toggle:SetDisabled(disabled)
    self._disabled = disabled
    if disabled then
        AnimationSystem:Tween(self._rail, {BackgroundTransparency = 0.8}, 0.2)
        if self._label then
            AnimationSystem:Tween(self._label, {TextTransparency = 0.5}, 0.2)
        end
    else
        self:_applyState()
    end
end

function Toggle:SetCallback(callback)
    self.Config.Callback = callback
end

-- ============================================================
-- Theme Application
-- ============================================================
function Toggle:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._desc then
        self._desc.Font = theme.Font
        self._desc.TextColor3 = theme.Text.Tertiary
    end
    self:_applyState(false)
    if self._railStroke then
        self._railStroke.Color = theme.Border.Default
    end
end

return Toggle
