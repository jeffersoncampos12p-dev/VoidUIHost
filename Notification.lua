--[[
    VoidUI | Notification Component
    Toast-style notifications that appear in a corner of the screen.
    Supports title, description, icon, variants (info/success/warning/error),
    auto-dismiss timer, and close button.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Notification = {}
Notification.__index = Notification
setmetatable(Notification, { __index = Component })

local VARIANT_COLORS = {
    Info = { color = Color3.fromRGB(33, 150, 243), icon = "rbxassetid://6285854194" },
    Success = { color = Color3.fromRGB(76, 175, 80), icon = "rbxassetid://6285854194" },
    Warning = { color = Color3.fromRGB(255, 193, 7), icon = "rbxassetid://6285854194" },
    Error = { color = Color3.fromRGB(244, 67, 54), icon = "rbxassetid://6285854194" },
}

-- Static container for stacking notifications
local _container = nil
local function _getContainer()
    if _container then return _container end
    local theme = Theme.Current()
    _container = Create("ScreenGui", {
        Name = "VoidUI_Notifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = VoidCore.GetParent(),
    })

    local holder = Create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -340, 0, 0),
        Parent = _container,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 8),
        Parent = holder,
    })

    local padding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 20),
        Parent = holder,
    })

    return holder
end

function Notification.new(config, voidUI)
    local self = Component.new("Notification")
    setmetatable(self, { __index = Notification })

    config = config or {}
    self._title = config.Title or "Notification"
    self._description = config.Description or config.Text or ""
    self._variant = config.Variant or "Info"
    self._duration = config.Duration or 5 -- seconds, 0 = no auto-dismiss
    self._icon = config.Icon or nil

    self.OnDismiss = self:AddSignal("OnDismiss")

    self:_createUI()
    return self
end

function Notification:_createUI()
    local theme = Theme.Current()
    local vc = VARIANT_COLORS[self._variant] or VARIANT_COLORS.Info
    local accentColor = vc.color

    self.Frame = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.05,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = nil,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = self.Frame,
    })

    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    -- Accent bar on left
    self.AccentBar = Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = self.Frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = self.AccentBar })

    -- Padding container
    local container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
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
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = container,
    })

    -- Icon
    self.IconLabel = Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        Image = self._icon or vc.icon,
        ImageColor3 = accentColor,
        Parent = container,
    })

    -- Text container
    local textContainer = Create("Frame", {
        Name = "TextContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = container,
    })

    local textLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
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
        Parent = textContainer,
    })

    -- Description
    if self._description and self._description ~= "" then
        self.Description = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.Font or Enum.Font.Gotham,
            Text = self._description,
            TextColor3 = theme.Text.Secondary,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = textContainer,
        })
    end

    -- Close button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = theme.Text.Tertiary,
        TextSize = 12,
        Parent = container,
    })
    Anim.AddHover(closeBtn, { HoverColor = theme.Text.Primary })
    closeBtn.MouseButton1Click:Connect(function()
        self:Dismiss()
    end)
end

function Notification:Show()
    local holder = _getContainer()
    self.Frame.Parent = holder

    -- Animate slide-in
    self.Frame.Position = UDim2.new(1, 20, 0, 0) -- start off-screen right
    Anim.Tween(self.Frame, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)

    -- Auto-dismiss timer
    if self._duration and self._duration > 0 then
        task.delay(self._duration, function()
            if self.Frame and self.Frame.Parent then
                self:Dismiss()
            end
        end)
    end
end

function Notification:Dismiss()
    if self._dismissing then return end
    self._dismissing = true

    Anim.Tween(self.Frame, { Position = UDim2.new(1, 20, 0, 0) }, 0.25)
    task.delay(0.25, function()
        self.OnDismiss:Fire()
        self:Destroy()
    end)
end

function Notification:SetTitle(title)
    self._title = title
    if self.Title then self.Title.Text = title end
end

function Notification:SetDescription(description)
    self._description = description
    if self.Description then self.Description.Text = description end
end

function Notification:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Component.Background
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.Title then self.Title.TextColor3 = theme.Text.Primary end
    if self.Description then self.Description.TextColor3 = theme.Text.Secondary end
end

return Notification
