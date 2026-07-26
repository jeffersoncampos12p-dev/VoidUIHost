--[[
    VoidUI - Dropdown Component
    Modern dropdown with smooth expand/collapse, search, icons,
    and value selection.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)
local UserInputService = game:GetService("UserInputService")

local Dropdown = setmetatable({}, {__index = Component})
Dropdown.__index = Dropdown

function Dropdown.new(options, parent)
    local self = Component.new("Dropdown")
    setmetatable(self, {__index = Dropdown})
    
    self.Config = Core.Utils.Merge({
        Name = "Dropdown",
        Text = "Dropdown",
        Options = {},
        Default = nil,
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
        Searchable = false,
        MaxHeight = 200,
        Icons = {},
    }, options)
    
    self._value = self.Config.Default
    self._expanded = false
    self._options = self.Config.Options
    
    self.OnSelected = self:AddSignal("OnSelected")
    
    self:_createUI()
    
    return self
end

function Dropdown:_createUI()
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
    
    -- Label
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
    
    -- Button (the clickable dropdown)
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
    
    -- Button content
    local btnContent = Core.Create("Frame", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, button)
    
    local btnLayout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, btnContent)
    
    -- Selected value display
    local valueDisplay = Core.Create("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        BackgroundTransparency = 1,
        Text = self._value or "Select...",
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = self._value and theme.Text.Primary or theme.Text.Tertiary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 3,
    }, btnContent)
    self._valueDisplay = valueDisplay
    
    -- Chevron icon
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
    
    -- Dropdown list (initially hidden)
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
    
    -- List layout
    local listLayout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)
    self._listLayout = listLayout
    
    -- Padding
    local listPadding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    }, list)
    
    -- Populate options
    self:_populateOptions()
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    AnimationSystem:AddHover(button, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0.1}, 0.15)
    
    -- Close on outside click
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

function Dropdown:_populateOptions()
    local theme = ThemeSystem:Current()
    
    -- Clear existing
    for _, child in ipairs(self._list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local maxH = 0
    
    for i, option in ipairs(self._options) do
        local optionBtn = Core.Create("TextButton", {
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
        
        local optionLayout = Core.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, optionBtn)
        
        -- Icon (if provided)
        if self.Config.Icons and self.Config.Icons[option] then
            local icon = Core.Create("ImageLabel", {
                Size = UDim2.fromOffset(14, 14),
                BackgroundTransparency = 1,
                Image = self.Config.Icons[option],
                ImageColor3 = theme.Text.Secondary,
                ZIndex = 12,
            }, optionBtn)
        end
        
        local optionLabel = Core.Create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            Text = tostring(option),
            Font = theme.Font,
            TextSize = theme.TextSize.Small,
            TextColor3 = self._value == option and theme.Accent or theme.Text.Primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.Ellipsis,
            ZIndex = 12,
        }, optionBtn)
        
        AnimationSystem:AddHover(optionBtn, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0}, 0.1)
        
        optionBtn.MouseButton1Click:Connect(function()
            self:Select(option)
        end)
        
        maxH = maxH + 30
        if maxH > self.Config.MaxHeight then break end
    end
    
    self._listMaxHeight = math.min(maxH + 8, self.Config.MaxHeight)
end

function Dropdown:Toggle()
    if self._expanded then
        self:Close()
    else
        self:Open()
    end
end

function Dropdown:Open()
    if self._expanded then return end
    self._expanded = true
    
    self._list.Visible = true
    self._list.Size = UDim2.new(1, 0, 0, 0)
    
    AnimationSystem:Tween(self._list, {Size = UDim2.new(1, 0, 0, self._listMaxHeight or 200)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AnimationSystem:Tween(self._chevron, {Rotation = -90}, 0.2)
end

function Dropdown:Close()
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

function Dropdown:Select(value, fireCallback)
    if self._value == value then
        self:Close()
        return
    end
    
    self._value = value
    self._valueDisplay.Text = tostring(value)
    self._valueDisplay.TextColor3 = ThemeSystem:Current().Text.Primary
    
    -- Update option labels
    self:_populateOptions()
    
    self.OnSelected:Fire(value)
    if fireCallback ~= false and self.Config.Callback then
        task.spawn(self.Config.Callback, value)
    end
    
    self:Close()
end

function Dropdown:GetValue()
    return self._value
end

function Dropdown:SetOptions(options)
    self.Config.Options = options
    self._options = options
    self:_populateOptions()
end

function Dropdown:_applyThemeImpl(theme)
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
        self._valueDisplay.TextColor3 = self._value and theme.Text.Primary or theme.Text.Tertiary
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

return Dropdown
