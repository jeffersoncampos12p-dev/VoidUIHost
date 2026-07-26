--[[
    VoidUI - Notifications & Dialogs Example
    =========================================
    Demonstrates the notification system, dialogs,
    toasts, and context menus.
]]

local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- Create the main window
local Window = VoidUI:CreateWindow({
    Title = "Notifications Demo",
    SubTitle = "Test all notification types",
    Theme = "Dark",
    Size = Vector2.new(480, 440),
})

local Tab = Window:AddTab({ Title = "Notifications" })

-- ============================================================
-- Notification Types Section
-- ============================================================
local NotifySection = Tab:AddSection({
    Title = "Notifications",
    Description = "Show different notification types",
})

NotifySection:AddButton({
    Text = "Info Notification",
    Style = "Primary",
    OnClick = function()
        VoidUI:Notify({
            Title = "Information",
            Description = "This is an informational notification.",
            Duration = 4,
        })
    end,
})

NotifySection:AddButton({
    Text = "Success Notification",
    Style = "Success",
    OnClick = function()
        VoidUI:NotifySuccess({
            Title = "Success!",
            Description = "Your changes have been saved successfully.",
        })
    end,
})

NotifySection:AddButton({
    Text = "Warning Notification",
    Style = "Secondary",
    OnClick = function()
        VoidUI:NotifyWarning({
            Title = "Warning",
            Description = "Please review your settings before continuing.",
        })
    end,
})

NotifySection:AddButton({
    Text = "Error Notification",
    Style = "Danger",
    OnClick = function()
        VoidUI:NotifyError({
            Title = "Error",
            Description = "Something went wrong. Please try again.",
        })
    end,
})

-- ============================================================
-- Toasts Section (Stacked Notifications)
-- ============================================================
local ToastsSection = Tab:AddSection({
    Title = "Toasts",
    Description = "Stacked, dismissible notifications",
})

ToastsSection:AddButton({
    Text = "Show Toast (Info)",
    Style = "Primary",
    OnClick = function()
        VoidUI:Toast({
            Title = "Toast Info",
            Description = "This is a toast notification.",
            Variant = "Info",
        })
    end,
})

ToastsSection:AddButton({
    Text = "Show Toast (Success)",
    Style = "Success",
    OnClick = function()
        VoidUI:Toast({
            Title = "Toast Success",
            Description = "Operation completed!",
            Variant = "Success",
        })
    end,
})

ToastsSection:AddButton({
    Text = "Dismiss All Toasts",
    Style = "Ghost",
    OnClick = function()
        VoidUI:GetToasts():DismissAll()
    end,
})

-- ============================================================
-- Dialogs Section
-- ============================================================
local DialogSection = Tab:AddSection({
    Title = "Dialogs",
    Description = "Modal dialogs for user confirmation",
})

DialogSection:AddButton({
    Text = "Show Confirmation Dialog",
    Style = "Primary",
    OnClick = function()
        VoidUI:ShowDialog({
            Title = "Confirm Action",
            Message = "Are you sure you want to perform this action? This cannot be undone.",
            Buttons = {
                { Text = "Cancel", Style = "Secondary" },
                { Text = "Confirm", Style = "Primary" },
            },
            OnConfirm = function()
                VoidUI:NotifySuccess({
                    Title = "Confirmed",
                    Description = "The action was confirmed.",
                })
            end,
            OnCancel = function()
                print("Dialog cancelled")
            end,
        })
    end,
})

DialogSection:AddButton({
    Text = "Show Warning Dialog",
    Style = "Danger",
    OnClick = function()
        VoidUI:ShowDialog({
            Title = "Delete Item",
            Message = "This will permanently delete the selected item. Are you sure?",
            Variant = "Warning",
            Buttons = {
                { Text = "Cancel", Style = "Secondary" },
                { Text = "Delete", Style = "Danger" },
            },
            OnConfirm = function()
                VoidUI:NotifySuccess({
                    Title = "Deleted",
                    Description = "The item has been deleted.",
                })
            end,
        })
    end,
})

-- ============================================================
-- Context Menu Section
-- ============================================================
local ContextSection = Tab:AddSection({
    Title = "Context Menu",
    Description = "Right-click the button below to see a context menu",
})

-- Create a button with a right-click context menu
local ContextButton = ContextSection:AddButton({
    Text = "Right-click me for a context menu!",
    Style = "Primary",
    OnClick = function()
        VoidUI:NotifyInfo({
            Title = "Left Click",
            Description = "You left-clicked! Try right-clicking for the context menu.",
        })
    end,
})

-- Attach a context menu to the button
VoidUI:GetEvents():OnRightClick(ContextButton.Instance, {
    {
        Text = "Copy",
        Icon = "rbxassetid://3928344256",
        OnSelect = function()
            VoidUI:NotifyInfo({ Title = "Copied", Description = "Content copied to clipboard." })
        end,
    },
    {
        Text = "Share",
        OnSelect = function()
            print("Share clicked")
        end,
    },
    { Separator = true },
    {
        Text = "Delete",
        Danger = true,
        OnSelect = function()
            VoidUI:NotifyError({ Title = "Deleted", Description = "Item deleted." })
        end,
    },
})

print("[VoidUI] Notifications and dialogs example loaded!")
