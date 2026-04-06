local UILib = {}
UILib.Windows = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
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

local function CreateGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui
    return gui
end

function UILib.Notify(text, duration, color)
    local gui = CreateGui("NotificationGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(1, -320, 0, 10)
    frame.BackgroundColor3 = color or Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.TextWrapped = true
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    frame:TweenPosition(UDim2.new(1, -320, 0, 10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(duration or 3)
    frame:TweenPosition(UDim2.new(1, 0, 0, 10), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.3)
    gui:Destroy()
end

function UILib.CreateWindow(title, size, themeColor)
    local gui = CreateGui("UILib_" .. title)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 700, 0, 500)
    frame.Position = UDim2.new(0.5, -350, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = themeColor or Color3.fromRGB(80,80,200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 1, 0)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 150, 1, -35)
    tabContainer.Position = UDim2.new(0, 0, 0, 35)
    tabContainer.BackgroundColor3 = Color3.fromRGB(35,35,35)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = frame

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -150, 1, -35)
    contentContainer.Position = UDim2.new(0, 150, 0, 35)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = frame

    MakeDraggable(frame, titleBar)

    local window = {
        gui = gui,
        frame = frame,
        tabContainer = tabContainer,
        contentContainer = contentContainer,
        tabs = {},
        activeTab = nil,
        theme = themeColor or Color3.fromRGB(80,80,200)
    }

    function window:AddTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -10, 0, 35)
        tabBtn.Position = UDim2.new(0, 5, 0, #self.tabs * 40 + 10)
        tabBtn.Text = tabName
        tabBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        tabBtn.TextColor3 = Color3.fromRGB(200,200,200)
        tabBtn.BorderSizePixel = 0
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 14
        tabBtn.Parent = self.tabContainer

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, -20, 1, -10)
        tabContent.Position = UDim2.new(0, 10, 0, 5)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 6
        tabContent.Visible = false
        tabContent.Parent = self.contentContainer

        local tabObj = { button = tabBtn, content = tabContent, elements = {} }

        tabBtn.MouseButton1Click:Connect(function()
            if self.activeTab then
                self.activeTab.content.Visible = false
                self.activeTab.button.BackgroundColor3 = Color3.fromRGB(45,45,45)
                self.activeTab.button.TextColor3 = Color3.fromRGB(200,200,200)
            end
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = self.theme
            tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
            self.activeTab = tabObj
        end)

        table.insert(self.tabs, tabObj)
        if #self.tabs == 1 then
            tabBtn.MouseButton1Click:Fire()
        end
        return tabObj
    end

    function window:AddButton(tab, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, #tab.content:GetChildren() * 40 + 10)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Parent = tab.content
        btn.MouseButton1Click:Connect(callback)
        table.insert(tab.elements, btn)
        tab.content.CanvasSize = UDim2.new(0, 0, 0, #tab.content:GetChildren() * 40 + 20)
        return btn
    end

    function window:AddToggle(tab, text, default, callback)
        local yPos = #tab.content:GetChildren() * 40 + 10
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 35)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = tab.content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -35, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = container

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 25, 0, 25)
        toggleBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
        toggleBtn.Text = default and "✔" or ""
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(70,200,70) or Color3.fromRGB(80,80,80)
        toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 16
        toggleBtn.Parent = container

        local state = default
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            toggleBtn.Text = state and "✔" or ""
            toggleBtn.BackgroundColor3 = state and Color3.fromRGB(70,200,70) or Color3.fromRGB(80,80,80)
            if callback then callback(state) end
        end)
        if callback then callback(state) end
        table.insert(tab.elements, container)
        tab.content.CanvasSize = UDim2.new(0, 0, 0, #tab.content:GetChildren() * 40 + 20)
        return { set = function(newState) state = newState; toggleBtn.Text = state and "✔" or ""; toggleBtn.BackgroundColor3 = state and Color3.fromRGB(70,200,70) or Color3.fromRGB(80,80,80) end }
    end

    function window:AddSlider(tab, text, minVal, maxVal, default, callback)
        local yPos = #tab.content:GetChildren() * 40 + 10
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 55)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = tab.content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = text .. ": " .. string.format("%.1f", default)
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = container

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -40, 0, 6)
        sliderBg.Position = UDim2.new(0, 20, 0, 30)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = container

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - minVal)/(maxVal - minVal), 0, 1, 0)
        sliderFill.BackgroundColor3 = self.theme
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg

        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((default - minVal)/(maxVal - minVal), -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
        knob.Text = ""
        knob.BorderSizePixel = 0
        knob.Parent = container

        local value = default
        local dragging = false
        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local newVal = minVal + (maxVal - minVal) * relativeX
            value = newVal
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            knob.Position = UDim2.new(relativeX, -8, 0.5, -8)
            label.Text = text .. ": " .. string.format("%.1f", value)
            if callback then callback(value) end
        end
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        table.insert(tab.elements, container)
        tab.content.CanvasSize = UDim2.new(0, 0, 0, #tab.content:GetChildren() * 40 + 20)
        return { get = function() return value end }
    end

    function window:AddDropdown(tab, text, options, defaultIndex, callback)
        local yPos = #tab.content:GetChildren() * 40 + 10
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 40)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = tab.content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, -5, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = container

        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(0.5, -5, 1, 0)
        dropdownBtn.Position = UDim2.new(0.5, 5, 0, 0)
        dropdownBtn.Text = options[defaultIndex] or options[1]
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
        dropdownBtn.BorderSizePixel = 0
        dropdownBtn.Font = Enum.Font.Gotham
        dropdownBtn.TextSize = 14
        dropdownBtn.Parent = container

        local dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0, 0, 0, #options * 30)
        dropdownList.Position = UDim2.new(0.5, 5, 0, 40)
        dropdownList.BackgroundColor3 = Color3.fromRGB(45,45,45)
        dropdownList.BorderSizePixel = 0
        dropdownList.Visible = false
        dropdownList.Parent = container

        local selectedIndex = defaultIndex or 1
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
            optBtn.TextColor3 = Color3.fromRGB(255,255,255)
            optBtn.BorderSizePixel = 0
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 14
            optBtn.Parent = dropdownList
            optBtn.MouseButton1Click:Connect(function()
                dropdownBtn.Text = opt
                selectedIndex = i
                dropdownList.Visible = false
                if callback then callback(opt, i) end
            end)
        end

        dropdownBtn.MouseButton1Click:Connect(function()
            dropdownList.Visible = not dropdownList.Visible
        end)

        table.insert(tab.elements, container)
        tab.content.CanvasSize = UDim2.new(0, 0, 0, #tab.content:GetChildren() * 40 + 20)
        return { get = function() return options[selectedIndex], selectedIndex end }
    end

    function window:AddKeybind(tab, text, defaultKey, callback)
        local yPos = #tab.content:GetChildren() * 40 + 10
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 35)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = tab.content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, -5, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = container

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0.4, -5, 1, 0)
        keyBtn.Position = UDim2.new(0.6, 5, 0, 0)
        keyBtn.Text = defaultKey.Name
        keyBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        keyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        keyBtn.BorderSizePixel = 0
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextSize = 14
        keyBtn.Parent = container

        local listening = false
        local currentKey = defaultKey

        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            keyBtn.BackgroundColor3 = Color3.fromRGB(150,70,70)
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not listening then conn:Disconnect() return end
                if gameProcessed then return end
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    keyBtn.Text = currentKey.Name
                    listening = false
                    keyBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
                    conn:Disconnect()
                    if callback then callback(currentKey) end
                end
            end)
        end)

        local bindConn
        bindConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == currentKey and not listening then
                callback(currentKey)
            end
        end)

        table.insert(tab.elements, container)
        tab.content.CanvasSize = UDim2.new(0, 0, 0, #tab.content:GetChildren() * 40 + 20)
        return { setKey = function(newKey) currentKey = newKey; keyBtn.Text = currentKey.Name end }
    end

    return window
end

function UILib.CreateWorkspaceExplorer(parentFrame, onSelect)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
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
            if onSelect then onSelect(instance) end
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

return UILib