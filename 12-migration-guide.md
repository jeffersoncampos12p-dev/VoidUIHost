# Migration Guide

This document helps you migrate from other UI libraries to VoidUI. It covers the most common patterns and provides side-by-side comparisons to make the transition as smooth as possible.

## General Migration Philosophy

VoidUI was designed to be intuitive and familiar to developers who have used other Lua UI libraries. While the API is entirely original, the concepts of windows, tabs, sections, and components are standard patterns that are easy to map from other libraries. The key differences are in the naming conventions, configuration patterns, and the additional features that VoidUI provides.

## From WindUI

WindUI was a major inspiration for VoidUI's organizational concepts, so the migration path is relatively straightforward. The main differences are in the visual identity, the expanded component set, and the additional systems (i18n, plugins, command palette).

### Window Creation

In WindUI, you might create a window like this:

```lua
local Window = WindUI:CreateWindow({
    Title = "My App",
    Icon = "rbxassetid://iconId",
})
```

In VoidUI, the equivalent is:

```lua
local Window = VoidUI:CreateWindow({
    Title = "My App",
    Subtitle = "Powered by VoidUI",
    Accent = Color3.fromRGB(120, 80, 255),
})
```

The key differences are that VoidUI uses `Subtitle` instead of additional title options, adds `Accent` for per-window accent color, and provides many more configuration options including `Acrylic`, `Transparency`, `MinSize`, `PersistState`, and more.

### Tab Creation

In WindUI:

```lua
local Tab = Window:CreateTab("Home", "icon")
```

In VoidUI:

```lua
local Tab = Window:CreateTab("Home", "rbxassetid://iconId")
```

The interface is nearly identical. VoidUI also supports SubTabs for additional navigation levels:

```lua
local SubTab = Tab:CreateSubTab("General", "rbxassetid://iconId")
```

### Section Creation

In WindUI:

```lua
local Section = Tab:CreateSection("Settings")
```

In VoidUI:

```lua
local Section = Tab:CreateSection("Settings", {
    Collapsible = true,
    Expanded = true,
})
```

VoidUI adds optional configuration for collapsible behavior and side positioning.

### Component Creation

The component creation pattern is similar across libraries. In WindUI:

```lua
Tab:CreateButton({
    Title = "Click Me",
    Callback = function() end,
})
```

In VoidUI:

```lua
Section:CreateButton({
    Text = "Click Me",
    Style = "Primary",
    Callback = function() end,
})
```

The main differences are that VoidUI uses `Text` instead of `Title` for component labels, and adds `Style` for button variants. Components are created on sections rather than tabs directly in VoidUI, which provides better organization.

### Theme Management

WindUI typically manages themes through configuration at the window level. In VoidUI, themes are managed globally:

```lua
VoidUI:SetTheme("Dark")
VoidUI:SetAccent(Color3.fromRGB(120, 80, 255))
```

This allows consistent theming across all windows and components.

## From Other Libraries

If you are migrating from other UI libraries, the general pattern is similar:

1. **Load the library** — Replace your current library load call with the VoidUI load call
2. **Create a window** — Use `VoidUI:CreateWindow(config)` with the appropriate options
3. **Create tabs** — Use `Window:CreateTab(name, icon)` for each tab
4. **Create sections** — Use `Tab:CreateSection(title, options)` for each section
5. **Add components** — Use the section's `Create*` methods with configuration tables
6. **Connect callbacks** — Use the `Callback` parameter or connect to signals directly

### Configuration Mapping

Here is a general mapping of common configuration options:

| Other Libraries | VoidUI | Notes |
|----------------|--------|-------|
| `Title` (for components) | `Text` | VoidUI uses `Text` for component labels |
| `Callback` | `Callback` | Same pattern |
| `Default` | `Default` | Same pattern |
| `Options` | `Options` | Same pattern for dropdowns |
| `Min`, `Max` | `Min`, `Max` | Same for sliders |
| N/A | `Style` | Button style variants (new in VoidUI) |
| N/A | `Description` | Optional description text (new in VoidUI) |

### Events Mapping

In other libraries, you might use callback parameters only. In VoidUI, every component also has signals:

| Other Libraries | VoidUI | Notes |
|----------------|--------|-------|
| `Callback` parameter | `Callback` + signals | Signals provide additional control |
| N/A | `OnClick`, `OnChanged`, etc. | Direct signal connections |

## Key Advantages of VoidUI

When migrating, you will gain access to several features that may not be available in your current library:

1. **Six built-in themes** with custom theme creation and runtime switching
2. **Internationalization** with three languages out of the box
3. **Plugin system** for extending the library with custom components and hooks
4. **Command palette** for keyboard-driven command access
5. **Developer console and log viewer** for debugging
6. **State persistence** with export and import
7. **Animation control** with quality and speed settings
8. **Over fifty components** covering virtually every UI need
9. **Window management** with multi-window support, docking, and tab reordering
10. **Modern visual design** with blur effects, gradients, and micro-animations

## Tips for a Smooth Migration

Start by creating a new window and a single tab with a few basic components to get familiar with the API. Once you are comfortable with the basic patterns, gradually migrate your existing components one section at a time. Take advantage of the additional features like themes and notifications to enhance your interface. Use the Export/Import system to persist user settings between sessions. If you have custom components in your current library, consider creating a VoidUI plugin to register them.

Remember that VoidUI is designed to be more than just a replacement — it is an upgrade. Take the time to explore the full API and component set to get the most out of the library.
