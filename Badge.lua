--[[
    VoidUI - Badge Component
    Small status badge with text and color variants.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local Component = require(script.Component)

local Badge = setmetatable({}, {__index = Component})
Badge.__index = Badge

function Badge.new(options, parent)
    local self = Component.new("Badge")
    setmetatable(self, {__index = Badge})
    
    self.Config = Core.Utils.Merge({
        Name = "Badge",
        Text = "Badge",
        Variant = "Default", -- Default, Success, Warning, Error, Info
        Size = UDim2.new(0, 60, 0, 20),
        Icon = nil,
    }, options)
    
    self:_createUI()
    
    return self
end

function Badge:_createUI()
    local theme = ThemeSystem:Current()
    local colors = self:_getColors(theme)
    
    local badge = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundColor3 = colors.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    self.Instance = badge
    
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, badge)
    self._corner = corner
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, badge)
    
    if self.Config.Icon then
        local icon = Core.Create("ImageLabel", {
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            Image = self.Config.Icon,
            ImageColor3 = colors.Text,
            ZIndex = 2,
        }, badge)
        self._icon = icon
    end
    
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.XS,
        TextColor3 = colors.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 2,
    }, badge)
    self._label = label
    
    -- Use AutomaticSize
    badge.AutomaticSize = Enum.AutomaticSize.X
    label.AutomaticSize = Enum.AutomaticSize.X
end

function Badge:_getColors(theme)
    local variant = self.Config.Variant or "Default"
    local colors = {}
    
    if variant == "Success" then
        colors.Background = theme.Success
        colors.Text = theme.Text.OnAccent
    elseif variant == "Warning" then
        colors.Background = theme.Warning
        colors.Text = theme.Text.OnAccent
    elseif variant == "Error" then
        colors.Background = theme.Error
        colors.Text = theme.Text.OnAccent
    elseif variant == "Info" then
        colors.Background = theme.Info
        colors.Text = theme.Text.OnAccent
    else
        colors.Background = theme.Component.Active
        colors.Text = theme.Text.Primary
    end
    
    return colors
end

function Badge:SetText(text)
    self.Config.Text = text
    if self._label then
        self._label.Text = text
    end
end

function Badge:_applyThemeImpl(theme)
    local colors = self:_getColors(theme)
    self.Instance.BackgroundColor3 = colors.Background
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = colors.Text
    end
    if self._icon then
        self._icon.ImageColor3 = colors.Text
    end
end

return Badge
