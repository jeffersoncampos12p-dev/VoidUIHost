--[[
    VoidUI - Paragraph Component
    Longer text paragraph with wrapping and styling.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local Component = require(script.Component)

local Paragraph = setmetatable({}, {__index = Component})
Paragraph.__index = Paragraph

function Paragraph.new(options, parent)
    local self = Component.new("Paragraph")
    setmetatable(self, {__index = Paragraph})
    
    self.Config = Core.Utils.Merge({
        Name = "Paragraph",
        Text = "",
        Size = UDim2.new(1, 0, 0, 0),
        RichText = true,
        TextWrapped = true,
        TextSize = nil,
        TextColor = nil,
        Title = nil,
    }, options)
    
    self._parent = parent
    
    self:_createUI()
    
    return self
end

function Paragraph:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    self.Instance = container
    self._container = container
    
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Medium,
    }, container)
    self._corner = corner
    
    local stroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.7,
    }, container)
    self._stroke = stroke
    
    local padding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
    }, container)
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    -- Title (optional)
    if self.Config.Title then
        local title = Core.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = self.Config.Title,
            Font = theme.Font,
            TextSize = theme.TextSize.Medium,
            TextColor3 = theme.Text.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true,
            ZIndex = 2,
        }, container)
        self._title = title
    end
    
    -- Paragraph text
    local text = Core.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = self.Config.TextSize or theme.TextSize.Small,
        TextColor3 = self.Config.TextColor or theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = self.Config.RichText,
        TextWrapped = self.Config.TextWrapped,
        ZIndex = 2,
    }, container)
    self._text = text
end

function Paragraph:SetText(text)
    self.Config.Text = text
    self._text.Text = text
end

function Paragraph:_applyThemeImpl(theme)
    if self._title then
        self._title.Font = theme.Font
        self._title.TextColor3 = theme.Text.Primary
    end
    if self._text then
        self._text.Font = theme.Font
        self._text.TextColor3 = self.Config.TextColor or theme.Text.Secondary
    end
    self._container.BackgroundColor3 = theme.Component.Background
    if self._stroke then
        self._stroke.Color = theme.Border.Default
    end
end

return Paragraph
