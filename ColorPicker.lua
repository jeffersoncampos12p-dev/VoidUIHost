--[[
    VoidUI - ColorPicker Component
    Modern color picker with HSV color wheel and hex input.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)
local UserInputService = game:GetService("UserInputService")

local ColorPicker = setmetatable({}, {__index = Component})
ColorPicker.__index = ColorPicker

function ColorPicker.new(options, parent)
    local self = Component.new("ColorPicker")
    setmetatable(self, {__index = ColorPicker})
    
    self.Config = Core.Utils.Merge({
        Name = "ColorPicker",
        Text = "Color",
        Default = Color3.fromRGB(120, 110, 240),
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
    }, options)
    
    self._value = self.Config.Default
    self._expanded = false
    self._hue = 0.5
    self._sat = 1
    self._val = 1
    
    self.OnChanged = self:AddSignal("OnChanged")
    
    -- Convert default color to HSV
    self:_updateHSVFromColor()
    
    self:_createUI()
    
    return self
end

function ColorPicker:_updateHSVFromColor()
    local h, s, v = Color3.toHSV(self._value)
    self._hue = h
    self._sat = s
    self._val = v
end

function ColorPicker:_createUI()
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
    
    -- Button
    local button = Core.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 2,
    }, container)
    self._button = button
    
    local buttonCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, button)
    self._buttonCorner = buttonCorner
    
    local buttonStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, button)
    self._buttonStroke = buttonStroke
    
    -- Color swatch
    local swatch = Core.Create("Frame", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(4, 4),
        BackgroundColor3 = self._value,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, button)
    self._swatch = swatch
    
    local swatchCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, swatch)
    
    -- Hex display
    local hexDisplay = Core.Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.fromOffset(32, 0),
        BackgroundTransparency = 1,
        Text = Core.Color.ToHex(self._value),
        Font = theme.FontMono,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, button)
    self._hexDisplay = hexDisplay
    
    -- Dropdown chevron
    local chevron = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(1, -14, 0.5, -7),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914130",
        ImageColor3 = theme.Text.Tertiary,
        Rotation = 90,
        ZIndex = 3,
    }, button)
    self._chevron = chevron
    
    -- Picker panel (initially hidden)
    local panel = Core.Create("Frame", {
        Name = "Panel",
        Size = UDim2.new(1, 0, 0, 180),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
    }, container)
    self._panel = panel
    
    local panelCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, panel)
    
    local panelStroke = Core.Create("UIStroke", {
        Color = theme.Border.Hover,
        Thickness = theme.Stroke.Size,
        Transparency = 0.5,
    }, panel)
    self._panelStroke = panelStroke
    
    local panelPadding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, panel)
    
    -- Saturation/Value area
    local svArea = Core.Create("Frame", {
        Size = UDim2.new(1, -24, 0, 100),
        BackgroundColor3 = Color3.fromHSV(self._hue, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 21,
    }, panel)
    self._svArea = svArea
    
    local svCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, svArea)
    
    -- SV gradient (saturation left to right)
    local satGradient = Core.Create("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
    }, svArea)
    
    -- Value gradient (top to bottom)
    local valGradient = Core.Create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        }),
    }, svArea)
    
    -- SV cursor
    local svCursor = Core.Create("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.fromScale(self._sat, 1 - self._val),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 22,
    }, svArea)
    self._svCursor = svCursor
    
    local svCursorCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, svCursor)
    local svCursorStroke = Core.Create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1.5,
    }, svCursor)
    
    -- Hue slider
    local hueSlider = Core.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 100),
        Position = UDim2.new(1, -14, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 21,
    }, panel)
    self._hueSlider = hueSlider
    
    local hueSliderCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, hueSlider)
    
    -- Hue gradient (rainbow)
    local hueGradient = Core.Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
    }, hueSlider)
    
    -- Hue cursor
    local hueCursor = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, self._hue, -4),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 22,
    }, hueSlider)
    self._hueCursor = hueCursor
    
    local hueCursorCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, hueCursor)
    local hueCursorStroke = Core.Create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
    }, hueCursor)
    
    -- Hex input
    local hexInput = Core.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.fromOffset(0, 116),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Text = Core.Color.ToHex(self._value),
        Font = theme.FontMono,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        PlaceholderText = "#RRGGBB",
        PlaceholderColor3 = theme.Text.Tertiary,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 21,
    }, panel)
    self._hexInput = hexInput
    
    local hexInputCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, hexInput)
    
    -- Drag handling for SV area
    local svDragging = false
    
    local function updateSV(input)
        local areaPos = svArea.AbsolutePosition
        local areaSize = svArea.AbsoluteSize
        local relX = (input.Position.X - areaPos.X) / areaSize.X
        local relY = (input.Position.Y - areaPos.Y) / areaSize.Y
        self._sat = math.max(0, math.min(1, relX))
        self._val = 1 - math.max(0, math.min(1, relY))
        self:_updateColor()
    end
    
    svArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            updateSV(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSV(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
        end
    end)
    
    -- Hue slider dragging
    local hueDragging = false
    
    local function updateHue(input)
        local sliderPos = hueSlider.AbsolutePosition
        local sliderSize = hueSlider.AbsoluteSize
        local relY = (input.Position.Y - sliderPos.Y) / sliderSize.Y
        self._hue = math.max(0, math.min(1, relY))
        self:_updateColor()
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            updateHue(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateHue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    -- Hex input handler
    hexInput.FocusLost:Connect(function(enterPressed)
        local text = hexInput.Text:gsub("#", "")
        if #text == 6 then
            local color = Core.Color.Hex(text)
            self._value = color
            self:_updateHSVFromColor()
            self:_updateColor(false)
            self.OnChanged:Fire(self._value)
            if self.Config.Callback then
                task.spawn(self.Config.Callback, self._value)
            end
        else
            hexInput.Text = Core.Color.ToHex(self._value)
        end
    end)
    
    -- Button click
    button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    AnimationSystem:AddHover(button, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0.1}, 0.15)
    
    UserInputService.InputBegan:Connect(function(input)
        if self._expanded and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = button.AbsolutePosition
            local buttonSize = button.AbsoluteSize
            local panelPos = panel.AbsolutePosition
            local panelSize = panel.AbsoluteSize
            
            if not Core.Utils.InBounds(mousePos.X, mousePos.Y, buttonPos.X, buttonPos.Y, buttonPos.X + buttonSize.X, buttonPos.Y + buttonSize.Y) and
               not Core.Utils.InBounds(mousePos.X, mousePos.Y, panelPos.X, panelPos.Y, panelPos.X + panelSize.X, panelPos.Y + panelSize.Y) then
                self:Close()
            end
        end
    end)
end

function ColorPicker:_updateColor(fireCallback)
    if fireCallback == nil then fireCallback = true end
    self._value = Color3.fromHSV(self._hue, self._sat, self._val)
    
    -- Update swatch
    self._swatch.BackgroundColor3 = self._value
    self._hexDisplay.Text = Core.Color.ToHex(self._value)
    if self._hexInput then
        self._hexInput.Text = Core.Color.ToHex(self._value)
    end
    
    -- Update SV cursor position
    if self._svCursor then
        self._svCursor.Position = UDim2.fromScale(self._sat, 1 - self._val)
    end
    
    -- Update SV area base color
    if self._svArea then
        self._svArea.BackgroundColor3 = Color3.fromHSV(self._hue, 1, 1)
    end
    
    -- Update hue cursor
    if self._hueCursor then
        self._hueCursor.Position = UDim2.new(0, 0, self._hue, -4)
    end
    
    if fireCallback then
        self.OnChanged:Fire(self._value)
        if self.Config.Callback then
            task.spawn(self.Config.Callback, self._value)
        end
    end
end

function ColorPicker:Toggle()
    if self._expanded then
        self:Close()
    else
        self:Open()
    end
end

function ColorPicker:Open()
    if self._expanded then return end
    self._expanded = true
    self._panel.Visible = true
    self._panel.Size = UDim2.new(1, 0, 0, 0)
    AnimationSystem:Tween(self._panel, {Size = UDim2.new(1, 0, 0, 180)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._chevron, {Rotation = -90}, 0.2)
end

function ColorPicker:Close()
    if not self._expanded then return end
    self._expanded = false
    AnimationSystem:Tween(self._panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._chevron, {Rotation = 90}, 0.2)
    task.delay(0.2, function()
        if not self._expanded then
            self._panel.Visible = false
        end
    end)
end

function ColorPicker:GetValue()
    return self._value
end

function ColorPicker:SetValue(color, fireCallback)
    self._value = color
    self:_updateHSVFromColor()
    self:_updateColor(fireCallback)
end

function ColorPicker:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._button then
        self._button.BackgroundColor3 = theme.Component.Background
    end
    if self._buttonStroke then
        self._buttonStroke.Color = theme.Border.Default
    end
    if self._hexDisplay then
        self._hexDisplay.Font = theme.FontMono
        self._hexDisplay.TextColor3 = theme.Text.Primary
    end
    if self._chevron then
        self._chevron.ImageColor3 = theme.Text.Tertiary
    end
    if self._hexInput then
        self._hexInput.BackgroundColor3 = theme.Component.Background
        self._hexInput.TextColor3 = theme.Text.Primary
    end
    if self._panel then
        self._panel.BackgroundColor3 = theme.Component.Background
    end
end

return ColorPicker
