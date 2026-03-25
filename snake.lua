-- Snake Game GUI for Roblox (Modern Redesign)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки игры
local CELL_SIZE = 22
local GRID_W, GRID_H = 18, 18
local TICK_RATE = 0.12

-- Удаление старой копии
if playerGui:FindFirstChild("SnakeGame") then playerGui.SnakeGame:Destroy() end

-- GUI Base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SnakeGame"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Эффект размытия заднего плана
local blur = Instance.new("BlurEffect")
blur.Size = 10
blur.Parent = game:GetService("Lighting")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 520)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Градиент для фона
local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
mainGradient.Rotation = 45
mainGradient.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "NEON SNAKE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Счёт
local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(1, 0, 0, 30)
scoreLabel.Position = UDim2.new(0, 0, 0, 50)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "SCORE: 0"
scoreLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
scoreLabel.TextSize = 18
scoreLabel.Font = Enum.Font.Code
scoreLabel.Parent = mainFrame

-- Игровое поле
local boardFrame = Instance.new("Frame")
boardFrame.Size = UDim2.new(0, CELL_SIZE * GRID_W, 0, CELL_SIZE * GRID_H)
boardFrame.Position = UDim2.new(0.5, -(CELL_SIZE * GRID_W) / 2, 0, 90)
boardFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
boardFrame.BorderSizePixel = 0
boardFrame.Parent = mainFrame

Instance.new("UICorner", boardFrame).CornerRadius = UDim.new(0, 8)
local boardStroke = Instance.new("UIStroke")
boardStroke.Color = Color3.fromRGB(50, 50, 80)
boardStroke.Thickness = 2
boardStroke.Parent = boardFrame

-- Оверлей начала/конца
local overlay = Instance.new("TextButton")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.Text = "PRESS ANY KEY TO START"
overlay.TextColor3 = Color3.fromRGB(255, 255, 255)
overlay.Font = Enum.Font.GothamBold
overlay.TextSize = 18
overlay.ZIndex = 20
overlay.Parent = boardFrame

-- Сетка ячеек (визуальная)
local cells = {}
for y = 1, GRID_H do
    cells[y] = {}
    for x = 1, GRID_W do
        local cell = Instance.new("Frame")
        cell.Size = UDim2.new(0, CELL_SIZE - 2, 0, CELL_SIZE - 2)
        cell.Position = UDim2.new(0, (x-1)*CELL_SIZE + 1, 0, (y-1)*CELL_SIZE + 1)
        cell.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        cell.BackgroundTransparency = 0.8
        cell.BorderSizePixel = 0
        cell.Parent = boardFrame
        cells[y][x] = cell
        
        Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 4)
    end
end

-- Кнопка закрытия (X)
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -40, 0, 15)
close.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 20
close.Parent = mainFrame
Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)

close.MouseButton1Click:Connect(function()
    blur:Destroy()
    screenGui:Destroy()
end)

---------------- Логика игры ----------------

local snake, dir, nextDir, food, score, running, gameOver = {}, {x=1, y=0}, {x=1, y=0}, nil, 0, false, false
local ticker = 0

local function updateScore(val)
    score = val
    scoreLabel.Text = "SCORE: " .. score
    TweenService:Create(scoreLabel, TweenInfo.new(0.1), {TextSize = 22}):Play()
    task.delay(0.1, function() TweenService:Create(scoreLabel, TweenInfo.new(0.1), {TextSize = 18}):Play() end)
end

local function spawnFood()
    local x, y
    repeat
        x, y = math.random(1, GRID_W), math.random(1, GRID_H)
        local onSnake = false
        for _, s in ipairs(snake) do if s.x == x and s.y == y then onSnake = true break end end
    until not onSnake
    food = {x=x, y=y}
    
    -- Анимация появления еды
    local fCell = cells[y][x]
    fCell.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fCell.BackgroundTransparency = 0
    fCell.Size = UDim2.new(0, 0, 0, 0)
    fCell.Position = UDim2.new(0, (x-1)*CELL_SIZE + CELL_SIZE/2, 0, (y-1)*CELL_SIZE + CELL_SIZE/2)
    TweenService:Create(fCell, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, CELL_SIZE - 2, 0, CELL_SIZE - 2),
        Position = UDim2.new(0, (x-1)*CELL_SIZE + 1, 0, (y-1)*CELL_SIZE + 1)
    }):Play()
end

local function render()
    for y = 1, GRID_H do
        for x = 1, GRID_W do
            local cell = cells[y][x]
            if food and food.x == x and food.y == y then
                cell.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
                cell.BackgroundTransparency = 0
            else
                cell.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                cell.BackgroundTransparency = 0.8
            end
        end
    end
    
    for i, s in ipairs(snake) do
        local cell = cells[s.y][s.x]
        cell.BackgroundTransparency = 0
        if i == 1 then
            cell.BackgroundColor3 = Color3.fromRGB(0, 255, 150) -- Голова
        else
            cell.BackgroundColor3 = Color3.fromRGB(0, 150, 100) -- Тело
        end
    end
end

local function startGame()
    snake = {{x=5, y=10}, {x=4, y=10}, {x=3, y=10}}
    dir = {x=1, y=0}
    nextDir = {x=1, y=0}
    updateScore(0)
    gameOver = false
    running = true
    overlay.Visible = false
    spawnFood()
end

UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if not running or gameOver then startGame() return end
    
    local k = input.KeyCode
    if (k == Enum.KeyCode.W or k == Enum.KeyCode.Up) and dir.y == 0 then nextDir = {x=0, y=-1}
    elseif (k == Enum.KeyCode.S or k == Enum.KeyCode.Down) and dir.y == 0 then nextDir = {x=0, y=1}
    elseif (k == Enum.KeyCode.A or k == Enum.KeyCode.Left) and dir.x == 0 then nextDir = {x=-1, y=0}
    elseif (k == Enum.KeyCode.D or k == Enum.KeyCode.Right) and dir.x == 0 then nextDir = {x=1, y=0} end
end)

RunService.Heartbeat:Connect(function(dt)
    if not running or gameOver or not screenGui.Parent then return end
    ticker += dt
    if ticker < TICK_RATE then return end
    ticker = 0
    
    dir = nextDir
    local head = {x = snake[1].x + dir.x, y = snake[1].y + dir.y}
    
    if head.x < 1 or head.x > GRID_W or head.y < 1 or head.y > GRID_H then 
        gameOver = true overlay.Visible = true overlay.Text = "GAME OVER\nFINAL SCORE: "..score return 
    end
    
    for _, s in ipairs(snake) do
        if head.x == s.x and head.y == s.y then 
            gameOver = true overlay.Visible = true overlay.Text = "YOU ATE YOURSELF!\nSCORE: "..score return 
        end
    end
    
    table.insert(snake, 1, head)
    if food and head.x == food.x and head.y == food.y then
        updateScore(score + 10)
        spawnFood()
    else
        table.remove(snake)
    end
    render()
end)
