--[[
    VoidUI - SearchBox Component
    Search input with icon and callback on input change.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local SearchBox = setmetatable({}, {__index = Component})
SearchBox.__index = SearchBox

function SearchBox.new(options, parent)
    local self = Component.new("SearchBox")
    setmetatable(self, {__index = SearchBox})
    
    self.Config = Core.Utils.Merge({
        Name = "SearchBox",
        Placeholder = "Search...",
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
        DebounceTime = 0.3,
    }, options)
    
    self._value = ""
    self._debounceTimer = 0
    self.OnSearch = self:AddSignal("OnSearch")
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    
    return self
end

function SearchBox:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    self.Instance = container
    
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Pill,
    }, container)
    
    local stroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, container)
    self._stroke = stroke
    
    -- Search icon
    local icon = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromOffset(10, 9),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914134",
        ImageColor3 = theme.Text.Tertiary,
        ZIndex = 2,
    }, container)
    self._icon = icon
    
    -- Input
    local input = Core.Create("TextBox", {
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.fromOffset(30, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = self.Config.Placeholder,
        PlaceholderColor3 = theme.Text.Tertiary,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, container)
    self._input = input
    
    -- Clear button (appears when there's text)
    local clearBtn = Core.Create("TextButton", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(1, -24, 0, 8),
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 4,
    }, container)
    self._clearBtn = clearBtn
    
    local clearIcon = Core.Create("ImageLabel", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://12634914135",
        ImageColor3 = theme.Text.Tertiary,
        ZIndex = 5,
    }, clearBtn)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = input.Text
        self._value = text
        clearBtn.Visible = #text > 0
        self.OnChanged:Fire(text)
        
        -- Debounce the search callback
        self._debounceTimer = tick()
        local currentTime = self._debounceTimer
        task.delay(self.Config.DebounceTime, function()
            if self._debounceTimer == currentTime then
                self.OnSearch:Fire(text)
                if self.Config.Callback then
                    task.spawn(self.Config.Callback, text)
                end
            end
        end)
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        input.Text = ""
        self._value = ""
        clearBtn.Visible = false
    end)
    
    input.Focused:Connect(function()
        AnimationSystem:Tween(self._stroke, {Color = theme.Accent, Transparency = 0}, 0.2)
    end)
    
    input.FocusLost:Connect(function()
        AnimationSystem:Tween(self._stroke, {Color = theme.Border.Default, Transparency = 0.6}, 0.2)
    end)
end

function SearchBox:GetValue()
    return self._value
end

function SearchBox:Clear()
    self._input.Text = ""
    self._value = ""
    self._clearBtn.Visible = false
end

function SearchBox:_applyThemeImpl(theme)
    self.Instance.BackgroundColor3 = theme.Component.Background
    if self._stroke then
        self._stroke.Color = theme.Border.Default
    end
    if self._icon then
        self._icon.ImageColor3 = theme.Text.Tertiary
    end
    if self._input then
        self._input.Font = theme.Font
        self._input.TextColor3 = theme.Text.Primary
        self._input.PlaceholderColor3 = theme.Text.Tertiary
    end
end

return SearchBox
