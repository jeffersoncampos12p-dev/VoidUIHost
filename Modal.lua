--[[
    VoidUI | Modal Component
    A modal overlay that displays content over the main UI with a dimmed
    backdrop. Used for Modal dialogs, custom content overlays, and
    confirmation flows. Supports custom content injection, animation,
    backdrop click to close, and ESC key handling.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Modal = {}
Modal.__index = Modal
setmetatable(Modal, { __index = Component })

local _modalGui = nil

local function _getGui()
    if _modalGui then return _modalGui end
    _modalGui = Create("ScreenGui", {
        Name = "VoidUI_Modals",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9000,
        Parent = VoidCore.GetParent(),
    })
    return _modalGui
end

function Modal.new(config, voidUI)
    local self = Component.new("Modal")
    setmetatable(self, { __index = Modal })

    config = config or {}
    self._size = config.Size or UDim2.new(0, 400, 0, 300)
    self._title = config.Title or nil
    self._closable = config.Closable ~= nil and config.Closable or true
    self._closeOnBackdrop = config.CloseOnBackdrop ~= nil and config.CloseOnBackdrop or true
    self._centered = config.Centered ~= nil and config.Centered or true

    self.OnOpen = self:AddSignal("OnOpen")
    self.OnClose = self:AddSignal("OnClose")

    self:_createUI()
    return self
end

function Modal:_createUI()
    local theme = Theme.Current()
    local gui = _getGui()

    -- Backdrop
    self.Backdrop = Create("TextButton", {
        Name = "Backdrop",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        AutoButtonColor = false,
        Text = "",
        Visible = false,
        Parent = gui,
    })

    if self._closeOnBackdrop then
        self.Backdrop.MouseButton1Click:Connect(function()
            self:Close()
        end)
    end

    -- Modal frame
    self.Frame = Create("Frame", {
        Name = "Modal",
        BackgroundColor3 = theme.Background.Main,
        BackgroundTransparency = 0.02,
        Size = self._size,
        Position = self._centered and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, -self._size.X.Offset / 2, 0.5, -self._size.Y.Offset / 2),
        AnchorPoint = self._centered and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
        Visible = false,
        Parent = self.Backdrop,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = self.Frame,
    })

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
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        ZIndex = -1,
        Image = "rbxassetid://6026416243",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Frame,
    })

    -- Header (optional title)
    if self._title then
        local header = Create("Frame", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            LayoutOrder = 0,
            Parent = self.Frame,
        })

        self.Title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            Font = theme.Font or Enum.Font.GothamBold,
            Text = self._title,
            TextColor3 = theme.Text.Primary,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header,
        })

        if self._closable then
            local closeBtn = Create("TextButton", {
                Name = "Close",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(1, -28, 0, 0),
                Font = Enum.Font.GothamBold,
                Text = "✕",
                TextColor3 = theme.Text.Tertiary,
                TextSize = 14,
                Parent = header,
            })
            Anim.AddHover(closeBtn, { HoverColor = theme.Text.Primary })
            closeBtn.MouseButton1Click:Connect(function()
                self:Close()
            end)
        end
    end

    -- Content area
    self.Content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = self.Frame,
    })

    self:_registerKeyHandler()
end

function Modal:_registerKeyHandler()
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Escape and self.Backdrop and self.Backdrop.Visible then
            if self._closable then
                self:Close()
            end
        end
    end)
end

function Modal:Open()
    self.Backdrop.Visible = true
    self.Frame.Visible = true

    -- Animate backdrop fade
    Anim.Tween(self.Backdrop, { BackgroundTransparency = 0.5 }, 0.2)

    -- Animate modal scale-in
    self.Frame.Size = UDim2.new(0, self._size.X.Offset * 0.9, 0, self._size.Y.Offset * 0.9)
    Anim.Tween(self.Frame, { Size = self._size }, 0.25)

    self.OnOpen:Fire()
end

function Modal:Close()
    Anim.Tween(self.Backdrop, { BackgroundTransparency = 1 }, 0.2)
    Anim.Tween(self.Frame, {
        Size = UDim2.new(0, self._size.X.Offset * 0.9, 0, self._size.Y.Offset * 0.9)
    }, 0.2)

    task.delay(0.2, function()
        if self.Backdrop then self.Backdrop.Visible = false end
        if self.Frame then self.Frame.Visible = false end
    end)

    self.OnClose:Fire()
end

function Modal:AddContent(instance)
    instance.Parent = self.Content
    return instance
end

function Modal:SetTitle(title)
    self._title = title
    if self.Title then self.Title.Text = title end
end

function Modal:SetSize(size)
    self._size = size
    self.Frame.Size = size
end

function Modal:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Main
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.Title then self.Title.TextColor3 = theme.Text.Primary end
end

function Modal:Destroy()
    if self.Backdrop then self.Backdrop:Destroy() end
    Component.Destroy(self)
end

return Modal
