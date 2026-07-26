--[[
    VoidUI - Spacer Component
    Empty space to add vertical or horizontal spacing.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local Component = require(script.Component)

local Spacer = setmetatable({}, {__index = Component})
Spacer.__index = Spacer

function Spacer.new(options, parent)
    local self = Component.new("Spacer")
    setmetatable(self, {__index = Spacer})
    
    self.Config = Core.Utils.Merge({
        Name = "Spacer",
        Size = UDim2.new(1, 0, 0, 12),
    }, options)
    
    local frame = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundTransparency = 1,
        ZIndex = 0,
    })
    self.Instance = frame
    
    return self
end

function Spacer:SetSize(size)
    self.Config.Size = size
    self.Instance.Size = size
end

return Spacer
