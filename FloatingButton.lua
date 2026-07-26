--[[
    VoidUI | FloatingButton Component
    A floating action button (FAB) that hovers above content, typically
    in a corner. Supports icon, ripple, tooltip, and expand-on-hover.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local FloatingButton = {}
FloatingButton.__index = FloatingButton
setmetatable(FloatingButton, { __index = Component })

function FloatingButton.new(config, voidUI)
    local self = Component.new("FloatingButton")
    setmetatable(self, { __index = FloatingButton })

    config = config or {}
    self._icon = config.Icon or "rbxassetid://6285854194"
    self._size = config.Size or 56
    self._position = config.Position or "BottomRight"
    self._text = config.Text or nil
    self._variant = config.Variant or "Primary" -- Primary, Extended

    self.OnClick = self:AddSignal("OnClick")

    self:_createUI()
    return self
end

function FloatingButton:_createUI()
    local theme = Theme.Current()

    self.ScreenGui = Create("ScreenGui", {
        Name = "VoidUI_FAB",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 5000,
        Parent = VoidCore.GetParent(),
    })

    local positions = {
        BottomRight = UDim2.new(1, -self._size - 20, 1, -self._size - 20),
        BottomLeft = UDim2.new(0, 20, 1, -self._size - 20),
        TopRight = UDim2.new(1, -self._size - 20, 0, 20),
        TopLeft = UDim2.new(0, 20, 0, 20),
        BottomCenter = UDim2.new(0.5, -self._size / 2, 1, -self._size - 20),
    }

    local pos = positions[self._position] or positions.BottomRight
    local btnWidth = self._variant == "Extended" and 140 or self._size

    self.Frame = Create("TextButton", {
        Name = "FAB",
        BackgroundColor3 = theme.Accent.Primary,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, btnWidth, 0, self._size),
        Position = pos,
        AutoButtonColor = false,
        Text = "",
        Parent = self.ScreenGui,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, self._size / 2), Parent = self.Frame })

    -- Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        ZIndex = -1,
        Image = "rbxassetid://6026416243",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        Parent = self.Frame,
    })

    -- Glow
    self.Glow = Create("UIStroke", {
        Color = theme.Accent.Primary,
        Thickness = 2,
        Transparency = 0.6,
        Parent = self.Frame,
    })

    -- Content layout
    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = self.Frame,
    })

    -- Icon
    self.IconLabel = Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        Image = self._icon,
        ImageColor3 = Color3.new(1, 1, 1),
        Parent = self.Frame,
    })

    -- Label (for extended variant)
    if self._variant == "Extended" and self._text then
        self.Label = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = self._text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Parent = self.Frame,
        })
    end

    -- Hover effect
    Anim.AddHover(self.Frame, { HoverColor = theme.Accent.Hover, HoverTransparency = 0 })

    -- Press effect
    Anim.AddPress(self.Frame)

    -- Click
    self.Frame.MouseButton1Click:Connect(function()
        self.OnClick:Fire()
    end)

    -- Pulse glow animation
    self._glowConn = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Glow then
            local t = tick()
            local alpha = (math.sin(t * 2) + 1) / 2
            self.Glow.Transparency = 0.6 - alpha * 0.3
        end
    end)
end

function FloatingButton:SetIcon(icon)
    self._icon = icon
    if self.IconLabel then self.IconLabel.Image = icon end
end

function FloatingButton:SetText(text)
    self._text = text
    if self.Label then self.Label.Text = text end
end

function FloatingButton:SetPosition(position)
    self._position = position
    local positions = {
        BottomRight = UDim2.new(1, -self._size - 20, 1, -self._size - 20),
        BottomLeft = UDim2.new(0, 20, 1, -self._size - 20),
        TopRight = UDim2.new(1, -self._size - 20, 0, 20),
        TopLeft = UDim2.new(0, 20, 0, 20),
        BottomCenter = UDim2.new(0.5, -self._size / 2, 1, -self._size - 20),
    }
    Anim.Tween(self.Frame, { Position = positions[position] or positions.BottomRight }, 0.3)
end

function FloatingButton:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Accent.Primary
    if self.Glow then self.Glow.Color = theme.Accent.Primary end
    if self.Label then self.Label.Font = theme.Font or Enum.Font.GothamMedium end
end

function FloatingButton:Destroy()
    if self._glowConn then
        self._glowConn:Disconnect()
        self._glowConn = nil
    end
    if self.ScreenGui then self.ScreenGui:Destroy() end
    Component.Destroy(self)
end

return FloatingButton
