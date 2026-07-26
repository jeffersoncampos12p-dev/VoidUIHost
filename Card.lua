--[[
    VoidUI - Card Component
    A card container with title, description, and optional image.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Card = setmetatable({}, {__index = Component})
Card.__index = Card

function Card.new(options, parent)
    local self = Component.new("Card")
    setmetatable(self, {__index = Card})
    
    self.Config = Core.Utils.Merge({
        Name = "Card",
        Title = "Card Title",
        Description = "",
        Image = nil,
        Size = UDim2.new(1, 0, 0, 100),
        OnClick = nil,
    }, options)
    
    self._onClick = self:AddSignal("OnClick")
    
    self:_createUI()
    
    return self
end

function Card:_createUI()
    local theme = ThemeSystem:Current()
    
    local card = Core.Create("TextButton", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    self.Instance = card
    self._card = card
    
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Medium,
    }, card)
    
    local stroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, card)
    self._stroke = stroke
    
    local padding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
    }, card)
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, card)
    
    -- Image (optional)
    if self.Config.Image then
        local image = Core.Create("ImageLabel", {
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = theme.Background.Deep,
            BackgroundTransparency = 0.5,
            Image = self.Config.Image,
            ScaleType = Enum.ScaleType.Crop,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, card)
        self._image = image
        
        local imageCorner = Core.Create("UICorner", {
            CornerRadius = theme.Corner.Small,
        }, image)
    end
    
    -- Title
    local title = Core.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = self.Config.Title,
        Font = theme.Font,
        TextSize = theme.TextSize.Medium,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        ZIndex = 2,
    }, card)
    self._title = title
    
    -- Description
    if self.Config.Description and #self.Config.Description > 0 then
        local desc = Core.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = self.Config.Description,
            Font = theme.Font,
            TextSize = theme.TextSize.Small,
            TextColor3 = theme.Text.Tertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 2,
        }, card)
        self._desc = desc
    end
    
    -- Hover effect
    AnimationSystem:AddHover(card, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0.1}, 0.15)
    AnimationSystem:AddPress(card, 0.98)
    self:AddRipple(card, Color3.fromRGB(255, 255, 255))
    
    card.MouseButton1Click:Connect(function()
        self._onClick:Fire()
        if self.Config.OnClick then
            task.spawn(self.Config.OnClick)
        end
    end)
end

function Card:_applyThemeImpl(theme)
    if self._card then
        self._card.BackgroundColor3 = theme.Component.Background
    end
    if self._stroke then
        self._stroke.Color = theme.Border.Default
    end
    if self._title then
        self._title.Font = theme.Font
        self._title.TextColor3 = theme.Text.Primary
    end
    if self._desc then
        self._desc.Font = theme.Font
        self._desc.TextColor3 = theme.Text.Tertiary
    end
    if self._image then
        self._image.BackgroundColor3 = theme.Background.Deep
    end
end

return Card
