# Plugins & Extensions

VoidUI includes a powerful plugin and extension system that allows third-party developers to extend the library with custom components, themes, commands, and lifecycle hooks. This document explains how to create and register plugins.

## Overview

The plugin system provides a sandboxed API that plugins receive when they are initialized. This API gives plugins access to a curated set of library functionality without exposing the entire internal structure. Plugins can register new component types, register themes, listen for lifecycle hooks, and access utility functions.

The plugin system follows a hook-based architecture. Plugins register callback functions for specific lifecycle events, and the library calls these callbacks at the appropriate times. This allows plugins to react to events like initialization, theme changes, language changes, window creation, and destruction.

## Registering a Plugin

Plugins are registered using the `RegisterPlugin` function. The function takes a name (which must be unique) and an initialization function. The initialization function is called immediately with the plugin API object.

```lua
VoidUI:RegisterPlugin("MyCustomPlugin", function(api)
    -- The api object provides access to library functionality
    api.Log("MyCustomPlugin initialized")
    
    -- Register a custom component
    api.RegisterComponent("MyWidget", function(config)
        local widget = {
            Text = config.Text or "Widget",
            Value = config.Default or 0,
        }
        function widget:SetValue(value)
            self.Value = value
            if self.OnChanged then
                self.OnChanged:Fire(value)
            end
        end
        return widget
    end)
    
    -- Listen for lifecycle hooks
    api.On("ThemeChanged", function(themeName)
        api.Log("Theme changed to: " .. themeName)
    end)
    
    api.On("Destroy", function()
        api.Log("MyCustomPlugin destroyed")
    end)
end)
```

## The Plugin API

The plugin API object provides the following methods and properties:

### `api.RegisterComponent(name, factory)`

Registers a new component type that can be created using `VoidUI:Create(name, config)` or through the `VoidUI.Components` table. The `factory` is a function that receives a configuration table and returns a component object.

```lua
api.RegisterComponent("MyWidget", function(config)
    -- Create and return your custom component
    local component = {}
    component.Text = config.Text or "Default"
    function component:SetText(text)
        self.Text = text
    end
    return component
end)
```

Once registered, the component can be created:

```lua
local widget = VoidUI:Create("MyWidget", { Text = "Hello" })
```

### `api.RegisterTheme(name, data)`

Registers a custom theme that can be used with `VoidUI:SetTheme(name)`. The `data` parameter is a theme table with color values.

```lua
api.RegisterTheme("NeonPurple", {
    Background = Color3.fromRGB(20, 10, 30),
    Text = Color3.fromRGB(230, 210, 255),
    Accent = Color3.fromRGB(180, 80, 255),
    -- ... other theme properties
})
```

### `api.On(hookName, callback)`

Registers a callback for a lifecycle hook. The following hooks are available:

- `"Init"` — Fired when the library is initialized (before your plugin is loaded)
- `"Update"` — Fired on each update cycle
- `"Destroy"` — Fired when the library is being destroyed
- `"ThemeChanged"` — Fired when the theme changes; receives the new theme name
- `"LanguageChanged"` — Fired when the language changes; receives the new language code
- `"WindowCreated"` — Fired when a new window is created; receives the window object

```lua
api.On("ThemeChanged", function(themeName)
    api.Log("Theme changed to: " .. themeName)
end)

api.On("WindowCreated", function(window)
    api.Log("New window created: " .. (window.Title or "Untitled"))
end)
```

### `api.Utils`

Access to the VoidCore Utils table, which contains helper functions like `GenerateId`, `DeepClone`, `Merge`, `Round`, `Clamp`, `Lerp`, `LerpColor`, `EncodeJSON`, `DecodeJSON`, `FormatNumber`, `Truncate`, and more.

```lua
local id = api.Utils.GenerateId()
local rounded = api.Utils.Round(3.14159, 2)  -- 3.14
local clamped = api.Utils.Clamp(150, 0, 100)  -- 100
```

### `api.Color`

Access to color utility functions for manipulating Color3 values.

### `api.Create`

Access to the Roblox Instance creation helper function, which simplifies creating UI elements with properties.

### `api.Tween`

Access to the tween helper function for creating smooth animations.

### `api.GetTheme()`

Returns the current theme table.

```lua
local theme = api.GetTheme()
print(theme.Background, theme.Accent)
```

### `api.Log(message)`

Logs a message to the debug console with the plugin name as a prefix.

```lua
api.Log("Doing something important...")
```

## Managing Plugins

### `VoidUI.UnregisterPlugin(name)`

Unregisters a plugin by name. This removes all its hooks and resources. The plugin's `Destroy` hook is called before it is removed.

```lua
VoidUI:UnregisterPlugin("MyCustomPlugin")
```

### `VoidUI.ListPlugins()`

Returns a list of all registered plugin names.

```lua
for _, name in ipairs(VoidUI:ListPlugins()) do
    print(name)
end
```

## Plugin Best Practices

Use a unique, descriptive name for your plugin to avoid conflicts with other plugins. A common convention is to use a prefix that identifies the author or organization, such as `"NinjaTech:MyPlugin"` or `"MyApp:Extensions"`.

Always clean up resources in the `Destroy` hook. If your plugin creates any Roblox instances, connections, or other resources, make sure to clean them up when the `Destroy` hook is called. This prevents memory leaks and ensures clean unloading.

Handle errors gracefully in your plugin code. Since plugins run in the same environment as the library, an unhandled error in a plugin could affect the entire application. Wrap potentially failing operations in `pcall` and log errors through the `api.Log` function.

Keep plugins focused and minimal. A plugin should do one thing well rather than trying to be a comprehensive solution. This makes plugins easier to maintain, test, and compose with other plugins.

Document your plugin's API and the components it registers. If your plugin registers custom components, provide documentation for the component's configuration options, methods, and signals so that users of your plugin know how to use it.
