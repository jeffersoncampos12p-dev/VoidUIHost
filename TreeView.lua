--[[
    VoidUI | TreeView Component
    A hierarchical tree view with expandable nodes. Each node can have
    children, an icon, and a label. Supports expand/collapse, selection,
    and nested indentation.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local TreeView = {}
TreeView.__index = TreeView
setmetatable(TreeView, { __index = Component })

function TreeView.new(config, voidUI)
    local self = Component.new("TreeView")
    setmetatable(self, { __index = TreeView })

    config = config or {}
    self._data = config.Data or {}
    self._size = config.Size or UDim2.new(1, 0, 0, 0)

    self.OnSelect = self:AddSignal("OnSelect")

    self:_createUI()
    return self
end

function TreeView:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("ScrollingFrame", {
        Name = "TreeView",
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

    self:_orderCounter = 0
    for _, node in ipairs(self._data) do
        self:_createNode(node, 0, self._container)
    end
end

function TreeView:_createNode(node, depth, parent)
    local theme = Theme.Current()
    self._orderCounter = self._orderCounter + 1

    local hasChildren = node.Children and #node.Children > 0

    -- Node container
    local nodeFrame = Create("Frame", {
        Name = "Node_" .. (node.Label or "Node"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._orderCounter,
        Parent = parent,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 1),
        Parent = nodeFrame,
    })

    -- Node row
    local row = Create("TextButton", {
        Name = "Row",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = 1,
        Parent = nodeFrame,
    })

    -- Indentation
    local indent = Create("UIPadding", {
        PaddingLeft = UDim.new(0, depth * 16),
        Parent = row,
    })

    local rowLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = row,
    })

    -- Expand/collapse chevron (only if has children)
    local chevron
    if hasChildren then
        chevron = Create("TextLabel", {
            Name = "Chevron",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 14, 0, 14),
            Font = Enum.Font.GothamBold,
            Text = "▸",
            TextColor3 = theme.Text.Tertiary,
            TextSize = 12,
            Parent = row,
        })
    else
        -- Spacer for alignment
        chevron = Create("Frame", {
            Name = "Spacer",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 14, 0, 14),
            Parent = row,
        })
    end

    -- Icon (optional)
    if node.Icon then
        local icon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            Image = node.Icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = row,
        })
    end

    -- Label
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 18),
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = node.Label or "Node",
        TextColor3 = theme.Text.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    -- Children container (hidden by default)
    local childrenContainer
    if hasChildren then
        childrenContainer = Create("Frame", {
            Name = "Children",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            LayoutOrder = 2,
            Parent = nodeFrame,
        })

        for _, child in ipairs(node.Children) do
            self:_createNode(child, depth + 1, childrenContainer)
        end
    end

    -- Interactions
    Anim.AddHover(row, { HoverColor = theme.Component.Hover, HoverTransparency = 0.7 })

    if hasChildren and chevron:IsA("TextLabel") then
        row.MouseButton1Click:Connect(function()
            local isExpanded = childrenContainer.Visible
            if isExpanded then
                childrenContainer.Visible = false
                Anim.Tween(chevron, { Rotation = 0 }, 0.2)
            else
                childrenContainer.Visible = true
                Anim.FadeIn(childrenContainer, 0.2)
                Anim.Tween(chevron, { Rotation = 90 }, 0.2)
            end
        end)
    end

    row.MouseButton1Click:Connect(function()
        self.OnSelect:Fire(node)
    end)
end

function TreeView:SetData(data)
    self._data = data
    -- Clear existing
    for _, child in ipairs(self._container:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    self._orderCounter = 0
    for _, node in ipairs(self._data) do
        self:_createNode(node, 0, self._container)
    end
end

function TreeView:_applyThemeImpl(theme)
    self.Frame.ScrollBarImageColor3 = theme.Component.ScrollBar
    -- Recursively apply theme
    local function applyThemeRecursive(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextLabel") then
                if child.Name == "Label" then
                    child.TextColor3 = theme.Text.Primary
                elseif child.Name == "Chevron" then
                    child.TextColor3 = theme.Text.Tertiary
                end
            elseif child:IsA("ImageLabel") and child.Name == "Icon" then
                child.ImageColor3 = theme.Text.Secondary
            elseif child:IsA("Frame") or child:IsA("TextButton") then
                applyThemeRecursive(child)
            end
        end
    end
    applyThemeRecursive(self._container)
end

return TreeView
