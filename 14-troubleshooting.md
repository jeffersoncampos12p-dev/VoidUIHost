# Troubleshooting

This document covers common issues you may encounter when using VoidUI and how to resolve them.

## Common Issues

### Components Are Not Visible

If your components are not appearing on screen, check the following:

Make sure you have created a window and that the window is visible and not minimized. The window must be created before any tabs or sections, and tabs must be created before sections. Components are added to sections, so you must have a section before adding components.

```lua
-- Correct order: Window → Tab → Section → Components
local Window = VoidUI:CreateWindow({ Title = "My App" })
local Tab = Window:CreateTab("Home", "icon")
local Section = Tab:CreateSection("Content")
Section:CreateButton({ Text = "Click Me" })
```

Also ensure that the ScreenGui is being placed in an appropriate parent. VoidUI places its UI in CoreGui by default, but if you are in a context where CoreGui is not accessible, you may need to adjust the parent. Check that the window is not positioned off-screen by verifying the `Position` configuration.

### Theme Is Not Applying

If your custom theme is not applying correctly:

Verify that the theme was registered with `VoidUI:CreateTheme()` before calling `VoidUI:SetTheme()`. The theme name must match exactly what you registered. Check that your theme data table includes all required properties (Background, Text, Accent, etc.). Use `VoidUI:ListThemes()` to verify that your theme is registered.

```lua
-- Register before setting
VoidUI:CreateTheme("MyTheme", { Background = ..., Text = ..., Accent = ... })
VoidUI:SetTheme("MyTheme")  -- Must match the name exactly
```

### Notifications Are Not Appearing

If notifications are not showing up:

Check that the notification system has not been disabled. Verify that the notification container is not being blocked by other UI elements with higher z-index. Ensure the `Duration` parameter is not set to 0 if you want auto-dismiss (0 means no auto-dismiss, but the notification should still appear). Try using the simpler notification functions like `VoidUI:NotifyInfo("Test", "Testing")` to see if the basic system works.

### Window Is Not Draggable or Resizable

If your window cannot be dragged or resized:

Check the `Draggable` and `Resizable` configuration options — they default to true but may have been set to false. Ensure the window is not in a maximized state, which may prevent dragging. Verify that no other UI elements are intercepting input events on the title bar.

### Sliders or Sliders Show Incorrect Values

If slider values seem incorrect:

Check that `Min` is less than `Max`. The `Default` value must be between `Min` and `Max`. If you are using a custom `Format` function, make sure it returns a string, not a number.

### Dropdown Does Not Show Selected Value

If the dropdown does not display the correct selected value:

Make sure the `Default` value exactly matches one of the strings in the `Options` array (case-sensitive). If using `SetOptions` to change options after creation, ensure the current value still exists in the new options list.

### ColorPicker Shows Wrong Color

If the color picker displays an incorrect color:

Verify that the `Default` color is a valid `Color3` object. If you are using hex values, convert them to `Color3` using `Color3.fromRGB(r, g, b)`. Check that you are reading the value with `GetColor()` and not `GetValue()`.

### Keybind Is Not Triggering

If a keybind is not triggering when the key is pressed:

Check the `TriggerMode` — it should be `"Press"`, `"Down"`, or `"Up"` depending on when you want the callback to fire. Ensure the keybind is not conflicting with other keybinds or Roblox's default shortcuts. Verify that the keybind system is not disabled.

### Animations Are Not Playing

If animations are not working:

Check that animations are enabled with `VoidUI:ToggleAnimations(true)`. Verify the animation quality is not set to a level that is too low for the effects to be visible. Check the animation speed — a very high speed may make animations too fast to see, while a very low speed may make them appear frozen.

### State Is Not Being Saved

If the Export/Import state is not working:

Make sure you are calling `Export()` at the right time (e.g., in the `OnClose` handler). Verify that the returned state table is being saved correctly — use `HttpService:JSONEncode` to convert it to a string before saving to a file. When importing, make sure you are passing the decoded table, not the JSON string.

```lua
-- Correct export
local state = VoidUI:Export()
local jsonStr = game:GetService("HttpService"):JSONEncode(state)
writefile("state.json", jsonStr)

-- Correct import
local jsonStr = readfile("state.json")
local state = game:GetService("HttpService"):JSONDecode(jsonStr)
VoidUI:Import(state)
```

### Plugin Is Not Working

If your custom plugin is not functioning:

Make sure the plugin name is unique and not already registered. Check that the initialization function is being called (add a `api.Log` call at the beginning). Verify that you are using the correct method names on the plugin API object. Ensure that any custom components you register are being created with the correct component type name.

### Performance Issues

If you experience performance problems:

Disable animations with `VoidUI:ToggleAnimations(false)` to see if animations are the cause. Reduce the number of visible components — only show what the user currently needs. Use `VoidUI:DestroyAll()` or `Window:Destroy()` to clean up windows that are no longer needed. Check for signal connections that are not being disconnected — these can accumulate and cause performance degradation over time.

### Error Messages

If you see error messages in the console:

Read the error message carefully — it usually indicates the file and line number where the error occurred. Check that all required parameters are provided in component configuration tables. Verify that callback functions are actually functions and not nil or other types. Use `pcall` to wrap potentially failing operations and handle errors gracefully.

## Getting Help

If you cannot resolve an issue using this troubleshooting guide, try the following:

1. Review the [API Reference](./03-api-reference.md) and [Components](./04-components.md) documentation to ensure you are using the API correctly.
2. Check the [Examples](./09-examples.md) for working code that demonstrates proper usage patterns.
3. Search the project's GitHub issues for similar problems that others may have encountered.
4. If you cannot find a solution, open a new issue on GitHub with a clear description of the problem, the code that triggers it, and any error messages you see.
