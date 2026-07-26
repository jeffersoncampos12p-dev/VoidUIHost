--[[
    VoidUI | LoadingScreen Component
    Full-screen loading overlay with spinner animation, optional text,
    and progress display. Used during initialization or heavy operations.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen
setmetatable(LoadingScreen, { __index = Component })

function LoadingScreen.new(config, voidUI)
    local self = Component.new("LoadingScreen")
    setmetatable(self, { __index = LoadingScreen })

    config = config or {}
    self._title = config.Title or "Loading"
    self._subtitle = config.Subtitle or ""
    self._showProgress = config.ShowProgress or false
    self._spinnerColor = config.SpinnerColor or nil

    self.OnComplete = self:AddSignal("OnComplete")

    self:_createUI()
    return self
end

function LoadingScreen:_createUI()
    local theme = Theme.Current()

    self.ScreenGui = Create("ScreenGui", {
        Name = "VoidUI_LoadingScreen",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10000,
        Parent = VoidCore.GetParent(),
    })

    self.Frame = Create("Frame", {
        Name = "Background",
        BackgroundColor3 = theme.Background.Main,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.ScreenGui,
    })

    -- Content container
    local container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 20),
        Parent = container,
    })

    -- Logo placeholder (circle with brand initial)
    local logoSize = 56
    self.Logo = Create("Frame", {
        Name = "Logo",
        BackgroundColor3 = self._spinnerColor or theme.Accent.Primary,
        Size = UDim2.new(0, logoSize, 0, logoSize),
        Parent = container,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Logo })

    local logoText = Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = "V",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 28,
        Parent = self.Logo,
    })

    -- Spinner ring
    self.SpinnerContainer = Create("Frame", {
        Name = "SpinnerContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 48, 0, 48),
        Parent = container,
    })

    self.Spinner = Create("Frame", {
        Name = "Spinner",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.SpinnerContainer,
    })

    -- Rotating arc (using a frame with a gradient-like approach)
    local arc = Create("Frame", {
        Name = "Arc",
        BackgroundColor3 = self._spinnerColor or theme.Accent.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
        Parent = self.Spinner,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = arc })

    -- Cover center to make a ring
    local cover = Create("Frame", {
        Name = "Cover",
        BackgroundColor3 = theme.Background.Main,
        Size = UDim2.new(0, 28, 0, 28),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.Spinner,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = cover })
    self.Cover = cover

    -- Start spinner rotation
    self._spinnerConn = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Spinner then
            self.Spinner.Rotation = (self.Spinner.Rotation + 3) % 360
        end
    end)

    -- Title
    self.Title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 0, 20),
        Font = theme.Font or Enum.Font.GothamBold,
        Text = self._title,
        TextColor3 = theme.Text.Primary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = container,
    })

    -- Subtitle
    if self._subtitle and self._subtitle ~= "" then
        self.Subtitle = Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.Font or Enum.Font.Gotham,
            Text = self._subtitle,
            TextColor3 = theme.Text.Tertiary,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = container,
        })
    end

    -- Progress bar (optional)
    if self._showProgress then
        local ProgressBar = require(script.Parent.ProgressBar)
        self.ProgressBar = ProgressBar.new({
            ShowLabel = true,
            Size = UDim2.new(0, 300, 0, 8),
        })
        self.ProgressBar.Frame.Parent = container
    end
end

function LoadingScreen:Show()
    self.ScreenGui.Enabled = true
    Anim.FadeIn(self.Frame, 0.3)
end

function LoadingScreen:Hide()
    Anim.FadeOut(self.Frame, 0.3)
    task.delay(0.3, function()
        self.ScreenGui.Enabled = false
    end)
end

function LoadingScreen:SetProgress(value)
    if self.ProgressBar then
        self.ProgressBar:SetValue(value)
    end
end

function LoadingScreen:SetTitle(title)
    self._title = title
    if self.Title then self.Title.Text = title end
end

function LoadingScreen:SetSubtitle(subtitle)
    self._subtitle = subtitle
    if self.Subtitle then
        self.Subtitle.Text = subtitle
    elseif subtitle and subtitle ~= "" then
        local theme = Theme.Current()
        self.Subtitle = Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.Font or Enum.Font.Gotham,
            Text = subtitle,
            TextColor3 = theme.Text.Tertiary,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = self.Frame:FindFirstChild("Container"),
        })
    end
end

function LoadingScreen:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Main
    if self.Logo then self.Logo.BackgroundColor3 = self._spinnerColor or theme.Accent.Primary end
    if self.Title then self.Title.TextColor3 = theme.Text.Primary end
    if self.Subtitle then self.Subtitle.TextColor3 = theme.Text.Tertiary end
    if self.Cover then self.Cover.BackgroundColor3 = theme.Background.Main end
end

function LoadingScreen:Destroy()
    if self._spinnerConn then
        self._spinnerConn:Disconnect()
        self._spinnerConn = nil
    end
    if self.ScreenGui then self.ScreenGui:Destroy() end
    Component.Destroy(self)
end

return LoadingScreen
