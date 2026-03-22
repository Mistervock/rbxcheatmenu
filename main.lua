-- ╔══════════════════════════════════════╗
-- ║         VOCK HUB  •  v2.2            ║
-- ║   + "Своё": кастомные категории,     ║
-- ║     кнопки, удаление                 ║
-- ╚══════════════════════════════════════╝

local Library = {}
Library.Categories = {}
Library.MainGui = nil
Library.ToggleButton = nil
Library.IsOpen = false
Library.ActiveCategory = nil
Library.UserCategories = {}   -- имена категорий, созданных пользователем
Library.UserScripts = {}      -- { {category, name, source} }

local C = {
    bg        = Color3.fromRGB(10,  10,  16),
    panel     = Color3.fromRGB(16,  16,  26),
    sidebar   = Color3.fromRGB(13,  13,  22),
    accent    = Color3.fromRGB(99,  102, 241),
    accentHi  = Color3.fromRGB(139, 92,  246),
    btnNorm   = Color3.fromRGB(22,  22,  36),
    btnHover  = Color3.fromRGB(36,  36,  60),
    catActive = Color3.fromRGB(26,  26,  50),
    text      = Color3.fromRGB(230, 230, 245),
    textDim   = Color3.fromRGB(130, 130, 160),
    red       = Color3.fromRGB(239, 68,  68),
    redDark   = Color3.fromRGB(60,  18,  18),
    green     = Color3.fromRGB(34,  197, 94),
    greenDark = Color3.fromRGB(15,  50,  25),
    border    = Color3.fromRGB(40,  40,  65),
    input     = Color3.fromRGB(18,  18,  30),
    inputBdr  = Color3.fromRGB(55,  55,  85),
}

local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end
local function Corner(p, r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 10) c.Parent=p end
local function Stroke(p, col, th) local s=Instance.new("UIStroke") s.Color=col or C.border s.Thickness=th or 1 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p end

-- ═══════════════════════════════════════════
--  МОДАЛЬНОЕ ОКНО (общий конструктор)
-- ═══════════════════════════════════════════

-- Единая функция закрытия
local function CloseModal(modal)
    if modal and modal.Parent then modal:Destroy() end
end

local function CreateModal(title, onClose)
    local sg = Library.MainGui.ScreenGui

    local modal = Instance.new("Frame")
    modal.Name = "VockModal"
    modal.Size = UDim2.new(0,360,0,0)
    modal.Position = UDim2.new(0.5,-180,0.5,-120)
    modal.BackgroundColor3 = C.panel
    modal.ZIndex = 11
    modal.AutomaticSize = Enum.AutomaticSize.Y
    modal.Parent = sg
    Corner(modal, 12)
    Stroke(modal, C.accent, 1.5)

    -- Заголовок модалки
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1,0,0,42)
    hdr.BackgroundTransparency = 1
    hdr.ZIndex = 12
    hdr.Parent = modal

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-50,1,0)
    ttl.Position = UDim2.new(0,16,0,0)
    ttl.BackgroundTransparency = 1
    ttl.Text = title
    ttl.TextColor3 = C.text
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 15
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.ZIndex = 12
    ttl.Parent = hdr

    local closeX = Instance.new("TextButton")
    closeX.Size = UDim2.new(0,28,0,28)
    closeX.Position = UDim2.new(1,-36,0,7)
    closeX.BackgroundColor3 = C.redDark
    closeX.Text = "✕"
    closeX.TextColor3 = C.red
    closeX.Font = Enum.Font.GothamBold
    closeX.TextSize = 13
    closeX.AutoButtonColor = false
    closeX.ZIndex = 12
    closeX.Parent = hdr
    Corner(closeX, 7)

    closeX.MouseButton1Click:Connect(function()
        CloseModal(modal)
        if onClose then onClose() end
    end)

    -- Тело модалки
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,-24,0,0)
    body.Position = UDim2.new(0,12,0,46)
    body.BackgroundTransparency = 1
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.ZIndex = 12
    body.Parent = modal

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0,10)
    bodyLayout.Parent = body

    local bodyPad = Instance.new("UIPadding")
    bodyPad.PaddingBottom = UDim.new(0,14)
    bodyPad.Parent = body

    return modal, body
end

-- Поле ввода
local function MakeInput(parent, placeholder, multiline, zidx)
    local z = zidx or 12
    local box = Instance.new(multiline and "Frame" or "TextBox")
    if multiline then
        box = Instance.new("Frame")
        box.Size = UDim2.new(1,0,0,80)
        box.BackgroundColor3 = C.input
        box.ZIndex = z
        box.Parent = parent
        Corner(box, 8)
        Stroke(box, C.inputBdr)
        local inner = Instance.new("TextBox")
        inner.Size = UDim2.new(1,-10,1,-8)
        inner.Position = UDim2.new(0,5,0,4)
        inner.BackgroundTransparency = 1
        inner.PlaceholderText = placeholder or ""
        inner.Text = ""
        inner.TextColor3 = C.text
        inner.PlaceholderColor3 = C.textDim
        inner.Font = Enum.Font.Code
        inner.TextSize = 12
        inner.MultiLine = true
        inner.TextWrapped = true
        inner.TextXAlignment = Enum.TextXAlignment.Left
        inner.TextYAlignment = Enum.TextYAlignment.Top
        inner.ClearTextOnFocus = false
        inner.ZIndex = z
        inner.Parent = box
        return box, inner
    else
        box = Instance.new("TextBox")
        box.Size = UDim2.new(1,0,0,36)
        box.BackgroundColor3 = C.input
        box.PlaceholderText = placeholder or ""
        box.Text = ""
        box.TextColor3 = C.text
        box.PlaceholderColor3 = C.textDim
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ZIndex = z
        box.Parent = parent
        Corner(box, 8)
        Stroke(box, C.inputBdr)
        local lp = Instance.new("UIPadding") lp.PaddingLeft=UDim.new(0,10) lp.Parent=box
        return box, box
    end
end

-- Метка
local function MakeLabel(parent, text, zidx)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,18)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.textDim
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = zidx or 12
    l.Parent = parent
end

-- Кнопка действия
local function MakeActionBtn(parent, text, col, zidx)
    local z = zidx or 12
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,38)
    b.BackgroundColor3 = col or C.accent
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = false
    b.ZIndex = z
    b.Parent = parent
    Corner(b, 9)
    return b
end

-- ═══════════════════════════════════════════
--  TOGGLE
-- ═══════════════════════════════════════════
local function CreateToggleButton()
    if Library.ToggleButton then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VockToggle"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = game:GetService("CoreGui")

    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0,110,0,38)
    pill.Position = UDim2.new(0,14,0.5,-19)
    pill.BackgroundColor3 = C.panel
    pill.Text = ""
    pill.AutoButtonColor = false
    pill.ClipsDescendants = true
    pill.Parent = sg
    Corner(pill, 19)
    Stroke(pill, C.accent, 1.5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-18,1,0)
    label.Position = UDim2.new(0,18,0,0)
    label.BackgroundTransparency = 1
    label.Text = "⚡  Vock Hub"
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = pill

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,7,0,7)
    dot.Position = UDim2.new(0,8,0.5,-3.5)
    dot.BackgroundColor3 = C.green
    dot.Parent = pill
    Corner(dot, 4)

    local function pulse()
        Tween(dot,{BackgroundTransparency=0.6},0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        task.delay(0.8,function()
            Tween(dot,{BackgroundTransparency=0},0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.delay(0.8,pulse)
        end)
    end
    pulse()

    pill.MouseEnter:Connect(function() Tween(pill,{BackgroundColor3=C.btnHover},0.15) end)
    pill.MouseLeave:Connect(function() Tween(pill,{BackgroundColor3=C.panel},0.15) end)
    pill.MouseButton1Click:Connect(function()
        if Library.MainGui and Library.MainGui.Frame then
            local show = not Library.MainGui.Frame.Visible
            Library.MainGui.Frame.Visible = show
            Library.IsOpen = show
        else
            Library:BuildGUI()
        end
        pill.Visible = not Library.IsOpen
    end)
    Library.ToggleButton = pill
end

-- ═══════════════════════════════════════════
--  ОСНОВНОЕ GUI
-- ═══════════════════════════════════════════
function Library:BuildGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "VockHub"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = game:GetService("CoreGui")

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0,540,0,370)
    win.Position = UDim2.new(0.5,-270,0.5,-185)
    win.BackgroundColor3 = C.bg
    win.ClipsDescendants = false
    win.Parent = sg
    Corner(win, 12)
    Stroke(win, C.border, 1)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1,-24,0,2)
    topBar.Position = UDim2.new(0,12,0,0)
    topBar.BackgroundColor3 = C.accent
    topBar.BorderSizePixel = 0
    topBar.Parent = win
    Corner(topBar, 2)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,46)
    header.BackgroundTransparency = 1
    header.Parent = win

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0,180,1,0)
    logo.Position = UDim2.new(0,16,0,0)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ VOCK HUB"
    logo.TextColor3 = C.text
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 17
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.TextTruncate = Enum.TextTruncate.AtEnd
    logo.Parent = header

    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(0,40,1,0)
    ver.Position = UDim2.new(0,152,0,0)
    ver.BackgroundTransparency = 1
    ver.Text = "v2.2"
    ver.TextColor3 = C.accentHi
    ver.Font = Enum.Font.GothamSemibold
    ver.TextSize = 11
    ver.TextXAlignment = Enum.TextXAlignment.Left
    ver.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-40,0,8)
    closeBtn.BackgroundColor3 = C.redDark
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.red
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.ClipsDescendants = true
    closeBtn.Parent = header
    Corner(closeBtn, 8)
    Stroke(closeBtn, Color3.fromRGB(80,30,30), 1)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn,{BackgroundColor3=C.red,TextColor3=Color3.new(1,1,1)},0.15) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn,{BackgroundColor3=C.redDark,TextColor3=C.red},0.15) end)
    closeBtn.MouseButton1Click:Connect(function()
        win.Visible = false
        Library.IsOpen = false
        if Library.ToggleButton then Library.ToggleButton.Visible = true end
    end)

    -- Drag
    local dragging, dragInput, dragStart, startPos
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; startPos = win.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
    end)
    UIS.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1,-20,0,1)
    sep.Position = UDim2.new(0,10,0,46)
    sep.BackgroundColor3 = C.border
    sep.BorderSizePixel = 0
    sep.Parent = win

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0,148,1,-56)
    sidebar.Position = UDim2.new(0,8,0,54)
    sidebar.BackgroundColor3 = C.sidebar
    sidebar.ClipsDescendants = true
    sidebar.Parent = win
    Corner(sidebar, 10)
    Stroke(sidebar, C.border, 1)

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1,-8,1,-8)
    catScroll.Position = UDim2.new(0,4,0,4)
    catScroll.BackgroundTransparency = 1
    catScroll.ScrollBarThickness = 2
    catScroll.ScrollBarImageColor3 = C.accent
    catScroll.CanvasSize = UDim2.new(0,0,0,0)
    catScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    catScroll.BorderSizePixel = 0
    catScroll.Parent = sidebar

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0,4)
    catLayout.Parent = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingTop = UDim.new(0,4)
    catPad.PaddingBottom = UDim.new(0,4)
    catPad.Parent = catScroll

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-168,1,-56)
    content.Position = UDim2.new(0,162,0,54)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = win

    Library.MainGui = {
        ScreenGui    = sg,
        Frame        = win,
        CatScroll    = catScroll,
        ContentFrame = content,
    }

    Library.IsOpen = true
    CreateToggleButton()
end

-- ═══════════════════════════════════════════
--  ДОБАВИТЬ КАТЕГОРИЮ
-- ═══════════════════════════════════════════
local CAT_ICONS = {
    ["Основная база сука"] = "🗡",
    ["R6"]="🏃",["R15"]="🦾",["Своё"]="✏️",["Об хабе"]="ℹ️",["Другие ХАБЫ"]="🌐",
}

function Library:AddCategory(name)
    if not Library.MainGui then Library:BuildGUI() end
    if Library.Categories[name] then return end

    local icon = CAT_ICONS[name] or "◈"

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-8,0,36)
    btn.BackgroundColor3 = C.btnNorm
    btn.Text = icon.."  "..name
    btn.TextColor3 = C.textDim
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = Library.MainGui.CatScroll
    Corner(btn, 8)
    local lp=Instance.new("UIPadding") lp.PaddingLeft=UDim.new(0,10) lp.PaddingRight=UDim.new(0,6) lp.Parent=btn

    local activeBar = Instance.new("Frame")
    activeBar.Size = UDim2.new(0,3,0.55,0)
    activeBar.Position = UDim2.new(0,0,0.225,0)
    activeBar.BackgroundColor3 = C.accentHi
    activeBar.BackgroundTransparency = 1
    activeBar.BorderSizePixel = 0
    activeBar.Parent = btn
    Corner(activeBar, 2)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1,0,1,0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = C.accent
    container.CanvasSize = UDim2.new(0,0,0,0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = Library.MainGui.ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop=UDim.new(0,6) padding.PaddingBottom=UDim.new(0,6) padding.PaddingRight=UDim.new(0,6)
    padding.Parent = container

    Library.Categories[name] = { Button=btn, Container=container, ActiveBar=activeBar }

    btn.MouseEnter:Connect(function()
        if Library.ActiveCategory~=name then Tween(btn,{BackgroundColor3=C.btnHover,TextColor3=C.text},0.12) end
    end)
    btn.MouseLeave:Connect(function()
        if Library.ActiveCategory~=name then Tween(btn,{BackgroundColor3=C.btnNorm,TextColor3=C.textDim},0.12) end
    end)
    btn.MouseButton1Click:Connect(function()
        for n,cat in pairs(Library.Categories) do
            cat.Container.Visible = false
            if n~=name then
                Tween(cat.Button,{BackgroundColor3=C.btnNorm,TextColor3=C.textDim},0.15)
                Tween(cat.ActiveBar,{BackgroundTransparency=1},0.15)
            end
        end
        container.Visible = true
        Library.ActiveCategory = name
        Tween(btn,{BackgroundColor3=C.catActive,TextColor3=C.text},0.18)
        Tween(activeBar,{BackgroundTransparency=0},0.18)
    end)
end

-- ═══════════════════════════════════════════
--  ДОБАВИТЬ СКРИПТ
-- ═══════════════════════════════════════════
function Library:AddScript(category, source, name, deletable)
    local cat = Library.Categories[category]
    if not cat then warn("Категория не найдена:", category) return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-4,0,46)
    btn.BackgroundColor3 = C.btnNorm
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.Parent = cat.Container
    Corner(btn, 10)
    Stroke(btn, C.border, 1)

    local label = Instance.new("TextLabel")
    -- если кнопка удаляемая — оставляем место для крестика
    label.Size = UDim2.new(1, deletable and -72 or -48, 1, 0)
    label.Position = UDim2.new(0,14,0,0)
    label.BackgroundTransparency = 1
    label.Text = name or "Execute"
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0,28,1,0)
    arrow.Position = UDim2.new(1, deletable and -62 or -36, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▶"
    arrow.TextColor3 = C.accent
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 13
    arrow.Parent = btn

    btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=C.btnHover},0.12) Tween(arrow,{TextColor3=C.accentHi},0.12) end)
    btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=C.btnNorm},0.12) Tween(arrow,{TextColor3=C.accent},0.12) end)

    btn.MouseButton1Click:Connect(function()
        Tween(btn,{BackgroundColor3=Color3.fromRGB(40,40,80)},0.08)
        task.delay(0.08,function() Tween(btn,{BackgroundColor3=C.btnNorm},0.15) end)
        local ok,err = pcall(function() loadstring(source)() end)
        if not ok then
            warn("[VockHub]",err)
            Tween(arrow,{TextColor3=C.red},0.1)
            task.delay(1.2,function() Tween(arrow,{TextColor3=C.accent},0.3) end)
        else
            Tween(arrow,{TextColor3=C.green},0.1)
            task.delay(1.2,function() Tween(arrow,{TextColor3=C.accent},0.3) end)
        end
    end)

    -- Кнопка удаления (только для пользовательских скриптов)
    if deletable then
        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0,28,0,28)
        del.Position = UDim2.new(1,-34,0.5,-14)
        del.BackgroundColor3 = C.redDark
        del.Text = "✕"
        del.TextColor3 = C.red
        del.Font = Enum.Font.GothamBold
        del.TextSize = 12
        del.AutoButtonColor = false
        del.ZIndex = 2
        del.Parent = btn
        Corner(del, 7)

        del.MouseEnter:Connect(function() Tween(del,{BackgroundColor3=C.red,TextColor3=Color3.new(1,1,1)},0.12) end)
        del.MouseLeave:Connect(function() Tween(del,{BackgroundColor3=C.redDark,TextColor3=C.red},0.12) end)
        del.MouseButton1Click:Connect(function()
            -- Удаляем из таблицы UserScripts
            for i, s in ipairs(Library.UserScripts) do
                if s.name == name and s.category == category then
                    table.remove(Library.UserScripts, i)
                    break
                end
            end
            btn:Destroy()
        end)
    end

    return btn
end

-- ═══════════════════════════════════════════
--  СЕКЦИЯ "СВОЁ" — строим контент
-- ═══════════════════════════════════════════
function Library:BuildSvoyoContent()
    local cat = Library.Categories["Своё"]
    if not cat then return end
    local container = cat.Container

    -- Очищаем старый контент (кроме layout и padding)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
    -- Восстанавливаем layout и padding
    if not container:FindFirstChildOfClass("UIListLayout") then
        local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,8) l.Parent=container
        local p=Instance.new("UIPadding")
        p.PaddingTop=UDim.new(0,6) p.PaddingBottom=UDim.new(0,6) p.PaddingRight=UDim.new(0,6) p.Parent=container
    end

    -- ── Кнопка: Создать категорию ──
    local btnAddCat = Instance.new("TextButton")
    btnAddCat.Size = UDim2.new(1,-4,0,40)
    btnAddCat.BackgroundColor3 = Color3.fromRGB(20,30,50)
    btnAddCat.Text = "＋  Новая категория"
    btnAddCat.TextColor3 = C.accent
    btnAddCat.Font = Enum.Font.GothamBold
    btnAddCat.TextSize = 13
    btnAddCat.AutoButtonColor = false
    btnAddCat.ClipsDescendants = true
    btnAddCat.TextTruncate = Enum.TextTruncate.AtEnd
    btnAddCat.Parent = container
    Corner(btnAddCat, 10)
    Stroke(btnAddCat, C.accent, 1)

    btnAddCat.MouseEnter:Connect(function() Tween(btnAddCat,{BackgroundColor3=Color3.fromRGB(28,40,70)},0.12) end)
    btnAddCat.MouseLeave:Connect(function() Tween(btnAddCat,{BackgroundColor3=Color3.fromRGB(20,30,50)},0.12) end)

    btnAddCat.MouseButton1Click:Connect(function()
        local modal, body = CreateModal("✏️  Новая категория")


        MakeLabel(body, "НАЗВАНИЕ")
        local nameBox = MakeInput(body, "Например: Мои скрипты")

        local confirm = MakeActionBtn(body, "Создать", C.accent)
        confirm.MouseButton1Click:Connect(function()
            local cname = nameBox.Text:match("^%s*(.-)%s*$")
            if cname == "" then return end
            if Library.Categories[cname] then
                nameBox.PlaceholderText = "⚠ Уже существует!"
                nameBox.Text = ""
                return
            end
            table.insert(Library.UserCategories, cname)
            Library:AddCategory(cname)
            CloseModal(modal)
            Library:BuildSvoyoContent()
        end)
    end)

    -- ── Кнопка: Создать скрипт ──
    local btnAddScript = Instance.new("TextButton")
    btnAddScript.Size = UDim2.new(1,-4,0,40)
    btnAddScript.BackgroundColor3 = Color3.fromRGB(20,35,28)
    btnAddScript.Text = "＋  Новая кнопка (скрипт)"
    btnAddScript.TextColor3 = C.green
    btnAddScript.Font = Enum.Font.GothamBold
    btnAddScript.TextSize = 13
    btnAddScript.AutoButtonColor = false
    btnAddScript.ClipsDescendants = true
    btnAddScript.TextTruncate = Enum.TextTruncate.AtEnd
    btnAddScript.Parent = container
    Corner(btnAddScript, 10)
    Stroke(btnAddScript, C.green, 1)

    btnAddScript.MouseEnter:Connect(function() Tween(btnAddScript,{BackgroundColor3=Color3.fromRGB(28,50,38)},0.12) end)
    btnAddScript.MouseLeave:Connect(function() Tween(btnAddScript,{BackgroundColor3=Color3.fromRGB(20,35,28)},0.12) end)

    btnAddScript.MouseButton1Click:Connect(function()
        -- Собираем список доступных категорий
        local catNames = {}
        for n in pairs(Library.Categories) do
            if n ~= "Своё" then table.insert(catNames, n) end
        end
        table.sort(catNames)

        local selectedCat = catNames[1] or ""
        local modal, body = CreateModal("🗡  Новая кнопка")

        MakeLabel(body, "НАЗВАНИЕ КНОПКИ")
        local nameBox = MakeInput(body, "Например: Мой полёт")

        MakeLabel(body, "КАТЕГОРИЯ")

        -- Выпадающий список категорий (кнопки-таблетки)
        local catRow = Instance.new("Frame")
        catRow.Size = UDim2.new(1,0,0,0)
        catRow.AutomaticSize = Enum.AutomaticSize.Y
        catRow.BackgroundTransparency = 1
        catRow.ZIndex = 12
        catRow.Parent = body
        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.Padding = UDim.new(0,4)
        rowLayout.Wraps = true
        rowLayout.Parent = catRow

        local catButtons = {}
        local function selectCat(name)
            selectedCat = name
            for n, b in pairs(catButtons) do
                if n == name then
                    Tween(b,{BackgroundColor3=C.accent,TextColor3=Color3.new(1,1,1)},0.12)
                else
                    Tween(b,{BackgroundColor3=C.btnNorm,TextColor3=C.textDim},0.12)
                end
            end
        end

        for _, n in ipairs(catNames) do
            local cb = Instance.new("TextButton")
            cb.Size = UDim2.new(0,0,0,28)
            cb.AutomaticSize = Enum.AutomaticSize.X
            cb.BackgroundColor3 = n==selectedCat and C.accent or C.btnNorm
            cb.Text = "  "..n.."  "
            cb.TextColor3 = n==selectedCat and Color3.new(1,1,1) or C.textDim
            cb.Font = Enum.Font.GothamSemibold
            cb.TextSize = 12
            cb.AutoButtonColor = false
            cb.ZIndex = 12
            cb.Parent = catRow
            Corner(cb, 7)
            catButtons[n] = cb
            cb.MouseButton1Click:Connect(function() selectCat(n) end)
        end

        MakeLabel(body, "КОД СКРИПТА (Lua)")
        local _, codeInner = MakeInput(body, 'loadstring(game:HttpGet("..."))()  -- вставь свой код', true)

        local confirm = MakeActionBtn(body, "Добавить кнопку", C.green)
        confirm.MouseButton1Click:Connect(function()
            local sname  = nameBox.Text:match("^%s*(.-)%s*$")
            local scode  = codeInner.Text:match("^%s*(.-)%s*$")
            local scat   = selectedCat
            if sname=="" or scode=="" or scat=="" then return end

            local entry = {category=scat, name=sname, source=scode}
            table.insert(Library.UserScripts, entry)
            Library:AddScript(scat, scode, sname, true)

            CloseModal(modal)
        end)
    end)

    -- ── Разделитель "Управление категориями" ──
    if #Library.UserCategories > 0 then
        local sectLabel = Instance.new("TextLabel")
        sectLabel.Size = UDim2.new(1,-4,0,20)
        sectLabel.BackgroundTransparency = 1
        sectLabel.Text = "── Созданные категории ──"
        sectLabel.TextColor3 = C.textDim
        sectLabel.Font = Enum.Font.GothamSemibold
        sectLabel.TextSize = 11
        sectLabel.TextXAlignment = Enum.TextXAlignment.Center
        sectLabel.Parent = container

        for _, cname in ipairs(Library.UserCategories) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,-4,0,38)
            row.BackgroundColor3 = C.btnNorm
            row.ClipsDescendants = true
            row.Parent = container
            Corner(row, 9)
            Stroke(row, C.border, 1)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-44,1,0)
            lbl.Position = UDim2.new(0,12,0,0)
            lbl.BackgroundTransparency = 1
            lbl.Text = (CAT_ICONS[cname] or "◈").."  "..cname
            lbl.TextColor3 = C.text
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = row

            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0,28,0,28)
            del.Position = UDim2.new(1,-34,0.5,-14)
            del.BackgroundColor3 = C.redDark
            del.Text = "✕"
            del.TextColor3 = C.red
            del.Font = Enum.Font.GothamBold
            del.TextSize = 12
            del.AutoButtonColor = false
            del.ZIndex = 2
            del.Parent = row
            Corner(del, 7)

            del.MouseEnter:Connect(function() Tween(del,{BackgroundColor3=C.red,TextColor3=Color3.new(1,1,1)},0.12) end)
            del.MouseLeave:Connect(function() Tween(del,{BackgroundColor3=C.redDark,TextColor3=C.red},0.12) end)

            del.MouseButton1Click:Connect(function()
                -- Удаляем кнопку в сайдбаре и контейнер
                local c = Library.Categories[cname]
                if c then
                    c.Button:Destroy()
                    c.Container:Destroy()
                    Library.Categories[cname] = nil
                end
                -- Чистим UserCategories
                for i, n in ipairs(Library.UserCategories) do
                    if n == cname then table.remove(Library.UserCategories, i) break end
                end
                -- Чистим UserScripts для этой категории
                for i = #Library.UserScripts, 1, -1 do
                    if Library.UserScripts[i].category == cname then
                        table.remove(Library.UserScripts, i)
                    end
                end
                if Library.ActiveCategory == cname then Library.ActiveCategory = nil end
                Library:BuildSvoyoContent()
            end)
        end
    end
end

-- ═══════════════════════════════════════════
--  ЗАПУСК
-- ═══════════════════════════════════════════
Library:AddCategory("база сука")
Library:AddCategory("игры бля")
Library:AddCategory("R6")
Library:AddCategory("R15")
Library:AddCategory("Своё")
Library:AddCategory("Об хабе")
Library:AddCategory("Другие ХАБЫ")

-- Строим содержимое "Своё" и обновляем при каждом открытии категории
Library:BuildSvoyoContent()
do
    local svoyoCat = Library.Categories["Своё"]
    if svoyoCat then
        svoyoCat.Button.MouseButton1Click:Connect(function()
            Library:BuildSvoyoContent()
        end)
    end
end

Library:AddScript("Об хабе",[[print("s")]],"Сделано ради Деворера")

Library:AddScript("R6",[[
loadstring(game:HttpGet('https://raw.githubusercontent.com/396abc/Script/refs/heads/main/Fly.lua'))()
]],"Неразвиваемый полёт")

Library:AddScript("R15",[[
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if isMobile then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua"))()
end
]],"Неразвиваемый полёт")

Library:AddScript("Другие ХАБЫ",[[
loadstring(game:HttpGet("https://gist.githubusercontent.com/maks1165/d7e70695bc613228d119efd4d28b963a/raw/f75cfce0f2ae0430cf1240d5f62c77f50dafcbfa/universal%2520script"))()
]],"Универсальное меню")

Library:AddScript("база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
]],"Полёт сына мияги")

Library:AddScript("база сука", [[
if not _G.FullBrightExecuted then

	_G.FullBrightEnabled = false

	_G.NormalLightingSettings = {
		Brightness = game:GetService("Lighting").Brightness,
		ClockTime = game:GetService("Lighting").ClockTime,
		FogEnd = game:GetService("Lighting").FogEnd,
		GlobalShadows = game:GetService("Lighting").GlobalShadows,
		Ambient = game:GetService("Lighting").Ambient
	}

	game:GetService("Lighting"):GetPropertyChangedSignal("Brightness"):Connect(function()
		if game:GetService("Lighting").Brightness ~= 1 and game:GetService("Lighting").Brightness ~= _G.NormalLightingSettings.Brightness then
			_G.NormalLightingSettings.Brightness = game:GetService("Lighting").Brightness
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").Brightness = 1
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
		if game:GetService("Lighting").ClockTime ~= 12 and game:GetService("Lighting").ClockTime ~= _G.NormalLightingSettings.ClockTime then
			_G.NormalLightingSettings.ClockTime = game:GetService("Lighting").ClockTime
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").ClockTime = 12
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
		if game:GetService("Lighting").FogEnd ~= 786543 and game:GetService("Lighting").FogEnd ~= _G.NormalLightingSettings.FogEnd then
			_G.NormalLightingSettings.FogEnd = game:GetService("Lighting").FogEnd
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").FogEnd = 786543
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("GlobalShadows"):Connect(function()
		if game:GetService("Lighting").GlobalShadows ~= false and game:GetService("Lighting").GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
			_G.NormalLightingSettings.GlobalShadows = game:GetService("Lighting").GlobalShadows
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").GlobalShadows = false
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("Ambient"):Connect(function()
		if game:GetService("Lighting").Ambient ~= Color3.fromRGB(178, 178, 178) and game:GetService("Lighting").Ambient ~= _G.NormalLightingSettings.Ambient then
			_G.NormalLightingSettings.Ambient = game:GetService("Lighting").Ambient
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)
		end
	end)

	game:GetService("Lighting").Brightness = 1
	game:GetService("Lighting").ClockTime = 12
	game:GetService("Lighting").FogEnd = 786543
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)

	local LatestValue = true
	spawn(function()
		repeat
			wait()
		until _G.FullBrightEnabled
		while wait() do
			if _G.FullBrightEnabled ~= LatestValue then
				if not _G.FullBrightEnabled then
					game:GetService("Lighting").Brightness = _G.NormalLightingSettings.Brightness
					game:GetService("Lighting").ClockTime = _G.NormalLightingSettings.ClockTime
					game:GetService("Lighting").FogEnd = _G.NormalLightingSettings.FogEnd
					game:GetService("Lighting").GlobalShadows = _G.NormalLightingSettings.GlobalShadows
					game:GetService("Lighting").Ambient = _G.NormalLightingSettings.Ambient
				else
					game:GetService("Lighting").Brightness = 1
					game:GetService("Lighting").ClockTime = 12
					game:GetService("Lighting").FogEnd = 786543
					game:GetService("Lighting").GlobalShadows = false
					game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)
				end
				LatestValue = not LatestValue
			end
		end
	end)
end

_G.FullBrightExecuted = true
_G.FullBrightEnabled = not _G.FullBrightEnabled
]], "убрать освещение (fullbright)")

Library:AddScript("игры бля",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotEnoughJack/LuaFluentDependancies/refs/heads/main/main.lua"))()
]],"красная ваншот еботня (JJS) скрипт читы")

Library:AddScript("игры бля", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/-beta-/main/AutoParry.lua"))()
]], "шары твоей бати (blade ball)")

Library:AddScript("игры бля",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/DeadRails", true))()
]],"твой дед под рельсами (dead rails) читы")

Library:AddScript("база сука",[[
loadstring(game:HttpGet("https://pastebin.com/raw/uqD7VqQU"))()
]],"симулятор взрыва Пакистана (RTX)")

Library:AddScript("база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();
]],"анти-афк")

Library:AddScript("база сука",[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Jerk_Tool.lua"))()
]],"Дрочка")

Library:AddScript("база сука",[[
game:GetService("CoreGui").VockHub:Destroy()
game:GetService("CoreGui").VockToggle:Destroy()
]],"стереть эту парашу с лица земли")
