--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                                                                  ║
    ║   VoidUI — Modern UI Library for Lua/LuaU                        ║
    ║   Version: 1.0.0                                                 ║
    ║   Author: NinjaTech AI Team                                      ║
    ║   License: MIT                                                   ║
    ║                                                                  ║
    ║   A complete, modular, and elegant UI library inspired by       ║
    ║   modern design principles. Built for performance,              ║
    ║   extensibility, and beauty.                                     ║
    ║                                                                  ║
    ╚══════════════════════════════════════════════════════════════════╝

    ┌──────────────────────────────────────────────────────────────────┐
    │                      QUICK START                                │
    │                                                                  │
    │  local VoidUI = loadstring(game:HttpGet(URL))()                │
    │                                                                  │
    │  local Window = VoidUI:CreateWindow({                          │
    │      Title = "My App",                                          │
    │      Subtitle = "Powered by VoidUI",                            │
    │  })                                                             │
    │                                                                  │
    │  local Tab = Window:CreateTab("Home", "icon")                  │
    │  local Section = Tab:CreateSection("Settings")                │
    │                                                                  │
    │  Section:CreateButton({                                         │
    │      Text = "Click Me",                                         │
 │      Callback = function() print("Hello!") end,                │
    │  })                                                             │
    │                                                                  │
    └──────────────────────────────────────────────────────────────────┘
]]

-- ─────────────────────────────────────────────────────────────────────
-- Core Modules
-- ─────────────────────────────────────────────────────────────────────
local VoidCore = require(script.core.VoidCore)
local Theme = require(script.theme.ThemeSystem)
local Anim = require(script.animation.AnimationSystem)
local Events = require(script.events.EventSystem)
local i18n = require(script.utils.i18n)
local PluginSystem = require(script.plugins.PluginSystem)

-- ─────────────────────────────────────────────────────────────────────
-- Component Modules
-- ─────────────────────────────────────────────────────────────────────
local Component = require(script.components.Component)
local Window = require(script.components.Window)
local Tab = require(script.components.Tab)
local SubTab = require(script.components.SubTab)
local Section = require(script.components.Section)
local GroupBox = require(script.components.GroupBox)
local Button = require(script.components.Button)
local Toggle = require(script.components.Toggle)
local Checkbox = require(script.components.Checkbox)
local Slider = require(script.components.Slider)
local Dropdown = require(script.components.Dropdown)
local MultiDropdown = require(script.components.MultiDropdown)
local ColorPicker = require(script.components.ColorPicker)
local Keybind = require(script.components.Keybind)
local Textbox = require(script.components.Textbox)
local Input = require(script.components.Input)
local PasswordInput = require(script.components.PasswordInput)
local SearchBox = require(script.components.SearchBox)
local CodeEditor = require(script.components.CodeEditor)
local Notification = require(script.components.Notification)
local Dialog = require(script.components.Dialog)
local Modal = require(script.components.Modal)
local Tooltip = require(script.components.Tooltip)
local Badge = require(script.components.Badge)
local ProgressBar = require(script.components.ProgressBar)
local LoadingScreen = require(script.components.LoadingScreen)
local SplashScreen = require(script.components.SplashScreen)
local WelcomeScreen = require(script.components.WelcomeScreen)
local Card = require(script.components.Card)
local Avatar = require(script.components.Avatar)
local Image = require(script.components.Image)
local VideoPreview = require(script.components.VideoPreview)
local Divider = require(script.components.Divider)
local Spacer = require(script.components.Spacer)
local Accordion = require(script.components.Accordion)
local TreeView = require(script.components.TreeView)
local List = require(script.components.List)
local DataTable = require(script.components.DataTable)
local StatusIndicator = require(script.components.StatusIndicator)
local Chip = require(script.components.Chip)
local Tag = require(script.components.Tag)
local Breadcrumb = require(script.components.Breadcrumb)
local Pagination = require(script.components.Pagination)
local FloatingButton = require(script.components.FloatingButton)
local Sidebar = require(script.components.Sidebar)
local Navbar = require(script.components.Navbar)
local ContextMenu = require(script.components.ContextMenu)
local RightClickMenu = require(script.components.RightClickMenu)
local WindowManager = require(script.components.WindowManager)
local DockingSystem = require(script.components.DockingSystem)
local TabsReorder = require(script.components.TabsReorder)
local Toasts = require(script.components.Toasts)
local CommandPalette = require(script.components.CommandPalette)
local Terminal = require(script.components.Terminal)
local Console = require(script.components.Console)
local LogViewer = require(script.components.LogViewer)

-- ─────────────────────────────────────────────────────────────────────
-- VoidUI Main Object
-- ─────────────────────────────────────────────────────────────────────
local VoidUI = {}

VoidUI.Version = "1.0.0"
VoidUI.Author = "NinjaTech AI Team"
VoidUI.License = "MIT"

-- Internal state
local _state = {
    windows = {},
    activeWindow = nil,
    config = {},
    toasts = nil,
    loadingScreen = nil,
    splashScreen = nil,
    commandPalette = nil,
    console = nil,
}

-- ─────────────────────────────────────────────────────────────────────
-- Core System Access
-- ─────────────────────────────────────────────────────────────────────

--- Access the core utilities module
function VoidUI.GetCore()
    return VoidCore
end

--- Access the theme system
function VoidUI.GetThemeSystem()
    return Theme
end

--- Access the animation system
function VoidUI.GetAnimationSystem()
    return Anim
end

--- Access the event system
function VoidUI.GetEvents()
    return Events
end

--- Access the i18n system
function VoidUI.GetI18n()
    return i18n
end

--- Access the plugin system
function VoidUI.GetPlugins()
    return PluginSystem
end

-- ─────────────────────────────────────────────────────────────────────
-- Theme API
-- ─────────────────────────────────────────────────────────────────────

--- Set the current theme by name
--- @param themeName string - The name of the theme to set
function VoidUI.SetTheme(themeName)
    Theme.Set(themeName)
    PluginSystem.FireHook("ThemeChanged", themeName)
end

--- Get the current theme
--- @return table - The current theme object
function VoidUI.GetTheme()
    return Theme.Current()
end

--- Get the current theme name
--- @return string - The current theme name
function VoidUI.GetThemeName()
    return Theme.CurrentName()
end

--- Load a theme from a saved configuration
--- @param themeData table - The theme data to load
function VoidUI.LoadTheme(themeData)
    return Theme.Import(themeData)
end

--- Save the current theme to a configuration
--- @return table - The exported theme data
function VoidUI.SaveTheme()
    return Theme.Export()
end

--- Create a custom theme
--- @param name string - The theme name
--- @param data table - The theme data
function VoidUI.CreateTheme(name, data)
    return Theme.Register(name, data)
end

--- List all available themes
--- @return table - Array of theme names
function VoidUI.ListThemes()
    return Theme.List()
end

--- Set the accent color
--- @param color Color3 - The accent color
function VoidUI.SetAccent(color)
    local current = Theme.Current()
    current.Accent.Primary = color
    -- Re-register the modified theme
    Theme.Register(Theme.CurrentName(), current)
    Theme.Set(Theme.CurrentName())
end

--- Toggle between dark and light themes
function VoidUI.ToggleTheme()
    local current = Theme.CurrentName()
    if current == "Dark" then
        Theme.Set("Light")
    else
        Theme.Set("Dark")
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- Window API
-- ─────────────────────────────────────────────────────────────────────

--- Create a new Window
--- @param config table - Window configuration
--- @return Window - The created window
function VoidUI.CreateWindow(config)
    config = config or {}
    local window = Window.new(config, VoidUI)
    table.insert(_state.windows, window)
    _state.activeWindow = window

    -- Fire hook for window creation
    PluginSystem.FireHook("WindowCreated", window)

    return window
end

--- Destroy a specific window
--- @param window Window - The window to destroy
function VoidUI.DestroyWindow(window)
    if window then
        for i, w in ipairs(_state.windows) do
            if w == window then
                table.remove(_state.windows, i)
                if window.Destroy then window:Destroy() end
                break
            end
        end
    end
end

--- Destroy all windows
function VoidUI.DestroyAll()
    for _, window in ipairs(_state.windows) do
        if window.Destroy then window:Destroy() end
    end
    _state.windows = {}
    _state.activeWindow = nil
end

--- Get all active windows
--- @return table - Array of windows
function VoidUI.GetWindows()
    return _state.windows
end

--- Get the active window
--- @return Window - The currently active window
function VoidUI.GetActiveWindow()
    return _state.activeWindow
end

-- ─────────────────────────────────────────────────────────────────────
-- Notification API
-- ─────────────────────────────────────────────────────────────────────

--- Show a notification
--- @param config table|string - Notification config or title
--- @return Notification - The created notification
function VoidUI.Notify(config)
    if type(config) == "string" then
        config = { Title = config }
    end
    local notif = Notification.new(config, VoidUI)
    notif:Show()
    return notif
end

--- Show an info notification
function VoidUI.NotifyInfo(title, description)
    return VoidUI.Notify({ Title = title, Description = description, Variant = "Info" })
end

--- Show a success notification
function VoidUI.NotifySuccess(title, description)
    return VoidUI.Notify({ Title = title, Description = description, Variant = "Success" })
end

--- Show a warning notification
function VoidUI.NotifyWarning(title, description)
    return VoidUI.Notify({ Title = title, Description = description, Variant = "Warning" })
end

--- Show an error notification
function VoidUI.NotifyError(title, description)
    return VoidUI.Notify({ Title = title, Description = description, Variant = "Error" })
end

--- Show a dialog
--- @param config table - Dialog configuration
--- @return Dialog - The created dialog
function VoidUI.ShowDialog(config)
    local dialog = Dialog.new(config, VoidUI)
    dialog:Open()
    return dialog
end

-- ─────────────────────────────────────────────────────────────────────
-- Toasts API (managed notification system)
-- ─────────────────────────────────────────────────────────────────────

--- Get the shared Toasts instance
--- @return Toasts - The toast manager
function VoidUI.GetToasts()
    if not _state.toasts then
        _state.toasts = Toasts.new({}, VoidUI)
    end
    return _state.toasts
end

--- Show a toast notification (managed)
--- @param title string - Toast title
--- @param description string - Toast description
--- @param variant string - Variant (Info/Success/Warning/Error)
--- @param duration number - Duration in seconds
function VoidUI.Toast(title, description, variant, duration)
    return VoidUI.GetToasts():Notify(title, description, variant, duration)
end

-- ─────────────────────────────────────────────────────────────────────
-- Loading & Splash API
-- ─────────────────────────────────────────────────────────────────────

--- Show a loading screen
--- @param config table - Loading screen configuration
--- @return LoadingScreen - The created loading screen
function VoidUI.ShowLoadingScreen(config)
    if _state.loadingScreen then
        _state.loadingScreen:Destroy()
    end
    _state.loadingScreen = LoadingScreen.new(config or {}, VoidUI)
    _state.loadingScreen:Show()
    return _state.loadingScreen
end

--- Hide the loading screen
function VoidUI.HideLoadingScreen()
    if _state.loadingScreen then
        _state.loadingScreen:Hide()
        _state.loadingScreen:Destroy()
        _state.loadingScreen = nil
    end
end

--- Show a splash screen
--- @param config table - Splash screen configuration
--- @return SplashScreen - The created splash screen
function VoidUI.ShowSplashScreen(config)
    if _state.splashScreen then
        _state.splashScreen:Destroy()
    end
    _state.splashScreen = SplashScreen.new(config or {}, VoidUI)
    _state.splashScreen:Show()
    return _state.splashScreen
end

--- Show a welcome/onboarding screen
--- @param config table - Welcome screen configuration
--- @return WelcomeScreen - The created welcome screen
function VoidUI.ShowWelcomeScreen(config)
    return WelcomeScreen.new(config or {}, VoidUI)
end

-- ─────────────────────────────────────────────────────────────────────
-- i18n API
-- ─────────────────────────────────────────────────────────────────────

--- Set the current language
--- @param lang string - Language code (e.g., "en-US", "pt-BR", "es-ES")
function VoidUI.SetLanguage(lang)
    i18n.SetLanguage(lang)
    PluginSystem.FireHook("LanguageChanged", lang)
end

--- Get the current language
--- @return string - The current language code
function VoidUI.GetLanguage()
    return i18n.GetLanguage()
end

--- Get available languages
--- @return table - Array of available language codes
function VoidUI.GetAvailableLanguages()
    return i18n.Available()
end

--- Translate a key to the current language
--- @param key string - The translation key
--- @return string - The translated text
function VoidUI.Translate(key)
    return i18n.Translate(key)
end

-- ─────────────────────────────────────────────────────────────────────
-- Animation API
-- ─────────────────────────────────────────────────────────────────────

--- Enable/disable animations
--- @param enabled boolean - Whether animations are enabled
function VoidUI.ToggleAnimations(enabled)
    if enabled == nil then
        Anim._enabled = not Anim._enabled
    else
        Anim._enabled = enabled
    end
end

--- Set animation quality
--- @param quality string - Quality level ("Fast", "Balanced", "Smooth")
function VoidUI.SetAnimationQuality(quality)
    Anim._quality = quality
end

--- Set animation speed multiplier
--- @param speed number - Speed multiplier (1 = normal, 2 = double speed)
function VoidUI.SetAnimationSpeed(speed)
    Anim._speed = speed
end

-- ─────────────────────────────────────────────────────────────────────
-- Blur / Acrylic API
-- ─────────────────────────────────────────────────────────────────────

--- Enable blur/acrylic effect globally
function VoidUI.EnableBlur()
    _state.blurEnabled = true
    for _, window in ipairs(_state.windows) do
        if window.SetAcrylic then
            window:SetAcrylic(true)
        end
    end
end

--- Disable blur/acrylic effect globally
function VoidUI.DisableBlur()
    _state.blurEnabled = false
    for _, window in ipairs(_state.windows) do
        if window.SetAcrylic then
            window:SetAcrylic(false)
        end
    end
end

--- Set global transparency level
--- @param transparency number - Transparency value (0 = opaque, 1 = transparent)
function VoidUI.SetTransparency(transparency)
    for _, window in ipairs(_state.windows) do
        if window.Frame then
            window.Frame.BackgroundTransparency = transparency
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- Component Factory API
-- ─────────────────────────────────────────────────────────────────────

--- Create a component directly without a window
--- @param componentType string - The component type name
--- @param config table - Component configuration
--- @return Component - The created component
function VoidUI.Create(componentType, config)
    local componentMap = {
        Button = Button,
        Toggle = Toggle,
        Checkbox = Checkbox,
        Slider = Slider,
        Dropdown = Dropdown,
        MultiDropdown = MultiDropdown,
        ColorPicker = ColorPicker,
        Keybind = Keybind,
        Textbox = Textbox,
        Input = Input,
        PasswordInput = PasswordInput,
        SearchBox = SearchBox,
        CodeEditor = CodeEditor,
        Badge = Badge,
        ProgressBar = ProgressBar,
        Card = Card,
        Avatar = Avatar,
        Image = Image,
        VideoPreview = VideoPreview,
        Divider = Divider,
        Spacer = Spacer,
        Accordion = Accordion,
        TreeView = TreeView,
        List = List,
        DataTable = DataTable,
        StatusIndicator = StatusIndicator,
        Chip = Chip,
        Tag = Tag,
        Breadcrumb = Breadcrumb,
        Pagination = Pagination,
        GroupBox = GroupBox,
        Label = require(script.components.Label),
        Paragraph = require(script.components.Paragraph),
    }

    local ComponentClass = componentMap[componentType]
    if not ComponentClass then
        -- Check plugin-registered components
        ComponentClass = PluginSystem.GetComponent(componentType)
    end

    if not ComponentClass then
        warn(string.format("[VoidUI] Unknown component type: %s", tostring(componentType)))
        return nil
    end

    return ComponentClass.new(config or {}, VoidUI)
end

-- ─────────────────────────────────────────────────────────────────────
-- Command Palette API
-- ─────────────────────────────────────────────────────────────────────

--- Get the shared CommandPalette instance
--- @return CommandPalette - The command palette
function VoidUI.GetCommandPalette()
    if not _state.commandPalette then
        _state.commandPalette = CommandPalette.new({ Commands = {} }, VoidUI)
    end
    return _state.commandPalette
end

--- Register a command in the command palette
--- @param command table - Command configuration { Title, Description, Icon, Shortcut, Callback }
function VoidUI.RegisterCommand(command)
    VoidUI.GetCommandPalette():AddCommand(command)
end

-- ─────────────────────────────────────────────────────────────────────
-- Debug Console API
-- ─────────────────────────────────────────────────────────────────────

--- Get the shared debug Console instance
--- @return Console - The debug console
function VoidUI.GetConsole()
    if not _state.console then
        _state.console = Console.new({}, VoidUI)
    end
    return _state.console
end

--- Log a debug message
--- @param message string - The message to log
function VoidUI.Log(message)
    VoidUI.GetConsole():Info(message)
end

--- Log a warning message
--- @param message string - The warning message
function VoidUI.LogWarning(message)
    VoidUI.GetConsole():Warn(message)
end

--- Log an error message
--- @param message string - The error message
function VoidUI.LogError(message)
    VoidUI.GetConsole():Error(message)
end

-- ─────────────────────────────────────────────────────────────────────
-- Import/Export API
-- ─────────────────────────────────────────────────────────────────────

--- Export the current VoidUI configuration
--- @return table - The exported configuration
function VoidUI.Export()
    local StateManager = VoidCore.StateManager
    return {
        Version = VoidUI.Version,
        Theme = Theme.Export(),
        Language = i18n.GetLanguage(),
        Settings = {
            AnimationsEnabled = Anim._enabled,
            AnimationSpeed = Anim._speed,
            AnimationQuality = Anim._quality,
            BlurEnabled = _state.blurEnabled,
        },
        State = StateManager.Load(),
    }
end

--- Import a VoidUI configuration
--- @param config table - The configuration to import
function VoidUI.Import(config)
    if not config then return end

    if config.Theme then
        Theme.Import(config.Theme)
    end

    if config.Language then
        i18n.SetLanguage(config.Language)
    end

    if config.Settings then
        if config.Settings.AnimationsEnabled ~= nil then
            Anim._enabled = config.Settings.AnimationsEnabled
        end
        if config.Settings.AnimationSpeed then
            Anim._speed = config.Settings.AnimationSpeed
        end
        if config.Settings.AnimationQuality then
            Anim._quality = config.Settings.AnimationQuality
        end
        if config.Settings.BlurEnabled ~= nil then
            _state.blurEnabled = config.Settings.BlurEnabled
        end
    end

    if config.State then
        local StateManager = VoidCore.StateManager
        for key, value in pairs(config.State) do
            StateManager.Set(key, value)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────
-- Version API
-- ─────────────────────────────────────────────────────────────────────

--- Get the VoidUI version
--- @return string - The version string
function VoidUI.GetVersion()
    return VoidUI.Version
end

--- Get version information
--- @return table - Version info { version, author, license }
function VoidUI.GetVersionInfo()
    return {
        Version = VoidUI.Version,
        Author = VoidUI.Author,
        License = VoidUI.License,
    }
end

--- Check if the current version is newer than a given version
--- @param version string - The version to compare against
--- @return boolean - True if current is newer or equal
function VoidUI.IsVersionAtLeast(version)
    local currentMajor, currentMinor, currentPatch = VoidUI.Version:match("(%d+)%.(%d+)%.(%d+)")
    local checkMajor, checkMinor, checkPatch = version:match("(%d+)%.(%d+)%.(%d+)")

    currentMajor, currentMinor, currentPatch = tonumber(currentMajor), tonumber(currentMinor), tonumber(currentPatch)
    checkMajor, checkMinor, checkPatch = tonumber(checkMajor), tonumber(checkMinor), tonumber(checkPatch)

    if currentMajor > checkMajor then return true end
    if currentMajor < checkMajor then return false end
    if currentMinor > checkMinor then return true end
    if currentMinor < checkMinor then return false end
    return currentPatch >= checkPatch
end

-- ─────────────────────────────────────────────────────────────────────
-- Plugin API
-- ─────────────────────────────────────────────────────────────────────

--- Register a plugin
--- @param name string - The plugin name
--- @param initFunction function - The initialization function
function VoidUI.RegisterPlugin(name, initFunction)
    return PluginSystem.Register(name, initFunction)
end

--- Unregister a plugin
--- @param name string - The plugin name
function VoidUI.UnregisterPlugin(name)
    PluginSystem.Unregister(name)
end

--- List registered plugins
--- @return table - Array of plugin names
function VoidUI.ListPlugins()
    return PluginSystem.List()
end

-- ─────────────────────────────────────────────────────────────────────
-- Update/Destroy API
-- ─────────────────────────────────────────────────────────────────────

--- Update the VoidUI system (call in a RunService loop if needed)
function VoidUI.Update()
    PluginSystem.FireHook("Update")
end

--- Destroy all VoidUI resources
function VoidUI.Destroy()
    VoidUI.DestroyAll()

    if _state.toasts then
        _state.toasts:DismissAll()
    end
    if _state.loadingScreen then
        _state.loadingScreen:Destroy()
        _state.loadingScreen = nil
    end
    if _state.splashScreen then
        _state.splashScreen:Destroy()
        _state.splashScreen = nil
    end
    if _state.commandPalette then
        if _state.commandPalette.ScreenGui then
            _state.commandPalette.ScreenGui:Destroy()
        end
        _state.commandPalette = nil
    end

    PluginSystem.Clear()
    PluginSystem.FireHook("Destroy")

    _state = {}
end

-- ─────────────────────────────────────────────────────────────────────
-- Expose Component Classes (for advanced usage)
-- ─────────────────────────────────────────────────────────────────────
VoidUI.Components = {
    Window = Window,
    Tab = Tab,
    SubTab = SubTab,
    Section = Section,
    GroupBox = GroupBox,
    Button = Button,
    Toggle = Toggle,
    Checkbox = Checkbox,
    Slider = Slider,
    Dropdown = Dropdown,
    MultiDropdown = MultiDropdown,
    ColorPicker = ColorPicker,
    Keybind = Keybind,
    Textbox = Textbox,
    Input = Input,
    PasswordInput = PasswordInput,
    SearchBox = SearchBox,
    CodeEditor = CodeEditor,
    Notification = Notification,
    Dialog = Dialog,
    Modal = Modal,
    Tooltip = Tooltip,
    Badge = Badge,
    ProgressBar = ProgressBar,
    LoadingScreen = LoadingScreen,
    SplashScreen = SplashScreen,
    WelcomeScreen = WelcomeScreen,
    Card = Card,
    Avatar = Avatar,
    Image = Image,
    VideoPreview = VideoPreview,
    Divider = Divider,
    Spacer = Spacer,
    Accordion = Accordion,
    TreeView = TreeView,
    List = List,
    DataTable = DataTable,
    StatusIndicator = StatusIndicator,
    Chip = Chip,
    Tag = Tag,
    Breadcrumb = Breadcrumb,
    Pagination = Pagination,
    FloatingButton = FloatingButton,
    Sidebar = Sidebar,
    Navbar = Navbar,
    ContextMenu = ContextMenu,
    RightClickMenu = RightClickMenu,
    WindowManager = WindowManager,
    DockingSystem = DockingSystem,
    TabsReorder = TabsReorder,
    Toasts = Toasts,
    CommandPalette = CommandPalette,
    Terminal = Terminal,
    Console = Console,
    LogViewer = LogViewer,
}

-- ─────────────────────────────────────────────────────────────────────
-- Initialization
-- ─────────────────────────────────────────────────────────────────────
PluginSystem.FireHook("Init")

print("[VoidUI] v" .. VoidUI.Version .. " initialized successfully.")

return VoidUI
