local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Vock hub V1", "Serpent")

-- Game Scripts
local Tab = Window:NewTab("Game Scripts")
local Section = Tab:NewSection("Game Scripts")
Section:NewButton("Funky Friday Script", "beep beep bobobobo beep beep", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/funky-friday-autoplay/main/main.lua",true))()
end)
Section:NewButton("RTX", "rtx", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Qunce5TP",true))()
end)
Section:NewButton("doors script", "doorsscript", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/slowpii/slowpihub/main/slowpihax",true))()
end)

--Character
local Tab = Window:NewTab("Character")
local Section = Tab:NewSection("Character")
Section:NewSlider("WalkSpeed", "Changes WalkSpeed", 500, 16, function(v) -- 500 (MaxValue) | 0 (MinValue)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)
Section:NewSlider("JumpPower", "Changes JumpPower", 500, 50, function(v) -- 500 (MaxValue) | 0 (MinValue)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    game.Players.LocalPlayer.Character.Humanoid.JumpHeight = v
end)
Section:NewButton("AnitCheat Bypass", "Works in most games but not all", function()
    Events = true -- Allow RemoteEvents (if true, blocks if false)
    Requests = false -- Allow RemoteFunctions (if true, blocks if false)
    Hitbox = true -- Allow Normal Hitbox (if true, attempt to bypass hbe if false)
    loadstring(game:HttpGet("https://pastebin.com/raw/MZrwt5Rm", true))()
    end)
Section:NewButton("noclip", "noclip", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/9LBsfRkD",true))()
end)

-- Settings
local Tab = Window:NewTab("Settings")
local Section = Tab:NewSection("Settings")
Section:NewKeybind("Toggle UI", "Toggle's UI", Enum.KeyCode.RightShift, function()
	Library:ToggleUI()
end)
--Credits
local Tab = Window:NewTab("Credits")
local Section = Tab:NewSection("Credits")
Section:NewButton("Made By Mistervock#3840", "author 1", function()
end)
--Keys
local Tab = Window:NewTab("Keys")
local Section = Tab:NewSection("Keys")
Section:NewButton("Doors script Key_mZUjim6kXqCkmid0c9pXH4jEqfk7F6PebRrmOTzd", "doorskey", function()
end)
