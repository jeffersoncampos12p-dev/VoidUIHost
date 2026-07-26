--[[
    VoidUI - Theme System
    Modern theme system with dark/light themes, custom themes,
    import/export capabilities, and live theme switching.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local HttpService = game:GetService("HttpService")
local Core = require(script.Parent.core.VoidCore)

local ThemeSystem = {
    _themes = {},
    _current = nil,
    _default = "Dark",
    _onChange = Core.Signal.new(),
    _registry = {},
}

-- ============================================================
-- Predefined Themes
-- ============================================================

-- Dark Theme (default) - inspired by 2026 modern aesthetics
local DarkTheme = {
    Name = "Dark",
    Description = "VoidUI default dark theme with elegant gradients and modern aesthetics",
    
    -- Background layers (from deepest to lightest)
    Background = {
        Deep = Color3.fromRGB(12, 12, 16),
        Base = Color3.fromRGB(18, 18, 24),
        Surface = Color3.fromRGB(26, 26, 35),
        Elevated = Color3.fromRGB(33, 33, 44),
        Overlay = Color3.fromRGB(22, 22, 30),
    },
    
    -- Component backgrounds
    Component = {
        Background = Color3.fromRGB(33, 33, 44),
        Hover = Color3.fromRGB(42, 42, 56),
        Active = Color3.fromRGB(50, 50, 68),
        Disabled = Color3.fromRGB(28, 28, 38),
        Selected = Color3.fromRGB(48, 48, 64),
    },
    
    -- Accent colors
    Accent = Color3.fromRGB(120, 110, 240),
    AccentHover = Color3.fromRGB(135, 125, 250),
    AccentActive = Color3.fromRGB(105, 95, 220),
    AccentDisabled = Color3.fromRGB(60, 55, 110),
    AccentSecondary = Color3.fromRGB(255, 95, 160),
    AccentGradient = Color3.fromRGB(80, 70, 200),
    
    -- Text colors
    Text = {
        Primary = Color3.fromRGB(240, 240, 250),
        Secondary = Color3.fromRGB(170, 170, 195),
        Tertiary = Color3.fromRGB(125, 125, 150),
        Disabled = Color3.fromRGB(90, 90, 110),
        OnAccent = Color3.fromRGB(255, 255, 255),
    },
    
    -- Border colors
    Border = {
        Default = Color3.fromRGB(48, 48, 62),
        Hover = Color3.fromRGB(70, 70, 92),
        Active = Color3.fromRGB(120, 110, 240),
        Disabled = Color3.fromRGB(40, 40, 52),
    },
    
    -- Status colors
    Success = Color3.fromRGB(80, 200, 130),
    Warning = Color3.fromRGB(255, 175, 50),
    Error = Color3.fromRGB(255, 80, 100),
    Info = Color3.fromRGB(80, 160, 255),
    
    -- Effects
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(120, 110, 240),
    
    -- Transparency
    Transparency = {
        Background = 0.1,
        Surface = 0.05,
        Component = 0,
        Border = 0,
        Acrylic = 0.15,
    },
    
    -- Sizes & spacing
    Corner = {
        Small = UDim.new(0, 6),
        Medium = UDim.new(0, 10),
        Large = UDim.new(0, 16),
        Pill = UDim.new(1, 0),
    },
    
    Padding = {
        Small = UDim.new(0, 8),
        Medium = UDim.new(0, 12),
        Large = UDim.new(0, 16),
        XLarge = UDim.new(0, 24),
    },
    
    -- Typography
    Font = Enum.Font.BuilderSans,
    FontMono = Enum.Font.Code,
    
    TextSize = {
        XS = 11,
        Small = 13,
        Medium = 15,
        Large = 18,
        XLarge = 24,
        Display = 32,
    },
    
    -- Stroke
    Stroke = {
        Size = 1,
        AccentSize = 1.5,
    },
    
    -- Blur
    Blur = {
        Enabled = true,
        Size = 12,
    },
}

-- Light Theme - clean and elegant
local LightTheme = {
    Name = "Light",
    Description = "VoidUI light theme with crisp whites and soft accents",
    
    Background = {
        Deep = Color3.fromRGB(245, 245, 248),
        Base = Color3.fromRGB(252, 252, 254),
        Surface = Color3.fromRGB(255, 255, 255),
        Elevated = Color3.fromRGB(252, 252, 255),
        Overlay = Color3.fromRGB(252, 252, 254),
    },
    
    Component = {
        Background = Color3.fromRGB(245, 245, 250),
        Hover = Color3.fromRGB(235, 235, 245),
        Active = Color3.fromRGB(225, 225, 240),
        Disabled = Color3.fromRGB(248, 248, 252),
        Selected = Color3.fromRGB(225, 225, 245),
    },
    
    Accent = Color3.fromRGB(110, 100, 230),
    AccentHover = Color3.fromRGB(95, 85, 210),
    AccentActive = Color3.fromRGB(125, 115, 245),
    AccentDisabled = Color3.fromRGB(180, 175, 220),
    AccentSecondary = Color3.fromRGB(235, 80, 150),
    AccentGradient = Color3.fromRGB(90, 80, 210),
    
    Text = {
        Primary = Color3.fromRGB(28, 28, 38),
        Secondary = Color3.fromRGB(85, 85, 105),
        Tertiary = Color3.fromRGB(130, 130, 150),
        Disabled = Color3.fromRGB(170, 170, 185),
        OnAccent = Color3.fromRGB(255, 255, 255),
    },
    
    Border = {
        Default = Color3.fromRGB(225, 225, 235),
        Hover = Color3.fromRGB(200, 200, 215),
        Active = Color3.fromRGB(110, 100, 230),
        Disabled = Color3.fromRGB(235, 235, 240),
    },
    
    Success = Color3.fromRGB(60, 170, 100),
    Warning = Color3.fromRGB(220, 150, 40),
    Error = Color3.fromRGB(230, 60, 80),
    Info = Color3.fromRGB(60, 140, 240),
    
    Shadow = Color3.fromRGB(180, 180, 200),
    Glow = Color3.fromRGB(110, 100, 230),
    
    Transparency = {
        Background = 0.05,
        Surface = 0,
        Component = 0,
        Border = 0,
        Acrylic = 0.1,
    },
    
    Corner = DarkTheme.Corner,
    Padding = DarkTheme.Padding,
    Font = DarkTheme.Font,
    FontMono = DarkTheme.FontMono,
    TextSize = DarkTheme.TextSize,
    Stroke = DarkTheme.Stroke,
    Blur = DarkTheme.Blur,
}

-- Midnight Theme - deep purple/blue accent
local MidnightTheme = Core.Utils.DeepClone(DarkTheme)
MidnightTheme.Name = "Midnight"
MidnightTheme.Description = "Deep midnight blue theme with cool accents"
MidnightTheme.Accent = Color3.fromRGB(80, 140, 255)
MidnightTheme.AccentHover = Color3.fromRGB(95, 155, 255)
MidnightTheme.AccentActive = Color3.fromRGB(65, 120, 230)
MidnightTheme.AccentGradient = Color3.fromRGB(50, 100, 220)
MidnightTheme.Glow = Color3.fromRGB(80, 140, 255)

-- Sunset Theme - warm orange/pink tones
local SunsetTheme = Core.Utils.DeepClone(DarkTheme)
SunsetTheme.Name = "Sunset"
SunsetTheme.Description = "Warm sunset theme with orange and pink accents"
SunsetTheme.Accent = Color3.fromRGB(255, 120, 80)
SunsetTheme.AccentHover = Color3.fromRGB(255, 135, 95)
SunsetTheme.AccentActive = Color3.fromRGB(235, 100, 65)
SunsetTheme.AccentSecondary = Color3.fromRGB(255, 80, 140)
SunsetTheme.AccentGradient = Color3.fromRGB(220, 90, 60)
SunsetTheme.Glow = Color3.fromRGB(255, 120, 80)

-- Forest Theme - green/nature inspired
local ForestTheme = Core.Utils.DeepClone(DarkTheme)
ForestTheme.Name = "Forest"
ForestTheme.Description = "Forest theme with emerald green accents"
ForestTheme.Accent = Color3.fromRGB(60, 200, 140)
ForestTheme.AccentHover = Color3.fromRGB(75, 215, 155)
ForestTheme.AccentActive = Color3.fromRGB(45, 180, 125)
ForestTheme.AccentGradient = Color3.fromRGB(40, 170, 110)
ForestTheme.Glow = Color3.fromRGB(60, 200, 140)

-- Cyber Theme - neon cyan/pink
local CyberTheme = Core.Utils.DeepClone(DarkTheme)
CyberTheme.Name = "Cyber"
CyberTheme.Description = "Cyberpunk inspired neon theme"
CyberTheme.Accent = Color3.fromRGB(0, 240, 255)
CyberTheme.AccentHover = Color3.fromRGB(40, 250, 255)
CyberTheme.AccentActive = Color3.fromRGB(0, 220, 235)
CyberTheme.AccentSecondary = Color3.fromRGB(255, 0, 200)
CyberTheme.AccentGradient = Color3.fromRGB(0, 200, 220)
CyberTheme.Glow = Color3.fromRGB(0, 240, 255)

-- Register themes
ThemeSystem._themes.Dark = DarkTheme
ThemeSystem._themes.Light = LightTheme
ThemeSystem._themes.Midnight = MidnightTheme
ThemeSystem._themes.Sunset = SunsetTheme
ThemeSystem._themes.Forest = ForestTheme
ThemeSystem._themes.Cyber = CyberTheme

-- ============================================================
-- Theme Management Functions
-- ============================================================

-- Register a custom theme
function ThemeSystem:Register(name, theme)
    if not theme.Name then
        theme.Name = name
    end
    self._themes[name] = theme
end

-- Get a theme by name
function ThemeSystem:GetTheme(name)
    return self._themes[name or self._current or self._default]
end

-- Get the current theme
function ThemeSystem:Current()
    return self:GetTheme(self._current or self._default)
end

-- Get current theme name
function ThemeSystem:CurrentName()
    return self._current or self._default
end

-- Set the current theme (triggers onChange)
function ThemeSystem:Set(name)
    if not self._themes[name] then
        warn("[VoidUI] Theme '" .. tostring(name) .. "' does not exist")
        return false
    end
    self._current = name
    self._onChange:Fire(self._themes[name])
    -- Notify all registered components
    for _, component in pairs(self._registry) do
        if component._ApplyTheme then
            task.spawn(function()
                component:_ApplyTheme(self._themes[name])
            end)
        end
    end
    return true
end

-- Register a component to receive theme updates
function ThemeSystem:RegisterComponent(component)
    local id = Core.Utils.GenerateId()
    self._registry[id] = component
    return function()
        self._registry[id] = nil
    end
end

-- Get the onChange signal
function ThemeSystem:GetChangeSignal()
    return self._onChange
end

-- List all available themes
function ThemeSystem:List()
    local names = {}
    for name in pairs(self._themes) do
        table.insert(names, name)
    end
    return names
end

-- Export a theme to a JSON string
function ThemeSystem:Export(name)
    local theme = self._themes[name or self._current]
    if not theme then return nil end
    
    -- Convert to JSON-serializable format
    local exportable = {}
    for k, v in pairs(theme) do
        if typeof(v) == "Color3" then
            exportable[k] = {
                type = "Color3",
                value = {r = v.R, g = v.G, b = v.B}
            }
        elseif type(v) == "table" then
            exportable[k] = {}
            for k2, v2 in pairs(v) do
                if typeof(v2) == "Color3" then
                    exportable[k][k2] = {
                        type = "Color3",
                        value = {r = v2.R, g = v2.G, b = v2.B}
                    }
                else
                    exportable[k][k2] = v2
                end
            end
        else
            exportable[k] = v
        end
    end
    
    return Core.Utils.EncodeJSON(exportable)
end

-- Import a theme from a JSON string
function ThemeSystem:Import(jsonString, name)
    local data = Core.Utils.DecodeJSON(jsonString)
    if not data then return nil end
    
    -- Convert back from JSON format
    local theme = {}
    for k, v in pairs(data) do
        if type(v) == "table" and v.type == "Color3" then
            theme[k] = Color3.new(v.value.r, v.value.g, v.value.b)
        elseif type(v) == "table" then
            theme[k] = {}
            for k2, v2 in pairs(v) do
                if type(v2) == "table" and v2.type == "Color3" then
                    theme[k][k2] = Color3.new(v2.value.r, v2.value.g, v2.value.b)
                else
                    theme[k][k2] = v2
                end
            end
        else
            theme[k] = v
        end
    end
    
    if name then
        theme.Name = name
        self._themes[name] = theme
    end
    
    return theme
end

-- Create a custom theme by extending an existing one
function ThemeSystem:Create(baseTheme, modifications)
    local base = self._themes[baseTheme] or self._themes[self._default]
    local newTheme = Core.Utils.DeepClone(base)
    for k, v in pairs(modifications) do
        newTheme[k] = v
    end
    return newTheme
end

-- Toggle between dark and light themes
function ThemeSystem:Toggle()
    local current = self._current or self._default
    if current == "Dark" then
        return self:Set("Light")
    else
        return self:Set("Dark")
    end
end

return ThemeSystem
