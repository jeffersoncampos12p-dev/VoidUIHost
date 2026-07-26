# VoidUI — Modern UI Library for Lua/LuaU

<div align="center">

**Version 1.0.0** | MIT License | By NinjaTech AI Team

A complete, modular, and elegant UI library inspired by modern design principles.
Built for performance, extensibility, and beauty.

</div>

---

## What is VoidUI?

VoidUI is a comprehensive user interface library for the Lua/LuaU scripting environment, designed to be one of the most modern, elegant, and complete UI libraries available. It provides over fifty reusable components, a powerful theming system, a fluid animation engine, an internationalization layer, a plugin architecture, and a full event-driven callback system — all wrapped in a clean, intuitive API that prioritizes developer experience without sacrificing flexibility or performance.

The library was conceived with a singular vision: to bring the polish and sophistication of modern web and desktop UI frameworks into the Lua scripting world. Every component has been carefully designed with soft borders, rounded corners, subtle shadows, blur effects, micro-animations, and a restrained color palette that together create an interface that feels premium and refined rather than utilitarian. The visual identity is entirely original, drawing inspiration from contemporary design trends without copying any existing library.

## Key Features

VoidUI ships with an extensive set of capabilities that cover virtually every UI need. The core library includes a signal-based event system for clean callback management, a Promise implementation for asynchronous workflows, an object-oriented base class pattern for consistent component architecture, and a comprehensive set of utility functions for common operations like JSON encoding, color manipulation, number formatting, and deep cloning.

The theming system provides six built-in themes (Dark, Light, Midnight, Sunset, Forest, and Cyber) with full support for custom theme creation, export, import, and runtime switching. Every component automatically responds to theme changes, and the accent color can be customized independently. The animation system offers tween helpers, ripple effects with object pooling, glow effects, hover and press states, pulse animations, shake effects, spinners, bounce, and sweep — all configurable through a global animation quality and speed setting.

The internationalization system supports English (en-US), Portuguese (pt-BR), and Spanish (es-ES) out of the box, with the ability to add additional languages at runtime. The plugin and extension system allows third-party developers to register custom components, themes, commands, and lifecycle hooks. State persistence is handled through a StateManager that saves and loads configuration via JSON file I/O. A command palette, developer console, terminal emulator, and log viewer round out the developer tooling.

## Component Catalog

VoidUI includes over fifty components organized into logical categories. The core structural components include Window, Tab, SubTab, Section, and GroupBox for organizing your interface hierarchy. Input components include Button, Toggle, Checkbox, Slider, Dropdown, MultiDropdown, ColorPicker, Keybind, Textbox, Input, PasswordInput, SearchBox, and CodeEditor for collecting user input. Feedback components include Notification, Dialog, Modal, Tooltip, Badge, ProgressBar, and LoadingScreen for communicating state and progress.

Display components include SplashScreen, WelcomeScreen, Card, Avatar, Image, VideoPreview, Divider, and Spacer for presenting content. Complex data components include Accordion, TreeView, List, DataTable, StatusIndicator, Chip, Tag, Breadcrumb, and Pagination for organizing and navigating structured information. Navigation components include FloatingButton, Sidebar, Navbar, ContextMenu, and RightClickMenu for application navigation patterns. Window management components include WindowManager, DockingSystem, and TabsReorder for managing multiple windows and their layout. Developer tooling components include Toasts, CommandPalette, Terminal, Console, and LogViewer for building developer-facing interfaces.

## Quick Start

Getting started with VoidUI takes just a few lines of code. The library is loaded via a single function call, after which you can create a window, add tabs and sections, and populate them with any of the available components.

```lua
local VoidUI = loadstring(game:HttpGet(URL))()

local Window = VoidUI:CreateWindow({
    Title = "My Application",
    Subtitle = "Powered by VoidUI",
})

local Tab = Window:CreateTab("Home", "rbxassetid://iconId")

local Section = Tab:CreateSection("Settings")

Section:CreateButton({
    Text = "Click Me",
    Callback = function()
        print("Hello from VoidUI!")
    end,
})

Section:CreateToggle({
    Text = "Enable Feature",
    Default = false,
    Callback = function(value)
        print("Feature is now:", value)
    end,
})
```

## Architecture Overview

VoidUI is built on a modular architecture where each concern is handled by a dedicated module. The core utilities module (VoidCore) provides the foundational building blocks: the Signal class for event-driven communication, the Promise class for asynchronous operations, the Object base class for object-oriented patterns, and a comprehensive Utils table with helper functions. The theme system, animation system, event system, and i18n system each live in their own modules, while every component is implemented as a separate file that extends the base Component class.

All components follow a consistent pattern: they are created through a factory function, they implement a `_createUI` method that builds their visual representation using Roblox Instance objects, they implement an `_applyThemeImpl` method that applies the current theme, and they expose setter methods for runtime configuration. Components emit signals that can be connected to using the `:Connect` method, and they automatically clean up their resources when destroyed.

## Documentation Index

The full documentation is organized into the following sections, each covering a specific aspect of the library:

1. **Installation** — How to install and load VoidUI in your project
2. **Getting Started** — A guided walkthrough of creating your first VoidUI interface
3. **API Reference** — Complete reference for the global VoidUI API
4. **Components** — Detailed documentation for every component
5. **Themes** — How to use, create, and customize themes
6. **Events & Callbacks** — The signal system, promises, and event patterns
7. **Internationalization** — Multi-language support and adding translations
8. **Plugins & Extensions** — Extending VoidUI with custom components and hooks
9. **Examples** — A collection of practical examples and use cases
10. **FAQ** — Frequently asked questions
11. **Changelog** — Version history and changes
12. **Migration Guide** — Upgrading from other libraries to VoidUI
13. **Best Practices** — Recommended patterns and conventions
14. **Troubleshooting** — Common issues and solutions
15. **License & Credits** — Licensing information and acknowledgments

## License

VoidUI is released under the MIT License. See the [License & Credits](./15-license-and-credits.md) document for full details.
