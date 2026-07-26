--[[
    VoidUI | ContextMenu Component
    A context menu that appears at a specified position with a list of
    actions. Used by RightClickMenu and other contextual interactions.
    Supports icons, separators, submenus, and disabled items.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local ContextMenu = {}
ContextMenu.__index = ContextMenu
setmetatable(ContextMenu, { __index = Component })

local _menuGui = nil
local function _getGui()
    if _menuGui then return _menuGui end
    _menuGui = Create("ScreenGui", {
        Name = "VoidUI_ContextMenus",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9500,
        Parent = VoidCore.GetParent(),
    })
    return _menuGui
end

function ContextMenu.new(config, voidUI)
    local self = Component.new("ContextMenu")
    setmetatable(self, { __index = ContextMenu })

    config = config or {}
    self._items = config.Items or {}
    self._position = config.Position or UDim2.new(0, 100, 0, 100)
    self._minWidth = config.MinWidth or 180
    self._maxHeight = config.MaxHeight or 400

    self.OnSelect = self:AddSignal("OnSelect")

    self:_createUI()
    return self
end

function ContextMenu:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "ContextMenu",
        BackgroundColor3 = theme.Background.Main,
        BackgroundTransparency = 0.02,
        Size = UDim2.new(0, self._minWidth, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = self._position,
        Visible = false,
        Parent = _getGui(),
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Frame })
    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    -- Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        ZIndex = -1,
        Image = "rbxassetid://6026416243",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = self.Frame,
    })

    self._layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = self.Frame,
    })

    for i, item in ipairs(self._items) do
        self:_createItem(i, item)
    end

    -- Close on outside click
    local UIS = game:GetService("UserInputService")
    self._mouseConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Frame.Visible then
            local mousePos = UIS:GetMouseLocation()
            local framePos = self.Frame.AbsolutePosition
            local frameSize = self.Frame.AbsoluteSize
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                self:Close()
            end
        end
    end)
end

function ContextMenu:_createItem(index, item)
    local theme = Theme.Current()

    -- Separator
    if item.Separator then
        local sep = Create("Frame", {
            Name = "Separator_" .. index,
            BackgroundColor3 = theme.Component.Border,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = index,
            Parent = self.Frame,
        })
        return
    end

    local btn = Create("TextButton", {
        Name = "Item_" .. (item.Label or "Item"),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 32),
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = index,
        Parent = self.Frame,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = btn,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = btn,
    })

    -- Icon
    if item.Icon then
        local icon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            Image = item.Icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = btn,
        })
    end

    -- Label
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 18),
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = item.Label or "Item",
        TextColor3 = item.Disabled and theme.Text.Tertiary or theme.Text.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })

    -- Shortcut (optional)
    if item.Shortcut then
        local shortcut = Create("TextLabel", {
            Name = "Shortcut",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = theme.Font or Enum.Font.Gotham,
            Text = item.Shortcut,
            TextColor3 = theme.Text.Tertiary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = btn,
        })
    end

    -- Danger variant
    if item.Danger then
        label.TextColor3 = theme.Status.Error
    end

    if not item.Disabled then
        Anim.AddHover(btn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.5 })
        btn.MouseButton1Click:Connect(function()
            if item.Callback then item.Callback() end
            self.OnSelect:Fire(item, index)
            self:Close()
        end)
    end
end

function ContextMenu:Show(position)
    if position then
        self.Frame.Position = position
    end
    self.Frame.Visible = true

    -- Scale-in animation
    self.Frame.Size = UDim2.new(0, self._minWidth * 0.9, 0, 0)
    self.Frame.AutomaticSize = Enum.AutomaticSize.None
    Anim.FadeIn(self.Frame, 0.15)

    -- Animate to full size
    task.delay(0.05, function()
        self.Frame.AutomaticSize = Enum.AutomaticSize.Y
    end)
end

function ContextMenu:Close()
    Anim.FadeOut(self.Frame, 0.1)
    task.delay(0.1, function()
        if self.Frame then self.Frame.Visible = false end
    end)
end

function ContextMenu:AddItem(item)
    table.insert(self._items, item)
    self:_createItem(#self._items, item)
end

function ContextMenu:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Main
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    for _, child in ipairs(self.Frame:GetChildren()) do
        if child:IsA("TextButton") then
            local label = child:FindFirstChild("Label")
            if label then
                label.TextColor3 = theme.Text.Primary
                label.Font = theme.Font or Enum.Font.GothamMedium
            end
        end
    end
end

function ContextMenu:Destroy()
    if self._mouseConn then self._mouseConn:Disconnect() end
    if self.Frame then self.Frame:Destroy() end
    Component.Destroy(self)
end

return ContextMenu
