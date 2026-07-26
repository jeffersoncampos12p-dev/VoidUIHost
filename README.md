# VoidUI

<div align="center">

![VoidUI Logo](assets/logo.png)

**The most modern, elegant, and complete UI library for Lua/LuaU**

[![Version](https://img.shields.io/badge/version-1.0.0-7850ff)]()
[![License](https://img.shields.io/badge/license-MIT-28c840)]()
[![LuaU](https://img.shields.io/badge/LuaU-compatible-64c8ff)]()
[![Components](https://img.shields.io/badge/components-50%2B-7850ff)]()
[![Themes](https://img.shields.io/badge/themes-6-7850ff)]()
[![Languages](https://img.shields.io/badge/i18n-3-64c8ff)]()

</div>

---

## Overview

VoidUI is a modern, elegant, and complete UI library for Lua/LuaU, designed for building premium user interfaces in the Roblox environment. Built entirely from scratch with an original architecture, visual identity, and API, VoidUI provides 50+ components, 6 built-in themes, 3 language packs, a full plugin system, and comprehensive documentation.

## Features

- **50+ Components** — Window, Tab, Section, Button, Toggle, Slider, Dropdown, ColorPicker, Keybind, DataTable, TreeView, Accordion, Command Palette, Terminal, and many more
- **6 Built-in Themes** — Dark, Light, Midnight, Sunset, Forest, and Cyber, plus full custom theme support
- **3 Languages** — English (en-US), Portuguese (pt-BR), and Spanish (es-ES) with full i18n system
- **Modern Animations** — Ripple effects, glow effects, hover/press animations, smooth tweens, and object pooling
- **Plugin System** — Register custom components, themes, and lifecycle hooks
- **Developer Tools** — Command Palette, Terminal, Console, and LogViewer
- **Event System** — Signal-based events, Promises, keybind system, and auto-disconnect
- **State Persistence** — Save and restore UI configuration with StateManager
- **Comprehensive Documentation** — 16 documentation files covering everything from installation to troubleshooting

## Installation

### Method 1: Loadstring (Recommended)

```lua
local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()
```

### Method 2: Local Script

Download the source code and load it from a local file:

```lua
local VoidUI = loadstring(readfile("VoidUI/VoidUI.lua"))()
```

### Method 3: Roblox Model

Import the VoidUI model from the toolbox and require it:

```lua
local VoidUI = require(script.Parent.VoidUI)
```

## Quick Start

```lua
local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

local Window = VoidUI:CreateWindow({
    Title = "My Application",
    Theme = "Dark",
    Size = Vector2.new(580, 460),
})

local Tab = Window:AddTab({ Title = "Home" })
local Section = Tab:AddSection({ Title = "Settings" })

Section:AddButton({
    Text = "Click Me!",
    Style = "Primary",
    OnClick = function()
        VoidUI:NotifySuccess({ Title = "Hello!", Description = "Button was clicked!" })
    end,
})

Section:AddToggle({
    Text = "Enable Feature",
    Default = true,
    OnChanged = function(value)
        print("Feature enabled:", value)
    end,
})

Section:AddSlider({
    Text = "Volume",
    Min = 0, Max = 100, Default = 50, Suffix = "%",
    OnChanged = function(value)
        print("Volume:", value)
    end,
})
```

## Project Structure

```
VoidUI/
├── assets/                 # Visual identity assets
│   └── logo.png            # VoidUI logo
├── docs/                   # Documentation (16 files)
│   ├── README.md           # Documentation index
│   ├── 01-installation.md
│   ├── 02-getting-started.md
│   ├── 03-api-reference.md
│   ├── 04-components.md
│   ├── 05-themes.md
│   ├── 06-events-and-callbacks.md
│   ├── 07-i18n.md
│   ├── 08-plugins.md
│   ├── 09-examples.md
│   ├── 10-faq.md
│   ├── 11-changelog.md
│   ├── 12-migration-guide.md
│   ├── 13-best-practices.md
│   ├── 14-troubleshooting.md
│   └── 15-license-and-credits.md
├── examples/               # Example scripts
│   ├── README.md
│   ├── complete_example.lua
│   ├── settings_panel.lua
│   ├── custom_theme.lua
│   ├── plugin_example.lua
│   ├── loading_screen.lua
│   ├── notifications_and_dialogs.lua
│   └── data_components.lua
├── src/                    # Source code (65 Lua files)
│   ├── VoidUI.lua          # Main loader with global API
│   ├── core/               # Core modules
│   │   └── VoidCore.lua    # Signal, Promise, Object, Utils, StateManager
│   ├── theme/              # Theme system
│   │   └── ThemeSystem.lua
│   ├── animation/          # Animation system
│   │   └── AnimationSystem.lua
│   ├── events/             # Event system
│   │   └── EventSystem.lua
│   ├── utils/              # Utilities
│   │   └── i18n.lua        # Internationalization
│   ├── plugins/            # Plugin system
│   │   └── PluginSystem.lua
│   └── components/         # All 50+ components
│       ├── Component.lua   # Base component class
│       ├── Window.lua
│       ├── Tab.lua
│       ├── Section.lua
│       ├── SubTab.lua
│       ├── GroupBox.lua
│       ├── Button.lua
│       ├── Toggle.lua
│       ├── Checkbox.lua
│       ├── Slider.lua
│       ├── Dropdown.lua
│       ├── MultiDropdown.lua
│       ├── ColorPicker.lua
│       ├── Keybind.lua
│       ├── Textbox.lua
│       ├── Input.lua
│       ├── PasswordInput.lua
│       ├── SearchBox.lua
│       ├── CodeEditor.lua
│       ├── Notification.lua
│       ├── Dialog.lua
│       ├── Modal.lua
│       ├── Tooltip.lua
│       ├── LoadingScreen.lua
│       ├── SplashScreen.lua
│       ├── WelcomeScreen.lua
│       ├── Badge.lua
│       ├── ProgressBar.lua
│       ├── Card.lua
│       ├── Avatar.lua
│       ├── Image.lua
│       ├── VideoPreview.lua
│       ├── Label.lua
│       ├── Paragraph.lua
│       ├── Divider.lua
│       ├── Spacer.lua
│       ├── Accordion.lua
│       ├── TreeView.lua
│       ├── List.lua
│       ├── DataTable.lua
│       ├── StatusIndicator.lua
│       ├── Chip.lua
│       ├── Tag.lua
│       ├── Breadcrumb.lua
│       ├── Pagination.lua
│       ├── FloatingButton.lua
│       ├── Sidebar.lua
│       ├── Navbar.lua
│       ├── ContextMenu.lua
│       ├── RightClickMenu.lua
│       ├── TabsReorder.lua
│       ├── WindowManager.lua
│       ├── DockingSystem.lua
│       ├── Toasts.lua
│       ├── CommandPalette.lua
│       ├── Terminal.lua
│       ├── Console.lua
│       └── LogViewer.lua
├── website/                # Official website
│   ├── index.html          # Landing page
│   ├── docs.html           # Documentation page
│   ├── showcase.html       # Showcase page
│   ├── playground.html     # Interactive playground
│   ├── changelog.html      # Changelog page
│   ├── faq.html            # FAQ page
│   └── assets/
│       └── style.css       # Website styling
├── todo.md                 # Development plan
└── README.md               # This file
```

## Documentation

Full documentation is available in the [docs/](docs/) directory or on the [official website](https://voidui.pages.dev).

Key documentation:
- [Installation Guide](docs/01-installation.md)
- [Getting Started](docs/02-getting-started.md)
- [API Reference](docs/03-api-reference.md)
- [Components Reference](docs/04-components.md)
- [Themes](docs/05-themes.md)
- [Events & Callbacks](docs/06-events-and-callbacks.md)
- [Plugins](docs/08-plugins.md)
- [Examples](docs/09-examples.md)
- [FAQ](docs/10-faq.md)
- [Best Practices](docs/13-best-practices.md)
- [Troubleshooting](docs/14-troubleshooting.md)

## Examples

See the [examples/](examples/) directory for complete working examples:

- **Complete Example** — All components in one application
- **Settings Panel** — Toggles, sliders, dropdowns, config
- **Custom Theme** — Creating and applying custom themes
- **Plugin Example** — Custom components and themes via plugin system
- **Loading Screen** — Loading, splash, and welcome screens
- **Notifications & Dialogs** — All notification types and dialogs
- **Data Components** — DataTable, List, TreeView, Accordion

## Themes

VoidUI includes 6 built-in themes:

| Theme | Description |
|-------|-------------|
| Dark | Default theme with deep dark backgrounds and purple accent |
| Light | Clean light theme with soft shadows |
| Midnight | Ultra-dark theme with blue undertones |
| Sunset | Warm theme with orange and pink accents |
| Forest | Nature-inspired with green accents |
| Cyber | Neon cyberpunk with vibrant colors |

```lua
-- Switch themes
VoidUI:SetTheme("Light")

-- Create custom theme
VoidUI:CreateTheme("MyTheme", {
    Background = Color3.fromRGB(18, 18, 28),
    Surface = Color3.fromRGB(24, 24, 38),
    -- ... full color palette
})
VoidUI:SetTheme("MyTheme")

-- Set just the accent color
VoidUI:SetAccent(Color3.fromRGB(0, 200, 255))
```

## License

VoidUI is released under the [MIT License](docs/15-license-and-credits.md).

```
MIT License

Copyright (c) 2026 NinjaTech AI Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

## Credits

- **Developer:** NinjaTech AI Team
- **Inspiration:** WindUI (organizational concepts), modern web/desktop UI design
- **Technologies:** Lua, LuaU, Roblox services

## Links

- [Website](https://voidui.pages.dev)
- [Documentation](docs/)
- [Examples](examples/)
- [Changelog](docs/11-changelog.md)
- [FAQ](docs/10-faq.md)

---

<div align="center">

**VoidUI** — Built with passion for the Lua community.

© 2026 NinjaTech AI Team. MIT License.

</div>
