--[[
    VoidUI - Checkbox Component
    Square checkbox with checkmark animation and label.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Checkbox = setmetatable({}, {__index = Component})
Checkbox.__index = Checkbox

function Checkbox.new(options, parent)
    local self = Component.new("Checkbox")
    setmetatable(self, {__index = Checkbox})
    
    self.Config = Core.Utils.Merge({
        Name = "Checkbox",
        Text = "Checkbox",
        Default = false,
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
    }, options)
    
    self._value = self.Config.Default
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    self:_applyState(false)
    
    return self
end

function Checkbox:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("TextButton", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 1,
    })
    self.Instance = container
    self._button = container
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    -- Checkbox box
    local box = Core.Create("Frame", {
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = theme.Component.Background,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, container)
    self._box = box
    
    local boxCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, box)
    
    local boxStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.5,
    }, box)
    self._boxStroke = boxStroke
    
    -- Check icon
    local check = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914136",
        ImageColor3 = theme.Text.OnAccent,
        ImageTransparency = 1,
        ZIndex = 3,
    }, box)
    self._check = check
    
    -- Label
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 2,
    }, container)
    self._label = label
    
    -- Click handler
    container.MouseButton1Click:Connect(function()
        self:SetValue(not self._value)
    end)
    
    AnimationSystem:AddHover(box, {BackgroundColor3 = theme.Component.Hover}, 0.15)
end

function Checkbox:_applyState(animate)
    local theme = ThemeSystem:Current()
    
    if self._value then
        AnimationSystem:Tween(self._box, {BackgroundColor3 = theme.Accent}, animate ~= false and 0.2 or 0)
        AnimationSystem:Tween(self._check, {ImageTransparency = 0}, animate ~= false and 0.2 or 0)
        if self._boxStroke then
            AnimationSystem:Tween(self._boxStroke, {Color = theme.Accent, Transparency = 0}, 0.2)
        end
    else
        AnimationSystem:Tween(self._box, {BackgroundColor3 = theme.Component.Background}, animate ~= false and 0.2 or 0)
        AnimationSystem:Tween(self._check, {ImageTransparency = 1}, animate ~= false and 0.2 or 0)
        if self._boxStroke then
            AnimationSystem:Tween(self._boxStroke, {Color = theme.Border.Default, Transparency = 0.5}, 0.2)
        end
    end
end

function Checkbox:SetValue(value, fireCallback)
    if self._value == value then return end
    self._value = value
    self:_applyState()
    self.OnChanged:Fire(value)
    if fireCallback ~= false and self.Config.Callback then
        task.spawn(self.Config.Callback, value)
    end
end

function Checkbox:GetValue()
    return self._value
end

function Checkbox:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    self:_applyState(false)
    if self._boxStroke then
        self._boxStroke.Color = theme.Border.Default
    end
end

return Checkbox
