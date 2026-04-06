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
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local flying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local spinning = false
local spinSpeed = 180
local spinFlingEnabled = false
local flingPower = 100
local angularVelocity = nil

local function startFly()
    if flying then return end
    flying = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.Velocity = Vector3.new(0,0,0)
    flyBodyVelocity.Parent = RootPart
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.CFrame = RootPart.CFrame
    flyBodyGyro.Parent = RootPart
    local moveConnection
    moveConnection = RunService.RenderStepped:Connect(function()
        if not flying then
            moveConnection:Disconnect()
            return
        end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0,-1,0) end
        local cam = workspace.CurrentCamera
        local moveVec = (cam.CFrame.RightVector * moveDir.X + cam.CFrame.UpVector * moveDir.Y + cam.CFrame.LookVector * moveDir.Z) * 50
        flyBodyVelocity.Velocity = moveVec
        flyBodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
end

local function startSpin()
    if spinning then return end
    spinning = true
    angularVelocity = Instance.new("BodyAngularVelocity")
    angularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    angularVelocity.AngularVelocity = Vector3.new(0, math.rad(spinSpeed), 0)
    angularVelocity.Parent = RootPart
end

local function stopSpin()
    spinning = false
    if angularVelocity then angularVelocity:Destroy() end
end

local function onTouch(otherPart)
    if not spinFlingEnabled then return end
    if not spinning then return end
    local otherCharacter = otherPart:FindFirstAncestorOfClass("Model")
    if not otherCharacter then return end
    if otherCharacter == Character then return end
    local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
    if not otherHumanoid then return end
    local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
    if not otherRoot then return end
    
    otherHumanoid.Sit = true
    
    local randomDirection = Vector3.new(math.random(-flingPower, flingPower), math.random(flingPower/2, flingPower), math.random(-flingPower, flingPower))
    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.MaxForce = math.huge
    linearVelocity.Velocity = randomDirection
    linearVelocity.Parent = otherRoot
    
    local angularVelocity = Instance.new("AngularVelocity")
    angularVelocity.MaxTorque = math.huge
    angularVelocity.AngularVelocity = Vector3.new(math.random(-500,500), math.random(-500,500), math.random(-500,500))
    angularVelocity.Parent = otherRoot
    
    task.wait(1)
    
    linearVelocity:Destroy()
    angularVelocity:Destroy()
end

RootPart.Touched:Connect(onTouch)

local MainTab = Window:CreateTab("Player", 0)
local PlayerSection = MainTab:CreateSection("Stats")

MainTab:CreateSlider({
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

MainTab:CreateSlider({
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

local MovementTab = Window:CreateTab("Movement", 0)
local FlySection = MovementTab:CreateSection("Fly")
MovementTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(State)
        if State then startFly() else stopFly() end
    end
})

local SpinSection = MovementTab:CreateSection("Spin Fling")
MovementTab:CreateToggle({
    Name = "Spin Fling Enabled",
    CurrentValue = false,
    Flag = "SpinFlingToggle",
    Callback = function(State)
        spinFlingEnabled = State
        if State and not spinning then
            startSpin()
        elseif not State and spinning and not spinFlingEnabled then
            stopSpin()
        end
    end
})

MovementTab:CreateSlider({
    Name = "Spin Speed",
    Range = {30, 720},
    Increment = 10,
    Suffix = "deg/s",
    CurrentValue = spinSpeed,
    Flag = "SpinSpeedSlider",
    Callback = function(Value)
        spinSpeed = Value
        if spinning then
            angularVelocity.AngularVelocity = Vector3.new(0, math.rad(spinSpeed), 0)
        end
    end
})

MovementTab:CreateSlider({
    Name = "Fling Power",
    Range = {50, 500},
    Increment = 10,
    Suffix = "Velocity",
    CurrentValue = flingPower,
    Flag = "FlingPowerSlider",
    Callback = function(Value)
        flingPower = Value
    end
})

Rayfield:Notify({
    Title = "Loaded",
    Content = "Use RightControl to toggle UI",
    Duration = 3
})