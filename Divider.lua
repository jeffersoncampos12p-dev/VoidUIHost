--[[
    VoidUI - Divider Component
    A horizontal or vertical divider line.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local Component = require(script.Component)

local Divider = setmetatable({}, {__index = Component})
Divider.__index = Divider

function Divider.new(options, parent)
    local self = Component.new("Divider")
    setmetatable(self, {__index = Divider})
    
    self.Config = Core.Utils.Merge({
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        Direction = "Horizontal",
        Thickness = 1,
        Text = nil,
    }, options)
    
    self:_createUI()
    
    return self
end

function Divider:_createUI()
    local theme = ThemeSystem:Current()
    
    if self.Config.Text then
        -- Divider with text in the middle
        local container = Core.Create("Frame", {
            Name = self.Config.Name,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            ZIndex = 1,
        })
        self.Instance = container
        self._container = container
        
        local layout = Core.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, container)
        
        -- Left line
        local leftLine = Core.Create("Frame", {
            Size = UDim2.new(0.5, -4, 0, 1),
            BackgroundColor3 = theme.Border.Default,
            BorderSizePixel = 0,
            ZIndex = 1,
        }, container)
        self._leftLine = leftLine
        
        -- Text
        local text = Core.Create("TextLabel", {
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundTransparency = 1,
            Text = self.Config.Text,
            Font = theme.Font,
            TextSize = theme.TextSize.XS,
            TextColor3 = theme.Text.Tertiary,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 2,
        }, container)
        self._text = text
        
        -- Right line
        local rightLine = Core.Create("Frame", {
            Size = UDim2.new(0.5, -4, 0, 1),
            BackgroundColor3 = theme.Border.Default,
            BorderSizePixel = 0,
            ZIndex = 1,
        }, container)
        self._rightLine = rightLine
    else
        -- Simple line
        local isVertical = self.Config.Direction == "Vertical"
        local line = Core.Create("Frame", {
            Name = self.Config.Name,
            Size = self.Config.Size,
            BackgroundColor3 = theme.Border.Default,
            BorderSizePixel = 0,
            ZIndex = 1,
        })
        self.Instance = line
        self._line = line
    end
end

function Divider:_applyThemeImpl(theme)
    if self._line then
        self._line.BackgroundColor3 = theme.Border.Default
    end
    if self._leftLine then
        self._leftLine.BackgroundColor3 = theme.Border.Default
    end
    if self._rightLine then
        self._rightLine.BackgroundColor3 = theme.Border.Default
    end
    if self._text then
        self._text.Font = theme.Font
        self._text.TextColor3 = theme.Text.Tertiary
    end
end

return Divider
