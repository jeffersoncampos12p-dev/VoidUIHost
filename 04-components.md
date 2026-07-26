# Components Reference

This document provides detailed documentation for every component available in VoidUI. Components are organized by category for easy reference. Each component section includes its configuration options, methods, and signals.

## Structural Components

### Window

The Window is the top-level container for your entire interface. It provides a draggable, resizable frame with a title bar, tab navigation, and content area.

**Configuration:**
- `Title` (string, default `"VoidUI"`) — Window title
- `Subtitle` (string, default `""`) — Subtitle below the title
- `Size` (UDim2, default `580x460`) — Initial size
- `MinSize` (Vector2, default `400x300`) — Minimum size
- `Position` (UDim2, default centered) — Initial position
- `Accent` (Color3, default theme accent) — Accent color
- `Theme` (string, default `"Dark"`) — Initial theme
- `Acrylic` (boolean, default `true`) — Enable blur effect
- `Transparency` (number, default `0.05`) — Background transparency
- `Draggable` (boolean, default `true`) — Draggable by title bar
- `Resizable` (boolean, default `true`) — Resizable
- `Minimizable` (boolean, default `true`) — Minimizable
- `Closable` (boolean, default `true`) — Closable
- `PersistState` (boolean, default `true`) — Save/restore state

**Methods:** `CreateTab(name, icon)`, `Destroy()`, `Minimize()`, `Maximize()`, `Restore()`, `SetTitle(title)`, `SetSubtitle(subtitle)`, `Focus()`

**Signals:** `OnClose`, `OnOpen`, `OnResize`, `OnFocus`, `OnMinimize`, `OnMaximize`

### Tab

A tab organizes content into sections accessible through the tab bar. Created via `Window:CreateTab(name, icon)`.

**Methods:** `CreateSection(title, options)`, `CreateSubTab(name, icon)`, `SetActive()`, `GetActive()`

**Signals:** `OnActivated`

### SubTab

A secondary level of navigation within a main Tab. Created via `Tab:CreateSubTab(name, icon)`.

**Methods:** `AddSection(title, options)`, `AddContent(instance)`, `SetActive()`, `GetActive()`

**Signals:** `OnActivated`

### Section

A section groups related components within a tab. Created via `Tab:CreateSection(title, options)` or `SubTab:AddSection(title, options)`.

**Configuration:**
- `Collapsible` (boolean, default `false`) — Whether the section can be collapsed
- `Expanded` (boolean, default `true`) — Initial expanded state
- `Side` (string, default `"Left"`) — Side of the tab content (`"Left"` or `"Right"`)

**Component Factory Methods:** The Section provides factory methods for creating all component types within it. Each method accepts a configuration table and returns the created component object. The available factory methods are: `CreateButton`, `CreateToggle`, `CreateCheckbox`, `CreateSlider`, `CreateDropdown`, `CreateMultiDropdown`, `CreateColorPicker`, `CreateKeybind`, `CreateTextbox`, `CreateInput`, `CreatePasswordInput`, `CreateSearchBox`, `CreateCodeEditor`, `CreateLabel`, `CreateParagraph`, `CreateDivider`, `CreateSpacer`, `CreateBadge`, `CreateProgressBar`, `CreateAccordion`, `CreateCard`, `CreateTag`, `CreateChip`, `CreateStatusIndicator`, `CreateImage`, `CreateAvatar`, `CreateTreeView`, `CreateList`, `CreateDataTable`, `CreatePagination`, `CreateBreadcrumb`.

### GroupBox

A container that visually groups related components with a border and optional title. Created via `Section:CreateGroupBox(title, options)` or standalone via `VoidUI:Create("GroupBox", config)`.

**Configuration:**
- `Title` (string) — Group title
- `Description` (string) — Optional description text

**Methods:** `AddComponent(component)`, `SetTitle(title)`, `SetDescription(description)`

## Input Components

### Button

A clickable button with five style variants and optional icon.

**Configuration:**
- `Text` (string) — Button label
- `Style` (string, default `"Primary"`) — Style variant: `"Primary"`, `"Secondary"`, `"Ghost"`, `"Danger"`, `"Success"`
- `Icon` (string/number) — Optional icon asset
- `Callback` (function) — Called when clicked
- `Disabled` (boolean, default `false`) — Disabled state

**Methods:** `SetText(text)`, `SetStyle(style)`, `SetIcon(icon)`, `SetDisabled(disabled)`

**Signals:** `OnClick`

### Toggle

An iOS-style toggle switch with label and optional description.

**Configuration:**
- `Text` (string) — Label text
- `Description` (string) — Optional description
- `Default` (boolean, default `false`) — Initial state
- `Callback` (function) — Called when toggled

**Methods:** `SetValue(value)`, `GetValue()`

**Signals:** `OnChanged`

### Checkbox

A square checkbox with label.

**Configuration:**
- `Text` (string) — Label text
- `Default` (boolean, default `false`) — Initial state
- `Callback` (function) — Called when changed

**Methods:** `SetValue(value)`, `GetValue()`

**Signals:** `OnChanged`

### Slider

A range slider with min, max, step, and custom formatting.

**Configuration:**
- `Text` (string) — Label text
- `Min` (number, default `0`) — Minimum value
- `Max` (number, default `100`) — Maximum value
- `Step` (number, default `1`) — Step increment
- `Default` (number, default `Min`) — Initial value
- `Suffix` (string) — Optional suffix (e.g., `"%"`)
- `Prefix` (string) — Optional prefix
- `Format` (function) — Custom value formatting function
- `Callback` (function) — Called when value changes

**Methods:** `SetValue(value)`, `GetValue()`

**Signals:** `OnChanged`

### Dropdown

A single-selection dropdown menu with optional search.

**Configuration:**
- `Text` (string) — Label text
- `Options` (table) — Array of option strings
- `Default` (string) — Initial selection
- `Searchable` (boolean, default `false`) — Enable search
- `Icons` (table) — Optional icons for options
- `Callback` (function) — Called when selection changes

**Methods:** `SetValue(value)`, `GetValue()`, `SetOptions(options)`

**Signals:** `OnChanged`

### MultiDropdown

A multi-selection dropdown with checkboxes.

**Configuration:**
- `Text` (string) — Label text
- `Options` (table) — Array of option strings
- `Default` (table) — Array of initially selected values
- `Callback` (function) — Called when selection changes

**Methods:** `SetValue(values)`, `GetValue()`

**Signals:** `OnChanged`

### ColorPicker

A color picker with HSV color wheel, saturation/value area, hue slider, and hex input.

**Configuration:**
- `Text` (string) — Label text
- `Default` (Color3, default white) — Initial color
- `Callback` (function) — Called when color changes

**Methods:** `SetColor(color)`, `GetColor()`

**Signals:** `OnChanged`

### Keybind

A keybind selector with live key capture and formatting.

**Configuration:**
- `Text` (string) — Label text
- `Default` (Enum/number) — Initial keybind
- `Callback` (function) — Called when keybind changes or is triggered
- `TriggerMode` (string) — When to trigger: `"Press"`, `"Down"`, `"Up"`

**Methods:** `SetKeybind(key)`, `GetKeybind()`

**Signals:** `OnChanged`, `OnTriggered`

### Textbox

A text input with label, placeholder, and validation options.

**Configuration:**
- `Text` (string) — Label text
- `Placeholder` (string) — Placeholder text
- `Default` (string) — Initial value
- `Multiline` (boolean, default `false`) — Multi-line input
- `MaxLength` (number) — Maximum character length
- `Numeric` (boolean, default `false`) — Only accept numbers
- `Callback` (function) — Called when text changes

**Methods:** `SetValue(value)`, `GetValue()`

**Signals:** `OnChanged`, `OnFocus`, `OnBlur`

### Input

A simple text input without a label, with optional icon.

**Configuration:**
- `Placeholder` (string) — Placeholder text
- `Default` (string) — Initial value
- `Icon` (string/number) — Optional icon
- `Callback` (function) — Called when text changes

**Signals:** `OnChanged`

### PasswordInput

A password input with mask/unmask toggle.

**Configuration:**
- `Placeholder` (string) — Placeholder text
- `Default` (string) — Initial value
- `Callback` (function) — Called when text changes

**Methods:** `SetValue(value)`, `GetValue()`

**Signals:** `OnChanged`

### SearchBox

A search input with search icon, clear button, and debounce.

**Configuration:**
- `Placeholder` (string, default `"Search..."`) — Placeholder text
- `Debounce` (number, default `0.3`) — Debounce time in seconds
- `Callback` (function) — Called when search text changes

**Signals:** `OnSearch`, `OnChanged`

### CodeEditor

A code editor with monospace font, line numbers, and copy button.

**Configuration:**
- `Text` (string) — Label text
- `Default` (string) — Initial code content
- `Language` (string) — Language hint for syntax highlighting
- `CopyButton` (boolean, default `true`) — Show copy button

**Methods:** `SetText(text)`, `GetText()`

**Signals:** `OnChanged`

## Feedback Components

### Notification

A toast-style notification in a screen corner. Usually used through the global notification API rather than directly.

**Configuration:**
- `Title` (string) — Notification title
- `Description` (string) — Notification text
- `Icon` (string/number) — Optional icon
- `Variant` (string, default `"Info"`) — `"Info"`, `"Success"`, `"Warning"`, `"Error"`
- `Duration` (number, default `5`) — Auto-dismiss time in seconds (0 for no auto-dismiss)

**Methods:** `Show()`, `Dismiss()`

**Signals:** `OnDismiss`

### Dialog

A pre-built modal dialog with title, message, and buttons. Usually created via `VoidUI:ShowDialog(config)`.

**Configuration:**
- `Title` (string) — Dialog title
- `Message` (string) — Dialog message
- `Variant` (string, default `"Info"`) — `"Info"`, `"Warning"`, `"Danger"`, `"Success"`
- `Buttons` (table, default `{"OK", "Cancel"}`) — Button labels

**Signals:** `OnConfirm`, `OnCancel`, `OnButton`

### Modal

A modal overlay with dimmed backdrop for custom content.

**Configuration:**
- `Title` (string) — Modal title
- `Size` (UDim2) — Modal size
- `CloseOnBackdrop` (boolean, default `true`) — Close when clicking outside

**Methods:** `Open()`, `Close()`, `AddContent(instance)`, `SetTitle(title)`, `SetSize(size)`

**Signals:** `OnOpen`, `OnClose`

### Tooltip

A hover tooltip that displays additional information.

**Configuration:**
- `Text` (string) — Tooltip text
- `Position` (string, default `"Top"`) — `"Top"`, `"Bottom"`, `"Left"`, `"Right"`
- `Delay` (number, default `0.5`) — Show delay in seconds

**Methods:** `SetTarget(instance)`, `SetText(text)`, `SetEnabled(enabled)`

### Badge

A small badge for displaying status or count.

**Configuration:**
- `Text` (string) — Badge text
- `Variant` (string, default `"Default"`) — `"Default"`, `"Success"`, `"Warning"`, `"Error"`, `"Info"`
- `Icon` (string/number) — Optional icon

**Methods:** `SetText(text)`, `SetVariant(variant)`

### ProgressBar

A progress bar with label and value display.

**Configuration:**
- `Text` (string) — Label text
- `Min` (number, default `0`) — Minimum value
- `Max` (number, default `100`) — Maximum value
- `Default` (number, default `0`) — Initial value
- `ShowValue` (boolean, default `true`) — Show value text

**Methods:** `SetValue(value)`, `GetValue()`

**Signals:** `OnComplete`

### LoadingScreen

A full-screen loading overlay with spinner. Created via `VoidUI:ShowLoadingScreen(config)`.

**Configuration:**
- `Title` (string, default `"Loading"`) — Loading text
- `Subtitle` (string) — Optional subtitle

**Methods:** `Show()`, `Hide()`, `SetProgress(percent)`, `SetTitle(title)`, `SetSubtitle(subtitle)`

**Signals:** `OnComplete`

## Display Components

### SplashScreen

A branded splash screen with the VoidUI logo. Created via `VoidUI:ShowSplashScreen(config)`.

**Configuration:**
- `BrandName` (string) — Brand name text
- `Tagline` (string) — Tagline text
- `Duration` (number, default `3`) — Auto-dismiss time in seconds

**Signals:** `OnDismiss`

### WelcomeScreen

A multi-step onboarding screen. Created via `VoidUI:ShowWelcomeScreen(config)`.

**Configuration:**
- `Steps` (table) — Array of step tables, each with `Icon`, `Title`, `Description`

**Signals:** `OnComplete`, `OnSkip`

### Card

A card with title, description, optional image, and click handling.

**Configuration:**
- `Title` (string) — Card title
- `Description` (string) — Card description
- `Image` (string/number) — Optional image
- `Callback` (function) — Called when clicked

**Signals:** `OnClick`

### Avatar

A user avatar with image or initials fallback.

**Configuration:**
- `Image` (string/number) — Avatar image
- `Initials` (string) — Fallback initials (e.g., `"JD"`)
- `Size` (string, default `"Medium"`) — `"Small"`, `"Medium"`, `"Large"`, `"XLarge"`
- `Ring` (boolean, default `false`) — Show ring border
- `Status` (string) — Optional status indicator

**Methods:** `SetImage(image)`, `SetInitials(initials)`, `SetSize(size)`

### Image

An image display with optional caption and rounded corners.

**Configuration:**
- `Source` (string/number) — Image source
- `Caption` (string) — Optional caption
- `Rounded` (boolean, default `true`) — Rounded corners
- `Border` (boolean, default `false`) — Show border

**Methods:** `SetSource(source)`, `SetCaption(caption)`, `SetSize(size)`

**Signals:** `OnClick`

### VideoPreview

A thumbnail-style video preview with play button overlay.

**Configuration:**
- `Thumbnail` (string/number) — Thumbnail image
- `Title` (string) — Video title
- `Duration` (string) — Duration badge text

**Signals:** `OnPlay`

### Divider

A horizontal or vertical divider line.

**Configuration:**
- `Orientation` (string, default `"Horizontal"`) — `"Horizontal"` or `"Vertical"`
- `Text` (string) — Optional text in the middle

### Spacer

A simple spacer element.

**Configuration:**
- `Size` (number, default `16`) — Spacer size in pixels

## Complex Components

### Accordion

A collapsible accordion with expandable items.

**Configuration:**
- `Multiple` (boolean, default `false`) — Allow multiple items open

**Methods:** `AddItem(item)` where item has `Title`, `Content` (function or instance), `Icon`

### TreeView

A hierarchical tree view with expandable nodes.

**Configuration:**
- `Data` (table) — Tree structure data

**Methods:** `SetData(data)`

**Signals:** `OnSelect`

### List

A scrollable list with selectable items.

**Configuration:**
- `Items` (table) — Array of items, each with `Text`, `Description`, `Icon`

**Methods:** `SetItems(items)`, `AddItem(item)`, `Clear()`, `Select(index)`

**Signals:** `OnSelect`

### DataTable

A tabular data display with columns, rows, sorting, and selection.

**Configuration:**
- `Columns` (table) — Array of column definitions with `Key`, `Title`, `Sortable`
- `Rows` (table) — Array of row data tables
- `Sortable` (boolean, default `true`) — Enable sorting

**Methods:** `SetRows(rows)`, `AddRow(row)`, `Clear()`

**Signals:** `OnRowSelect`, `OnSort`

### StatusIndicator

A small dot indicator showing status.

**Configuration:**
- `Status` (string, default `"Online"`) — `"Online"`, `"Offline"`, `"Busy"`, `"Away"`, `"Available"`, `"Invisible"`
- `Text` (string) — Optional status text
- `Pulse` (boolean, default `true`) — Pulsing animation

**Methods:** `SetStatus(status)`, `SetText(text)`, `SetPulse(enabled)`

### Chip

An interactive chip for filters and selections.

**Configuration:**
- `Text` (string) — Chip text
- `Icon` (string/number) — Optional icon
- `Avatar` (string/number) — Optional avatar image
- `Closable` (boolean, default `false`) — Show close button
- `Selectable` (boolean, default `false`) — Click to select

**Methods:** `SetSelected(selected)`, `GetSelected()`, `SetText(text)`

**Signals:** `OnSelected`, `OnClose`

### Tag

A compact label for categorizing items.

**Configuration:**
- `Text` (string) — Tag text
- `Variant` (string, default `"Default"`) — `"Default"`, `"Primary"`, `"Success"`, `"Warning"`, `"Error"`
- `Icon` (string/number) — Optional icon
- `Closable` (boolean, default `false`) — Show close button

**Methods:** `SetText(text)`, `SetVariant(variant)`

### Breadcrumb

A navigation breadcrumb trail.

**Configuration:**
- `Items` (table) — Array of breadcrumb items with `Text`, `Icon`

**Methods:** `SetItems(items)`, `AddItem(item)`

**Signals:** `OnNavigate`

### Pagination

Pagination controls with page numbers.

**Configuration:**
- `CurrentPage` (number, default `1`) — Current page
- `TotalPages` (number, default `1`) — Total pages

**Methods:** `SetPage(page)`, `GetPage()`, `SetTotalPages(total)`

**Signals:** `OnPageChange`

## Navigation Components

### FloatingButton

A floating action button (FAB) that hovers above content.

**Configuration:**
- `Icon` (string/number) — Button icon
- `Position` (string, default `"BottomRight"`) — `"BottomRight"`, `"BottomLeft"`, `"TopRight"`, `"TopLeft"`, `"BottomCenter"`
- `Extended` (boolean, default `false`) — Extended with text label
- `Text` (string) — Text for extended mode
- `Tooltip` (string) — Optional tooltip text

**Signals:** `OnClick`

### Sidebar

A vertical navigation sidebar with logo, nav items, and optional footer.

**Configuration:**
- `Title` (string) — Sidebar title
- `Items` (table) — Array of nav items with `Text`, `Icon`
- `Collapsible` (boolean, default `false`) — Collapsible sidebar
- `Footer` (table) — Optional footer content

**Methods:** `Toggle()`

**Signals:** `OnNavigate`, `OnToggle`

### Navbar

A horizontal top navigation bar with logo/title, nav links, and action buttons.

**Configuration:**
- `Title` (string) — Navbar title
- `Items` (table) — Array of nav items

**Methods:** `AddAction(item)`

**Signals:** `OnNavigate`

### ContextMenu

A context menu appearing at a position with a list of actions.

**Configuration:**
- `Items` (table) — Array of menu items with `Text`, `Icon`, `Action`, `Separator`, `Disabled`, `Danger`, `Shortcut`

**Methods:** `Show(position)`, `Close()`, `AddItem(item)`

**Signals:** `OnSelect`

### RightClickMenu

Attaches a ContextMenu to a target element on right-click.

**Configuration:**
- `Items` (table) — Array of menu items

**Methods:** `Attach(targetInstance)`

## Window Management Components

### WindowManager

Manages multiple Window instances with focus management and z-ordering.

**Methods:** `AddWindow(window)`, `FocusWindow(window)`, `RemoveWindow(window)`, `GetWindows()`, `GetActiveWindow()`, `CloseAll()`

**Signals:** `OnWindowFocus`, `OnWindowAdded`, `OnWindowRemoved`

### DockingSystem

A docking system for arranging windows in docked positions.

**Methods:** `DockWindow(window, position)`, `UndockWindow(window)`, `ShowZones()`, `HideZones()`

**Signals:** `OnDock`, `OnUndock`

### TabsReorder

Drag-to-reorder functionality for tab bars.

**Methods:** `GetOrder()`

**Signals:** `OnReorder`

## Developer Tooling Components

### Toasts

A singleton toast notification manager. Accessed via `VoidUI:GetToasts()`.

**Methods:** `Notify(config)`, `Info(title, desc)`, `Success(title, desc)`, `Warning(title, desc)`, `Error(title, desc)`, `DismissAll()`

### CommandPalette

A searchable command palette (Ctrl+P). Accessed via `VoidUI:GetCommandPalette()`.

**Methods:** `Open()`, `Close()`, `Toggle()`, `AddCommand(command)`

**Signals:** `OnCommand`

### Terminal

A terminal-style interface with command input and output history.

**Configuration:**
- `Title` (string) — Terminal title

**Methods:** `Print(text)`, `Execute(command)`, `RegisterHandler(name, handler)`, `Clear()`, `Focus()`

**Signals:** `OnCommand`, `OnOutput`

### Console

A developer console with message log levels.

**Methods:** `Log(message)`, `Info(message)`, `Warn(message)`, `Error(message)`, `Debug(message)`, `Success(message)`, `SetFilter(level)`, `Clear()`, `Export()`

### LogViewer

A log file viewer with syntax-highlighted entries by severity.

**Configuration:**
- `AutoScroll` (boolean, default `true`) — Auto-scroll to bottom

**Methods:** `AddEntry(entry)`, `AddEntries(entries)`, `SetEntries(entries)`, `SetFilter(severity)`, `Clear()`, `SetAutoScroll(enabled)`, `Export()`
