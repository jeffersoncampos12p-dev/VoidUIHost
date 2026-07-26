--[[
    VoidUI | RightClickMenu Component
    Attaches a ContextMenu to a target element that appears on right-click.
    Provides a convenient wrapper for context-sensitive menus.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local RightClickMenu = {}
RightClickMenu.__index = RightClickMenu
setmetatable(RightClickMenu, { __index = Component })

function RightClickMenu.new(config, voidUI)
    local self = Component.new("RightClickMenu")
    setmetatable(self, { __index = RightClickMenu })

    config = config or {}
    self._items = config.Items or {}
    self._target = config.Target or nil

    self.OnSelect = self:AddSignal("OnSelect")

    self:_createUI()
    return self
end

function RightClickMenu:_createUI()
    -- Create the underlying ContextMenu
    local ContextMenu = require(script.Parent.ContextMenu)
    self._menu = ContextMenu.new({
        Items = self._items,
    })

    self.OnSelect = self._menu.OnSelect

    if self._target then
        self:Attach(self._target)
    end
end

function RightClickMenu:Attach(target)
    self._target = target

    target.MouseButton2Click:Connect(function()
        local UIS = game:GetService("UserInputService")
        local mousePos = UIS:GetMouseLocation()
        -- Adjust for TopBarInset
        self._menu:Show(UDim2.new(0, mousePos.X, 0, mousePos.Y - 36))
    end)
end

function RightClickMenu:AddItem(item)
    self._menu:AddItem(item)
end

function RightClickMenu:Show(position)
    self._menu:Show(position)
end

function RightClickMenu:Close()
    self._menu:Close()
end

function RightClickMenu:_applyThemeImpl(theme)
    if self._menu then self._menu:_ApplyTheme(theme) end
end

return RightClickMenu
