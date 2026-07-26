# Best Practices

This document provides recommended patterns and conventions for using VoidUI effectively. Following these practices will help you build clean, maintainable, and performant interfaces.

## Architecture

### Organize Your Code by Feature

Group related components together by feature rather than by type. For example, if you have a settings panel, group all the settings components in the same section rather than scattering them across different sections. This makes your code easier to navigate and maintain.

```lua
-- Good: Group related components
local SettingsSection = Tab:CreateSection("Settings")
SettingsSection:CreateToggle({ Text = "Enable Feature A", ... })
SettingsSection:CreateToggle({ Text = "Enable Feature B", ... })
SettingsSection:CreateSlider({ Text = "Feature A Intensity", ... })

-- Bad: Scatter components across unrelated sections
local Section1 = Tab:CreateSection("General")
Section1:CreateToggle({ Text = "Enable Feature A", ... })
local Section2 = Tab:CreateSection("Other")
Section2:CreateToggle({ Text = "Enable Feature B", ... })
```

### Use Sections for Organization

Sections provide natural grouping for related components. Use them liberally to keep your interface organized and easy to navigate. Collapsible sections are especially useful for grouping advanced or less frequently used settings.

### Use SubTabs for Complex Interfaces

When a single tab becomes too crowded, use SubTabs to create another level of navigation. This keeps each tab focused and manageable without overwhelming the user with too many components at once.

## Component Configuration

### Use the Callback Parameter for Simple Cases

For most use cases, the `Callback` parameter in component configuration is the simplest and most readable approach. Only use direct signal connections when you need multiple listeners, dynamic connection management, or the `Wait` yielding behavior.

```lua
-- Good: Simple callback
Section:CreateButton({
    Text = "Save",
    Callback = function() saveData() end,
})

-- Overly complex for simple cases
button.OnClick:Connect(function() saveData() end)
```

### Provide Descriptions for Important Toggles

Toggles and other binary controls benefit from descriptive text that explains what the option does. Use the `Description` parameter to provide context:

```lua
Section:CreateToggle({
    Text = "Enable Notifications",
    Description = "Receive alerts when important events occur.",
    Default = true,
    Callback = function(value) ... end,
})
```

### Use Meaningful Default Values

Set default values that make sense for the typical use case. This reduces the configuration burden on users and ensures a sensible initial state for your application.

### Use Suffix for Sliders

For sliders that represent a percentage, quantity, or other measurable value, use a suffix to make the value clear:

```lua
Section:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Suffix = "%",
    Default = 50,
})
```

## Theming

### Stick to Built-in Themes for Most Cases

The built-in themes are carefully designed with appropriate contrast, readability, and visual harmony. Use them as the default for your application and only create custom themes when you have a specific brand or design requirement.

### Use Accent Color for Branding

The accent color is the primary way to infuse your brand identity into the interface. Use a consistent accent color across all your components to create a cohesive visual identity.

```lua
VoidUI:SetAccent(Color3.fromRGB(120, 80, 255))  -- Your brand color
```

### Respect the User's Theme Choice

If your application allows users to choose a theme, persist their choice using the Export/Import system. Do not force a specific theme — let users choose what works best for their environment.

## Performance

### Disable Animations for Performance-Critical Scenarios

If you are running in a performance-constrained environment, disable animations to reduce the overhead:

```lua
VoidUI:ToggleAnimations(false)
```

You can also reduce the animation quality or increase the speed to find a balance between visual polish and performance.

### Clean Up Resources

Always destroy windows and components when they are no longer needed. This frees up memory and prevents unnecessary updates:

```lua
Window:Destroy()
-- Or for all windows:
VoidUI:DestroyAll()
```

### Avoid Creating Unnecessary Components

Only create components that are actually visible and needed. If a component is in a tab that the user rarely visits, consider creating it lazily when the tab is activated rather than at initialization.

## State Persistence

### Save State at Appropriate Times

Save the application state at appropriate times, such as when the window is closed, when important changes are made, or at regular intervals:

```lua
Window.OnClose:Connect(function()
    local state = VoidUI:Export()
    -- Save state to persistent storage
end)
```

### Handle Import Errors Gracefully

When importing state, handle errors gracefully in case the saved state is corrupted or from an incompatible version:

```lua
local success, state = pcall(function()
    return HttpService:JSONDecode(readfile("state.json"))
end)
if success then
    pcall(function() VoidUI:Import(state) end)
end
```

## Internationalization

### Use Translation Keys for All User-Facing Text

For applications that need to support multiple languages, use the translation system for all user-facing text rather than hardcoding strings. This makes localization easy and maintainable.

### Provide English as the Baseline

Always provide English translations as the baseline, since English is the fallback language. This ensures that any missing translations in other languages fall back to English rather than showing raw keys.

## Signals and Events

### Disconnect Connections When No Longer Needed

While VoidUI automatically disconnects internal connections when components are destroyed, you should disconnect any connections you create yourself to prevent memory leaks:

```lua
local connection = button.OnClick:Connect(function() ... end)
-- Later:
connection:Disconnect()
```

### Use Global Events for Cross-Component Communication

For communication between components that do not have direct references to each other, use the global event system rather than creating complex dependency chains:

```lua
Events.Global:Fire("settings:changed", newValue)
```

## Code Organization

### Keep Configuration Tables Readable

Format your configuration tables for readability with one property per line and clear alignment. This makes the code easier to scan and modify:

```lua
Section:CreateSlider({
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

### Document Complex Callback Logic

If your callbacks contain complex logic, add comments to explain what the code does. This helps future maintainers (including yourself) understand the intent:

```lua
Section:CreateButton({
    Text = "Export Data",
    Callback = function()
        -- Collect all current settings
        local data = collectSettings()
        -- Export to JSON and save to file
        saveToFile(HttpService:JSONEncode(data))
        -- Show success notification
        VoidUI:NotifySuccess("Exported", "Data saved to file.")
    end,
})
```

### Use Plugins for Reusable Extensions

If you find yourself duplicating component creation logic across multiple projects, consider creating a VoidUI plugin that encapsulates that logic. This makes your code reusable and easier to maintain.
