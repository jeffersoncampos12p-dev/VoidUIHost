--[[
    VoidUI - Textbox Component
    Text input with label, placeholder, validation, and callback.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Textbox = setmetatable({}, {__index = Component})
Textbox.__index = Textbox

function Textbox.new(options, parent)
    local self = Component.new("Textbox")
    setmetatable(self, {__index = Textbox})
    
    self.Config = Core.Utils.Merge({
        Name = "Textbox",
        Text = "Textbox",
        Placeholder = "Enter text...",
        Default = "",
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
        Multiline = false,
        MaxLength = nil,
        ClearOnFocus = false,
        Numeric = false,
    }, options)
    
    self._value = self.Config.Default
    self.OnChanged = self:AddSignal("OnChanged")
    self.OnFocus = self:AddSignal("OnFocus")
    self.OnFocusLost = self:AddSignal("OnFocusLost")
    
    self:_createUI()
    
    return self
end

function Textbox:_createUI()
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
    
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        ZIndex = 1,
    }, container)
    self._label = label
    
    local input = Core.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Text = self.Config.Default,
        PlaceholderText = self.Config.Placeholder,
        PlaceholderColor3 = theme.Text.Tertiary,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = self.Config.ClearOnFocus,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, container)
    self._input = input
    
    if self.Config.MaxLength then
        input.MaxLength = self.Config.MaxLength
    end
    if self.Config.Multiline then
        input.Size = UDim2.new(1, 0, 0, 80)
        input.MultiLine = true
        input.TextWrapped = true
    end
    
    local inputCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, input)
    self._inputCorner = inputCorner
    
    local inputStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, input)
    self._inputStroke = inputStroke
    
    local inputPadding = Core.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, input)
    
    input.Focused:Connect(function()
        self.OnFocus:Fire()
        AnimationSystem:Tween(input, {BackgroundColor3 = theme.Component.Active, BackgroundTransparency = 0.1}, 0.2)
        AnimationSystem:Tween(inputStroke, {Color = theme.Accent, Transparency = 0}, 0.2)
    end)
    
    input.FocusLost:Connect(function(enterPressed)
        self._value = input.Text
        self.OnFocusLost:Fire(self._value, enterPressed)
        self.OnChanged:Fire(self._value)
        AnimationSystem:Tween(input, {BackgroundColor3 = theme.Component.Background, BackgroundTransparency = 0.3}, 0.2)
        AnimationSystem:Tween(inputStroke, {Color = theme.Border.Default, Transparency = 0.6}, 0.2)
        if self.Config.Callback then
            task.spawn(self.Config.Callback, self._value)
        end
    end)
    
    if self.Config.Numeric then
        input:GetPropertyChangedSignal("Text"):Connect(function()
            local text = input.Text
            if not text:match("^%d*$") then
                input.Text = text:gsub("%D", "")
            end
        end)
    end
end

function Textbox:GetValue()
    return self._value
end

function Textbox:SetValue(value)
    self._value = value
    self._input.Text = value
    self.OnChanged:Fire(value)
end

function Textbox:SetText(text)
    self.Config.Text = text
    if self._label then
        self._label.Text = text
    end
end

function Textbox:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._input then
        self._input.BackgroundColor3 = theme.Component.Background
        self._input.Font = theme.Font
        self._input.TextColor3 = theme.Text.Primary
        self._input.PlaceholderColor3 = theme.Text.Tertiary
    end
    if self._inputStroke then
        self._inputStroke.Color = theme.Border.Default
    end
end

return Textbox
