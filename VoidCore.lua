--[[
    VoidUI - Core Utilities
    Signal system, Object base, and foundational utilities
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local VoidCore = {}

-- ============================================================
-- Signal: Modern event system with connections and disconnect
-- ============================================================
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _handlers = {},
        _count = 0,
    }, Signal)
end

function Signal:Connect(handler)
    self._count = self._count + 1
    local id = self._count
    self._handlers[id] = handler
    
    local connection = {}
    function connection:Disconnect()
        self._handlers[id] = nil
    end
    function connection:IsConnected()
        return self._handlers[id] ~= nil
    end
    
    return connection
end

function Signal:ConnectOnce(handler)
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        handler(...)
    end)
    return conn
end

function Signal:Fire(...)
    for _, handler in pairs(self._handlers) do
        if type(handler) == "function" then
            task.spawn(handler, ...)
        end
    end
end

function Signal:Wait()
    local event = Instance.new("BindableEvent")
    local conn = self:Connect(function(...)
        event:Fire(...)
    end)
    local args = event.Event:Wait()
    conn:Disconnect()
    return unpack(args)
end

function Signal:DisconnectAll()
    table.clear(self._handlers)
end

function Signal:GetHandlerCount()
    local count = 0
    for _ in pairs(self._handlers) do
        count = count + 1
    end
    return count
end

VoidCore.Signal = Signal

-- ============================================================
-- Promise: Lightweight promise implementation
-- ============================================================
local Promise = {}
Promise.__index = Promise

function Promise.new(executor)
    local self = setmetatable({
        _state = "pending",
        _value = nil,
        _reason = nil,
        _onResolved = {},
        _onRejected = {},
    }, Promise)
    
    local function resolve(value)
        if self._state ~= "pending" then return end
        self._state = "fulfilled"
        self._value = value
        for _, cb in ipairs(self._onResolved) do
            task.spawn(cb, value)
        end
    end
    
    local function reject(reason)
        if self._state ~= "pending" then return end
        self._state = "rejected"
        self._reason = reason
        for _, cb in ipairs(self._onRejected) do
            task.spawn(cb, reason)
        end
    end
    
    local ok, err = pcall(executor, resolve, reject)
    if not ok then
        reject(err)
    end
    
    return self
end

function Promise:Then(onResolved)
    if self._state == "fulfilled" then
        task.spawn(onResolved, self._value)
    elseif self._state == "pending" then
        table.insert(self._onResolved, onResolved)
    end
    return self
end

function Promise:Catch(onRejected)
    if self._state == "rejected" then
        task.spawn(onRejected, self._reason)
    elseif self._state == "pending" then
        table.insert(self._onRejected, onRejected)
    end
    return self
end

function Promise.Resolve(value)
    return Promise.new(function(resolve) resolve(value) end)
end

function Promise.Reject(reason)
    return Promise.new(function(_, reject) reject(reason) end)
end

function Promise.All(promises)
    return Promise.new(function(resolve, reject)
        local results = {}
        local count = #promises
        for i, p in ipairs(promises) do
            p:Then(function(val)
                results[i] = val
                count = count - 1
                if count == 0 then resolve(results) end
            end):Catch(reject)
        end
    end)
end

VoidCore.Promise = Promise

-- ============================================================
-- Object Base: Foundation for all components
-- ============================================================
local Object = {}
Object.__index = Object

function Object.new(className, data)
    local obj = data or {}
    obj.ClassName = className
    obj._connections = {}
    obj._signals = {}
    obj._children = {}
    obj._visible = true
    obj._disposed = false
    
    function obj:GetClassName()
        return self.ClassName
    end
    
    function obj:ConnectSignal(signal, handler)
        local conn = signal:Connect(handler)
        table.insert(self._connections, conn)
        return conn
    end
    
    function obj:AddSignal(name)
        local sig = Signal.new()
        self._signals[name] = sig
        return sig
    end
    
    function obj:GetSignal(name)
        return self._signals[name]
    end
    
    function obj:DisconnectAll()
        for _, conn in ipairs(self._connections) do
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end
        for _, sig in pairs(self._signals) do
            sig:DisconnectAll()
        end
        self._connections = {}
    end
    
    function obj:Dispose()
        if self._disposed then return end
        self._disposed = true
        self:DisconnectAll()
        for _, child in ipairs(self._children) do
            if child and child.Dispose then
                child:Dispose()
            end
        end
        if self.Instance then
            self.Instance:Destroy()
        end
    end
    
    return setmetatable(obj, {__index = Object})
end

VoidCore.Object = Object

-- ============================================================
-- Utility Functions
-- ============================================================
VoidCore.Utils = {}

-- Generate unique ID
function VoidCore.Utils.GenerateId()
    return HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 8)
end

-- Deep clone a table
function VoidCore.Utils.DeepClone(tbl)
    local clone = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            clone[k] = VoidCore.Utils.DeepClone(v)
        else
            clone[k] = v
        end
    end
    return clone
end

-- Merge tables (deep merge)
function VoidCore.Utils.Merge(...)
    local result = {}
    for _, tbl in ipairs({...}) do
        if type(tbl) == "table" then
            for k, v in pairs(tbl) do
                if type(v) == "table" and type(result[k]) == "table" then
                    result[k] = VoidCore.Utils.Merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end
    return result
end

-- Round number to specified decimals
function VoidCore.Utils.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Clamp value
function VoidCore.Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Lerp (linear interpolation)
function VoidCore.Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Color lerp
function VoidCore.Utils.LerpColor(c1, c2, t)
    return Color3.new(
        VoidCore.Utils.Lerp(c1.R, c2.R, t),
        VoidCore.Utils.Lerp(c1.G, c2.G, t),
        VoidCore.Utils.Lerp(c1.B, c2.B, t)
    )
end

-- Check if position is in bounds
function VoidCore.Utils.InBounds(x, y, left, top, right, bottom)
    return x >= left and x <= right and y >= top and y <= bottom
end

-- Safe wrap function
function VoidCore.Utils.Safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        warn("[VoidUI] Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Encode JSON
function VoidCore.Utils.EncodeJSON(data)
    return HttpService:JSONEncode(data)
end

-- Decode JSON
function VoidCore.Utils.DecodeJSON(str)
    return HttpService:JSONDecode(str)
end

-- Format number with thousands separator
function VoidCore.Utils.FormatNumber(n)
    local formatted = tostring(n)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

-- Truncate text
function VoidCore.Utils.Truncate(text, maxLength)
    if #text > maxLength then
        return text:sub(1, maxLength - 3) .. "..."
    end
    return text
end

-- ============================================================
-- Services (cached)
-- ============================================================
VoidCore.Services = {
    TweenService = TweenService,
    HttpService = HttpService,
    RunService = RunService,
    UserInputService = UserInputService,
    Workspace = Workspace,
    CoreGui = CoreGui,
    Players = Players,
    LocalPlayer = LocalPlayer,
    Lighting = game:GetService("Lighting"),
    TextService = game:GetService("TextService"),
    ContextActionService = game:GetService("ContextActionService"),
}

-- ============================================================
-- Parent resolution (gets a safe parent for UI)
-- ============================================================
function VoidCore.GetParent()
    -- Try to use a safe container
    local ok, result = pcall(function()
        -- Try getguihiding approach
        if RunService:IsStudio() then
            return LocalPlayer:WaitForChild("PlayerGui")
        end
        
        -- Try CoreGui first
        if CoreGui then
            return CoreGui
        end
        
        -- Fallback to PlayerGui
        return LocalPlayer:WaitForChild("PlayerGui")
    end)
    
    if ok then
        return result
    end
    
    -- Last resort
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- Instance creation helper
-- ============================================================
function VoidCore.Create(className, properties, parent)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

-- ============================================================
-- Tween helper
-- ============================================================
function VoidCore.Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- ============================================================
-- State Manager for config persistence
-- ============================================================
local StateManager = {}
StateManager.__index = StateManager

function StateManager.new(configName)
    return setmetatable({
        _name = configName or "VoidUI_Config",
        _data = {},
        _loaded = false,
    }, StateManager)
end

function StateManager:Load()
    if self._loaded then return self._data end
    self._loaded = true
    
    if isfile and isfile(self._name) then
        local ok, content = pcall(function()
            return readfile(self._name)
        end)
        if ok and content then
            local ok2, data = pcall(function()
                return VoidCore.Utils.DecodeJSON(content)
            end)
            if ok2 and data then
                self._data = data
            end
        end
    end
    return self._data
end

function StateManager:Save()
    if not writefile then
        warn("[VoidUI] writefile not available - config will not be saved")
        return false
    end
    
    local ok, json = pcall(function()
        return VoidCore.Utils.EncodeJSON(self._data)
    end)
    if not ok then return false end
    
    local ok2 = pcall(function()
        writefile(self._name, json)
    end)
    return ok2
end

function StateManager:Get(key, default)
    self:Load()
    if self._data[key] ~= nil then
        return self._data[key]
    end
    return default
end

function StateManager:Set(key, value)
    self._data[key] = value
    self:Save()
end

function StateManager:Clear()
    self._data = {}
    self:Save()
end

VoidCore.StateManager = StateManager

-- ============================================================
-- Color utilities
-- ============================================================
VoidCore.Color = {}

function VoidCore.Color.Hex(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
    )
end

function VoidCore.Color.ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255))
end

function VoidCore.Color.FromHSL(h, s, l)
    local function hueToRgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    
    local r, g, b
    if s == 0 then
        r, g, b = l, l, l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hueToRgb(p, q, h + 1/3)
        g = hueToRgb(p, q, h)
        b = hueToRgb(p, q, h - 1/3)
    end
    return Color3.new(r, g, b)
end

function VoidCore.Color.Lighten(color, amount)
    return Color3.new(
        math.min(1, color.R + amount),
        math.min(1, color.G + amount),
        math.min(1, color.B + amount)
    )
end

function VoidCore.Color.Darken(color, amount)
    return Color3.new(
        math.max(0, color.R - amount),
        math.max(0, color.G - amount),
        math.max(0, color.B - amount)
    )
end

function VoidCore.Color.WithAlpha(color, alpha)
    return Color3.new(color.R, color.G, color.B)
end

return VoidCore
