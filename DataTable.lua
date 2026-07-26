--[[
    VoidUI | DataTable Component
    A tabular data display with columns, rows, sorting, and selection.
    Supports column headers, data rows, sortable columns, and row selection.
]]

local Component = require(script.Parent.Component)
local Theme = require(script.Parent.Parent.theme.ThemeSystem)
local Anim = require(script.Parent.Parent.animation.AnimationSystem)
local VoidCore = require(script.Parent.Parent.core.VoidCore)

local Create = VoidCore.Create

local DataTable = {}
DataTable.__index = DataTable
setmetatable(DataTable, { __index = Component })

function DataTable.new(config, voidUI)
    local self = Component.new("DataTable")
    setmetatable(self, { __index = DataTable })

    config = config or {}
    self._columns = config.Columns or {}
    self._rows = config.Rows or {}
    self._size = config.Size or UDim2.new(1, 0, 0, 300)
    self._sortable = config.Sortable or true
    self._sortColumn = nil
    self._sortAscending = true

    self.OnRowSelect = self:AddSignal("OnRowSelect")
    self.OnSort = self:AddSignal("OnSort")

    self:_createUI()
    return self
end

function DataTable:_createUI()
    local theme = Theme.Current()

    self.Frame = Create("Frame", {
        Name = "DataTable",
        BackgroundColor3 = theme.Component.Background,
        BackgroundTransparency = 0.5,
        Size = self._size,
        ClipsDescendants = true,
        Parent = nil,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Frame })
    self.Stroke = Create("UIStroke", {
        Color = theme.Component.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = self.Frame,
    })

    local layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Parent = self.Frame,
    })

    -- Header row
    self._header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = theme.Component.Header,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.Frame,
    })

    local hLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = self._header,
    })

    -- Create header cells
    self._headerCells = {}
    local totalWidth = 0
    for i, col in ipairs(self._columns) do
        local cellWidth = col.Width or (1 / #self._columns)
        local cell = Create("TextButton", {
            Name = "Col_" .. (col.Label or "Col"),
            BackgroundTransparency = 1,
            Size = UDim2.new(cellWidth, 0, 1, 0),
            AutoButtonColor = false,
            Font = theme.Font or Enum.Font.GothamMedium,
            Text = col.Label or "Column",
            TextColor3 = theme.Text.Secondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self._header,
        })
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            Parent = cell,
        })

        if self._sortable then
            Anim.AddHover(cell, { HoverColor = theme.Component.Hover, HoverTransparency = 0.7 })
            cell.MouseButton1Click:Connect(function()
                self:_sortBy(col.Key or col.Label)
            end)
        end

        self._headerCells[i] = cell
        totalWidth = totalWidth + cellWidth
    end

    -- Body (scrollable)
    self._body = Create("ScrollingFrame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Component.ScrollBar,
        Parent = self.Frame,
    })

    self._bodyContainer = Create("Frame", {
        Name = "BodyContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self._body,
    })

    self._rowLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Parent = self._bodyContainer,
    })

    self:_renderRows()
end

function DataTable:_renderRows()
    -- Clear existing rows
    for _, child in ipairs(self._bodyContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local theme = Theme.Current()

    for i, rowData in ipairs(self._rows) do
        local row = Create("TextButton", {
            Name = "Row_" .. i,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = i,
            Parent = self._bodyContainer,
        })

        local rLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = row,
        })

        for j, col in ipairs(self._columns) do
            local cellWidth = col.Width or (1 / #self._columns)
            local value = rowData[col.Key] or ""

            local cell = Create("TextLabel", {
                Name = "Cell_" .. j,
                BackgroundTransparency = 1,
                Size = UDim2.new(cellWidth, 0, 1, 0),
                Font = theme.Font or Enum.Font.Gotham,
                Text = tostring(value),
                TextColor3 = theme.Text.Primary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                Parent = cell,
            })
        end

        -- Alternating row backgrounds
        if i % 2 == 0 then
            row.BackgroundColor3 = theme.Component.Hover
            row.BackgroundTransparency = 0.8
        end

        Anim.AddHover(row, { HoverColor = theme.Component.Hover, HoverTransparency = 0.6 })

        row.MouseButton1Click:Connect(function()
            self.OnRowSelect:Fire(rowData, i)
        end)
    end
end

function DataTable:_sortBy(key)
    if self._sortColumn == key then
        self._sortAscending = not self._sortAscending
    else
        self._sortColumn = key
        self._sortAscending = true
    end

    table.sort(self._rows, function(a, b)
        local va, vb = a[key] or "", b[key] or ""
        if self._sortAscending then
            return tostring(va) < tostring(vb)
        else
            return tostring(va) > tostring(vb)
        end
    end)

    self.OnSort:Fire(key, self._sortAscending)
    self:_renderRows()
end

function DataTable:SetRows(rows)
    self._rows = rows
    self:_renderRows()
end

function DataTable:AddRow(rowData)
    table.insert(self._rows, rowData)
    self:_renderRows()
end

function DataTable:Clear()
    self._rows = {}
    self:_renderRows()
end

function DataTable:_applyThemeImpl(theme)
    self.Frame.BackgroundColor3 = theme.Component.Background
    if self.Stroke then self.Stroke.Color = theme.Component.Border end
    self._header.BackgroundColor3 = theme.Component.Header
    for _, cell in ipairs(self._headerCells or {}) do
        cell.TextColor3 = theme.Text.Secondary
    end
    self._body.ScrollBarImageColor3 = theme.Component.ScrollBar
    self:_renderRows()
end

return DataTable
