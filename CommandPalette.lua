--[[
    VoidUI | CommandPalette Component
    A command palette (like VS Code's Ctrl+Shift+P) with searchable commands.
    Supports fuzzy search, keyboard navigation, and custom command registration.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local CommandPalette = {}
CommandPalette.__index = CommandPalette
setmetatable(CommandPalette, { __index = Component })

function CommandPalette.new(config, voidUI)
    local self = Component.new("CommandPalette")
    setmetatable(self, { __index = CommandPalette })

    config = config or {}
    self._commands = config.Commands or {}
    self._maxResults = config.MaxResults or 8
    self._shortcut = config.Shortcut or Enum.KeyCode.P

    self.OnCommand = self:AddSignal("OnCommand")

    self:_createUI()
    self:_setupKeyboardShortcut()
    return self
end

function CommandPalette:_createUI()
    local theme = Theme.Current()

    self.ScreenGui = Create("ScreenGui", {
        Name = "VoidUI_CommandPalette",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9800,
        Enabled = false,
        Parent = VoidCore.GetParent(),
    })

    -- Backdrop
    self.Backdrop = Create("TextButton", {
        Name = "Backdrop",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        AutoButtonColor = false,
        Text = "",
        Parent = self.ScreenGui,
    })
    self.Backdrop.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Main frame
    self.Frame = Create("Frame", {
        Name = "Palette",
        BackgroundColor3 = theme.Background.Main,
        BackgroundTransparency = 0.02,
        Size = UDim2.new(0, 500, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 80),
        Parent = self.Backdrop,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.Frame })
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

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = self.Frame,
    })

    -- Search input
    self.SearchBox = Create("TextBox", {
        Name = "Search",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        Font = theme.Font or Enum.Font.GothamMedium,
        PlaceholderText = "Type a command...",
        Text = "",
        TextColor3 = theme.Text.Primary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    local searchPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = self.SearchBox,
    })

    -- Results container
    self._resultsContainer = Create("ScrollingFrame", {
        Name = "Results",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Component.ScrollBar,
        Parent = self.Frame,
    })

    self._resultsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = self._resultsContainer,
    })

    -- Search handler
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:_search(self.SearchBox.Text)
    end)

    -- Enter key to run first command
    self.SearchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:_runFirstResult()
        end
    end)

    self:_renderResults(self._commands)
end

function CommandPalette:_setupKeyboardShortcut()
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        -- Ctrl/Cmd + P (or custom shortcut)
        if input.KeyCode == self._shortcut then
            local ctrlDown = UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)
            if ctrlDown then
                self:Toggle()
            end
        end
        if input.KeyCode == Enum.KeyCode.Escape and self.ScreenGui.Enabled then
            self:Close()
        end
    end)
end

function CommandPalette:_search(query)
    query = query:lower()
    if query == "" then
        self:_renderResults(self._commands)
        return
    end

    local results = {}
    for _, cmd in ipairs(self._commands) do
        local text = (cmd.Title or ""):lower() .. " " .. (cmd.Description or ""):lower()
        if text:find(query) then
            table.insert(results, cmd)
        end
    end

    self:_renderResults(results)
end

function CommandPalette:_renderResults(commands)
    -- Clear
    for _, child in ipairs(self._resultsContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local theme = Theme.Current()
    local count = 0

    for i, cmd in ipairs(commands) do
        if count >= self._maxResults then break end

        local btn = Create("TextButton", {
            Name = "Cmd_" .. (cmd.Title or "Command"),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = i,
            Parent = self._resultsContainer,
        })

        local layout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
            Parent = btn,
        })

        local padding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = btn,
        })

        -- Icon
        if cmd.Icon then
            local icon = Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image = cmd.Icon,
                ImageColor3 = theme.Text.Secondary,
                Parent = btn,
            })
        end

        -- Title
        local label = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 18),
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = cmd.Title or "Command",
            TextColor3 = theme.Text.Primary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn,
        })

        -- Shortcut
        if cmd.Shortcut then
            local shortcut = Create("TextLabel", {
                Name = "Shortcut",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 16),
                AutomaticSize = Enum.AutomaticSize.X,
                Font = theme.Font or Enum.Font.Gotham,
                Text = cmd.Shortcut,
                TextColor3 = theme.Text.Tertiary,
                TextSize = 11,
                Parent = btn,
            })
        end

        Anim.AddHover(btn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })
        btn.MouseButton1Click:Connect(function()
            self:_runCommand(cmd)
        end)

        count = count + 1
    end
end

function CommandPalette:_runFirstResult()
    local first = self._resultsContainer:FindFirstChildOfClass("TextButton")
    if first then
        local cmd = self._commands[first.LayoutOrder]
        if cmd then
            self:_runCommand(cmd)
        end
    end
end

function CommandPalette:_runCommand(cmd)
    if cmd.Callback then cmd.Callback() end
    self.OnCommand:Fire(cmd)
    self:Close()
end

function CommandPalette:Open()
    self.ScreenGui.Enabled = true
    self.SearchBox.Text = ""
    Anim.FadeIn(self.Frame, 0.2)
    self._renderResults(self._commands)
    -- Focus the search box
    self.SearchBox:CaptureFocus()
end

function CommandPalette:Close()
    Anim.FadeOut(self.Frame, 0.15)
    task.delay(0.15, function()
        self.ScreenGui.Enabled = false
    end)
end

function CommandPalette:Toggle()
    if self.ScreenGui.Enabled then
        self:Close()
    else
        self:Open()
    end
end

function CommandPalette:AddCommand(cmd)
    table.insert(self._commands, cmd)
end

function CommandPalette:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Background.Main
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    self.SearchBox.BackgroundColor3 = theme.Component.Background
    self.SearchBox.TextColor3 = theme.Text.Primary
    self._resultsContainer.ScrollBarImageColor3 = theme.Component.ScrollBar
    self:_renderResults(self._commands)
end

return CommandPalette
