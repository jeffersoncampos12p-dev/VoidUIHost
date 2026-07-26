--[[
    VoidUI | Chip Component
    A versatile chip/badge that can be interactive, selectable, and used as filters.
    Supports selection state, icon, avatar, and close button.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Chip = {}
Chip.__index = Chip
setmetatable(Chip, { __index = Component })

function Chip.new(config, voidUI)
    local self = Component.new("Chip")
    setmetatable(self, { __index = Chip })

    config = config or {}
    self._text = config.Text or "Chip"
    self._icon = config.Icon or nil
    self._selected = config.Selected or false
    self._closable = config.Closable or false
    self._selectable = config.Selectable or false
    self._avatarImage = config.AvatarImage or nil

    self.OnSelected = self:AddSignal("OnSelected")
    self.OnClose = self:AddSignal("OnClose")

    self:_createUI()
    return self
end

function Chip:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("TextButton", {
        Name = "Chip",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 0, 0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
        AutoButtonColor = false,
        Text = "",
        Parent = nil,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0), -- pill shape
        Parent = self.Frame,
    })

    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.3,
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.Frame,
    })

    -- Avatar (optional)
    if self._avatarImage then
        local avatar = Create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Image = self._avatarImage,
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatar })
        self.Avatar = avatar
    end

    -- Icon (optional)
    if self._icon then
        self.IconLabel = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            Image = self._icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = self.Frame,
        })
    end

    -- Label
    self.Label = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = self._text,
        TextColor3 = theme.Text.Primary,
        TextSize = 13,
        Parent = self.Frame,
    })

    -- Close button (optional)
    if self._closable then
        local closeBtn = Create("TextButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = "✕",
            TextColor3 = theme.Text.Secondary,
            TextSize = 11,
            Parent = self.Frame,
        })
        Anim.AddHover(closeBtn, { HoverColor = theme.Text.Primary })
        closeBtn.MouseButton1Click:Connect(function()
            self.OnClose:Fire()
            self:Destroy()
        end)
    end

    -- Hover and click for selectable
    Anim.AddHover(self.Frame, { HoverColor = theme.Component.Hover })

    if self._selectable then
        self.Frame.MouseButton1Click:Connect(function()
            self:SetSelected(not self._selected)
            self.OnSelected:Fire(self._selected)
        end)
    end

    if self._selected then
        self:_applySelectedStyle()
    end
end

function Chip:_applySelectedStyle()
    local theme = Theme.Current()
    Anim.Tween(self.Frame, { BackgroundColor3 = theme.Accent.Primary }, 0.15)
    if self.Label then
        Anim.Tween(self.Label, { TextColor3 = Color3.new(1, 1, 1) }, 0.15)
    end
    if self.Stroke then
        self.Stroke.Color = theme.Accent.Primary
    end
    if self.IconLabel then
        self.IconLabel.ImageColor3 = Color3.new(1, 1, 1)
    end
end

function Chip:_applyUnselectedStyle()
    local theme = Theme.Current()
    Anim.Tween(self.Frame, { BackgroundColor3 = theme.Component.Background }, 0.15)
    if self.Label then
        Anim.Tween(self.Label, { TextColor3 = theme.Text.Primary }, 0.15)
    end
    if self.Stroke then
        self.Stroke.Color = theme.Component.Border
    end
    if self.IconLabel then
        self.IconLabel.ImageColor3 = theme.Text.Secondary
    end
end

function Chip:SetSelected(selected)
    self._selected = selected
    if selected then
        self:_applySelectedStyle()
    else
        self:_applyUnselectedStyle()
    end
end

function Chip:GetSelected()
    return self._selected
end

function Chip:SetText(text)
    self._text = text
    if self.Label then self.Label.Text = text end
end

function Chip:_applyThemeImpl(theme)
    if not self._selected then
        self.Frame.BackgroundColor3 = theme.Component.Background
        if self.Label then self.Label.TextColor3 = theme.Text.Primary end
        if self.Stroke then self.Stroke.Color = theme.Component.Border end
    end
end

return Chip
