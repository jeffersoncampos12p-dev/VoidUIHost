--[[
    VoidUI - Input Component
    Simple text input without label, useful for forms.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Input = setmetatable({}, {__index = Component})
Input.__index = Input

function Input.new(options, parent)
    local self = Component.new("Input")
    setmetatable(self, {__index = Input})
    
    self.Config = Core.Utils.Merge({
        Name = "Input",
        Placeholder = "Enter text...",
        Default = "",
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
        Icon = nil,
    }, options)
    
    self._value = self.Config.Default
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    
    return self
end

function Input:_createUI()
    local theme = ThemeSystem:Current()
    
    local input = Core.Create("TextBox", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Text = self.Config.Default,
        PlaceholderText = self.Config.Placeholder,
        PlaceholderColor3 = theme.Text.Tertiary,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    self.Instance = input
    self._input = input
    
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, input)
    
    local stroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, input)
    self._stroke = stroke
    
    local padding = Core.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, input)
    
    input.FocusLost:Connect(function()
        self._value = input.Text
        self.OnChanged:Fire(self._value)
        if self.Config.Callback then
            task.spawn(self.Config.Callback, self._value)
        end
    end)
end

function Input:GetValue()
    return self._value
end

function Input:SetValue(value)
    self._value = value
    self._input.Text = value
end

function Input:_applyThemeImpl(theme)
    self._input.BackgroundColor3 = theme.Component.Background
    self._input.Font = theme.Font
    self._input.TextColor3 = theme.Text.Primary
    self._input.PlaceholderColor3 = theme.Text.Tertiary
    self._stroke.Color = theme.Border.Default
end

return Input
