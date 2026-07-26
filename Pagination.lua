--[[
    VoidUI | Pagination Component
    Pagination controls for navigating through paged content. Supports
    page numbers, previous/next buttons, and current page indicator.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local Pagination = {}
Pagination.__index = Pagination
setmetatable(Pagination, { __index = Component })

function Pagination.new(config, voidUI)
    local self = Component.new("Pagination")
    setmetatable(self, { __index = Pagination })

    config = config or {}
    self._totalPages = config.TotalPages or 1
    self._currentPage = config.CurrentPage or 1
    self._maxVisible = config.MaxVisible or 7

    self.OnPageChange = self:AddSignal("OnPageChange")

    self:_createUI()
    return self
end

function Pagination:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "Pagination",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = nil,
    })

    self._layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = self.Frame,
    })

    self:_render()
end

function Pagination:_createPageButton(pageNum, isActive)
    local theme = Theme.Current()

    local btn = Create("TextButton", {
        Name = "Page_" .. pageNum,
        BackgroundColor3 = isActive and theme.Accent.Primary or theme.Component.Background,
        BackgroundTransparency = isActive and 0 or 0.5,
        Size = UDim2.new(0, 32, 0, 32),
        AutoButtonColor = false,
        Font = theme.Font or Enum.Font.GothamMedium,
        Text = tostring(pageNum),
        TextColor3 = isActive and Color3.new(1, 1, 1) or theme.Text.Secondary,
        TextSize = 12,
        Parent = self.Frame,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })

    if not isActive then
        Anim.AddHover(btn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })
        btn.MouseButton1Click:Connect(function()
            self:SetPage(pageNum)
        end)
    end

    return btn
end

function Pagination:_createNavButton(text, enabled, callback)
    local theme = Theme.Current()

    local btn = Create("TextButton", {
        Name = "Nav_" .. text,
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = enabled and 0.5 or 0.8,
        Size = UDim2.new(0, 32, 0, 32),
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = enabled and theme.Text.Secondary or theme.Text.Tertiary,
        TextSize = 12,
        Parent = self.Frame,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })

    if enabled then
        Anim.AddHover(btn, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

function Pagination:_render()
    -- Clear existing
    for _, child in ipairs(self.Frame:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    -- Previous button
    self:_createNavButton("‹", self._currentPage > 1, function()
        self:SetPage(self._currentPage - 1)
    end)

    -- Page buttons
    local startPage = math.max(1, self._currentPage - math.floor(self._maxVisible / 2))
    local endPage = math.min(self._totalPages, startPage + self._maxVisible - 1)
    startPage = math.max(1, endPage - self._maxVisible + 1)

    if startPage > 1 then
        self:_createPageButton(1, self._currentPage == 1)
        if startPage > 2 then
            local ellipsis = Create("TextLabel", {
                Name = "Ellipsis1",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 32),
                Font = theme.Font or Enum.Font.Gotham,
                Text = "...",
                TextColor3 = theme.Text.Tertiary,
                TextSize = 12,
                Parent = self.Frame,
            })
        end
    end

    for p = startPage, endPage do
        self:_createPageButton(p, p == self._currentPage)
    end

    if endPage < self._totalPages then
        if endPage < self._totalPages - 1 then
            local theme = Theme.Current()
            local ellipsis = Create("TextLabel", {
                Name = "Ellipsis2",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 32),
                Font = theme.Font or Enum.Font.Gotham,
                Text = "...",
                TextColor3 = theme.Text.Tertiary,
                TextSize = 12,
                Parent = self.Frame,
            })
        end
        self:_createPageButton(self._totalPages, self._currentPage == self._totalPages)
    end

    -- Next button
    self:_createNavButton("›", self._currentPage < self._totalPages, function()
        self:SetPage(self._currentPage + 1)
    end)
end

function Pagination:SetPage(page)
    if page < 1 or page > self._totalPages then return end
    self._currentPage = page
    self.OnPageChange:Fire(page)
    self:_render()
end

function Pagination:GetPage()
    return self._currentPage
end

function Pagination:SetTotalPages(total)
    self._totalPages = total
    if self._currentPage > total then
        self._currentPage = total
    end
    self:_render()
end

function Pagination:_applyThemeImpl(theme)
    self:_render()
end

return Pagination
