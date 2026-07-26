--[[
    VoidUI - Tab Component
    A tab container with content area and navigation button.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Tab = setmetatable({}, {__index = Component})
Tab.__index = Tab

-- ============================================================
-- Tab Factory
-- ============================================================
function Tab.new(name, icon, window)
    local self = Component.new("Tab")
    setmetatable(self, {__index = Tab})
    
    self.Name = name
    self.Icon = icon
    self._window = window
    self._sections = {}
    self._isActive = false
    
    -- Tab events
    self.OnActivate = self:AddSignal("OnActivate")
    self.OnDeactivate = self:AddSignal("OnDeactivate")
    
    self:_createButton()
    self:_createContent()
    
    return self
end

-- ============================================================
-- Create Tab Button
-- ============================================================
function Tab:_createButton()
    local theme = ThemeSystem:Current()
    
    local btn = Core.Create("TextButton", {
        Name = "Tab_" .. self.Name,
        Size = UDim2.fromOffset(100, 28),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 2,
    }, self._window._tabList)
    self._button = btn
    
    -- Corner
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, btn)
    self._buttonCorner = corner
    
    -- Inner content frame
    local contentFrame = Core.Create("Frame", {
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.fromOffset(4, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, btn)
    self._buttonContent = contentFrame
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, contentFrame)
    
    -- Icon
    if self.Icon then
        local icon = Core.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            Image = self.Icon,
            ImageColor3 = theme.Text.Secondary,
            ZIndex = 3,
        }, contentFrame)
        self._buttonIcon = icon
    end
    
    -- Label
    local label = Core.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.fromOffset(self.Icon and 70 or 80, 14),
        BackgroundTransparency = 1,
        Text = self.Name,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 3,
    }, contentFrame)
    self._buttonLabel = label
    
    -- Hover effect
    AnimationSystem:AddHover(btn, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0.3}, 0.15)
    self:AddRipple(btn, Color3.fromRGB(255, 255, 255))
    
    btn.MouseButton1Click:Connect(function()
        self._window:_setActiveTab(self)
    end)
end

-- ============================================================
-- Create Content Area
-- ============================================================
function Tab:_createContent()
    local theme = ThemeSystem:Current()
    
    local content = Core.Create("ScrollingFrame", {
        Name = "TabContent_" .. self.Name,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Border.Default,
        ScrollBarImageTransparency = 0.7,
        ScrollBarScaling = 0.5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        ZIndex = 1,
    }, self._window._contentArea)
    self._contentFrame = content
    
    -- Padding frame inside
    local padding = Core.Create("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.fromOffset(12, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, content)
    self._contentPadding = padding
    
    -- UIListLayout for sections
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, padding)
    self._contentLayout = layout
    
    -- UI padding
    local uiPadding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 16),
    }, content)
end

-- ============================================================
-- Set Active State
-- ============================================================
function Tab:SetActive(active)
    if self._isActive == active then return end
    self._isActive = active
    
    local theme = ThemeSystem:Current()
    
    if active then
        AnimationSystem:Tween(self._button, {BackgroundColor3 = theme.Accent, BackgroundTransparency = 0}, 0.2)
        if self._buttonIcon then
            AnimationSystem:Tween(self._buttonIcon, {ImageColor3 = theme.Text.OnAccent}, 0.2)
        end
        AnimationSystem:Tween(self._buttonLabel, {TextColor3 = theme.Text.OnAccent}, 0.2)
        self._contentFrame.Visible = true
        AnimationSystem:FadeIn(self._contentFrame, 0.2)
        self.OnActivate:Fire()
    else
        AnimationSystem:Tween(self._button, {BackgroundColor3 = theme.Component.Background, BackgroundTransparency = 0.5}, 0.2)
        if self._buttonIcon then
            AnimationSystem:Tween(self._buttonIcon, {ImageColor3 = theme.Text.Secondary}, 0.2)
        end
        AnimationSystem:Tween(self._buttonLabel, {TextColor3 = theme.Text.Secondary}, 0.2)
        self._contentFrame.Visible = false
        self.OnDeactivate:Fire()
    end
end

-- ============================================================
-- Section Management
-- ============================================================
function Tab:CreateSection(title, options)
    local Section = require(script.Section)
    local section = Section.new(title, self, options)
    table.insert(self._sections, section)
    section.Instance.Parent = self._contentPadding
    return section
end

function Tab:CreateParagraph(options)
    -- Direct paragraph in tab content (without section wrapper)
    local Paragraph = require(script.Paragraph)
    local paragraph = Paragraph.new(options, self)
    table.insert(self._sections, paragraph)
    paragraph.Instance.Parent = self._contentPadding
    return paragraph
end

function Tab:AddComponent(component)
    table.insert(self._sections, component)
    if component.Instance then
        component.Instance.Parent = self._contentPadding
    end
    return component
end

-- ============================================================
-- Theme Application
-- ============================================================
function Tab:_applyThemeImpl(theme)
    if self._buttonIcon then
        if not self._isActive then
            self._buttonIcon.ImageColor3 = theme.Text.Secondary
        else
            self._buttonIcon.ImageColor3 = theme.Text.OnAccent
        end
    end
    
    if self._buttonLabel then
        if not self._isActive then
            self._buttonLabel.TextColor3 = theme.Text.Secondary
        else
            self._buttonLabel.TextColor3 = theme.Text.OnAccent
        end
        self._buttonLabel.Font = theme.Font
    end
    
    if not self._isActive then
        self._button.BackgroundColor3 = theme.Component.Background
    else
        self._button.BackgroundColor3 = theme.Accent
    end
    
    self._contentFrame.ScrollBarImageColor3 = theme.Border.Default
end

return Tab
