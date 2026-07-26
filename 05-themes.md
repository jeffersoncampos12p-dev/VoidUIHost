# Themes

VoidUI includes a powerful theming system that controls the visual appearance of every component. The system ships with six built-in themes and supports unlimited custom themes created at runtime.

## Built-in Themes

VoidUI provides six carefully designed themes that cover a range of visual styles. Each theme is a table of color values, typography settings, and other properties that are applied to every component.

### Dark

The default theme, featuring a deep dark background with a soft purple accent. This theme is designed for low-light environments and provides excellent contrast for extended use. The background uses a near-black tone with a subtle blue undertone, text is a soft white, and the accent is a vibrant purple that stands out without being overwhelming. This is the recommended theme for most use cases.

### Light

A clean, bright theme with a white background and the same purple accent. Designed for daylight environments and users who prefer light interfaces. The background is a soft off-white that reduces eye strain compared to pure white, text uses a dark slate color for readability, and the accent remains the same purple as the dark theme for brand consistency.

### Midnight

A very dark, deep blue theme that is even darker than the standard Dark theme. The background uses a deep midnight blue, giving the interface a more immersive, focused feel. The accent shifts to a cooler blue-purple, complementing the deep blue background. This theme is ideal for focused work sessions and late-night use.

### Sunset

A warm theme with orange and pink accents evoking a sunset palette. The background remains dark but warmer than the standard Dark theme, with a slight orange undertone. The accent is a warm coral-orange that brings energy to the interface. This theme is perfect for applications that want a more vibrant, expressive feel.

### Forest

A nature-inspired theme with green accents. The background uses a dark green-tinted gray, and the accent is a fresh green. This theme evokes a sense of calm and natural harmony, making it suitable for productivity applications, eco-themed projects, or anyone who prefers green color schemes.

### Cyber

A vibrant, neon-themed theme with electric blue and magenta accents. The background is a very dark blue-black, and the accent is a bright electric blue with hints of magenta. This theme has a futuristic, cyberpunk aesthetic that works well for gaming interfaces, tech tools, and any application that wants to make a bold visual statement.

## Switching Themes

Switching between themes is done through the global API. When you change the theme, every registered component automatically updates its colors and visual properties.

```lua
VoidUI:SetTheme("Midnight")
```

You can also toggle between the Dark and Light themes using the convenience function:

```lua
VoidUI:ToggleTheme()
```

To get the current theme or its name:

```lua
local theme = VoidUI:GetTheme()
local themeName = VoidUI:GetThemeName()
print(themeName)  -- "Dark"
```

## Accent Color

The accent color is a special color used throughout the interface for highlights, interactive elements, and focus states. It can be changed independently of the overall theme, allowing you to customize the interface without switching the entire theme.

```lua
VoidUI:SetAccent(Color3.fromRGB(255, 100, 150))
```

When you set a custom accent color, it overrides the theme's default accent. All components will update to use the new accent color for their highlights and interactive elements.

## Creating Custom Themes

You can create your own custom themes using the `CreateTheme` function. A theme is defined by a table of color values. At minimum, a theme should include the following properties:

- `Background` — The main background color
- `BackgroundSecondary` — A slightly different background for cards and sections
- `Text` — The primary text color
- `TextSecondary` — A secondary, muted text color
- `TextMuted` — A very muted text color for labels
- `Accent` — The accent color for highlights and interactions
- `AccentHover` — A slightly different accent for hover states
- `Border` — The border color
- `Divider` — The divider line color
- `Success` — The success color (green)
- `Warning` — The warning color (amber)
- `Error` — The error color (red)
- `Info` — The info color (blue)

Here is an example of creating a custom theme:

```lua
VoidUI:CreateTheme("Ocean", {
    Background = Color3.fromRGB(12, 28, 48),
    BackgroundSecondary = Color3.fromRGB(18, 38, 62),
    Text = Color3.fromRGB(210, 230, 250),
    TextSecondary = Color3.fromRGB(160, 180, 200),
    TextMuted = Color3.fromRGB(120, 140, 160),
    Accent = Color3.fromRGB(0, 160, 220),
    AccentHover = Color3.fromRGB(40, 180, 240),
    Border = Color3.fromRGB(30, 50, 70),
    Divider = Color3.fromRGB(25, 45, 65),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(240, 180, 60),
    Error = Color3.fromRGB(240, 80, 100),
    Info = Color3.fromRGB(80, 160, 240),
})

VoidUI:SetTheme("Ocean")
```

Once created, the theme is registered and can be used with `SetTheme` by name. It will also appear in the list returned by `ListThemes()`.

## Exporting and Importing Themes

You can export the current theme to a data table for saving and later import it back. This is useful for sharing themes, persisting user preferences, or building a theme editor.

```lua
-- Export the current theme
local themeData = VoidUI:SaveTheme()
-- themeData is a table that can be JSON-encoded and saved

-- Import a theme from data
VoidUI:LoadTheme(themeData)
```

The exported theme data includes the theme name and all color values. When imported, the theme is applied immediately and all components update to reflect the new colors.

## Theme Change Events

You can listen for theme changes using the theme system's change signal. This is useful for components or logic that needs to react to theme changes beyond the automatic visual updates.

```lua
local ThemeSystem = VoidUI:GetThemeSystem()
ThemeSystem.OnChanged:Connect(function(themeName, theme)
    print("Theme changed to:", themeName)
end)
```

Every component automatically registers with the theme system and receives theme change events through its internal `_applyThemeImpl` method. You do not need to manually handle theme changes for standard components — the library handles this automatically.

## Theme Persistence

When state persistence is enabled on a window, the current theme name and accent color are included in the exported state. This means that when you export and later import the state, the theme is automatically restored to what it was when the state was exported.

```lua
-- Export state (includes theme)
local state = VoidUI:Export()

-- Later, import state (restores theme)
VoidUI:Import(state)
```

## Listing Available Themes

To get a list of all available themes (both built-in and custom), use the `ListThemes` function:

```lua
local themes = VoidUI:ListThemes()
for _, name in ipairs(themes) do
    print(name)
end
-- Dark, Light, Midnight, Sunset, Forest, Cyber, Ocean, ...
```

This is useful for building a theme selector dropdown or displaying available themes to the user.
