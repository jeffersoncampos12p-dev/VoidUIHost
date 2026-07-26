# API Reference

This document provides a complete reference for the global VoidUI API. The API is exposed as methods on the main `VoidUI` table returned by the loader function.

## Core Module Access

These functions provide access to the internal core modules of the library. They are useful when you need to use the lower-level functionality directly or when building custom components or plugins.

### `VoidUI.GetCore()`

Returns the VoidCore module, which contains the Signal class, Promise class, Object base class, Utils table, Color utilities, and StateManager.

```lua
local Core = VoidUI:GetCore()
local Signal = Core.Signal
local Promise = Core.Promise
local Utils = Core.Utils
```

### `VoidUI.GetThemeSystem()`

Returns the ThemeSystem module, which manages theme registration, switching, and change notifications.

```lua
local ThemeSystem = VoidUI:GetThemeSystem()
ThemeSystem.Set("Light")
```

### `VoidUI.GetAnimationSystem()`

Returns the AnimationSystem module, which provides tween helpers, ripple effects, glow effects, and other animation utilities.

```lua
local Anim = VoidUI:GetAnimationSystem()
Anim.SetEnabled(false)  -- disable all animations
```

### `VoidUI.GetEvents()`

Returns the EventSystem module, which provides the global event dispatcher and keybind management.

```lua
local Events = VoidUI:GetEvents()
Events.Global:Connect("myEvent", function(...) end)
```

### `VoidUI.GetI18n()`

Returns the i18n module, which manages language translations.

```lua
local i18n = VoidUI:GetI18n()
print(i18n.T("welcome_message"))
```

### `VoidUI.GetPlugins()`

Returns the PluginSystem module, which manages plugin registration and lifecycle hooks.

```lua
local Plugins = VoidUI:GetPlugins()
Plugins.Register("MyPlugin", function(api) end)
```

## Theme Management

These functions control the visual theme of the interface. VoidUI ships with six built-in themes and supports custom theme creation.

### `VoidUI.SetTheme(themeName)`

Sets the current theme by name. All registered components will update to reflect the new theme.

```lua
VoidUI:SetTheme("Midnight")
```

### `VoidUI.GetTheme()`

Returns the current theme table, which contains all the color values, typography settings, and other theme properties.

```lua
local theme = VoidUI:GetTheme()
print(theme.Background, theme.Text, theme.Accent)
```

### `VoidUI.GetThemeName()`

Returns the name of the currently active theme as a string.

```lua
print(VoidUI:GetThemeName())  -- "Dark"
```

### `VoidUI.LoadTheme(themeData)`

Loads a theme from a data table. This is useful for loading custom themes from saved configurations.

```lua
VoidUI:LoadTheme({
    Name = "My Custom Theme",
    Background = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(220, 220, 230),
    Accent = Color3.fromRGB(255, 100, 200),
})
```

### `VoidUI.SaveTheme()`

Returns the current theme as a data table that can be saved and later loaded with `LoadTheme`.

```lua
local themeData = VoidUI:SaveTheme()
-- Save themeData to persistent storage
```

### `VoidUI.CreateTheme(name, data)`

Registers a new custom theme with the given name and theme data. The theme becomes available for use with `SetTheme`.

```lua
VoidUI:CreateTheme("Ocean", {
    Background = Color3.fromRGB(10, 30, 50),
    Text = Color3.fromRGB(200, 230, 255),
    Accent = Color3.fromRGB(0, 150, 200),
})
VoidUI:SetTheme("Ocean")
```

### `VoidUI.ListThemes()`

Returns a list of all registered theme names as an array of strings.

```lua
for _, name in ipairs(VoidUI:ListThemes()) do
    print(name)
end
```

### `VoidUI.SetAccent(color)`

Sets the accent color for the current theme without changing the entire theme. The accent color is used for highlights, interactive elements, and focus states.

```lua
VoidUI:SetAccent(Color3.fromRGB(255, 80, 120))
```

### `VoidUI.ToggleTheme()`

Toggles between the Dark and Light themes. This is a convenience function for implementing a dark mode toggle.

```lua
VoidUI:ToggleTheme()
```

## Window Management

These functions create and manage the main application windows.

### `VoidUI.CreateWindow(config)`

Creates a new Window instance with the given configuration and returns it. The window is automatically added to the window manager and becomes the active window.

The `config` table accepts the following options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | `"VoidUI"` | The window title shown in the header |
| `Subtitle` | string | `""` | A subtitle shown below the title |
| `Size` | UDim2 | `580x460` | The initial window size |
| `MinSize` | Vector2 | `400x300` | The minimum resizable size |
| `Position` | UDim2 | centered | The initial window position |
| `Accent` | Color3 | theme accent | The accent color for this window |
| `Theme` | string | `"Dark"` | The initial theme name |
| `Acrylic` | boolean | `true` | Whether to enable blur effects |
| `Transparency` | number | `0.05` | Background transparency (0-1) |
| `Draggable` | boolean | `true` | Whether the window is draggable |
| `Resizable` | boolean | `true` | Whether the window is resizable |
| `Minimizable` | boolean | `true` | Whether the window can be minimized |
| `Closable` | boolean | `true` | Whether the window can be closed |
| `PersistState` | boolean | `true` | Whether to save/restore state |

```lua
local Window = VoidUI:CreateWindow({
    Title = "My App",
    Subtitle = "v1.0",
    Accent = Color3.fromRGB(120, 80, 255),
})
```

The returned Window object has the following methods:

- `Window:CreateTab(name, icon)` — Creates a new tab and returns it
- `Window:Destroy()` — Destroys the window and all its contents
- `Window:Minimize()` — Minimizes the window
- `Window:Maximize()` — Maximizes the window
- `Window:Restore()` — Restores the window from minimized/maximized state
- `Window:SetTitle(title)` — Sets the window title
- `Window:SetSubtitle(subtitle)` — Sets the window subtitle
- `Window:Focus()` — Brings the window to the front

The Window object also has the following signals:

- `Window.OnClose` — Fired when the window is closed
- `Window.OnOpen` — Fired when the window is opened
- `Window.OnResize` — Fired when the window is resized
- `Window.OnFocus` — Fired when the window gains focus
- `Window.OnMinimize` — Fired when the window is minimized
- `Window.OnMaximize` — Fired when the window is maximized

### `VoidUI.DestroyWindow(window)`

Destroys a specific window instance and all its contents, removing it from the window manager.

```lua
VoidUI:DestroyWindow(myWindow)
```

### `VoidUI.DestroyAll()`

Destroys all active windows. This is useful for cleanup when your application is shutting down.

```lua
VoidUI:DestroyAll()
```

### `VoidUI.GetWindows()`

Returns a list of all active window instances.

```lua
for _, window in ipairs(VoidUI:GetWindows()) do
    print(window.Title)
end
```

### `VoidUI.GetActiveWindow()`

Returns the currently active (focused) window, or nil if no windows are active.

```lua
local active = VoidUI:GetActiveWindow()
```

## Notifications

These functions display notifications to the user.

### `VoidUI.Notify(config)`

Displays a notification with full configuration options.

```lua
VoidUI:Notify({
    Title = "Custom Notification",
    Description = "This is a custom notification.",
    Icon = "rbxassetid://iconId",
    Variant = "Info",       -- Info, Success, Warning, Error
    Duration = 5,           -- seconds, 0 for no auto-dismiss
})
```

### `VoidUI.NotifyInfo(title, description)`

Displays an info notification with the given title and description.

```lua
VoidUI:NotifyInfo("Update Available", "Version 1.1 is ready to download.")
```

### `VoidUI.NotifySuccess(title, description)`

Displays a success notification with a green accent.

```lua
VoidUI:NotifySuccess("Saved", "Your changes have been saved.")
```

### `VoidUI.NotifyWarning(title, description)`

Displays a warning notification with an amber accent.

```lua
VoidUI:NotifyWarning("Low Disk Space", "You have less than 1GB remaining.")
```

### `VoidUI.NotifyError(title, description)`

Displays an error notification with a red accent.

```lua
VoidUI:NotifyError("Connection Failed", "Could not connect to the server.")
```

### `VoidUI.ShowDialog(config)`

Displays a modal dialog with a title, message, and buttons. Returns a dialog object with `OnConfirm` and `OnCancel` signals.

```lua
VoidUI:ShowDialog({
    Title = "Confirm Deletion",
    Message = "Are you sure you want to delete this item? This action cannot be undone.",
    Variant = "Danger",
    Buttons = {"Cancel", "Delete"},
})
```

## Toasts

### `VoidUI.GetToasts()`

Returns the singleton Toasts manager instance.

### `VoidUI.Toast(title, description, variant, duration)`

Displays a compact toast notification.

```lua
VoidUI:Toast("Alert", "Something happened.", "Info", 3)
```

## Loading and Splash Screens

### `VoidUI.ShowLoadingScreen(config)`

Displays a full-screen loading overlay with a spinner.

```lua
local loader = VoidUI:ShowLoadingScreen({
    Title = "Loading",
    Subtitle = "Please wait...",
})
loader:SetProgress(50)
loader:SetProgress(100)
```

### `VoidUI.HideLoadingScreen()`

Hides the loading screen if one is currently visible.

### `VoidUI.ShowSplashScreen(config)`

Displays the branded splash screen with the VoidUI logo.

```lua
VoidUI:ShowSplashScreen({
    BrandName = "MyApp",
    Tagline = "The best app ever",
    Duration = 3,
})
```

### `VoidUI.ShowWelcomeScreen(config)`

Displays a multi-step welcome/onboarding screen.

```lua
local welcome = VoidUI:ShowWelcomeScreen({
    Steps = {
        {Icon = "icon", Title = "Welcome", Description = "Get started with VoidUI."},
        {Icon = "icon", Title = "Features", Description = "Explore the powerful features."},
        {Icon = "icon", Title = "Ready", Description = "You are all set!"},
    },
})
welcome.OnComplete:Connect(function()
    print("Onboarding complete!")
end)
```

## Internationalization

### `VoidUI.SetLanguage(lang)`

Sets the active language for the interface. Supported values are `"en-US"`, `"pt-BR"`, and `"es-ES"` (plus any custom languages added).

```lua
VoidUI:SetLanguage("pt-BR")
```

### `VoidUI.GetLanguage()`

Returns the current language code.

```lua
print(VoidUI:GetLanguage())  -- "en-US"
```

### `VoidUI.GetAvailableLanguages()`

Returns a list of all available language codes.

### `VoidUI.Translate(key)`

Translates a key string using the current language. Falls back to the key itself if no translation is found.

```lua
print(VoidUI:Translate("save_button"))
```

## Animation Control

### `VoidUI.ToggleAnimations(enabled)`

Enables or disables all animations globally. When disabled, components update instantly without transitions.

```lua
VoidUI:ToggleAnimations(false)
```

### `VoidUI.SetAnimationQuality(quality)`

Sets the animation quality level. Acceptable values are `"Low"`, `"Medium"`, and `"High"`. Higher quality uses more frames and smoother transitions.

```lua
VoidUI:SetAnimationQuality("High")
```

### `VoidUI.SetAnimationSpeed(speed)`

Sets the global animation speed multiplier. A value of 1 is normal speed, 0.5 is half speed, and 2 is double speed.

```lua
VoidUI:SetAnimationSpeed(1.5)
```

## Blur and Transparency

### `VoidUI.EnableBlur()`

Enables the acrylic blur effect behind windows.

### `VoidUI.DisableBlur()`

Disables the acrylic blur effect.

### `VoidUI.SetTransparency(transparency)`

Sets the background transparency level for windows. Accepts a value from 0 (fully opaque) to 1 (fully transparent).

```lua
VoidUI:SetTransparency(0.1)
```

## Component Factory

### `VoidUI.Create(componentType, config)`

Creates a standalone component of the given type with the provided configuration. This is useful for creating components outside of a window/section hierarchy, such as floating buttons, sidebars, or context menus.

```lua
local fab = VoidUI:Create("FloatingButton", {
    Icon = "rbxassetid://iconId",
    Position = "BottomRight",
    OnClick = function() print("FAB clicked") end,
})

local sidebar = VoidUI:Create("Sidebar", {
    Title = "Navigation",
    Items = {
        {Text = "Home", Icon = "icon"},
        {Text = "Settings", Icon = "icon"},
    },
})
```

The `componentType` parameter is a string matching the component name (e.g., `"Button"`, `"FloatingButton"`, `"Sidebar"`, `"Notification"`, etc.).

## Command Palette

### `VoidUI.GetCommandPalette()`

Returns the singleton CommandPalette instance, which provides a searchable command interface (opened with Ctrl+P by default).

### `VoidUI.RegisterCommand(command)`

Registers a custom command that appears in the command palette.

```lua
VoidUI:RegisterCommand({
    Name = "Save File",
    Shortcut = "Ctrl+S",
    Callback = function()
        print("Saving file...")
    end,
})
```

## Debug Console

### `VoidUI.GetConsole()`

Returns the singleton Console instance for developer logging.

### `VoidUI.Log(message)`

Logs a message to the debug console.

### `VoidUI.LogWarning(message)`

Logs a warning message to the debug console.

### `VoidUI.LogError(message)`

Logs an error message to the debug console.

## Import and Export

### `VoidUI.Export()`

Exports the current library state as a JSON-encodable table. This includes the theme name, accent color, window configurations, and saved component states.

```lua
local state = VoidUI:Export()
```

### `VoidUI.Import(config)`

Imports a previously exported state, restoring the theme, accent color, window configurations, and component states.

```lua
VoidUI:Import(savedState)
```

## Version Information

### `VoidUI.GetVersion()`

Returns the library version as a string.

```lua
print(VoidUI:GetVersion())  -- "1.0.0"
```

### `VoidUI.GetVersionInfo()`

Returns a table with detailed version information including version string, author, and license.

```lua
local info = VoidUI:GetVersionInfo()
print(info.Version, info.Author, info.License)
```

### `VoidUI.IsVersionAtLeast(version)`

Returns a boolean indicating whether the current library version is at least the specified version. Useful for compatibility checks.

```lua
if VoidUI:IsVersionAtLeast("1.0.0") then
    print("Version is compatible")
end
```

## Plugin System

### `VoidUI.RegisterPlugin(name, initFunction)`

Registers a plugin with the given name. The `initFunction` is called with a plugin API object that provides access to the library's core functionality.

```lua
VoidUI:RegisterPlugin("MyPlugin", function(api)
    api.RegisterComponent("MyWidget", function(config)
        -- Create a custom component
    end)
    api.RegisterTheme("MyTheme", { ... })
    api.On("Update", function() end)
    api.Log("Plugin initialized")
end)
```

The plugin API object provides the following methods:

- `api.RegisterComponent(name, factory)` — Register a custom component type
- `api.RegisterTheme(name, data)` — Register a custom theme
- `api.On(hookName, callback)` — Listen for lifecycle hooks (Init, Update, Destroy, ThemeChanged, LanguageChanged, WindowCreated)
- `api.Utils` — Access to the Utils table
- `api.Color` — Access to color utilities
- `api.Create` — Access to the Instance creation helper
- `api.Tween` — Access to the tween helper
- `api.GetTheme()` — Get the current theme
- `api.Log(message)` — Log a message

### `VoidUI.UnregisterPlugin(name)`

Unregisters a plugin by name, cleaning up its resources and hooks.

### `VoidUI.ListPlugins()`

Returns a list of all registered plugin names.

## Lifecycle

### `VoidUI.Update()`

Triggers a manual update of all components and fires the `Update` hook for all plugins. This is called automatically by the library but can be invoked manually if needed.

### `VoidUI.Destroy()`

Destroys all windows, components, and resources managed by the library. This is the proper cleanup function to call when your application is shutting down.

```lua
VoidUI:Destroy()
```
