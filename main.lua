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
    sliders = { 16898613777, 48, 48, 404, 771 }
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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Admin Settings
local Admin = {
    -- Player Settings
    Speed = 16,
    JumpPower = 50,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    Invisible = false,
    
    -- Target Player (for fling, spin, kill)
    TargetPlayer = nil,
    
    -- UI
    ShowConsole = true,
}

-- Fly variables
local flying = false
local noclip = false
local flyBodyVelocity = nil
local noclipParts = {}

-- Infinite Jump
local infiniteJump = false
local originalJumpPower = 50

-- Invisible
local invisible = false
local originalTransparency = {}

-- Spin variables
local spinning = false
local spinConnection = nil
local spinSpeed = 360

-- Fling variables
local flinging = false
local flingConnection = nil

-- Console output
local function ConsolePrint(msg, color)
    color = color or Color3.fromRGB(255, 255, 255)
    print(msg)
end

-- ==================== PLAYER MANAGEMENT ====================

-- Get all players
local function GetAllPlayers()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(players, player)
    end
    return players
end

-- Get player by name or partial name
local function GetPlayer(input)
    if type(input) == "string" then
        for _, player in pairs(Players:GetPlayers()) do
            if string.lower(player.Name) == string.lower(input) or string.lower(player.DisplayName) == string.lower(input) then
                return player
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if string.find(string.lower(player.Name), string.lower(input)) or string.find(string.lower(player.DisplayName), string.lower(input)) then
                return player
            end
        end
    elseif type(input) == "number" then
        return Players:GetPlayerByUserId(input)
    end
    return nil
end

-- Get player from selection dropdown
local function UpdateTargetList()
    local players = GetAllPlayers()
    local names = {}
    for _, player in pairs(players) do
        table.insert(names, player.Name)
    end
    return names
end

-- ==================== FLY SYSTEM ====================
local function StartFly()
    if flying then return end
    flying = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Create body velocity
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyBodyVelocity.Parent = hrp
    
    -- Movement loop
    spawn(function()
        while flying and LocalPlayer.Character and hrp.Parent do
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
            
            local speed = 50
            flyBodyVelocity.Velocity = (Camera.CFrame.RightVector * moveDirection.X + 
                                         Camera.CFrame.UpVector * moveDirection.Y + 
                                         Camera.CFrame.LookVector * moveDirection.Z) * speed
            
            -- Disable gravity
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            
            RunService.RenderStepped:Wait()
        end
    end)
    
    ConsolePrint("✈️ Fly: ON")
end

local function StopFly()
    if not flying then return end
    flying = false
    
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    
    ConsolePrint("✈️ Fly: OFF")
end

-- ==================== NOCLIP SYSTEM ====================
local function StartNoclip()
    if noclip then return end
    noclip = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Store original CanCollide values and disable collision
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            noclipParts[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    
    ConsolePrint("💨 Noclip: ON")
end

local function StopNoclip()
    if not noclip then return end
    noclip = false
    
    local char = LocalPlayer.Character
    if char then
        for part, original in pairs(noclipParts) do
            if part.Parent == char then
                part.CanCollide = original
            end
        end
    end
    noclipParts = {}
    
    ConsolePrint("💨 Noclip: OFF")
end

-- ==================== INFINITE JUMP ====================
local function StartInfiniteJump()
    if infiniteJump then return end
    infiniteJump = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        originalJumpPower = humanoid.JumpPower
    end
    
    local connection
    connection = UserInputService.JumpRequest:Connect(function()
        if infiniteJump and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    ConsolePrint("🦘 Infinite Jump: ON")
end

local function StopInfiniteJump()
    infiniteJump = false
    
    ConsolePrint("🦘 Infinite Jump: OFF")
end

-- ==================== SPIN SYSTEM ====================
local function StartSpin(targetPlayer)
    if spinning then return end
    spinning = true
    
    local target = targetPlayer or Admin.TargetPlayer
    if not target then
        ConsolePrint("❌ No target selected for spin!")
        spinning = false
        return
    end
    
    local char = target.Character
    if not char then
        ConsolePrint("❌ Target has no character!")
        spinning = false
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        ConsolePrint("❌ Target has no HumanoidRootPart!")
        spinning = false
        return
    end
    
    local originalCF = hrp.CFrame
    
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        if spinning and target.Character and hrp.Parent then
            local newAngle = spinSpeed * dt
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(newAngle), 0)
        end
    end)
    
    ConsolePrint("🌀 Spinning " .. target.Name .. "!")
end

local function StopSpin()
    if not spinning then return end
    spinning = false
    
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    
    ConsolePrint("🌀 Spin stopped!")
end

-- ==================== FLING SYSTEM ====================
local function StartFling(targetPlayer)
    if flinging then return end
    flinging = true
    
    local target = targetPlayer or Admin.TargetPlayer
    if not target then
        ConsolePrint("❌ No target selected for fling!")
        flinging = false
        return
    end
    
    local char = target.Character
    if not char then
        ConsolePrint("❌ Target has no character!")
        flinging = false
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        ConsolePrint("❌ Target has no HumanoidRootPart!")
        flinging = false
        return
    end
    
    flingConnection = RunService.RenderStepped:Connect(function()
        if flinging and target.Character and hrp.Parent then
            local randomDir = Vector3.new(math.random(-100, 100), math.random(50, 150), math.random(-100, 100))
            hrp.AssemblyLinearVelocity = randomDir
        end
    end)
    
    ConsolePrint("💥 Flinging " .. target.Name .. "!")
end

local function StopFling()
    if not flinging then return end
    flinging = false
    
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    
    ConsolePrint("💥 Fling stopped!")
end

-- ==================== KILL PLAYER ====================
local function KillPlayer(targetPlayer)
    local target = targetPlayer or Admin.TargetPlayer
    if not target then
        ConsolePrint("❌ No target selected to kill!")
        return
    end
    
    local char = target.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
            ConsolePrint("💀 Killed " .. target.Name .. "!")
        else
            ConsolePrint("❌ Could not kill " .. target.Name .. "!")
        end
    else
        ConsolePrint("❌ " .. target.Name .. " has no character!")
    end
end

-- ==================== TELEPORT ====================
local function TeleportToPlayer(targetPlayer)
    local target = targetPlayer
    if not target then
        ConsolePrint("❌ No target selected to teleport to!")
        return
    end
    
    local targetChar = target.Character
    if not targetChar then
        ConsolePrint("❌ Target has no character!")
        return
    end
    
    local localChar = LocalPlayer.Character
    if not localChar then
        ConsolePrint("❌ You have no character!")
        return
    end
    
    local targetPos = targetChar:GetPivot().Position
    localChar:PivotTo(CFrame.new(targetPos))
    
    ConsolePrint("✨ Teleported to " .. target.Name .. "!")
end

local function TeleportToPosition(position)
    local localChar = LocalPlayer.Character
    if not localChar then
        ConsolePrint("❌ You have no character!")
        return
    end
    
    localChar:PivotTo(CFrame.new(position))
    ConsolePrint("✨ Teleported to position!")
end

-- ==================== HEADSIT ====================
local function HeadSit(targetPlayer)
    local target = targetPlayer or Admin.TargetPlayer
    if not target then
        ConsolePrint("❌ No target selected for headsit!")
        return
    end
    
    local targetChar = target.Character
    if not targetChar then
        ConsolePrint("❌ Target has no character!")
        return
    end
    
    local localChar = LocalPlayer.Character
    if not localChar then
        ConsolePrint("❌ You have no character!")
        return
    end
    
    local head = targetChar:FindFirstChild("Head")
    if not head then
        ConsolePrint("❌ Target has no head!")
        return
    end
    
    -- Sit on head
    localChar:PivotTo(CFrame.new(head.Position + Vector3.new(0, 2, 0)))
    
    -- Create weld to stay on head
    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
    if localHRP then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = localHRP
        weld.Part1 = head
        weld.Parent = localHRP
        
        task.delay(0.5, function()
            if weld then weld:Destroy() end
        end)
    end
    
    ConsolePrint("👑 Sitting on " .. target.Name .. "'s head!")
end

-- ==================== INVISIBLE ====================
local function StartInvisible()
    if invisible then return end
    invisible = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Store original transparency and make invisible
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalTransparency[part] = part.Transparency
            part.Transparency = 1
        end
    end
    
    ConsolePrint("👻 Invisible: ON")
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
    
    ConsolePrint("👻 Invisible: OFF")
end

-- ==================== BUILDING TOOLS ====================
local function GiveBuildingTools()
    local tools = {
        "rbxassetid://169209103", -- Base part tool
        "rbxassetid://169191869", -- Wedge part tool
        "rbxassetid://169211324", -- Corner wedge tool
        "rbxassetid://169217863", -- Cylinder tool
        "rbxassetid://169223733", -- Sphere tool
        "rbxassetid://169224140", -- Torus tool
        "rbxassetid://169224309", -- Delete tool
        "rbxassetid://169224443", -- Drag tool
        "rbxassetid://169224599", -- Color tool
        "rbxassetid://169224715", -- Material tool
    }
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    for _, toolId in pairs(tools) do
        local tool = Instance.new("Tool")
        tool.Name = "Building Tool"
        tool.RequiresHandle = false
        tool.ToolTip = "Building Tool"
        
        local script = Instance.new("Script")
        script.Name = "Main"
        script.Source = [[
            local tool = script.Parent
            local mouse = game.Players.LocalPlayer:GetMouse()
            
            tool.Equipped:Connect(function()
                mouse.Icon = "rbxasset://textures/Gui/cursor.png"
            end)
            
            tool.Unequipped:Connect(function()
                mouse.Icon = ""
            end)
            
            tool.Activated:Connect(function()
                -- Simple building functionality
                local part = Instance.new("Part")
                part.Size = Vector3.new(4, 1, 4)
                part.Position = mouse.Hit.Position
                part.Anchored = true
                part.Parent = workspace
            end)
        ]]
        script.Parent = tool
        
        tool.Parent = backpack
    end
    
    ConsolePrint("🔨 Building tools added to backpack!")
end

-- ==================== DEX EXPLORER ====================
local function OpenDEX()
    -- Load DEX Explorer
    local dex = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhammy/Roblox-Exploits/main/dex.lua"))()
    ConsolePrint("📁 DEX Explorer opened!")
end

-- ==================== SERVER INFO ====================
local function GetServerInfo()
    local placeId = game.PlaceId
    local jobId = game.JobId
    local playerCount = #Players:GetPlayers()
    local maxPlayers = game.Players.MaxPlayers
    
    local info = string.format([[
=== SERVER INFO ===
Place ID: %d
Job ID: %s
Players: %d/%d
Ping: %d ms
==================
    ]], placeId, jobId, playerCount, maxPlayers, game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    
    ConsolePrint(info)
    return info
end

-- ==================== SERVER HOP ====================
local function ServerHop()
    local servers = {}
    
    -- Try to get servers from API
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
        ConsolePrint("🔄 Teleporting to new server...")
    else
        ConsolePrint("❌ No servers found to hop to!")
    end
end

-- ==================== JOIN PLAYER ====================
local function JoinPlayer(playerName)
    local player = GetPlayer(playerName)
    if not player then
        ConsolePrint("❌ Player not found: " .. playerName)
        return
    end
    
    -- Get player's current game
    local userId = player.UserId
    local url = "https://users.roblox.com/v1/users/" .. userId
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        local data = HttpService:JSONDecode(response)
        -- Try to join via TeleportService
        TeleportService:TeleportToPlaceInstance(game.PlaceId, player, LocalPlayer)
        ConsolePrint("🔗 Attempting to join " .. player.Name .. "...")
    else
        ConsolePrint("❌ Could not join " .. player.Name)
    end
end

-- ==================== COMMAND SYSTEM ====================
local function ProcessCommand(msg)
    if not string.sub(msg, 1, 1) == ";" then return end
    
    local args = {}
    for word in string.gmatch(msg, "[^%s]+") do
        table.insert(args, word)
    end
    
    local cmd = string.lower(args[1])
    
    -- Speed
    if cmd == ";speed" then
        local speed = tonumber(args[2])
        if speed then
            Admin.Speed = speed
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = speed
                end
            end
            ConsolePrint("🏃 Speed set to " .. speed)
        end
        
    -- Jump Power
    elseif cmd == ";jumppower" or cmd == ";jp" then
        local jump = tonumber(args[2])
        if jump then
            Admin.JumpPower = jump
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = jump
                end
            end
            ConsolePrint("🦘 Jump Power set to " .. jump)
        end
        
    -- Fly
    elseif cmd == ";fly" then
        if flying then
            StopFly()
        else
            StartFly()
        end
        
    -- Noclip
    elseif cmd == ";noclip" then
        if noclip then
            StopNoclip()
        else
            StartNoclip()
        end
        
    -- Infinite Jump
    elseif cmd == ";infjump" or cmd == ";infj" then
        if infiniteJump then
            StopInfiniteJump()
        else
            StartInfiniteJump()
        end
        
    -- Invisible
    elseif cmd == ";invis" or cmd == ";invisible" then
        if invisible then
            StopInvisible()
        else
            StartInvisible()
        end
        
    -- Select Target
    elseif cmd == ";target" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                Admin.TargetPlayer = target
                ConsolePrint("🎯 Target set to: " .. target.Name)
            else
                ConsolePrint("❌ Player not found: " .. targetName)
            end
        else
            ConsolePrint("🎯 Current target: " .. (Admin.TargetPlayer and Admin.TargetPlayer.Name or "None"))
        end
        
    -- Spin
    elseif cmd == ";spin" then
        if spinning then
            StopSpin()
        else
            StartSpin()
        end
        
    -- Fling
    elseif cmd == ";fling" then
        if flinging then
            StopFling()
        else
            StartFling()
        end
        
    -- Kill
    elseif cmd == ";kill" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                KillPlayer(target)
            else
                ConsolePrint("❌ Player not found: " .. targetName)
            end
        else
            KillPlayer()
        end
        
    -- Teleport
    elseif cmd == ";tp" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                TeleportToPlayer(target)
            else
                ConsolePrint("❌ Player not found: " .. targetName)
            end
        else
            ConsolePrint("❌ Usage: ;tp [username]")
        end
        
    -- Headsit
    elseif cmd == ";headsit" then
        local targetName = args[2]
        if targetName then
            local target = GetPlayer(targetName)
            if target then
                HeadSit(target)
            else
                ConsolePrint("❌ Player not found: " .. targetName)
            end
        else
            HeadSit()
        end
        
    -- Building Tools
    elseif cmd == ";btools" then
        GiveBuildingTools()
        
    -- DEX Explorer
    elseif cmd == ";dex" or cmd == ";explorer" then
        OpenDEX()
        
    -- Server Info
    elseif cmd == ";serverinfo" or cmd == ";info" then
        GetServerInfo()
        
    -- Server Hop
    elseif cmd == ";serverhop" or cmd == ";shop" then
        ServerHop()
        
    -- Join Player
    elseif cmd == ";joinplayer" or cmd == ";join" then
        local targetName = args[2]
        if targetName then
            JoinPlayer(targetName)
        else
            ConsolePrint("❌ Usage: ;join [username]")
        end
        
    -- Creator Info
    elseif cmd == ";creator" then
        ConsolePrint("👨‍💻 Created by: Universal Admin Panel")
        ConsolePrint("📧 Contact: admin@example.com")
        
    -- Help
    elseif cmd == ";cmds" or cmd == ";help" then
        ConsolePrint([[
=== UNIVERSAL ADMIN PANEL COMMANDS ===

=== Player Commands ===
;speed [value] - Set walk speed
;jumppower [value] - Set jump power
;fly - Toggle fly mode
;noclip - Toggle noclip
;infjump - Toggle infinite jump
;invis - Toggle invisibility

=== Target Commands ===
;target [name] - Select target player
;spin - Spin target
;fling - Fling target
;kill [name] - Kill target player
;tp [name] - Teleport to player
;headsit [name] - Sit on player's head

=== Utility Commands ===
;btools - Give building tools
;dex - Open DEX Explorer
;serverinfo - Show server info
;serverhop - Hop to new server
;join [name] - Join a player
;creator - Show creator info

=== Other ===
;cmds - Show this menu
=====================================
        ]])
    end
end

-- Chat command listener
local function SetupChatCommands()
    -- For normal chat
    local onChatted
    onChatted = LocalPlayer.Chatted:Connect(function(msg)
        ProcessCommand(msg)
    end)
    
    -- For TextChatService (new chat system)
    local textChatService = game:GetService("TextChatService")
    if textChatService then
        local textChannels = textChatService:WaitForChild("TextChannels")
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

-- ==================== MOVEMENT UPDATE ====================
local function UpdateMovement()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Admin.Speed
            humanoid.JumpPower = Admin.JumpPower
        end
    end
end

-- ==================== RENDER LOOP ====================
local function OnRenderStep()
    UpdateMovement()
    
    -- Update fly/noclip if character changes
    if flying and not flyBodyVelocity then
        StartFly()
    end
    if noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not noclipParts[part] then
                    noclipParts[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end
    end
end

-- ==================== CHARACTER ADDED ====================
local function OnCharacterAdded(character)
    UpdateMovement()
    
    -- Re-apply noclip
    if noclip then
        task.wait(0.5)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                noclipParts[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    end
    
    -- Re-apply invisibility
    if invisible then
        task.wait(0.5)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency
                part.Transparency = 1
            end
        end
    end
end

-- ==================== SETUP CONNECTIONS ====================
local Connections = {}
Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
Connections.RenderStepped = RunService.RenderStepped:Connect(OnRenderStep)

-- ==================== UI CREATION ====================
local Window = Library:CreateWindow("Universal Admin")

-- Player Tab
local PlayerTab = Window:CreateTab("Player", "user")
local PlayerSubTab = PlayerTab:CreateSubTab("Movement", "zap")
local PlayerSection = PlayerSubTab:CreateSection("Movement Settings")

local speedSlider = PlayerSection:CreateSlider("Walk Speed", 16, 250, Admin.Speed, function(val)
    Admin.Speed = val
    UpdateMovement()
end)

local jumpSlider = PlayerSection:CreateSlider("Jump Power", 50, 250, Admin.JumpPower, function(val)
    Admin.JumpPower = val
    UpdateMovement()
end)

PlayerSection:CreateToggle("Fly", Admin.Fly, function(val)
    if val then
        StartFly()
    else
        StopFly()
    end
end)

PlayerSection:CreateToggle("Noclip", Admin.Noclip, function(val)
    if val then
        StartNoclip()
    else
        StopNoclip()
    end
end)

PlayerSection:CreateToggle("Infinite Jump", Admin.InfiniteJump, function(val)
    if val then
        StartInfiniteJump()
    else
        StopInfiniteJump()
    end
end)

PlayerSection:CreateToggle("Invisible", Admin.Invisible, function(val)
    if val then
        StartInvisible()
    else
        StopInvisible()
    end
end)

-- Target Tab
local TargetTab = Window:CreateTab("Target", "target")
local TargetSubTab = TargetTab:CreateSubTab("Actions", "swords")
local TargetSection = TargetSubTab:CreateSection("Target Selection")

local targetDropdown = TargetSection:CreateDropdown("Select Target", UpdateTargetList(), "None", function(val)
    Admin.TargetPlayer = GetPlayer(val)
    ConsolePrint("🎯 Target set to: " .. val)
end)

TargetSection:CreateButton("Refresh Player List", function()
    targetDropdown:Refresh(UpdateTargetList())
end)

TargetSection:CreateButton("Spin Target", function()
    if spinning then
        StopSpin()
    else
        StartSpin()
    end
end)

TargetSection:CreateButton("Fling Target", function()
    if flinging then
        StopFling()
    else
        StartFling()
    end
end)

TargetSection:CreateButton("Kill Target", function()
    KillPlayer()
end)

TargetSection:CreateButton("Teleport to Target", function()
    TeleportToPlayer()
end)

TargetSection:CreateButton("Head Sit on Target", function()
    HeadSit()
end)

-- Utility Tab
local UtilityTab = Window:CreateTab("Utility", "settings")
local UtilitySubTab = UtilityTab:CreateSubTab("Tools", "save")
local UtilitySection = UtilitySubTab:CreateSection("Utility Tools")

UtilitySection:CreateButton("Give Building Tools (;btools)", function()
    GiveBuildingTools()
end)

UtilitySection:CreateButton("Open DEX Explorer (;dex)", function()
    OpenDEX()
end)

UtilitySection:CreateButton("Show Server Info (;serverinfo)", function()
    GetServerInfo()
end)

UtilitySection:CreateButton("Server Hop (;serverhop)", function()
    ServerHop()
end)

-- Commands Tab
local CommandsTab = Window:CreateTab("Commands", "search")
local CommandsSubTab = CommandsTab:CreateSubTab("Help", "globe")
local CommandsSection = CommandsSubTab:CreateSection("Command List")

CommandsSection:CreateButton("Show All Commands (;cmds)", function()
    ConsolePrint([[
=== UNIVERSAL ADMIN PANEL COMMANDS ===

=== Player Commands ===
;speed [value] - Set walk speed
;jumppower [value] - Set jump power
;fly - Toggle fly mode
;noclip - Toggle noclip
;infjump - Toggle infinite jump
;invis - Toggle invisibility

=== Target Commands ===
;target [name] - Select target player
;spin - Spin target
;fling - Fling target
;kill [name] - Kill target player
;tp [name] - Teleport to player
;headsit [name] - Sit on player's head

=== Utility Commands ===
;btools - Give building tools
;dex - Open DEX Explorer
;serverinfo - Show server info
;serverhop - Hop to new server
;join [name] - Join a player
;creator - Show creator info

=== Other ===
;cmds - Show this menu
=====================================
    ]])
end)

-- Info Tab (FIXED - Using CreateLabel which now exists)
local InfoTab = Window:CreateTab("Info", "account")
local InfoSubTab = InfoTab:CreateSubTab("About", "user")
local InfoSection = InfoSubTab:CreateSection("Information")

-- Now CreateLabel is available in the UI library!
InfoSection:CreateLabel("Universal Admin Panel")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("Similar to Infinite Yield")
InfoSection:CreateLabel("Works in ALL Roblox games!")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("Commands work in chat:")
InfoSection:CreateLabel("Example: ;fly")
InfoSection:CreateLabel("Example: ;speed 50")
InfoSection:CreateLabel("Example: ;target PlayerName")
InfoSection:CreateLabel("")
InfoSection:CreateLabel("Press Right Shift to toggle UI")

-- Start
SetupChatCommands()

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

ConsolePrint("========================================")
ConsolePrint("   UNIVERSAL ADMIN PANEL LOADED!")
ConsolePrint("   Press Right Shift to open UI")
ConsolePrint("   Type ;cmds in chat for commands")
ConsolePrint("========================================")