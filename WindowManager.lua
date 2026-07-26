--[[
    VoidUI | WindowManager Component
    Manages multiple Window instances, including focus management, z-ordering,
    and window switching. Provides a unified interface for multi-window apps.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local WindowManager = {}
WindowManager.__index = WindowManager
setmetatable(WindowManager, { __index = Component })

function WindowManager.new(config, voidUI)
    local self = Component.new("WindowManager")
    setmetatable(self, { __index = WindowManager })

    config = config or {}
    self._windows = {}
    self._activeWindow = nil
    self._maxZIndex = 0

    self.OnWindowFocus = self:AddSignal("OnWindowFocus")
    self.OnWindowAdded = self:AddSignal("OnWindowAdded")
    self.OnWindowRemoved = self:AddSignal("OnWindowRemoved")

    return self
end

function WindowManager:AddWindow(window)
    if not window then return end
    table.insert(self._windows, window)
    self._maxZIndex = self._maxZIndex + 1

    -- Set z-index for the window's ScreenGui
    if window.ScreenGui then
        window.ScreenGui.DisplayOrder = self._maxZIndex
    end

    -- Register focus handler
    if window.Frame then
        window.Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:FocusWindow(window)
            end
        end)
    end

    self.OnWindowAdded:Fire(window)
    self:FocusWindow(window)
    return window
end

function WindowManager:FocusWindow(window)
    if self._activeWindow == window then return end

    self._activeWindow = window
    self._maxZIndex = self._maxZIndex + 1

    if window.ScreenGui then
        window.ScreenGui.DisplayOrder = self._maxZIndex
    end

    -- Update visual focus state
    local theme = Theme.Current()
    for _, w in ipairs(self._windows) do
        if w ~= window and w.Frame then
            local stroke = w.Frame:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Transparency = 0.8
            end
        end
    end

    if window.Frame then
        local stroke = window.Frame:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Transparency = theme.Stroke.Transparency or 0.5
        end
    end

    self.OnWindowFocus:Fire(window)
end

function WindowManager:RemoveWindow(window)
    for i, w in ipairs(self._windows) do
        if w == window then
            table.remove(self._windows, i)
            self.OnWindowRemoved:Fire(window)
            if self._activeWindow == window and #self._windows > 0 then
                self:FocusWindow(self._windows[#self._windows])
            end
            break
        end
    end
end

function WindowManager:GetWindows()
    return self._windows
end

function WindowManager:GetActiveWindow()
    return self._activeWindow
end

function WindowManager:CloseAll()
    for _, w in ipairs(self._windows) do
        if w.Close then w:Close() end
        if w.Destroy then w:Destroy() end
    end
    self._windows = {}
    self._activeWindow = nil
end

return WindowManager
