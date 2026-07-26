--[[
    VoidUI | WelcomeScreen Component
    A multi-step welcome/onboarding screen with slides, progress indicator,
    and navigation (Next/Back/Skip). Used for first-time user introduction.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local WelcomeScreen = {}
WelcomeScreen.__index = WelcomeScreen
setmetatable(WelcomeScreen, { __index = Component })

function WelcomeScreen.new(config, voidUI)
    local self = Component.new("WelcomeScreen")
    setmetatable(self, { __index = WelcomeScreen })

    config = config or {}
    self._steps = config.Steps or {}
    self._size = config.Size or UDim2.new(0, 500, 0, 400)
    self._currentStep = 1

    self.OnComplete = self:AddSignal("OnComplete")
    self.OnSkip = self:AddSignal("OnSkip")

    self:_createUI()
    return self
end

function WelcomeScreen:_createUI()
    local theme = Theme.Current()

    self.ScreenGui = Create("ScreenGui", {
        Name = "VoidUI_Welcome",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9998,
        Parent = VoidCore.GetParent(),
    })

    self.Backdrop = Create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.ScreenGui,
    })

    self.Frame = Create("Frame", {
        Name = "WelcomeFrame",
        BackgroundColor3 = theme.Background.Main,
        BackgroundTransparency = 0.02,
        Size = self._size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.Backdrop,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = self.Frame })
    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 24),
        PaddingRight = UDim.new(0, 24),
        PaddingTop = UDim.new(0, 24),
        PaddingBottom = UDim.new(0, 24),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Frame,
    })

    -- Icon area
    self.IconContainer = Create("Frame", {
        Name = "IconContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 80),
        LayoutOrder = 0,
        Parent = self.Frame,
    })

    self.IconLabel = Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 64, 0, 64),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 8),
        BackgroundTransparency = 1,
        Image = "",
        Parent = self.IconContainer,
    })

    -- Title
    self.Title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Font = theme.Font or Enum.Font.GothamBold,
        Text = "",
        TextColor3 = theme.Text.Primary,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 1,
        Parent = self.Frame,
    })

    -- Description
    self.Description = Create("TextLabel", {
        Name = "Description",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = theme.Font or Enum.Font.Gotham,
        Text = "",
        TextColor3 = theme.Text.Secondary,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 2,
        Parent = self.Frame,
    })

    -- Step indicator (dots)
    self.StepIndicator = Create("Frame", {
        Name = "StepIndicator",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = 3,
        Parent = self.Frame,
    })

    local indicatorLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.StepIndicator,
    })

    self._dots = {}
    for i = 1, #self._steps do
        local dot = Create("Frame", {
            Name = "Dot" .. i,
            BackgroundColor3 = theme.Component.Border,
            Size = UDim2.new(0, 6, 0, 6),
            Parent = self.StepIndicator,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
        self._dots[i] = dot
    end

    -- Button container
    local Button = require(script.Parent.Button)
    self.ButtonContainer = Create("Frame", {
        Name = "ButtonContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = 4,
        Parent = self.Frame,
    })

    local btnLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        Parent = self.ButtonContainer,
    })

    -- Skip button
    self.SkipButton = Button.new({
        Text = "Skip",
        Style = "Ghost",
        Size = UDim2.new(0, 90, 0, 32),
    })
    self.SkipButton.Frame.Parent = self.ButtonContainer
    self.SkipButton.OnClick:Connect(function()
        self.OnSkip:Fire()
        self:Dismiss()
    end)

    -- Back button
    self.BackButton = Button.new({
        Text = "Back",
        Style = "Secondary",
        Size = UDim2.new(0, 90, 0, 32),
    })
    self.BackButton.Frame.Parent = self.ButtonContainer
    self.BackButton.OnClick:Connect(function()
        self:_goToStep(self._currentStep - 1)
    end)

    -- Next button
    self.NextButton = Button.new({
        Text = "Next",
        Style = "Primary",
        Size = UDim2.new(0, 90, 0, 32),
    })
    self.NextButton.Frame.Parent = self.ButtonContainer
    self.NextButton.OnClick:Connect(function()
        if self._currentStep >= #self._steps then
            self.OnComplete:Fire()
            self:Dismiss()
        else
            self:_goToStep(self._currentStep + 1)
        end
    end)

    if #self._steps > 0 then
        self:_renderStep(1)
    end
end

function WelcomeScreen:_renderStep(index)
    local theme = Theme.Current()
    self._currentStep = index
    local step = self._steps[index]
    if not step then return end

    -- Fade out, update, fade in
    Anim.FadeOut(self.Title, 0.1)
    Anim.FadeOut(self.Description, 0.1)
    Anim.FadeOut(self.IconLabel, 0.1)

    task.delay(0.1, function()
        self.Title.Text = step.Title or ""
        self.Description.Text = step.Description or ""
        self.IconLabel.Image = step.Icon or ""
        Anim.FadeIn(self.Title, 0.2)
        Anim.FadeIn(self.Description, 0.2)
        Anim.FadeIn(self.IconLabel, 0.2)
    end)

    -- Update dots
    for i, dot in ipairs(self._dots) do
        if i == index then
            Anim.Tween(dot, { BackgroundColor3 = theme.Accent.Primary, Size = UDim2.new(0, 24, 0, 6) }, 0.2)
        else
            Anim.Tween(dot, { BackgroundColor3 = theme.Component.Border, Size = UDim2.new(0, 6, 0, 6) }, 0.2)
        end
    end

    -- Update button visibility
    self.BackButton:SetVisible(index > 1)
    if index >= #self._steps then
        self.NextButton:SetText("Get Started")
    else
        self.NextButton:SetText("Next")
    end
    self.SkipButton:SetVisible(index < #self._steps)
end

function WelcomeScreen:_goToStep(index)
    if index < 1 then index = 1 end
    if index > #self._steps then index = #self._steps end
    self:_renderStep(index)
end

function WelcomeScreen:Show()
    self.ScreenGui.Enabled = true
    Anim.FadeIn(self.Frame, 0.3)
end

function WelcomeScreen:Dismiss()
    Anim.FadeOut(self.Frame, 0.3)
    Anim.FadeOut(self.Backdrop, 0.3)
    task.delay(0.3, function()
        self.ScreenGui.Enabled = false
    end)
end

function WelcomeScreen:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Main
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.Title then self.Title.TextColor3 = theme.Text.Primary end
    if self.Description then self.Description.TextColor3 = theme.Text.Secondary end
    for i, dot in ipairs(self._dots or {}) do
        if i == self._currentStep then
            dot.BackgroundColor3 = theme.Accent.Primary
        else
            dot.BackgroundColor3 = theme.Component.Border
        end
    end
end

function WelcomeScreen:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    Component.Destroy(self)
end

return WelcomeScreen
