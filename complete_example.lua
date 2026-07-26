--[[
    VoidUI - Complete Example Script
    ================================
    This example demonstrates a full-featured application built with VoidUI.
    It covers windows, tabs, sections, all major components, themes,
    notifications, state persistence, and event handling.

    Usage:
        Load this script in a Roblox executor environment.
        VoidUI will be loaded automatically via loadstring.
]]

-- ============================================================
-- 1. Load VoidUI
-- ============================================================
local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- Optional: Set the language
VoidUI:SetLanguage("en-US")

-- ============================================================
-- 2. Create the Main Window
-- ============================================================
local Window = VoidUI:CreateWindow({
    Title = "VoidUI Demo",
    SubTitle = "Complete Example Application",
    Theme = "Dark",
    Size = Vector2.new(680, 520),
    MinSize = Vector2.new(400, 300),
    MaxSize = Vector2.new(1200, 800),
    Position = UDim2.new(0.5, -340, 0.5, -260),
    Acrylic = true,
    Transparency = 0.92,
    Draggable = true,
    Resizable = true,
    ShowShadow = true,
    MinimizeButton = true,
    CloseButton = true,
})

-- Handle window events
Window.OnClose:Connect(function()
    VoidUI:NotifyInfo({
        Title = "Goodbye",
        Description = "Window was closed",
        Duration = 3,
    })
end)

Window.OnMinimize:Connect(function()
    print("Window minimized")
end)

-- ============================================================
-- 3. Create Tabs
-- ============================================================
local HomeTab = Window:AddTab({
    Title = "Home",
    Icon = "rbxassetid://3928340255", -- Home icon
})

local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "rbxassetid://3928340378", -- Settings icon
})

local AboutTab = Window:AddTab({
    Title = "About",
    Icon = "rbxassetid://3928340501", -- Info icon
})

-- ============================================================
-- 4. Home Tab Content
-- ============================================================
local HomeSection = HomeTab:AddSection({
    Title = "Welcome",
    Description = "Explore VoidUI's features below",
})

HomeSection:AddParagraph({
    Title = "Getting Started",
    Text = "Welcome to VoidUI! This example demonstrates all the major components and features. Use the tabs above to navigate between sections.",
})

HomeSection:AddButton({
    Text = "Show Notification",
    Style = "Primary",
    Icon = "rbxassetid://3928344256",
    OnClick = function()
        VoidUI:Notify({
            Title = "Hello from VoidUI",
            Description = "This notification was triggered by a button click.",
            Duration = 4,
        })
    end,
})

HomeSection:AddButton({
    Text = "Show Success Toast",
    Style = "Success",
    OnClick = function()
        VoidUI:NotifySuccess({
            Title = "Success!",
            Description = "The operation completed successfully.",
        })
    end,
})

HomeSection:AddButton({
    Text = "Show Dialog",
    Style = "Secondary",
    OnClick = function()
        VoidUI:ShowDialog({
            Title = "Confirm Action",
            Message = "Are you sure you want to proceed with this action?",
            Buttons = {
                { Text = "Cancel", Style = "Secondary" },
                { Text = "Confirm", Style = "Primary" },
            },
            OnConfirm = function()
                VoidUI:NotifySuccess({
                    Title = "Confirmed",
                    Description = "Action was confirmed by the user.",
                })
            end,
            OnCancel = function()
                print("Dialog was cancelled")
            end,
        })
    end,
})

-- ============================================================
-- 5. Settings Tab - Toggle Components
-- ============================================================
local TogglesSection = SettingsTab:AddSection({
    Title = "Preferences",
    Description = "Toggle your preferences",
})

TogglesSection:AddToggle({
    Text = "Enable Notifications",
    Description = "Receive notifications for important events",
    Default = true,
    OnChanged = function(value)
        print("Notifications:", value)
    end,
})

TogglesSection:AddToggle({
    Text = "Dark Mode",
    Description = "Use dark theme throughout the application",
    Default = true,
    OnChanged = function(value)
        if value then
            VoidUI:SetTheme("Dark")
        else
            VoidUI:SetTheme("Light")
        end
    end,
})

TogglesSection:AddToggle({
    Text = "Auto-save",
    Description = "Automatically save your configuration",
    Default = false,
    OnChanged = function(value)
        print("Auto-save:", value)
    end,
})

TogglesSection:AddCheckbox({
    Text = "Accept Terms",
    Description = "I agree to the terms and conditions",
    Default = false,
    OnChanged = function(value)
        print("Terms accepted:", value)
    end,
})

-- ============================================================
-- 6. Settings Tab - Sliders
-- ============================================================
local SlidersSection = SettingsTab:AddSection({
    Title = "Adjustments",
})

SlidersSection:AddSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Suffix = "%",
    OnChanged = function(value)
        print("Volume set to:", value)
    end,
})

SlidersSection:AddSlider({
    Text = "UI Scale",
    Min = 50,
    Max = 150,
    Default = 100,
    Step = 5,
    Suffix = "%",
    OnChanged = function(value)
        print("UI Scale:", value)
    end,
})

SlidersSection:AddSlider({
    Text = "Animation Speed",
    Min = 0,
    Max = 3,
    Default = 1,
    Step = 0.1,
    Format = function(value)
        return string.format("%.1fx", value)
    end,
    OnChanged = function(value)
        VoidUI:SetAnimationSpeed(value)
    end,
})

-- ============================================================
-- 7. Settings Tab - Dropdowns
-- ============================================================
local DropdownSection = SettingsTab:AddSection({
    Title = "Selections",
})

DropdownSection:AddDropdown({
    Text = "Theme",
    Options = { "Dark", "Light", "Midnight", "Sunset", "Forest", "Cyber" },
    Default = "Dark",
    OnChanged = function(value)
        VoidUI:SetTheme(value)
        VoidUI:NotifyInfo({
            Title = "Theme Changed",
            Description = "Theme set to: " .. value,
            Duration = 2,
        })
    end,
})

DropdownSection:AddDropdown({
    Text = "Language",
    Options = { "English", "Português", "Español" },
    Default = "English",
    OnChanged = function(value)
        local langMap = {
            English = "en-US",
            ["Português"] = "pt-BR",
            ["Español"] = "es-ES",
        }
        VoidUI:SetLanguage(langMap[value] or "en-US")
    end,
})

DropdownSection:AddMultiDropdown({
    Text = "Enabled Features",
    Options = { "Animations", "Blur", "Shadows", "Glow", "Ripple", "Tooltips" },
    Default = { "Animations", "Blur", "Shadows" },
    OnChanged = function(selected)
        print("Enabled features:", table.concat(selected, ", "))
    end,
})

-- ============================================================
-- 8. Settings Tab - Color Picker & Keybind
-- ============================================================
local CustomizationSection = SettingsTab:AddSection({
    Title = "Customization",
})

CustomizationSection:AddColorPicker({
    Text = "Accent Color",
    Default = Color3.fromRGB(120, 80, 255),
    OnChanged = function(color)
        VoidUI:SetAccent(color)
        print("Accent color set to:", color)
    end,
})

CustomizationSection:AddKeybind({
    Text = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Mode = "Toggle",
    OnTriggered = function()
        Window:SetVisible(not Window:IsVisible())
    end,
    OnChanged = function(key)
        print("Keybind changed to:", key)
    end,
})

-- ============================================================
-- 9. Settings Tab - Input Fields
-- ============================================================
local InputSection = SettingsTab:AddSection({
    Title = "Input Fields",
})

InputSection:AddTextbox({
    Text = "Username",
    Placeholder = "Enter your username",
    Default = "",
    OnChanged = function(value)
        print("Username:", value)
    end,
})

InputSection:AddInput({
    Placeholder = "Search...",
    Icon = "rbxassetid://3928344256",
    OnChanged = function(value)
        print("Search:", value)
    end,
})

InputSection:AddPasswordInput({
    Text = "Password",
    Placeholder = "Enter your password",
    OnChanged = function(value)
        print("Password length:", #value)
    end,
})

-- ============================================================
-- 10. About Tab Content
-- ============================================================
local AboutSection = AboutTab:AddSection({
    Title = "About VoidUI",
})

AboutSection:AddParagraph({
    Title = "VoidUI v1.0.0",
    Text = "VoidUI is a modern, elegant, and complete UI library for Lua/LuaU. It features 50+ components, 6 built-in themes, 3 language packs, a full plugin system, and comprehensive documentation.",
})

AboutSection:AddParagraph({
    Title = "Features",
    Text = "50+ Components | 6 Themes | 3 Languages | Plugin System | Modern Animations | Developer Tools | Full Documentation | MIT License",
})

local StatsSection = AboutTab:AddSection({
    Title = "Statistics",
})

StatsSection:AddLabel({ Text = "Components: 50+", Style = "Bold" })
StatsSection:AddLabel({ Text = "Themes: 6 built-in + custom" })
StatsSection:AddLabel({ Text = "Languages: en-US, pt-BR, es-ES" })
StatsSection:AddLabel({ Text = "License: MIT" })

StatsSection:AddDivider({ Text = "Quick Actions" })

StatsSection:AddButton({
    Text = "Open Command Palette",
    Style = "Primary",
    OnClick = function()
        VoidUI:OpenCommandPalette()
    end,
})

StatsSection:AddButton({
    Text = "Open Debug Console",
    Style = "Secondary",
    OnClick = function()
        VoidUI:OpenConsole()
    end,
})

-- ============================================================
-- 11. Save and Restore State
-- ============================================================
-- Save the current state
task.spawn(function()
    task.wait(2)
    VoidUI:Export("VoidUI_Demo_Config")
    print("[VoidUI] Configuration saved.")
end)

-- ============================================================
-- 12. Show a welcome notification
-- ============================================================
VoidUI:NotifyInfo({
    Title = "Welcome to VoidUI!",
    Description = "All components are ready. Explore the tabs to see everything in action.",
    Duration = 5,
})

print("[VoidUI] Example application loaded successfully!")
print("[VoidUI] Version:", VoidUI:GetVersion())
