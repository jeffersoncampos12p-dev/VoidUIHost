--[[
    VoidUI - Loading & Splash Screen Example
    =========================================
    Demonstrates loading screens, splash screens, and
    welcome/onboarding screens.
]]

local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- ============================================================
-- 1. Show a Loading Screen with Progress
-- ============================================================
local LoadingScreen = VoidUI:ShowLoadingScreen({
    Title = "Loading VoidUI",
    SubTitle = "Initializing components...",
})

-- Simulate loading progress
local steps = {
    { progress = 20, text = "Loading core modules..." },
    { progress = 40, text = "Initializing theme system..." },
    { progress = 60, text = "Loading components..." },
    { progress = 80, text = "Setting up event system..." },
    { progress = 100, text = "Ready!" },
}

for _, step in ipairs(steps) do
    LoadingScreen:SetProgress(step.progress)
    LoadingScreen:SetText(step.text)
    task.wait(0.5)
end

LoadingScreen:Dismiss()
task.wait(0.3)

-- ============================================================
-- 2. Show a Splash Screen
-- ============================================================
local SplashScreen = VoidUI:ShowSplashScreen({
    BrandName = "VoidUI",
    Tagline = "The future of Lua UI libraries",
    Duration = 3,
})

SplashScreen.OnDismiss:Connect(function()
    print("Splash screen dismissed, showing welcome screen...")
end)

task.wait(3.5)

-- ============================================================
-- 3. Show a Welcome / Onboarding Screen
-- ============================================================
local WelcomeScreen = VoidUI:ShowWelcomeScreen({
    Steps = {
        {
            Title = "Welcome to VoidUI",
            Description = "The most modern, elegant, and complete UI library for Lua/LuaU.",
            Icon = "rbxassetid://3928340255",
        },
        {
            Title = "50+ Components",
            Description = "From buttons to data tables, VoidUI has everything you need to build beautiful interfaces.",
            Icon = "rbxassetid://3928340378",
        },
        {
            Title = "6 Built-in Themes",
            Description = "Choose from Dark, Light, Midnight, Sunset, Forest, and Cyber, or create your own.",
            Icon = "rbxassetid://3928340501",
        },
        {
            Title = "Ready to Go!",
            Description = "You're all set. Start building amazing interfaces with VoidUI today!",
            Icon = "rbxassetid://3928340639",
        },
    },
})

WelcomeScreen.OnComplete:Connect(function()
    VoidUI:NotifySuccess({
        Title = "Welcome Complete!",
        Description = "You're ready to start using VoidUI.",
    })
end)

WelcomeScreen.OnSkip:Connect(function()
    print("User skipped the welcome screen")
end)

task.wait(1)

-- ============================================================
-- 4. Create the Main Window After Loading
-- ============================================================
local Window = VoidUI:CreateWindow({
    Title = "VoidUI",
    SubTitle = "Loading complete!",
    Theme = "Dark",
    Size = Vector2.new(440, 360),
})

local Tab = Window:AddTab({ Title = "Home" })
local Section = Tab:AddSection({
    Title = "Welcome!",
    Description = "Loading and splash screens demo complete",
})

Section:AddParagraph({
    Text = "This example demonstrated loading screens, splash screens, and welcome/onboarding screens. Check the console for logs.",
})

Section:AddButton({
    Text = "Show Loading Screen Again",
    Style = "Primary",
    OnClick = function()
        local ls = VoidUI:ShowLoadingScreen({
            Title = "Reloading",
            SubTitle = "Please wait...",
        })
        for i = 0, 100, 10 do
            ls:SetProgress(i)
            task.wait(0.2)
        end
        ls:Dismiss()
    end,
})

Section:AddButton({
    Text = "Show Splash Again",
    Style = "Secondary",
    OnClick = function()
        VoidUI:ShowSplashScreen({
            BrandName = "VoidUI",
            Tagline = "Reloaded!",
            Duration = 2,
        })
    end,
})

print("[VoidUI] Loading and splash screen example loaded!")
