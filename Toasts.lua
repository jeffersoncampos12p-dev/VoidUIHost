--[[
    VoidUI | Toasts Component
    A toast notification system that manages and displays multiple toasts.
    Wraps Notification with a higher-level API for quick toast creation.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Toasts = {}
Toasts.__index = Toasts
setmetatable(Toasts, { __index = Component })

local _instance = nil

function Toasts.new(config, voidUI)
    if _instance then return _instance end

    local self = Component.new("Toasts")
    setmetatable(self, { __index = Toasts })

    config = config or {}
    self._toasts = {}
    self._maxToasts = config.MaxToasts or 5
    self._defaultDuration = config.DefaultDuration or 4

    _instance = self
    return self
end

function Toasts:Notify(title, description, variant, duration)
    local Notification = require(script.Parent.Notification)
    local notif = Notification.new({
        Title = title,
        Description = description,
        Variant = variant or "Info",
        Duration = duration or self._defaultDuration,
    })

    -- Remove oldest if exceeding max
    if #self._toasts >= self._maxToasts then
        local oldest = table.remove(self._toasts, 1)
        if oldest and oldest.Dismiss then
            oldest:Dismiss()
        end
    end

    table.insert(self._toasts, notif)
    notif:Show()

    notif.OnDismiss:Connect(function()
        for i, t in ipairs(self._toasts) do
            if t == notif then
                table.remove(self._toasts, i)
                break
            end
        end
    end)

    return notif
end

function Toasts:Info(title, description, duration)
    return self:Notify(title, description, "Info", duration)
end

function Toasts:Success(title, description, duration)
    return self:Notify(title, description, "Success", duration)
end

function Toasts:Warning(title, description, duration)
    return self:Notify(title, description, "Warning", duration)
end

function Toasts:Error(title, description, duration)
    return self:Notify(title, description, "Error", duration)
end

function Toasts:DismissAll()
    for _, toast in ipairs(self._toasts) do
        if toast and toast.Dismiss then
            toast:Dismiss()
        end
    end
    self._toasts = {}
end

function Toasts:GetActive()
    return #self._toasts
end

return Toasts
