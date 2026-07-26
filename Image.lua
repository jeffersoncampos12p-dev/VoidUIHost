--[[
    VoidUI | Image Component
    A versatile image display with optional rounded corners, border, caption,
    hover effects, and click handling. Supports various fit modes.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Image = {}
Image.__index = Image
setmetatable(Image, { __index = Component })

function Image.new(config, voidUI)
    local self = Component.new("Image")
    setmetatable(self, { __index = Image })

    config = config or {}
    self._source = config.Source or ""
    self._size = config.Size or UDim2.new(0, 200, 0, 150)
    self._cornerRadius = config.CornerRadius or 8
    self._caption = config.Caption or nil
    self._border = config.Border ~= nil and config.Border or true
    self._scaleType = config.ScaleType or Enum.ScaleType.Fit
    self._clickable = config.Clickable or false

    self.OnClick = self:AddSignal("OnClick")

    self:_createUI()
    return self
end

function Image:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Image",
        BackgroundTransparency = 1,
        Size = self._size,
        Parent = nil,
    })

    -- Image label
    self.ImageLabel = Create("ImageLabel", {
        Name = "Image",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        Image = self._source,
        ScaleType = self._scaleType,
        Parent = self.Frame,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, self._cornerRadius),
        Parent = self.ImageLabel,
    })

    if self._border then
        self.Stroke = Create("UIStroke", {
            Color = theme.Component.Border,
            Thickness = 1,
            Transparency = 0.3,
            Parent = self.ImageLabel,
        })
    end

    if self._clickable then
        local overlay = Create("TextButton", {
            Name = "Overlay",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            Parent = self.Frame,
        })
        Anim.AddHover(overlay, { HoverColor = Color3.new(0, 0, 0), HoverTransparency = 0.4 })
        overlay.MouseButton1Click:Connect(function()
            self.OnClick:Fire()
        end)
        self.Overlay = overlay
    end

    -- Caption
    if self._caption then
        local labelHeight = 24
        self.ImageLabel.Size = UDim2.new(1, 0, 1, -labelHeight)

        self.Caption = Create("TextLabel", {
            Name = "Caption",
            BackgroundColor3 = theme.Component.Background,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, labelHeight),
            Position = UDim2.new(0, 0, 1, -labelHeight),
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = self._caption,
            TextColor3 = theme.Text.Secondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = self.Frame,
        })
        -- Adjust corner: bottom corners rounded only
        Create("UICorner", { CornerRadius = UDim.new(0, 0), Parent = self.Caption })
    end
end

function Image:SetSource(source)
    self._source = source
    if self.ImageLabel then self.ImageLabel.Image = source end
end

function Image:SetCaption(caption)
    self._caption = caption
    if self.Caption then
        self.Caption.Text = caption
    end
end

function Image:SetSize(size)
    self._size = size
    self.Frame.Size = size
end

function Image:GetSource()
    return self._source
end

function Image:_applyThemeImpl(theme)
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.Caption then
        self.Caption.TextColor3 = theme.Text.Secondary
        self.Caption.BackgroundColor3 = theme.Component.Background
    end
end

return Image
