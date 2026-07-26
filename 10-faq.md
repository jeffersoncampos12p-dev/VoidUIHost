# FAQ — Frequently Asked Questions

This document answers the most common questions about VoidUI.

## General

### What is VoidUI?

VoidUI is a comprehensive, modern UI library for Lua/LuaU that provides over fifty reusable components, a theming system, an animation engine, internationalization support, a plugin architecture, and a full event-driven callback system. It is designed to be the most elegant and complete UI library available for the Lua scripting environment.

### Is VoidUI free to use?

Yes, VoidUI is released under the MIT License, which means it is free to use, modify, and distribute for both personal and commercial projects. See the License & Credits document for full details.

### What environments does VoidUI support?

VoidUI is designed for the Roblox Lua/LuaU environment and uses Roblox services and Instance system for its GUI components. The utility functions, signal system, and promise system can be used in any Lua environment, but the visual components require the Roblox runtime.

### How many components does VoidUI include?

VoidUI includes over fifty components organized into categories: structural (Window, Tab, SubTab, Section, GroupBox), input (Button, Toggle, Checkbox, Slider, Dropdown, MultiDropdown, ColorPicker, Keybind, Textbox, Input, PasswordInput, SearchBox, CodeEditor), feedback (Notification, Dialog, Modal, Tooltip, Badge, ProgressBar, LoadingScreen), display (SplashScreen, WelcomeScreen, Card, Avatar, Image, VideoPreview, Divider, Spacer), complex data (Accordion, TreeView, List, DataTable, StatusIndicator, Chip, Tag, Breadcrumb, Pagination), navigation (FloatingButton, Sidebar, Navbar, ContextMenu, RightClickMenu), window management (WindowManager, DockingSystem, TabsReorder), and developer tooling (Toasts, CommandPalette, Terminal, Console, LogViewer).

## Usage

### How do I load VoidUI?

You load VoidUI using a loadstring call that fetches and executes the library, or by requiring a local copy of the source. See the Installation guide for details.

### Can I use VoidUI without a window?

Yes, you can use the utility functions, signals, promises, and standalone components (like FloatingButton, Sidebar, ContextMenu) without creating a window. Use `VoidUI:Create("ComponentType", config)` to create standalone components.

### How do I create a custom theme?

Use the `VoidUI:CreateTheme(name, data)` function to register a custom theme, then `VoidUI:SetTheme(name)` to apply it. See the Themes documentation for details on the required theme properties.

### Can I add my own language?

Yes, use the `i18n.AddLanguage(code, translations)` function to add a new language, then `VoidUI:SetLanguage(code)` to use it. See the Internationalization documentation for details.

### How do I persist the user's settings?

Use `VoidUI:Export()` to get the current state as a table, save it to your preferred storage (file, DataStore, etc.), and use `VoidUI:Import(state)` to restore it later. See the Getting Started guide for an example.

## Components

### How do I handle button clicks?

You can use the `Callback` parameter in the button configuration, or connect to the `OnClick` signal directly:

```lua
Section:CreateButton({
    Text = "Click Me",
    Callback = function() print("Clicked!") end,
})

-- Or:
button.OnClick:Connect(function() print("Clicked!") end)
```

### Can I disable a component?

Yes, most components accept a `Disabled` option in their configuration, and many have a `SetDisabled` method to toggle the disabled state at runtime.

### How do I get the current value of a component?

Each value-holding component has a `GetValue` method. For example, `toggle:GetValue()`, `slider:GetValue()`, `dropdown:GetValue()`, `colorPicker:GetColor()`.

### Can I create multiple windows?

Yes, you can create multiple windows using `VoidUI:CreateWindow(config)` multiple times. The WindowManager handles focus management and z-ordering between windows. Use `VoidUI:GetWindows()` to get all windows and `VoidUI:GetActiveWindow()` to get the focused one.

## Performance

### Does VoidUI impact performance?

VoidUI is designed with performance in mind. The animation system uses object pooling for ripple effects to prevent memory leaks, tweens are used efficiently, and the theme system only updates components that are currently visible. You can further optimize by disabling animations with `VoidUI:ToggleAnimations(false)` or reducing the animation quality with `VoidUI:SetAnimationQuality("Low")`.

### How do I clean up resources?

Use `VoidUI:Destroy()` to clean up all library resources, or `window:Destroy()` to destroy a specific window. Component signals are automatically disconnected when components are destroyed, but you should disconnect any connections you create yourself.

## Compatibility

### Can I use VoidUI alongside other UI libraries?

Yes, VoidUI uses unique naming for its internal instances and a self-contained architecture. However, you should be careful about conflicts with global variables and ensure that the library is loaded only once.

### Does VoidUI work on mobile?

VoidUI is designed primarily for desktop environments with keyboard and mouse input. Some components (like keybind, terminal) may not work well on touch devices. However, the basic components (buttons, toggles, sliders, dropdowns) work fine on touch interfaces.

### Is VoidUI compatible with Rojo or other build tools?

Yes, VoidUI is a pure Lua library with no external dependencies. It works with any Lua/LuaU build tool or framework as long as the Roblox runtime is available.

## Troubleshooting

### My components are not showing

Make sure you have created a window, tab, and section before adding components. Components are added to sections, which are added to tabs, which are added to windows. Also ensure the window is visible and not minimized.

### My theme is not applying

Make sure you are using a valid theme name from `VoidUI:ListThemes()`. If you created a custom theme, make sure it was registered with `VoidUI:CreateTheme()` before calling `VoidUI:SetTheme()`.

### My notifications are not appearing

Notifications appear in a corner of the screen. Make sure the notification system is not blocked by other UI elements. Also check the `Duration` parameter — a duration of 0 means the notification will not auto-dismiss but will appear immediately.

### How do I report a bug?

If you encounter a bug, please report it on the project's GitHub repository with a clear description of the issue, steps to reproduce it, and the version of VoidUI you are using.
