local UILib = require(script.Parent.UILibrary)

local mainWin = UILib.CreateWindow("Admin Panel", UDim2.new(0, 850, 0, 600), Color3.fromRGB(200, 100, 100))

local playerTab = mainWin:AddTab("Players")
local tweenTab = mainWin:AddTab("Tween / Spin")
local worldTab = mainWin:AddTab("World")
local exploreTab = mainWin:AddTab("Explorer")
local settingsTab = mainWin:AddTab("Settings")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local noclip = false
local flyBodyVelocity = nil
local spinBodyGyro = nil
local spinning = false

local function startFly()
    if flying then return end
    flying = true
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.new(0,0,0)
    bodyVel.Parent = rootPart
    flyBodyVelocity = bodyVel

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    spinBodyGyro = bodyGyro

    game:GetService("RunService").RenderStepped:Connect(function()
        if not flying then return end
        local moveDir = Vector3.new()
        local UserInputService = game:GetService("UserInputService")
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0,-1,0) end
        local cam = workspace.CurrentCamera
        local moveVec = (cam.CFrame.RightVector * moveDir.X + cam.CFrame.UpVector * moveDir.Y + cam.CFrame.LookVector * moveDir.Z) * 50
        bodyVel.Velocity = moveVec
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if spinBodyGyro then spinBodyGyro:Destroy() end
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
    game:GetService("RunService").RenderStepped:Connect(function()
        if not spinning then gyro:Destroy() return end
        local newCF = lastCFrame * CFrame.Angles(0, math.rad(speed or 180), 0)
        gyro.CFrame = newCF
        lastCFrame = newCF
    end)
end

local function stopSpin()
    spinning = false
end

local function teleportToPlayer(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        UILib.Notify("Teleported to " .. targetName)
    else
        UILib.Notify("Player not found or no character", 2, Color3.fromRGB(200,50,50))
    end
end

local function bringAll()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
    UILib.Notify("Brought all players to you")
end

local function killAll()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= character then
            v.Humanoid.Health = 0
        end
    end
    UILib.Notify("Killed all NPCs/players (except you)")
end

mainWin:AddButton(playerTab, "Teleport to me (Bring)", function() bringAll() end)
mainWin:AddButton(playerTab, "Kill all others", function() killAll() end)

local playerList = {}
for _, plr in ipairs(game.Players:GetPlayers()) do
    table.insert(playerList, plr.Name)
end
local playerDropdown = mainWin:AddDropdown(playerTab, "Teleport to player", playerList, 1, function(selected)
    teleportToPlayer(selected)
end)

mainWin:AddSlider(playerTab, "Walk Speed", 16, 250, 16, function(value)
    humanoid.WalkSpeed = value
end)

mainWin:AddSlider(playerTab, "Jump Power", 50, 250, 50, function(value)
    humanoid.JumpPower = value
end)

local flyToggle = mainWin:AddToggle(playerTab, "Fly Mode", false, function(state)
    if state then startFly() else stopFly() end
end)

local noclipToggle = mainWin:AddToggle(playerTab, "Noclip", false, function(state)
    setNoclip(state)
end)

mainWin:AddButton(tweenTab, "Start Spin (180°/s)", function() startSpin(180) end)
mainWin:AddButton(tweenTab, "Stop Spin", function() stopSpin() end)
local spinSpeedSlider = mainWin:AddSlider(tweenTab, "Spin Speed (deg/s)", 0, 720, 180, function(speed)
    if spinning then
        stopSpin()
        startSpin(speed)
    end
end)

mainWin:AddSlider(worldTab, "Time of Day", 0, 24, 12, function(value)
    game.Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(value))
end)

local weatherOptions = {"Clear", "Foggy", "Rain", "Storm"}
mainWin:AddDropdown(worldTab, "Weather", weatherOptions, 1, function(option)
    if option == "Clear" then
        game.Lighting.FogEnd = 100000
        game.Lighting.Rain = 0
    elseif option == "Foggy" then
        game.Lighting.FogEnd = 100
        game.Lighting.Rain = 0
    elseif option == "Rain" then
        game.Lighting.Rain = 1
        game.Lighting.FogEnd = 100000
    elseif option == "Storm" then
        game.Lighting.Rain = 1
        game.Lighting.Thunder = 1
    end
end)

local explorerFrame = Instance.new("Frame")
explorerFrame.Size = UDim2.new(1, -20, 1, -10)
explorerFrame.Position = UDim2.new(0, 10, 0, 5)
explorerFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
explorerFrame.BorderSizePixel = 0
explorerFrame.Parent = exploreTab.content

local workspaceExplorer = UILib.CreateWorkspaceExplorer(explorerFrame, function(selectedInstance)
    UILib.Notify("Selected: " .. selectedInstance:GetFullName())
    print(selectedInstance:GetFullName())
end)

mainWin:AddKeybind(settingsTab, "Toggle Menu", Enum.KeyCode.RightControl, function()
    mainWin.frame.Visible = not mainWin.frame.Visible
end)

mainWin:AddButton(settingsTab, "Refresh Explorer", function()
    workspaceExplorer.refresh()
    UILib.Notify("Explorer refreshed")
end)

mainWin:AddButton(settingsTab, "Unload Admin Panel", function()
    mainWin.gui:Destroy()
    UILib.Notify("Admin Panel unloaded")
end)

UILib.Notify("Admin Panel loaded! Press RightControl to toggle.")