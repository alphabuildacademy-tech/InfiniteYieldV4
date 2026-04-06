-- AdminPanel.lua
local Library = require(script.Parent.source)

-- Create main window
local Window = Library:MakeWindow({
    Name = "Infinite Yield Admin Panel",
    SaveConfig = true,
    ConfigFolder = "AdminPanelConfig"
})

-- Create tabs
local PlayersTab = Window:MakeTab({Name = "Players"})
local MovementTab = Window:MakeTab({Name = "Movement"})
local WorldTab = Window:MakeTab({Name = "World"})
local ExplorerTab = Window:MakeTab({Name = "Explorer"})
local SettingsTab = Window:MakeTab({Name = "Settings"})

-- ========== Helper Functions ==========
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Fly variables
local flying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil

-- Noclip
local noclip = false

-- Spin variables
local spinning = false
local spinConnection = nil

-- Fly function
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

-- Noclip function
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

-- Spin function
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

-- Teleport functions
local function teleportToPlayer(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Library:MakeNotification({
            Name = "Teleport",
            Content = "Teleported to " .. targetName,
            Time = 2
        })
    else
        Library:MakeNotification({
            Name = "Error",
            Content = "Player not found",
            Time = 2
        })
    end
end

local function bringAll()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
    Library:MakeNotification({
        Name = "Bring",
        Content = "Brought all players to you",
        Time = 2
    })
end

local function killAll()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= character then
            v.Humanoid.Health = 0
        end
    end
    Library:MakeNotification({
        Name = "Kill All",
        Content = "Killed all NPCs/players",
        Time = 2
    })
end

-- Workspace Explorer
local function createWorkspaceExplorer(parentFrame)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -10)
    scroll.Position = UDim2.new(0, 10, 0, 5)
    scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.Parent = parentFrame
    
    local function buildTree(container, instance, depth)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, #container:GetChildren() * 25)
        btn.Text = string.rep("  ", depth) .. instance.Name .. " (" .. instance.ClassName .. ")"
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = container
        btn.MouseButton1Click:Connect(function()
            Library:MakeNotification({
                Name = "Selected",
                Content = instance:GetFullName(),
                Time = 2
            })
            print(instance:GetFullName())
        end)
        
        for _, child in ipairs(instance:GetChildren()) do
            buildTree(container, child, depth + 1)
        end
    end
    
    local function refresh()
        for _, child in ipairs(scroll:GetChildren()) do child:Destroy() end
        buildTree(scroll, workspace, 0)
        scroll.CanvasSize = UDim2.new(0, 0, 0, #scroll:GetChildren() * 25 + 20)
    end
    
    refresh()
    workspace.DescendantAdded:Connect(refresh)
    workspace.DescendantRemoved:Connect(refresh)
    return { refresh = refresh }
end

-- ========== Build UI Sections ==========

-- Players Tab Section
local playerSection = PlayersTab.AddSection({Name = "Player Controls"})

playerSection:AddButton({
    Name = "Bring All Players",
    Callback = bringAll
})

playerSection:AddButton({
    Name = "Kill All Others",
    Callback = killAll
})

-- Player list dropdown
local playerList = {}
for _, plr in ipairs(game.Players:GetPlayers()) do
    table.insert(playerList, plr.Name)
end

playerSection:AddDropdown({
    Name = "Teleport To Player",
    Options = playerList,
    Default = playerList[1] or "",
    Callback = teleportToPlayer
})

playerSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Color = Color3.fromRGB(70, 200, 70),
    Callback = function(value)
        humanoid.WalkSpeed = value
    end
})

playerSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 250,
    Default = 50,
    Color = Color3.fromRGB(70, 200, 70),
    Callback = function(value)
        humanoid.JumpPower = value
    end
})

-- Movement Tab Section
local movementSection = MovementTab.AddSection({Name = "Movement Modifiers"})

movementSection:AddToggle({
    Name = "Fly Mode",
    Default = false,
    Color = Color3.fromRGB(70, 150, 255),
    Callback = function(state)
        if state then startFly() else stopFly() end
    end
})

movementSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Color = Color3.fromRGB(70, 150, 255),
    Callback = function(state)
        setNoclip(state)
    end
})

local spinSection = MovementTab.AddSection({Name = "Spin"})

spinSection:AddButton({
    Name = "Start Spin (180°/s)",
    Callback = function() startSpin(180) end
})

spinSection:AddButton({
    Name = "Stop Spin",
    Callback = stopSpin
})

spinSection:AddSlider({
    Name = "Spin Speed",
    Min = 0,
    Max = 720,
    Default = 180,
    Color = Color3.fromRGB(255, 150, 70),
    Callback = function(speed)
        if spinning then
            stopSpin()
            startSpin(speed)
        end
    end
})

-- World Tab Section
local worldSection = WorldTab.AddSection({Name = "World Settings"})

worldSection:AddSlider({
    Name = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Color = Color3.fromRGB(255, 200, 100),
    Callback = function(value)
        game.Lighting.ClockTime = value
    end
})

worldSection:AddDropdown({
    Name = "Weather",
    Options = {"Clear", "Foggy", "Rain", "Storm"},
    Default = "Clear",
    Callback = function(option)
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
    end
})

-- Explorer Tab Section
local explorerFrame = Instance.new("Frame")
explorerFrame.Size = UDim2.new(1, 0, 1, 0)
explorerFrame.BackgroundTransparency = 1
explorerFrame.Parent = ExplorerTab

local workspaceExplorer = createWorkspaceExplorer(explorerFrame)

-- Settings Tab Section
local settingsSection = SettingsTab.AddSection({Name = "UI Settings"})

settingsSection:AddButton({
    Name = "Refresh Explorer",
    Callback = function()
        workspaceExplorer.refresh()
        Library:MakeNotification({
            Name = "Explorer",
            Content = "Workspace tree refreshed",
            Time = 2
        })
    end
})

settingsSection:AddButton({
    Name = "Unload Admin Panel",
    Callback = function()
        Window:Destroy()
        Library:MakeNotification({
            Name = "Unloaded",
            Content = "Admin panel unloaded",
            Time = 2
        })
    end
})

-- Keybind to toggle menu
local toggleKeybind = settingsSection:AddKeybind({
    Name = "Toggle Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        Window:Toggle()
    end
})

-- Startup notification
Library:MakeNotification({
    Name = "Admin Panel",
    Content = "Loaded successfully! Press RightControl to toggle.",
    Time = 4
})