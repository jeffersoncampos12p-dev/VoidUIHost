--[[
    VoidUI - Data Components Example
    =================================
    Demonstrates DataTable, List, TreeView, Accordion,
    and other complex data display components.
]]

local VoidUI = loadstring(game:HttpGet(
    "https://voidui.dev/latest.lua"
))()

-- Create the main window
local Window = VoidUI:CreateWindow({
    Title = "Data Components",
    SubTitle = "Tables, lists, trees, and more",
    Theme = "Dark",
    Size = Vector2.new(640, 520),
})

-- ============================================================
-- Tab 1: Data Table
-- ============================================================
local TableTab = Window:AddTab({ Title = "DataTable" })
local TableSection = TableTab:AddSection({ Title = "User Data" })

local UserTable = TableSection:AddDataTable({
    Columns = {
        { Header = "Name", Key = "name", Width = 150 },
        { Header = "Role", Key = "role", Width = 120 },
        { Header = "Status", Key = "status", Width = 100 },
        { Header = "Score", Key = "score", Width = 80 },
    },
    Rows = {
        { name = "Alice", role = "Admin", status = "Active", score = 95 },
        { name = "Bob", role = "Editor", status = "Active", score = 82 },
        { name = "Charlie", role = "Viewer", status = "Inactive", score = 67 },
        { name = "Diana", role = "Editor", status = "Active", score = 91 },
        { name = "Eve", role = "Admin", status = "Pending", score = 78 },
    },
    Sortable = true,
    OnRowSelect = function(row)
        VoidUI:NotifyInfo({
            Title = "Row Selected",
            Description = "You selected: " .. row.name .. " (" .. row.role .. ")",
            Duration = 3,
        })
    end,
    OnSort = function(column, direction)
        print("Sorted by", column, direction)
    end,
})

-- Add a button to add more rows
TableSection:AddButton({
    Text = "Add Random Row",
    Style = "Primary",
    OnClick = function()
        local names = { "Frank", "Grace", "Henry", "Ivy", "Jack" }
        local roles = { "Admin", "Editor", "Viewer" }
        local statuses = { "Active", "Inactive", "Pending" }
        local name = names[math.random(#names)]
        local role = roles[math.random(#roles)]
        local status = statuses[math.random(#statuses)]
        UserTable:AddRow({
            name = name,
            role = role,
            status = status,
            score = math.random(50, 100),
        })
    end,
})

TableSection:AddButton({
    Text = "Clear Table",
    Style = "Danger",
    OnClick = function()
        UserTable:Clear()
    end,
})

-- ============================================================
-- Tab 2: List & TreeView
-- ============================================================
local ListTab = Window:AddTab({ Title = "Lists" })
local ListSection = ListTab:AddSection({ Title = "Selectable List" })

local ItemList = ListSection:AddList({
    Items = {
        { Text = "First Item", Description = "This is the first item", Icon = "rbxassetid://3928340255" },
        { Text = "Second Item", Description = "This is the second item" },
        { Text = "Third Item", Description = "Another item in the list" },
        { Text = "Fourth Item", Description = "Last but not least" },
    },
    OnSelect = function(item)
        print("Selected:", item.Text)
    end,
})

ListSection:AddButton({
    Text = "Clear List",
    Style = "Secondary",
    OnClick = function()
        ItemList:Clear()
    end,
})

-- TreeView
local TreeSection = ListTab:AddSection({ Title = "TreeView" })

local Tree = TreeSection:AddTreeView({
    Data = {
        {
            Text = "Project Root",
            Children = {
                {
                    Text = "src",
                    Children = {
                        { Text = "main.lua" },
                        { Text = "config.lua" },
                        {
                            Text = "components",
                            Children = {
                                { Text = "Button.lua" },
                                { Text = "Toggle.lua" },
                                { Text = "Slider.lua" },
                            },
                        },
                    },
                },
                {
                    Text = "docs",
                    Children = {
                        { Text = "README.md" },
                        { Text = "api-reference.md" },
                    },
                },
                { Text = "README.md" },
            },
        },
    },
    OnSelect = function(node)
        print("Selected node:", node.Text)
    end,
})

-- ============================================================
-- Tab 3: Accordion & Breadcrumb
-- ============================================================
local AccordionTab = Window:AddTab({ Title = "Accordion" })
local AccordionSection = AccordionTab:AddSection({ Title = "FAQ Accordion" })

local Accordion = AccordionSection:AddAccordion({
    Multiple = false,
})

Accordion:AddItem({
    Title = "What is VoidUI?",
    Content = "VoidUI is a modern, elegant, and complete UI library for Lua/LuaU with 50+ components, 6 themes, and 3 languages.",
})

Accordion:AddItem({
    Title = "How do I install VoidUI?",
    Content = "You can install VoidUI via loadstring, local script, or Roblox model. See the documentation for details.",
})

Accordion:AddItem({
    Title = "Is VoidUI free?",
    Content = "Yes! VoidUI is open source under the MIT License. You can use it freely in personal and commercial projects.",
})

Accordion:AddItem({
    Title = "Can I create custom themes?",
    Content = "Absolutely! Use VoidUI:CreateTheme() to define your own color palette and VoidUI:SetTheme() to apply it.",
})

-- Breadcrumb
local BreadcrumbSection = AccordionTab:AddSection({ Title = "Breadcrumb Navigation" })

BreadcrumbSection:AddBreadcrumb({
    Items = {
        { Text = "Home" },
        { Text = "Documentation" },
        { Text = "Components" },
        { Text = "Accordion" },
    },
    OnNavigate = function(item, index)
        print("Navigated to:", item.Text, "at index", index)
    end,
})

-- Pagination
local PaginationSection = AccordionTab:AddSection({ Title = "Pagination" })

PaginationSection:AddPagination({
    TotalPages = 10,
    CurrentPage = 1,
    OnPageChange = function(page)
        print("Page changed to:", page)
    end,
})

-- ============================================================
-- Tab 4: Status Indicators & Badges
-- ============================================================
local StatusTab = Window:AddTab({ Title = "Status" })
local StatusSection = StatusTab:AddSection({ Title = "Status Indicators" })

StatusSection:AddStatusIndicator({
    Status = "Online",
    Text = "Server is online",
})

StatusSection:AddStatusIndicator({
    Status = "Busy",
    Text = "Processing requests",
})

StatusSection:AddStatusIndicator({
    Status = "Away",
    Text = "User is away",
})

StatusSection:AddStatusIndicator({
    Status = "Offline",
    Text = "Server is offline",
})

local BadgeSection = StatusTab:AddSection({ Title = "Badges" })

BadgeSection:AddBadge({
    Text = "New",
    Variant = "Info",
})

BadgeSection:AddBadge({
    Text = "Verified",
    Variant = "Success",
})

BadgeSection:AddBadge({
    Text = "Beta",
    Variant = "Warning",
})

BadgeSection:AddBadge({
    Text = "Deprecated",
    Variant = "Error",
})

print("[VoidUI] Data components example loaded!")
