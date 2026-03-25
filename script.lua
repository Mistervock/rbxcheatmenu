-- vockHub key-system Improved
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local correctKey = "1111"

-- Создание UI
local sg = Instance.new("ScreenGui")
sg.Name = "VockKeySystem"
sg.ResetOnSpawn = false
sg.Parent = CoreGui

-- Основной фрейм
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Глубокий темный
frame.BorderSizePixel = 0
frame.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Тень (простой обвод)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(45, 45, 60)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "vockHub"
title.TextColor3 = Color3.fromRGB(120, 130, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

-- Поле ввода
local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -40, 0, 45)
box.Position = UDim2.new(0, 20, 0, 65)
box.PlaceholderText = "Введите ключ доступа..."
box.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
box.Text = ""
box.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.GothamMedium
box.TextSize = 14
box.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = box

-- Кнопка
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 45)
btn.Position = UDim2.new(0, 20, 0, 125)
btn.Text = "Проверить ключ"
btn.BackgroundColor3 = Color3.fromRGB(85, 90, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.AutoButtonColor = false
btn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = btn

--- Анимации и Логика ---

local function animateClick(object)
    local goal = {BackgroundColor3 = Color3.fromRGB(60, 65, 200)}
    local ti = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, ti, goal)
    tween:Play()
    tween.Completed:Connect(function()
        TweenService:Create(object, ti, {BackgroundColor3 = Color3.fromRGB(85, 90, 255)}):Play()
    end)
end

btn.MouseButton1Click:Connect(function()
    animateClick(btn)
    
    if box.Text == correctKey then
        title.Text = "Успешно!"
        title.TextColor3 = Color3.fromRGB(100, 255, 150)
        task.wait(0.5)
        sg:Destroy()
        -- Загрузка основного скрипта
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mistervock/rbxcheatmenu/refs/heads/readme/main.lua"))();
    else
        box.Text = ""
        box.PlaceholderText = "Неверный ключ!"
        box.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)
        
        -- Небольшая тряска при ошибке
        local originalPos = frame.Position
        for i = 1, 6 do
            local offset = (i % 2 == 0 and 5 or -5)
            frame.Position = originalPos + UDim2.new(0, offset, 0, 0)
            task.wait(0.05)
        end
        frame.Position = originalPos
    end
end)
