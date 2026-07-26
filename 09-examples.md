# Examples

This document provides a collection of practical examples demonstrating how to use VoidUI in various scenarios. Each example is self-contained and can be adapted to your specific needs.

## Example 1: Complete Settings Panel

This example creates a complete settings panel with multiple tabs and a wide range of component types, demonstrating how to build a full-featured settings interface.

```lua
local VoidUI = loadstring(game:HttpGet(URL))()

local Window = VoidUI:CreateWindow({
    Title = "Settings",
    Subtitle = "Configure your application",
    Accent = Color3.fromRGB(120, 80, 255),
})

-- General tab
local GeneralTab = Window:CreateTab("General", "rbxassetid://iconId")
local GeneralSection = GeneralTab:CreateSection("General")

GeneralSection:CreateToggle({
    Text = "Notifications",
    Description = "Enable push notifications",
    Default = true,
    Callback = function(value)
        print("Notifications:", value)
    end,
})

GeneralSection:CreateSlider({
    Text = "Notification Volume",
    Min = 0,
    Max = 100,
    Step = 5,
    Default = 50,
    Suffix = "%",
    Callback = function(value)
        print("Volume:", value)
    end,
})

GeneralSection:CreateDropdown({
    Text = "Default Language",
    Options = {"English", "Português", "Español"},
    Default = "English",
    Callback = function(value)
        VoidUI:SetLanguage(value == "Português" and "pt-BR" or value == "Español" and "es-ES" or "en-US")
    end,
})

-- Appearance tab
local AppearanceTab = Window:CreateTab("Appearance", "rbxassetid://iconId")
local AppearanceSection = AppearanceTab:CreateSection("Theme")

AppearanceSection:CreateDropdown({
    Text = "Theme",
    Options = VoidUI:ListThemes(),
    Default = VoidUI:GetThemeName(),
    Callback = function(themeName)
        VoidUI:SetTheme(themeName)
    end,
})

AppearanceSection:CreateColorPicker({
    Text = "Accent Color",
    Default = Color3.fromRGB(120, 80, 255),
    Callback = function(color)
        VoidUI:SetAccent(color)
    end,
})

AppearanceSection:CreateToggle({
    Text = "Acrylic Blur",
    Default = true,
    Callback = function(value)
        if value then
            VoidUI:EnableBlur()
        else
            VoidUI:DisableBlur()
        end
    end,
})

AppearanceSection:CreateSlider({
    Text = "Transparency",
    Min = 0,
    Max = 0.3,
    Step = 0.05,
    Default = 0.05,
    Callback = function(value)
        VoidUI:SetTransparency(value)
    end,
})

AppearanceSection:CreateToggle({
    Text = "Enable Animations",
    Default = true,
    Callback = function(value)
        VoidUI:ToggleAnimations(value)
    end,
})

AppearanceSection:CreateSlider({
    Text = "Animation Speed",
    Min = 0.5,
    Max = 2,
    Step = 0.1,
    Default = 1,
    Suffix = "x",
    Callback = function(value)
        VoidUI:SetAnimationSpeed(value)
    end,
})
```

## Example 2: Confirmation Dialog

This example shows how to create a confirmation dialog with custom buttons and handle the user's response.

```lua
VoidUI:ShowDialog({
    Title = "Delete File",
    Message = "Are you sure you want to delete this file? This action cannot be undone.",
    Variant = "Danger",
    Buttons = {"Cancel", "Delete"},
})

-- The dialog fires OnConfirm or OnCancel signals
-- You can connect to these signals to handle the response
local dialog = VoidUI:ShowDialog({
    Title = "Save Changes?",
    Message = "You have unsaved changes. Do you want to save before closing?",
    Variant = "Warning",
    Buttons = {"Don't Save", "Cancel", "Save"},
})

dialog.OnButton:Connect(function(buttonText)
    if buttonText == "Save" then
        saveChanges()
    elseif buttonText == "Don't Save" then
        closeWithoutSaving()
    end
end)
```

## Example 3: Notification System

This example demonstrates the different notification types and the toast system.

```lua
-- Full notifications with icons
VoidUI:NotifyInfo("Update Available", "Version 1.1.0 is ready to download.")
VoidUI:NotifySuccess("File Saved", "Your document has been saved to disk.")
VoidUI:NotifyWarning("Low Battery", "Your device has less than 20% battery remaining.")
VoidUI:NotifyError("Connection Failed", "Could not connect to the server. Please check your internet connection.")

-- Compact toasts
VoidUI:Toast("Syncing", "Synchronizing with cloud...", "Info", 2)
VoidUI:Toast("Complete", "Sync finished successfully.", "Success", 3)

-- Custom notification with icon
VoidUI:Notify({
    Title = "New Message",
    Description = "You have received a new message from John.",
    Icon = "rbxassetid://iconId",
    Variant = "Info",
    Duration = 8,
})
```

## Example 4: Data Table with Sorting

This example creates a data table with multiple columns, sortable headers, and row selection.

```lua
local Tab = Window:CreateTab("Data", "rbxassetid://iconId")
local DataSection = Tab:CreateSection("Records")

local dataTable = DataSection:CreateDataTable({
    Columns = {
        {Key = "name", Title = "Name", Sortable = true},
        {Key = "age", Title = "Age", Sortable = true},
        {Key = "email", Title = "Email", Sortable = false},
        {Key = "status", Title = "Status", Sortable = true},
    },
    Rows = {
        {name = "Alice", age = 30, email = "alice@example.com", status = "Active"},
        {name = "Bob", age = 25, email = "bob@example.com", status = "Inactive"},
        {name = "Charlie", age = 35, email = "charlie@example.com", status = "Active"},
        {name = "Diana", age = 28, email = "diana@example.com", status = "Pending"},
    },
    Sortable = true,
})

dataTable.OnRowSelect:Connect(function(row)
    print("Selected:", row.name, row.email)
end)

dataTable.OnSort:Connect(function(columnKey, ascending)
    print("Sorting by:", columnKey, ascending and "ascending" or "descending")
end)
```

## Example 5: Sidebar Navigation

This example creates a sidebar navigation with collapsible behavior and multiple items.

```lua
local sidebar = VoidUI:Create("Sidebar", {
    Title = "Navigation",
    Collapsible = true,
    Items = {
        {Text = "Dashboard", Icon = "rbxassetid://icon1"},
        {Text = "Projects", Icon = "rbxassetid://icon2"},
        {Text = "Tasks", Icon = "rbxassetid://icon3"},
        {Text = "Team", Icon = "rbxassetid://icon4"},
        {Text = "Settings", Icon = "rbxassetid://icon5"},
    },
})

sidebar.OnNavigate:Connect(function(itemText)
    print("Navigated to:", itemText)
    -- Show the appropriate content for the selected item
end)
```

## Example 6: State Persistence

This example demonstrates saving and restoring the application state, including theme, window position, and component values.

```lua
-- Export state when the window closes
Window.OnClose:Connect(function()
    local state = VoidUI:Export()
    -- Save state to your preferred storage (DataStore, file, etc.)
    writefile("voidui_state.json", game:GetService("HttpService"):JSONEncode(state))
end)

-- Import state on startup
local success, content = pcall(readfile, "voidui_state.json")
if success then
    local state = game:GetService("HttpService"):JSONDecode(content)
    VoidUI:Import(state)
end
```

## Example 7: Custom Plugin

This example creates a custom plugin that registers a new component type and hooks into library lifecycle events.

```lua
VoidUI:RegisterPlugin("CustomWidgets", function(api)
    api.Log("CustomWidgets plugin loaded")
    
    -- Register a custom progress ring component
    api.RegisterComponent("ProgressRing", function(config)
        local ring = {
            Value = config.Default or 0,
            Max = config.Max or 100,
        }
        function ring:SetValue(value)
            self.Value = api.Utils.Clamp(value, 0, self.Max)
            local percent = self.Value / self.Max
            api.Log("Progress ring updated: " .. tostring(percent * 100) .. "%")
        end
        function ring:GetProgress()
            return self.Value / self.Max
        end
        return ring
    end)
    
    -- Register a custom theme
    api.RegisterTheme("CustomBlue", {
        Background = Color3.fromRGB(10, 20, 35),
        Text = Color3.fromRGB(200, 220, 255),
        Accent = Color3.fromRGB(60, 120, 220),
    })
    
    -- Hook into theme changes
    api.On("ThemeChanged", function(themeName)
        api.Log("Theme changed to: " .. themeName)
    end)
end)

-- Use the custom component
local ring = VoidUI:Create("ProgressRing", { Default = 50 })
ring:SetValue(75)
print(ring:GetProgress())  -- 0.75
```

## Example 8: Loading Screen with Progress

This example shows how to display a loading screen with a progress indicator while performing initialization tasks.

```lua
local loader = VoidUI:ShowLoadingScreen({
    Title = "Loading",
    Subtitle = "Initializing application...",
})

-- Simulate loading progress
for i = 1, 10 do
    task.wait(0.2)
    loader:SetProgress(i * 10)
end

loader:SetProgress(100)
task.wait(0.5)
VoidUI:HideLoadingScreen()
VoidUI:NotifySuccess("Ready", "Application loaded successfully.")
```

## Example 9: Context Menu

This example creates a context menu that appears on right-click with a list of actions.

```lua
local rightClickMenu = VoidUI:Create("RightClickMenu", {
    Items = {
        {Text = "Copy", Shortcut = "Ctrl+C", Action = function() print("Copied") end},
        {Text = "Paste", Shortcut = "Ctrl+V", Action = function() print("Pasted") end},
        {Separator = true},
        {Text = "Delete", Danger = true, Action = function() print("Deleted") end},
        {Text = "Properties", Action = function() print("Properties") end},
    },
})

-- Attach to a specific element
rightClickMenu:Attach(someFrame)
```

## Example 10: Multi-Step Welcome Screen

This example creates a welcome screen with multiple steps for onboarding new users.

```lua
local welcome = VoidUI:ShowWelcomeScreen({
    Steps = {
        {
            Icon = "rbxassetid://icon1",
            Title = "Welcome to VoidUI",
            Description = "The most modern UI library for Lua. Let's get you started!",
        },
        {
            Icon = "rbxassetid://icon2",
            Title = "Create Your First Window",
            Description = "Use CreateWindow to build your interface with tabs and sections.",
        },
        {
            Icon = "rbxassetid://icon3",
            Title = "Add Components",
            Description = "Populate your sections with buttons, toggles, sliders, and more.",
        },
        {
            Icon = "rbxassetid://icon4",
            Title = "Customize",
            Description = "Choose from six built-in themes or create your own custom theme.",
        },
        {
            Icon = "rbxassetid://icon5",
            Title = "You're All Set!",
            Description = "Start building amazing interfaces with VoidUI today.",
        },
    },
})

welcome.OnComplete:Connect(function()
    VoidUI:NotifySuccess("Welcome!", "You are ready to use VoidUI.")
end)

welcome.OnSkip:Connect(function()
    print("User skipped the welcome screen")
end)
```
