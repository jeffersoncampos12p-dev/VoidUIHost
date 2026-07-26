--[[
    VoidUI - Button Component
    Modern button with ripple effect, hover, press animation,
    icon support, and variants.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Button = setmetatable({}, {__index = Component})
Button.__index = Button

-- ============================================================
-- Button Factory
-- ============================================================
function Button.new(options, parent)
    local self = Component.new("Button")
    setmetatable(self, {__index = Button})
    
    self.Config = Core.Utils.Merge({
        Name = "Button",
        Text = "Click Me",
        Icon = nil,
        Size = UDim2.new(1, 0, 0, 32),
        Callback = nil,
        Style = "Primary", -- Primary, Secondary, Ghost, Danger, Success
        Disabled = false,
        Loading = false,
    }, options)
    
    self._parent = parent
    
    -- Button events
    self.OnClick = self:AddSignal("OnClick")
    
    self:_createUI()
    
    return self
end

-- ============================================================
-- UI Creation
-- ============================================================
function Button:_createUI()
    local theme = ThemeSystem:Current()
    local colors = self:_getColors(theme)
    
    local btn = Core.Create("TextButton", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundColor3 = colors.Background,
        BackgroundTransparency = colors.Transparency,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    self.Instance = btn
    self._button = btn
    
    -- Corner
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, btn)
    self._corner = corner
    
    -- Stroke
    local stroke = Core.Create("UIStroke", {
        Color = colors.Stroke,
        Thickness = theme.Stroke.Size,
        Transparency = 0.8,
    }, btn)
    self._stroke = stroke
    
    -- Gradient (subtle)
    if self.Config.Style == "Primary" then
        local gradient = Core.Create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Accent),
                ColorSequenceKeypoint.new(1, theme.AccentGradient),
            }),
        }, btn)
        self._gradient = gradient
    end
    
    -- Content frame
    local content = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, btn)
    self._content = content
    
    -- Layout
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)
    
    -- Icon
    if self.Config.Icon then
        local icon = Core.Create("ImageLabel", {
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            Image = self.Config.Icon,
            ImageColor3 = colors.Text,
            ZIndex = 3,
        }, content)
        self._icon = icon
    end
    
    -- Label
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = colors.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 3,
    }, content)
    self._label = label
    
    -- Hover effect
    AnimationSystem:AddHover(btn, {BackgroundColor3 = colors.Hover}, 0.15)
    
    -- Ripple effect
    self:AddRipple(btn, Color3.fromRGB(255, 255, 255))
    
    -- Click handler
    btn.MouseButton1Click:Connect(function()
        if self.Config.Disabled or self.Config.Loading then return end
        self.OnClick:Fire()
        if self.Config.Callback then
            task.spawn(self.Config.Callback)
        end
    end)
    
    -- Press animation
    AnimationSystem:AddPress(btn, 0.97)
end

-- ============================================================
-- Get colors based on style
-- ============================================================
function Button:_getColors(theme)
    local style = self.Config.Style or "Primary"
    local colors = {}
    
    if style == "Primary" then
        colors.Background = theme.Accent
        colors.Hover = theme.AccentHover
        colors.Text = theme.Text.OnAccent
        colors.Stroke = theme.Accent
        colors.Transparency = 0
    elseif style == "Secondary" then
        colors.Background = theme.Component.Background
        colors.Hover = theme.Component.Hover
        colors.Text = theme.Text.Primary
        colors.Stroke = theme.Border.Default
        colors.Transparency = 0.5
    elseif style == "Ghost" then
        colors.Background = theme.Component.Background
        colors.Hover = theme.Component.Hover
        colors.Text = theme.Text.Secondary
        colors.Stroke = theme.Border.Default
        colors.Transparency = 1
    elseif style == "Danger" then
        colors.Background = theme.Error
        colors.Hover = Color3.fromRGB(255, 100, 120)
        colors.Text = theme.Text.OnAccent
        colors.Stroke = theme.Error
        colors.Transparency = 0
    elseif style == "Success" then
        colors.Background = theme.Success
        colors.Hover = Color3.fromRGB(100, 220, 150)
        colors.Text = theme.Text.OnAccent
        colors.Stroke = theme.Success
        colors.Transparency = 0
    else
        colors.Background = theme.Accent
        colors.Hover = theme.AccentHover
        colors.Text = theme.Text.OnAccent
        colors.Stroke = theme.Accent
        colors.Transparency = 0
    end
    
    return colors
end

-- ============================================================
-- Setters
-- ============================================================
function Button:SetText(text)
    self.Config.Text = text
    if self._label then
        self._label.Text = text
    end
end

function Button:SetIcon(icon)
    self.Config.Icon = icon
    if self._icon then
        self._icon.Image = icon
    end
end

function Button:SetDisabled(disabled)
    self.Config.Disabled = disabled
    local theme = ThemeSystem:Current()
    if disabled then
        AnimationSystem:Tween(self._button, {BackgroundTransparency = 0.8}, 0.2)
        if self._label then
            AnimationSystem:Tween(self._label, {TextTransparency = 0.5}, 0.2)
        end
    else
        AnimationSystem:Tween(self._button, {BackgroundTransparency = 0}, 0.2)
        if self._label then
            AnimationSystem:Tween(self._label, {TextTransparency = 0}, 0.2)
        end
    end
end

function Button:SetLoading(loading)
    self.Config.Loading = loading
    -- Could add spinner here
end

function Button:SetStyle(style)
    self.Config.Style = style
    local theme = ThemeSystem:Current()
    local colors = self:_getColors(theme)
    self._button.BackgroundColor3 = colors.Background
    if self._label then
        self._label.TextColor3 = colors.Text
    end
    if self._stroke then
        self._stroke.Color = colors.Stroke
    end
    if self._gradient then
        self._gradient:Destroy()
    end
    if style == "Primary" then
        local gradient = Core.Create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Accent),
                ColorSequenceKeypoint.new(1, theme.AccentGradient),
            }),
        }, self._button)
        self._gradient = gradient
    end
end

-- ============================================================
-- Theme Application
-- ============================================================
function Button:_applyThemeImpl(theme)
    local colors = self:_getColors(theme)
    self._button.BackgroundColor3 = colors.Background
    self._button.BackgroundTransparency = colors.Transparency
    if self._stroke then
        self._stroke.Color = colors.Stroke
    end
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = colors.Text
    end
    if self._icon then
        self._icon.ImageColor3 = colors.Text
    end
end

return Button
