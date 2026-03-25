-- ╔══════════════════════════════════════════════╗
-- ║           VOCK HUB  •  v2.3                  ║
-- ║   Переработан дизайн: градиенты, анимации,   ║
-- ║   новые иконки, улучшенная типографика       ║
-- ╚══════════════════════════════════════════════╝

local Library = {}
Library.Categories   = {}
Library.MainGui      = nil
Library.ToggleButton = nil
Library.IsOpen       = false
Library.ActiveCategory = nil
Library.UserCategories = {}
Library.UserScripts    = {}

-- ═══════════════════════════════════════════════
--  ПАЛИТРА ЦВЕТОВ
-- ═══════════════════════════════════════════════
local C = {
    bg        = Color3.fromRGB(8,   8,   14),
    panel     = Color3.fromRGB(14,  14,  24),
    sidebar   = Color3.fromRGB(11,  11,  20),
    accent    = Color3.fromRGB(110, 86,  255),
    accentHi  = Color3.fromRGB(168, 85,  247),
    btnNorm   = Color3.fromRGB(20,  20,  34),
    btnHover  = Color3.fromRGB(32,  32,  58),
    catActive = Color3.fromRGB(22,  18,  52),
    text      = Color3.fromRGB(235, 235, 250),
    textDim   = Color3.fromRGB(120, 120, 155),
    textMuted = Color3.fromRGB(70,  70,  100),
    red       = Color3.fromRGB(248, 68,  68),
    redDark   = Color3.fromRGB(55,  15,  15),
    green     = Color3.fromRGB(52,  211, 153),
    greenDark = Color3.fromRGB(12,  48,  32),
    border    = Color3.fromRGB(35,  35,  60),
    input     = Color3.fromRGB(16,  16,  28),
    inputBdr  = Color3.fromRGB(50,  50,  80),
}

local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

-- ═══════════════════════════════════════════════
--  УТИЛИТЫ
-- ═══════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Gradient(parent, colorA, colorB, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function MakeShadow(parent, size, color, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, size or 24, 1, size or 24)
    shadow.ZIndex = (parent.ZIndex or 1) - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = color or Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

-- ═══════════════════════════════════════════════
--  МОДАЛЬНЫЕ ОКНА
-- ═══════════════════════════════════════════════
local function CreateModal(title, onClose)
    local sg = Library.MainGui.ScreenGui

    local overlay = Instance.new("Frame")
    overlay.Name = "VockOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.55
    overlay.ZIndex = 10
    overlay.Parent = sg

    local modal = Instance.new("Frame")
    modal.Name = "VockModal"
    modal.Size = UDim2.new(0, 370, 0, 0)
    modal.Position = UDim2.new(0.5, -185, 0.5, -130)
    modal.BackgroundColor3 = C.panel
    modal.ZIndex = 11
    modal.AutomaticSize = Enum.AutomaticSize.Y
    modal.Parent = sg
    Corner(modal, 14)
    Stroke(modal, C.accent, 1.5)
    MakeShadow(modal, 30, C.accent, 0.75)

    local hdrBg = Instance.new("Frame")
    hdrBg.Size = UDim2.new(1, 0, 0, 46)
    hdrBg.BackgroundColor3 = C.bg
    hdrBg.BorderSizePixel = 0
    hdrBg.ZIndex = 12
    hdrBg.Parent = modal
    Corner(hdrBg, 14)
    Gradient(hdrBg, Color3.fromRGB(20, 16, 48), C.bg, 135)

    local hdrFix = Instance.new("Frame")
    hdrFix.Size = UDim2.new(1, 0, 0, 14)
    hdrFix.Position = UDim2.new(0, 0, 1, -14)
    hdrFix.BackgroundColor3 = C.bg
    hdrFix.BorderSizePixel = 0
    hdrFix.ZIndex = 12
    hdrFix.Parent = hdrBg

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -60, 1, 0)
    ttl.Position = UDim2.new(0, 18, 0, 0)
    ttl.BackgroundTransparency = 1
    ttl.Text = title
    ttl.TextColor3 = C.text
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 15
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.ZIndex = 13
    ttl.Parent = hdrBg

    local closeX = Instance.new("TextButton")
    closeX.Size = UDim2.new(0, 28, 0, 28)
    closeX.Position = UDim2.new(1, -40, 0.5, -14)
    closeX.BackgroundColor3 = C.redDark
    closeX.Text = "✕"
    closeX.TextColor3 = C.red
    closeX.Font = Enum.Font.GothamBold
    closeX.TextSize = 13
    closeX.AutoButtonColor = false
    closeX.ZIndex = 13
    closeX.Parent = hdrBg
    Corner(closeX, 8)
    Stroke(closeX, Color3.fromRGB(90, 25, 25), 1)

    closeX.MouseEnter:Connect(function()
        Tween(closeX, {BackgroundColor3 = C.red, TextColor3 = Color3.new(1,1,1)}, 0.12)
    end)
    closeX.MouseLeave:Connect(function()
        Tween(closeX, {BackgroundColor3 = C.redDark, TextColor3 = C.red}, 0.12)
    end)

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -28, 0, 0)
    body.Position = UDim2.new(0, 14, 0, 52)
    body.BackgroundTransparency = 1
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.ZIndex = 12
    body.Parent = modal

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0, 10)
    bodyLayout.Parent = body

    local bodyPad = Instance.new("UIPadding")
    bodyPad.PaddingBottom = UDim.new(0, 16)
    bodyPad.Parent = body

    local function closeAll()
        if overlay and overlay.Parent then overlay:Destroy() end
        if modal and modal.Parent then modal:Destroy() end
        if onClose then onClose() end
    end

    closeX.MouseButton1Click:Connect(closeAll)
    return modal, body, closeAll
end

-- ═══════════════════════════════════════════════
--  UI-КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════
local function MakeInput(parent, placeholder, multiline, zidx)
    local z = zidx or 12
    if multiline then
        local box = Instance.new("Frame")
        box.Size = UDim2.new(1, 0, 0, 90)
        box.BackgroundColor3 = C.input
        box.ZIndex = z
        box.Parent = parent
        Corner(box, 9)
        Stroke(box, C.inputBdr)
        local inner = Instance.new("TextBox")
        inner.Size = UDim2.new(1, -12, 1, -10)
        inner.Position = UDim2.new(0, 6, 0, 5)
        inner.BackgroundTransparency = 1
        inner.PlaceholderText = placeholder or ""
        inner.Text = ""
        inner.TextColor3 = C.text
        inner.PlaceholderColor3 = C.textMuted
        inner.Font = Enum.Font.Code
        inner.TextSize = 12
        inner.MultiLine = true
        inner.TextWrapped = true
        inner.TextXAlignment = Enum.TextXAlignment.Left
        inner.TextYAlignment = Enum.TextYAlignment.Top
        inner.ClearTextOnFocus = false
        inner.ZIndex = z
        inner.Parent = box
        inner.Focused:Connect(function() Tween(box, {BackgroundColor3 = Color3.fromRGB(22, 22, 40)}, 0.12) end)
        inner.FocusLost:Connect(function() Tween(box, {BackgroundColor3 = C.input}, 0.12) end)
        return box, inner
    else
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, 38)
        box.BackgroundColor3 = C.input
        box.PlaceholderText = placeholder or ""
        box.Text = ""
        box.TextColor3 = C.text
        box.PlaceholderColor3 = C.textMuted
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ZIndex = z
        box.Parent = parent
        Corner(box, 9)
        Stroke(box, C.inputBdr)
        local lp = Instance.new("UIPadding")
        lp.PaddingLeft = UDim.new(0, 12)
        lp.Parent = box
        box.Focused:Connect(function() Tween(box, {BackgroundColor3 = Color3.fromRGB(22, 22, 40)}, 0.12) end)
        box.FocusLost:Connect(function() Tween(box, {BackgroundColor3 = C.input}, 0.12) end)
        return box, box
    end
end

local function MakeLabel(parent, text, zidx)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.accentHi
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = zidx or 12
    l.Parent = parent
end

local function MakeActionBtn(parent, text, col, zidx)
    local z = zidx or 12
    local origColor = col or C.accent
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = origColor
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = false
    b.ZIndex = z
    b.Parent = parent
    Corner(b, 10)
    b.MouseEnter:Connect(function()
        Tween(b, {BackgroundColor3 = origColor:Lerp(Color3.new(1,1,1), 0.12)}, 0.12)
    end)
    b.MouseLeave:Connect(function()
        Tween(b, {BackgroundColor3 = origColor}, 0.12)
    end)
    b.MouseButton1Click:Connect(function()
        Tween(b, {BackgroundColor3 = origColor:Lerp(Color3.new(0,0,0), 0.15)}, 0.06)
        task.delay(0.06, function() Tween(b, {BackgroundColor3 = origColor}, 0.12) end)
    end)
    return b
end

-- ═══════════════════════════════════════════════
--  КНОПКА-ТОГГЛЕР
-- ═══════════════════════════════════════════════
local function CreateToggleButton()
    if Library.ToggleButton then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VockToggle"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = game:GetService("CoreGui")

    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, 120, 0, 40)
    pill.Position = UDim2.new(0, 12, 0.5, -20)
    pill.BackgroundColor3 = C.panel
    pill.Text = ""
    pill.AutoButtonColor = false
    pill.ClipsDescendants = true
    pill.Parent = sg
    Corner(pill, 20)
    Stroke(pill, C.accent, 1.5)
    MakeShadow(pill, 20, C.accent, 0.78)
    Gradient(pill, Color3.fromRGB(18, 14, 42), C.panel, 135)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 12, 0.5, -3)
    dot.BackgroundColor3 = C.green
    dot.Parent = pill
    Corner(dot, 4)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 22, 1, 0)
    icon.Position = UDim2.new(0, 22, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚡"
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.Parent = pill

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, 0)
    label.Position = UDim2.new(0, 46, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Vock Hub"
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = pill

    local function pulse()
        Tween(dot, {BackgroundTransparency = 0.7}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.delay(0.9, function()
            Tween(dot, {BackgroundTransparency = 0}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.delay(0.9, pulse)
        end)
    end
    pulse()

    pill.MouseEnter:Connect(function() Tween(pill, {BackgroundColor3 = C.btnHover}, 0.15) end)
    pill.MouseLeave:Connect(function() Tween(pill, {BackgroundColor3 = C.panel}, 0.15) end)
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

-- ═══════════════════════════════════════════════
--  ОСНОВНОЕ GUI
-- ═══════════════════════════════════════════════
function Library:BuildGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "VockHub"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = game:GetService("CoreGui")

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 560, 0, 385)
    win.Position = UDim2.new(0.5, -280, 0.5, -192)
    win.BackgroundColor3 = C.bg
    win.ClipsDescendants = false
    win.Parent = sg
    Corner(win, 14)
    Stroke(win, C.border, 1.2)
    MakeShadow(win, 40, Color3.fromRGB(0, 0, 0), 0.45)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -28, 0, 2)
    topBar.Position = UDim2.new(0, 14, 0, 0)
    topBar.BackgroundColor3 = C.accent
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2
    topBar.Parent = win
    Corner(topBar, 2)
    Gradient(topBar, C.accent, C.accentHi, 90)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.ZIndex = 2
    header.Parent = win

    local headerBg = Instance.new("Frame")
    headerBg.Size = UDim2.new(1, 0, 1, 0)
    headerBg.BackgroundColor3 = C.bg
    headerBg.ZIndex = 1
    headerBg.Parent = header
    Gradient(headerBg, Color3.fromRGB(16, 12, 40), C.bg, 90)

    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.new(0, 30, 1, 0)
    logoIcon.Position = UDim2.new(0, 14, 0, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "⚡"
    logoIcon.Font = Enum.Font.GothamBold
    logoIcon.TextSize = 20
    logoIcon.TextXAlignment = Enum.TextXAlignment.Center
    logoIcon.ZIndex = 3
    logoIcon.Parent = header

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(0, 120, 1, 0)
    logoText.Position = UDim2.new(0, 46, 0, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "VOCK HUB"
    logoText.TextColor3 = C.text
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 17
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    logoText.ZIndex = 3
    logoText.Parent = header

    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(0, 36, 0, 18)
    ver.Position = UDim2.new(0, 168, 0.5, -9)
    ver.BackgroundColor3 = C.catActive
    ver.Text = "v2.3"
    ver.TextColor3 = C.accentHi
    ver.Font = Enum.Font.GothamBold
    ver.TextSize = 10
    ver.ZIndex = 3
    ver.Parent = header
    Corner(ver, 5)
    Stroke(ver, C.accent, 1)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -42, 0.5, -15)
    closeBtn.BackgroundColor3 = C.redDark
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.red
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 3
    closeBtn.Parent = header
    Corner(closeBtn, 9)
    Stroke(closeBtn, Color3.fromRGB(80, 22, 22), 1)

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = C.red, TextColor3 = Color3.new(1,1,1)}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = C.redDark, TextColor3 = C.red}, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        win.Visible = false
        Library.IsOpen = false
        if Library.ToggleButton then Library.ToggleButton.Visible = true end
    end)

    local dragging, dragInput, dragStart, startPos
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = win.Position
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
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 0, 50)
    sep.BackgroundColor3 = C.border
    sep.BorderSizePixel = 0
    sep.Parent = win
    Gradient(sep, C.accent, C.border, 90)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 152, 1, -62)
    sidebar.Position = UDim2.new(0, 8, 0, 58)
    sidebar.BackgroundColor3 = C.sidebar
    sidebar.ClipsDescendants = true
    sidebar.Parent = win
    Corner(sidebar, 11)
    Stroke(sidebar, C.border, 1)

    local sideAccent = Instance.new("Frame")
    sideAccent.Size = UDim2.new(0, 2, 0.7, 0)
    sideAccent.Position = UDim2.new(1, -2, 0.15, 0)
    sideAccent.BackgroundColor3 = C.accent
    sideAccent.BackgroundTransparency = 0.6
    sideAccent.BorderSizePixel = 0
    sideAccent.Parent = sidebar
    Corner(sideAccent, 2)
    Gradient(sideAccent, C.accent, Color3.fromRGB(0, 0, 0), 90)

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1, -8, 1, -8)
    catScroll.Position = UDim2.new(0, 4, 0, 4)
    catScroll.BackgroundTransparency = 1
    catScroll.ScrollBarThickness = 2
    catScroll.ScrollBarImageColor3 = C.accent
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    catScroll.BorderSizePixel = 0
    catScroll.Parent = sidebar

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0, 4)
    catLayout.Parent = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingTop    = UDim.new(0, 5)
    catPad.PaddingBottom = UDim.new(0, 5)
    catPad.Parent = catScroll

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -172, 1, -62)
    content.Position = UDim2.new(0, 166, 0, 58)
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

-- ═══════════════════════════════════════════════
--  КАТЕГОРИИ
-- ═══════════════════════════════════════════════
local CAT_ICONS = {
    ["база сука"]   = "🗡️",
    ["игры бля"]    = "🎮",
    ["R6"]          = "🏃",
    ["R15"]         = "🦾",
    ["Своё"]        = "✏️",
    ["Об хабе"]     = "ℹ️",
    ["Другие ХАБЫ"] = "🌐",
}

function Library:AddCategory(name)
    if not Library.MainGui then Library:BuildGUI() end
    if Library.Categories[name] then return end

    local icon = CAT_ICONS[name] or "◈"

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 38)
    btn.BackgroundColor3 = C.btnNorm
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = C.textDim
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = Library.MainGui.CatScroll
    Corner(btn, 9)

    local lp = Instance.new("UIPadding")
    lp.PaddingLeft  = UDim.new(0, 12)
    lp.PaddingRight = UDim.new(0, 6)
    lp.Parent = btn

    local activeBar = Instance.new("Frame")
    activeBar.Size = UDim2.new(0, 3, 0.5, 0)
    activeBar.Position = UDim2.new(0, 0, 0.25, 0)
    activeBar.BackgroundColor3 = C.accentHi
    activeBar.BackgroundTransparency = 1
    activeBar.BorderSizePixel = 0
    activeBar.Parent = btn
    Corner(activeBar, 2)

    local activeFill = Instance.new("Frame")
    activeFill.Size = UDim2.new(1, 0, 1, 0)
    activeFill.BackgroundColor3 = C.accent
    activeFill.BackgroundTransparency = 1
    activeFill.ZIndex = 0
    activeFill.Parent = btn
    Corner(activeFill, 9)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = C.accent
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = Library.MainGui.ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop    = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingRight  = UDim.new(0, 6)
    padding.Parent = container

    Library.Categories[name] = {
        Button    = btn,
        Container = container,
        ActiveBar = activeBar,
        Fill      = activeFill,
    }

    btn.MouseEnter:Connect(function()
        if Library.ActiveCategory ~= name then
            Tween(btn, {BackgroundColor3 = C.btnHover, TextColor3 = C.text}, 0.14)
        end
    end)
    btn.MouseLeave:Connect(function()
        if Library.ActiveCategory ~= name then
            Tween(btn, {BackgroundColor3 = C.btnNorm, TextColor3 = C.textDim}, 0.14)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for n, cat in pairs(Library.Categories) do
            cat.Container.Visible = false
            if n ~= name then
                Tween(cat.Button,    {BackgroundColor3 = C.btnNorm, TextColor3 = C.textDim}, 0.15)
                Tween(cat.ActiveBar, {BackgroundTransparency = 1}, 0.15)
                Tween(cat.Fill,      {BackgroundTransparency = 1}, 0.15)
            end
        end
        container.Visible = true
        Library.ActiveCategory = name
        Tween(btn,        {BackgroundColor3 = C.catActive, TextColor3 = C.text}, 0.18)
        Tween(activeBar,  {BackgroundTransparency = 0}, 0.18)
        Tween(activeFill, {BackgroundTransparency = 0.92}, 0.18)
    end)
end

-- ═══════════════════════════════════════════════
--  СКРИПТЫ
-- ═══════════════════════════════════════════════
function Library:AddScript(category, source, name, deletable)
    local cat = Library.Categories[category]
    if not cat then warn("[VockHub] Категория не найдена:", category) return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 50)
    btn.BackgroundColor3 = C.btnNorm
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.Parent = cat.Container
    Corner(btn, 11)
    Stroke(btn, C.border, 1)

    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 34, 0, 34)
    iconBg.Position = UDim2.new(0, 8, 0.5, -17)
    iconBg.BackgroundColor3 = C.catActive
    iconBg.ZIndex = 2
    iconBg.Parent = btn
    Corner(iconBg, 9)
    Stroke(iconBg, C.accent, 1)

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(1, 0, 1, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▶"
    arrow.TextColor3 = C.accent
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.ZIndex = 3
    arrow.Parent = iconBg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, deletable and -100 or -68, 0, 20)
    label.Position = UDim2.new(0, 52, 0.5, -14)
    label.BackgroundTransparency = 1
    label.Text = name or "Execute"
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.ZIndex = 2
    label.Parent = btn

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, deletable and -100 or -68, 0, 16)
    subLabel.Position = UDim2.new(0, 52, 0.5, 2)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "Нажми для запуска"
    subLabel.TextColor3 = C.textMuted
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 10
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.ZIndex = 2
    subLabel.Parent = btn

    btn.MouseEnter:Connect(function()
        Tween(btn,    {BackgroundColor3 = C.btnHover}, 0.12)
        Tween(iconBg, {BackgroundColor3 = C.accent}, 0.12)
        Tween(arrow,  {TextColor3 = Color3.new(1,1,1)}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,    {BackgroundColor3 = C.btnNorm}, 0.12)
        Tween(iconBg, {BackgroundColor3 = C.catActive}, 0.12)
        Tween(arrow,  {TextColor3 = C.accent}, 0.12)
    end)

    btn.MouseButton1Click:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 30, 75)}, 0.07)
        task.delay(0.07, function() Tween(btn, {BackgroundColor3 = C.btnNorm}, 0.2) end)

        local ok, err = pcall(function() loadstring(source)() end)
        if not ok then
            warn("[VockHub]", err)
            Tween(iconBg, {BackgroundColor3 = C.redDark}, 0.1)
            Tween(arrow,  {TextColor3 = C.red}, 0.1)
            subLabel.Text      = "Ошибка!"
            subLabel.TextColor3 = C.red
            task.delay(1.5, function()
                Tween(iconBg, {BackgroundColor3 = C.catActive}, 0.3)
                Tween(arrow,  {TextColor3 = C.accent}, 0.3)
                subLabel.Text      = "Нажми для запуска"
                subLabel.TextColor3 = C.textMuted
            end)
        else
            Tween(iconBg, {BackgroundColor3 = C.greenDark}, 0.1)
            Tween(arrow,  {TextColor3 = C.green}, 0.1)
            subLabel.Text      = "Выполнено ✓"
            subLabel.TextColor3 = C.green
            task.delay(1.5, function()
                Tween(iconBg, {BackgroundColor3 = C.catActive}, 0.3)
                Tween(arrow,  {TextColor3 = C.accent}, 0.3)
                subLabel.Text      = "Нажми для запуска"
                subLabel.TextColor3 = C.textMuted
            end)
        end
    end)

    if deletable then
        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0, 30, 0, 30)
        del.Position = UDim2.new(1, -38, 0.5, -15)
        del.BackgroundColor3 = C.redDark
        del.Text = "✕"
        del.TextColor3 = C.red
        del.Font = Enum.Font.GothamBold
        del.TextSize = 12
        del.AutoButtonColor = false
        del.ZIndex = 2
        del.Parent = btn
        Corner(del, 8)
        Stroke(del, Color3.fromRGB(80, 22, 22), 1)

        del.MouseEnter:Connect(function()
            Tween(del, {BackgroundColor3 = C.red, TextColor3 = Color3.new(1,1,1)}, 0.12)
        end)
        del.MouseLeave:Connect(function()
            Tween(del, {BackgroundColor3 = C.redDark, TextColor3 = C.red}, 0.12)
        end)
        del.MouseButton1Click:Connect(function()
            for i, s in ipairs(Library.UserScripts) do
                if s.name == name and s.category == category then
                    table.remove(Library.UserScripts, i) break
                end
            end
            Tween(btn, {BackgroundTransparency = 1}, 0.15)
            task.delay(0.15, function() btn:Destroy() end)
        end)
    end

    return btn
end

-- ═══════════════════════════════════════════════
--  РАЗДЕЛ "СВОЁ"
-- ═══════════════════════════════════════════════
function Library:BuildSvoyoContent()
    local cat = Library.Categories["Своё"]
    if not cat then return end
    local container = cat.Container

    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
    if not container:FindFirstChildOfClass("UIListLayout") then
        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0, 8)
        l.Parent = container
        local p = Instance.new("UIPadding")
        p.PaddingTop = UDim.new(0, 6) ; p.PaddingBottom = UDim.new(0, 6)
        p.PaddingRight = UDim.new(0, 6) ; p.Parent = container
    end

    -- ── Создать категорию ──
    local btnAddCat = Instance.new("TextButton")
    btnAddCat.Size = UDim2.new(1, -4, 0, 42)
    btnAddCat.BackgroundColor3 = Color3.fromRGB(16, 14, 40)
    btnAddCat.Text = "＋  Новая категория"
    btnAddCat.TextColor3 = C.accent
    btnAddCat.Font = Enum.Font.GothamBold
    btnAddCat.TextSize = 13
    btnAddCat.AutoButtonColor = false
    btnAddCat.ClipsDescendants = true
    btnAddCat.TextTruncate = Enum.TextTruncate.AtEnd
    btnAddCat.Parent = container
    Corner(btnAddCat, 11)
    Stroke(btnAddCat, C.accent, 1.2)

    btnAddCat.MouseEnter:Connect(function()
        Tween(btnAddCat, {BackgroundColor3 = Color3.fromRGB(24, 20, 58)}, 0.12)
    end)
    btnAddCat.MouseLeave:Connect(function()
        Tween(btnAddCat, {BackgroundColor3 = Color3.fromRGB(16, 14, 40)}, 0.12)
    end)
    btnAddCat.MouseButton1Click:Connect(function()
        local modal, body, closeAll = CreateModal("✏️  Новая категория")
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
            closeAll()
            Library:BuildSvoyoContent()
        end)
    end)

    -- ── Создать скрипт ──
    local btnAddScript = Instance.new("TextButton")
    btnAddScript.Size = UDim2.new(1, -4, 0, 42)
    btnAddScript.BackgroundColor3 = Color3.fromRGB(12, 32, 22)
    btnAddScript.Text = "＋  Новая кнопка (скрипт)"
    btnAddScript.TextColor3 = C.green
    btnAddScript.Font = Enum.Font.GothamBold
    btnAddScript.TextSize = 13
    btnAddScript.AutoButtonColor = false
    btnAddScript.ClipsDescendants = true
    btnAddScript.TextTruncate = Enum.TextTruncate.AtEnd
    btnAddScript.Parent = container
    Corner(btnAddScript, 11)
    Stroke(btnAddScript, C.green, 1.2)

    btnAddScript.MouseEnter:Connect(function()
        Tween(btnAddScript, {BackgroundColor3 = Color3.fromRGB(18, 46, 32)}, 0.12)
    end)
    btnAddScript.MouseLeave:Connect(function()
        Tween(btnAddScript, {BackgroundColor3 = Color3.fromRGB(12, 32, 22)}, 0.12)
    end)
    btnAddScript.MouseButton1Click:Connect(function()
        local catNames = {}
        for n in pairs(Library.Categories) do
            if n ~= "Своё" then table.insert(catNames, n) end
        end
        table.sort(catNames)

        local selectedCat = catNames[1] or ""
        local modal, body, closeAll = CreateModal("🗡️  Новая кнопка")

        MakeLabel(body, "НАЗВАНИЕ КНОПКИ")
        local nameBox = MakeInput(body, "Например: Мой полёт")
        MakeLabel(body, "КАТЕГОРИЯ")

        local catRow = Instance.new("Frame")
        catRow.Size = UDim2.new(1, 0, 0, 0)
        catRow.AutomaticSize = Enum.AutomaticSize.Y
        catRow.BackgroundTransparency = 1
        catRow.ZIndex = 12
        catRow.Parent = body
        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.Padding = UDim.new(0, 5)
        rowLayout.Wraps = true
        rowLayout.Parent = catRow

        local catButtons = {}
        local function selectCat(n)
            selectedCat = n
            for nm, b in pairs(catButtons) do
                if nm == n then
                    Tween(b, {BackgroundColor3 = C.accent, TextColor3 = Color3.new(1,1,1)}, 0.12)
                else
                    Tween(b, {BackgroundColor3 = C.btnNorm, TextColor3 = C.textDim}, 0.12)
                end
            end
        end

        for _, n in ipairs(catNames) do
            local cb = Instance.new("TextButton")
            cb.Size = UDim2.new(0, 0, 0, 30)
            cb.AutomaticSize = Enum.AutomaticSize.X
            cb.BackgroundColor3 = (n == selectedCat) and C.accent or C.btnNorm
            cb.Text = "  " .. n .. "  "
            cb.TextColor3 = (n == selectedCat) and Color3.new(1,1,1) or C.textDim
            cb.Font = Enum.Font.GothamSemibold
            cb.TextSize = 12
            cb.AutoButtonColor = false
            cb.ZIndex = 12
            cb.Parent = catRow
            Corner(cb, 8)
            catButtons[n] = cb
            cb.MouseButton1Click:Connect(function() selectCat(n) end)
        end

        MakeLabel(body, "КОД СКРИПТА (Lua)")
        local _, codeInner = MakeInput(body, 'loadstring(game:HttpGet("..."))()  -- вставь свой код', true)

        local confirm = MakeActionBtn(body, "Добавить кнопку", C.green)
        confirm.MouseButton1Click:Connect(function()
            local sname = nameBox.Text:match("^%s*(.-)%s*$")
            local scode = codeInner.Text:match("^%s*(.-)%s*$")
            local scat  = selectedCat
            if sname == "" or scode == "" or scat == "" then return end
            table.insert(Library.UserScripts, {category = scat, name = sname, source = scode})
            Library:AddScript(scat, scode, sname, true)
            closeAll()
        end)
    end)

    -- ── Созданные категории ──
    if #Library.UserCategories > 0 then
        local sectLabel = Instance.new("TextLabel")
        sectLabel.Size = UDim2.new(1, -4, 0, 22)
        sectLabel.BackgroundTransparency = 1
        sectLabel.Text = "── Созданные категории ──"
        sectLabel.TextColor3 = C.textMuted
        sectLabel.Font = Enum.Font.GothamSemibold
        sectLabel.TextSize = 10
        sectLabel.TextXAlignment = Enum.TextXAlignment.Center
        sectLabel.Parent = container

        for _, cname in ipairs(Library.UserCategories) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 40)
            row.BackgroundColor3 = C.btnNorm
            row.ClipsDescendants = true
            row.Parent = container
            Corner(row, 10)
            Stroke(row, C.border, 1)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 14, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = (CAT_ICONS[cname] or "◈") .. "  " .. cname
            lbl.TextColor3 = C.text
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = row

            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0, 30, 0, 30)
            del.Position = UDim2.new(1, -38, 0.5, -15)
            del.BackgroundColor3 = C.redDark
            del.Text = "✕"
            del.TextColor3 = C.red
            del.Font = Enum.Font.GothamBold
            del.TextSize = 12
            del.AutoButtonColor = false
            del.ZIndex = 2
            del.Parent = row
            Corner(del, 8)
            Stroke(del, Color3.fromRGB(80, 22, 22), 1)

            del.MouseEnter:Connect(function()
                Tween(del, {BackgroundColor3 = C.red, TextColor3 = Color3.new(1,1,1)}, 0.12)
            end)
            del.MouseLeave:Connect(function()
                Tween(del, {BackgroundColor3 = C.redDark, TextColor3 = C.red}, 0.12)
            end)
            del.MouseButton1Click:Connect(function()
                local c = Library.Categories[cname]
                if c then
                    c.Button:Destroy()
                    c.Container:Destroy()
                    Library.Categories[cname] = nil
                end
                for i, n in ipairs(Library.UserCategories) do
                    if n == cname then table.remove(Library.UserCategories, i) break end
                end
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

-- ═══════════════════════════════════════════════
--  ЗАПУСК
-- ═══════════════════════════════════════════════
Library:AddCategory("база сука")
Library:AddCategory("игры бля")
Library:AddCategory("R6")
Library:AddCategory("R15")
Library:AddCategory("Своё")
Library:AddCategory("Об хабе")
Library:AddCategory("Другие ХАБЫ")

Library:BuildSvoyoContent()
do
    local svoyoCat = Library.Categories["Своё"]
    if svoyoCat then
        svoyoCat.Button.MouseButton1Click:Connect(function()
            Library:BuildSvoyoContent()
        end)
    end
end

Library:AddScript("Об хабе", [[print("s")]], "Сделано ради Деворера")

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

Library:AddScript("Другие ХАБЫ", [[
loadstring(game:HttpGet("https://gist.githubusercontent.com/maks1165/d7e70695bc613228d119efd4d28b963a/raw/f75cfce0f2ae0430cf1240d5f62c77f50dafcbfa/universal%2520script"))()
]], "Универсальное меню")

Library:AddScript("база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
]], "Полёт сына мияги")

Library:AddScript("база сука", [[
if not _G.FullBrightExecuted then
    _G.FullBrightEnabled = false
    _G.NormalLightingSettings = {
        Brightness    = game:GetService("Lighting").Brightness,
        ClockTime     = game:GetService("Lighting").ClockTime,
        FogEnd        = game:GetService("Lighting").FogEnd,
        GlobalShadows = game:GetService("Lighting").GlobalShadows,
        Ambient       = game:GetService("Lighting").Ambient,
    }
    local L = game:GetService("Lighting")
    L:GetPropertyChangedSignal("Brightness"):Connect(function()
        if L.Brightness ~= 1 and L.Brightness ~= _G.NormalLightingSettings.Brightness then
            _G.NormalLightingSettings.Brightness = L.Brightness
            if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
            L.Brightness = 1
        end
    end)
    L:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if L.ClockTime ~= 12 and L.ClockTime ~= _G.NormalLightingSettings.ClockTime then
            _G.NormalLightingSettings.ClockTime = L.ClockTime
            if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
            L.ClockTime = 12
        end
    end)
    L:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if L.FogEnd ~= 786543 and L.FogEnd ~= _G.NormalLightingSettings.FogEnd then
            _G.NormalLightingSettings.FogEnd = L.FogEnd
            if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
            L.FogEnd = 786543
        end
    end)
    L:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
        if L.GlobalShadows ~= false and L.GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
            _G.NormalLightingSettings.GlobalShadows = L.GlobalShadows
            if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
            L.GlobalShadows = false
        end
    end)
    L:GetPropertyChangedSignal("Ambient"):Connect(function()
        if L.Ambient ~= Color3.fromRGB(178,178,178) and L.Ambient ~= _G.NormalLightingSettings.Ambient then
            _G.NormalLightingSettings.Ambient = L.Ambient
            if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
            L.Ambient = Color3.fromRGB(178,178,178)
        end
    end)
    L.Brightness = 1 ; L.ClockTime = 12 ; L.FogEnd = 786543
    L.GlobalShadows = false ; L.Ambient = Color3.fromRGB(178,178,178)
    local LatestValue = true
    spawn(function()
        repeat wait() until _G.FullBrightEnabled
        while wait() do
            if _G.FullBrightEnabled ~= LatestValue then
                if not _G.FullBrightEnabled then
                    L.Brightness    = _G.NormalLightingSettings.Brightness
                    L.ClockTime     = _G.NormalLightingSettings.ClockTime
                    L.FogEnd        = _G.NormalLightingSettings.FogEnd
                    L.GlobalShadows = _G.NormalLightingSettings.GlobalShadows
                    L.Ambient       = _G.NormalLightingSettings.Ambient
                else
                    L.Brightness = 1 ; L.ClockTime = 12 ; L.FogEnd = 786543
                    L.GlobalShadows = false ; L.Ambient = Color3.fromRGB(178,178,178)
                end
                LatestValue = not LatestValue
            end
        end
    end)
end
_G.FullBrightExecuted = true
_G.FullBrightEnabled  = not _G.FullBrightEnabled
]], "Убрать освещение (Fullbright)")

Library:AddScript("база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mistervock/rbxcheatmenu/refs/heads/readme/snake.lua"))()
]], "Змея Анджелы")

Library:AddScript("игры бля", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotEnoughJack/LuaFluentDependancies/refs/heads/main/main.lua"))()
]], "Красная ваншот еботня (JJS) — читы")

Library:AddScript("игры бля", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/-beta-/main/AutoParry.lua"))()
]], "Шары твоей бати (Blade Ball)")

Library:AddScript("игры бля", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/DeadRails", true))()
]], "Твой дед под рельсами (Dead Rails) — читы")

Library:AddScript("игры бля", [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phnnsecret-hash/AutoBuilderV3/main/script.luau", true))()
]], "Ленивый строитель бля (JJS)")

Library:AddScript("база сука", [[
loadstring(game:HttpGet("https://pastebin.com/raw/uqD7VqQU"))()
]], "Симулятор взрыва Пакистана (RTX)")

Library:AddScript("база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
]], "Анти-АФК")

Library:AddScript("база сука", [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Jerk_Tool.lua"))()
]], "Дрочка")

Library:AddScript("база сука", [[
game:GetService("CoreGui").VockHub:Destroy()
game:GetService("CoreGui").VockToggle:Destroy()
]], "Стереть эту парашу с лица земли")
