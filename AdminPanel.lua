local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local customTheme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(15, 15, 15),
    Topbar = Color3.fromRGB(34, 34, 34),
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
    Name = "Infinite Yield V4 - By Z...",
    LoadingTitle = "Loading Admin Panel...",
    LoadingSubtitle = "by System",
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
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

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
local flingPower = 150
local angularVelocity = nil

-- ========== FLY MODE ==========
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

-- ========== CHARACTER SCALING (FIXED) ==========
local function setCharacterScale(scaleX, scaleY, scaleZ)
    pcall(function()
        Humanoid.AutomaticScalingEnabled = false
        Humanoid.BodyWidthScale = scaleX
        Humanoid.BodyHeightScale = scaleY
        Humanoid.BodyDepthScale = scaleZ
    end)
end

-- ========== SPIN FLING (IMPROVED) ==========
local function startSpin()
    if spinning then return end
    spinning = true
    angularVelocity = Instance.new("AngularVelocity")
    angularVelocity.MaxTorque = math.huge
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

    otherHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    otherHumanoid.Sit = true
    task.wait(0.05)

    local randomDirection = Vector3.new(
        math.random(-flingPower * 2, flingPower * 2),
        math.random(flingPower, flingPower * 2),
        math.random(-flingPower * 2, flingPower * 2)
    )
    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.MaxForce = math.huge
    linearVelocity.Velocity = randomDirection
    linearVelocity.Parent = otherRoot

    local angularVel = Instance.new("AngularVelocity")
    angularVel.MaxTorque = math.huge
    angularVel.AngularVelocity = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
    angularVel.Parent = otherRoot

    task.wait(1.5)
    linearVelocity:Destroy()
    angularVel:Destroy()
end

RootPart.Touched:Connect(onTouch)

local function flingPlayer(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        targetHumanoid.Sit = true
        task.wait(0.05)
    end
    local direction = (targetRoot.Position - RootPart.Position).Unit
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = direction * flingPower + Vector3.new(0, flingPower * 0.7, 0)
    bodyVel.Parent = targetRoot
    
    local angularVel = Instance.new("AngularVelocity")
    angularVel.MaxTorque = math.huge
    angularVel.AngularVelocity = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
    angularVel.Parent = targetRoot
    
    task.wait(1.5)
    bodyVel:Destroy()
    angularVel:Destroy()
end

local function flopTarget(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        targetHumanoid.Sit = true
        task.wait(0.05)
    end
    targetRoot.CFrame = targetRoot.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    targetRoot.Velocity = Vector3.new(0, 0, 0)
    Rayfield:Notify({Title = "Flop", Content = "Flopped " .. targetPlayer.Name, Duration = 2})
end

-- ========== IN-GAME CONSOLE WINDOW (WITH DRAGGING & LOG SERVICE) ==========
local consoleGui = nil
local consoleScroll = nil
local consoleLines = {}

local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    local UserInputService = game:GetService("UserInputService")
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function addConsoleMessage(message, messageType)
    if not consoleGui or not consoleGui.Parent then
        consoleGui = Instance.new("ScreenGui")
        consoleGui.Name = "InGameConsole"
        consoleGui.Parent = game.CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 500, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = consoleGui
        
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        titleBar.Parent = mainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -60, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.Text = "Console Output"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleBar
        
        local clearBtn = Instance.new("TextButton")
        clearBtn.Size = UDim2.new(0, 50, 1, 0)
        clearBtn.Position = UDim2.new(1, -90, 0, 0)
        clearBtn.Text = "Clear"
        clearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        clearBtn.Parent = titleBar
        clearBtn.MouseButton1Click:Connect(function()
            for _, line in ipairs(consoleLines) do
                line:Destroy()
            end
            consoleLines = {}
            consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        end)
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 1, 0)
        closeBtn.Position = UDim2.new(1, -30, 0, 0)
        closeBtn.Text = "X"
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Parent = titleBar
        closeBtn.MouseButton1Click:Connect(function()
            consoleGui:Destroy()
            consoleGui = nil
        end)
        
        consoleScroll = Instance.new("ScrollingFrame")
        consoleScroll.Size = UDim2.new(1, 0, 1, -30)
        consoleScroll.Position = UDim2.new(0, 0, 0, 30)
        consoleScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        consoleScroll.BorderSizePixel = 0
        consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        consoleScroll.ScrollBarThickness = 6
        consoleScroll.Parent = mainFrame
        
        MakeDraggable(mainFrame)
    end
    
    local color = (messageType == "error" and Color3.fromRGB(255, 100, 100)) or
                  (messageType == "warning" and Color3.fromRGB(255, 200, 100)) or
                  Color3.fromRGB(200, 200, 200)
    
    local timestamp = os.date("%H:%M:%S")
    local formattedMessage = "[" .. timestamp .. "] " .. message
    
    local lineLabel = Instance.new("TextLabel")
    lineLabel.Size = UDim2.new(1, -10, 0, 20)
    lineLabel.Position = UDim2.new(0, 5, 0, #consoleLines * 20)
    lineLabel.Text = formattedMessage
    lineLabel.TextColor3 = color
    lineLabel.BackgroundTransparency = 1
    lineLabel.TextXAlignment = Enum.TextXAlignment.Left
    lineLabel.TextSize = 11
    lineLabel.Font = Enum.Font.Code
    lineLabel.Parent = consoleScroll
    lineLabel.TextWrapped = true
    lineLabel.TextScaled = false
    lineLabel.Size = UDim2.new(1, -10, 0, 20)
    
    table.insert(consoleLines, lineLabel)
    consoleScroll.CanvasSize = UDim2.new(0, 0, 0, #consoleLines * 20 + 10)
    consoleScroll.CanvasPosition = Vector2.new(0, consoleScroll.CanvasSize.Y.Offset)
end

local oldPrint = print
local oldWarn = warn
local oldError = error

print = function(...)
    local args = {...}
    local message = ""
    for i, arg in ipairs(args) do
        message = message .. tostring(arg)
        if i < #args then message = message .. " " end
    end
    addConsoleMessage(message, "print")
    oldPrint(...)
end

warn = function(...)
    local args = {...}
    local message = ""
    for i, arg in ipairs(args) do
        message = message .. tostring(arg)
        if i < #args then message = message .. " " end
    end
    addConsoleMessage(message, "warning")
    oldWarn(...)
end

error = function(message, level)
    addConsoleMessage(message, "error")
    oldError(message, level)
end

LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        addConsoleMessage(message, "error")
    elseif messageType == Enum.MessageType.MessageWarning then
        addConsoleMessage(message, "warning")
    else
        addConsoleMessage(message, "print")
    end
end)

local function printToConsole(message, messageType)
    addConsoleMessage(message, messageType or "print")
end

-- ========== REMOTE SPY WITH SEPARATE WINDOW ==========
local remoteSpyEnabled = false
local remoteSpyConnections = {}
local remoteSpyGui = nil
local remoteSpyScroll = nil
local remoteSpyLines = {}

local function toggleRemoteSpy()
    remoteSpyEnabled = not remoteSpyEnabled
    
    if remoteSpyEnabled then
        if remoteSpyGui then remoteSpyGui:Destroy() end
        
        remoteSpyGui = Instance.new("ScreenGui")
        remoteSpyGui.Name = "RemoteSpy"
        remoteSpyGui.Parent = game.CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 500, 0, 400)
        mainFrame.Position = UDim2.new(1, -520, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = remoteSpyGui
        
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        titleBar.Parent = mainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -60, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.Text = "Remote Spy [ACTIVE]"
        titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleBar
        
        local clearBtn = Instance.new("TextButton")
        clearBtn.Size = UDim2.new(0, 50, 1, 0)
        clearBtn.Position = UDim2.new(1, -90, 0, 0)
        clearBtn.Text = "Clear"
        clearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        clearBtn.Parent = titleBar
        clearBtn.MouseButton1Click:Connect(function()
            for _, line in ipairs(remoteSpyLines) do
                line:Destroy()
            end
            remoteSpyLines = {}
        end)
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 1, 0)
        closeBtn.Position = UDim2.new(1, -30, 0, 0)
        closeBtn.Text = "X"
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Parent = titleBar
        closeBtn.MouseButton1Click:Connect(function()
            toggleRemoteSpy()
        end)
        
        remoteSpyScroll = Instance.new("ScrollingFrame")
        remoteSpyScroll.Size = UDim2.new(1, 0, 1, -30)
        remoteSpyScroll.Position = UDim2.new(0, 0, 0, 30)
        remoteSpyScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        remoteSpyScroll.BorderSizePixel = 0
        remoteSpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        remoteSpyScroll.ScrollBarThickness = 6
        remoteSpyScroll.Parent = mainFrame
        
        MakeDraggable(mainFrame)
        
        for _, remote in ipairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local conn
                if remote:IsA("RemoteEvent") then
                    conn = remote.OnClientEvent:Connect(function(...)
                        local msg = "[RemoteEvent] " .. remote.Name .. " fired with args: " .. HttpService:JSONEncode({...})
                        local line = Instance.new("TextLabel")
                        line.Size = UDim2.new(1, -10, 0, 20)
                        line.Position = UDim2.new(0, 5, 0, #remoteSpyLines * 20)
                        line.Text = msg
                        line.TextColor3 = Color3.fromRGB(255, 200, 100)
                        line.BackgroundTransparency = 1
                        line.TextXAlignment = Enum.TextXAlignment.Left
                        line.TextSize = 11
                        line.Font = Enum.Font.Code
                        line.Parent = remoteSpyScroll
                        line.TextWrapped = true
                        line.TextScaled = false
                        line.Size = UDim2.new(1, -10, 0, 20)
                        table.insert(remoteSpyLines, line)
                        remoteSpyScroll.CanvasSize = UDim2.new(0, 0, 0, #remoteSpyLines * 20 + 10)
                        remoteSpyScroll.CanvasPosition = Vector2.new(0, remoteSpyScroll.CanvasSize.Y.Offset)
                    end)
                else
                    conn = remote.OnClientInvoke:Connect(function(...)
                        local msg = "[RemoteFunction] " .. remote.Name .. " invoked with args: " .. HttpService:JSONEncode({...})
                        local line = Instance.new("TextLabel")
                        line.Size = UDim2.new(1, -10, 0, 20)
                        line.Position = UDim2.new(0, 5, 0, #remoteSpyLines * 20)
                        line.Text = msg
                        line.TextColor3 = Color3.fromRGB(100, 200, 255)
                        line.BackgroundTransparency = 1
                        line.TextXAlignment = Enum.TextXAlignment.Left
                        line.TextSize = 11
                        line.Font = Enum.Font.Code
                        line.Parent = remoteSpyScroll
                        line.TextWrapped = true
                        line.TextScaled = false
                        line.Size = UDim2.new(1, -10, 0, 20)
                        table.insert(remoteSpyLines, line)
                        remoteSpyScroll.CanvasSize = UDim2.new(0, 0, 0, #remoteSpyLines * 20 + 10)
                        remoteSpyScroll.CanvasPosition = Vector2.new(0, remoteSpyScroll.CanvasSize.Y.Offset)
                        return nil
                    end)
                end
                table.insert(remoteSpyConnections, conn)
            end
        end
        Rayfield:Notify({Title = "Remote Spy", Content = "Enabled. Window opened.", Duration = 3})
    else
        for _, conn in ipairs(remoteSpyConnections) do
            conn:Disconnect()
        end
        remoteSpyConnections = {}
        if remoteSpyGui then remoteSpyGui:Destroy() end
        remoteSpyGui = nil
        Rayfield:Notify({Title = "Remote Spy", Content = "Disabled.", Duration = 2})
    end
end

-- ========== WORKSPACE EXPLORER (ROBLOX STUDIO STYLE) ==========
local explorerGui = nil
local explorerScroll = nil
local explorerButtons = {}

local function getIconForInstance(instance)
    local className = instance.ClassName
    local icons = {
        ["Model"] = "rbxassetid://10699139705",
        ["Part"] = "rbxassetid://14250206650",
        ["Script"] = "rbxassetid://3019710370",
        ["LocalScript"] = "rbxassetid://7553924985",
        ["ModuleScript"] = "rbxassetid://15503803917",
        ["Tool"] = "rbxassetid://1841419669",
        ["Humanoid"] = "rbxassetid://1841419535",
        ["Folder"] = "rbxassetid://1841419360",
        ["BasePart"] = "rbxassetid://1841419492",
        ["Decal"] = "rbxassetid://1841419582",
        ["MeshPart"] = "rbxassetid://1841419492",
        ["WedgePart"] = "rbxassetid://1841419492",
        ["Cylinder"] = "rbxassetid://1841419492",
        ["SpawnLocation"] = "rbxassetid://1841419808",
        ["Team"] = "rbxassetid://1841419808",
    }
    return icons[className] or "rbxassetid://1841419360"
end

local function buildExplorerTree(container, instance, depth)
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
    icon.Image = getIconForInstance(instance)
    icon.BackgroundTransparency = 1
    icon.Parent = btn
    
    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0, 16, 0, 16)
    expandBtn.Position = UDim2.new(0, -14, 0.5, -8)
    expandBtn.Text = "▶"
    expandBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    expandBtn.TextSize = 10
    expandBtn.BackgroundTransparency = 1
    expandBtn.Visible = #instance:GetChildren() > 0
    expandBtn.Parent = btn
    
    local childrenContainer = Instance.new("Frame")
    childrenContainer.Size = UDim2.new(1, 0, 0, 0)
    childrenContainer.BackgroundTransparency = 1
    childrenContainer.Visible = false
    childrenContainer.Parent = container
    
    expandBtn.MouseButton1Click:Connect(function()
        if childrenContainer.Visible then
            childrenContainer.Visible = false
            expandBtn.Text = "▶"
        else
            childrenContainer.Visible = true
            expandBtn.Text = "▼"
            if #childrenContainer:GetChildren() == 0 then
                for _, child in ipairs(instance:GetChildren()) do
                    buildExplorerTree(childrenContainer, child, depth + 1)
                end
                childrenContainer.Size = UDim2.new(1, 0, 0, #childrenContainer:GetChildren() * 25)
            end
        end
        local totalHeight = 0
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("TextButton") then
                totalHeight = totalHeight + 25
            elseif child:IsA("Frame") and child.Visible then
                totalHeight = totalHeight + child.Size.Y.Offset
            end
        end
        container.Parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
    end)
    
    btn.MouseButton1Click:Connect(function()
        Rayfield:Notify({Title = "Selected", Content = instance:GetFullName(), Duration = 2})
        printToConsole("Selected: " .. instance:GetFullName())
    end)
    
    table.insert(explorerButtons, btn)
end

local function toggleWorkspaceExplorer()
    if explorerGui then
        explorerGui:Destroy()
        explorerGui = nil
        return
    end
    
    explorerGui = Instance.new("ScreenGui")
    explorerGui.Name = "WorkspaceExplorer"
    explorerGui.Parent = game.CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = explorerGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = "Game Explorer"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 50, 1, 0)
    refreshBtn.Position = UDim2.new(1, -90, 0, 0)
    refreshBtn.Text = "Refresh"
    refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Parent = titleBar
    refreshBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(explorerScroll:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        explorerButtons = {}
        
        local services = game:GetChildren()
        for _, service in ipairs(services) do
            local serviceBtn = Instance.new("TextButton")
            serviceBtn.Size = UDim2.new(1, -10, 0, 25)
            serviceBtn.Position = UDim2.new(0, 5, 0, #explorerScroll:GetChildren() * 25)
            serviceBtn.Text = service.Name .. " (" .. service.ClassName .. ")"
            serviceBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            serviceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            serviceBtn.TextXAlignment = Enum.TextXAlignment.Left
            serviceBtn.Font = Enum.Font.GothamBold
            serviceBtn.TextSize = 12
            serviceBtn.BorderSizePixel = 0
            serviceBtn.Parent = explorerScroll
            
            local serviceIcon = Instance.new("ImageLabel")
            serviceIcon.Size = UDim2.new(0, 16, 0, 16)
            serviceIcon.Position = UDim2.new(0, 2, 0.5, -8)
            serviceIcon.Image = getIconForInstance(service)
            serviceIcon.BackgroundTransparency = 1
            serviceIcon.Parent = serviceBtn
            
            local serviceExpandBtn = Instance.new("TextButton")
            serviceExpandBtn.Size = UDim2.new(0, 16, 0, 16)
            serviceExpandBtn.Position = UDim2.new(0, -14, 0.5, -8)
            serviceExpandBtn.Text = "▶"
            serviceExpandBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            serviceExpandBtn.TextSize = 10
            serviceExpandBtn.BackgroundTransparency = 1
            serviceExpandBtn.Visible = #service:GetChildren() > 0
            serviceExpandBtn.Parent = serviceBtn
            
            local serviceChildrenContainer = Instance.new("Frame")
            serviceChildrenContainer.Size = UDim2.new(1, 0, 0, 0)
            serviceChildrenContainer.BackgroundTransparency = 1
            serviceChildrenContainer.Visible = false
            serviceChildrenContainer.Parent = explorerScroll
            
            serviceExpandBtn.MouseButton1Click:Connect(function()
                if serviceChildrenContainer.Visible then
                    serviceChildrenContainer.Visible = false
                    serviceExpandBtn.Text = "▶"
                else
                    serviceChildrenContainer.Visible = true
                    serviceExpandBtn.Text = "▼"
                    if #serviceChildrenContainer:GetChildren() == 0 then
                        for _, child in ipairs(service:GetChildren()) do
                            buildExplorerTree(serviceChildrenContainer, child, 1)
                        end
                        serviceChildrenContainer.Size = UDim2.new(1, 0, 0, #serviceChildrenContainer:GetChildren() * 25)
                    end
                end
                local totalHeight = 0
                for _, child in ipairs(explorerScroll:GetChildren()) do
                    if child:IsA("TextButton") then
                        totalHeight = totalHeight + 25
                    elseif child:IsA("Frame") and child.Visible then
                        totalHeight = totalHeight + child.Size.Y.Offset
                    end
                end
                explorerScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
            end)
            
            serviceBtn.MouseButton1Click:Connect(function()
                Rayfield:Notify({Title = "Selected", Content = service:GetFullName(), Duration = 2})
                printToConsole("Selected: " .. service:GetFullName())
            end)
            
            table.insert(explorerButtons, serviceBtn)
        end
        
        explorerScroll.CanvasSize = UDim2.new(0, 0, 0, #explorerScroll:GetChildren() * 25 + 20)
    end)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        explorerGui:Destroy()
        explorerGui = nil
    end)
    
    explorerScroll = Instance.new("ScrollingFrame")
    explorerScroll.Size = UDim2.new(1, 0, 1, -30)
    explorerScroll.Position = UDim2.new(0, 0, 0, 30)
    explorerScroll.BackgroundTransparency = 1
    explorerScroll.BorderSizePixel = 0
    explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    explorerScroll.ScrollBarThickness = 6
    explorerScroll.Parent = mainFrame
    
    MakeDraggable(mainFrame)
    
    local services = game:GetChildren()
    for _, service in ipairs(services) do
        local serviceBtn = Instance.new("TextButton")
        serviceBtn.Size = UDim2.new(1, -10, 0, 25)
        serviceBtn.Position = UDim2.new(0, 5, 0, #explorerScroll:GetChildren() * 25)
        serviceBtn.Text = service.Name .. " (" .. service.ClassName .. ")"
        serviceBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        serviceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        serviceBtn.TextXAlignment = Enum.TextXAlignment.Left
        serviceBtn.Font = Enum.Font.GothamBold
        serviceBtn.TextSize = 12
        serviceBtn.BorderSizePixel = 0
        serviceBtn.Parent = explorerScroll
        
        local serviceIcon = Instance.new("ImageLabel")
        serviceIcon.Size = UDim2.new(0, 16, 0, 16)
        serviceIcon.Position = UDim2.new(0, 2, 0.5, -8)
        serviceIcon.Image = getIconForInstance(service)
        serviceIcon.BackgroundTransparency = 1
        serviceIcon.Parent = serviceBtn
        
        local serviceExpandBtn = Instance.new("TextButton")
        serviceExpandBtn.Size = UDim2.new(0, 16, 0, 16)
        serviceExpandBtn.Position = UDim2.new(0, -14, 0.5, -8)
        serviceExpandBtn.Text = "▶"
        serviceExpandBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        serviceExpandBtn.TextSize = 10
        serviceExpandBtn.BackgroundTransparency = 1
        serviceExpandBtn.Visible = #service:GetChildren() > 0
        serviceExpandBtn.Parent = serviceBtn
        
        local serviceChildrenContainer = Instance.new("Frame")
        serviceChildrenContainer.Size = UDim2.new(1, 0, 0, 0)
        serviceChildrenContainer.BackgroundTransparency = 1
        serviceChildrenContainer.Visible = false
        serviceChildrenContainer.Parent = explorerScroll
        
        serviceExpandBtn.MouseButton1Click:Connect(function()
            if serviceChildrenContainer.Visible then
                serviceChildrenContainer.Visible = false
                serviceExpandBtn.Text = "▶"
            else
                serviceChildrenContainer.Visible = true
                serviceExpandBtn.Text = "▼"
                if #serviceChildrenContainer:GetChildren() == 0 then
                    for _, child in ipairs(service:GetChildren()) do
                        buildExplorerTree(serviceChildrenContainer, child, 1)
                    end
                    serviceChildrenContainer.Size = UDim2.new(1, 0, 0, #serviceChildrenContainer:GetChildren() * 25)
                end
            end
            local totalHeight = 0
            for _, child in ipairs(explorerScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    totalHeight = totalHeight + 25
                elseif child:IsA("Frame") and child.Visible then
                    totalHeight = totalHeight + child.Size.Y.Offset
                end
            end
            explorerScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
        end)
        
        serviceBtn.MouseButton1Click:Connect(function()
            Rayfield:Notify({Title = "Selected", Content = service:GetFullName(), Duration = 2})
            printToConsole("Selected: " .. service:GetFullName())
        end)
        
        table.insert(explorerButtons, serviceBtn)
    end
    
    explorerScroll.CanvasSize = UDim2.new(0, 0, 0, #explorerScroll:GetChildren() * 25 + 20)
end

-- ========== UI TABS AND ELEMENTS ==========
local MainTab = Window:CreateTab("Player", 0)
local MovementTab = Window:CreateTab("Movement", 0)
local TrollTab = Window:CreateTab("Troll", 0)
local SizeTab = Window:CreateTab("Size", 0)
local ToolsTab = Window:CreateTab("Tools", 0)
local CustomizationTab = Window:CreateTab("Customize", 0)

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = Humanoid.WalkSpeed,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
        printToConsole("Walk Speed set to: " .. Value)
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
        printToConsole("Jump Power set to: " .. Value)
    end
})

MovementTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(State)
        if State then startFly() else stopFly() end
        printToConsole("Fly Mode: " .. (State and "Enabled" or "Disabled"))
    end
})

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
        printToConsole("Spin Fling: " .. (State and "Enabled" or "Disabled"))
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
        printToConsole("Spin Speed set to: " .. Value .. " deg/s")
    end
})

MovementTab:CreateSlider({
    Name = "Fling Power",
    Range = {50, 500},
    Increment = 10,
    Suffix = "Force",
    CurrentValue = flingPower,
    Flag = "FlingPowerSlider",
    Callback = function(Value)
        flingPower = Value
        printToConsole("Fling Power set to: " .. Value)
    end
})

local playerList = {}
local selectedPlayer = ""

local function updatePlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
    end
    if #playerList > 0 and selectedPlayer == "" then
        selectedPlayer = playerList[1]
    end
end

updatePlayerList()

local playerDropdown = TrollTab:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = selectedPlayer,
    Flag = "PlayerSelect",
    Callback = function(option)
        selectedPlayer = option
        printToConsole("Selected player: " .. option)
    end
})

TrollTab:CreateButton({
    Name = "Flop Player",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target then
            flopTarget(target)
            printToConsole("Flopped player: " .. selectedPlayer)
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found", Duration = 2})
            printToConsole("Error: Player not found - " .. selectedPlayer)
            updatePlayerList()
            playerDropdown:RefreshOptions(playerList, selectedPlayer)
        end
    end
})

TrollTab:CreateButton({
    Name = "Fling Player",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target then
            flingPlayer(target)
            printToConsole("Flung player: " .. selectedPlayer)
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found", Duration = 2})
            printToConsole("Error: Player not found - " .. selectedPlayer)
            updatePlayerList()
            playerDropdown:RefreshOptions(playerList, selectedPlayer)
        end
    end
})

SizeTab:CreateSlider({
    Name = "Scale X (Width)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = Humanoid.BodyWidthScale,
    Flag = "ScaleX",
    Callback = function(Value)
        setCharacterScale(Value, Humanoid.BodyHeightScale, Humanoid.BodyDepthScale)
        printToConsole("Character Width set to: " .. Value)
    end
})

SizeTab:CreateSlider({
    Name = "Scale Y (Height)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = Humanoid.BodyHeightScale,
    Flag = "ScaleY",
    Callback = function(Value)
        setCharacterScale(Humanoid.BodyWidthScale, Value, Humanoid.BodyDepthScale)
        printToConsole("Character Height set to: " .. Value)
    end
})

SizeTab:CreateSlider({
    Name = "Scale Z (Depth)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = Humanoid.BodyDepthScale,
    Flag = "ScaleZ",
    Callback = function(Value)
        setCharacterScale(Humanoid.BodyWidthScale, Humanoid.BodyHeightScale, Value)
        printToConsole("Character Depth set to: " .. Value)
    end
})

SizeTab:CreateButton({
    Name = "Reset Size",
    Callback = function()
        setCharacterScale(1, 1, 1)
        Rayfield:Notify({Title = "Size Reset", Content = "Character size reset to default", Duration = 2})
        printToConsole("Character size reset to default")
    end
})

ToolsTab:CreateButton({
    Name = "Remote Spy",
    Callback = toggleRemoteSpy
})

ToolsTab:CreateButton({
    Name = "Open Game Explorer",
    Callback = toggleWorkspaceExplorer
})

ToolsTab:CreateButton({
    Name = "Open Console Window",
    Callback = function()
        addConsoleMessage("Console window opened")
        Rayfield:Notify({Title = "Console", Content = "Console window opened", Duration = 2})
    end
})

CustomizationTab:CreateButton({
    Name = "Apply Custom Theme",
    Callback = function()
        Window:ModifyTheme(customTheme)
        Rayfield:Notify({Title = "Theme Applied", Content = "Custom theme has been applied!", Duration = 2})
        printToConsole("Custom theme applied")
    end
})

CustomizationTab:CreateButton({
    Name = "Reset to Default Theme",
    Callback = function()
        Window:ModifyTheme("Default")
        Rayfield:Notify({Title = "Theme Reset", Content = "Default theme restored", Duration = 2})
        printToConsole("Default theme restored")
    end
})

printToConsole("Ultimate Admin Panel Loaded!")
printToConsole("Use RightControl to toggle UI")

Rayfield:Notify({
    Title = "Infinite Yield V4",
    Content = "Use RightControl to toggle UI",
    Duration = 3
})

Players.PlayerAdded:Connect(function()
    updatePlayerList()
    if playerDropdown then
        playerDropdown:RefreshOptions(playerList, selectedPlayer)
    end
    printToConsole("Player joined: " .. Players[#Players:GetPlayers()].Name)
end)

Players.PlayerRemoving:Connect(function(playerLeft)
    updatePlayerList()
    if playerDropdown then
        playerDropdown:RefreshOptions(playerList, selectedPlayer)
    end
    printToConsole("Player left: " .. playerLeft.Name)
end)