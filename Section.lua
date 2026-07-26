--[[
    VoidUI - Section Component
    A collapsible section within a tab, containing a title and
    optional content with a grouped layout.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)
local ThemeSystem = require(script.Parent.theme.ThemeSystem)
local AnimationSystem = require(script.Parent.animation.AnimationSystem)
local Component = require(script.Component)

local Section = setmetatable({}, {__index = Component})
Section.__index = Section

-- ============================================================
-- Section Factory
-- ============================================================
function Section.new(title, tab, options)
    local self = Component.new("Section")
    setmetatable(self, {__index = Section})
    
    self.Title = title
    self._tab = tab
    self._components = {}
    self._collapsed = false
    
    options = options or {}
    self._collapsible = options.Collapsible or false
    self._defaultCollapsed = options.Collapsed or false
    self._side = options.Side or "Left" -- For two-column layout
    
    -- Section events
    self.OnCollapse = self:AddSignal("OnCollapse")
    self.OnExpand = self:AddSignal("OnExpand")
    
    self:_createUI()
    
    if self._defaultCollapsed then
        self:_collapse(true)
    end
    
    return self
end

-- ============================================================
-- UI Creation
-- ============================================================
function Section:_createUI()
    local theme = ThemeSystem:Current()
    
    -- Section container
    local container = Core.Create("Frame", {
        Name = "Section_" .. self.Title:gsub("%s", "_"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    self.Instance = container
    
    -- Title bar
    local titleBar = Core.Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, container)
    self._titleBar = titleBar
    
    -- Section title text
    local title = Core.Create("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = theme.Font,
        TextSize = theme.TextSize.Small,
        TextColor3 = theme.Text.Tertiary,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        TextTruncate = Enum.TextTruncate.Ellipsis,
        ZIndex = 2,
    }, titleBar)
    self._title = title
    
    -- Collapse icon (if collapsible)
    if self._collapsible then
        local icon = Core.Create("ImageLabel", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(1, -14, 0.5, -7),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://12634914130",
            ImageColor3 = theme.Text.Tertiary,
            Rotation = 90,
            ZIndex = 2,
        }, titleBar)
        self._collapseIcon = icon
        
        -- Click handler
        local hitbox = Core.Create("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 3,
        }, titleBar)
        self._titleHitbox = hitbox
        
        hitbox.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
    end
    
    -- Content container
    local content = Core.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, container)
    self._content = content
    
    -- Corner
    local corner = Core.Create("UICorner", {
        CornerRadius = theme.Corner.Medium,
    }, content)
    self._corner = corner
    
    -- Stroke
    local stroke = Core.Create("UIStroke", {
        Color = theme.Border.Default,
        Thickness = theme.Stroke.Size,
        Transparency = 0.7,
    }, content)
    self._stroke = stroke
    
    -- Padding for content (UI padding)
    local uiPadding = Core.Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, content)
    
    -- Layout
    local layout = Core.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)
    self._layout = layout
end

-- ============================================================
-- Collapse / Expand
-- ============================================================
function Section:_collapse(noAnim)
    self._collapsed = true
    
    -- Hide content
    if noAnim then
        self._content.Visible = false
    else
        AnimationSystem:Tween(self._content, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(0.25, function()
            if self._collapsed then
                self._content.Visible = false
            end
        end)
    end
    
    -- Rotate icon
    if self._collapseIcon then
        AnimationSystem:Tween(self._collapseIcon, {Rotation = 0}, 0.2)
    end
    
    self.OnCollapse:Fire()
end

function Section:_expand(noAnim)
    self._collapsed = false
    
    self._content.Visible = true
    if not noAnim then
        AnimationSystem:Tween(self._content, {BackgroundTransparency = 0.3}, 0.25)
    end
    
    if self._collapseIcon then
        AnimationSystem:Tween(self._collapseIcon, {Rotation = 90}, 0.2)
    end
    
    self.OnExpand:Fire()
end

function Section:Toggle()
    if self._collapsed then
        self:_expand()
    else
        self:_collapse()
    end
end

-- ============================================================
-- Component Management
-- ============================================================
function Section:Add(component)
    table.insert(self._components, component)
    if component.Instance then
        component.Instance.Parent = self._content
    end
    return component
end

function Section:CreateButton(options)
    local Button = require(script.Button)
    local btn = Button.new(options, self)
    return self:Add(btn)
end

function Section:CreateToggle(options)
    local Toggle = require(script.Toggle)
    local toggle = Toggle.new(options, self)
    return self:Add(toggle)
end

function Section:CreateCheckbox(options)
    local Checkbox = require(script.Checkbox)
    local cb = Checkbox.new(options, self)
    return self:Add(cb)
end

function Section:CreateSlider(options)
    local Slider = require(script.Slider)
    local slider = Slider.new(options, self)
    return self:Add(slider)
end

function Section:CreateDropdown(options)
    local Dropdown = require(script.Dropdown)
    local dropdown = Dropdown.new(options, self)
    return self:Add(dropdown)
end

function Section:CreateMultiDropdown(options)
    local MultiDropdown = require(script.MultiDropdown)
    local md = MultiDropdown.new(options, self)
    return self:Add(md)
end

function Section:CreateColorPicker(options)
    local ColorPicker = require(script.ColorPicker)
    local cp = ColorPicker.new(options, self)
    return self:Add(cp)
end

function Section:CreateKeybind(options)
    local Keybind = require(script.Keybind)
    local kb = Keybind.new(options, self)
    return self:Add(kb)
end

function Section:CreateTextbox(options)
    local Textbox = require(script.Textbox)
    local tb = Textbox.new(options, self)
    return self:Add(tb)
end

function Section:CreateLabel(options)
    local Label = require(script.Label)
    local label = Label.new(options, self)
    return self:Add(label)
end

function Section:CreateParagraph(options)
    local Paragraph = require(script.Paragraph)
    local p = Paragraph.new(options, self)
    return self:Add(p)
end

function Section:CreateDivider(options)
    local Divider = require(script.Divider)
    local d = Divider.new(options, self)
    return self:Add(d)
end

function Section:CreateSpacer(options)
    local Spacer = require(script.Spacer)
    local s = Spacer.new(options, self)
    return self:Add(s)
end

function Section:CreateBadge(options)
    local Badge = require(script.Badge)
    local b = Badge.new(options, self)
    return self:Add(b)
end

function Section:CreateProgressBar(options)
    local ProgressBar = require(script.ProgressBar)
    local pb = ProgressBar.new(options, self)
    return self:Add(pb)
end

function Section:CreateAccordion(options)
    local Accordion = require(script.Accordion)
    local acc = Accordion.new(options, self)
    return self:Add(acc)
end

function Section:CreateCard(options)
    local Card = require(script.Card)
    local card = Card.new(options, self)
    return self:Add(card)
end

function Section:CreateTag(options)
    local Tag = require(script.Tag)
    local tag = Tag.new(options, self)
    return self:Add(tag)
end

function Section:CreateChip(options)
    local Chip = require(script.Chip)
    local chip = Chip.new(options, self)
    return self:Add(chip)
end

function Section:CreateStatusIndicator(options)
    local StatusIndicator = require(script.StatusIndicator)
    local si = StatusIndicator.new(options, self)
    return self:Add(si)
end

function Section:CreateImage(options)
    local Image = require(script.Image)
    local img = Image.new(options, self)
    return self:Add(img)
end

function Section:CreateAvatar(options)
    local Avatar = require(script.Avatar)
    local av = Avatar.new(options, self)
    return self:Add(av)
end

function Section:CreateSearchBox(options)
    local SearchBox = require(script.SearchBox)
    local sb = SearchBox.new(options, self)
    return self:Add(sb)
end

function Section:CreateInput(options)
    local Input = require(script.Input)
    local input = Input.new(options, self)
    return self:Add(input)
end

function Section:CreatePasswordInput(options)
    local PasswordInput = require(script.PasswordInput)
    local pi = PasswordInput.new(options, self)
    return self:Add(pi)
end

function Section:CreateCodeEditor(options)
    local CodeEditor = require(script.CodeEditor)
    local ce = CodeEditor.new(options, self)
    return self:Add(ce)
end

function Section:CreateTreeView(options)
    local TreeView = require(script.TreeView)
    local tv = TreeView.new(options, self)
    return self:Add(tv)
end

function Section:CreateList(options)
    local List = require(script.List)
    local list = List.new(options, self)
    return self:Add(list)
end

function Section:CreateDataTable(options)
    local DataTable = require(script.DataTable)
    local dt = DataTable.new(options, self)
    return self:Add(dt)
end

function Section:CreatePagination(options)
    local Pagination = require(script.Pagination)
    local pg = Pagination.new(options, self)
    return self:Add(pg)
end

function Section:CreateBreadcrumb(options)
    local Breadcrumb = require(script.Breadcrumb)
    local bc = Breadcrumb.new(options, self)
    return self:Add(bc)
end

-- ============================================================
-- Theme Application
-- ============================================================
function Section:_applyThemeImpl(theme)
    if self._title then
        self._title.Font = theme.Font
        self._title.TextColor3 = theme.Text.Tertiary
    end
    if self._collapseIcon then
        self._collapseIcon.ImageColor3 = theme.Text.Tertiary
    end
    if self._content then
        self._content.BackgroundColor3 = theme.Component.Background
    end
    if self._stroke then
        self._stroke.Color = theme.Border.Default
    end
end

return Section
