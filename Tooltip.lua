--[[
    VoidUI | Tooltip Component
    Hover tooltips that display additional information when hovering over
    an element. Supports text, rich formatting, and positioning.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Tooltip = {}
Tooltip.__index = Tooltip
setmetatable(Tooltip, { __index = Component })

local _tooltipGui = nil

local function _getGui()
    if _tooltipGui then return _tooltipGui end
    _tooltipGui = Create("ScreenGui", {
        Name = "VoidUI_Tooltips",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
        Parent = VoidCore.GetParent(),
    })
    return _tooltipGui
end

function Tooltip.new(config, voidUI)
    local self = Component.new("Tooltip")
    setmetatable(self, { __index = Tooltip })

    config = config or {}
    self._text = config.Text or "Tooltip"
    self._target = config.Target or nil -- the element to attach to
    self._delay = config.Delay or 0.5
    self._position = config.Position or "Top" -- Top, Bottom, Left, Right
    self._enabled = config.Enabled ~= nil and config.Enabled or true

    self:_createUI()
    self:_attachToTarget()
    return self
end

function Tooltip:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = theme.Background.Dark or theme.Background.Main,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 9999,
        Parent = nil,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Frame,
    })

    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = self.Frame,
    })

    -- Shadow
    Create("UIStroke", {
        Color = Color3.new(0, 0, 0),
        Thickness = 0,
        Transparency = 1,
        Parent = self.Frame,
    })

    self.Label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = self._text,
        TextColor3 = theme.Text.Primary,
        TextSize = 12,
        TextWrapped = false,
        Parent = self.Frame,
    })
end

function Tooltip:_attachToTarget()
    if not self._target then return end

    local hoverConn
    local mouseLeaveConn
    local showTimer

    self._target.MouseEnter:Connect(function()
        if not self._enabled then return end
        showTimer = task.delay(self._delay, function()
            self:_show()
        end)
    end)

    self._target.MouseLeave:Connect(function()
        if showTimer then
            task.cancel(showTimer)
            showTimer = nil
        end
        self:_hide()
    end)
end

function Tooltip:_show()
    local gui = _getGui()
    self.Frame.Parent = gui
    self.Frame.Visible = true

    -- Calculate position relative to target
    if self._target then
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local targetPos = self._target.AbsolutePosition
        local targetSize = self._target.AbsoluteSize
        local tipSize = self.Frame.AbsoluteSize

        local x, y
        if self._position == "Top" then
            x = targetPos.X + targetSize.X / 2
            y = targetPos.Y - tipSize.Y - 8
        elseif self._position == "Bottom" then
            x = targetPos.X + targetSize.X / 2
            y = targetPos.Y + targetSize.Y + 8
        elseif self._position == "Left" then
            x = targetPos.X - tipSize.X - 8
            y = targetPos.Y + targetSize.Y / 2
        else -- Right
            x = targetPos.X + targetSize.X + 8
            y = targetPos.Y + targetSize.Y / 2
        end

        self.Frame.Position = UDim2.new(0, x, 0, y - 36) -- offset for top bar
    end

    Anim.FadeIn(self.Frame, 0.15)
end

function Tooltip:_hide()
    Anim.FadeOut(self.Frame, 0.1)
    task.delay(0.1, function()
        if self.Frame then self.Frame.Visible = false end
    end)
end

function Tooltip:SetText(text)
    self._text = text
    if self.Label then self.Label.Text = text end
end

function Tooltip:SetTarget(target)
    self._target = target
    self:_attachToTarget()
end

function Tooltip:SetEnabled(enabled)
    self._enabled = enabled
    if not enabled then self:_hide() end
end

function Tooltip:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Dark or theme.Background.Main
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.Label then self.Label.TextColor3 = theme.Text.Primary end
end

return Tooltip
