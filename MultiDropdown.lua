--[[
    VoidUI - Multi Dropdown Component
    Dropdown that allows multiple selection with checkboxes.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)
local UserInputService = game:GetService("UserInputService")

local MultiDropdown = setmetatable({}, {__index = Component})
MultiDropdown.__index = MultiDropdown

function MultiDropdown.new(options, parent)
    local self = Component.new("MultiDropdown")
    setmetatable(self, {__index = MultiDropdown})
    
    self.Config = Core.Utils.Merge({
        Name = "MultiDropdown",
        Text = "MultiDropdown",
        Options = {},
        Default = {},
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
        MaxHeight = 200,
        ShowClearAll = true,
    }, options)
    
    self._values = self.Config.Default or {}
    self._expanded = false
    self._options = self.Config.Options
    
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    self:_updateDisplay()
    
    return self
end

function MultiDropdown:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 1,
    })
    self.Instance = container
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        ZIndex = 1,
    }, container)
    self._label = label
    
    local button = Core.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 2,
    }, container)
    self._button = button
    
    local buttonCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, button)
    self._buttonCorner = buttonCorner
    
    local buttonStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, button)
    self._buttonStroke = buttonStroke
    
    -- Display text showing selected count
    local valueDisplay = Core.Create("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = "None selected",
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Tertiary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 3,
    }, button)
    self._valueDisplay = valueDisplay
    
    local chevron = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(1, -14, 0.5, -7),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914130",
        ImageColor3 = theme.Text.Tertiary,
        Rotation = 90,
        ZIndex = 3,
    }, button)
    self._chevron = chevron
    
    -- Dropdown list
    local list = Core.Create("Frame", {
        Name = "List",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
    }, container)
    self._list = list
    
    local listCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, list)
    
    local listStroke = Core.Create("UIStroke", {
        Color = theme.Border.Hover,
        Thickness = theme.Stroke.Size,
        Transparency = 0.5,
    }, list)
    self._listStroke = listStroke
    
    local listLayout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)
    self._listLayout = listLayout
    
    local listPadding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    }, list)
    
    self:_populateOptions()
    
    button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    AnimationSystem:AddHover(button, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0.1}, 0.15)
    
    UserInputService.InputBegan:Connect(function(input)
        if self._expanded and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = button.AbsolutePosition
            local buttonSize = button.AbsoluteSize
            local listPos = list.AbsolutePosition
            local listSize = list.AbsoluteSize
            
            if not Core.Utils.InBounds(mousePos.X, mousePos.Y, buttonPos.X, buttonPos.Y, buttonPos.X + buttonSize.X, buttonPos.Y + buttonSize.Y) and
               not Core.Utils.InBounds(mousePos.X, mousePos.Y, listPos.X, listPos.Y, listPos.X + listSize.X, listPos.Y + listSize.Y) then
                self:Close()
            end
        end
    end)
end

function MultiDropdown:_populateOptions()
    local theme = ThemeSystem:Current()
    
    for _, child in ipairs(self._list:GetChildren()) do
        if child.Name == "OptionItem" then
            child:Destroy()
        end
    end
    
    local maxH = 0
    
    for i, option in ipairs(self._options) do
        local optionBtn = Core.Create("TextButton", {
            Name = "OptionItem",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = theme.Component.Background,
            BackgroundTransparency = 0.5,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 11,
        }, self._list)
        
        local optionCorner = Core.Create("UICorner", {
            CornerRadius = theme.Corner.Small,
        }, optionBtn)
        
        local isSelected = self:_isSelected(option)
        
        -- Checkbox
        local box = Core.Create("Frame", {
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.fromOffset(5, 5),
            BackgroundColor3 = isSelected and theme.Accent or theme.Component.Background,
            BorderSizePixel = 0,
            ZIndex = 12,
        }, optionBtn)
        
        local boxCorner = Core.Create("UICorner", {
            CornerRadius = theme.Corner.Small,
        }, box)
        
        local boxStroke = Core.Create("UIStroke", {
            Color = isSelected and theme.Accent or theme.Border.Default,
            Thickness = 1,
            Transparency = 0.5,
        }, box)
        
        if isSelected then
            local check = Core.Create("ImageLabel", {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://12634914136",
                ImageColor3 = theme.Text.OnAccent,
                ZIndex = 13,
            }, box)
        end
        
        local optionLabel = Core.Create("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.fromOffset(28, 0),
            BackgroundTransparency = 1,
            Text = tostring(option),
            Font = theme.Font,
            TextSize = theme.TextSize.Small,
            TextColor3 = theme.Text.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.Ellipsis,
            ZIndex = 12,
        }, optionBtn)
        
        AnimationSystem:AddHover(optionBtn, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0}, 0.1)
        
        optionBtn.MouseButton1Click:Connect(function()
            self:ToggleOption(option)
        end)
        
        maxH = maxH + 30
    end
    
    self._listMaxHeight = math.min(maxH + 8, self.Config.MaxHeight)
end

function MultiDropdown:_isSelected(value)
    for _, v in ipairs(self._values) do
        if v == value then return true end
    end
    return false
end

function MultiDropdown:_updateDisplay()
    local count = #self._values
    if count == 0 then
        self._valueDisplay.Text = "None selected"
        self._valueDisplay.TextColor3 = ThemeSystem:Current().Text.Tertiary
    elseif count == 1 then
        self._valueDisplay.Text = tostring(self._values[1])
        self._valueDisplay.TextColor3 = ThemeSystem:Current().Text.Primary
    else
        self._valueDisplay.Text = count .. " selected"
        self._valueDisplay.TextColor3 = ThemeSystem:Current().Text.Primary
    end
end

function MultiDropdown:ToggleOption(value)
    local found = false
    for i, v in ipairs(self._values) do
        if v == value then
            table.remove(self._values, i)
            found = true
            break
        end
    end
    if not found then
        table.insert(self._values, value)
    end
    
    self:_populateOptions()
    self:_updateDisplay()
    self.OnChanged:Fire(self._values)
    if self.Config.Callback then
        task.spawn(self.Config.Callback, self._values)
    end
end

function MultiDropdown:GetValues()
    return self._values
end

function MultiDropdown:SetValues(values)
    self._values = values or {}
    self:_populateOptions()
    self:_updateDisplay()
end

function MultiDropdown:ClearAll()
    self._values = {}
    self:_populateOptions()
    self:_updateDisplay()
    self.OnChanged:Fire(self._values)
    if self.Config.Callback then
        task.spawn(self.Config.Callback, self._values)
    end
end

function MultiDropdown:Toggle()
    if self._expanded then
        self:Close()
    else
        self:Open()
    end
end

function MultiDropdown:Open()
    if self._expanded then return end
    self._expanded = true
    self._list.Visible = true
    self._list.Size = UDim2.new(1, 0, 0, 0)
    AnimationSystem:Tween(self._list, {Size = UDim2.new(1, 0, 0, self._listMaxHeight or 200)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._chevron, {Rotation = -90}, 0.2)
end

function MultiDropdown:Close()
    if not self._expanded then return end
    self._expanded = false
    AnimationSystem:Tween(self._list, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._chevron, {Rotation = 90}, 0.2)
    task.delay(0.2, function()
        if not self._expanded then
            self._list.Visible = false
        end
    end)
end

function MultiDropdown:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._button then
        self._button.BackgroundColor3 = theme.Component.Background
    end
    if self._buttonStroke then
        self._buttonStroke.Color = theme.Border.Default
    end
    if self._valueDisplay then
        self._valueDisplay.Font = theme.Font
        self:_updateDisplay()
    end
    if self._chevron then
        self._chevron.ImageColor3 = theme.Text.Tertiary
    end
    if self._list then
        self._list.BackgroundColor3 = theme.Component.Background
    end
    if self._listStroke then
        self._listStroke.Color = theme.Border.Hover
    end
    self:_populateOptions()
end

return MultiDropdown
