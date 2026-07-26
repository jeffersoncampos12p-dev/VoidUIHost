# Changelog

All notable changes to VoidUI are documented in this file. The format is based on semantic versioning, and each release documents the changes that were made.

## Version 1.0.0 (Initial Release)

This is the initial release of VoidUI, a complete, modular, and elegant UI library for Lua/LuaU. This release includes the full core library, comprehensive documentation, and the complete component suite.

### Added

**Core Library:**
- VoidCore module with Signal class, Promise class, Object base class, Utils table, Color utilities, and StateManager for state persistence
- Theme system with six built-in themes (Dark, Light, Midnight, Sunset, Forest, Cyber), custom theme creation, theme export and import, and accent color management
- Animation system with tween helpers, ripple effects with object pooling, glow effects, hover and press states, pulse animations, shake effects, spinners, bounce, and sweep animations
- Event system with global event dispatcher and keybind management
- i18n system with English (en-US), Portuguese (pt-BR), and Spanish (es-ES) translations, custom language support, and language change events
- Plugin and extension system with component registration, theme registration, lifecycle hooks, and a sandboxed plugin API

**Structural Components:**
- Window with draggable, resizable, minimizable, and closable behavior, acrylic blur, tab navigation, and state persistence
- Tab with icon support and content area
- SubTab for nested navigation levels
- Section with collapsible behavior and side positioning
- GroupBox for grouping related components

**Input Components:**
- Button with five style variants (Primary, Secondary, Ghost, Danger, Success), icon support, and ripple effect
- Toggle with iOS-style switch, label, and description
- Checkbox with square box and smooth checkmark animation
- Slider with min, max, step, suffix, prefix, custom formatting, and gradient fill
- Dropdown with searchable options, icons, and single selection
- MultiDropdown with checkbox-style multi-selection
- ColorPicker with HSV color wheel, saturation/value area, hue slider, and hex input
- Keybind with live key capture, key formatting, and trigger modes
- Textbox with label, placeholder, multiline, max length, and numeric validation
- Input with icon support and no label
- PasswordInput with mask/unmask toggle
- SearchBox with search icon, clear button, debounce, and search events
- CodeEditor with monospace font, line numbers, and copy button

**Feedback Components:**
- Notification with toast-style display, four variants (Info, Success, Warning, Error), auto-dismiss, and close button
- Dialog with title, message, configurable buttons, and four variants
- Modal with dimmed backdrop, custom content injection, and backdrop click to close
- Tooltip with hover display, four positions (Top, Bottom, Left, Right), and delay
- Badge with five variants (Default, Success, Warning, Error, Info) and pill shape
- ProgressBar with min, max, label, value display, and gradient fill animation
- LoadingScreen with full-screen overlay, spinner animation, and progress display

**Display Components:**
- SplashScreen with VoidUI branding, gradient overlay, and auto-dismiss
- WelcomeScreen with multi-step onboarding, progress indicator, and navigation
- Card with title, description, optional image, and click handling
- Avatar with image, initials fallback, four size variants, and optional status indicator
- Image with rounded corners, optional caption, border, and hover effects
- VideoPreview with thumbnail, play button overlay, and duration badge
- Divider with horizontal and vertical variants and optional text
- Spacer with configurable size

**Complex Components:**
- Accordion with expandable items and single or multiple open modes
- TreeView with hierarchical nodes, expand/collapse, selection, and nested indentation
- List with scrollable items, selection, and optional descriptions
- DataTable with columns, rows, sorting, and row selection
- StatusIndicator with six statuses (Online, Offline, Busy, Away, Available, Invisible) and pulsing animation
- Chip with selection state, icon, avatar, and close button
- Tag with five variants, icon, and close button
- Breadcrumb with clickable items, separators, and current page indicator
- Pagination with page numbers, prev/next buttons, and ellipsis for large counts

**Navigation Components:**
- FloatingButton with five positions, extended variant, tooltip, and pulsing glow
- Sidebar with logo, nav items, collapse/expand, and footer
- Navbar with logo/title, nav links, and action buttons
- ContextMenu with position-based display, icons, separators, disabled items, and shortcuts
- RightClickMenu that attaches ContextMenu to elements on right-click

**Window Management Components:**
- WindowManager with focus management, z-ordering, and window switching
- DockingSystem with dock positions, dock zone indicators, and dock/undock
- TabsReorder with drag-to-reorder functionality

**Developer Tooling Components:**
- Toasts singleton with compact notifications and dismiss all
- CommandPalette with fuzzy search, keyboard navigation, and custom commands
- Terminal with command input, output display, and history navigation
- Console with message log levels, filtering, and export
- LogViewer with syntax-highlighted entries, severity filtering, and auto-scroll

**Global API:**
- Full global API with SetTheme, GetTheme, LoadTheme, SaveTheme, CreateTheme, ListThemes, SetAccent, ToggleTheme
- Window management with CreateWindow, DestroyWindow, DestroyAll, GetWindows, GetActiveWindow
- Notification system with Notify, NotifyInfo, NotifySuccess, NotifyWarning, NotifyError, ShowDialog
- Toast system with GetToasts and Toast
- Loading and splash screens with ShowLoadingScreen, HideLoadingScreen, ShowSplashScreen, ShowWelcomeScreen
- i18n with SetLanguage, GetLanguage, GetAvailableLanguages, Translate
- Animation control with ToggleAnimations, SetAnimationQuality, SetAnimationSpeed
- Blur and transparency with EnableBlur, DisableBlur, SetTransparency
- Component factory with Create
- Command palette with GetCommandPalette, RegisterCommand
- Debug console with GetConsole, Log, LogWarning, LogError
- Import and export with Export, Import
- Version information with GetVersion, GetVersionInfo, IsVersionAtLeast
- Plugin system with RegisterPlugin, UnregisterPlugin, ListPlugins
- Lifecycle management with Update, Destroy

### Documentation

- Complete documentation suite including installation guide, getting started guide, API reference, components reference, themes documentation, events and callbacks documentation, internationalization documentation, plugins documentation, examples, FAQ, changelog, migration guide, best practices, troubleshooting, and license information
