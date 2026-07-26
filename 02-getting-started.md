# Getting Started

This guide walks you through creating your first VoidUI interface from scratch. By the end, you will have a fully functional settings window with tabs, sections, and a variety of input components.

## Step 1: Load the Library

Begin by loading VoidUI into your script. The library returns a table that serves as the entry point for all functionality.

```lua
local VoidUI = loadstring(game:HttpGet(URL))()
```

At this point, the `VoidUI` table is available and the library has been initialized. The initialization process loads all core modules, sets up the default theme, registers all built-in components, and fires the `Init` hook for any loaded plugins.

## Step 2: Create a Window

The window is the top-level container for your entire interface. It provides the draggable frame, title bar, tab navigation, and all the structural elements that hold your components.

```lua
local Window = VoidUI:CreateWindow({
    Title = "My Application",
    Subtitle = "Powered by VoidUI",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(400, 300),
    Accent = Color3.fromRGB(120, 80, 255),
    Theme = "Dark",
    Acrylic = true,
    Transparency = 0.05,
})
```

The window configuration accepts many options. The `Title` and `Subtitle` appear in the window header. `Size` determines the initial dimensions of the window. `MinSize` prevents the window from being resized below this minimum. `Accent` sets the accent color used throughout the interface for highlights and interactive elements. `Theme` selects the initial theme by name. `Acrylic` enables or disables the blur effect behind the window. `Transparency` controls the overall transparency level from 0 to 1.

The window is draggable by its title bar, can be minimized, maximized, and closed using the built-in window controls, and remembers its position and size if state persistence is enabled.

## Step 3: Add Tabs

Tabs organize your interface into logical sections. Each tab has a button in the tab bar and a content area that is shown when the tab is active.

```lua
local HomeTab = Window:CreateTab("Home", "rbxassetid://iconId")
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://iconId")
local AboutTab = Window:CreateTab("About", "rbxassetid://iconId")
```

Each tab takes a name and an optional icon. The icon can be an asset ID string or a numeric ID. The first tab created becomes the active tab by default. You can also create sub-tabs within a tab for additional navigation levels.

```lua
local GeneralSubTab = SettingsTab:CreateSubTab("General", "rbxassetid://iconId")
local AdvancedSubTab = SettingsTab:CreateSubTab("Advanced", "rbxassetid://iconId")
```

## Step 4: Add Sections

Sections group related components within a tab. A section has a title header and a content area where components are added. Sections can also be collapsible.

```lua
local GeneralSection = GeneralSubTab:CreateSection("General Settings")
local AppearanceSection = GeneralSubTab:CreateSection("Appearance", {
    Collapsible = true,
    Expanded = true,
})
```

The `Collapsible` option allows the section to be expanded and collapsed by clicking its header. The `Expanded` option sets the initial expanded state. The `Side` option can be used to position the section on the left or right side of the tab content area.

## Step 5: Add Components

Now you can populate your sections with components. Each component is created through a factory method on the section object.

```lua
-- A toggle switch
GeneralSection:CreateToggle({
    Text = "Enable Notifications",
    Description = "Receive alerts when something happens.",
    Default = true,
    Callback = function(value)
        print("Notifications:", value)
    end,
})

-- A slider
GeneralSection:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 50,
    Suffix = "%",
    Callback = function(value)
        print("Volume set to:", value)
    end,
})

-- A dropdown
GeneralSection:CreateDropdown({
    Text = "Language",
    Options = {"English", "Português", "Español"},
    Default = "English",
    Callback = function(value)
        print("Language selected:", value)
    end,
})

-- A button
AppearanceSection:CreateButton({
    Text = "Apply Changes",
    Style = "Primary",
    Callback = function()
        print("Changes applied!")
    end,
})
```

Every component accepts a configuration table with options specific to its type. Most interactive components accept a `Callback` function that is called when the component's value changes or an action is triggered. The callback receives the new value as its first argument for components that have a value.

## Step 6: Connect to Events

In addition to callbacks, VoidUI components emit signals that you can connect to. This is useful for advanced scenarios where you need to react to multiple events or manage connections dynamically.

```lua
local Toggle = GeneralSection:CreateToggle({
    Text = "Dark Mode",
    Default = false,
})

Toggle.OnChanged:Connect(function(value)
    if value then
        VoidUI:SetTheme("Dark")
    else
        VoidUI:SetTheme("Light")
    end
end)
```

The signal system uses the `:Connect` method which returns a connection object. You can disconnect a connection by calling `:Disconnect()` on the returned object. This allows you to clean up event listeners when they are no longer needed.

## Step 7: Use Notifications and Toasts

VoidUI provides a notification system for displaying temporary messages to the user.

```lua
VoidUI:NotifySuccess("Settings Saved", "Your preferences have been saved successfully.")
VoidUI:NotifyWarning("Attention", "Some settings may require a restart.")
VoidUI:NotifyError("Error", "Failed to save settings. Please try again.")
VoidUI:NotifyInfo("Information", "New updates are available.")
```

For a more compact notification style, use the toast system:

```lua
VoidUI:Toast("File Saved", "Document saved to disk.", "Success", 3)
```

The toast function takes a title, description, variant (Info, Success, Warning, Error), and an optional duration in seconds.

## Step 8: Save and Restore State

VoidUI can save and restore the state of your interface, including theme preference, window position, and component values. This is done through the export and import functions.

```lua
-- Export the current state
local state = VoidUI:Export()
-- state is a JSON-encodable table that can be saved anywhere

-- Import and restore state
VoidUI:Import(state)
```

The exported state includes the current theme name, the accent color, the window configuration (position, size, minimized state), and the saved values of all components that have state persistence enabled. You can save this state to a data store, a file, or any other persistent storage and restore it on the next session.

## Complete Example

Here is a complete, working example that ties together everything covered in this guide:

```lua
local VoidUI = loadstring(game:HttpGet(URL))()

-- Create the main window
local Window = VoidUI:CreateWindow({
    Title = "VoidUI Demo",
    Subtitle = "Getting Started Example",
    Accent = Color3.fromRGB(120, 80, 255),
})

-- Create tabs
local HomeTab = Window:CreateTab("Home", "rbxassetid://iconId")
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://iconId")

-- Home tab content
local HomeSection = HomeTab:CreateSection("Welcome")

HomeSection:CreateParagraph({
    Title = "Welcome to VoidUI",
    Text = "This is a demonstration of the VoidUI library. Navigate to the Settings tab to see the available components.",
})

HomeSection:CreateButton({
    Text = "Show Notification",
    Style = "Primary",
    Callback = function()
        VoidUI:NotifySuccess("Hello!", "You clicked the button.")
    end,
})

-- Settings tab content
local SettingsSection = SettingsTab:CreateSection("Preferences", {
    Collapsible = true,
})

SettingsSection:CreateToggle({
    Text = "Enable Animations",
    Description = "Toggle smooth animations throughout the interface.",
    Default = true,
    Callback = function(value)
        VoidUI:ToggleAnimations(value)
    end,
})

SettingsSection:CreateSlider({
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

SettingsSection:CreateDropdown({
    Text = "Theme",
    Options = VoidUI:ListThemes(),
    Default = VoidUI:GetThemeName(),
    Callback = function(themeName)
        VoidUI:SetTheme(themeName)
    end,
})

-- Save state on close
Window.OnClose:Connect(function()
    local state = VoidUI:Export()
    -- Save state to your preferred storage
    print("State exported")
end)
```

This example creates a window with two tabs, a welcome message on the home tab, and a set of settings controls on the settings tab. The animations toggle and slider control the global animation settings, and the theme dropdown allows the user to switch between available themes. When the window is closed, the state is exported for persistence.

## Next Steps

Now that you have a working interface, explore the [API Reference](./03-api-reference.md) to learn about all the available functions, or browse the [Components](./04-components.md) documentation to see what each component can do.
