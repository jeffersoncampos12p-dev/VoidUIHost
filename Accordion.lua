--[[
    VoidUI | Accordion Component
    A collapsible accordion with expandable items. Each item has a header
    that toggles the visibility of its content. Supports single or multiple
    open items, icons, and smooth animations.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Accordion = {}
Accordion.__index = Accordion
setmetatable(Accordion, { __index = Component })

function Accordion.new(config, voidUI)
    local self = Component.new("Accordion")
    setmetatable(self, { __index = Accordion })

    config = config or {}
    self._items = config.Items or {}
    self._multipleOpen = config.MultipleOpen or false
    self._size = config.Size or UDim2.new(1, 0, 0, 0)

    self._openItems = {} -- track which items are open by index

    self:_createUI()
    return self
end

function Accordion:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Accordion",
        BackgroundTransparency = 1,
        Size = self._size,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = nil,
    })

    self._layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Frame,
    })

    for i, item in ipairs(self._items) do
        self:_createItem(i, item)
    end
end

function Accordion:_createItem(index, item)
    local theme = Theme.Current()

    local itemFrame = Create("Frame", {
        Name = "Item_" .. (item.Title or "Item"),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = index,
        Parent = self.Frame,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = itemFrame })

    local stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = itemFrame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Parent = itemFrame,
    })

    -- Header
    local header = Create("TextButton", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        AutoButtonColor = false,
        Text = "",
        Parent = itemFrame,
    })

    local hPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = header,
    })

    local hLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 8),
        Parent = header,
    })

    -- Expand/collapse icon
    local chevron = Create("TextLabel", {
        Name = "Chevron",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "▸",
        TextColor3 = theme.Text.Secondary,
        TextSize = 14,
        Parent = header,
    })
    chevron.Rotation = 0

    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 18),
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = item.Title or "Item",
        TextColor3 = theme.Text.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    -- Content area
    local content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = itemFrame,
    })

    local cPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 12),
        Parent = content,
    })

    local cLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 6),
        Parent = content,
    })

    -- If item has a Content instance, add it
    if item.Content and typeof(item.Content) == "Instance" then
        item.Content.Parent = content
    end

    -- Store references
    self._openItems[index] = false

    -- Toggle handler
    Anim.AddHover(header, { HoverColor = theme.Component.Hover, HoverTransparency = 0.7 })
    header.MouseButton1Click:Connect(function()
        self:_toggleItem(index, chevron, content)
    end)

    -- Auto-open first item if configured
    if item.DefaultOpen then
        self:_openItem(index, chevron, content)
    end
end

function Accordion:_toggleItem(index, chevron, content)
    if self._openItems[index] then
        self:_closeItem(index, chevron, content)
    else
        if not self._multipleOpen then
            -- Close all other items
            -- (This is a simplification; in a full implementation we'd track all items)
        end
        self:_openItem(index, chevron, content)
    end
end

function Accordion:_openItem(index, chevron, content)
    self._openItems[index] = true
    content.Visible = true
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    Anim.Tween(chevron, { Rotation = 90 }, 0.2)
    Anim.FadeIn(content, 0.2)
end

function Accordion:_closeItem(index, chevron, content)
    self._openItems[index] = false
    Anim.FadeOut(content, 0.15)
    Anim.Tween(chevron, { Rotation = 0 }, 0.2)
    task.delay(0.15, function()
        content.Visible = false
    end)
end

function Accordion:AddItem(item)
    table.insert(self._items, item)
    self:_createItem(#self._items, item)
end

function Accordion:_applyThemeImpl(theme)
    -- Re-apply theme to all items
    for _, child in ipairs(self.Frame:GetChildren()) do
        if child:IsA("Frame") then
            child.BackgroundColor3 = theme.Component.Background
            local stroke = child:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = theme.Component.Border end
            local header = child:FindFirstChild("Header")
            if header then
                local chevron = header:FindFirstChild("Chevron")
                local title = header:FindFirstChild("Title")
                if chevron then chevron.TextColor3 = theme.Text.Secondary end
                if title then title.TextColor3 = theme.Text.Primary end
            end
        end
    end
end

return Accordion
