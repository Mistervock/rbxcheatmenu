-- Простая GUI-панель в стиле executor'а с категориями и кнопками
-- + категория "Своё" с возможностью добавлять свои скрипты через GUI

local Library = {}

Library.Categories = {}
Library.MainGui = nil
Library.ToggleButton = nil
Library.IsOpen = false
Library.DefaultCategory = "Своё"

-- Toggle кнопка
local function CreateToggleButton()

    if Library.ToggleButton then return end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "HubToggleBtn"
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,100,0,40)
    btn.Position = UDim2.new(0,15,0.5,-20)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,45)
    btn.Text = "Open Hub"
    btn.TextColor3 = Color3.fromRGB(180,210,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = sg

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,10)

    btn.MouseButton1Click:Connect(function()

        if Library.MainGui and Library.MainGui.Frame then
            Library.MainGui.Frame.Visible = not Library.MainGui.Frame.Visible
            Library.IsOpen = Library.MainGui.Frame.Visible
        else
            Library:BuildGUI()
        end

        btn.Visible = not Library.IsOpen

    end)

    Library.ToggleButton = btn
end

-- Основное GUI
function Library:BuildGUI()

    local sg = Instance.new("ScreenGui")
    sg.Name = "vockhub"
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,520,0,360)
    MainFrame.Position = UDim2.new(0.5,-260,0.5,-180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(16,16,22)
    MainFrame.Parent = sg

    Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,10)

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = "Vock Hub"
    title.TextColor3 = Color3.fromRGB(220,220,240)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = MainFrame

    -- DRAG СИСТЕМА
    local UIS = game:GetService("UserInputService")

    local dragging
    local dragInput
    local dragStart
    local startPos

    title.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

        end
    end)

    title.InputChanged:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end

    end)

    UIS.InputChanged:Connect(function(input)

        if input == dragInput and dragging then

            local delta = input.Position - dragStart

            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )

        end

    end)

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,32,0,32)
    closeBtn.Position = UDim2.new(1,-38,0,4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = MainFrame

    closeBtn.MouseButton1Click:Connect(function()

        MainFrame.Visible = false
        Library.IsOpen = false

        if Library.ToggleButton then
            Library.ToggleButton.Visible = true
        end

    end)

    -- Категории
    local CategoryScroll = Instance.new("ScrollingFrame")
    CategoryScroll.Size = UDim2.new(0,150,1,-48)
    CategoryScroll.Position = UDim2.new(0,10,0,44)
    CategoryScroll.BackgroundTransparency = 1
    CategoryScroll.Parent = MainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.Parent = CategoryScroll

    -- Контент
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1,-170,1,-48)
    ContentFrame.Position = UDim2.new(0,160,0,44)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    Library.MainGui = {
        ScreenGui = sg,
        Frame = MainFrame,
        CategoryScroll = CategoryScroll,
        ContentFrame = ContentFrame
    }

    Library.IsOpen = true
    CreateToggleButton()
end

-- Добавить категорию
function Library:AddCategory(name)

    if not Library.MainGui then
        Library:BuildGUI()
    end

    if Library.Categories[name] then return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,38)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,38)
    btn.Text = " "..name
    btn.TextColor3 = Color3.fromRGB(190,190,210)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Library.MainGui.CategoryScroll

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1,0,1,0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = Library.MainGui.ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = container

    Library.Categories[name] = {
        Button = btn,
        Container = container
    }

    btn.MouseButton1Click:Connect(function()

        for _,cat in pairs(Library.Categories) do
            cat.Container.Visible = false
        end

        container.Visible = true

    end)

end

-- Добавить скрипт
function Library:AddScript(category,source,name)

    local cat = Library.Categories[category]
    if not cat then
        warn("Категория не найдена:",category)
        return
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-12,0,44)
    btn.BackgroundColor3 = Color3.fromRGB(38,38,65)
    btn.Text = name or "Execute"
    btn.TextColor3 = Color3.fromRGB(210,210,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.Parent = cat.Container

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()

        local ok,err = pcall(function()
            loadstring(source)()
        end)

        if not ok then
            warn(err)
        end

    end)

end


-- ───── ЗАПУСК ─────

Library:AddCategory("Основная база сука")
Library:AddCategory("R6")
Library:AddCategory("R15")
Library:AddCategory("Своё")
Library:AddCategory("Об хабе")
Library:AddCategory("Другие ХАБЫ")
Library:AddScript("Об хабе",[[print("s")]],"Сделано ради Деворера")


Library:AddScript("R6", [[
loadstring(game:HttpGet('https://raw.githubusercontent.com/396abc/Script/refs/heads/main/Fly.lua'))()
]], "Неразвиваемый полёт")

Library:AddScript("R15", [[

local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if isMobile then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua"))()
end

    
]], "Неразвиваемый полёт")

----
Library:AddScript("Другие ХАБЫ",[[
loadstring(game:HttpGet("https://gist.githubusercontent.com/maks1165/d7e70695bc613228d119efd4d28b963a/raw/f75cfce0f2ae0430cf1240d5f62c77f50dafcbfa/universal%2520script"))()
]],"Универсальное меню")

Library:AddScript("Основная база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
]],"Полёт сына мияги")

Library:AddScript("Основная база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotEnoughJack/LuaFluentDependancies/refs/heads/main/main.lua"))()
]],"красная ваншот еботня (жжс) скрипт читы")

Library:AddScript("Основная база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/DeadRails", true))()
]],"твой дед под рельсами читы")

Library:AddScript("Основная база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();
]],"анти-афк")

Library:AddScript("Основная база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Jerk_Tool.lua"))()
]],"Дрочка")

Library:AddScript("Основная база сука",[[
game:GetService("CoreGui").vockhub:Destroy()
]],"стереть эту парашу с лица земли")
