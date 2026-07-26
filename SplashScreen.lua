--[[
    VoidUI | SplashScreen Component
    Branded splash screen shown at library initialization. Features the
    VoidUI logo, brand name, and a smooth fade-in/fade-out animation.
    Auto-dismisses after a configurable duration.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local SplashScreen = {}
SplashScreen.__index = SplashScreen
setmetatable(SplashScreen, { __index = Component })

function SplashScreen.new(config, voidUI)
    local self = Component.new("SplashScreen")
    setmetatable(self, { __index = SplashScreen })

    config = config or {}
    self._duration = config.Duration or 2.5
    self._brandName = config.BrandName or "VoidUI"
    self._tagline = config.Tagline or "Modern UI Library"

    self.OnDismiss = self:AddSignal("OnDismiss")

    self:_createUI()
    return self
end

function SplashScreen:_createUI()
    local theme = Theme.Current()

    self.ScreenGui = Create("ScreenGui", {
        Name = "VoidUI_Splash",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 10001,
        Parent = VoidCore.GetParent(),
    })

    self.Frame = Create("Frame", {
        Name = "Background",
        BackgroundColor3 = theme.Background.Main,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.ScreenGui,
    })

    -- Gradient overlay for visual depth
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            Color3.new(theme.Background.Main.R, theme.Background.Main.G, theme.Background.Main.B),
            Color3.new(theme.Background.Dark and theme.Background.Dark.R or 0, theme.Background.Dark and theme.Background.Dark.G or 0, theme.Background.Dark and theme.Background.Dark.B or 0),
        }),
        Rotation = 45,
        Parent = self.Frame,
    })

    -- Center container
    local container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 16),
        Parent = container,
    })

    -- Logo (stylized "V" in a rounded square)
    local logoSize = 80
    self.Logo = Create("Frame", {
        Name = "Logo",
        BackgroundColor3 = theme.Accent.Primary,
        Size = UDim2.new(0, logoSize, 0, logoSize),
        Parent = container,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 20), Parent = self.Logo })

    -- Glow
    local glow = Create("UIStroke", {
        Color = theme.Accent.Primary,
        Thickness = 4,
        Transparency = 0.5,
        Parent = self.Logo,
    })
    self.Glow = glow

    local logoText = Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = "V",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 48,
        Parent = self.Logo,
    })

    -- Brand name
    self.BrandName = Create("TextLabel", {
        Name = "BrandName",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamBold,
        Text = self._brandName,
        TextColor3 = theme.Text.Primary,
        TextSize = 24,
        Parent = container,
    })

    -- Tagline
    self.Tagline = Create("TextLabel", {
        Name = "Tagline",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.Gotham,
        Text = self._tagline,
        TextColor3 = theme.Text.Tertiary,
        TextSize = 13,
        Parent = container,
    })

    -- Loading indicator (three dots)
    local dotsContainer = Create("Frame", {
        Name = "Dots",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 8),
        Parent = container,
    })

    local dotsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = dotsContainer,
    })

    self._dots = {}
    for i = 1, 3 do
        local dot = Create("Frame", {
            Name = "Dot" .. i,
            BackgroundColor3 = theme.Text.Tertiary,
            Size = UDim2.new(0, 6, 0, 6),
            Parent = dotsContainer,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
        self._dots[i] = dot
    end

    -- Animate dots pulsing
    self._dotConn = game:GetService("RunService").Heartbeat:Connect(function()
        local t = tick()
        for i, dot in ipairs(self._dots) do
            local phase = t * 3 - i * 0.4
            local alpha = (math.sin(phase) + 1) / 2
            dot.BackgroundTransparency = 1 - alpha * 0.8
        end
    end)
end

function SplashScreen:Show()
    self.ScreenGui.Enabled = true

    -- Logo bounce-in
    self.Logo.Size = UDim2.new(0, 0, 0, 0)
    Anim.Tween(self.Logo, { Size = UDim2.new(0, 80, 0, 80) }, 0.5)

    -- Fade in text
    Anim.FadeIn(self.BrandName, 0.5)
    Anim.FadeIn(self.Tagline, 0.5)

    -- Auto-dismiss
    if self._duration and self._duration > 0 then
        task.delay(self._duration, function()
            self:Dismiss()
        end)
    end
end

function SplashScreen:Dismiss()
    Anim.FadeOut(self.Frame, 0.4)
    task.delay(0.4, function()
        self.ScreenGui.Enabled = false
        self.OnDismiss:Fire()
    end)
end

function SplashScreen:SetBrandName(name)
    self._brandName = name
    if self.BrandName then self.BrandName.Text = name end
end

function SplashScreen:SetTagline(tagline)
    self._tagline = tagline
    if self.Tagline then self.Tagline.Text = tagline end
end

function SplashScreen:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Main
    if self.Logo then self.Logo.BackgroundColor3 = theme.Accent.Primary end
    if self.Glow then self.Glow.Color = theme.Accent.Primary end
    if self.BrandName then self.BrandName.TextColor3 = theme.Text.Primary end
    if self.Tagline then self.Tagline.TextColor3 = theme.Text.Tertiary end
    for _, dot in ipairs(self._dots or {}) do
        dot.BackgroundColor3 = theme.Text.Tertiary
    end
end

function SplashScreen:Destroy()
    if self._dotConn then
        self._dotConn:Disconnect()
        self._dotConn = nil
    end
    if self.ScreenGui then self.ScreenGui:Destroy() end
    Component.Destroy(self)
end

return SplashScreen
