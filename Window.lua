--[[
    VoidUI - Window Component
    The main window with title bar, navigation tabs, content area,
    theming, acrylic blur, draggable, minimizable, and closable.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local i18n = require(script.Parent.utils.i18n)
local Component = require(script.Component)
local EventSystem = require(script.Parent.events.EventSystem)

local Window = setmetatable({}, {__index = Component})
Window.__index = Window

-- ============================================================
-- Window Factory
-- ============================================================
function Window.new(config, voidUI)
    local self = Component.new("Window")
    setmetatable(self, {__index = Window})
    
    -- Store VoidUI reference for global access
    self._voidUI = voidUI
    
    -- Configuration
    self.Config = Core.Utils.Merge({
        Title = "VoidUI",
        Subtitle = "",
        Theme = "Dark",
        Acrylic = true,
        SaveConfig = true,
        ConfigName = "VoidUI",
        Size = UDim2.fromOffset(680, 480),
        MinSize = Vector2.new(400, 280),
        MaxSize = Vector2.new(1200, 800),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Minimizable = true,
        Closable = true,
        Resizable = false,
        Draggable = true,
        ShowSidebar = false,
        SideBarWidth = 200,
        Accent = nil,
    }, config)
    
    -- State
    self._tabs = {}
    self._tabButtons = {}
    self._activeTab = nil
    self._minimized = false
    self._state = "open"
    
    -- Window events
    self.OnClose = self:AddSignal("OnClose")
    self.OnOpen = self:AddSignal("OnOpen")
    self.OnResize = self:AddSignal("OnResize")
    self.OnFocus = self:AddSignal("OnFocus")
    self.OnMinimize = self:AddSignal("OnMinimize")
    self.OnMaximize = self:AddSignal("OnMaximize")
    
    -- Apply theme if specified
    if self.Config.Theme then
        ThemeSystem:Set(self.Config.Theme)
    end
    if self.Config.Accent then
        ThemeSystem:GetTheme().Accent = self.Config.Accent
    end
    
    -- Create the window
    self:_createUI()
    
    -- Register for theme changes
    self._themeUnregister = ThemeSystem:RegisterComponent(self)
    
    -- Apply initial theme
    self:_applyThemeImpl(ThemeSystem:Current())
    
    -- State manager for config persistence
    if self.Config.SaveConfig then
        self._stateManager = Core.StateManager.new(self.Config.ConfigName .. "_state.json")
        self:_loadState()
    end
    
    self.OnOpen:Fire(self)
    
    return self
end

-- ============================================================
-- UI Creation
-- ============================================================
function Window:_createUI()
    local parent = Core.GetParent()
    
    -- ScreenGui
    local screenGui = Core.Create("ScreenGui", {
        Name = "VoidUI_" .. (self.Config.Title:gsub("%s", "_")),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, parent)
    self.Instance = screenGui
    
    -- Acrylic blur
    if self.Config.Acrylic then
        local blur = Core.Create("Frame", {
            Name = "Acrylic",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            ZIndex = 0,
        }, screenGui)
        self._acrylic = blur
        
        -- Acrylic gradient
        local gradient = Core.Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.9),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, blur)
    end
    
    -- Main window container
    local window = Core.Create("Frame", {
        Name = "Window",
        Size = self.Config.Size,
        Position = self.Config.Position,
        AnchorPoint = self.Config.AnchorPoint,
        BackgroundColor3 = ThemeSystem:Current().Background.Base,
        BackgroundTransparency = ThemeSystem:Current().Transparency.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1,
    }, screenGui)
    self._windowFrame = window
    
    -- Shadow
    local shadow = Core.Create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(22, 22, 282, 282),
        BackgroundTransparency = 1,
        ImageTransparency = 0.3,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 0,
    }, window)
    self._shadow = shadow
    
    -- Corner radius
    local corner = Core.Create("UICorner", {
        CornerRadius = ThemeSystem:Current().Corner.Large,
    }, window)
    self._corner = corner
    
    -- Stroke
    local stroke = Core.Create("UIStroke", {
        Color = ThemeSystem:Current().Border.Default,
        Thickness = ThemeSystem:Current().Stroke.Size,
        Transparency = ThemeSystem:Current().Transparency.Border,
    }, window)
    self._stroke = stroke
    
    -- Gradient overlay (subtle gradient for premium feel)
    local gradOverlay = Core.Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 30)),
        }),
    }, window)
    self._gradOverlay = gradOverlay
    
    -- Top bar (title bar)
    local topBar = Core.Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = ThemeSystem:Current().Background.Surface,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, window)
    self._topBar = topBar
    
    local topBarCorner = Core.Create("UICorner", {
        CornerRadius = ThemeSystem:Current().Corner.Large,
    }, topBar)
    
    -- Bottom corner cutting (only round top)
    local topBarCutFix = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromScale(0, 0.5),
        BackgroundColor3 = topBar.BackgroundColor3,
        BackgroundTransparency = topBar.BackgroundTransparency,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, topBar)
    
    -- Logo / Title area
    local logoFrame = Core.Create("Frame", {
        Name = "Logo",
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(16, 8),
        BackgroundColor3 = ThemeSystem:Current().Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, topBar)
    
    local logoCorner = Core.Create("UICorner", {
        CornerRadius = ThemeSystem:Current().Corner.Medium,
    }, logoFrame)
    
    local logoText = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914126",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 4,
    }, logoFrame)
    
    -- Logo gradient
    local logoGradient = Core.Create("UIGradient", {
        Rotation = 45,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, ThemeSystem:Current().Accent),
            ColorSequenceKeypoint.new(1, ThemeSystem:Current().AccentGradient),
        }),
    }, logoFrame)
    self._logoGradient = logoGradient
    
    -- Title
    local title = Core.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(54, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Title,
        Font = ThemeSystem:Current().Font,
        TextSize = ThemeSystem:Current().TextSize.Medium,
        TextColor3 = ThemeSystem:Current().Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        ZIndex = 3,
    }, topBar)
    self._title = title
    
    -- Subtitle
    if self.Config.Subtitle then
        local subtitle = Core.Create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(0, 200, 0, 14),
            Position = UDim2.fromOffset(54, 24),
            BackgroundTransparency = 1,
            Text = self.Config.Subtitle,
            Font = ThemeSystem:Current().Font,
            TextSize = ThemeSystem:Current().TextSize.XS,
            TextColor3 = ThemeSystem:Current().Text.Tertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            ZIndex = 3,
        }, topBar)
        self._subtitle = subtitle
    end
    
    -- Window control buttons (right side)
    local controlButtons = Core.Create("Frame", {
        Name = "Controls",
        Size = UDim2.fromOffset(96, 32),
        Position = UDim2.new(1, -108, 0, 6),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, topBar)
    self._controlsFrame = controlButtons
    
    -- Minimize button
    if self.Config.Minimizable then
        local minimizeBtn = Core.Create("TextButton", {
            Name = "Minimize",
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.fromOffset(0, 0),
            BackgroundColor3 = ThemeSystem:Current().Component.Background,
            BackgroundTransparency = 0.5,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
        }, controlButtons)
        local minCorner = Core.Create("UICorner", {
            CornerRadius = ThemeSystem:Current().Corner.Small,
        }, minimizeBtn)
        local minIcon = Core.Create("ImageLabel", {
            Size = UDim2.fromOffset(12, 12),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://12634914131",
            ImageColor3 = ThemeSystem:Current().Text.Secondary,
            ZIndex = 4,
        }, minimizeBtn)
        self._minimizeBtn = minimizeBtn
        self._minimizeIcon = minIcon
        
        -- Hover effect
        AnimationSystem:AddHover(minimizeBtn, {BackgroundColor3 = ThemeSystem:Current().Component.Hover}, 0.15)
        self:AddRipple(minimizeBtn, Color3.fromRGB(255, 255, 255))
        
        minimizeBtn.MouseButton1Click:Connect(function()
            self:Minimize()
        end)
    end
    
    -- Close button
    if self.Config.Closable then
        local closeBtn = Core.Create("TextButton", {
            Name = "Close",
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.fromOffset(68, 0),
            BackgroundColor3 = ThemeSystem:Current().Component.Background,
            BackgroundTransparency = 0.5,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
        }, controlButtons)
        local closeCorner = Core.Create("UICorner", {
            CornerRadius = ThemeSystem:Current().Corner.Small,
        }, closeBtn)
        local closeIcon = Core.Create("ImageLabel", {
            Size = UDim2.fromOffset(12, 12),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://12634914135",
            ImageColor3 = ThemeSystem:Current().Text.Secondary,
            ZIndex = 4,
        }, closeBtn)
        self._closeBtn = closeBtn
        self._closeIcon = closeIcon
        
        AnimationSystem:AddHover(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 60, 80)}, 0.15)
        self:AddRipple(closeBtn, Color3.fromRGB(255, 255, 255))
        
        closeBtn.MouseButton1Click:Connect(function()
            self:Close()
        end)
    end
    
    -- Tab bar (below top bar)
    local tabContainer = Core.Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.fromOffset(0, 44),
        BackgroundColor3 = ThemeSystem:Current().Background.Surface,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, window)
    self._tabBar = tabContainer
    
    -- Tab list (horizontal scroll)
    local tabList = Core.Create("Frame", {
        Name = "TabList",
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.fromOffset(16, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, tabContainer)
    self._tabList = tabList
    
    -- UIListLayout for tabs
    local tabListLayout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)
    self._tabListLayout = tabListLayout
    
    -- Tab divider
    local tabDivider = Core.Create("Frame", {
        Name = "TabDivider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.fromOffset(0, 39),
        BackgroundColor3 = ThemeSystem:Current().Border.Default,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, tabContainer)
    self._tabDivider = tabDivider
    
    -- Content area (for all tabs)
    local contentArea = Core.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -84),
        Position = UDim2.fromOffset(0, 84),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, window)
    self._contentArea = contentArea
    
    -- Make window draggable
    if self.Config.Draggable then
        self:_makeDraggable()
    end
    
    -- Add subtle entrance animation
    window.Size = UDim2.new(0, 0, 0, 0)
    window.BackgroundTransparency = 1
    AnimationSystem:Tween(window, {Size = self.Config.Size, BackgroundTransparency = ThemeSystem:Current().Transparency.Background}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

-- ============================================================
-- Make Window Draggable
-- ============================================================
function Window:_makeDraggable()
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self._windowFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        self.OnResize:Fire(self._windowFrame.AbsoluteSize)
    end
    
    self._topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self._windowFrame.Position
            self.OnFocus:Fire()
        end
    end)
    
    self._topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- Tab Management
-- ============================================================
function Window:CreateTab(name, icon)
    -- Import Tab component
    local Tab = require(script.Tab)
    local tab = Tab.new(name, icon, self)
    
    -- Add to internal list
    table.insert(self._tabs, tab)
    table.insert(self._tabButtons, tab)
    
    -- Set first tab active
    if #self._tabs == 1 then
        self:_setActiveTab(tab)
    end
    
    return tab
end

-- Internal: Set active tab
function Window:_setActiveTab(tab)
    if self._activeTab == tab then return end
    
    -- Deactivate current tab
    if self._activeTab then
        self._activeTab:SetActive(false)
    end
    
    -- Activate new tab
    self._activeTab = tab
    tab:SetActive(true)
end

-- ============================================================
-- Window Controls
-- ============================================================
function Window:Minimize()
    if self._minimized then return end
    self._minimized = true
    
    AnimationSystem:Tween(self._contentArea, {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, 44)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._windowFrame, {Size = UDim2.new(self.Config.Size.X.Scale, self.Config.Size.X.Offset, 0, 44)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    self.OnMinimize:Fire()
end

function Window:Maximize()
    if not self._minimized then return end
    self._minimized = false
    
    AnimationSystem:Tween(self._windowFrame, {Size = self.Config.Size}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._contentArea, {Size = UDim2.new(1, 0, 1, -84), Position = UDim2.fromOffset(0, 84)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    self.OnMaximize:Fire()
end

function Window:ToggleMinimize()
    if self._minimized then
        self:Maximize()
    else
        self:Minimize()
    end
end

function Window:Close()
    if self._state == "closed" then return end
    self._state = "closing"
    
    -- Save state if enabled
    if self._stateManager then
        self:_saveState()
    end
    
    -- Fade out animation
    AnimationSystem:Tween(self._windowFrame, {Size = UDim2.new(self.Config.Size.X.Scale, self.Config.Size.X.Offset * 0.8, 0, 0), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    task.delay(0.25, function()
        self.OnClose:Fire()
        self.Instance.Enabled = false
        self._state = "closed"
    end)
end

function Window:Open()
    if self._state == "open" then return end
    self._state = "open"
    self.Instance.Enabled = true
    AnimationSystem:Tween(self._windowFrame, {Size = self.Config.Size, BackgroundTransparency = ThemeSystem:Current().Transparency.Background}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    self.OnOpen:Fire()
end

function Window:Destroy()
    self.OnDestroy:Fire()
    if self._themeUnregister then
        self._themeUnregister()
    end
    self:DisconnectAll()
    self.Instance:Destroy()
end

-- ============================================================
-- Getters & Setters
-- ============================================================
function Window:SetTitle(text)
    self.Config.Title = text
    if self._title then
        self._title.Text = text
    end
end

function Window:SetSubtitle(text)
    self.Config.Subtitle = text
    if self._subtitle then
        self._subtitle.Text = text
    end
end

function Window:GetTitle()
    return self.Config.Title
end

function Window:GetSize()
    return self._windowFrame.AbsoluteSize
end

function Window:GetPosition()
    return self._windowFrame.AbsolutePosition
end

function Window:SetSize(size, animated)
    if animated then
        AnimationSystem:Tween(self._windowFrame, {Size = size}, 0.2)
    else
        self._windowFrame.Size = size
    end
    self.Config.Size = size
end

function Window:SetPosition(position, animated)
    if animated then
        AnimationSystem:Tween(self._windowFrame, {Position = position}, 0.2)
    else
        self._windowFrame.Position = position
    end
    self.Config.Position = position
end

function Window:GetTabs()
    return self._tabs
end

-- ============================================================
-- Theme Application
-- ============================================================
function Window:_applyThemeImpl(theme)
    self._currentTheme = theme
    
    if self._windowFrame then
        self._windowFrame.BackgroundColor3 = theme.Background.Base
        self._windowFrame.BackgroundTransparency = theme.Transparency.Background
    end
    
    if self._stroke then
        self._stroke.Color = theme.Border.Default
    end
    
    if self._topBar then
        self._topBar.BackgroundColor3 = theme.Background.Surface
    end
    
    if self._tabBar then
        self._tabBar.BackgroundColor3 = theme.Background.Surface
    end
    
    if self._tabDivider then
        self._tabDivider.BackgroundColor3 = theme.Border.Default
    end
    
    if self._title then
        self._title.Font = theme.Font
        self._title.TextColor3 = theme.Text.Primary
    end
    
    if self._subtitle then
        self._subtitle.Font = theme.Font
        self._subtitle.TextColor3 = theme.Text.Tertiary
    end
    
    -- Logo
    if self._logoGradient then
        local colorSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentGradient),
        })
        self._logoGradient.Color = colorSeq
    end
end

-- ============================================================
-- State Persistence
-- ============================================================
function Window:_saveState()
    if not self._stateManager then return end
    self._stateManager:Set("theme", ThemeSystem:CurrentName())
    self._stateManager:Set("windowPos", {
        x = self._windowFrame.Position.X.Scale,
        xOff = self._windowFrame.Position.X.Offset,
        y = self._windowFrame.Position.Y.Scale,
        yOff = self._windowFrame.Position.Y.Offset,
    })
    self._stateManager:Set("windowSize", {
        x = self._windowFrame.Size.X.Scale,
        xOff = self._windowFrame.Size.X.Offset,
        y = self._windowFrame.Size.Y.Scale,
        yOff = self._windowFrame.Size.Y.Offset,
    })
    self._stateManager:Save()
end

function Window:_loadState()
    if not self._stateManager then return end
    
    local savedTheme = self._stateManager:Get("theme")
    if savedTheme then
        ThemeSystem:Set(savedTheme)
    end
    
    local savedPos = self._stateManager:Get("windowPos")
    if savedPos and self._windowFrame then
        self._windowFrame.Position = UDim2.new(savedPos.x, savedPos.xOff, savedPos.y, savedPos.yOff)
    end
    
    local savedSize = self._stateManager:Get("windowSize")
    if savedSize and self._windowFrame then
        self._windowFrame.Size = UDim2.new(savedSize.x, savedSize.xOff, savedSize.y, savedSize.yOff)
        self.Config.Size = self._windowFrame.Size
    end
end

return Window
