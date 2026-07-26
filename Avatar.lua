--[[
    VoidUI | Avatar Component
    Displays user avatars with image, initials fallback, size variants,
    ring/border, and optional status indicator.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create
local Utils = VoidCore.Utils

local Avatar = {}
Avatar.__index = Avatar
setmetatable(Avatar, { __index = Component })

local SIZE_MAP = {
    Small = 32,
    Medium = 48,
    Large = 72,
    XLarge = 96,
}

function Avatar.new(config, voidUI)
    local self = Component.new("Avatar")
    setmetatable(self, { __index = Avatar })

    config = config or {}
    self._imageSource = config.Image or ""
    self._initials = config.Initials or "?"
    self._size = config.Size or "Medium"
    self._showRing = config.ShowRing or false
    self._clickable = config.Clickable or false

    self.OnClick = self:AddSignal("OnClick")

    self:_createUI()
    return self
end

function Avatar:_createUI()
    local theme = Theme.Current()
    local px = SIZE_MAP[self._size] or 48

    self.Frame = Create("Frame", {
        Name = "Avatar",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, px, 0, px),
        Parent = nil,
    })

    -- Ring (outer decorative ring)
    if self._showRing then
        self.Ring = Create("Frame", {
            Name = "Ring",
            BackgroundColor3 = theme.Accent.Primary,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, 4, 1, 4),
            Position = UDim2.new(0, -2, 0, -2),
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Ring })
    end

    -- Image avatar
    if self._imageSource and self._imageSource ~= "" then
        self.ImageLabel = Create("ImageLabel", {
            Name = "Image",
            BackgroundColor3 = theme.Component.Background,
            Size = UDim2.new(1, 0, 1, 0),
            Image = self._imageSource,
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.ImageLabel })
    else
        -- Fallback to initials
        self.Initials = Create("TextLabel", {
            Name = "Initials",
            BackgroundColor3 = theme.Accent.Primary,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = self._initials,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = px * 0.4,
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Initials })
    end

    -- Border
    self.Stroke = Create("UIStroke", {
        Color = theme.Background.Main,
        Thickness = 2,
        Parent = self.ImageLabel or self.Initials,
    })

    -- Click overlay
    if self._clickable then
        local click = Create("TextButton", {
            Name = "Click",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = click })
        Anim.AddHover(click, { HoverTransparency = 0.2, HoverColor = Color3.new(1, 1, 1) })
        click.MouseButton1Click:Connect(function()
            self.OnClick:Fire()
        end)
    end
end

function Avatar:SetImage(imageSource)
    self._imageSource = imageSource
    if self.ImageLabel then
        self.ImageLabel.Image = imageSource
        self.ImageLabel.Visible = true
    elseif self.Initials then
        -- Replace initials with image
        self.Initials:Destroy()
        local theme = Theme.Current()
        self.ImageLabel = Create("ImageLabel", {
            Name = "Image",
            BackgroundColor3 = theme.Component.Background,
            Size = UDim2.new(1, 0, 1, 0),
            Image = imageSource,
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.ImageLabel })
    end
end

function Avatar:SetInitials(initials)
    self._initials = initials
    if self.Initials then self.Initials.Text = initials end
end

function Avatar:SetSize(size)
    self._size = size
    local px = SIZE_MAP[size] or 48
    self.Frame.Size = UDim2.new(0, px, 0, px)
    if self.Initials then self.Initials.TextSize = px * 0.4 end
end

function Avatar:_applyThemeImpl(theme)
    if self.Ring then self.Ring.BackgroundColor3 = theme.Accent.Primary end
    if self.Stroke then self.Stroke.Color = theme.Background.Main end
    if self.Initials then self.Initials.BackgroundColor3 = theme.Accent.Primary end
end

return Avatar
