# Installation

VoidUI is designed to be easy to install and integrate into your Lua/LuaU project. There are several ways to load the library depending on your environment and workflow preferences.

## Method 1: Loadstring (Recommended)

The simplest and most common way to use VoidUI is through a loadstring call that fetches and executes the library from a hosted source. This is the recommended approach for most users because it ensures you are always running the latest version and requires no local file management.

```lua
local VoidUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NinjaTechAI/VoidUI/main/src/VoidUI.lua"
))()
```

Replace the URL with the actual hosted location of the VoidUI source. Once loaded, the `VoidUI` table contains the entire library API and is ready to use immediately.

## Method 2: Local Script

If you prefer to host the library locally within your project, you can place the entire `src` directory structure into your script hierarchy and require the main loader file directly. This approach gives you full control over the source code and allows you to make modifications without depending on an external host.

```lua
-- Assuming the src folder is placed as a child of your script
local VoidUI = require(script.Parent.src.VoidUI)
```

When using this method, ensure that the entire directory structure is preserved exactly as distributed. The main loader file (`VoidUI.lua`) uses relative requires to load all sub-modules, so the folder structure must remain intact. The required structure is as follows: the `src` directory should contain `VoidUI.lua` at its root, with subdirectories for `core`, `theme`, `animation`, `events`, `utils`, `plugins`, and `components`, each containing their respective module files.

## Method 3: Model

For Roblox projects, you can load VoidUI from a published model. This is useful when you want to distribute the library as a self-contained package that can be inserted into any game.

```lua
local VoidUIModel = game.ReplicatedStorage:WaitForChild("VoidUI")
local VoidUI = require(VoidUIModel)
```

To use this method, insert the VoidUI model into ReplicatedStorage (or another accessible location) and require it from your scripts. The model should contain the complete `src` directory structure with `VoidUI.lua` as the main module.

## Requirements

VoidUI requires a Lua/LuaU environment with access to the standard Roblox services and Instance system. The library relies on the following services: TweenService for animations, RunService for frame-based updates, UserInputService for input handling, HttpService for JSON encoding and web requests, CoreGui or PlayerGui for UI parent containers, and Players for player-specific UI.

The library is designed to work on both the client and server, though most components are intended for client-side use since they create GUI elements that need to be rendered on a player's screen. For server-side logic, the utility functions, signal system, and promise system can be used independently of the visual components.

## Verifying Installation

After loading the library, you can verify that it was loaded correctly by checking the version information:

```lua
local VoidUI = loadstring(game:HttpGet(URL))()

print(VoidUI:GetVersion())        -- "1.0.0"
print(VoidUI:GetVersionInfo())    -- table with version details
print(VoidUI.ListThemes())        -- list of available themes
print(VoidUI.GetAvailableLanguages())  -- list of available languages
```

If these functions return the expected values, the library has been loaded successfully and you are ready to start building your interface.

## Next Steps

Once VoidUI is installed and verified, head over to the [Getting Started](./02-getting-started.md) guide to learn how to create your first window and populate it with components.
