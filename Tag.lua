--[[
    VoidUI | Tag Component
    A compact label used for categorizing or marking items.
    Supports closable tags with an optional close button.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create
local Utils = VoidCore.Utils

local Tag = {}
Tag.__index = Tag
setmetatable(Tag, { __index = Component })

function Tag.new(config, voidUI)
    local self = Component.new("Tag")
    setmetatable(self, { __index = Tag })

    config = config or {}
    self._text = config.Text or "Tag"
    self._closable = config.Closable or false
    self._variant = config.Variant or "Default" -- Default, Primary, Success, Warning, Error
    self._icon = config.Icon or nil

    self:_createUI()

    return self
end

function Tag:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Tag",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = nil,
    })

    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Frame,
    })

    local stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.Frame,
    })

    if self._icon then
        self.IconLabel = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            Image = self._icon,
            ImageColor3 = theme.Text.Secondary,
            Parent = self.Frame,
        })
    end

    self.Label = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = self._text,
        TextColor3 = theme.Text.Primary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = self.Frame,
    })

    if self._closable then
        local closeBtn = Create("TextButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = "✕",
            TextColor3 = theme.Text.Secondary,
            TextSize = 10,
            Parent = self.Frame,
        })
        self.CloseButton = closeBtn
        Anim.AddHover(closeBtn, { HoverColor = theme.Text.Primary })

        closeBtn.MouseButton1Click:Connect(function()
            self.OnClose:Fire()
            self:Destroy()
        end)

        self.OnClose = self:AddSignal("OnClose")
    end

    self:_applyVariant()
end

function Tag:_applyVariant()
    local theme = Theme.Current()
    local colors = {
        Default = { Bg = theme.Component.Background, Text = theme.Text.Primary, Border = theme.Component.Border },
        Primary = { Bg = theme.Accent.Primary, Text = Color3.new(1, 1, 1), Border = theme.Accent.Primary },
        Success = { Bg = theme.Status.Success, Text = Color3.new(1, 1, 1), Border = theme.Status.Success },
        Warning = { Bg = theme.Status.Warning, Text = Color3.new(0, 0, 0), Border = theme.Status.Warning },
        Error = { Bg = theme.Status.Error, Text = Color3.new(1, 1, 1), Border = theme.Status.Error },
    }
    local c = colors[self._variant] or colors.Default
    self.Frame.BackgroundColor3 = c.Bg
    if self.Label then self.Label.TextColor3 = c.Text end
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color = c.Border end
    if self.IconLabel then self.IconLabel.ImageColor3 = c.Text end
end

function Tag:SetText(text)
    self._text = text
    if self.Label then self.Label.Text = text end
end

function Tag:SetVariant(variant)
    self._variant = variant
    self:_applyVariant()
end

function Tag:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Component.Background
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color = theme.Component.Border end
    self:_applyVariant()
end

return Tag
