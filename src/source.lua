-- Orion/MarVLib UI Library
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local MarVLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false
}

-- Feather Icons=
local Icons = {}
local Success, Response = pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)
if not Success then
    warn("MarV Library - Failed to load icons")
end

local function GetIcon(IconName)
    return Icons[IconName]
end

local MarV = Instance.new("ScreenGui")
MarV.Name = "MarV"
if syn then
    syn.protect_gui(MarV)
    MarV.Parent = game.CoreGui
else
    MarV.Parent = gethui() or game.CoreGui
end

if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == MarV.Name and Interface ~= MarV then
            Interface:Destroy()
        end
    end
else
    for _, Interface in ipairs(game.CoreGui:GetChildren()) do
        if Interface.Name == MarV.Name and Interface ~= MarV then
            Interface:Destroy()
        end
    end
end

function MarVLib:IsRunning()
    if gethui then
        return MarV.Parent == gethui()
    else
        return MarV.Parent == game:GetService("CoreGui")
    end
end

local function AddConnection(Signal, Function)
    if (not MarVLib:IsRunning()) then return end
    local SignalConnect = Signal:Connect(Function)
    table.insert(MarVLib.Connections, SignalConnect)
    return SignalConnect
end

task.spawn(function()
    while (MarVLib:IsRunning()) do wait() end
    for _, Connection in next, MarVLib.Connections do
        Connection:Disconnect()
    end
end)

local function AddDraggingFunctionality(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        DragPoint.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        DragPoint.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                DragInput = Input
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                }):Play()
            end
        end)
    end)
end

local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do
        Object[i] = v
    end
    for i, v in next, Children or {} do
        v.Parent = Object
    end
    return Object
end

local function CreateElement(ElementName, ElementFunction)
    MarVLib.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    local NewElement = MarVLib.Elements[ElementName](...)
    return NewElement
end

local function SetProps(Element, Props)
    table.foreach(Props, function(Property, Value)
        Element[Property] = Value
    end)
    return Element
end

local function SetChildren(Element, Children)
    table.foreach(Children, function(_, Child)
        Child.Parent = Element
    end)
    return Element
end

local function Round(Number, Factor)
    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then
        Result = Result + Factor
    end
    return Result
end

local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    end
    if Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    end
    if Object:IsA("UIStroke") then
        return "Color"
    end
    if Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    end
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end
end

local function AddThemeObject(Object, Type)
    if not MarVLib.ThemeObjects[Type] then
        MarVLib.ThemeObjects[Type] = {}
    end
    table.insert(MarVLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = MarVLib.Themes[MarVLib.SelectedTheme][Type]
    return Object
end

local function SetTheme()
    for Name, Type in pairs(MarVLib.ThemeObjects) do
        for _, Object in pairs(Type) do
            Object[ReturnProperty(Object)] = MarVLib.Themes[MarVLib.SelectedTheme][Name]
        end
    end
end

local function PackColor(Color)
    return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
    return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
    local Data = HttpService:JSONDecode(Config)
    table.foreach(Data, function(a,b)
        if MarVLib.Flags[a] then
            spawn(function()
                if MarVLib.Flags[a].Type == "Colorpicker" then
                    MarVLib.Flags[a]:Set(UnpackColor(b))
                else
                    MarVLib.Flags[a]:Set(b)
                end
            end)
        else
            warn("MarV Library Config Loader - Could not find ", a ,b)
        end
    end)
end

local function SaveCfg(Name)
    local Data = {}
    for i,v in pairs(MarVLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then
                Data[i] = PackColor(v.Value)
            else
                Data[i] = v.Value
            end
        end
    end
    writefile(MarVLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local function MakeKeybind(Bind)
    local Keybind = Bind.Keybind
    if Keybind == Enum.KeyCode.Unknown then
        Keybind = nil
    end
    if Keybind then
        local Connection
        local KeybindLabel = Bind.KeybindLabel
        local Callback = Bind.Callback
        if Connection then
            Connection:Disconnect()
        end
        Connection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
            if GameProcessed then return end
            if Input.KeyCode == Keybind and Callback then
                Callback()
            end
        end)
        return Connection
    end
end

function MarVLib:MakeNotification(NotificationConfig)
    local NotificationFrame = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 250, 0, 70),
        Position = UDim2.new(1, 20, 0, 0),
        BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MarV
    })
    AddThemeObject(NotificationFrame, "Second")
    Create("UIStroke", {
        Thickness = 1.5,
        Color = MarVLib.Themes[MarVLib.SelectedTheme].Stroke,
        Parent = NotificationFrame
    })
    AddThemeObject(NotificationFrame.UIStroke, "Stroke")
    local NotificationTitle = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = NotificationConfig.Name,
        TextColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationFrame
    })
    AddThemeObject(NotificationTitle, "Text")
    local NotificationContent = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, -35),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = NotificationConfig.Content,
        TextColor3 = MarVLib.Themes[MarVLib.SelectedTheme].TextDark,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = NotificationFrame
    })
    AddThemeObject(NotificationContent, "TextDark")
    NotificationFrame:TweenPosition(UDim2.new(1, -270, 0, 0), 'Out', 'Quint', 0.8, true)
    task.wait(NotificationConfig.Time or 5)
    NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
    task.wait(0.8)
    NotificationFrame:Destroy()
end

function MarVLib:Init()
    if MarVLib.SaveCfg then
        pcall(function()
            if isfile(MarVLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(MarVLib.Folder .. "/" .. game.GameId .. ".txt"))
                MarVLib:MakeNotification({
                    Name = "Configuration",
                    Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
                    Time = 5
                })
            end
        end)
    end
end

-- Create base UI elements
CreateElement("RoundFrame", function(Color, Transparency, Rounding)
    local Frame = Create("Frame", {
        BackgroundColor3 = Color,
        BackgroundTransparency = Transparency,
        BorderSizePixel = 0
    })
    local UICorner = Create("UICorner", {
        CornerRadius = UDim.new(0, Rounding)
    })
    UICorner.Parent = Frame
    return Frame
end)

CreateElement("Stroke", function()
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return Stroke
end)

CreateElement("Image", function(AssetId)
    local Image = Instance.new("ImageLabel")
    Image.Image = AssetId
    Image.BackgroundTransparency = 1
    return Image
end)

CreateElement("Button", function()
    local Button = Instance.new("TextButton")
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.BackgroundTransparency = 1
    return Button
end)

CreateElement("Label", function(Text, Size)
    local Label = Instance.new("TextLabel")
    Label.Text = Text
    Label.TextSize = Size or 14
    Label.Font = Enum.Font.Gotham
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.TextYAlignment = Enum.TextYAlignment.Center
    return Label
end)

CreateElement("ScrollFrame", function(Color, Rounding)
    local Frame = Create("RoundFrame", Color, 0, Rounding)
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1,0,1,0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
    ScrollingFrame.Parent = Frame
    return Frame, ScrollingFrame
end)

CreateElement("List", function()
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 4)
    return UIListLayout
end)

CreateElement("Padding", function(Left, Right, Top, Bottom)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, Left)
    UIPadding.PaddingRight = UDim.new(0, Right)
    UIPadding.PaddingTop = UDim.new(0, Top)
    UIPadding.PaddingBottom = UDim.new(0, Bottom)
    return UIPadding
end)

function MarVLib:MakeWindow(WindowConfig)
    local FirstTab = true
    local Minimized = false
    local Loaded = false
    local UIHidden = false
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "MarV Library"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    
    MarVLib.Folder = WindowConfig.ConfigFolder
    MarVLib.SaveCfg = WindowConfig.SaveConfig
    if WindowConfig.SaveConfig then
        if not isfolder(WindowConfig.ConfigFolder) then
            makefolder(WindowConfig.ConfigFolder)
        end
    end
    
    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
        Size = UDim2.new(1, 0, 1, -50)
    }), {
        MakeElement("List"),
        MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")
    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)
    
    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18)
        }), "Text")
    })
    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18),
            Name = "Icon"
        }), "Text")
    })
    local Title = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 15), {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    }), "Text")
    local DragPoint = SetChildren(SetProps(MakeElement("RoundFrame", MarVLib.Themes[MarVLib.SelectedTheme].Main, 0, 5), {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Main,
        Name = "DragPoint"
    }), {
        Title,
        MinimizeBtn,
        CloseBtn
    })
    AddThemeObject(DragPoint, "Main")
    local MainFrame = SetChildren(SetProps(MakeElement("RoundFrame", MarVLib.Themes[MarVLib.SelectedTheme].Main, 0, 8), {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        Active = true,
        Draggable = true,
        ClipsDescendants = true,
        Parent = MarV
    }), {
        DragPoint,
        TabHolder
    })
    AddThemeObject(MainFrame, "Main")
    AddDraggingFunctionality(DragPoint, MainFrame)
    
    local Tabs = {}
    local TabButtons = {}
    local CurrentTab = nil
    local Window = {}
    
    function Window:MakeTab(TabConfig)
        local Tab = {}
        local TabButton = SetChildren(SetProps(MakeElement("Button"), {
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, #TabButtons * 35 + 5),
            BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
            Name = TabConfig.Name
        }), {
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            }), "Text"),
            AddThemeObject(MakeElement("Stroke"), "Stroke")
        })
        AddThemeObject(TabButton, "Second")
        local TabContent = SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
            Size = UDim2.new(1, 0, 1, 0),
            Visible = FirstTab,
            Position = UDim2.new(0, 0, 0, 0),
            Name = TabConfig.Name
        }), {
            MakeElement("List"),
            MakeElement("Padding", 8, 0, 0, 8)
        })
        AddThemeObject(TabContent, "Divider")
        TabContent.Parent = MainFrame
        AddConnection(TabContent.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContent.UIListLayout.AbsoluteContentSize.Y + 16)
        end)
        if FirstTab then
            FirstTab = false
            CurrentTab = TabButton
            TabButton.BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Main
            TabButton.TextLabel.TextColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Text
        end
        TabButton.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second
                CurrentTab.TextLabel.TextColor3 = MarVLib.Themes[MarVLib.SelectedTheme].TextDark
                for _, Content in pairs(MainFrame:GetChildren()) do
                    if Content:IsA("ScrollingFrame") and Content.Name == CurrentTab.Name then
                        Content.Visible = false
                    end
                end
            end
            CurrentTab = TabButton
            TabButton.BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Main
            TabButton.TextLabel.TextColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Text
            TabContent.Visible = true
        end)
        table.insert(TabButtons, TabButton)
        TabButton.Parent = TabHolder
        TabContent.Parent = MainFrame
        
        local function AddSection(SectionConfig)
            local SectionFrame = SetChildren(SetProps(MakeElement("RoundFrame", MarVLib.Themes[MarVLib.SelectedTheme].Second, 0, 5), {
                Size = UDim2.new(1, -10, 0, 30),
                BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
                Name = SectionConfig.Name
            }), {
                AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                }), "Text"),
                AddThemeObject(MakeElement("Stroke"), "Stroke")
            })
            AddThemeObject(SectionFrame, "Second")
            SectionFrame.Parent = TabContent
            local Section = {}
            
            function Section:AddButton(ButtonConfig)
                local ButtonFrame = SetChildren(SetProps(MakeElement("RoundFrame", MarVLib.Themes[MarVLib.SelectedTheme].Second, 0, 5), {
                    Size = UDim2.new(1, -10, 0, 35),
                    BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 14), {
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Left
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                })
                AddThemeObject(ButtonFrame, "Second")
                local ButtonClick = AddThemeObject(SetProps(MakeElement("Button"), {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Name = "Button"
                }), "Text")
                ButtonClick.Parent = ButtonFrame
                ButtonFrame.Parent = TabContent
                ButtonClick.MouseButton1Click:Connect(ButtonConfig.Callback)
                AddConnection(ButtonClick.MouseEnter, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(MarVLib.Themes[MarVLib.SelectedTheme].Second.R * 255 + 3, MarVLib.Themes[MarVLib.SelectedTheme].Second.G * 255 + 3, MarVLib.Themes[MarVLib.SelectedTheme].Second.B * 255 + 3)
                    }):Play()
                end)
                AddConnection(ButtonClick.MouseLeave, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second
                    }):Play()
                end)
                return ButtonClick
            end
            
            function Section:AddToggle(ToggleConfig)
                local Toggle = {}
                Toggle.Type = "Toggle"
                Toggle.Value = ToggleConfig.Default or false
                Toggle.Save = ToggleConfig.Save or true
                local Click = AddThemeObject(SetProps(MakeElement("Button"), {
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(1, -35, 0.5, -15),
                    BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
                    Name = "Toggle"
                }), "Second")
                local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", Toggle.Value and ToggleConfig.Color or MarVLib.Themes.Default.Divider, 0, 5), {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = Toggle.Value and ToggleConfig.Color or MarVLib.Themes.Default.Divider,
                    Name = "ToggleBox"
                }), {
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
                        Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        Name = "Ico"
                    })
                })
                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = TabContent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    ToggleBox,
                    Click
                }), "Second")
                function Toggle:Set(Value)
                    Toggle.Value = Value
                    TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Toggle.Value and ToggleConfig.Color or MarVLib.Themes.Default.Divider
                    }):Play()
                    TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Color = Toggle.Value and ToggleConfig.Color or MarVLib.Themes.Default.Stroke
                    }):Play()
                    TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ImageTransparency = Toggle.Value and 0 or 1,
                        Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)
                    }):Play()
                    ToggleConfig.Callback(Toggle.Value)
                end
                Toggle:Set(Toggle.Value)
                AddConnection(Click.MouseEnter, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(MarVLib.Themes[MarVLib.SelectedTheme].Second.R * 255 + 3, MarVLib.Themes[MarVLib.SelectedTheme].Second.G * 255 + 3, MarVLib.Themes[MarVLib.SelectedTheme].Second.B * 255 + 3)
                    }):Play()
                end)
                AddConnection(Click.MouseLeave, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second
                    }):Play()
                end)
                Click.MouseButton1Click:Connect(function()
                    Toggle:Set(not Toggle.Value)
                end)
                MarVLib.Flags[ToggleConfig.Name] = Toggle
                return Toggle
            end
            
            function Section:AddSlider(SliderConfig)
                local Slider = {}
                Slider.Type = "Slider"
                Slider.Value = SliderConfig.Default or 0
                Slider.Save = SliderConfig.Save or true
                local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 55),
                    Parent = TabContent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 14), {
                        Position = UDim2.new(0, 12, 0, 5),
                        Size = UDim2.new(1, -24, 0, 20),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "Label"
                    }), "Text"),
                    AddThemeObject(SetProps(MakeElement("Label", tostring(Slider.Value), 14), {
                        Position = UDim2.new(1, -40, 0, 5),
                        Size = UDim2.new(0, 30, 0, 20),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Name = "ValueLabel"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                local SliderBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", MarVLib.Themes[MarVLib.SelectedTheme].Divider, 0, 10), {
                    Position = UDim2.new(0, 12, 0, 32),
                    Size = UDim2.new(1, -54, 0, 6),
                    BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Divider
                }), {
                    SetProps(MakeElement("RoundFrame", SliderConfig.Color or Color3.fromRGB(70, 70, 255), 0, 10), {
                        Name = "Fill",
                        Size = UDim2.new((Slider.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0)
                    })
                }), "Divider")
                local SliderButton = AddThemeObject(SetProps(MakeElement("Button"), {
                    Size = UDim2.new(0, 15, 0, 15),
                    Position = UDim2.new((Slider.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), -7.5, 0, -4.5),
                    BackgroundColor3 = SliderConfig.Color or Color3.fromRGB(70, 70, 255),
                    Name = "SliderButton"
                }), "Text")
                SliderButton.Parent = SliderBar
                local Dragging = false
                SliderButton.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                    end
                end)
                SliderButton.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        local MousePos = UserInputService:GetMouseLocation()
                        local SliderPos = SliderBar.AbsolutePosition.X
                        local SliderSize = SliderBar.AbsoluteSize.X
                        local Percent = (MousePos.X - SliderPos) / SliderSize
                        Percent = math.clamp(Percent, 0, 1)
                        local Value = SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * Percent
                        Value = Round(Value, SliderConfig.Increment or 1)
                        Slider:Set(Value)
                    end
                end)
                function Slider:Set(Value)
                    Slider.Value = Value
                    local Percent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    SliderBar.Fill.Size = UDim2.new(Percent, 0, 1, 0)
                    SliderButton.Position = UDim2.new(Percent, -7.5, 0, -4.5)
                    SliderFrame.ValueLabel.Text = tostring(Value)
                    SliderConfig.Callback(Value)
                end
                Slider:Set(Slider.Value)
                MarVLib.Flags[SliderConfig.Name] = Slider
                return Slider
            end
            
            function Section:AddDropdown(DropdownConfig)
                local Dropdown = {}
                Dropdown.Type = "Dropdown"
                Dropdown.Value = DropdownConfig.Default or DropdownConfig.Options[1]
                Dropdown.Save = DropdownConfig.Save or true
                local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = TabContent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 14), {
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "Label"
                    }), "Text"),
                    AddThemeObject(SetProps(MakeElement("Button"), {
                        Size = UDim2.new(0, 30, 0, 30),
                        Position = UDim2.new(1, -40, 0.5, -15),
                        BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
                        Name = "DropdownButton"
                    }), "Second"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                local DropdownList = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 40),
                    BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
                    Visible = false,
                    Name = "DropdownList"
                }), {
                    MakeElement("List"),
                    MakeElement("Padding", 4, 0, 0, 4)
                }), "Second")
                DropdownList.Parent = DropdownFrame
                local DropdownButton = DropdownFrame.DropdownButton
                local DropdownValue = AddThemeObject(SetProps(MakeElement("Label", Dropdown.Value, 14), {
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                }), "Text")
                DropdownValue.Parent = DropdownButton
                local function UpdateList()
                    for _, v in pairs(DropdownList:GetChildren()) do
                        if v:IsA("TextButton") then
                            v:Destroy()
                        end
                    end
                    for i, Option in ipairs(DropdownConfig.Options) do
                        local OptionButton = SetChildren(SetProps(MakeElement("RoundFrame", MarVLib.Themes[MarVLib.SelectedTheme].Second, 0, 5), {
                            Size = UDim2.new(1, -8, 0, 30),
                            BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
                            Name = "OptionButton"
                        }), {
                            AddThemeObject(SetProps(MakeElement("Label", Option, 14), {
                                Position = UDim2.new(0, 10, 0, 0),
                                Size = UDim2.new(1, -20, 1, 0),
                                TextXAlignment = Enum.TextXAlignment.Left
                            }), "Text"),
                            AddThemeObject(MakeElement("Stroke"), "Stroke")
                        })
                        AddThemeObject(OptionButton, "Second")
                        OptionButton.Parent = DropdownList
                        local ButtonClick = AddThemeObject(SetProps(MakeElement("Button"), {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1
                        }), "Text")
                        ButtonClick.Parent = OptionButton
                        ButtonClick.MouseButton1Click:Connect(function()
                            DropdownValue.Text = Option
                            Dropdown.Value = Option
                            DropdownList.Visible = false
                            DropdownConfig.Callback(Option, i)
                        end)
                    end
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, #DropdownConfig.Options * 35 + 16)
                end
                UpdateList()
                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownList.Visible = not DropdownList.Visible
                end)
                MarVLib.Flags[DropdownConfig.Name] = Dropdown
                return Dropdown
            end
            
            function Section:AddKeybind(KeybindConfig)
                local Keybind = {}
                Keybind.Type = "Keybind"
                Keybind.Value = KeybindConfig.Default or Enum.KeyCode.Unknown
                Keybind.Save = KeybindConfig.Save or true
                local KeybindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = TabContent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", KeybindConfig.Name, 14), {
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "Label"
                    }), "Text"),
                    AddThemeObject(SetProps(MakeElement("Button"), {
                        Size = UDim2.new(0, 80, 0, 30),
                        Position = UDim2.new(1, -90, 0.5, -15),
                        BackgroundColor3 = MarVLib.Themes[MarVLib.SelectedTheme].Second,
                        Name = "KeybindButton"
                    }), "Second"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                local KeybindButton = KeybindFrame.KeybindButton
                local KeybindLabel = AddThemeObject(SetProps(MakeElement("Label", Keybind.Value.Name, 14), {
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Center
                }), "Text")
                KeybindLabel.Parent = KeybindButton
                local Listening = false
                local function SetKeybind(Key)
                    Keybind.Value = Key
                    KeybindLabel.Text = Key.Name
                    KeybindConfig.Callback(Key)
                end
                KeybindButton.MouseButton1Click:Connect(function()
                    if Listening then return end
                    Listening = true
                    KeybindLabel.Text = "..."
                    local Connection
                    Connection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                        if GameProcessed then return end
                        if Input.KeyCode ~= Enum.KeyCode.Unknown then
                            SetKeybind(Input.KeyCode)
                            Listening = false
                            Connection:Disconnect()
                        end
                    end)
                end)
                MarVLib.Flags[KeybindConfig.Name] = Keybind
                return Keybind
            end
            
            function Section:AddColorpicker(ColorpickerConfig)
                local Colorpicker = {}
                Colorpicker.Type = "Colorpicker"
                Colorpicker.Value = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
                Colorpicker.Save = ColorpickerConfig.Save or true
                local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = TabContent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 14), {
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "Label"
                    }), "Text"),
                    AddThemeObject(SetProps(MakeElement("Button"), {
                        Size = UDim2.new(0, 30, 0, 30),
                        Position = UDim2.new(1, -40, 0.5, -15),
                        BackgroundColor3 = Colorpicker.Value,
                        Name = "ColorButton"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                local ColorButton = ColorpickerFrame.ColorButton
                local function UpdateColor(Color)
                    Colorpicker.Value = Color
                    ColorButton.BackgroundColor3 = Color
                    ColorpickerConfig.Callback(Color)
                end
                ColorButton.MouseButton1Click:Connect(function()
                    -- Simplified color picker (you can expand)
                    local NewColor = Color3.fromHSV(math.random(), 1, 1)
                    UpdateColor(NewColor)
                end)
                MarVLib.Flags[ColorpickerConfig.Name] = Colorpicker
                return Colorpicker
            end
            
            return Section
        end
        
        Tab.AddSection = AddSection
        return Tab
    end
    
    function Window:Toggle()
        MainFrame.Visible = not MainFrame.Visible
    end
    
    function Window:Destroy()
        MarV:Destroy()
    end
    
    CloseBtn.MouseButton1Click:Connect(function()
        WindowConfig.CloseCallback()
        Window:Destroy()
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 500, 0, 30)
            }):Play()
            TweenService:Create(MinimizeBtn.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Image = "rbxassetid://7072725342"
            }):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 500, 0, 400)
            }):Play()
            TweenService:Create(MinimizeBtn.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Image = "rbxassetid://7072719338"
            }):Play()
        end
    end)
    
    return Window
end

return MarVLib