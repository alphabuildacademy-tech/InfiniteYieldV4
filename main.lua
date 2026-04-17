-- main.lua (Kurby's Admin Panel) 
-- Made By - Z..../Zoro

-- ==================== UI LIBRARY ====================
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")

-- Clipboard function 
local function CopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    elseif syn and syn.write_clipboard then
        syn.write_clipboard(text)
    elseif game:GetService("CoreGui").RobloxGui:FindFirstChild("Clipboard") then
        game:GetService("CoreGui").RobloxGui.Clipboard:SetText(text)
    else
        warn("Clipboard not supported")
        return false
    end
    return true
end

local Library = { Toggled = true, Accent = Color3.fromRGB(160, 60, 255), _blockDrag = false }

local Icons = {
    home = { 16898613509, 48, 48, 820, 147 },
    flame = { 16898613353, 48, 48, 967, 306 },
    settings = { 16898613777, 48, 48, 771, 257 },
    account = { 16898613869, 48, 48, 661, 869 },
    eye = { 16898613353, 48, 48, 771, 563 },
    ["map-pin"] = { 16898613613, 48, 48, 820, 257 },
    ["bar-chart-2"] = { 16898612629, 48, 48, 967, 710 },
    swords = { 16898613777, 48, 48, 967, 759 },
    user = { 16898613869, 48, 48, 661, 869 },
    shield = { 16898613777, 48, 48, 869, 0 },
    zap = { 16898613869, 48, 48, 918, 906 },
    target = { 16898613869, 48, 48, 514, 771 },
    globe = { 16898613509, 48, 48, 771, 563 },
    layout = { 16898613509, 48, 48, 967, 612 },
    search = { 16898613699, 48, 48, 918, 857 },
    save = { 16898613699, 48, 48, 918, 453 },
    sliders = { 16898613777, 48, 48, 404, 771 },
    info = { 16898613869, 48, 48, 820, 147 },
    commands = { 16898613699, 48, 48, 771, 563 }
}

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in next, props do
        if i ~= "Parent" then
            obj[i] = v
        end
    end
    obj.Parent = props.Parent
    return obj
end

local function Tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:MakeDraggable(handle, target)
    target = target or handle
    local THRESHOLD = 4
    local dragging, didDrag = false, false
    local dStart, sPos

    handle.InputBegan:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not Library._blockDrag then
            dragging = true
            didDrag = false
            dStart = i.Position
            sPos = target.Position
        end
    end)

    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            if not didDrag and (math.abs(d.X) >= THRESHOLD or math.abs(d.Y) >= THRESHOLD) then
                didDrag = true
            end
            if didDrag then
                target.Position = UDim2.new(
                    sPos.X.Scale, sPos.X.Offset + d.X,
                    sPos.Y.Scale, sPos.Y.Offset + d.Y
                )
            end
        end
    end)

    return function()
        local v = didDrag
        didDrag = false
        return v
    end
end

function Library:GetIcon(name)
    return Icons[name] or Icons.home
end

function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", {
        Name = "KurbyLib",
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui,
        ResetOnSpawn = false
    })
    if getgenv then
        if getgenv()._KurbyUI then
            getgenv()._KurbyUI:Destroy()
        end
        getgenv()._KurbyUI = ScreenGui
    end

    local Main = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(8, 8, 8),
        Position = UDim2.new(0.5, -300, 0.5, -220),
        Size = UDim2.new(0, 600, 0, 440)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Main })
    Create("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Parent = Main })

    local Sidebar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
        Size = UDim2.new(0, 50, 1, 0)
    })
    Create("UIStroke", { Color = Color3.fromRGB(35, 35, 35), ApplyStrokeMode = "Border", Parent = Sidebar })

    Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Font = "GothamBold",
        Text = "K",
        TextColor3 = Library.Accent,
        TextSize = 22
    })

    local List = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 1, -36)
    })
    Create("UIListLayout", {
        Parent = List,
        HorizontalAlignment = "Center",
        Padding = UDim.new(0, 4)
    })

    local Container = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(1, -50, 1, 0)
    })

    local DragBar = Create("Frame", {
        Name = "DragBar",
        Parent = Main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 0
    })
    local DragSide = Create("Frame", {
        Name = "DragSide",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 10
    })
    local wasDragging = Library:MakeDraggable(DragBar, Main)
    Library:MakeDraggable(DragSide, Main)

    local Header = Create("Frame", { Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48) })
    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0, 180, 1, 0),
        Font = "GothamBold",
        Text = title or "Kurby Hub",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        TextXAlignment = "Left"
    })

    local CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Parent = Header,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(200, 55, 55),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        Font = "GothamBold",
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 10
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = CloseBtn })
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(255, 70, 70) }) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(200, 55, 55) }) end)
    CloseBtn.MouseButton1Click:Connect(function()
        if wasDragging() then return end
        toggled = false
        Main.Visible = false
    end)

    local SubTabBar = Create("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(1, -240, 1, 0)
    })
    Create("UIListLayout", {
        Parent = SubTabBar,
        FillDirection = "Horizontal",
        Padding = UDim.new(0, 16),
        VerticalAlignment = "Center"
    })
    Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1)
    })

    local Folder = Create("Frame", {
        Parent = Container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 1, -48)
    })

    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local toggled = true

    local function toggleUI()
        toggled = not toggled
        Main.Visible = toggled
    end

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleUI()
        end
    end)

    if isMobile then
        local ToggleBtn = Create("ImageButton", {
            Name = "MobileToggle",
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Position = UDim2.new(1, -60, 1, -60),
            Size = UDim2.new(0, 44, 0, 44),
            Image = "",
            AutoButtonColor = false,
            ZIndex = 100
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleBtn })
        Create("UIStroke", { Color = Library.Accent, Thickness = 2, Parent = ToggleBtn })
        Create("TextLabel", {
            Parent = ToggleBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = "GothamBold",
            Text = "K",
            TextColor3 = Library.Accent,
            TextSize = 20,
            ZIndex = 101
        })
        local wasDraggingBtn = Library:MakeDraggable(ToggleBtn)
        ToggleBtn.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) and not wasDraggingBtn() then
                toggleUI()
            end
        end)
    end

    local Window = { Current = nil }

    function Window:CreateTab(name, iconName)
        local Btn = Create("ImageButton", {
            Name = name .. "Tab",
            Parent = List,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50)
        })

        local Highlight = Create("Frame", {
            Parent = Btn,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0)
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Highlight })

        local Ind = Create("Frame", {
            Name = "Indicator",
            Parent = Btn,
            BackgroundColor3 = Library.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, -12),
            Size = UDim2.new(0, 3, 0, 24),
            BackgroundTransparency = 1,
            ZIndex = 5
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Ind })

        local iconData = Library:GetIcon(iconName or "home")
        local Ico = Create("ImageLabel", {
            Name = "Icon",
            Parent = Btn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -12, 0.5, -12),
            Size = UDim2.new(0, 24, 0, 24),
            Image = "rbxassetid://" .. iconData[1],
            ImageRectSize = Vector2.new(iconData[2], iconData[3]),
            ImageRectOffset = Vector2.new(iconData[4], iconData[5]),
            ImageColor3 = Color3.fromRGB(140, 140, 140),
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 6
        })

        local Tab = { SubTabs = {}, CurrentST = nil }

        function Tab:Select()
            for _, v in next, List:GetChildren() do
                if v:IsA("ImageButton") then
                    if v:FindFirstChild("Indicator") then
                        Tween(v.Indicator, 0.25, { BackgroundTransparency = 1 })
                    end
                    if v:FindFirstChild("Icon") then
                        Tween(v.Icon, 0.25, { ImageColor3 = Color3.fromRGB(140, 140, 140) })
                    end
                    for _, f in next, v:GetChildren() do
                        if f:IsA("Frame") and f.Name ~= "Indicator" then
                            Tween(f, 0.25, { BackgroundTransparency = 1 })
                        end
                    end
                end
            end
            if Window.Current then
                for _, st in next, Window.Current.Tab.SubTabs do
                    st.Btn.Visible = false
                    st.Page.Visible = false
                end
            end
            Window.Current = { Tab = Tab }
            Tween(Ico, 0.25, { ImageColor3 = Library.Accent })
            Tween(Ind, 0.25, { BackgroundTransparency = 0 })
            Tween(Highlight, 0.25, { BackgroundTransparency = 0.85 })
            for _, st in next, Tab.SubTabs do
                st.Btn.Visible = true
            end
            if Tab.CurrentST then
                Tab.CurrentST:Select()
            elseif Tab.SubTabs[1] then
                Tab.SubTabs[1]:Select()
            end
        end

        Btn.MouseButton1Click:Connect(function() Tab:Select() end)
        Btn.MouseEnter:Connect(function() if not Window.Current or Window.Current.Tab ~= Tab then Tween(Highlight, 0.2, { BackgroundTransparency = 0.92 }) end end)
        Btn.MouseLeave:Connect(function() if not Window.Current or Window.Current.Tab ~= Tab then Tween(Highlight, 0.2, { BackgroundTransparency = 1 }) end end)

        function Tab:CreateSubTab(stName, stIconName)
            local stIconData = Library:GetIcon(stIconName or "layout")
            local SBtn = Create("Frame", {
                Parent = SubTabBar,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = "X",
                Visible = false
            })
            local SClick = Create("TextButton", {
                Parent = SBtn,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            local SIco = Create("ImageLabel", {
                Name = "Icon",
                Parent = SBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://" .. stIconData[1],
                ImageRectSize = Vector2.new(stIconData[2], stIconData[3]),
                ImageRectOffset = Vector2.new(stIconData[4], stIconData[5]),
                ImageColor3 = Color3.fromRGB(160, 160, 160),
                ScaleType = Enum.ScaleType.Fit
            })
            local SText = Create("TextLabel", {
                Name = "Label",
                Parent = SBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 20, 0, 0),
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = "X",
                Font = "Gotham",
                Text = stName,
                TextColor3 = Color3.fromRGB(160, 160, 160),
                TextSize = 13
            })
            local SLine = Create("Frame", {
                Parent = SBtn,
                BackgroundColor3 = Library.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 2)
            })
            local SPage = Create("ScrollingFrame", {
                Parent = Folder,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Accent
            })
            Create("UIListLayout", {
                Parent = SPage,
                Padding = UDim.new(0, 10),
                HorizontalAlignment = "Center"
            })
            Create("UIPadding", {
                Parent = SPage,
                PaddingTop = UDim.new(0, 14),
                PaddingLeft = UDim.new(0, 18),
                PaddingRight = UDim.new(0, 18)
            })

            local SubTab = { Page = SPage, Btn = SBtn }

            function SubTab:Select()
                if Tab.CurrentST then
                    Tab.CurrentST.Page.Visible = false
                    Tween(Tab.CurrentST.Btn.Label, 0.2, { TextColor3 = Color3.fromRGB(160, 160, 160) })
                    Tween(Tab.CurrentST.Btn.Icon, 0.2, { ImageColor3 = Color3.fromRGB(160, 160, 160) })
                    local oldLine = Tab.CurrentST.Btn:FindFirstChildOfClass("Frame")
                    if oldLine then
                        Tween(oldLine, 0.2, { BackgroundTransparency = 1 })
                    end
                end
                Tab.CurrentST = SubTab
                SPage.Visible = true
                Tween(SText, 0.2, { TextColor3 = Color3.new(1, 1, 1) })
                Tween(SIco, 0.2, { ImageColor3 = Library.Accent })
                Tween(SLine, 0.2, { BackgroundTransparency = 0 })
            end
            SClick.MouseButton1Click:Connect(function() SubTab:Select() end)
            table.insert(Tab.SubTabs, SubTab)

            function SubTab:CreateSection(secName)
                local Sec = Create("Frame", {
                    Parent = SPage,
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                    Size = UDim2.new(1, 0, 0, 30)
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Sec })
                Create("Frame", {
                    Parent = Sec,
                    BackgroundColor3 = Library.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 6),
                    Size = UDim2.new(0, 2, 0, 18)
                })
                Create("TextLabel", {
                    Parent = Sec,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = "GothamBold",
                    Text = secName:upper(),
                    TextColor3 = Color3.fromRGB(190, 190, 190),
                    TextSize = 11,
                    TextXAlignment = "Left"
                })
                local Content = Create("Frame", {
                    Parent = SPage,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0)
                })
                local L = Create("UIListLayout", { Parent = Content, Padding = UDim.new(0, 6) })
                L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    Content.Size = UDim2.new(1, 0, 0, L.AbsoluteContentSize.Y)
                    SPage.CanvasSize = UDim2.new(0, 0, 0, SPage.UIListLayout.AbsoluteContentSize.Y + 40)
                end)
                local S = {}

                function S:CreateLabel(n)
                    local Lbl = Create("TextLabel", {
                        Parent = Content,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        TextSize = 14,
                        TextXAlignment = "Center"
                    })
                    return Lbl
                end

                function S:CreateToggle(n, def, cb)
                    local toggleValue = def or false
                    local toggleObject = nil
                    
                    local F = Create("Frame", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 42)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = F })
                    Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -64, 1, 0),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 14,
                        TextXAlignment = "Left"
                    })
                    local O = Create("Frame", {
                        Parent = F,
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        Position = UDim2.new(1, -12, 0.5, 0),
                        Size = UDim2.new(0, 36, 0, 18)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = O })
                    local I = Create("Frame", {
                        Parent = O,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(0, 2, 0.5, -7),
                        Size = UDim2.new(0, 14, 0, 14)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = I })
                    
                    local function u()
                        Tween(O, 0.2, { BackgroundColor3 = toggleValue and Library.Accent or Color3.fromRGB(35, 35, 35) })
                        Tween(I, 0.2, { Position = toggleValue and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) })
                        if cb then
                            cb(toggleValue)
                        end
                    end
                    
                    F.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then
                            toggleValue = not toggleValue
                            u()
                        end
                    end)
                    u()
                    
                    toggleObject = {
                        Set = function(_, v)
                            toggleValue = v
                            u()
                        end,
                        Get = function()
                            return toggleValue
                        end
                    }
                    return toggleObject
                end

                function S:CreateButton(n, cb)
                    local B = Create("TextButton", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 42),
                        Text = "",
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = B })
                    Create("TextLabel", {
                        Parent = B,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 14
                    })
                    B.MouseEnter:Connect(function() Tween(B, 0.15, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }) end)
                    B.MouseLeave:Connect(function() Tween(B, 0.15, { BackgroundColor3 = Color3.fromRGB(13, 13, 13) }) end)
                    B.MouseButton1Click:Connect(function() if cb then cb() end end)
                end

                function S:CreateSlider(n, min, max, def, cb)
                    min = min or 0
                    max = max or 100
                    local currentValue = def or min
                    local isDragging = false
                    
                    cb = cb or function() end
                    
                    local F = Create("Frame", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 50)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = F })
                    Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -70, 0, 24),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 14,
                        TextXAlignment = "Left"
                    })
                    local Val = Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -60, 0, 0),
                        Size = UDim2.new(0, 48, 0, 24),
                        Font = "GothamBold",
                        Text = tostring(currentValue),
                        TextColor3 = Library.Accent,
                        TextSize = 13,
                        TextXAlignment = "Right"
                    })
                    local Bar = Create("Frame", {
                        Parent = F,
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        Position = UDim2.new(0, 12, 0, 32),
                        Size = UDim2.new(1, -24, 0, 6)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar })
                    local Fill = Create("Frame", {
                        Parent = Bar,
                        BackgroundColor3 = Library.Accent,
                        Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                    local Knob = Create("Frame", {
                        Parent = Fill,
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
                    
                    local function updateValue(input)
                        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                        local val = min + (max - min) * pos
                        val = math.floor(val * 100) / 100
                        currentValue = val
                        Fill.Size = UDim2.new(pos, 0, 1, 0)
                        Val.Text = tostring(currentValue)
                        cb(currentValue)
                    end
                    
                    Bar.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            isDragging = true
                            Library._blockDrag = true
                            updateValue(i)
                        end
                    end)
                    
                    UIS.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            isDragging = false
                            Library._blockDrag = false
                        end
                    end)
                    
                    UIS.InputChanged:Connect(function(i)
                        if isDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                            updateValue(i)
                        end
                    end)
                    
                    return {
                        SetValue = function(_, v)
                            v = math.clamp(v, min, max)
                            local pos = (v - min) / (max - min)
                            currentValue = v
                            Fill.Size = UDim2.new(pos, 0, 1, 0)
                            Val.Text = tostring(v)
                            cb(v)
                        end,
                        GetValue = function()
                            return currentValue
                        end
                    }
                end

                function S:CreateTextbox(n, def, cb)
                    local currentValue = def or ""
                    
                    local F = Create("Frame", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 42)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = F })
                    
                    local Lbl = Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(0, 100, 1, 0),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 14,
                        TextXAlignment = "Left"
                    })
                    
                    local Box = Create("TextBox", {
                        Parent = F,
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        Position = UDim2.new(0, 120, 0, 6),
                        Size = UDim2.new(1, -130, 0, 30),
                        Font = "Gotham",
                        Text = currentValue,
                        PlaceholderText = "Enter player name...",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                        TextSize = 13,
                        ClearTextOnFocus = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })
                    
                    Box.FocusLost:Connect(function(enterPressed)
                        if enterPressed and Box.Text ~= "" then
                            currentValue = Box.Text
                            if cb then
                                cb(currentValue)
                            end
                        end
                    end)
                    
                    return {
                        SetText = function(_, text)
                            currentValue = text
                            Box.Text = text
                        end,
                        GetText = function()
                            return currentValue
                        end
                    }
                end

                function S:CreateDropdown(n, items, def, cb)
                    items = items or {}
                    cb = cb or function() end
                    local selected = def or items[1] or "None"

                    local F = Create("Frame", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 42),
                        ClipsDescendants = true
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = F })

                    local MainBtn = Create("TextButton", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 42),
                        Text = "",
                        AutoButtonColor = false
                    })
                    local Lbl = Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -44, 0, 42),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 14,
                        TextXAlignment = "Left"
                    })
                    local SelLbl = Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -64, 0, 42),
                        Font = "Gotham",
                        Text = tostring(selected),
                        TextColor3 = Library.Accent,
                        TextSize = 13,
                        TextXAlignment = "Right"
                    })
                    local Arrow = Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -12, 0, 21),
                        Size = UDim2.new(0, 20, 0, 20),
                        Font = "GothamBold",
                        Text = "v",
                        TextColor3 = Color3.fromRGB(140, 140, 140),
                        TextSize = 12
                    })

                    local ItemList = Create("Frame", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 6, 0, 42),
                        Size = UDim2.new(1, -12, 0, 0)
                    })
                    local LList = Create("UIListLayout", { Parent = ItemList, Padding = UDim.new(0, 3) })

                    local opened = false

                    local function uDropdown()
                        local h = opened and (42 + LList.AbsoluteContentSize.Y + 8) or 42
                        Tween(F, 0.25, { Size = UDim2.new(1, 0, 0, h) })
                        Tween(Arrow, 0.25, { Rotation = opened and 180 or 0 })
                    end

                    local function refresh(list)
                        items = list
                        for _, c in next, ItemList:GetChildren() do
                            if c:IsA("TextButton") then
                                c:Destroy()
                            end
                        end
                        for _, item in next, list do
                            local Btn = Create("TextButton", {
                                Parent = ItemList,
                                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                                Size = UDim2.new(1, 0, 0, 30),
                                Font = "Gotham",
                                Text = tostring(item),
                                TextColor3 = (selected == item) and Library.Accent or Color3.fromRGB(200, 200, 200),
                                TextSize = 13,
                                AutoButtonColor = false
                            })
                            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })

                            Btn.MouseEnter:Connect(function()
                                Tween(Btn, 0.1, { BackgroundColor3 = Color3.fromRGB(26, 26, 26) })
                            end)
                            Btn.MouseLeave:Connect(function()
                                Tween(Btn, 0.1, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) })
                            end)

                            Btn.MouseButton1Click:Connect(function()
                                selected = item
                                SelLbl.Text = tostring(item)
                                opened = false
                                uDropdown()
                                cb(item)
                                refresh(items)
                            end)
                        end
                        if opened then
                            uDropdown()
                        end
                    end

                    refresh(items)
                    MainBtn.MouseButton1Click:Connect(function()
                        opened = not opened
                        uDropdown()
                    end)

                    return {
                        Refresh = refresh,
                        Set = function(_, v)
                            selected = v
                            SelLbl.Text = tostring(v)
                            cb(v)
                            refresh(items)
                        end,
                        Get = function()
                            return selected
                        end
                    }
                end

                function S:CreateKeybind(n, defKey, cb)
                    local currentKey = defKey or Enum.KeyCode.None
                    cb = cb or function() end
                    
                    local F = Create("Frame", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 42)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = F })
                    Create("TextLabel", {
                        Parent = F,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -100, 1, 0),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 14,
                        TextXAlignment = "Left"
                    })
                    local KeyBtn = Create("TextButton", {
                        Parent = F,
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(1, -10, 0.5, 0),
                        Size = UDim2.new(0, 70, 0, 26),
                        Font = "GothamBold",
                        Text = currentKey.Name,
                        TextColor3 = Library.Accent,
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeyBtn })
                    
                    local waiting = false
                    
                    KeyBtn.MouseButton1Click:Connect(function()
                        waiting = true
                        KeyBtn.Text = "..."
                    end)
                    
                    UIS.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if waiting then
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                waiting = false
                                currentKey = input.KeyCode
                                KeyBtn.Text = currentKey.Name
                                cb(currentKey)
                            end
                        end
                    end)
                    
                    return {
                        SetKey = function(_, key)
                            currentKey = key
                            KeyBtn.Text = key.Name
                            cb(key)
                        end,
                        GetKey = function()
                            return currentKey
                        end
                    }
                end

                function S:CreateColorPicker(n, defaultColor, cb)
                    local hue = 0
                    local isRainbow = false
                    local rainbowConnection = nil
                    local currentColor = defaultColor

                    local container = Create("Frame", {
                        Parent = Content,
                        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
                        Size = UDim2.new(1, 0, 0, 65),
                        ClipsDescendants = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = container })

                    local label = Create("TextLabel", {
                        Parent = container,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 5),
                        Size = UDim2.new(1, -20, 0, 20),
                        Font = "Gotham",
                        Text = n,
                        TextColor3 = Color3.fromRGB(225, 225, 225),
                        TextSize = 12,
                        TextXAlignment = "Left"
                    })

                    local colorDisplay = Create("Frame", {
                        Parent = container,
                        BackgroundColor3 = defaultColor,
                        Position = UDim2.new(0, 10, 0, 28),
                        Size = UDim2.new(0, 80, 0, 25)
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = colorDisplay })
                    Create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Parent = colorDisplay })

                    local rgbButton = Create("TextButton", {
                        Parent = container,
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        Position = UDim2.new(0, 100, 0, 28),
                        Size = UDim2.new(0, 60, 0, 25),
                        Font = "GothamBold",
                        Text = "RGB",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = rgbButton })

                    local redBtn = Create("TextButton", {
                        Parent = container,
                        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
                        Position = UDim2.new(0, 170, 0, 28),
                        Size = UDim2.new(0, 25, 0, 25),
                        Text = "",
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = redBtn })

                    local greenBtn = Create("TextButton", {
                        Parent = container,
                        BackgroundColor3 = Color3.fromRGB(50, 255, 50),
                        Position = UDim2.new(0, 200, 0, 28),
                        Size = UDim2.new(0, 25, 0, 25),
                        Text = "",
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = greenBtn })

                    local blueBtn = Create("TextButton", {
                        Parent = container,
                        BackgroundColor3 = Color3.fromRGB(50, 50, 255),
                        Position = UDim2.new(0, 230, 0, 28),
                        Size = UDim2.new(0, 25, 0, 25),
                        Text = "",
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = blueBtn })

                    local whiteBtn = Create("TextButton", {
                        Parent = container,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = UDim2.new(0, 260, 0, 28),
                        Size = UDim2.new(0, 25, 0, 25),
                        Text = "",
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = whiteBtn })

                    local function updateColor(color)
                        currentColor = color
                        colorDisplay.BackgroundColor3 = color
                        if cb then
                            cb(color)
                        end
                    end

                    local function startRainbow()
                        isRainbow = true
                        rgbButton.TextColor3 = Color3.fromRGB(160, 60, 255)
                        if rainbowConnection then
                            rainbowConnection:Disconnect()
                        end
                        rainbowConnection = RunService.RenderStepped:Connect(function()
                            hue = (hue + 0.01) % 1
                            updateColor(Color3.fromHSV(hue, 1, 1))
                        end)
                    end

                    local function stopRainbow()
                        isRainbow = false
                        rgbButton.TextColor3 = Color3.new(1, 1, 1)
                        if rainbowConnection then
                            rainbowConnection:Disconnect()
                            rainbowConnection = nil
                        end
                    end

                    rgbButton.MouseButton1Click:Connect(function()
                        if isRainbow then
                            stopRainbow()
                        else
                            startRainbow()
                        end
                    end)

                    redBtn.MouseButton1Click:Connect(function()
                        stopRainbow()
                        updateColor(Color3.fromRGB(255, 50, 50))
                    end)

                    greenBtn.MouseButton1Click:Connect(function()
                        stopRainbow()
                        updateColor(Color3.fromRGB(50, 255, 50))
                    end)

                    blueBtn.MouseButton1Click:Connect(function()
                        stopRainbow()
                        updateColor(Color3.fromRGB(50, 50, 255))
                    end)

                    whiteBtn.MouseButton1Click:Connect(function()
                        stopRainbow()
                        updateColor(Color3.fromRGB(255, 255, 255))
                    end)

                    return {
                        SetColor = function(_, color)
                            stopRainbow()
                            updateColor(color)
                        end,
                        SetRainbow = function(_, enabled)
                            if enabled then
                                startRainbow()
                            else
                                stopRainbow()
                            end
                        end,
                        GetColor = function()
                            return currentColor
                        end,
                        IsRainbow = function()
                            return isRainbow
                        end
                    }
                end

                return S
            end
            return SubTab
        end
        if not Window.Current then
            Tab:Select()
        end
        return Tab
    end
    return Window
end

-- ==================== END UI LIBRARY ====================

-- ==================== UNIVERSAL ADMIN PANEL ====================

-- Variables
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayersService.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local StatsService = game:GetService("Stats")

-- Admin Settings
local Admin = {
    Speed = 16,
    JumpPower = 50,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    Invisible = false,
    GodMode = false,
    TargetPlayer = nil,
    TargetPlayerName = "",
    SpinSpeed = 360,
}

-- Feature states
local flying = false
local noclip = false
local infiniteJump = false
local invisible = false
local godMode = false
local spinning = false
local flinging = false

-- Connections and objects
local flyBodyVelocity = nil
local flyConnection = nil
local noclipConnection = nil
local jumpConnection = nil
local godModeConnection = nil
local spinConnection = nil
local flingConnection = nil
local originalTransparency = {}

-- UI References
local targetTextbox = nil
local playerListPopup = nil
local currentSuggestions = {}
local suggestionIndex = 0

-- Command list for auto-complete
local commandList = {
    "speed", "jumppower", "jp", "fly", "unfly", "noclip", "infjump", "infj",
    "invis", "invisible", "godmode", "god", "target", "spin", "fling", "kill",
    "tp", "headsit", "btools", "dex", "explorer", "serverinfo", "info",
    "serverhop", "shop", "players", "playerlist", "cmds", "help", "creator"
}

-- Console output
local function ConsolePrint(msg)
    print(msg)
end

-- ==================== CLIPBOARD FUNCTIONS ====================

local function CopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    elseif toclipboard then
        toclipboard(text)
        return true
    elseif syn and syn.write_clipboard then
        syn.write_clipboard(text)
        return true
    end
    return false
end

-- ==================== PLAYER LIST POPUP WITH COPY FEATURE ====================

local function CreatePlayerListPopup()
    if playerListPopup then
        pcall(function() playerListPopup:Destroy() end)
        playerListPopup = nil
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerListGui"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 450)
    frame.Position = UDim2.new(1, -360, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Parent = frame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    titleBar.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Players Online"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        playerListPopup = nil
    end)
    
    -- Player count label
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -20, 0, 25)
    countLabel.Position = UDim2.new(0, 10, 0, 40)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Players: 0"
    countLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    countLabel.TextSize = 12
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Parent = frame
    
    -- Player list frame
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -10, 1, -80)
    listFrame.Position = UDim2.new(0, 5, 0, 70)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(160, 60, 255)
    listFrame.Parent = frame
    
    local playerList = Instance.new("UIListLayout")
    playerList.Padding = UDim.new(0, 5)
    playerList.Parent = listFrame
    
    local function UpdatePlayerList()
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local players = {}
        for _, player in pairs(PlayersService:GetPlayers()) do
            table.insert(players, player)
        end
        
        table.sort(players, function(a, b) return a.Name < b.Name end)
        
        countLabel.Text = "Players: " .. #players
        
        for _, player in pairs(players) do
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, 0, 0, 50)
            playerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            playerFrame.Parent = listFrame
            
            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 4)
            frameCorner.Parent = playerFrame
            
            -- Highlight if this is the current target
            if Admin.TargetPlayer and Admin.TargetPlayer.Name == player.Name then
                playerFrame.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
            end
            
            -- Username label
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.5, -10, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = playerFrame
            
            -- User ID label
            local idLabel = Instance.new("TextLabel")
            idLabel.Size = UDim2.new(0.3, -10, 1, 0)
            idLabel.Position = UDim2.new(0.5, 0, 0, 0)
            idLabel.BackgroundTransparency = 1
            idLabel.Text = "ID: " .. player.UserId
            idLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
            idLabel.TextSize = 11
            idLabel.Font = Enum.Font.Gotham
            idLabel.TextXAlignment = Enum.TextXAlignment.Left
            idLabel.Parent = playerFrame
            
            -- Copy Username button
            local copyNameBtn = Instance.new("TextButton")
            copyNameBtn.Size = UDim2.new(0, 30, 0, 25)
            copyNameBtn.Position = UDim2.new(0.8, 0, 0.5, -12.5)
            copyNameBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            copyNameBtn.Text = "📋"
            copyNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyNameBtn.TextSize = 12
            copyNameBtn.Font = Enum.Font.GothamBold
            copyNameBtn.Parent = playerFrame
            
            local copyNameCorner = Instance.new("UICorner")
            copyNameCorner.CornerRadius = UDim.new(0, 4)
            copyNameCorner.Parent = copyNameBtn
            
            copyNameBtn.MouseButton1Click:Connect(function()
                if CopyToClipboard(player.Name) then
                    copyNameBtn.Text = "✓"
                    task.wait(0.5)
                    copyNameBtn.Text = "📋"
                    ConsolePrint("Copied username: " .. player.Name)
                end
            end)
            
            -- Copy User ID button
            local copyIdBtn = Instance.new("TextButton")
            copyIdBtn.Size = UDim2.new(0, 30, 0, 25)
            copyIdBtn.Position = UDim2.new(0.88, 0, 0.5, -12.5)
            copyIdBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            copyIdBtn.Text = "🆔"
            copyIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyIdBtn.TextSize = 12
            copyIdBtn.Font = Enum.Font.GothamBold
            copyIdBtn.Parent = playerFrame
            
            local copyIdCorner = Instance.new("UICorner")
            copyIdCorner.CornerRadius = UDim.new(0, 4)
            copyIdCorner.Parent = copyIdBtn
            
            copyIdBtn.MouseButton1Click:Connect(function()
                if CopyToClipboard(tostring(player.UserId)) then
                    copyIdBtn.Text = "✓"
                    task.wait(0.5)
                    copyIdBtn.Text = "🆔"
                    ConsolePrint("Copied User ID: " .. player.UserId)
                end
            end)
            
            -- Set as target button
            local targetBtn = Instance.new("TextButton")
            targetBtn.Size = UDim2.new(0, 40, 0, 25)
            targetBtn.Position = UDim2.new(0.96, 0, 0.5, -12.5)
            targetBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
            targetBtn.Text = "🎯"
            targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            targetBtn.TextSize = 12
            targetBtn.Font = Enum.Font.GothamBold
            targetBtn.Parent = playerFrame
            
            local targetCorner = Instance.new("UICorner")
            targetCorner.CornerRadius = UDim.new(0, 4)
            targetCorner.Parent = targetBtn
            
            targetBtn.MouseButton1Click:Connect(function()
                if player ~= LocalPlayer then
                    Admin.TargetPlayer = player
                    Admin.TargetPlayerName = player.Name
                    if targetTextbox then
                        targetTextbox:SetText(player.Name)
                    end
                    ConsolePrint("Target set to: " .. player.Name)
                    UpdatePlayerList()
                end
            end)
        end
        
        task.wait()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, playerList.AbsoluteContentSize.Y + 10)
    end
    
    UpdatePlayerList()
    
    -- Auto-refresh every 2 seconds
    local refreshConnection
    refreshConnection = game:GetService("RunService").Stepped:Connect(function()
        if screenGui and screenGui.Parent then
            UpdatePlayerList()
        else
            if refreshConnection then refreshConnection:Disconnect() end
        end
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    playerListPopup = screenGui
    return screenGui
end

-- ==================== COMMAND PROMPT WITH AUTO-COMPLETE ====================

local function ShowCommandPrompt(defaultCommand)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CommandPromptGui"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 140)
    frame.Position = UDim2.new(0.5, -225, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Parent = frame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    titleBar.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Execute Command"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 35)
    inputBox.Position = UDim2.new(0, 10, 0, 45)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    inputBox.Text = defaultCommand or ""
    inputBox.PlaceholderText = "Type command... (Tab to autocomplete)"
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.TextSize = 13
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputBox
    
    -- Suggestions frame
    local suggestionsFrame = Instance.new("Frame")
    suggestionsFrame.Size = UDim2.new(1, -20, 0, 0)
    suggestionsFrame.Position = UDim2.new(0, 10, 0, 85)
    suggestionsFrame.BackgroundTransparency = 1
    suggestionsFrame.ClipsDescendants = true
    suggestionsFrame.Visible = false
    suggestionsFrame.Parent = frame
    
    local suggestionsList = Instance.new("UIListLayout")
    suggestionsList.Padding = UDim.new(0, 2)
    suggestionsList.Parent = suggestionsFrame
    
    -- Execute button
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0, 80, 0, 30)
    execBtn.Position = UDim2.new(1, -90, 1, -40)
    execBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
    execBtn.Text = "Execute"
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.TextSize = 13
    execBtn.Font = Enum.Font.GothamBold
    execBtn.Parent = frame
    
    local execCorner = Instance.new("UICorner")
    execCorner.CornerRadius = UDim.new(0, 4)
    execCorner.Parent = execBtn
    
    -- Get player names for auto-complete
    local function GetPlayerNames()
        local names = {}
        for _, player in pairs(PlayersService:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(names, player.Name)
            end
        end
        return names
    end
    
    -- Update suggestions based on input
    local function UpdateSuggestions()
        local text = inputBox.Text
        local parts = {}
        for word in string.gmatch(text, "[^%s]+") do
            table.insert(parts, word)
        end
        
        local lastPart = parts[#parts] or ""
        local isCommandPart = #parts <= 1
        
        local suggestions = {}
        
        if isCommandPart then
            -- Suggest commands
            for _, cmd in pairs(commandList) do
                if string.sub(string.lower(cmd), 1, string.len(lastPart)) == string.lower(lastPart) and lastPart ~= "" then
                    table.insert(suggestions, cmd)
                elseif lastPart == "" and #suggestions < 10 then
                    table.insert(suggestions, cmd)
                end
            end
        else
            -- Suggest player names for commands that need a target
            local targetCommands = {"target", "kill", "tp", "headsit", "spin", "fling"}
            local firstCmd = string.lower(parts[1] or "")
            
            for _, tc in pairs(targetCommands) do
                if tc == firstCmd or (firstCmd == "target" and tc == "target") then
                    for _, player in pairs(PlayersService:GetPlayers()) do
                        if player ~= LocalPlayer then
                            if string.sub(string.lower(player.Name), 1, string.len(lastPart)) == string.lower(lastPart) then
                                table.insert(suggestions, player.Name)
                            end
                        end
                    end
                    break
                end
            end
        end
        
        -- Clear old suggestions
        for _, child in pairs(suggestionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if #suggestions > 0 then
            suggestionsFrame.Visible = true
            currentSuggestions = suggestions
            suggestionIndex = 0
            
            for i, sug in pairs(suggestions) do
                local sugBtn = Instance.new("TextButton")
                sugBtn.Size = UDim2.new(1, 0, 0, 25)
                sugBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                sugBtn.Text = sug
                sugBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                sugBtn.TextSize = 12
                sugBtn.Font = Enum.Font.Gotham
                sugBtn.TextXAlignment = Enum.TextXAlignment.Left
                sugBtn.Parent = suggestionsFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = sugBtn
                
                sugBtn.MouseButton1Click:Connect(function()
                    if isCommandPart then
                        inputBox.Text = sug .. " "
                    else
                        local newText = ""
                        for j, part in ipairs(parts) do
                            if j < #parts then
                                newText = newText .. part .. " "
                            else
                                newText = newText .. sug
                            end
                        end
                        inputBox.Text = newText
                    end
                    inputBox:CaptureFocus()
                    UpdateSuggestions()
                end)
                
                sugBtn.MouseEnter:Connect(function()
                    sugBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
                    sugBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                end)
                
                sugBtn.MouseLeave:Connect(function()
                    sugBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    sugBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end)
            end
            
            local totalHeight = #suggestions * 27
            suggestionsFrame.Size = UDim2.new(1, -20, 0, math.min(totalHeight, 150))
            frame.Size = UDim2.new(0, 450, 0, 140 + math.min(totalHeight, 150))
        else
            suggestionsFrame.Visible = false
            frame.Size = UDim2.new(0, 450, 0, 140)
        end
    end
    
    -- Handle Tab key for autocomplete
    inputBox:GetPropertyChangedSignal("Text"):Connect(UpdateSuggestions)
    
    inputBox.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Tab and #currentSuggestions > 0 then
            suggestionIndex = (suggestionIndex % #currentSuggestions) + 1
            local selected = currentSuggestions[suggestionIndex]
            
            local parts = {}
            for word in string.gmatch(inputBox.Text, "[^%s]+") do
                table.insert(parts, word)
            end
            
            if #parts <= 1 then
                inputBox.Text = selected .. " "
            else
                local newText = ""
                for i, part in ipairs(parts) do
                    if i < #parts then
                        newText = newText .. part .. " "
                    else
                        newText = newText .. selected
                    end
                end
                inputBox.Text = newText
            end
            inputBox:CaptureFocus()
            UpdateSuggestions()
        elseif input.KeyCode == Enum.KeyCode.Enter then
            local cmd = inputBox.Text
            screenGui:Destroy()
            ProcessCommand(cmd)
        end
    end)
    
    execBtn.MouseButton1Click:Connect(function()
        local cmd = inputBox.Text
        screenGui:Destroy()
        ProcessCommand(cmd)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local cmd = inputBox.Text
            screenGui:Destroy()
            ProcessCommand(cmd)
        end
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    task.wait()
    inputBox:CaptureFocus()
    UpdateSuggestions()
    
    return screenGui
end

-- ==================== COMMAND LIST POPUP ====================

local function ShowCommandList()
    local commandsList = {
        {cmd = "speed [value]", desc = "Set walk speed"},
        {cmd = "jumppower [value]", desc = "Set jump power"},
        {cmd = "fly", desc = "Toggle fly mode"},
        {cmd = "unfly", desc = "Turn off fly mode"},
        {cmd = "noclip", desc = "Toggle noclip"},
        {cmd = "infjump", desc = "Toggle infinite jump"},
        {cmd = "invis", desc = "Toggle invisibility"},
        {cmd = "godmode", desc = "Toggle god mode"},
        {cmd = "target [name]", desc = "Select target player"},
        {cmd = "spin [speed]", desc = "Spin target (optional speed)"},
        {cmd = "fling", desc = "Fling target"},
        {cmd = "kill [name]", desc = "Kill target player"},
        {cmd = "tp [name]", desc = "Teleport to player"},
        {cmd = "headsit [name]", desc = "Sit on player's head"},
        {cmd = "btools", desc = "Give building tools"},
        {cmd = "dex", desc = "Open DEX Explorer"},
        {cmd = "serverinfo", desc = "Show server info"},
        {cmd = "serverhop", desc = "Hop to new server"},
        {cmd = "players", desc = "Show player list"},
        {cmd = "cmds", desc = "Show this menu"},
        {cmd = "creator", desc = "Show creator info"},
    }
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CommandListGui"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 550, 0, 500)
    frame.Position = UDim2.new(0.5, -275, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Parent = frame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    titleBar.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Command List"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Search bar
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 0, 35)
    searchBox.Position = UDim2.new(0, 10, 0, 45)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search commands..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextSize = 13
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = frame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 4)
    searchCorner.Parent = searchBox
    
    -- Command list
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -20, 1, -100)
    listFrame.Position = UDim2.new(0, 10, 0, 90)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(160, 60, 255)
    listFrame.Parent = frame
    
    local cmdList = Instance.new("UIListLayout")
    cmdList.Padding = UDim.new(0, 5)
    cmdList.Parent = listFrame
    
    local function populateList(searchText)
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        searchText = string.lower(searchText or "")
        
        for _, cmd in pairs(commandsList) do
            if searchText == "" or string.find(string.lower(cmd.cmd), searchText) or string.find(string.lower(cmd.desc), searchText) then
                local cmdFrame = Instance.new("Frame")
                cmdFrame.Size = UDim2.new(1, 0, 0, 40)
                cmdFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                cmdFrame.Parent = listFrame
                
                local cmdCorner = Instance.new("UICorner")
                cmdCorner.CornerRadius = UDim.new(0, 4)
                cmdCorner.Parent = cmdFrame
                
                local cmdLabel = Instance.new("TextLabel")
                cmdLabel.Size = UDim2.new(0.4, -10, 1, 0)
                cmdLabel.Position = UDim2.new(0, 10, 0, 0)
                cmdLabel.BackgroundTransparency = 1
                cmdLabel.Text = cmd.cmd
                cmdLabel.TextColor3 = Color3.fromRGB(160, 60, 255)
                cmdLabel.TextSize = 13
                cmdLabel.Font = Enum.Font.GothamBold
                cmdLabel.TextXAlignment = Enum.TextXAlignment.Left
                cmdLabel.Parent = cmdFrame
                
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(0.45, -10, 1, 0)
                descLabel.Position = UDim2.new(0.4, 0, 0, 0)
                descLabel.BackgroundTransparency = 1
                descLabel.Text = cmd.desc
                descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                descLabel.TextSize = 12
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.Parent = cmdFrame
                
                local execBtn = Instance.new("TextButton")
                execBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
                execBtn.Position = UDim2.new(0.88, -5, 0.15, 0)
                execBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                execBtn.Text = "Run"
                execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                execBtn.TextSize = 11
                execBtn.Font = Enum.Font.GothamBold
                execBtn.Parent = cmdFrame
                
                local execCorner = Instance.new("UICorner")
                execCorner.CornerRadius = UDim.new(0, 3)
                execCorner.Parent = execBtn
                
                execBtn.MouseButton1Click:Connect(function()
                    screenGui:Destroy()
                    ShowCommandPrompt(cmd.cmd)
                end)
            end
        end
        
        task.wait()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, cmdList.AbsoluteContentSize.Y + 10)
    end
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateList(searchBox.Text)
    end)
    
    populateList("")
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return screenGui
end

-- ==================== COMMAND SYSTEM ====================

-- Get all players
local function GetAllPlayers()
    local players = {}
    for _, player in pairs(PlayersService:GetPlayers()) do
        table.insert(players, player)
    end
    return players
end

local function GetPlayer(input)
    if type(input) == "string" then
        for _, player in pairs(PlayersService:GetPlayers()) do
            if string.lower(player.Name) == string.lower(input) or string.lower(player.DisplayName) == string.lower(input) then
                return player
            end
        end
        for _, player in pairs(PlayersService:GetPlayers()) do
            if string.find(string.lower(player.Name), string.lower(input)) or string.find(string.lower(player.DisplayName), string.lower(input)) then
                return player
            end
        end
    end
    return nil
end

-- Apply speed and jump power
local function ApplyMovementSettings()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = Admin.Speed
                humanoid.JumpPower = Admin.JumpPower
            end)
        end
    end
end

-- Kill Player
local function KillPlayer(targetPlayer)
    local target = targetPlayer or Admin.TargetPlayer
    if not target or target == LocalPlayer then
        ConsolePrint("No target selected to kill!")
        return
    end
    
    local char = target.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
            ConsolePrint("Killed " .. target.Name .. "!")
        else
            ConsolePrint("Could not kill " .. target.Name .. "!")
        end
    else
        ConsolePrint(target.Name .. " has no character!")
    end
end

-- Teleport to Player
local function TeleportToPlayer(targetPlayer)
    local target = targetPlayer
    if not target or target == LocalPlayer then
        ConsolePrint("No target selected to teleport to!")
        return
    end
    
    local targetChar = target.Character
    if not targetChar then
        ConsolePrint("Target has no character!")
        return
    end
    
    local localChar = LocalPlayer.Character
    if not localChar then
        ConsolePrint("You have no character!")
        return
    end
    
    local targetPos = targetChar:GetPivot().Position
    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
    
    if localHRP then
        localHRP.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        ConsolePrint("Teleported to " .. target.Name .. "!")
    else
        ConsolePrint("Could not teleport!")
    end
end

-- Head Sit
local function HeadSit(targetPlayer)
    local target = targetPlayer or Admin.TargetPlayer
    if not target or target == LocalPlayer then
        ConsolePrint("No target selected for headsit!")
        return
    end
    
    local targetChar = target.Character
    if not targetChar then
        ConsolePrint("Target has no character!")
        return
    end
    
    local localChar = LocalPlayer.Character
    if not localChar then
        ConsolePrint("You have no character!")
        return
    end
    
    local head = targetChar:FindFirstChild("Head")
    if not head then
        ConsolePrint("Target has no head!")
        return
    end
    
    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
    if localHRP then
        localHRP.CFrame = CFrame.new(head.Position + Vector3.new(0, 2, 0))
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = localHRP
        weld.Part1 = head
        weld.Parent = localHRP
        
        task.delay(0.5, function()
            if weld then weld:Destroy() end
        end)
    end
    
    ConsolePrint("Sitting on " .. target.Name .. "'s head!")
end

-- God Mode
local function StartGodMode()
    if godMode then return end
    godMode = true
    
    godModeConnection = RunService.RenderStepped:Connect(function()
        if godMode and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.BreakJointsOnDeath = false
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
        end
    end)
    
    ConsolePrint("God Mode: ON")
end

local function StopGodMode()
    if not godMode then return end
    godMode = false
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.BreakJointsOnDeath = true
            humanoid.MaxHealth = 100
            if humanoid.Health > 100 then
                humanoid.Health = 100
            end
        end
    end
    
    ConsolePrint("God Mode: OFF")
end

-- Fly System
local function StartFly()
    if flying then return end
    flying = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyBodyVelocity.Parent = hrp
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if flying and LocalPlayer.Character and hrp and hrp.Parent then
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Vector3.new(0, 0, -1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection + Vector3.new(0, 0, 1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection + Vector3.new(-1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Vector3.new(1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection + Vector3.new(0, -1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            local speed = 75
            flyBodyVelocity.Velocity = (Camera.CFrame.RightVector * moveDirection.X + 
                                         Camera.CFrame.UpVector * moveDirection.Y + 
                                         Camera.CFrame.LookVector * moveDirection.Z) * speed
        end
    end)
    
    ConsolePrint("Fly: ON")
end

local function StopFly()
    if not flying then return end
    flying = false
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    ConsolePrint("Fly: OFF")
end

-- Noclip System
local function UpdateNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclip
        end
    end
end

local function StartNoclip()
    if noclip then return end
    noclip = true
    
    UpdateNoclip()
    
    noclipConnection = RunService.RenderStepped:Connect(function()
        if noclip then
            UpdateNoclip()
        end
    end)
    
    ConsolePrint("Noclip: ON")
end

local function StopNoclip()
    if not noclip then return end
    noclip = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    UpdateNoclip()
    
    ConsolePrint("Noclip: OFF")
end

-- Infinite Jump
local function StartInfiniteJump()
    if infiniteJump then return end
    infiniteJump = true
    
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJump and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    ConsolePrint("Infinite Jump: ON")
end

local function StopInfiniteJump()
    infiniteJump = false
    
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
    
    ConsolePrint("Infinite Jump: OFF")
end

-- Invisible
local function StartInvisible()
    if invisible then return end
    invisible = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalTransparency[part] = part.Transparency
            part.Transparency = 1
        end
    end
    
    ConsolePrint("Invisible: ON")
end

local function StopInvisible()
    if not invisible then return end
    invisible = false
    
    local char = LocalPlayer.Character
    if char then
        for part, original in pairs(originalTransparency) do
            if part.Parent == char then
                part.Transparency = original
            end
        end
    end
    originalTransparency = {}
    
    ConsolePrint("Invisible: OFF")
end

-- Spin System
local function StartSpin(speed)
    if spinning then return end
    
    local target = Admin.TargetPlayer
    if not target or target == LocalPlayer then
        ConsolePrint("No target selected for spin!")
        return
    end
    
    local char = target.Character
    if not char then
        ConsolePrint("Target has no character!")
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        ConsolePrint("Target has no HumanoidRootPart!")
        return
    end
    
    spinning = true
    local spinSpeedValue = speed or Admin.SpinSpeed
    
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        if spinning and target.Character and hrp and hrp.Parent then
            local newAngle = spinSpeedValue * dt
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(newAngle), 0)
        end
    end)
    
    ConsolePrint("Spinning " .. target.Name .. " at speed " .. tostring(spinSpeedValue) .. "!")
end

local function StopSpin()
    if not spinning then return end
    spinning = false
    
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    
    ConsolePrint("Spin stopped!")
end

-- Fling System
local function StartFling()
    if flinging then return end
    
    local target = Admin.TargetPlayer
    if not target or target == LocalPlayer then
        ConsolePrint("No target selected for fling!")
        return
    end
    
    local char = target.Character
    if not char then
        ConsolePrint("Target has no character!")
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        ConsolePrint("Target has no HumanoidRootPart!")
        return
    end
    
    flinging = true
    
    flingConnection = RunService.RenderStepped:Connect(function()
        if flinging and target.Character and hrp and hrp.Parent then
            local randomDir = Vector3.new(math.random(-150, 150), math.random(50, 200), math.random(-150, 150))
            hrp.AssemblyLinearVelocity = randomDir
        end
    end)
    
    ConsolePrint("Flinging " .. target.Name .. "!")
end

local function StopFling()
    if not flinging then return end
    flinging = false
    
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    
    ConsolePrint("Fling stopped!")
end

-- Building Tools
local function GiveBuildingTools()
    local toolIds = {
        "rbxassetid://169209103",
        "rbxassetid://169191869",
        "rbxassetid://169211324",
        "rbxassetid://169217863",
        "rbxassetid://169223733",
        "rbxassetid://169224140",
        "rbxassetid://169224309",
        "rbxassetid://169224443",
        "rbxassetid://169224599",
        "rbxassetid://169224715",
    }
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    for _, toolId in pairs(toolIds) do
        local tool = Instance.new("Tool")
        tool.Name = "Building Tool"
        tool.RequiresHandle = false
        tool.ToolTip = "Building Tool"
        tool.Parent = backpack
    end
    
    ConsolePrint("Building tools added to backpack!")
end

-- DEX Explorer
local function OpenDEX()
    loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
    ConsolePrint("DEX Explorer opened!")
end

-- Server Hop
local function ServerHop()
    local servers = {}
    
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        local data = HttpService:JSONDecode(response)
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
        ConsolePrint("Teleporting to new server...")
    else
        ConsolePrint("No servers found to hop to!")
    end
end

-- ==================== PROCESS COMMAND ====================

local function ProcessCommand(cmd)
    if not cmd or cmd == "" then return end
    if type(cmd) ~= "string" then return end
    
    -- Remove the ; prefix if it exists
    if string.sub(cmd, 1, 1) == ";" then
        cmd = string.sub(cmd, 2)
    end
    
    local args = {}
    for word in string.gmatch(cmd, "[^%s]+") do
        table.insert(args, word)
    end
    
    if #args == 0 then return end
    
    local command = string.lower(args[1])
    
    -- Player Commands
    if command == "speed" then
        local speed = tonumber(args[2])
        if speed then
            Admin.Speed = speed
            ApplyMovementSettings()
            ConsolePrint("Speed set to " .. tostring(speed))
        else
            ConsolePrint("Usage: speed [number]")
        end
        
    elseif command == "jumppower" or command == "jp" then
        local jump = tonumber(args[2])
        if jump then
            Admin.JumpPower = jump
            ApplyMovementSettings()
            ConsolePrint("Jump Power set to " .. tostring(jump))
        else
            ConsolePrint("Usage: jumppower [number]")
        end
        
    elseif command == "fly" then
        if flying then StopFly() else StartFly() end
        
    elseif command == "unfly" then
        if flying then StopFly() end
        
    elseif command == "noclip" then
        if noclip then StopNoclip() else StartNoclip() end
        
    elseif command == "infjump" or command == "infj" then
        if infiniteJump then StopInfiniteJump() else StartInfiniteJump() end
        
    elseif command == "invis" or command == "invisible" then
        if invisible then StopInvisible() else StartInvisible() end
        
    elseif command == "godmode" or command == "god" then
        if godMode then StopGodMode() else StartGodMode() end
        
    -- Target Commands
    elseif command == "target" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target and target ~= LocalPlayer then
                Admin.TargetPlayer = target
                Admin.TargetPlayerName = target.Name
                if targetTextbox then
                    targetTextbox:SetText(target.Name)
                end
                ConsolePrint("Target set to: " .. target.Name)
            else
                ConsolePrint("Player not found: " .. tostring(targetName))
            end
        else
            ConsolePrint("Current target: " .. (Admin.TargetPlayerName ~= "" and Admin.TargetPlayerName or "None"))
        end
        
    elseif command == "spin" then
        local speed = tonumber(args[2])
        if spinning then 
            StopSpin() 
        else 
            if speed then
                StartSpin(speed)
            else
                StartSpin()
            end
        end
        
    elseif command == "fling" then
        if flinging then StopFling() else StartFling() end
        
    elseif command == "kill" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                KillPlayer(target)
            else
                ConsolePrint("Player not found: " .. tostring(targetName))
            end
        else
            KillPlayer()
        end
        
    elseif command == "tp" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                TeleportToPlayer(target)
            else
                ConsolePrint("Player not found: " .. tostring(targetName))
            end
        else
            ConsolePrint("Usage: tp [username]")
        end
        
    elseif command == "headsit" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                HeadSit(target)
            else
                ConsolePrint("Player not found: " .. tostring(targetName))
            end
        else
            HeadSit()
        end
        
    -- Utility Commands
    elseif command == "btools" then
        GiveBuildingTools()
        
    elseif command == "dex" or command == "explorer" then
        OpenDEX()
        
    elseif command == "serverinfo" or command == "info" then
        local ping = "N/A"
        local success, result = pcall(function()
            local network = StatsService:FindFirstChild("Network")
            if network then
                local serverStats = network:FindFirstChild("ServerStatsItem")
                if serverStats then
                    local dataPing = serverStats:FindFirstChild("Data Ping")
                    if dataPing then
                        return dataPing:GetValueString()
                    end
                end
            end
            return nil
        end)
        if success and result then
            ping = tostring(result)
        end
        
        local infoText = "=== SERVER INFO ===\n" ..
            "Place ID: " .. tostring(game.PlaceId) .. "\n" ..
            "Job ID: " .. tostring(game.JobId) .. "\n" ..
            "Players: " .. tostring(#PlayersService:GetPlayers()) .. "/" .. tostring(game.Players.MaxPlayers) .. "\n" ..
            "Ping: " .. ping .. " ms\n" ..
            "Server Time: " .. os.date("%H:%M:%S") .. "\n" ..
            "=================="
        ConsolePrint(infoText)
        
    elseif command == "serverhop" or command == "shop" then
        ServerHop()
        
    elseif command == "players" or command == "playerlist" then
        if playerListPopup then
            playerListPopup:Destroy()
            playerListPopup = nil
        else
            CreatePlayerListPopup()
        end
        
    elseif command == "cmds" or command == "help" then
        local helpText = "=== COMMANDS ===\n" ..
            "speed [n] - Set walk speed\n" ..
            "jumppower [n] - Set jump power\n" ..
            "fly / unfly - Toggle fly\n" ..
            "noclip - Toggle noclip\n" ..
            "infjump - Toggle infinite jump\n" ..
            "invis - Toggle invisibility\n" ..
            "godmode - Toggle god mode\n" ..
            "target [name] - Select target\n" ..
            "spin [speed] - Spin target\n" ..
            "fling - Fling target\n" ..
            "kill [name] - Kill player\n" ..
            "tp [name] - Teleport to player\n" ..
            "headsit [name] - Sit on head\n" ..
            "btools - Give building tools\n" ..
            "dex - Open DEX Explorer\n" ..
            "serverinfo - Show server info\n" ..
            "serverhop - Hop to new server\n" ..
            "players - Show player list\n" ..
            "cmds - Show this menu\n" ..
            "================"
        ConsolePrint(helpText)
        
    elseif command == "creator" then
        ConsolePrint("Universal Admin Panel v2.0\nCreated for Roblox")
    else
        ConsolePrint("Unknown command: " .. command .. ". Type 'cmds' for help.")
    end
end

-- ==================== CHAT COMMANDS ====================
local function SetupChatCommands()
    pcall(function()
        LocalPlayer.Chatted:Connect(function(msg)
            ProcessCommand(msg)
        end)
    end)
    
    pcall(function()
        local textChatService = game:GetService("TextChatService")
        if textChatService then
            local textChannels = textChatService:FindFirstChild("TextChannels")
            if textChannels then
                local rbxSystem = textChannels:FindFirstChild("RBXSystem")
                if rbxSystem then
                    rbxSystem.MessageReceived:Connect(function(message)
                        if message.TextSource == LocalPlayer then
                            ProcessCommand(message.Text)
                        end
                    end)
                end
            end
        end
    end)
end

-- ==================== MOVEMENT UPDATE ====================
local function UpdateMovement()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = Admin.Speed
                humanoid.JumpPower = Admin.JumpPower
            end)
        end
    end
end

-- ==================== RENDER LOOP ====================
RunService.RenderStepped:Connect(function()
    UpdateMovement()
end)

-- ==================== CHARACTER ADDED ====================
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    ApplyMovementSettings()
    
    if noclip then
        UpdateNoclip()
    end
    
    if invisible then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency
                part.Transparency = 1
            end
        end
    end
    
    if godMode then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.BreakJointsOnDeath = false
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
    
    if flying then
        StopFly()
        task.wait(0.1)
        StartFly()
    end
end)

-- ==================== UI CREATION ====================
local Window = Library:CreateWindow("Universal Admin")

-- Player Tab
local PlayerTab = Window:CreateTab("Player", "user")
local PlayerSubTab = PlayerTab:CreateSubTab("Movement", "zap")
local PlayerSection = PlayerSubTab:CreateSection("Movement Settings")

PlayerSection:CreateSlider("Walk Speed", 16, 250, Admin.Speed, function(val)
    Admin.Speed = val
    ApplyMovementSettings()
end)

PlayerSection:CreateSlider("Jump Power", 50, 250, Admin.JumpPower, function(val)
    Admin.JumpPower = val
    ApplyMovementSettings()
end)

PlayerSection:CreateToggle("Fly", Admin.Fly, function(val)
    if val then StartFly() else StopFly() end
end)

PlayerSection:CreateToggle("Noclip", Admin.Noclip, function(val)
    if val then StartNoclip() else StopNoclip() end
end)

PlayerSection:CreateToggle("Infinite Jump", Admin.InfiniteJump, function(val)
    if val then StartInfiniteJump() else StopInfiniteJump() end
end)

PlayerSection:CreateToggle("Invisible", Admin.Invisible, function(val)
    if val then StartInvisible() else StopInvisible() end
end)

PlayerSection:CreateToggle("God Mode", Admin.GodMode, function(val)
    if val then StartGodMode() else StopGodMode() end
end)

-- Target Tab
local TargetTab = Window:CreateTab("Target", "target")
local TargetSubTab = TargetTab:CreateSubTab("Actions", "swords")
local TargetSection = TargetSubTab:CreateSection("Target Selection")

-- Text input for target instead of dropdown
targetTextbox = TargetSection:CreateTextbox("Target Player Name", Admin.TargetPlayerName, function(val)
    if val and val ~= "" then
        local target = GetPlayer(val)
        if target and target ~= LocalPlayer then
            Admin.TargetPlayer = target
            Admin.TargetPlayerName = target.Name
            ConsolePrint("Target set to: " .. target.Name)
            -- Update player list highlight
            if playerListPopup then
                pcall(function()
                    for _, btn in pairs(playerListPopup:GetDescendants()) do
                        if btn:IsA("Frame") and btn:FindFirstChild("TextLabel") then
                            local nameLabel = btn:FindFirstChild("TextLabel")
                            if nameLabel and nameLabel.Text == target.Name then
                                btn.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
                            elseif btn.BackgroundColor3 == Color3.fromRGB(160, 60, 255) then
                                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            end
                        end
                    end
                end)
            end
        else
            ConsolePrint("Player not found: " .. val)
        end
    end
end)

TargetSection:CreateButton("Show Player List", function()
    if playerListPopup then
        playerListPopup:Destroy()
        playerListPopup = nil
    else
        CreatePlayerListPopup()
    end
end)

TargetSection:CreateButton("Spin Target", function()
    if spinning then StopSpin() else StartSpin() end
end)

TargetSection:CreateSlider("Spin Speed", 100, 1000, Admin.SpinSpeed, function(val)
    Admin.SpinSpeed = val
    if spinning then
        StopSpin()
        StartSpin()
    end
end)

TargetSection:CreateButton("Fling Target", function()
    if flinging then StopFling() else StartFling() end
end)

TargetSection:CreateButton("Kill Target", function()
    KillPlayer()
end)

TargetSection:CreateButton("Teleport to Target", function()
    TeleportToPlayer(Admin.TargetPlayer)
end)

TargetSection:CreateButton("Head Sit on Target", function()
    HeadSit()
end)

-- Utility Tab
local UtilityTab = Window:CreateTab("Utility", "settings")
local UtilitySubTab = UtilityTab:CreateSubTab("Tools", "save")
local UtilitySection = UtilitySubTab:CreateSection("Utility Tools")

UtilitySection:CreateButton("Give Building Tools (btools)", function()
    GiveBuildingTools()
end)

UtilitySection:CreateButton("Open DEX Explorer (dex)", function()
    OpenDEX()
end)

UtilitySection:CreateButton("Show Server Info (serverinfo)", function()
    ProcessCommand("serverinfo")
end)

UtilitySection:CreateButton("Server Hop (serverhop)", function()
    ServerHop()
end)

-- Commands Tab
local CommandsTab = Window:CreateTab("Commands", "commands")
local CommandsSubTab = CommandsTab:CreateSubTab("Help", "globe")
local CommandsSection = CommandsSubTab:CreateSection("Command List")

CommandsSection:CreateButton("Show All Commands (cmds)", function()
    ShowCommandList()
end)

CommandsSection:CreateButton("Execute Custom Command", function()
    ShowCommandPrompt("")
end)

-- Info Tab
local InfoTab = Window:CreateTab("Info", "info")
local InfoSubTab = InfoTab:CreateSubTab("About", "user")
local InfoSection = InfoSubTab:CreateSection("INFORMATION")

InfoSection:CreateLabel("═══════════════════════════════")
InfoSection:CreateLabel("     UNIVERSAL ADMIN PANEL")
InfoSection:CreateLabel("═══════════════════════════════")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("Version: 2.0")
InfoSection:CreateLabel("Works in ALL Roblox games!")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("HOW TO USE:")
InfoSection:CreateLabel("Press Right Shift to toggle UI")
InfoSection:CreateLabel("Type commands in chat or use UI")
InfoSection:CreateLabel("Example: fly")
InfoSection:CreateLabel("Example: speed 50")
InfoSection:CreateLabel("Example: target PlayerName")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("FEATURES:")
InfoSection:CreateLabel("God Mode - You can't die!")
InfoSection:CreateLabel("Adjustable Spin Speed")
InfoSection:CreateLabel("Live Player List with Copy")
InfoSection:CreateLabel("Auto-Complete Command Bar")
InfoSection:CreateLabel("Tab to autocomplete commands")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("COMMANDS:")
InfoSection:CreateLabel("fly / unfly - Toggle flight")
InfoSection:CreateLabel("players - Show player list")
InfoSection:CreateLabel("cmds - Show all commands")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("Drag the UI by the top bar")
InfoSection:CreateLabel("═══════════════════════════════")

-- Start
SetupChatCommands()

-- Apply initial movement settings
task.wait(0.5)
ApplyMovementSettings()

ConsolePrint("========================================")
ConsolePrint("   UNIVERSAL ADMIN PANEL LOADED!")
ConsolePrint("   Press Right Shift to open UI")
ConsolePrint("   Type 'cmds' in chat for commands")
ConsolePrint("   Type 'players' for player list")
ConsolePrint("   Type 'fly' to fly, 'unfly' to stop")
ConsolePrint("   Tab key autocompletes commands!")
ConsolePrint("========================================")