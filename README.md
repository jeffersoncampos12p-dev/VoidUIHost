# VoidUI — Examples

This directory contains example scripts that demonstrate how to use VoidUI's features and components.

## Examples

| File | Description |
|------|-------------|
| `complete_example.lua` | A complete application showcasing all major components, themes, notifications, events, and state persistence |
| `settings_panel.lua` | A focused settings panel with toggles, sliders, dropdowns, color picker, keybind, and config export |
| `custom_theme.lua` | Creating and applying custom themes (Ocean Breeze, Rose Gold, Matrix) with live theme switching |
| `plugin_example.lua` | Plugin system demo with a custom "RatingStars" component and custom "Aurora" theme |
| `loading_screen.lua` | Loading screens, splash screens, and multi-step welcome/onboarding screens |
| `notifications_and_dialogs.lua` | Notification types, toasts, confirmation dialogs, and context menus |
| `data_components.lua` | DataTable, List, TreeView, Accordion, Breadcrumb, Pagination, StatusIndicators, and Badges |

## Running Examples

### Prerequisites
- A Roblox executor environment that supports `game:HttpGet` and `CoreGui`
- VoidUI loaded via loadstring (included in each example)

### Quick Start

1. Open your Roblox executor
2. Load any example script (e.g., `complete_example.lua`)
3. The VoidUI window will appear with all components ready to use

### Loading a Specific Example

```lua
-- Load the complete example
loadstring(game:HttpGet("https://voidui.dev/examples/complete_example.lua"))()

-- Or copy and paste the code from any example file
```

## Key Concepts Demonstrated

- **Window creation** with tabs, sections, and components
- **Component configuration** with callbacks and events
- **Theme switching** with built-in and custom themes
- **Notifications** and dialog systems
- **State persistence** with import/export
- **Plugin system** with custom components and themes
- **Data display** components like tables, lists, and trees
- **Loading screens** and onboarding flows

## Notes

- All examples assume VoidUI is loaded via loadstring from the official URL
- Examples are self-contained and can be run independently
- Modify the configurations to experiment with different options
- Check the [documentation](../docs/) for detailed API references
