--[[
    VoidUI | Terminal Component
    A terminal-style interface with command input, output display, and
    history navigation. Supports custom command handlers and output formatting.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Terminal = {}
Terminal.__index = Terminal
setmetatable(Terminal, { __index = Component })

function Terminal.new(config, voidUI)
    local self = Component.new("Terminal")
    setmetatable(self, { __index = Terminal })

    config = config or {}
    self._size = config.Size or UDim2.new(1, 0, 1, 0)
    self._prompt = config.Prompt or "voidui> "
    self._handlers = config.Handlers or {}
    self._history = {}
    self._historyIndex = 0

    self.OnCommand = self:AddSignal("OnCommand")
    self.OnOutput = self:AddSignal("OnOutput")

    self:_createUI()
    return self
end

function Terminal:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Terminal",
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

    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        Size = UDim2.new(1, 0, 0, 32),
        Parent = self.Frame,
    })

    local titleLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = titleBar,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = titleBar,
    })

    -- Terminal dots (decorative)
    for i, color in ipairs({ Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63) }) do
        local dot = Create("Frame", {
            Name = "Dot" .. i,
            BackgroundColor3 = color,
            Size = UDim2.new(0, 10, 0, 10),
            Parent = titleBar,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
    end

    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Code,
        Text = "Terminal — voidui",
        TextColor3 = theme.Text.Secondary,
        TextSize = 12,
        Parent = titleBar,
    })

    -- Output area (scrollable)
    self.Output = Create("ScrollingFrame", {
        Name = "Output",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -64),
        Position = UDim2.new(0, 0, 0, 32),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65),
        Parent = self.Frame,
    })

    local outputPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = self.Output,
    })

    self._outputLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = self.Output,
    })

    -- Input row
    local inputRow = Create("Frame", {
        Name = "InputRow",
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 1, -32),
        Parent = self.Frame,
    })

    local inputLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = inputRow,
    })

    local inputPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = inputRow,
    })

    self.PromptLabel = Create("TextLabel", {
        Name = "Prompt",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Code,
        Text = self._prompt,
        TextColor3 = Color3.fromRGB(76, 175, 80),
        TextSize = 13,
        Parent = inputRow,
    })

    self.Input = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 28),
        Font = Enum.Font.Code,
        Text = "",
        TextColor3 = Color3.fromRGB(220, 220, 225),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputRow,
    })

    -- Handle input
    self.Input.FocusLost:Connect(function(enterPressed)
        if enterPressed and self.Input.Text ~= "" then
            self:Execute(self.Input.Text)
            self.Input.Text = ""
        end
        self.Input:CaptureFocus()
    end)

    -- History navigation
    local UIS = game:GetService("UserInputService")
    self.Input.Focused:Connect(function()
        self._inputConn = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Up and #self._history > 0 then
                self._historyIndex = math.max(1, self._historyIndex - 1)
                self.Input.Text = self._history[self._historyIndex] or ""
            elseif input.KeyCode == Enum.KeyCode.Down then
                self._historyIndex = math.min(#self._history + 1, self._historyIndex + 1)
                self.Input.Text = self._history[self._historyIndex] or ""
            end
        end)
    end)

    self.Input.FocusLost:Connect(function()
        if self._inputConn then
            self._inputConn:Disconnect()
            self._inputConn = nil
        end
    end)

    -- Welcome message
    self:Print("VoidUI Terminal v1.0.0 — Type 'help' for available commands.", Color3.fromRGB(120, 120, 130))
    self:Print("", Color3.fromRGB(120, 120, 130))
end

function Terminal:Print(text, color)
    local line = Create("TextLabel", {
        Name = "Line",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Code,
        Text = text,
        TextColor3 = color or Color3.fromRGB(220, 220, 225),
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = self.Output,
    })

    -- Scroll to bottom
    task.defer(function()
        self.Output.CanvasPosition = Vector2.new(0, self.Output.CanvasSize.Y.Offset)
    end)

    self.OnOutput:Fire(text)
end

function Terminal:Execute(command)
    -- Add to history
    table.insert(self._history, command)
    self._historyIndex = #self._history + 1

    -- Print the command with prompt
    self:Print(self._prompt .. command, Color3.fromRGB(200, 200, 210))

    -- Parse and execute
    local parts = {}
    for part in string.gmatch(command, "%S+") do
        table.insert(parts, part)
    end

    local cmdName = parts[1]
    if not cmdName then return end

    local handler = self._handlers[cmdName]
    if handler then
        local result = handler(table.remove(parts, 1), parts)
        if result then
            self:Print(result, Color3.fromRGB(180, 220, 180))
        end
    else
        self:Print("Command not found: " .. cmdName .. " — Type 'help' for available commands.", Color3.fromRGB(255, 100, 100))
    end

    self.OnCommand:Fire(command)
end

function Terminal:RegisterHandler(name, handler)
    self._handlers[name] = handler
end

function Terminal:Clear()
    for _, child in ipairs(self.Output:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
end

function Terminal:Focus()
    self.Input:CaptureFocus()
end

function Terminal:_applyThemeImpl(theme)
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.TitleLabel then self.TitleLabel.TextColor3 = theme.Text.Secondary end
end

return Terminal
