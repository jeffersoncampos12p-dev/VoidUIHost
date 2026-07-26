# Events & Callbacks

VoidUI uses a signal-based event system for handling callbacks and communication between components. This document explains the signal system, the promise system, and the event patterns used throughout the library.

## The Signal System

At the heart of VoidUI's event handling is the Signal class, which provides a lightweight, efficient implementation of the observer pattern. A signal is an object that can be connected to multiple listener functions. When the signal is fired, all connected listeners are called with the provided arguments.

### Creating Signals

Signals are created using the Signal constructor from the VoidCore module. Most components create their own signals internally and expose them as properties, so you typically do not need to create signals yourself. However, you can create custom signals for your own use cases.

```lua
local Core = VoidUI:GetCore()
local Signal = Core.Signal

local mySignal = Signal.new()

mySignal:Connect(function(value)
    print("Signal fired with:", value)
end)

mySignal:Fire("Hello!")  -- prints: "Signal fired with: Hello!"
```

### Connecting to Signals

You connect a listener function to a signal using the `:Connect` method. This returns a connection object that you can use to disconnect the listener later.

```lua
local connection = mySignal:Connect(function()
    print("Listener called")
end)

-- Later, disconnect
connection:Disconnect()
```

The connection object has a `Disconnect` method that removes the listener from the signal. This is important for cleaning up event listeners to prevent memory leaks and unwanted callbacks.

### Firing Signals

You fire a signal using the `:Fire` method, passing any arguments you want to send to the listeners. All connected listeners are called synchronously in the order they were connected.

```lua
mySignal:Fire(arg1, arg2, arg3)
```

### Signal Properties

- `Signal:Connect(callback)` — Connects a listener function, returns a connection
- `Signal:Fire(...)` — Fires the signal with the given arguments
- `Signal:Wait()` — Yields until the signal is fired, returns the arguments
- `Signal:DisconnectAll()` — Disconnects all listeners
- `Signal:GetConnections()` — Returns the number of connected listeners

### Component Signals

Every VoidUI component exposes signals as properties that you can connect to. These signals are named with an `On` prefix to indicate they are event signals. For example, a Button has an `OnClick` signal, a Toggle has an `OnChanged` signal, and a Window has `OnClose`, `OnOpen`, `OnResize`, `OnFocus`, `OnMinimize`, and `OnMaximize` signals.

```lua
local button = Section:CreateButton({
    Text = "Save",
    Callback = function() print("Saved!") end,
})

-- The Callback is a convenience that connects to OnClick internally
-- You can also connect directly to the signal
button.OnClick:Connect(function()
    print("Button was clicked!")
end)
```

The `Callback` parameter in component configuration is a convenience that automatically connects to the primary signal for that component. For a Button, the callback is connected to `OnClick`. For a Toggle, it is connected to `OnChanged`. For a Dropdown, it is connected to `OnChanged`, and so on.

Using the `Callback` parameter is the simplest way to handle component events for most use cases. Using the signal directly gives you more control, such as connecting multiple listeners or managing connections dynamically.

## The Promise System

VoidUI includes a Promise implementation for handling asynchronous operations. Promises provide a clean, chainable API for managing async workflows and are particularly useful for operations that may succeed or fail.

### Creating Promises

```lua
local Core = VoidUI:GetCore()
local Promise = Core.Promise

local myPromise = Promise.new(function(resolve, reject)
    -- Do something asynchronous
    if success then
        resolve(result)
    else
        reject(error)
    end
end)
```

### Using Promises

```lua
myPromise
    :Then(function(result)
        print("Success:", result)
        return processedResult
    end)
    :Catch(function(err)
        print("Error:", err)
    end)
    :Finally(function()
        print("Done (regardless of success or failure)")
    end)
```

### Promise Methods

- `Promise.new(executor)` — Creates a new promise with an executor function
- `Promise.resolve(value)` — Creates an immediately resolved promise
- `Promise.reject(error)` — Creates an immediately rejected promise
- `Promise.all(promises)` — Waits for all promises to resolve
- `Promise.race(promises)` — Returns the first promise to settle
- `promise:Then(onSuccess, onError)` — Chains success and error handlers
- `promise:Catch(onError)` — Handles errors
- `promise:Finally(onFinally)` — Runs after completion regardless of outcome
- `promise:Await()` — Yields and returns the result or error synchronously

## The Event System

The EventSystem module provides a global event dispatcher for cross-component communication. This is useful for communication between components that do not have a direct reference to each other.

### Global Events

```lua
local Events = VoidUI:GetEvents()

-- Listen for a global event
Events.Global:Connect("myCustomEvent", function(...)
    print("Event received:", ...)
end)

-- Fire a global event
Events.Global:Fire("myCustomEvent", "arg1", "arg2")
```

The global event system allows any part of your application to communicate with any other part without needing direct references. This is particularly useful for decoupled architectures where components need to communicate without knowing about each other.

### Keybind System

The EventSystem also includes a keybind management system that allows you to register keyboard shortcuts globally.

```lua
local Events = VoidUI:GetEvents()

Events.Keybinds:Register("Ctrl+S", function()
    print("Save triggered")
end)
```

## Auto-Disconnection

VoidUI components automatically disconnect their signals when they are destroyed. This means that when a component is destroyed (either explicitly via `:Destroy()` or when its parent window is destroyed), all signal connections associated with that component are cleaned up automatically.

However, if you create your own connections to component signals, you should manage those connections yourself. Store the connection object and disconnect it when no longer needed, or ensure it is disconnected before the component is destroyed.

```lua
local connection = button.OnClick:Connect(function() end)

-- When you are done with the button:
connection:Disconnect()
button:Destroy()
```

## Best Practices

Always disconnect connections when they are no longer needed. While the library handles cleanup for internal connections, your own connections should be managed to prevent memory leaks. Use the connection object's `Disconnect` method or the signal's `DisconnectAll` method.

For most use cases, the `Callback` parameter in component configuration is sufficient and the simplest approach. Only use the signal directly when you need multiple listeners, dynamic connection management, or the `Wait` yielding behavior.

When using promises, always include a `Catch` handler to handle errors gracefully. Unhandled promise rejections can lead to confusing behavior that is hard to debug.

For global events, use clear, unique event names to avoid collisions. A common convention is to prefix event names with the module or component name, such as `"settings:changed"` or `"window:closed"`.
