--[[
    VoidUI - Keybind Component
    Keybind selector with live key capture and event triggering.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)
local UserInputService = game:GetService("UserInputService")

local Keybind = setmetatable({}, {__index = Component})
Keybind.__index = Keybind

function Keybind.new(options, parent)
    local self = Component.new("Keybind")
    setmetatable(self, {__index = Keybind})
    
    self.Config = Core.Utils.Merge({
        Name = "Keybind",
        Text = "Keybind",
        Default = nil,
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 32),
        Action = "Down", -- "Down", "Up", "Hold"
    }, options)
    
    self._value = self.Config.Default
    self._capturing = false
    
    self.OnTriggered = self:AddSignal("OnTriggered")
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    
    -- Bind the key
    if self._value then
        self:_bindKey()
    end
    
    return self
end

function Keybind:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        BackgroundTransparency = 1,
        ZIndex = 1,
    })
    self.Instance = container
    
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    
    -- Label
    local label = Core.Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        ZIndex = 2,
    }, container)
    self._label = label
    
    -- Key display button
    local keyBtn = Core.Create("TextButton", {
        Size = UDim2.fromOffset(92, 24),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Text = self:_formatKey(self._value) or "Click to set",
        Font = theme.FontMono,
        TextSize = theme.TextSize.Small,
        TextColor3 = self._value and theme.Text.Primary or theme.Text.Tertiary,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 2,
    }, container)
    self._keyBtn = keyBtn
    
    local keyBtnCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, keyBtn)
    self._keyBtnCorner = keyBtnCorner
    
    local keyBtnStroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.6,
    }, keyBtn)
    self._keyBtnStroke = keyBtnStroke
    
    -- Click handler
    keyBtn.MouseButton1Click:Connect(function()
        self:StartCapture()
    end)
    
    AnimationSystem:AddHover(keyBtn, {BackgroundColor3 = theme.Component.Hover, BackgroundTransparency = 0.1}, 0.15)
end

function Keybind:_formatKey(keyCode)
    if not keyCode then return nil end
    local name = tostring(keyCode):gsub("Enum.KeyCode.", "")
    -- Format common key names
    if name == "LeftControl" then return "Ctrl" end
    if name == "RightControl" then return "Ctrl" end
    if name == "LeftShift" then return "Shift" end
    if name == "RightShift" then return "Shift" end
    if name == "LeftAlt" then return "Alt" end
    if name == "RightAlt" then return "Alt" end
    return name
end

function Keybind:StartCapture()
    if self._capturing then return end
    self._capturing = true
    
    local theme = ThemeSystem:Current()
    self._keyBtn.Text = "Press a key..."
    self._keyBtn.TextColor3 = theme.Accent
    self._keyBtnStroke.Color = theme.Accent
    
    local conn
    
    conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Handle mouse click to cancel
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Don't capture the same click that triggered this
            if self._capturing then
                self._capturing = false
                self._keyBtn.Text = self:_formatKey(self._value) or "Click to set"
                self._keyBtn.TextColor3 = self._value and theme.Text.Primary or theme.Text.Tertiary
                self._keyBtnStroke.Color = theme.Border.Default
                conn:Disconnect()
            end
            return
        end
        
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            self._value = input.KeyCode
            self._capturing = false
            self._keyBtn.Text = self:_formatKey(self._value)
            self._keyBtn.TextColor3 = theme.Text.Primary
            self._keyBtnStroke.Color = theme.Border.Default
            
            self:_bindKey()
            self.OnChanged:Fire(self._value)
            if self.Config.Callback then
                task.spawn(self.Config.Callback, self._value)
            end
            conn:Disconnect()
        end
    end)
end

function Keybind:_bindKey()
    if not self._value then return end
    -- Disconnect old binding
    if self._keybindConn then
        self._keybindConn:Disconnect()
    end
    
    self._keybindConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self._value then
            self.OnTriggered:Fire(self._value)
            if self.Config.Callback then
                task.spawn(self.Config.Callback, self._value)
            end
        end
    end)
end

function Keybind:GetValue()
    return self._value
end

function Keybind:SetValue(keyCode)
    self._value = keyCode
    self._keyBtn.Text = self:_formatKey(keyCode) or "Click to set"
    if keyCode then
        self:_bindKey()
    end
end

function Keybind:_applyThemeImpl(theme)
    if self._label then
        self._label.Font = theme.Font
        self._label.TextColor3 = theme.Text.Primary
    end
    if self._keyBtn then
        self._keyBtn.BackgroundColor3 = theme.Component.Background
        self._keyBtn.Font = theme.FontMono
        if not self._capturing then
            self._keyBtn.TextColor3 = self._value and theme.Text.Primary or theme.Text.Tertiary
        end
    end
    if self._keyBtnStroke then
        self._keyBtnStroke.Color = theme.Border.Default
    end
end

return Keybind
