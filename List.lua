--[[
    VoidUI | List Component
    A scrollable list with selectable items. Each item can have an icon,
    label, description, and trailing element. Supports single or multiple
    selection modes.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local List = {}
List.__index = List
setmetatable(List, { __index = Component })

function List.new(config, voidUI)
    local self = Component.new("List")
    setmetatable(self, { __index = List })

    config = config or {}
    self._items = config.Items or {}
    self._size = config.Size or UDim2.new(1, 0, 0, 200)
    self._selectable = config.Selectable ~= nil and config.Selectable or true
    self._selectedIndex = nil

    self.OnSelect = self:AddSignal("OnSelect")

    self:_createUI()
    return self
end

function List:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("ScrollingFrame", {
        Name = "List",
        BackgroundTransparency = 1,
        Size = self._size,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Component.ScrollBar,
        Parent = nil,
    })

    self._container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.Frame,
    })

    self._layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self._container,
    })

    for i, item in ipairs(self._items) do
        self:_createItem(i, item)
    end
end

function List:_createItem(index, item)
    local theme = Theme.Current()

    local row = Create("TextButton", {
        Name = "Item_" .. (item.Label or "Item"),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, 0, 0, 44),
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = index,
        Parent = self._container,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = row,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = row,
    })

    -- Icon (optional)
    if item.Icon then
        local icon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            Image = item.Icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = row,
        })
    end

    -- Text container
    local textContainer = Create("Frame", {
        Name = "TextContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = row,
    })

    local textLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })

    -- Label
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = item.Label or "Item",
        TextColor3 = theme.Text.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textContainer,
    })

    -- Description (optional)
    if item.Description then
        local desc = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.Font or Enum.Font.Gotham,
            Text = item.Description,
            TextColor3 = theme.Text.Tertiary,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = textContainer,
        })
    end

    -- Trailing element (optional, e.g. a badge or indicator)
    if item.Trailing then
        item.Trailing.Parent = row
    end

    -- Hover
    Anim.AddHover(row, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })

    -- Selection
    if self._selectable then
        row.MouseButton1Click:Connect(function()
            self:Select(index)
        end)
    end
end

function List:Select(index)
    local theme = Theme.Current()
    -- Deselect previous
    if self._selectedIndex then
        local prev = self._container:GetChildren()[self._selectedIndex]
        if prev then
            Anim.Tween(prev, { BackgroundColor3 = theme.Component.Background, BackgroundTransparency = 0.7 }, 0.15)
        end
    end

    self._selectedIndex = index
    local item = self._container:GetChildren()[index]
    if item then
        Anim.Tween(item, { BackgroundColor3 = theme.Accent.Primary, BackgroundTransparency = 0.8 }, 0.15)
    end

    self.OnSelect:Fire(self._items[index], index)
end

function List:AddItem(item)
    table.insert(self._items, item)
    self:_createItem(#self._items, item)
end

function List:Clear()
    self._items = {}
    self._selectedIndex = nil
    for _, child in ipairs(self._container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

function List:SetItems(items)
    self:Clear()
    self._items = items
    for i, item in ipairs(self._items) do
        self:_createItem(i, item)
    end
end

function List:_applyThemeImpl(theme)
    self.Frame.ScrollBarImageColor3 = theme.Component.ScrollBar
    for _, child in ipairs(self._container:GetChildren()) do
        if child:IsA("TextButton") then
            local isSelected = (child.LayoutOrder == self._selectedIndex)
            child.BackgroundColor3 = isSelected and theme.Accent.Primary or theme.Component.Background
        end
    end
end

return List
