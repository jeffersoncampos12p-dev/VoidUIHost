--[[
    VoidUI | SubTab Component
    Secondary tab level within a main Tab. Creates a nested tab bar for
    further content organization within a tab's content area.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local SubTab = {}
SubTab.__index = SubTab
setmetatable(SubTab, { __index = Component })

function SubTab.new(name, icon, parentTab)
    local self = Component.new("SubTab")
    setmetatable(self, { __index = SubTab })

    self._name = name
    self._icon = icon or nil
    self._parentTab = parentTab
    self._isActive = false

    self.OnActivated = self:AddSignal("OnActivated")

    self:_createUI()
    return self
end

function SubTab:_createUI()
    local theme = Theme.Current()

    -- SubTab button (smaller than main tab)
    self.Button = Create("TextButton", {
        Name = "SubTab_" .. self._name,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        AutoButtonColor = false,
        Text = "",
        Parent = nil,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = self.Button,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.Button,
    })

    -- Indicator (left bar that appears when active)
    self.Indicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = theme.Accent.Primary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 2, 0, 16),
        Parent = self.Button,
    })

    -- Icon
    if self._icon then
        self.IconLabel = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            Image = self._icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = self.Button,
        })
    end

    -- Label
    self.Label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = self._name,
        TextColor3 = theme.Text.Secondary,
        TextSize = 12,
        Parent = self.Button,
    })

    -- Content container
    self.Content = Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Component.ScrollBar,
        Visible = false,
        Parent = nil,
    })

    local contentPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = self.Content,
    })

    self._contentLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Content,
    })

    -- Hover and click
    Anim.AddHover(self.Button, { HoverColor = theme.Component.Hover, HoverTransparency = 0.7 })

    self.Button.MouseButton1Click:Connect(function()
        self:SetActive(true)
    end)
end

function SubTab:SetActive(active)
    self._isActive = active
    local theme = Theme.Current()

    if active then
        Anim.Tween(self.Indicator, { BackgroundTransparency = 0 }, 0.2)
        if self.IconLabel then
            Anim.Tween(self.IconLabel, { ImageColor3 = theme.Accent.Primary }, 0.2)
        end
        Anim.Tween(self.Label, { TextColor3 = theme.Text.Primary }, 0.2)
        if self.Content then
            self.Content.Visible = true
            Anim.FadeIn(self.Content, 0.2)
        end
        self.OnActivated:Fire()
    else
        Anim.Tween(self.Indicator, { BackgroundTransparency = 1 }, 0.2)
        if self.IconLabel then
            Anim.Tween(self.IconLabel, { ImageColor3 = theme.Text.Secondary }, 0.2)
        end
        Anim.Tween(self.Label, { TextColor3 = theme.Text.Secondary }, 0.2)
        if self.Content then
            Anim.FadeOut(self.Content, 0.15)
            task.delay(0.15, function()
                self.Content.Visible = false
            end)
        end
    end
end

function SubTab:GetActive()
    return self._isActive
end

function SubTab:AddSection(title, options)
    local Section = require(script.Parent.Section)
    local section = Section.new(title, self, options or {})
    section.Frame.Parent = self.Content
    return section
end

function SubTab:AddContent(instance)
    instance.Parent = self.Content
    return instance
end

function SubTab:GetName()
    return self._name
end

function SubTab:_applyThemeImpl(theme)
    if self._isActive then
        self.Indicator.BackgroundColor3 = theme.Accent.Primary
        if self.IconLabel then self.IconLabel.ImageColor3 = theme.Accent.Primary end
        self.Label.TextColor3 = theme.Text.Primary
    else
        if self.IconLabel then self.IconLabel.ImageColor3 = theme.Text.Secondary end
        self.Label.TextColor3 = theme.Text.Secondary
    end
    if self.Content then
        self.Content.ScrollBarImageColor3 = theme.Component.ScrollBar
    end
end

return SubTab
