--[[
    VoidUI | Plugin/Extension System
    Allows third-party extensions to register components, themes, commands,
    and hooks into the VoidUI lifecycle. Provides a sandboxed environment
    for plugins to extend the library without modifying core code.
]]

local VoidCore = require(script.Parent.core.VoidCore)
local Theme = require(script.Parent.theme.ThemeSystem)

local PluginSystem = {}

-- Registered plugins
local _plugins = {}
-- Hook registry
local _hooks = {}
-- Custom components registered by plugins
local _customComponents = {}

-- API surface exposed to plugins
local function _createPluginAPI(name)
    return {
        Name = name,

        -- Register a custom component
        RegisterComponent = function(componentName, componentModule)
            _customComponents[componentName] = componentModule
        end,

        -- Register a theme
        RegisterTheme = function(themeName, themeData)
            Theme.Register(themeName, themeData)
        end,

        -- Register a hook (called at specific lifecycle events)
        On = function(hookName, callback)
            if not _hooks[hookName] then
                _hooks[hookName] = {}
            end
            table.insert(_hooks[hookName], { plugin = name, callback = callback })
        end,

        -- Access core utilities
        Utils = VoidCore.Utils,
        Color = VoidCore.Color,
        Create = VoidCore.Create,
        Tween = VoidCore.Tween,

        -- Access theme
        GetTheme = function() return Theme.Current() end,
        GetThemeName = function() return Theme.CurrentName() end,

        -- Log
        Log = function(msg)
            print(string.format("[VoidUI Plugin: %s] %s", name, tostring(msg)))
        end,
    }
end

-- Register a plugin
function PluginSystem.Register(name, initFunction)
    if _plugins[name] then
        warn(string.format("[VoidUI] Plugin '%s' is already registered", name))
        return
    end

    local api = _createPluginAPI(name)
    local success, err = pcall(initFunction, api)

    if not success then
        warn(string.format("[VoidUI] Plugin '%s' failed to initialize: %s", name, tostring(err)))
        return false, err
    end

    _plugins[name] = { name = name, api = api }
    print(string.format("[VoidUI] Plugin '%s' registered successfully", name))
    return true
end

-- Unregister a plugin
function PluginSystem.Unregister(name)
    _plugins[name] = nil
    -- Remove hooks from this plugin
    for hookName, hooks in pairs(_hooks) do
        for i = #hooks, 1, -1 do
            if hooks[i].plugin == name then
                table.remove(hooks, i)
            end
        end
    end
end

-- Fire a hook (calls all registered callbacks for that hook)
function PluginSystem.FireHook(hookName, ...)
    local hooks = _hooks[hookName]
    if not hooks then return end

    for _, hook in ipairs(hooks) do
        local success, err = pcall(hook.callback, ...)
        if not success then
            warn(string.format("[VoidUI] Hook '%s' in plugin '%s' failed: %s", hookName, hook.plugin, tostring(err)))
        end
    end
end

-- Get a custom component registered by a plugin
function PluginSystem.GetComponent(componentName)
    return _customComponents[componentName]
end

-- List all registered plugins
function PluginSystem.List()
    local names = {}
    for name, _ in pairs(_plugins) do
        table.insert(names, name)
    end
    return names
end

-- Get all custom components
function PluginSystem.GetCustomComponents()
    return _customComponents
end

-- Clear all plugins
function PluginSystem.Clear()
    _plugins = {}
    _hooks = {}
    _customComponents = {}
end

return PluginSystem
