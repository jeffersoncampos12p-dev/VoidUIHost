--[[
    VoidUI - Label Component
    Simple text label with rich text support.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local Component = require(script.Component)

local Label = setmetatable({}, {__index = Component})
Label.__index = Label

function Label.new(options, parent)
    local self = Component.new("Label")
    setmetatable(self, {__index = Label})
    
    self.Config = Core.Utils.Merge({
        Name = "Label",
        Text = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        RichText = true,
        TextWrapped = false,
        TextSize = nil,
        TextColor = nil,
        TextAlignment = Enum.TextXAlignment.Left,
    }, options)
    
    self._parent = parent
    
    self:_createUI()
    
    return self
end

function Label:_createUI()
    local theme = ThemeSystem:Current()
    
    local label = Core.Create("TextLabel", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = self.Config.TextSize or theme.TextSize.Small,
        TextColor3 = self.Config.TextColor or theme.Text.Secondary,
        TextXAlignment = self.Config.TextAlignment,
        RichText = self.Config.RichText,
        TextWrapped = self.Config.TextWrapped,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 1,
    })
    self.Instance = label
    self._label = label
end

function Label:SetText(text)
    self.Config.Text = text
    self._label.Text = text
end

function Label:_applyThemeImpl(theme)
    self._label.Font = theme.Font
    self._label.TextColor3 = self.Config.TextColor or theme.Text.Secondary
end

return Label
