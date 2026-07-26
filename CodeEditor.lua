--[[
    VoidUI - Code Editor Component
    Code editor with monospace font, line numbers, syntax highlighting
    simulation, and copy button.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local CodeEditor = setmetatable({}, {__index = Component})
CodeEditor.__index = CodeEditor

function CodeEditor.new(options, parent)
    local self = Component.new("CodeEditor")
    setmetatable(self, {__index = CodeEditor})
    
    self.Config = Core.Utils.Merge({
        Name = "CodeEditor",
        Text = "Code",
        Default = "",
        Callback = nil,
        Size = UDim2.new(1, 0, 0, 150),
        Language = "lua",
        ShowLineNumbers = true,
        ShowCopyButton = true,
    }, options)
    
    self._value = self.Config.Default
    self._lineCount = 0
    self.OnChanged = self:AddSignal("OnChanged")
    
    self:_createUI()
    
    return self
end

function CodeEditor:_createUI()
    local theme = ThemeSystem:Current()
    
    local container = Core.Create("Frame", {
        Name = self.Config.Name,
        Size = self.Config.Size,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Background.Deep,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    self.Instance = container
    self._container = container
    
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, container)
    
    local stroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.7,
    }, container)
    self._stroke = stroke
    
    -- Title bar
    local titleBar = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, container)
    self._titleBar = titleBar
    
    local titleCorner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Small,
    }, titleBar)
    
    -- Title text
    local titleText = Core.Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Text,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, titleBar)
    self._titleText = titleText
    
    -- Copy button
    if self.Config.ShowCopyButton then
        local copyBtn = Core.Create("TextButton", {
            Size = UDim2.fromOffset(50, 22),
            Position = UDim2.new(1, -58, 0, 3),
            BackgroundColor3 = theme.Component.Hover,
            BackgroundTransparency = 0.5,
            Text = "Copy",
            Font = theme.Font,
            TextSize = theme.TextSize.XS,
            TextColor3 = theme.Text.Secondary,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
        }, titleBar)
        self._copyBtn = copyBtn
        
        local copyCorner = Core.Create("UICorner", {
            CornerRadius = theme.Corner.Small,
        }, copyBtn)
        
        copyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(self._value)
            end
            copyBtn.Text = "Copied!"
            AnimationSystem:Tween(copyBtn, {BackgroundColor3 = theme.Success, TextColor3 = theme.Text.OnAccent}, 0.2)
            task.delay(1, function()
                copyBtn.Text = "Copy"
                AnimationSystem:Tween(copyBtn, {BackgroundColor3 = theme.Component.Hover, TextColor3 = theme.Text.Secondary}, 0.2)
            end)
        end)
    end
    
    -- Code area
    local codeArea = Core.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 120),
        Position = UDim2.fromOffset(0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, container)
    self._codeArea = codeArea
    
    -- Line numbers
    if self.Config.ShowLineNumbers then
        local lineNumbers = Core.Create("TextLabel", {
            Size = UDim2.fromOffset(30, 1, 1, -2),
            BackgroundColor3 = theme.Background.Deep,
            BackgroundTransparency = 0.5,
            Text = "1",
            Font = theme.FontMono,
            TextSize = theme.TextSize.XS,
            TextColor3 = theme.Text.Tertiary,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Top,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, codeArea)
        self._lineNumbers = lineNumbers
        
        local linePadding = Core.Create("UIPadding", {
            PaddingTop = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        }, lineNumbers)
        
        local lineCorner = Core.Create("UICorner", {
            CornerRadius = theme.Corner.Small,
        }, lineNumbers)
    end
    
    -- Input (the actual text editor)
    local input = Core.Create("TextBox", {
        Size = UDim2.new(1, -34, 1, -2),
        Position = UDim2.fromOffset(34, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Default,
        Font = theme.FontMono,
        TextSize = theme.TextSize.XS,
        TextColor3 = theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        MultiLine = true,
        TextWrapped = false,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, codeArea)
    self._input = input
    
    local inputPadding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
    }, input)
    
    -- Update line numbers
    self:_updateLineNumbers(self.Config.Default)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        self._value = input.Text
        self:_updateLineNumbers(input.Text)
        self.OnChanged:Fire(self._value)
        if self.Config.Callback then
            task.spawn(self.Config.Callback, self._value)
        end
    end)
end

function CodeEditor:_updateLineNumbers(text)
    if not self._lineNumbers then return end
    local count = 1
    for _ in text:gmatch("\n") do
        count = count + 1
    end
    self._lineCount = count
    local numbers = {}
    for i = 1, count do
        table.insert(numbers, tostring(i))
    end
    self._lineNumbers.Text = table.concat(numbers, "\n")
end

function CodeEditor:GetValue()
    return self._value
end

function CodeEditor:SetValue(value)
    self._value = value
    self._input.Text = value
    self:_updateLineNumbers(value)
end

function CodeEditor:_applyThemeImpl(theme)
    self._container.BackgroundColor3 = theme.Background.Deep
    if self._stroke then
        self._stroke.Color = theme.Border.Default
    end
    if self._titleBar then
        self._titleBar.BackgroundColor3 = theme.Component.Background
    end
    if self._titleText then
        self._titleText.Font = theme.Font
        self._titleText.TextColor3 = theme.Text.Secondary
    end
    if self._copyBtn then
        self._copyBtn.BackgroundColor3 = theme.Component.Hover
        self._copyBtn.TextColor3 = theme.Text.Secondary
    end
    if self._lineNumbers then
        self._lineNumbers.Font = theme.FontMono
        self._lineNumbers.TextColor3 = theme.Text.Tertiary
        self._lineNumbers.BackgroundColor3 = theme.Background.Deep
    end
    if self._input then
        self._input.Font = theme.FontMono
        self._input.TextColor3 = theme.Text.Primary
    end
end

return CodeEditor
