local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Infinite Yield V4 - Admin Panel",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local MainTab = Window:CreateTab("Player", 0)
local Section = MainTab:CreateSection("Stats")

Section:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = Humanoid.WalkSpeed,
    Flag = "Speed",
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
    end
})

Section:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = Humanoid.JumpPower,
    Flag = "Jump",
    Callback = function(Value)
        Humanoid.JumpPower = Value
    end
})

Rayfield:Notify({
    Title = "Loaded",
    Content = "Use RightControl to toggle UI",
    Duration = 3
})