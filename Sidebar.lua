--[[
    VoidUI | Sidebar Component
    A vertical navigation sidebar with logo, nav items, and optional
    footer section. Supports icons, active indicators, collapse/expand,
    and tooltips.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Sidebar = {}
Sidebar.__index = Sidebar
setmetatable(Sidebar, { __index = Component })

function Sidebar.new(config, voidUI)
    local self = Component.new("Sidebar")
    setmetatable(self, { __index = Sidebar })

    config = config or {}
    self._items = config.Items or {}
    self._logo = config.Logo or "V"
    self._title = config.Title or "VoidUI"
    self._width = config.Width or 240
    self._collapsible = config.Collapsible or false
    self._collapsed = config.Collapsed or false

    self.OnNavigate = self:AddSignal("OnNavigate")
    self.OnToggle = self:AddSignal("OnToggle")

    self:_createUI()
    return self
end

function Sidebar:_createUI()
    local theme = Theme.Current()

    local actualWidth = self._collapsed and 64 or self._width

    self.Frame = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Background.Side or theme.Component.Background,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, actualWidth, 1, 0),
        Parent = nil,
    })

    local stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        Parent = self.Frame,
    })

    -- Logo/Brand area
    local brand = Create("Frame", {
        Name = "Brand",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Frame,
    })

    local brandLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = brand,
    })

    local logo = Create("Frame", {
        Name = "Logo",
        BackgroundColor3 = theme.Accent.Primary,
        Size = UDim2.new(0, 32, 0, 32),
        Parent = brand,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = logo })

    local logoText = Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = self._logo,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Parent = logo,
    })
    self.LogoFrame = logo

    -- Brand title (hidden when collapsed)
    self.BrandTitle = Create("TextLabel", {
        Name = "BrandTitle",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamBold,
        Text = self._title,
        TextColor3 = theme.Text.Primary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = not self._collapsed,
        Parent = brand,
    })

    -- Nav items
    self._navContainer = Create("Frame", {
        Name = "NavItems",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Frame,
    })

    local navLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        Parent = self._navContainer,
    })

    self._navButtons = {}
    for i, item in ipairs(self._items) do
        self:_createNavItem(i, item)
    end

    -- Collapse button (optional)
    if self._collapsible then
        local collapseBtn = Create("TextButton", {
            Name = "Collapse",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamBold,
            Text = self._collapsed and "›" or "‹",
            TextColor3 = theme.Text.Secondary,
            TextSize = 16,
            AutoButtonColor = false,
            Parent = self.Frame,
        })
        Anim.AddHover(collapseBtn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })
        collapseBtn.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        self.CollapseButton = collapseBtn
    end
end

function Sidebar:_createNavItem(index, item)
    local theme = Theme.Current()

    local btn = Create("TextButton", {
        Name = "Nav_" .. (item.Label or "Item"),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, 0, 0, 40),
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = index,
        Parent = self._navContainer,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = btn,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = btn,
    })

    -- Icon
    if item.Icon then
        local icon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Image = item.Icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = btn,
        })
    end

    -- Label (hidden when collapsed)
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 20),
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = item.Label or "Item",
        TextColor3 = theme.Text.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = not self._collapsed,
        Parent = btn,
    })

    -- Active indicator (left bar)
    local indicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = theme.Accent.Primary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 3, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Parent = btn,
    })

    Anim.AddHover(btn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.5 })

    if item.Default then
        self:_setActiveNav(btn, indicator)
    end

    btn.MouseButton1Click:Connect(function()
        -- Deselect all
        for _, navBtn in ipairs(self._navButtons) do
            local ind = navBtn.btn:FindFirstChild("Indicator")
            if ind then
                Anim.Tween(ind, { BackgroundTransparency = 1 }, 0.2)
            end
            Anim.Tween(navBtn.btn, { BackgroundColor3 = theme.Component.Background, BackgroundTransparency = 0.7 }, 0.2)
        end
        self:_setActiveNav(btn, indicator)
        self.OnNavigate:Fire(item, index)
    end)

    table.insert(self._navButtons, { btn = btn, indicator = indicator, item = item })
end

function Sidebar:_setActiveNav(btn, indicator)
    local theme = Theme.Current()
    Anim.Tween(indicator, { BackgroundTransparency = 0 }, 0.2)
    Anim.Tween(btn, { BackgroundColor3 = theme.Accent.Primary, BackgroundTransparency = 0.85 }, 0.2)
end

function Sidebar:Toggle()
    self._collapsed = not self._collapsed
    local newWidth = self._collapsed and 64 or self._width
    Anim.Tween(self.Frame, { Size = UDim2.new(0, newWidth, 1, 0) }, 0.3)

    -- Toggle visibility of labels
    if self.BrandTitle then
        self.BrandTitle.Visible = not self._collapsed
    end
    for _, navBtn in ipairs(self._navButtons) do
        local label = navBtn.btn:FindFirstChild("Label")
        if label then
            label.Visible = not self._collapsed
        end
    end
    if self.CollapseButton then
        self.CollapseButton.Text = self._collapsed and "›" or "‹"
    end

    self.OnToggle:Fire(self._collapsed)
end

function Sidebar:AddItem(item)
    table.insert(self._items, item)
    self:_createNavItem(#self._items, item)
end

function Sidebar:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Side or theme.Component.Background
    if self.BrandTitle then self.BrandTitle.TextColor3 = theme.Text.Primary end
    if self.LogoFrame then self.LogoFrame.BackgroundColor3 = theme.Accent.Primary end
    for _, navBtn in ipairs(self._navButtons) do
        local label = navBtn.btn:FindFirstChild("Label")
        if label then label.TextColor3 = theme.Text.Primary end
    end
end

return Sidebar
