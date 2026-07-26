--[[
    VoidUI | LogViewer Component
    A log file viewer with syntax-highlighted log entries, filtering by
    severity, search, and auto-scroll. Useful for viewing log files.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local LogViewer = {}
LogViewer.__index = LogViewer
setmetatable(LogViewer, { __index = Component })

local LEVEL_COLORS = {
    TRACE = Color3.fromRGB(140, 140, 140),
    DEBUG = Color3.fromRGB(100, 160, 220),
    INFO = Color3.fromRGB(180, 220, 180),
    WARN = Color3.fromRGB(255, 193, 7),
    ERROR = Color3.fromRGB(255, 100, 100),
    FATAL = Color3.fromRGB(255, 50, 50),
}

function LogViewer.new(config, voidUI)
    local self = Component.new("LogViewer")
    setmetatable(self, { __index = LogViewer })

    config = config or {}
    self._size = config.Size or UDim2.new(1, 0, 1, 0)
    self._entries = config.Entries or {}
    self._autoScroll = config.AutoScroll or true
    self._filter = nil

    self:_createUI()
    return self
end

function LogViewer:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "LogViewer",
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
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

    -- Toolbar
    local toolbar = Create("Frame", {
        Name = "Toolbar",
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.Frame,
    })

    local toolbarLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = toolbar,
    })

    local toolbarPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = toolbar,
    })

    -- Title
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium,
        Text = "Log Viewer",
        TextColor3 = theme.Text.Secondary,
        TextSize = 13,
        Parent = toolbar,
    })

    -- Spacer
    local spacer = Create("Frame", {
        Name = "Spacer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 0, 0),
        Parent = toolbar,
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
        Parent = toolbar,
    })
    Anim.AddHover(clearBtn, { HoverColor = theme.Text.Primary })
    clearBtn.MouseButton1Click:Connect(function()
        self:Clear()
    end)

    -- Log display area
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

    -- Initial render
    self:_renderAll()
end

function LogViewer:_parseEntry(entry)
    -- Parse log entry to extract level
    if type(entry) == "string" then
        for level in pairs(LEVEL_COLORS) do
            if entry:upper():find(level) then
                return { text = entry, level = level }
            end
        end
        return { text = entry, level = "INFO" }
    end
    return entry
end

function LogViewer:_renderEntry(entry)
    local data = self:_parseEntry(entry)
    local color = LEVEL_COLORS[data.level] or LEVEL_COLORS.INFO

    -- Apply filter
    if self._filter and self._filter:upper() ~= data.level:upper() then
        return
    end

    local line = Create("TextLabel", {
        Name = "LogLine",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Code,
        Text = data.text,
        TextColor3 = color,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = self.Output,
    })

    if self._autoScroll then
        task.defer(function()
            self.Output.CanvasPosition = Vector2.new(0, self.Output.CanvasSize.Y.Offset)
        end)
    end
end

function LogViewer:_renderAll()
    for _, entry in ipairs(self._entries) do
        self:_renderEntry(entry)
    end
end

function LogViewer:AddEntry(entry)
    table.insert(self._entries, entry)
    self:_renderEntry(entry)
end

function LogViewer:AddEntries(entries)
    for _, entry in ipairs(entries) do
        self:AddEntry(entry)
    end
end

function LogViewer:SetEntries(entries)
    self._entries = entries
    self:Clear()
    self:_renderAll()
end

function LogViewer:SetFilter(level)
    self._filter = level
    self:Clear()
    self:_renderAll()
end

function LogViewer:Clear()
    for _, child in ipairs(self.Output:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
end

function LogViewer:SetAutoScroll(enabled)
    self._autoScroll = enabled
end

function LogViewer:Export()
    local result = {}
    for _, entry in ipairs(self._entries) do
        if type(entry) == "string" then
            table.insert(result, entry)
        else
            table.insert(result, entry.text or "")
        end
    end
    return table.concat(result, "\n")
end

function LogViewer:_applyThemeImpl(theme)
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.TitleLabel then self.TitleLabel.TextColor3 = theme.Text.Secondary end
end

return LogViewer
