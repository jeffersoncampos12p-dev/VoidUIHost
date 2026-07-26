--[[
    VoidUI - Event System
    Global event manager for cross-component communication,
    keybinds, and dispatch system.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local UserInputService = game:GetService("UserInputService")
local Core = require(script.Parent.core.VoidCore)

local EventSystem = {
    _globalSignals = {},
    _keybinds = {},
    _listeners = {},
}

-- ============================================================
-- Global Signal System
-- ============================================================
function EventSystem:GetSignal(name)
    if not self._globalSignals[name] then
        self._globalSignals[name] = Core.Signal.new()
    end
    return self._globalSignals[name]
end

function EventSystem:Emit(name, ...)
    local signal = self._globalSignals[name]
    if signal then
        signal:Fire(...)
    end
end

function EventSystem:On(name, handler)
    return self:GetSignal(name):Connect(handler)
end

function EventSystem:Once(name, handler)
    return self:GetSignal(name):ConnectOnce(handler)
end

function EventSystem:Off(name)
    if self._globalSignals[name] then
        self._globalSignals[name]:DisconnectAll()
    end
end

function EventSystem:HasSignal(name)
    return self._globalSignals[name] ~= nil
end

function EventSystem:ClearAll()
    for _, signal in pairs(self._globalSignals) do
        signal:DisconnectAll()
    end
    self._globalSignals = {}
end

-- ============================================================
-- Keybind System
-- ============================================================
function EventSystem:RegisterKeybind(name, keyCode, callback, options)
    options = options or {}
    local keybind = {
        name = name,
        keyCode = keyCode,
        callback = callback,
        enabled = true,
        ctrl = options.ctrl or false,
        shift = options.shift or false,
        alt = options.alt or false,
        action = options.action or "Down", -- "Down", "Up", "Hold"
    }
    
    self._keybinds[name] = keybind
    return {
        SetKeyCode = function(self, code) keybind.keyCode = code end,
        Enable = function(self) keybind.enabled = true end,
        Disable = function(self) keybind.enabled = false end,
        Destroy = function(self) self._keybinds[name] = nil end,
    }
end

function EventSystem:UnregisterKeybind(name)
    self._keybinds[name] = nil
end

-- Initialize keybind input processing
local function initKeybinds()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        for _, keybind in pairs(EventSystem._keybinds) do
            if keybind.enabled and keybind.keyCode == input.KeyCode then
                local ctrl = (keybind.ctrl and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl))) or (not keybind.ctrl)
                local shift = (keybind.shift and (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift))) or (not keybind.shift)
                local alt = (keybind.alt and (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt))) or (not keybind.alt)
                
                if ctrl and shift and alt and (keybind.action == "Down" or keybind.action == "Hold") then
                    task.spawn(keybind.callback)
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, processed)
        for _, keybind in pairs(EventSystem._keybinds) do
            if keybind.enabled and keybind.keyCode == input.KeyCode then
                if keybind.action == "Up" then
                    task.spawn(keybind.callback)
                end
            end
        end
    end)
end

initKeybinds()

-- ============================================================
-- Event Dispatcher
-- ============================================================
function EventSystem:Dispatch(action, data)
    self:Emit("action:" .. action, data)
    -- Also fire general action event
    self:Emit("action", action, data)
end

return EventSystem
