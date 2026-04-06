local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Infinite Yield V4 - Admin Panel",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false,
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local MainTab = Window:CreateTab("Player", 0)
local Section = MainTab:CreateSection("Stats")

local SpeedSlider = Section:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = Humanoid.WalkSpeed,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
    end
})

local JumpSlider = Section:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = Humanoid.JumpPower,
    Flag = "JumpSlider",
    Callback = function(Value)
        Humanoid.JumpPower = Value
    end
})

Section:CreateButton({
    Name = "Example Button",
    Callback = function()
        Rayfield:Notify({
            Title = "Button Clicked",
            Content = "The button works!",
            Duration = 2
        })
    end
})

Rayfield:Notify({
    Title = "Loaded",
    Content = "Use RightControl to toggle UI",
    Duration = 3
})