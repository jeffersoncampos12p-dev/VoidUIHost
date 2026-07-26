--[[
    VoidUI | TabsReorder Component
    Provides drag-to-reorder functionality for tab bars. Allows users to
    rearrange tabs by dragging them within the tab bar.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local TabsReorder = {}
TabsReorder.__index = TabsReorder
setmetatable(TabsReorder, { __index = Component })

function TabsReorder.new(config, voidUI)
    local self = Component.new("TabsReorder")
    setmetatable(self, { __index = TabsReorder })

    config = config or {}
    self._tabs = config.Tabs or {} -- array of tab objects with .Frame, .OnDragged
    self._container = config.Container or nil -- the UIListLayout parent
    self._size = config.Size or UDim2.new(1, 0, 0, 36)

    self.OnReorder = self:AddSignal("OnReorder")

    self:_createUI()
    self:_setupDrag()
    return self
end

function TabsReorder:_createUI()
    -- The TabsReorder manages an existing container of tabs
    -- It adds drag handles and reorder logic
    if not self._container then return end

    self._layout = self._container:FindFirstChildOfClass("UIListLayout")
    if not self._layout then
        self._layout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            Parent = self._container,
        })
    end
end

function TabsReorder:_setupDrag()
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    for i, tab in ipairs(self._tabs) do
        if tab.Frame then
            local isDragging = false
            local dragStartPos
            local dragIndex = i

            tab.Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Only start drag if tab is not being activated by a click
                    -- Use a longer threshold for drag vs click
                    isDragging = true
                    dragStartPos = input.Position
                    dragIndex = i
                end
            end)

            tab.Frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UIS:GetMouseLocation()
                    local framePos = tab.Frame.AbsolutePosition
                    local frameSize = tab.Frame.AbsoluteSize

                    -- Check if mouse is over a different tab
                    for j, otherTab in ipairs(self._tabs) do
                        if j ~= dragIndex and otherTab.Frame then
                            local otherPos = otherTab.Frame.AbsolutePosition
                            local otherSize = otherTab.Frame.AbsoluteSize
                            if mousePos.X >= otherPos.X and mousePos.X <= otherPos.X + otherSize.X and
                               mousePos.Y >= otherPos.Y and mousePos.Y <= otherPos.Y + otherSize.Y then
                                -- Swap tabs
                                self:_swapTabs(dragIndex, j)
                                dragIndex = j
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end

function TabsReorder:_swapTabs(indexA, indexB)
    -- Swap in array
    local temp = self._tabs[indexA]
    self._tabs[indexA] = self._tabs[indexB]
    self._tabs[indexB] = temp

    -- Update LayoutOrder
    for i, tab in ipairs(self._tabs) do
        if tab.Frame then
            tab.Frame.LayoutOrder = i
        end
    end

    self.OnReorder:Fire(self._tabs, indexA, indexB)
end

function TabsReorder:GetOrder()
    local order = {}
    for i, tab in ipairs(self._tabs) do
        table.insert(order, tab)
    end
    return order
end

return TabsReorder
