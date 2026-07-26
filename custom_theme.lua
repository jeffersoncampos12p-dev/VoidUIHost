--[[
    VoidUI - Custom Theme Example
    ==============================
    Demonstrates creating and applying custom themes.
]]

local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- ============================================================
-- Create Custom Themes
-- ============================================================

-- Ocean Breeze — a cool blue theme
VoidUI:CreateTheme("OceanBreeze", {
    Background = Color3.fromRGB(18, 28, 48),
    Surface = Color3.fromRGB(24, 38, 62),
    SurfaceVariant = Color3.fromRGB(30, 48, 76),
    Primary = Color3.fromRGB(64, 156, 255),
    Secondary = Color3.fromRGB(100, 180, 255),
    Text = Color3.fromRGB(230, 240, 255),
    SubText = Color3.fromRGB(150, 170, 200),
    Border = Color3.fromRGB(40, 60, 90),
    Accent = Color3.fromRGB(64, 200, 220),
    Error = Color3.fromRGB(255, 90, 110),
    Warning = Color3.fromRGB(255, 180, 60),
    Success = Color3.fromRGB(60, 220, 130),
})

-- Rose Gold — a warm pink theme
VoidUI:CreateTheme("RoseGold", {
    Background = Color3.fromRGB(28, 20, 24),
    Surface = Color3.fromRGB(38, 28, 32),
    SurfaceVariant = Color3.fromRGB(48, 36, 42),
    Primary = Color3.fromRGB(255, 120, 140),
    Secondary = Color3.fromRGB(255, 160, 180),
    Text = Color3.fromRGB(255, 240, 245),
    SubText = Color3.fromRGB(200, 170, 180),
    Border = Color3.fromRGB(60, 45, 50),
    Accent = Color3.fromRGB(255, 180, 120),
    Error = Color3.fromRGB(255, 80, 100),
    Warning = Color3.fromRGB(255, 200, 80),
    Success = Color3.fromRGB(120, 220, 140),
})

-- Matrix — a green-on-black hacker theme
VoidUI:CreateTheme("Matrix", {
    Background = Color3.fromRGB(8, 12, 8),
    Surface = Color3.fromRGB(14, 20, 14),
    SurfaceVariant = Color3.fromRGB(20, 28, 20),
    Primary = Color3.fromRGB(0, 255, 100),
    Secondary = Color3.fromRGB(0, 200, 80),
    Text = Color3.fromRGB(180, 255, 200),
    SubText = Color3.fromRGB(100, 160, 120),
    Border = Color3.fromRGB(20, 40, 25),
    Accent = Color3.fromRGB(0, 255, 100),
    Error = Color3.fromRGB(255, 60, 60),
    Warning = Color3.fromRGB(255, 220, 0),
    Success = Color3.fromRGB(0, 255, 100),
})

-- Apply the Ocean Breeze theme
VoidUI:SetTheme("OceanBreeze")

-- ============================================================
-- Create a window to showcase the themes
-- ============================================================
local Window = VoidUI:CreateWindow({
    Title = "Custom Themes",
    SubTitle = "Switch between custom themes below",
    Size = Vector2.new(480, 420),
})

local Tab = Window:AddTab({ Title = "Theme Gallery" })
local Section = Tab:AddSection({
    Title = "Available Themes",
    Description = "Select a theme to apply it instantly",
})

-- Built-in themes
Section:AddDropdown({
    Text = "Built-in Themes",
    Options = { "Dark", "Light", "Midnight", "Sunset", "Forest", "Cyber" },
    Default = "Dark",
    OnChanged = function(value)
        VoidUI:SetTheme(value)
    end,
})

-- Custom themes
Section:AddDropdown({
    Text = "Custom Themes",
    Options = { "OceanBreeze", "RoseGold", "Matrix" },
    Default = "OceanBreeze",
    OnChanged = function(value)
        VoidUI:SetTheme(value)
    end,
})

-- Quick switch buttons
Section:AddDivider({ Text = "Quick Switch" })

Section:AddButton({
    Text = "Ocean Breeze",
    Style = "Primary",
    OnClick = function()
        VoidUI:SetTheme("OceanBreeze")
    end,
})

Section:AddButton({
    Text = "Rose Gold",
    Style = "Secondary",
    OnClick = function()
        VoidUI:SetTheme("RoseGold")
    end,
})

Section:AddButton({
    Text = "Matrix",
    Style = "Success",
    OnClick = function()
        VoidUI:SetTheme("Matrix")
    end,
})

-- Show some components to see the theme in action
local DemoSection = Tab:AddSection({
    Title = "Theme Preview",
})

DemoSection:AddToggle({
    Text = "Sample Toggle",
    Default = true,
})

DemoSection:AddSlider({
    Text = "Sample Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
})

DemoSection:AddColorPicker({
    Text = "Sample Color Picker",
    Default = Color3.fromRGB(64, 200, 220),
})

-- List all available themes
print("[VoidUI] Available themes:")
for _, name in ipairs(VoidUI:ListThemes()) do
    print("  -", name)
end

print("[VoidUI] Custom theme example loaded!")
