--[[
    VoidUI | Navbar Component
    A horizontal top navigation bar with logo/title, nav links,
    and optional action buttons on the right side.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Navbar = {}
Navbar.__index = Navbar
setmetatable(Navbar, { __index = Component })

function Navbar.new(config, voidUI)
    local self = Component.new("Navbar")
    setmetatable(self, { __index = Navbar })

    config = config or {}
    self._title = config.Title or "VoidUI"
    self._logo = config.Logo or "V"
    self._items = config.Items or {}
    self._size = config.Size or UDim2.new(1, 0, 0, 56)

    self.OnNavigate = self:AddSignal("OnNavigate")

    self:_createUI()
    return self
end

function Navbar:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Navbar",
        BackgroundColor3 = theme.Background.Side or theme.Component.Background,
        BackgroundTransparency = 0.3,
        Size = self._size,
        Parent = nil,
    })

    local stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 20),
        Parent = self.Frame,
    })

    -- Logo + Title (left)
    local brand = Create("Frame", {
        Name = "Brand",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 40),
        AutomaticSize = Enum.AutomaticSize.X,
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

    self.Title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamBold,
        Text = self._title,
        TextColor3 = theme.Text.Primary,
        TextSize = 16,
        Parent = brand,
    })

    -- Nav items (center)
    self._navContainer = Create("Frame", {
        Name = "NavItems",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = self.Frame,
    })

    local navLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = self._navContainer,
    })

    self._navButtons = {}
    for i, item in ipairs(self._items) do
        self:_createNavItem(i, item)
    end

    -- Spacer to push actions right
    local spacer = Create("Frame", {
        Name = "Spacer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 0, 0),
        LayoutOrder = 5,
        Parent = self.Frame,
    })

    -- Actions container (right)
    self.Actions = Create("Frame", {
        Name = "Actions",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 10,
        Parent = self.Frame,
    })

    local actionsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = self.Actions,
    })
end

function Navbar:_createNavItem(index, item)
    local theme = Theme.Current()

    local btn = Create("TextButton", {
        Name = "Nav_" .. (item.Label or "Item"),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
        AutoButtonColor = false,
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = item.Label or "Item",
        TextColor3 = theme.Text.Secondary,
        TextSize = 13,
        LayoutOrder = index,
        Parent = self._navContainer,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = btn,
    })

    Anim.AddHover(btn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })

    btn.MouseButton1Click:Connect(function()
        for _, navBtn in ipairs(self._navButtons) do
            navBtn.TextColor3 = theme.Text.Secondary
        end
        Anim.Tween(btn, { TextColor3 = theme.Accent.Primary }, 0.2)
        self.OnNavigate:Fire(item, index)
    end)

    table.insert(self._navButtons, btn)
end

function Navbar:AddAction(actionInstance)
    actionInstance.Parent = self.Actions
    return actionInstance
end

function Navbar:SetTitle(title)
    self._title = title
    if self.Title then self.Title.Text = title end
end

function Navbar:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Side or theme.Component.Background
    if self.Title then self.Title.TextColor3 = theme.Text.Primary end
    if self.LogoFrame then self.LogoFrame.BackgroundColor3 = theme.Accent.Primary end
    for _, btn in ipairs(self._navButtons) do
        btn.TextColor3 = theme.Text.Secondary
        btn.Font = theme.Font or Enum.Font.GothamMedium
    end
end

return Navbar
