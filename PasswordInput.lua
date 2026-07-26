--[[
    VoidUI - Password Input Component
    Secure password input with show/hide toggle.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local PasswordInput = setmetatable({}, {__index = Component})
PasswordInput.__index = PasswordInput

function PasswordInput.new(options, parent)
    local self = Component.new("PasswordInput")
    setmetatable(self, {__index = PasswordInput})
    
    self.Config = Core.Utils.Merge({
        Name = "PasswordInput",
        Text = "Password",
        Placeholder = "Enter password...",
        Default = "",
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
    }, options)
    
    self._value = self.Config.Default
    self._masked = true
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    
    return self
end

function PasswordInput:_createUI()
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
    
    -- Label
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1,
    }, container)
    self._label = label
    
    -- Input row
    local inputRow = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, container)
    self._inputRow = inputRow
    
    local rowCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, inputRow)
    
    local rowStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, inputRow)
    self._rowStroke = rowStroke
    
    -- Input
    local input = Core.Create("TextBox", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = self:_maskValue(self.Config.Default),
        PlaceholderText = self.Config.Placeholder,
        PlaceholderColor3 = theme.Text.Tertiary,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, inputRow)
    self._input = input
    
    -- Toggle button (eye icon)
    local toggleBtn = Core.Create("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -32, 0, 2),
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 3,
    }, inputRow)
    self._toggleBtn = toggleBtn
    
    local toggleIcon = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914133",
        ImageColor3 = theme.Text.Tertiary,
        ZIndex = 4,
    }, toggleBtn)
    self._toggleIcon = toggleIcon
    
    toggleBtn.MouseButton1Click:Connect(function()
        self._masked = not self._masked
        input.Text = self:_maskValue(self._value)
        if not self._masked then
            toggleIcon.ImageColor3 = theme.Text.Primary
        else
            toggleIcon.ImageColor3 = theme.Text.Tertiary
        end
    end)
    
    input.FocusLost:Connect(function()
        if not self._masked then
            self._value = input.Text
        end
        self.OnChanged:Fire(self._value)
        if self.Config.Callback then
            task.spawn(self.Config.Callback, self._value)
        end
    end)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if not self._masked then
            self._value = input.Text
        end
    end)
end

function PasswordInput:_maskValue(value)
    if not self._masked then
        return value or ""
    end
    if not value then return "" end
    return string.rep("*", #value)
end

function PasswordInput:GetValue()
    return self._value
end

function PasswordInput:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._inputRow then
        self._inputRow.BackgroundColor3 = theme.Component.Background
    end
    if self._input then
        self._input.Font = theme.Font
        self._input.TextColor3 = theme.Text.Primary
        self._input.PlaceholderColor3 = theme.Text.Tertiary
    end
    if self._rowStroke then
        self._rowStroke.Color = theme.Border.Default
    end
end

return PasswordInput
