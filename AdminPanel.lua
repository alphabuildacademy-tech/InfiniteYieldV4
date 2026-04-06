local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local customTheme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(15, 15, 15),
    Topbar = Color3.fromRGB(173, 216, 230),
    Shadow = Color3.fromRGB(0, 0, 0),
    NotificationBackground = Color3.fromRGB(20, 20, 20),
    NotificationTextColor = Color3.fromRGB(255, 255, 255),
    NotificationActionsBackground = Color3.fromRGB(35, 0, 70),
    TabBackground = Color3.fromRGB(15, 15, 15),
    TabStroke = Color3.fromRGB(85, 85, 85),
    TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
    TabTextColor = Color3.fromRGB(149, 149, 149),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
    ElementStroke = Color3.fromRGB(50, 50, 50),
    SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
    SliderBackground = Color3.fromRGB(50, 138, 220),
    SliderProgress = Color3.fromRGB(50, 138, 220),
    SliderStroke = Color3.fromRGB(58, 163, 255),
    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(0, 146, 214),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
    ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
    ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
    ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
    DropdownSelected = Color3.fromRGB(40, 40, 40),
    DropdownUnselected = Color3.fromRGB(30, 30, 30),
    InputBackground = Color3.fromRGB(30, 30, 30),
    InputStroke = Color3.fromRGB(65, 65, 65),
    PlaceholderColor = Color3.fromRGB(178, 178, 178),
}

local Window = Rayfield:CreateWindow({
    Name = "Infinite Yield V4 - Admin Panel",
    LoadingTitle = "Loading Admin Panel...",
    LoadingSubtitle = "by You",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UltimateAdmin",
        FileName = "Config"
    },
    KeySystem = false,
    ToggleUIKeybind = Enum.KeyCode.RightControl,
    Theme = customTheme,
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

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
local flingingPlayers = {}
local remoteSpyEnabled = false
local remoteSpyConnections = {}

-- Fly mode using BodyVelocity and BodyGyro
local function startFly()
    if flying then return end
    flying = true

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = RootPart

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = RootPart.CFrame
    bodyGyro.Parent = RootPart

    local moveConnection
    moveConnection = RunService.RenderStepped:Connect(function()
        if not flying then
            moveConnection:Disconnect()
            return
        end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end

        local cam = workspace.CurrentCamera
        local moveVec = (cam.CFrame.RightVector * moveDir.X + cam.CFrame.UpVector * moveDir.Y + cam.CFrame.LookVector * moveDir.Z) * 50
        bodyVelocity.Velocity = moveVec
        bodyGyro.CFrame = cam.CFrame
    end)

    flyBodyVelocity = bodyVelocity
    flyBodyGyro = bodyGyro
end

local function stopFly()
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
end

-- Scale the character using Humanoid scale properties
local function setCharacterScale(scaleX, scaleY, scaleZ)
    Humanoid.BodyDepthScale = scaleZ
    Humanoid.BodyWidthScale = scaleX
    Humanoid.BodyHeightScale = scaleY
end

-- Spin and Fling
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

local function flingPlayer(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid.Sit = true
    end
    local direction = (targetRoot.Position - RootPart.Position).Unit
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = direction * flingPower + Vector3.new(0, flingPower * 0.5, 0)
    bodyVel.Parent = targetRoot
    task.wait(1)
    bodyVel:Destroy()
end

local function flopTarget(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid.Sit = true
    end
    targetRoot.CFrame = targetRoot.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    targetRoot.Velocity = Vector3.new(0, 0, 0)
    Rayfield:Notify({Title = "Flop", Content = "Flopped " .. targetPlayer.Name, Duration = 2})
end

local function toggleRemoteSpy()
    remoteSpyEnabled = not remoteSpyEnabled
    if remoteSpyEnabled then
        for _, remote in ipairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local conn
                if remote:IsA("RemoteEvent") then
                    conn = remote.OnClientEvent:Connect(function(...)
                        warn("[RemoteSpy] " .. remote.Name .. " fired with args: ", ...)
                    end)
                else
                    conn = remote.OnClientInvoke:Connect(function(...)
                        warn("[RemoteSpy] " .. remote.Name .. " invoked with args: ", ...)
                        return nil
                    end)
                end
                table.insert(remoteSpyConnections, conn)
            end
        end
        Rayfield:Notify({Title = "Remote Spy", Content = "Enabled. Check console (F9).", Duration = 3})
    else
        for _, conn in ipairs(remoteSpyConnections) do
            conn:Disconnect()
        end
        remoteSpyConnections = {}
        Rayfield:Notify({Title = "Remote Spy", Content = "Disabled.", Duration = 2})
    end
end

-- Toggle Workspace Explorer with a proper tree view
local function toggleWorkspaceExplorer()
    local explorerGui = Instance.new("ScreenGui")
    explorerGui.Name = "WorkspaceExplorer"
    explorerGui.Parent = game.CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = explorerGui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.Text = "Workspace Explorer"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        explorerGui:Destroy()
    end)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame

    local function getIcon(instance)
        local className = instance.ClassName
        local icons = {
            ["Part"] = "rbxassetid://1841419492",
            ["Model"] = "rbxassetid://1841419182",
            ["Script"] = "rbxassetid://1841419622",
            ["Tool"] = "rbxassetid://1841419669",
            ["Humanoid"] = "rbxassetid://1841419535",
        }
        return icons[className] or "rbxassetid://1841419360"
    end

    local function buildTree(container, instance, depth, isLastChild)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5 + (depth * 15), 0, #container:GetChildren() * 25)
        btn.Text = "  " .. instance.Name .. " (" .. instance.ClassName .. ")"
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = container

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 2, 0.5, -8)
        icon.Image = getIcon(instance)
        icon.BackgroundTransparency = 1
        icon.Parent = btn

        btn.MouseButton1Click:Connect(function()
            Rayfield:Notify({Title = "Selected", Content = instance:GetFullName(), Duration = 2})
            print(instance:GetFullName())
        end)

        for _, child in ipairs(instance:GetChildren()) do
            buildTree(container, child, depth + 1, false)
        end
    end

    buildTree(scrollFrame, workspace, 0, true)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 25 + 20)
end

-- Create Tabs
local MainTab = Window:CreateTab("Player", 0)
local MovementTab = Window:CreateTab("Movement", 0)
local TrollTab = Window:CreateTab("Troll", 0)
local SizeTab = Window:CreateTab("Size", 0)
local ToolsTab = Window:CreateTab("Tools", 0)
local CustomizationTab = Window:CreateTab("Customize", 0)

-- Player Tab
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

-- Movement Tab
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

-- Troll Tab
local TrollSection = TrollTab:CreateSection("Troll Commands")

local playerList = {}
local function updatePlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
    end
end

updatePlayerList()

local selectedPlayer = playerList[1] or ""
local playerDropdown = TrollTab:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = selectedPlayer,
    Flag = "PlayerSelect",
    Callback = function(option)
        selectedPlayer = option
    end
})

TrollTab:CreateButton({
    Name = "Flop Player",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target then
            flopTarget(target)
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found", Duration = 2})
        end
    end
})

TrollTab:CreateButton({
    Name = "Fling Player",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target then
            flingPlayer(target)
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found", Duration = 2})
        end
    end
})

-- Size Tab
local SizeSection = SizeTab:CreateSection("Character Size")

SizeTab:CreateSlider({
    Name = "Scale X (Width)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "ScaleX",
    Callback = function(Value)
        setCharacterScale(Value, Humanoid.BodyWidthScale, Humanoid.BodyDepthScale)
    end
})

SizeTab:CreateSlider({
    Name = "Scale Y (Height)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "ScaleY",
    Callback = function(Value)
        setCharacterScale(Humanoid.BodyWidthScale, Value, Humanoid.BodyDepthScale)
    end
})

SizeTab:CreateSlider({
    Name = "Scale Z (Depth)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "ScaleZ",
    Callback = function(Value)
        setCharacterScale(Humanoid.BodyWidthScale, Humanoid.BodyHeightScale, Value)
    end
})

SizeTab:CreateButton({
    Name = "Reset Size",
    Callback = function()
        setCharacterScale(1, 1, 1)
        Rayfield:Notify({Title = "Size Reset", Content = "Character size reset to default", Duration = 2})
    end
})

-- Tools Tab
local ToolsSection = ToolsTab:CreateSection("Dev Tools")

ToolsTab:CreateButton({
    Name = "Remote Spy",
    Callback = toggleRemoteSpy
})

ToolsTab:CreateButton({
    Name = "Open Workspace Explorer",
    Callback = toggleWorkspaceExplorer
})

-- Customization Tab
local CustomSection = CustomizationTab:CreateSection("Window Customization")

CustomizationTab:CreateButton({
    Name = "Apply Custom Theme",
    Callback = function()
        Window:ModifyTheme(customTheme)
        Rayfield:Notify({Title = "Theme Applied", Content = "Custom theme has been applied!", Duration = 2})
    end
})

CustomizationTab:CreateButton({
    Name = "Reset to Default Theme",
    Callback = function()
        Window:ModifyTheme("Default")
        Rayfield:Notify({Title = "Theme Reset", Content = "Default theme restored", Duration = 2})
    end
})

-- Startup notification
Rayfield:Notify({
    Title = "Ultimate Admin Loaded",
    Content = "Use RightControl to toggle UI",
    Duration = 3
})