--[[
    VoidUI | DockingSystem Component
    A docking system for arranging windows in docked positions (left, right,
    top, bottom, center). Provides snap-to-edge docking and layout management.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local DockingSystem = {}
DockingSystem.__index = DockingSystem
setmetatable(DockingSystem, { __index = Component })

local DOCK_POSITIONS = {
    Left = { X = 0, Y = 0, W = 0.5, H = 1 },
    Right = { X = 0.5, Y = 0, W = 0.5, H = 1 },
    Top = { X = 0, Y = 0, W = 1, H = 0.5 },
    Bottom = { X = 0, Y = 0.5, W = 1, H = 0.5 },
    Center = { X = 0.25, Y = 0.25, W = 0.5, H = 0.5 },
    FullLeft = { X = 0, Y = 0, W = 0.33, H = 1 },
    FullRight = { X = 0.67, Y = 0, W = 0.33, H = 1 },
}

function DockingSystem.new(config, voidUI)
    local self = Component.new("DockingSystem")
    setmetatable(self, { __index = DockingSystem })

    config = config or {}
    self._windows = {} -- { window = dockPosition }
    self._showZones = config.ShowZones or true

    self.OnDock = self:AddSignal("OnDock")
    self.OnUndock = self:AddSignal("OnUndock")

    self:_createUI()
    return self
end

function DockingSystem:_createUI()
    local theme = Theme.Current()

    -- Docking zone indicators (hidden, shown during drag)
    self.ZoneContainer = Create("ScreenGui", {
        Name = "VoidUI_DockZones",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 8000,
        Enabled = false,
        Parent = VoidCore.GetParent(),
    })

    self._zones = {}
    for name, pos in pairs(DOCK_POSITIONS) do
        local zone = Create("Frame", {
            Name = "Zone_" .. name,
            BackgroundColor3 = theme.Accent.Primary,
            BackgroundTransparency = 0.8,
            Size = UDim2.new(pos.W, 0, pos.H, 0),
            Position = UDim2.new(pos.X, 0, pos.Y, 0),
            Visible = false,
            Parent = self.ZoneContainer,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = zone })
        self._zones[name] = zone
    end
end

function DockingSystem:DockWindow(window, position)
    local pos = DOCK_POSITIONS[position]
    if not pos then return end

    -- Animate window to docked position
    if window.Frame then
        Anim.Tween(window.Frame, {
            Size = UDim2.new(pos.W, 0, pos.H, 0),
            Position = UDim2.new(pos.X, 0, pos.Y, 0),
        }, 0.3)
    end

    self._windows[window] = position
    self.OnDock:Fire(window, position)
end

function DockingSystem:UndockWindow(window)
    if self._windows[window] then
        self._windows[window] = nil
        self.OnUndock:Fire(window)
    end
end

function DockingSystem:ShowZones()
    if not self._showZones then return end
    self.ZoneContainer.Enabled = true
    for _, zone in pairs(self._zones) do
        zone.Visible = true
        Anim.FadeIn(zone, 0.2)
    end
end

function DockingSystem:HideZones()
    for _, zone in pairs(self._zones) do
        Anim.FadeOut(zone, 0.2)
    end
    task.delay(0.2, function()
        self.ZoneContainer.Enabled = false
    end)
end

function DockingSystem:GetDockPosition(window)
    return self._windows[window]
end

function DockingSystem:GetDockedWindows()
    return self._windows
end

function DockingSystem:_applyThemeImpl(theme)
    for _, zone in pairs(self._zones) do
        zone.BackgroundColor3 = theme.Accent.Primary
    end
end

return DockingSystem
