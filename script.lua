-- vockHub key-system

local correctKey = "1111" --

local sg = Instance.new("ScreenGui")
sg.Name = "VockKeySystem"
sg.ResetOnSpawn = false
sg.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "🔑 vockHub key-system"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1,-20,0,40)
box.Position = UDim2.new(0,10,0,50)
box.PlaceholderText = "Enter key..."
box.Text = ""
box.BackgroundColor3 = Color3.fromRGB(30,30,45)
box.TextColor3 = Color3.new(1,1,1)
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1,-20,0,40)
btn.Position = UDim2.new(0,10,0,100)
btn.Text = "Submit"
btn.BackgroundColor3 = Color3.fromRGB(100,100,255)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    if box.Text == correctKey then
        sg:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mistervock/rbxcheatmenu/refs/heads/readme/main.lua"))();
    else
        box.Text = ""
        box.PlaceholderText = "Wrong key!"
    end
end)
