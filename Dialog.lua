--[[
    VoidUI | Dialog Component
    A pre-built modal dialog with title, message, and configurable buttons
    (Confirm, Cancel, or custom). Supports variants (info, warning, danger)
    and icon display.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Dialog = {}
Dialog.__index = Dialog
setmetatable(Dialog, { __index = Component })

local VARIANT_COLORS = {
    Info = Color3.fromRGB(33, 150, 243),
    Warning = Color3.fromRGB(255, 193, 7),
    Danger = Color3.fromRGB(244, 67, 54),
    Success = Color3.fromRGB(76, 175, 80),
}

function Dialog.new(config, voidUI)
    local self = Component.new("Dialog")
    setmetatable(self, { __index = Dialog })

    config = config or {}
    self._title = config.Title or "Dialog"
    self._message = config.Message or config.Content or ""
    self._variant = config.Variant or "Info"
    self._buttons = config.Buttons or { "OK", "Cancel" }
    self._icon = config.Icon or nil

    self.OnConfirm = self:AddSignal("OnConfirm")
    self.OnCancel = self:AddSignal("OnCancel")
    self.OnButton = self:AddSignal("OnButton")

    self:_createUI()
    return self
end

function Dialog:_createUI()
    local theme = Theme.Current()
    local accentColor = VARIANT_COLORS[self._variant] or VARIANT_COLORS.Info

    -- Use Modal as base
    local Modal = require(script.Parent.Modal)
    self._modal = Modal.new({
        Title = self._title,
        Size = UDim2.new(0, 380, 0, 220),
        Closable = false,
        CloseOnBackdrop = false,
    }, voidUI)

    self.Frame = self._modal.Frame
    self.Content = self._modal.Content

    -- Icon
    if self._icon then
        local iconFrame = Create("Frame", {
            Name = "IconFrame",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = self.Content,
        })
        self.IconLabel = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 40, 0, 40),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Image = self._icon,
            ImageColor3 = accentColor,
            Parent = iconFrame,
        })
    end

    -- Message
    self.Message = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = theme.Font or Enum.Font.Gotham,
        Text = self._message,
        TextColor3 = theme.Text.Secondary,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.Content,
    })

    -- Button container
    local ButtonContainer = require(script.Parent.Button)
    local btnHolder = Create("Frame", {
        Name = "ButtonHolder",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.Content,
    })

    local btnLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
        Parent = btnHolder,
    })

    -- Create buttons
    for i, btnText in ipairs(self._buttons) do
        local isPrimary = (i == 1)
        local btn = ButtonContainer.new({
            Text = btnText,
            Style = isPrimary and "Primary" or "Secondary",
            Size = UDim2.new(0, 100, 0, 32),
        })
        btn.Frame.Parent = btnHolder
        btn.OnClick:Connect(function()
            self.OnButton:Fire(btnText, i)
            if isPrimary then
                self.OnConfirm:Fire()
            elseif btnText:lower():find("cancel") or btnText:lower():find("close") then
                self.OnCancel:Fire()
            end
            self:Close()
        end)
    end
end

function Dialog:Open()
    self._modal:Open()
end

function Dialog:Close()
    self._modal:Close()
end

function Dialog:SetMessage(message)
    self._message = message
    if self.Message then self.Message.Text = message end
end

function Dialog:SetTitle(title)
    self._title = title
    self._modal:SetTitle(title)
end

function Dialog:_applyThemeImpl(theme)
    if self.Message then self.Message.TextColor3 = theme.Text.Secondary end
    if self._modal then self._modal:_ApplyTheme(theme) end
end

function Dialog:Destroy()
    if self._modal then self._modal:Destroy() end
    Component.Destroy(self)
end

return Dialog
