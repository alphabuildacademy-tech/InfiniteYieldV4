-- AdminPanel.lua
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Admin Panel",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by You",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AdminPanelConfig",
        FileName = "Config"
    },
    KeySystem = false,
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

local PlayersTab = Window:CreateTab("Players", 0)
local MovementTab = Window:CreateTab("Movement", 0)
local WorldTab = Window:CreateTab("World", 0)
local SettingsTab = Window:CreateTab("Settings", 0)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local noclip = false
local spinning = false
local spinConnection = nil

local function startFly()
    if flying then return end
    flying = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.Velocity = Vector3.new(0,0,0)
    flyBodyVelocity.Parent = rootPart
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.CFrame = rootPart.CFrame
    flyBodyGyro.Parent = rootPart
    local moveConnection
    moveConnection = RunService.RenderStepped:Connect(function()
        if not flying then
            moveConnection:Disconnect()
            return
        end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0,0,1) end
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

local function setNoclip(state)
    noclip = state
    local function noclipLoop()
        while noclip and character and character:FindFirstChild("HumanoidRootPart") do
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait(0.1)
        end
    end
    if state then
        coroutine.wrap(noclipLoop)()
    else
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function startSpin(speed)
    if spinning then return end
    spinning = true
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    gyro.CFrame = rootPart.CFrame
    gyro.Parent = rootPart
    local lastCFrame = rootPart.CFrame
    spinConnection = RunService.RenderStepped:Connect(function()
        if not spinning then
            gyro:Destroy()
            spinConnection:Disconnect()
            return
        end
        local newCF = lastCFrame * CFrame.Angles(0, math.rad(speed or 180), 0)
        gyro.CFrame = newCF
        lastCFrame = newCF
    end)
end

local function stopSpin()
    spinning = false
    if spinConnection then spinConnection:Disconnect() end
end

local function teleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Rayfield:Notify({Title = "Teleport", Content = "Teleported to " .. targetName, Duration = 2})
    else
        Rayfield:Notify({Title = "Error", Content = "Player not found", Duration = 2})
    end
end

local function bringAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
    Rayfield:Notify({Title = "Bring", Content = "Brought all players to you", Duration = 2})
end

local function killAll()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= character then
            v.Humanoid.Health = 0
        end
    end
    Rayfield:Notify({Title = "Kill All", Content = "Killed all NPCs/players", Duration = 2})
end

local PlayerSection = PlayersTab:CreateSection("Player Controls")
PlayerSection:CreateButton({Name = "Bring All Players", Callback = bringAll})
PlayerSection:CreateButton({Name = "Kill All Others", Callback = killAll})

local playerList = {}
for _, plr in ipairs(Players:GetPlayers()) do
    table.insert(playerList, plr.Name)
end
PlayerSection:CreateDropdown({
    Name = "Teleport To Player",
    Options = playerList,
    CurrentOption = playerList[1] or "",
    Callback = teleportToPlayer
})

PlayerSection:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value) humanoid.WalkSpeed = value end
})

PlayerSection:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value) humanoid.JumpPower = value end
})

local MovementSection = MovementTab:CreateSection("Movement Modifiers")
MovementSection:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(state) if state then startFly() else stopFly() end end
})

MovementSection:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(state) setNoclip(state) end
})

local SpinSection = MovementTab:CreateSection("Spin")
SpinSection:CreateButton({Name = "Start Spin (180°/s)", Callback = function() startSpin(180) end})
SpinSection:CreateButton({Name = "Stop Spin", Callback = stopSpin})
SpinSection:CreateSlider({
    Name = "Spin Speed",
    Range = {0, 720},
    Increment = 10,
    CurrentValue = 180,
    Flag = "SpinSpeed",
    Callback = function(speed)
        if spinning then
            stopSpin()
            startSpin(speed)
        end
    end
})

local WorldSection = WorldTab:CreateSection("World Settings")
WorldSection:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 1,
    CurrentValue = 12,
    Flag = "TimeOfDay",
    Callback = function(value) Lighting.ClockTime = value end
})

WorldSection:CreateDropdown({
    Name = "Weather",
    Options = {"Clear", "Foggy", "Rain", "Storm"},
    CurrentOption = "Clear",
    Flag = "Weather",
    Callback = function(option)
        if option == "Clear" then
            Lighting.FogEnd = 100000
            Lighting.Rain = 0
        elseif option == "Foggy" then
            Lighting.FogEnd = 100
            Lighting.Rain = 0
        elseif option == "Rain" then
            Lighting.Rain = 1
            Lighting.FogEnd = 100000
        elseif option == "Storm" then
            Lighting.Rain = 1
            Lighting.Thunder = 1
        end
    end
})

local SettingsSection = SettingsTab:CreateSection("UI Settings")
SettingsSection:CreateButton({Name = "Unload Admin Panel", Callback = function() Rayfield:Destroy() end})

Rayfield:Notify({Title = "Admin Panel", Content = "Loaded! Press RightControl to toggle.", Duration = 4})