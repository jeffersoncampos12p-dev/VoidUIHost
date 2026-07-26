--[[
    VoidUI | VideoPreview Component
    A thumbnail-style preview for video content with play icon overlay,
    duration badge, and hover effects. Click triggers a play action callback.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local VideoPreview = {}
VideoPreview.__index = VideoPreview
setmetatable(VideoPreview, { __index = Component })

function VideoPreview.new(config, voidUI)
    local self = Component.new("VideoPreview")
    setmetatable(self, { __index = VideoPreview })

    config = config or {}
    self._thumbnail = config.Thumbnail or ""
    self._title = config.Title or nil
    self._duration = config.Duration or nil
    self._size = config.Size or UDim2.new(0, 280, 0, 158)

    self.OnPlay = self:AddSignal("OnPlay")

    self:_createUI()
    return self
end

function VideoPreview:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "VideoPreview",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Size = self._size,
        ClipsDescendants = true,
        Parent = nil,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Frame })
    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    -- Thumbnail
    self.Thumbnail = Create("ImageLabel", {
        Name = "Thumbnail",
        BackgroundColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Image = self._thumbnail,
        ScaleType = Enum.ScaleType.Crop,
        Parent = self.Frame,
    })

    -- Dark overlay for better text contrast
    self.Overlay = Create("Frame", {
        Name = "Overlay",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.Frame,
    })

    -- Play button (center)
    local playSize = 48
    self.PlayButton = Create("Frame", {
        Name = "PlayButton",
        BackgroundColor3 = theme.Accent.Primary,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, playSize, 0, playSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = self.Frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.PlayButton })

    -- Glow around play button
    local glow = Create("UIStroke", {
        Color = theme.Accent.Primary,
        Thickness = 3,
        Transparency = 0.6,
        Parent = self.PlayButton,
    })

    -- Play triangle (using TextLabel with Unicode)
    self.PlayIcon = Create("TextLabel", {
        Name = "PlayIcon",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = "▶",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = self.PlayButton,
    })

    -- Duration badge (bottom-right)
    if self._duration then
        local durationFrame = Create("Frame", {
            Name = "Duration",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.3,
            Size = UDim2.new(0, 50, 0, 20),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -8, 1, -8),
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = durationFrame })

        self.Duration = Create("TextLabel", {
            Name = "DurationText",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = self._duration,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = durationFrame,
        })
    end

    -- Title (bottom)
    if self._title then
        local titleFrame = Create("Frame", {
            Name = "TitleFrame",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 1, -28),
            Parent = self.Frame,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 0), Parent = titleFrame })

        self.Title = Create("TextLabel", {
            Name = "TitleText",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = self._title,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = titleFrame,
        })
    end

    -- Hover and click
    Anim.AddHover(self.Frame, { HoverColor = Color3.new(0, 0, 0), HoverTransparency = 0.4 })

    local clickButton = Create("TextButton", {
        Name = "Click",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = self.Frame,
    })

    clickButton.MouseButton1Click:Connect(function()
        -- Scale play button on click
        Anim.Tween(self.PlayButton, { Size = UDim2.new(0, playSize * 0.8, 0, playSize * 0.8) }, 0.1)
        task.delay(0.1, function()
            Anim.Tween(self.PlayButton, { Size = UDim2.new(0, playSize, 0, playSize) }, 0.2)
        end)
        self.OnPlay:Fire()
    end)

    -- Pulse play button to draw attention
    self._pulseConn = game:GetService("RunService").Heartbeat:Connect(function()
        if self.PlayButton then
            local t = tick()
            local alpha = (math.sin(t * 2) + 1) / 2
            self.PlayButton.BackgroundTransparency = 0.1 + alpha * 0.1
        end
    end)
end

function VideoPreview:SetThumbnail(thumbnail)
    self._thumbnail = thumbnail
    if self.Thumbnail then self.Thumbnail.Image = thumbnail end
end

function VideoPreview:SetTitle(title)
    self._title = title
    if self.Title then self.Title.Text = title end
end

function VideoPreview:SetDuration(duration)
    self._duration = duration
    if self.Duration then self.Duration.Text = duration end
end

function VideoPreview:_applyThemeImpl(theme)
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    if self.PlayButton then self.PlayButton.BackgroundColor3 = theme.Accent.Primary end
    if self.Title then self.Title.Font = theme.Font or Enum.Font.GothamMedium end
end

function VideoPreview:Destroy()
    if self._pulseConn then
        self._pulseConn:Disconnect()
        self._pulseConn = nil
    end
    Component.Destroy(self)
end

return VideoPreview
