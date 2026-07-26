--[[
    VoidUI - Settings Panel Example
    ===============================
    A focused example showing a settings panel with
    toggles, sliders, dropdowns, and state persistence.
]]

local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- Create window
local Window = VoidUI:CreateWindow({
    Title = "Settings",
    SubTitle = "Configure your preferences",
    Theme = "Dark",
    Size = Vector2.new(520, 460),
})

-- General Settings Tab
local GeneralTab = Window:AddTab({
    Title = "General",
    Icon = "rbxassetid://3928340255",
})

local GeneralSection = GeneralTab:AddSection({
    Title = "General Settings",
    Description = "Basic application preferences",
})

GeneralSection:AddToggle({
    Text = "Launch on Startup",
    Description = "Start the application when the game loads",
    Default = true,
    OnChanged = function(value)
        print("Launch on startup:", value)
    end,
})

GeneralSection:AddToggle({
    Text = "Check for Updates",
    Description = "Automatically check for new versions",
    Default = true,
    OnChanged = function(value)
        print("Auto-update:", value)
    end,
})

GeneralSection:AddToggle({
    Text = "Minimize to Tray",
    Default = false,
    OnChanged = function(value)
        print("Minimize to tray:", value)
    end,
})

GeneralSection:AddSlider({
    Text = "Window Opacity",
    Min = 50,
    Max = 100,
    Default = 92,
    Suffix = "%",
    OnChanged = function(value)
        Window:SetTransparency(value / 100)
    end,
})

GeneralSection:AddSlider({
    Text = "UI Scale",
    Min = 50,
    Max = 150,
    Default = 100,
    Step = 5,
    Suffix = "%",
})

-- Appearance Tab
local AppearanceTab = Window:AddTab({
    Title = "Appearance",
    Icon = "rbxassetid://3928340378",
})

local AppearanceSection = AppearanceTab:AddSection({
    Title = "Theme & Colors",
})

AppearanceSection:AddDropdown({
    Text = "Theme",
    Options = { "Dark", "Light", "Midnight", "Sunset", "Forest", "Cyber" },
    Default = "Dark",
    OnChanged = function(value)
        VoidUI:SetTheme(value)
    end,
})

AppearanceSection:AddColorPicker({
    Text = "Accent Color",
    Default = Color3.fromRGB(120, 80, 255),
    OnChanged = function(color)
        VoidUI:SetAccent(color)
    end,
})

AppearanceSection:AddToggle({
    Text = "Enable Blur",
    Description = "Apply acrylic blur to windows",
    Default = true,
    OnChanged = function(value)
        if value then
            VoidUI:EnableBlur()
        else
            VoidUI:DisableBlur()
        end
    end,
})

AppearanceSection:AddToggle({
    Text = "Enable Animations",
    Default = true,
    OnChanged = function(value)
        VoidUI:ToggleAnimations(value)
    end,
})

AppearanceSection:AddSlider({
    Text = "Animation Speed",
    Min = 0.5,
    Max = 2.0,
    Default = 1.0,
    Step = 0.1,
    Format = function(v) return string.format("%.1fx", v) end,
    OnChanged = function(value)
        VoidUI:SetAnimationSpeed(value)
    end,
})

-- Advanced Tab
local AdvancedTab = Window:AddTab({
    Title = "Advanced",
    Icon = "rbxassetid://3928340501",
})

local AdvancedSection = AdvancedTab:AddSection({
    Title = "Advanced Settings",
})

AdvancedSection:AddDropdown({
    Text = "Language",
    Options = { "English", "Português", "Español" },
    Default = "English",
    OnChanged = function(value)
        local langMap = { English = "en-US", ["Português"] = "pt-BR", ["Español"] = "es-ES" }
        VoidUI:SetLanguage(langMap[value] or "en-US")
    end,
})

AdvancedSection:AddKeybind({
    Text = "Toggle UI Hotkey",
    Default = Enum.KeyCode.RightShift,
    Mode = "Toggle",
    OnTriggered = function()
        Window:SetVisible(not Window:IsVisible())
    end,
})

AdvancedSection:AddTextbox({
    Text = "Config Name",
    Placeholder = "Enter a name for this configuration",
    Default = "Default",
    OnChanged = function(value)
        print("Config name:", value)
    end,
})

AdvancedSection:AddButton({
    Text = "Export Configuration",
    Style = "Primary",
    OnClick = function()
        VoidUI:Export("Settings_Export")
        VoidUI:NotifySuccess({
            Title = "Exported",
            Description = "Configuration has been exported successfully.",
        })
    end,
})

AdvancedSection:AddButton({
    Text = "Reset to Defaults",
    Style = "Danger",
    OnClick = function()
        VoidUI:ShowDialog({
            Title = "Reset Settings",
            Message = "Are you sure you want to reset all settings to their defaults?",
            Buttons = {
                { Text = "Cancel", Style = "Secondary" },
                { Text = "Reset", Style = "Danger" },
            },
            OnConfirm = function()
                VoidUI:SetTheme("Dark")
                VoidUI:SetAccent(Color3.fromRGB(120, 80, 255))
                VoidUI:ToggleAnimations(true)
                VoidUI:NotifySuccess({
                    Title = "Reset Complete",
                    Description = "All settings have been reset.",
                })
            end,
        })
    end,
})

print("[VoidUI] Settings panel example loaded!")
