-- Простая GUI-панель в стиле executor'а с категориями и кнопками
-- + категория "Своё" с возможностью добавлять свои скрипты через GUI

local Library = {}

Library.Categories = {}
Library.MainGui = nil
Library.ToggleButton = nil
Library.IsOpen = false
Library.DefaultCategory = "Своё"

-- Создаём кнопку "Open Hub"
local function CreateToggleButton()
    if Library.ToggleButton then return end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "HubToggleBtn"
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 40)
    btn.Position = UDim2.new(0, 15, 0.5, -20)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    btn.Text = "Open Hub"
    btn.Name = "OpenH"
    btn.TextColor3 = Color3.fromRGB(180, 210, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 130, 255)
    stroke.Thickness = 1.6
    stroke.Transparency = 0.45
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        stroke.Transparency = 0.2
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        stroke.Transparency = 0.45
    end)

    btn.MouseButton1Click:Connect(function()
        if Library.MainGui and Library.MainGui.Frame then
            Library.MainGui.Frame.Visible = not Library.MainGui.Frame.Visible
            Library.IsOpen = Library.MainGui.Frame.Visible
        else
            Library:BuildGUI()
        end
        
        if Library.ToggleButton then
            Library.ToggleButton.Visible = not Library.IsOpen
        end
    end)

    Library.ToggleButton = btn
end

-- Создаём основное окно
function Library:BuildGUI()
    if Library.MainGui and Library.MainGui.Frame then
        Library.MainGui.Frame:Destroy()
        Library.MainGui = nil
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "vockhub"
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("CoreGui") -- 

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = sg

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = MainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(60, 140, 255)
    uiStroke.Thickness = 1.5
    uiStroke.Transparency = 0.5
    uiStroke.Parent = MainFrame

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Vock Hub"
    title.TextColor3 = Color3.fromRGB(220, 220, 240)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = MainFrame

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = MainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        Library.IsOpen = false
        if Library.ToggleButton then
            Library.ToggleButton.Visible = true
        end
    end)

    -- Левая панель — категории
    local CategoryScroll = Instance.new("ScrollingFrame")
    CategoryScroll.Size = UDim2.new(0, 150, 1, -48)
    CategoryScroll.Position = UDim2.new(0, 10, 0, 44)
    CategoryScroll.BackgroundTransparency = 1
    CategoryScroll.ScrollBarThickness = 4
    CategoryScroll.Parent = MainFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0, 6)
    catLayout.FillDirection = Enum.FillDirection.Vertical
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent = CategoryScroll

    -- Правая часть — контент
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -170, 1, -48)
    ContentFrame.Position = UDim2.new(0, 160, 0, 44)
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

    -- Автообновление размера списка категорий
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        CategoryScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 20)
    end)
end

-- Добавить категорию
function Library:AddCategory(name)
    if not Library.MainGui or not Library.MainGui.Frame then
        Library:BuildGUI()
    end

    if Library.Categories[name] then return end

    local catButton = Instance.new("TextButton")
    catButton.Size = UDim2.new(1, -10, 0, 38)
    catButton.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    catButton.Text = "  " .. name
    catButton.TextColor3 = Color3.fromRGB(190, 190, 210)
    catButton.Font = Enum.Font.GothamSemibold
    catButton.TextSize = 15
    catButton.TextXAlignment = Enum.TextXAlignment.Left
    catButton.Parent = Library.MainGui.CategoryScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = catButton

    local container = Instance.new("ScrollingFrame")
    container.Name = name .. "Content"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.Visible = false
    container.Parent = Library.MainGui.ContentFrame

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.FillDirection = Enum.FillDirection.Vertical
    btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnLayout.Parent = container

    btnLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, btnLayout.AbsoluteContentSize.Y + 20)
    end)

    Library.Categories[name] = {
        Button = catButton,
        Container = container
    }

    local function selectCategory()
        for _, data in pairs(Library.Categories) do
            data.Container.Visible = false
            data.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            data.Button.TextColor3 = Color3.fromRGB(190, 190, 210)
        end
        container.Visible = true
        catButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        catButton.TextColor3 = Color3.fromRGB(230, 230, 255)
    end

    catButton.MouseButton1Click:Connect(selectCategory)

    catButton.MouseEnter:Connect(function()
        if not container.Visible then
            catButton.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
        end
    end)
    
    catButton.MouseLeave:Connect(function()
        if not container.Visible then
            catButton.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        end
    end)

    -- Если это категория по умолчанию — выбираем её сразу
    if name == Library.DefaultCategory then
        task.spawn(function()
            task.wait()   -- ждём один кадр, чтобы все элементы GUI точно создались
            selectCategory()
        end)
    end
end

-- Обычное добавление скрипта (для других категорий)
function Library:AddScript(categoryName, scriptSource, buttonText)
    local cat = Library.Categories[categoryName]
    if not cat then
        warn("Категория не найдена: " .. tostring(categoryName))
        return
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(38, 38, 65)
    btn.Text = buttonText or "Execute"
    btn.TextColor3 = Color3.fromRGB(210, 210, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextWrapped = true
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.Parent = cat.Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.6
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            loadstring(scriptSource)()
        end)
        if not success then
            warn("Ошибка в скрипте \"" .. (buttonText or "без имени") .. "\": " .. tostring(err))
        end
    end)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 90)
        stroke.Transparency = 0.3
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(38, 38, 65)
        stroke.Transparency = 0.6
    end)
end

-- ────────────────────────────────────────────────
-- Категория "Своё" + форма для добавления скриптов
-- ────────────────────────────────────────────────

local CustomCategoryCreated = false

local function CreateCustomScriptsSection()
    if CustomCategoryCreated then return end
    CustomCategoryCreated = true

    local catName = "Своё (продв.)"
    Library:AddCategory(catName)
    local cat = Library.Categories[catName]

    -- Панелька сверху для ввода нового скрипта
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputPanel"
    InputFrame.Size = UDim2.new(1, -12, 0, 140)
    InputFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    InputFrame.BorderSizePixel = 0
    InputFrame.LayoutOrder = -1          -- чтобы была всегда сверху
    InputFrame.Parent = cat.Container

    local inCorner = Instance.new("UICorner")
    inCorner.CornerRadius = UDim.new(0, 8)
    inCorner.Parent = InputFrame

    -- Название кнопки
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 24)
    nameLabel.Position = UDim2.new(0, 8, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Название кнопки:"
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = InputFrame

    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, -16, 0, 28)
    nameBox.Position = UDim2.new(0, 8, 0, 30)
    nameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    nameBox.TextColor3 = Color3.fromRGB(220, 220, 255)
    nameBox.PlaceholderText = "Например: Godmode"
    nameBox.Text = ""
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.ClearTextOnFocus = false
    nameBox.Parent = InputFrame

    local nbCorner = Instance.new("UICorner")
    nbCorner.CornerRadius = UDim.new(0, 6)
    nbCorner.Parent = nameBox

    -- Поле для кода
    local codeLabel = Instance.new("TextLabel")
    codeLabel.Size = UDim2.new(1, 0, 0, 24)
    codeLabel.Position = UDim2.new(0, 8, 0, 64)
    codeLabel.BackgroundTransparency = 1
    codeLabel.Text = "Код (loadstring):"
    codeLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    codeLabel.Font = Enum.Font.GothamSemibold
    codeLabel.TextSize = 14
    codeLabel.TextXAlignment = Enum.TextXAlignment.Left
    codeLabel.Parent = InputFrame

    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -16, 0, 60)
    codeBox.Position = UDim2.new(0, 8, 0, 88)
    codeBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    codeBox.TextColor3 = Color3.fromRGB(220, 220, 255)
    codeBox.PlaceholderText = "print('Hello!') или game:HttpGet(...)"
    codeBox.Text = ""
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 13
    codeBox.MultiLine = true
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.Parent = InputFrame

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = codeBox

    -- Кнопка Добавить
    local addBtn = Instance.new("TextButton")
    addBtn.Size = UDim2.new(0, 110, 0, 32)
    addBtn.Position = UDim2.new(1, -126, 1, -42)
    addBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 80)
    addBtn.Text = "Добавить"
    addBtn.TextColor3 = Color3.new(1,1,1)
    addBtn.Font = Enum.Font.GothamBold
    addBtn.TextSize = 15
    addBtn.Parent = InputFrame

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 8)
    abCorner.Parent = addBtn

    addBtn.MouseButton1Click:Connect(function()
        local btnName = nameBox.Text:match("^%s*(.-)%s*$") or ""
        local scriptCode = codeBox.Text

        if scriptCode == "" then return end
        if btnName == "" then
            btnName = "Скрипт #" .. tostring(#cat.Container:GetChildren() - 1)
        end

        Library:AddScript(catName, scriptCode, btnName)

        nameBox.Text = ""
        codeBox.Text = ""
    end)
end

-- ────────────────────────────────────────────────
-- Запуск
-- ────────────────────────────────────────────────





-- Примеры других категорий https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Jerk_Tool.lua
Library:AddCategory("Основная база сука")
Library:AddCategory("Другие ХАБЫ")
CreateCustomScriptsSection()
Library:AddCategory("Об хабе")

-- //////

Library:AddScript("Об хабе", [[print("s")]], "Сделано ради Деворера")

-- /////
-- //////
Library:AddScript("Другие ХАБЫ", [[

loadstring(game:HttpGet("https://gist.githubusercontent.com/maks1165/d7e70695bc613228d119efd4d28b963a/raw/f75cfce0f2ae0430cf1240d5f62c77f50dafcbfa/universal%2520script"))()

]], "Универсальное меню")



-- //////
Library:AddScript("Основная база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
]], "Полёт сына мияги")

Library:AddScript("Основная база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();
]], "анти-афк")

Library:AddScript("Основная база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Jerk_Tool.lua"))()
]], "Дрочка")

Library:AddScript("Основная база сука", [[
game:GetService("CoreGui").vockhub:Destroy()
]], "стереть эту парашу с лица земли")
-- Если хочешь открыть сразу при запуске (раскомментируй):
-- Library:BuildGUI()
-- Library.ToggleButton.Visible = false
