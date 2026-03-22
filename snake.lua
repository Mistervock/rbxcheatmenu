-- Snake Game GUI for Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки игры
local CELL_SIZE = 20
local GRID_W = 20
local GRID_H = 20
local TICK_RATE = 0.15

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SnakeGame"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 560)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🐍 Змейка"
titleLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Счёт
local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(1, 0, 0, 30)
scoreLabel.Position = UDim2.new(0, 0, 0, 48)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "Счёт: 0"
scoreLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
scoreLabel.TextSize = 16
scoreLabel.Font = Enum.Font.Gotham
scoreLabel.Parent = mainFrame

-- Игровое поле
local boardFrame = Instance.new("Frame")
boardFrame.Size = UDim2.new(0, CELL_SIZE * GRID_W, 0, CELL_SIZE * GRID_H)
boardFrame.Position = UDim2.new(0.5, -(CELL_SIZE * GRID_W) / 2, 0, 82)
boardFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
boardFrame.BorderSizePixel = 0
boardFrame.ClipsDescendants = true
boardFrame.Parent = mainFrame

local boardCorner = Instance.new("UICorner")
boardCorner.CornerRadius = UDim.new(0, 8)
boardCorner.Parent = boardFrame

-- Подсказка управления
local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, 0, 0, 25)
hintLabel.Position = UDim2.new(0, 0, 0, 488)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "WASD или стрелки для управления"
hintLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
hintLabel.TextSize = 13
hintLabel.Font = Enum.Font.Gotham
hintLabel.Parent = mainFrame

-- Оверлей (старт / game over)
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0
overlay.ZIndex = 10
overlay.Parent = boardFrame

local overlayLabel = Instance.new("TextLabel")
overlayLabel.Size = UDim2.new(1, 0, 0, 60)
overlayLabel.Position = UDim2.new(0, 0, 0.35, 0)
overlayLabel.BackgroundTransparency = 1
overlayLabel.Text = "Нажми любую клавишу\nдля начала игры"
overlayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
overlayLabel.TextSize = 18
overlayLabel.Font = Enum.Font.GothamBold
overlayLabel.TextWrapped = true
overlayLabel.ZIndex = 11
overlayLabel.Parent = boardFrame

-- Ячейки поля
local cells = {}
for y = 1, GRID_H do
    cells[y] = {}
    for x = 1, GRID_W do
        local cell = Instance.new("Frame")
        cell.Size = UDim2.new(0, CELL_SIZE - 1, 0, CELL_SIZE - 1)
        cell.Position = UDim2.new(0, (x-1)*CELL_SIZE, 0, (y-1)*CELL_SIZE)
        cell.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
        cell.BorderSizePixel = 0
        cell.Parent = boardFrame
        cells[y][x] = cell
    end
end

-- Состояние игры
local snake, dir, nextDir, food, score, running, gameOver
local ticker = 0

local function randomFood(snakeBody)
    local free = {}
    for y = 1, GRID_H do
        for x = 1, GRID_W do
            local ok = true
            for _, s in ipairs(snakeBody) do
                if s.x == x and s.y == y then ok = false break end
            end
            if ok then free[#free+1] = {x=x, y=y} end
        end
    end
    if #free == 0 then return nil end
    return free[math.random(1, #free)]
end

local function renderBoard()
    -- Очищаем
    for y = 1, GRID_H do
        for x = 1, GRID_W do
            cells[y][x].BackgroundColor3 = Color3.fromRGB(18, 18, 28)
        end
    end
    -- Еда
    if food then
        cells[food.y][food.x].BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
    -- Змейка
    for i, s in ipairs(snake) do
        if s.y >= 1 and s.y <= GRID_H and s.x >= 1 and s.x <= GRID_W then
            if i == 1 then
                cells[s.y][s.x].BackgroundColor3 = Color3.fromRGB(100, 230, 100)
            else
                local t = 1 - (i / #snake) * 0.5
                cells[s.y][s.x].BackgroundColor3 = Color3.fromRGB(40, math.floor(160*t), 40)
            end
        end
    end
end

local function initGame()
    snake = {{x=10, y=10}, {x=9, y=10}, {x=8, y=10}}
    dir = {x=1, y=0}
    nextDir = {x=1, y=0}
    score = 0
    scoreLabel.Text = "Счёт: 0"
    food = randomFood(snake)
    gameOver = false
    running = true
    overlay.Visible = false
    renderBoard()
end

local function endGame()
    running = false
    gameOver = true
    overlay.Visible = true
    overlayLabel.Text = "Игра окончена!\nСчёт: " .. score .. "\n\nНажми любую клавишу\nдля перезапуска"
end

-- Управление
local keyConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local k = input.KeyCode
    if not running and not gameOver then
        initGame()
        return
    end
    if gameOver then
        initGame()
        return
    end
    if k == Enum.KeyCode.W or k == Enum.KeyCode.Up then
        if dir.y ~= 1 then nextDir = {x=0, y=-1} end
    elseif k == Enum.KeyCode.S or k == Enum.KeyCode.Down then
        if dir.y ~= -1 then nextDir = {x=0, y=1} end
    elseif k == Enum.KeyCode.A or k == Enum.KeyCode.Left then
        if dir.x ~= 1 then nextDir = {x=-1, y=0} end
    elseif k == Enum.KeyCode.D or k == Enum.KeyCode.Right then
        if dir.x ~= -1 then nextDir = {x=1, y=0} end
    end
end)

-- Игровой цикл
local loopConn
loopConn = RunService.Heartbeat:Connect(function(dt)
    if screenGui.Parent == nil then
        loopConn:Disconnect()
        keyConn:Disconnect()
        return
    end
    if not running then return end

    ticker = ticker + dt
    if ticker < TICK_RATE then return end
    ticker = 0

    dir = nextDir
    local head = {x = snake[1].x + dir.x, y = snake[1].y + dir.y}

    -- Столкновение со стенкой
    if head.x < 1 or head.x > GRID_W or head.y < 1 or head.y > GRID_H then
        endGame() return
    end
    -- Столкновение с собой
    for _, s in ipairs(snake) do
        if s.x == head.x and s.y == head.y then
            endGame() return
        end
    end

    table.insert(snake, 1, head)

    -- Съела еду?
    if food and head.x == food.x and head.y == food.y then
        score = score + 10
        scoreLabel.Text = "Счёт: " .. score
        food = randomFood(snake)
    else
        table.remove(snake)
    end

    renderBoard()
end)

-- Начальный экран
overlay.Visible = true
overlayLabel.Text = "Нажми любую клавишу\nдля начала игры"
running = false
gameOver = false
