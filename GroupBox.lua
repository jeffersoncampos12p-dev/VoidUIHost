--[[
    VoidUI | GroupBox Component
    A container that groups related components with a title, border, and
    optional description. Useful for organizing content within sections.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local GroupBox = {}
GroupBox.__index = GroupBox
setmetatable(GroupBox, { __index = Component })

function GroupBox.new(config, voidUI)
    local self = Component.new("GroupBox")
    setmetatable(self, { __index = GroupBox })

    config = config or {}
    self._title = config.Title or "Group"
    self._description = config.Description or nil
    self._size = config.Size or UDim2.new(1, 0, 0, 0)

    self:_createUI()
    return self
end

function GroupBox:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "GroupBox",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Size = self._size,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = nil,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, theme.CornerRadius or 8),
        Parent = self.Frame,
    })

    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = theme.Stroke.Thickness or 1,
        Transparency = theme.Stroke.Transparency or 0.5,
        Parent = self.Frame,
    })

    -- Padding container
    local container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = container,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container,
    })

    -- Title
    self.Title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = theme.Font or Enum.Font.GothamBold,
        Text = self._title,
        TextColor3 = theme.Text.Primary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        Parent = container,
    })

    -- Description (optional)
    if self._description then
        self.Description = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.Font or Enum.Font.Gotham,
            Text = self._description,
            TextColor3 = theme.Text.Secondary,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            Parent = container,
        })
    end

    -- Content area
    self.Content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Parent = container,
    })

    local contentLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Content,
    })

    self._container = container
end

function GroupBox:AddComponent(instance)
    instance.Parent = self.Content
    return instance
end

function GroupBox:SetTitle(title)
    self._title = title
    if self.Title then self.Title.Text = title end
end

function GroupBox:SetDescription(description)
    self._description = description
    if self.Description then
        self.Description.Text = description
    elseif description then
        local theme = Theme.Current()
        self.Description = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.Font or Enum.Font.Gotham,
            Text = description,
            TextColor3 = theme.Text.Secondary,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            Parent = self._container,
        })
    end
end

function GroupBox:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Component.Background
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.Title then self.Title.TextColor3 = theme.Text.Primary end
    if self.Description then self.Description.TextColor3 = theme.Text.Secondary end
end

return GroupBox
