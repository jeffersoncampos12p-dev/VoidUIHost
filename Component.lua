--[[
    VoidUI - Component Base Class
    Foundation for all UI components with theming, events,
    and consistent lifecycle.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local EventSystem = require(script.Parent.events.EventSystem)
local i18n = require(script.Parent.utils.i18n)

local Component = {}
Component.__index = Component

-- ============================================================
-- Component Base Factory
-- ============================================================
function Component.new(className)
    local self = Core.Object.new(className)
    setmetatable(self, {__index = Component})
    
    self.Theme = ThemeSystem
    self.Anim = AnimationSystem
    self.Events = EventSystem
    self.i18n = i18n
    
    -- Component-specific signals
    self.OnCreate = self:AddSignal("OnCreate")
    self.OnDestroy = self:AddSignal("OnDestroy")
    self.OnThemeChanged = self:AddSignal("OnThemeChanged")
    
    return self
end

-- Get current theme (shorthand)
function Component:GetTheme()
    return self.Theme:Current()
end

-- Apply theme to this component (override in subclasses)
function Component:_ApplyTheme(theme)
    self._currentTheme = theme
    self.OnThemeChanged:Fire(theme)
    if self._applyThemeImpl then
        self:_applyThemeImpl(theme)
    end
end

-- Get a localized string
function Component:T(key, fallback)
    return self.i18n:T(key, fallback)
end

-- Enable ripple effect on a frame
function Component:AddRipple(frame, color)
    frame.MouseButton1Down:Connect(function(x, y)
        if frame.Visible then
            local framePos = frame.AbsolutePosition
            local localX = x - framePos.X
            local localY = y - framePos.Y
            self.Anim:CreateRipple(frame, Vector2.new(localX, localY), color)
        end
    end)
end

-- Get the current UI scale and pixel density
function Component:GetScale()
    if self.Instance and self.Instance:FindFirstAncestorOfClass("ScreenGui") then
        local gui = self.Instance:FindFirstAncestorOfClass("ScreenGui")
        if gui.AbsoluteSize then
            -- Detect screen size for responsive scaling
            local screen = workspace.CurrentCamera.ViewportSize
            -- Base design is 1920x1080
            return {
                X = screen.X / 1920,
                Y = screen.Y / 1080,
                Min = math.min(screen.X / 1920, screen.Y / 1080),
            }
        end
    end
    return {X = 1, Y = 1, Min = 1}
end

-- Set visibility with optional animation
function Component:SetVisible(visible, animated)
    if not animated then
        if self.Instance then
            self.Instance.Visible = visible
        end
        self._visible = visible
        return
    end
    
    if visible then
        if self.Instance then
            self.Instance.Visible = true
        end
        self.Anim:FadeIn(self.Instance, 0.2)
    else
        self.Anim:FadeOut(self.Instance, 0.2, function()
            -- already hidden by fade
        end)
    end
    self._visible = visible
end

return Component
