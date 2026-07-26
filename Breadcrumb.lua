--[[
    VoidUI | Breadcrumb Component
    Navigation breadcrumb trail showing the current location hierarchy.
    Supports clickable items, separators, and the current page indicator.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Breadcrumb = {}
Breadcrumb.__index = Breadcrumb
setmetatable(Breadcrumb, { __index = Component })

function Breadcrumb.new(config, voidUI)
    local self = Component.new("Breadcrumb")
    setmetatable(self, { __index = Breadcrumb })

    config = config or {}
    self._items = config.Items or {}
    self._separator = config.Separator or "/"

    self.OnNavigate = self:AddSignal("OnNavigate")

    self:_createUI()
    return self
end

function Breadcrumb:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Breadcrumb",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = nil,
    })

    self._layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.Frame,
    })

    self:_render()
end

function Breadcrumb:_render()
    -- Clear
    for _, child in ipairs(self.Frame:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local theme = Theme.Current()

    for i, item in ipairs(self._items) do
        -- Label (clickable if not the last item)
        local isLast = (i == #self._items)

        local label = Create("TextButton", {
            Name = "Item_" .. i,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = item.Label or item,
            TextColor3 = isLast and theme.Text.Primary or theme.Text.Tertiary,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = self.Frame,
        })

        if not isLast then
            Anim.AddHover(label, { HoverColor = theme.Text.Secondary })
            label.MouseButton1Click:Connect(function()
                self.OnNavigate:Fire(item, i)
            end)
        end
    end

    -- Add separators between items
    local children = self.Frame:GetChildren()
    local labels = {}
    for _, child in ipairs(children) do
        if child:IsA("TextButton") then
            table.insert(labels, child)
        end
    end

    for i = 1, #labels - 1 do
        local sep = Create("TextLabel", {
            Name = "Separator_" .. i,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 8, 0, 18),
            Font = theme.Font or Enum.Font.Gotham,
            Text = self._separator,
            TextColor3 = theme.Text.Tertiary,
            TextSize = 12,
            LayoutOrder = labels[i].LayoutOrder + 0.5,
            Parent = self.Frame,
        })
    end
end

function Breadcrumb:SetItems(items)
    self._items = items
    self:_render()
end

function Breadcrumb:AddItem(item)
    table.insert(self._items, item)
    self:_render()
end

function Breadcrumb:_applyThemeImpl(theme)
    self:_render()
end

return Breadcrumb
