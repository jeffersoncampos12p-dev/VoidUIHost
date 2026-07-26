--[[
    VoidUI | Console Component
    A developer console with message log levels (info, warn, error, debug),
    filtering, and clearing. Useful for debugging and runtime inspection.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Console = {}
Console.__index = Console
setmetatable(Console, { __index = Component })

local LEVEL_COLORS = {
    Info = Color3.fromRGB(100, 180, 255),
    Warn = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(255, 100, 100),
    Debug = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(76, 175, 80),
}

function Console.new(config, voidUI)
    local self = Component.new("Console")
    setmetatable(self, { __index = Console })

    config = config or {}
    self._size = config.Size or UDim2.new(1, 0, 1, 0)
    self._maxLines = config.MaxLines or 200
    self._lines = {}
    self._filter = config.Filter or nil -- level filter

    self:_createUI()
    return self
end

function Console:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Console",
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        Size = self._size,
        ClipsDescendants = true,
        Parent = nil,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Frame })
    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Parent = self.Frame,
    })

    -- Header with filter buttons
    local header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.Frame,
    })

    local headerLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = header,
    })

    local headerPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = header,
    })

    -- Title
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Code,
        Text = "Console",
        TextColor3 = theme.Text.Secondary,
        TextSize = 13,
        Parent = header,
    })

    -- Spacer
    local spacer = Create("Frame", {
        Name = "Spacer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 0, 0),
        Parent = header,
    })

    -- Clear button
    local clearBtn = Create("TextButton", {
        Name = "Clear",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 24),
        Font = Enum.Font.GothamMedium,
        Text = "Clear",
        TextColor3 = theme.Text.Secondary,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = header,
    })
    Anim.AddHover(clearBtn, { HoverColor = theme.Text.Primary })
    clearBtn.MouseButton1Click:Connect(function()
        self:Clear()
    end)

    -- Output area
    self.Output = Create("ScrollingFrame", {
        Name = "Output",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65),
        Parent = self.Frame,
    })

    local outputPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = self.Output,
    })

    self._outputLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 1),
        Parent = self.Output,
    })
end

function Console:Log(text, level)
    level = level or "Info"
    local color = LEVEL_COLORS[level] or LEVEL_COLORS.Info

    -- Store line
    local lineData = { text = text, level = level, timestamp = os.date("%H:%M:%S") }
    table.insert(self._lines, lineData)

    -- Trim if exceeding max
    if #self._lines > self._maxLines then
        table.remove(self._lines, 1)
        local first = self.Output:GetChildren()[1]
        if first then first:Destroy() end
    end

    -- Apply filter
    if self._filter and self._filter ~= level then
        return
    end

    self:_renderLine(lineData, color)
end

function Console:_renderLine(lineData, color)
    local time = lineData.timestamp or ""
    local level = lineData.level or "Info"
    local text = lineData.text or ""

    local line = Create("TextLabel", {
        Name = "Line",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Code,
        Text = string.format("[%s] [%s] %s", time, level:upper(), text),
        TextColor3 = color,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = self.Output,
    })

    -- Scroll to bottom
    task.defer(function()
        self.Output.CanvasPosition = Vector2.new(0, self.Output.CanvasSize.Y.Offset)
    end)
end

function Console:Info(text)
    self:Log(text, "Info")
end

function Console:Warn(text)
    self:Log(text, "Warn")
end

function Console:Error(text)
    self:Log(text, "Error")
end

function Console:Debug(text)
    self:Log(text, "Debug")
end

function Console:Success(text)
    self:Log(text, "Success")
end

function Console:SetFilter(level)
    self._filter = level
    -- Re-render all lines
    self:Clear()
    for _, lineData in ipairs(self._lines) do
        if not level or level == lineData.level then
            local color = LEVEL_COLORS[lineData.level] or LEVEL_COLORS.Info
            self:_renderLine(lineData, color)
        end
    end
end

function Console:Clear()
    for _, child in ipairs(self.Output:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    self._lines = {}
end

function Console:GetLines()
    return self._lines
end

function Console:Export()
    local result = {}
    for _, line in ipairs(self._lines) do
        table.insert(result, string.format("[%s] [%s] %s", line.timestamp, line.level, line.text))
    end
    return table.concat(result, "\n")
end

function Console:_applyThemeImpl(theme)
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.TitleLabel then self.TitleLabel.TextColor3 = theme.Text.Secondary end
end

return Console
