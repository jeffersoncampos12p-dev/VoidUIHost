--[[
    VoidUI - Plugin Example
    =======================
    Demonstrates the plugin/extension system by registering
    a custom component and a custom theme.
]]

local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- ============================================================
-- Register a Plugin
-- ============================================================
local Plugin = VoidUI:GetPlugins():Register("MyCustomPlugin")

-- Hook into the Init event
Plugin:On("Init", function()
    Plugin:Log("MyCustomPlugin initialized successfully!")
end)

-- Hook into AfterCreate to modify components after creation
Plugin:On("AfterCreate", function(component, componentType)
    if componentType == "Button" then
        Plugin:Log("A button was created: " .. (component.Config.Text or "unnamed"))
    end
end)

-- ============================================================
-- Register a Custom Component: Rating Stars
-- ============================================================
Plugin:RegisterComponent("RatingStars", function(config)
    local Utils = Plugin.Utils
    local Create = Plugin.Create
    local Tween = Plugin.Tween
    local Theme = Plugin.GetTheme()

    local Container = Create("Frame", {
        Name = "RatingStars",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    })

    local Label = Create("TextLabel", {
        Parent = Container,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = config.Text or "Rating",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local StarsContainer = Create("Frame", {
        Parent = Container,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
    })

    local starLayout = Create("UIListLayout", {
        Parent = StarsContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 4),
    })

    local currentRating = config.Default or 0
    local stars = {}

    local function updateStars()
        for i = 1, 5 do
            local star = stars[i]
            if i <= currentRating then
                Tween(star, { TextColor3 = Theme.Accent }, 0.2)
            else
                Tween(star, { TextColor3 = Theme.SubText }, 0.2)
            end
        end
    end

    for i = 1, 5 do
        local star = Create("TextButton", {
            Parent = StarsContainer,
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Text = "★",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Theme.SubText,
            LayoutOrder = i,
        })

        star.MouseButton1Click:Connect(function()
            currentRating = i
            updateStars()
            if config.OnChanged then
                config.OnChanged(i)
            end
        end)

        stars[i] = star
    end

    updateStars()

    return {
        Instance = Container,
        Config = config,
        GetValue = function()
            return currentRating
        end,
        SetValue = function(_, value)
            currentRating = math.clamp(value, 0, 5)
            updateStars()
        end,
        OnChanged = Plugin.Utils.Signal.new(),
    }
end)

-- ============================================================
-- Register a Custom Theme: Aurora
-- ============================================================
Plugin:RegisterTheme("Aurora", {
    Background = Color3.fromRGB(12, 16, 28),
    Surface = Color3.fromRGB(18, 24, 40),
    SurfaceVariant = Color3.fromRGB(24, 32, 52),
    Primary = Color3.fromRGB(120, 200, 255),
    Secondary = Color3.fromRGB(140, 220, 255),
    Text = Color3.fromRGB(220, 230, 255),
    SubText = Color3.fromRGB(130, 150, 180),
    Border = Color3.fromRGB(30, 40, 60),
    Accent = Color3.fromRGB(100, 220, 200),
    Error = Color3.fromRGB(255, 80, 120),
    Warning = Color3.fromRGB(255, 190, 80),
    Success = Color3.fromRGB(60, 220, 130),
})

-- Apply the custom theme
VoidUI:SetTheme("Aurora")

-- ============================================================
-- Create a Window to Showcase the Plugin
-- ============================================================
local Window = VoidUI:CreateWindow({
    Title = "Plugin Demo",
    SubTitle = "Custom components and themes",
    Size = Vector2.new(480, 400),
})

local Tab = Window:AddTab({ Title = "Plugin Showcase" })
local Section = Tab:AddSection({
    Title = "Custom Components",
    Description = "Components registered by MyCustomPlugin",
})

-- Use the custom RatingStars component!
Section:AddRatingStars({
    Text = "Rate this library",
    Default = 4,
    OnChanged = function(rating)
        print("User rated:", rating, "stars")
        VoidUI:NotifyInfo({
            Title = "Rating Received",
            Description = "You rated VoidUI " .. rating .. " out of 5 stars!",
        })
    end,
})

Section:AddRatingStars({
    Text = "Rate the design",
    Default = 5,
    OnChanged = function(rating)
        print("Design rated:", rating)
    end,
})

Section:AddRatingStars({
    Text = "Rate the performance",
    Default = 0,
    OnChanged = function(rating)
        print("Performance rated:", rating)
    end,
})

-- Show a section to switch themes
local ThemeSection = Tab:AddSection({
    Title = "Custom Theme",
})

ThemeSection:AddDropdown({
    Text = "Theme",
    Options = { "Aurora", "Dark", "OceanBreeze", "Midnight" },
    Default = "Aurora",
    OnChanged = function(value)
        VoidUI:SetTheme(value)
    end,
})

-- List registered plugins
print("[VoidUI] Registered plugins:")
for _, name in ipairs(VoidUI:GetPlugins():List()) do
    print("  -", name)
end

print("[VoidUI] Plugin example loaded!")
