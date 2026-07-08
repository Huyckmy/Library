local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local bearlib = {
    Theme = {
        ["Color Hub 1"] = Color3.fromRGB(0, 0, 0),
        ["Color Hub 2"] = Color3.fromRGB(15, 15, 15),
        ["Color Hub 3"] = Color3.fromRGB(255, 255, 255),
        ["Color Background Main"] = Color3.fromRGB(0, 0, 0),
        ["Color Stroke"] = Color3.fromRGB(0, 0, 0),
        ["Color Theme"] = Color3.fromRGB(255, 255, 255),
        ["Color Text"] = Color3.fromRGB(255, 255, 255),
        ["Color Dark Text"] = Color3.fromRGB(170, 170, 170),
        ["Color Discord Text"] = Color3.fromRGB(255, 255, 255),
        ["Color Discord Stats"] = Color3.fromRGB(255, 255, 255),
        ["Color Discord Border"] = Color3.fromRGB(255, 255, 255),
        ["Color Profile Border"] = Color3.fromRGB(255, 255, 255),
        ["Color Toggle On"] = Color3.fromRGB(255, 255, 0),
        ["Color Toggle Off"] = Color3.fromRGB(0, 0, 0),
        ["Color Toggle Knob On"] = Color3.fromRGB(255, 255, 255),
        ["Color Toggle Knob Off"] = Color3.fromRGB(255, 255, 0),
        ["Color Toggle Border"] = Color3.fromRGB(255, 255, 255),
        ["Border Thickness"] = 1.5,
        ["UI Border Color"] = Color3.fromRGB(255, 255, 255),
        ["Corner Radius"] = 12,
        ["ShowVNFlag"] = false,
    },
    Info = {
        Name = "Bear Library",
        By = "Quang Huy",
        Version = "1.2.0"
    },
    Save = {
        UISize = {550, 380},
        TabSize = 160,
        BarPosition = {X = 350, Y = -65}
    },
    Settings = {},
    Connection = {},
    Instances = {},
    Elements = {},
    Options = {},
    Flags = {},
    Tabs = {},
    TabGroups = {},
    Icons = (function()
        return {}
    end)(),
    AllElements = {},
    ThunderActive = false
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450

local Settings = bearlib.Settings
local Flags = bearlib.Flags

local SetProps, SetChildren, InsertTheme, Create do
    InsertTheme = function(Instance, Type)
        table.insert(bearlib.Instances, {
            Instance = Instance,
            Type = Type
        })
        return Instance
    end

    SetChildren = function(Instance, Children)
        if Children then
            table.foreach(Children, function(_, Child)
                Child.Parent = Instance
            end)
        end
        return Instance
    end

    SetProps = function(Instance, Props)
        if Props then
            table.foreach(Props, function(prop, value)
                Instance[prop] = value
            end)
        end
        return Instance
    end

    Create = function(...)
        local args = {...}
        if type(args) ~= "table" then return end
        local new = Instance.new(args[1])
        local Children = {}

        if type(args[2]) == "table" then
            SetProps(new, args[2])
            SetChildren(new, args[3])
            Children = args[3] or {}
        elseif typeof(args[2]) == "Instance" then
            new.Parent = args[2]
            SetProps(new, args[3])
            SetChildren(new, args[4])
            Children = args[4] or {}
        end
        return new
    end

    local function Save(file)
        if readfile and isfile and isfile(file) then
            local decode = HttpService:JSONDecode(readfile(file))

            if type(decode) == "table" then
                if rawget(decode, "UISize") then bearlib.Save["UISize"] = decode["UISize"] end
                if rawget(decode, "TabSize") then bearlib.Save["TabSize"] = decode["TabSize"] end
                if rawget(decode, "BarPosition") then
                    bearlib.Save["BarPosition"] = decode["BarPosition"]
                end
            end
        end
    end

    pcall(Save, "bearlib.json")
end

local Funcs = {} do
    function Funcs:InsertCallback(tab, func)
        if type(func) == "function" then
            table.insert(tab, func)
        end
        return func
    end

    function Funcs:FireCallback(tab, ...)
        for _, v in ipairs(tab) do
            if type(v) == "function" then
                task.spawn(v, ...)
            end
        end
    end

    function Funcs:ToggleVisible(Obj, Bool)
        Obj.Visible = Bool ~= nil and Bool or not Obj.Visible
    end

    function Funcs:GetConnectionFunctions(ConnectedFuncs, func)
        local Connected = {Function = func, Connected = true}

        function Connected:Disconnect()
            if self.Connected then
                table.remove(ConnectedFuncs, table.find(ConnectedFuncs, self.Function))
                self.Connected = false
            end
        end

        function Connected:Fire(...)
            if self.Connected then
                task.spawn(self.Function, ...)
            end
        end

        return Connected
    end

    function Funcs:GetCallback(Configs, index)
        local func = Configs[index] or Configs.Callback or function() end

        if type(func) == "table" then
            return ({function(Value) func[1][func[2]] = Value end})
        end
        return {func}
    end
end

local Connections, Connection = {}, bearlib.Connection do
    local function NewConnectionList(List)
        if type(List) ~= "table" then return end

        for _, CoName in ipairs(List) do
            local ConnectedFuncs, Connect = {}, {}
            Connection[CoName] = Connect
            Connections[CoName] = ConnectedFuncs
            Connect.Name = CoName

            function Connect:Connect(func)
                if type(func) == "function" then
                    table.insert(ConnectedFuncs, func)
                    return Funcs:GetConnectionFunctions(ConnectedFuncs, func)
                end
            end

            function Connect:Once(func)
                if type(func) == "function" then
                    local Connected;

                    local _NFunc; _NFunc = function(...)
                        task.spawn(func, ...)
                        Connected:Disconnect()
                    end

                    Connected = Funcs:GetConnectionFunctions(ConnectedFuncs, _NFunc)
                    return Connected
                end
            end
        end
    end

    function Connection:FireConnection(CoName, ...)
        local Connection = type(CoName) == "string" and Connections[CoName] or Connections[CoName.Name]
        for _, Func in pairs(Connection) do
            task.spawn(Func, ...)
        end
    end

    NewConnectionList({"FlagsChanged", "FileSaved", "OptionAdded"})
end

local GetFlag, SetFlag, CheckFlag do
    CheckFlag = function(Name)
        return type(Name) == "string" and Flags[Name] ~= nil
    end

    GetFlag = function(Name)
        return type(Name) == "string" and Flags[Name]
    end

    SetFlag = function(Flag, Value)
        if Flag and (Value ~= Flags[Flag] or type(Value) == "table") then
            Flags[Flag] = Value
            Connection:FireConnection("FlagsChanged", Flag, Value)
        end
    end

    local db
    Connection.FlagsChanged:Connect(function(Flag, Value)
        local ScriptFile = Settings.ScriptFile
        if not db and ScriptFile and writefile then
            db = true;
            task.wait(0.1);
            db = false

            local Success, Encoded = pcall(function()
                return HttpService:JSONEncode(Flags)
            end)

            if Success then
                local Success = pcall(writefile, ScriptFile, Encoded)
                if Success then
                    Connection:FireConnection("FileSaved", "Script-Flags", ScriptFile, Encoded)
                end
            end
        end
    end)
end

local ScreenGui = Create("ScreenGui", CoreGui, {
    Name = "bearlib",
}, {
    Create("UIScale", {
        Scale = UIScale,
        Name = "Scale"
    })
})

local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then
    ScreenFind:Destroy()
end

local Theme = bearlib.Theme

local function GetStr(val)
    if type(val) == "function" then
        return val()
    end
    return val
end

local function CreateTween(Configs)
    local Instance = Configs[1] or Configs.Instance
    local Prop = Configs[2] or Configs.Prop
    local NewVal = Configs[3] or Configs.NewVal
    local Time = Configs[4] or Configs.Time or 0.5
    local TweenWait = Configs[5] or Configs.wait or false
    local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quint)

    local Tween = TweenService:Create(Instance, TweenInfo, {[Prop] = NewVal})
    Tween:Play()
    if TweenWait then
        Tween.Completed:Wait()
    end
    return Tween
end

local function MakeDrag(Instance)
    task.spawn(function()
        SetProps(Instance, {
            Active = true,
            AutoButtonColor = false
        })

        local DragStart, StartPos, InputOn

        local function Update(Input)
            local delta = Input.Position - DragStart
            local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X / UIScale, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y / UIScale)
            CreateTween({Instance, "Position", Position, 0.35})
        end

        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                InputOn = true
                StartPos = Instance.Position
                DragStart = Input.Position
            end
        end)

        Instance.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                InputOn = false
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if InputOn and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                Update(Input)
            end
        end)
    end)
    return Instance
end

local function MakeDragSmooth(Instance, onDrag)
    task.spawn(function()
        SetProps(Instance, {
            Active = true,
            AutoButtonColor = false
        })

        local DragStart, StartPos, InputOn

        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                InputOn = true
                StartPos = Instance.Position
                DragStart = Input.Position
            end
        end)

        Instance.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                InputOn = false
                if onDrag then
                    onDrag(true)
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if InputOn and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local delta = Input.Position - DragStart
                if onDrag then
                    onDrag(false, delta, StartPos)
                end
            end
        end)
    end)
    return Instance
end

local function SaveJson(FileName, save)
    if writefile then
        local json = HttpService:JSONEncode(save)
        writefile(FileName, json)
    end
end

local function AddEle(Name, Func)
    bearlib.Elements[Name] = Func
end

local function Make(Ele, Instance, props, ...)
    local Element = bearlib.Elements[Ele](Instance, props, ...)
    return Element
end

AddEle("Corner", function(parent, CornerRadius)
    local New = SetProps(Create("UICorner", parent, {
        CornerRadius = CornerRadius or UDim.new(0, 7)
    }))
    return New
end)

AddEle("Stroke", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("UIStroke", parent, {
        Color = args[1] or Theme["Color Stroke"],
        Thickness = args[2] or 1,
        ApplyStrokeMode = "Border"
    }), props), "Stroke")
    return New
end)

AddEle("Button", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("TextButton", parent, {
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme["Color Hub 2"],
        AutoButtonColor = false
    }), props), "Frame")

    New.MouseEnter:Connect(function()
        New.BackgroundTransparency = 0.4
    end)
    New.MouseLeave:Connect(function()
        New.BackgroundTransparency = 0
    end)
    if args[1] then
        New.Activated:Connect(args[1])
    end
    return New
end)

AddEle("Gradient", function(parent, props, ...)
    local args = {...}
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(Theme["Color Hub 1"])
    gradient.Rotation = args[1] or 45
    gradient.Parent = parent
    return InsertTheme(gradient, "Gradient")
end)

local function ButtonFrame(Instance, Title, Description, HolderSize)
    local TitleL = InsertTheme(Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme["Color Text"],
        Size = UDim2.new(1, -20),
        AutomaticSize = "Y",
        Position = UDim2.new(0, 0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        TextTruncate = "AtEnd",
        TextSize = 10,
        TextXAlignment = "Left",
        Text = "",
        RichText = true,
        ZIndex = 5
    }), "Text")

    local DescL = InsertTheme(Create("TextLabel", {
        Font = Enum.Font.Gotham,
        TextColor3 = Theme["Color Dark Text"],
        Size = UDim2.new(1, -20),
        AutomaticSize = "Y",
        Position = UDim2.new(0, 12, 0, 15),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextSize = 8,
        TextXAlignment = "Left",
        Text = "",
        RichText = true,
        ZIndex = 5
    }), "DarkText")

    local Frame = Make("Button", Instance, {
        Size = UDim2.new(1, 0, 0, 25),
        AutomaticSize = "Y",
        Name = "Option"
    })
    Make("Corner", Frame, UDim.new(0, 6))

    Make("Stroke", Frame, nil, Theme["Color Stroke"], 1)

    local LabelHolder = Create("Frame", Frame, {
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Size = HolderSize,
        Position = UDim2.new(0, 10, 0),
        AnchorPoint = Vector2.new(0, 0),
        ZIndex = 4
    }, {
        Create("UIListLayout", {
            SortOrder = "LayoutOrder",
            VerticalAlignment = "Center",
            Padding = UDim.new(0, 2)
        }),
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5)
        }),
        TitleL,
        DescL,
    })

    local Label = {}
    function Label:SetTitle(NewTitle)
        if type(NewTitle) == "string" and NewTitle:gsub(" ", ""):len() > 0 then
            TitleL.Text = NewTitle
        end
    end
    function Label:SetDesc(NewDesc)
        if type(NewDesc) == "string" and NewDesc:gsub(" ", ""):len() > 0 then
            DescL.Visible = true
            DescL.Text = NewDesc
            LabelHolder.Position = UDim2.new(0, 10, 0)
            LabelHolder.AnchorPoint = Vector2.new(0, 0)
        else
            DescL.Visible = false
            DescL.Text = ""
            LabelHolder.Position = UDim2.new(0, 10, 0.5)
            LabelHolder.AnchorPoint = Vector2.new(0, 0.5)
        end
    end

    Label:SetTitle(Title)
    Label:SetDesc(Description)
    return Frame, Label
end

function bearlib:GetIcon(index)
    if type(index) ~= "string" or index:find("rbxassetid://") or #index == 0 then
        return index
    end

    local firstMatch = nil
    index = string.lower(index):gsub("lucide", ""):gsub("-", "")

    if self.Icons[index] then
        return self.Icons[index]
    end

    for Name, Icon in self.Icons do
        if Name == index then
            return Icon
        elseif not firstMatch and Name:find(index, 1, true) then
            firstMatch = Icon
        end
    end

    return firstMatch or index
end

local MainFrame = nil
local MinimizeButton = nil
local ToggleButton = nil
local ToggleGui = nil
local MinimizedBar = nil
local NotificationHolder = nil
local MaximizeButton = nil
local SettingsButton = nil
local IsMaximized = false
local OriginalUISize = nil
local SmallBar = nil
local SmallBarText = nil
local SmallBarStroke = nil
local SmallBar2 = nil
local SmallBar2Text = nil
local SmallBar2Stroke = nil
local SmallBar3 = nil
local SmallBar3Text = nil
local SmallBar3Stroke = nil
local SmallBar4 = nil
local SmallBar4Text = nil
local SmallBar4Stroke = nil
local SmallBar5 = nil
local SmallBar5Text = nil
local SmallBar5Stroke = nil
local DividerLine = nil
local SmallBarIcon = nil
local SmallBar2Icon = nil
local SmallBar3Icon = nil
local SmallBar4Icon = nil
local SmallBar5Icon = nil
local SmallBarPadding = 4

local function ApplyRoundedCorners(frame, radius)
    if not frame then return end
    local corner = frame:FindFirstChildWhichIsA("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.Parent = frame
    end
    corner.CornerRadius = radius or UDim.new(0, Theme["Corner Radius"] or 12)
    return corner
end

local function UpdateBarLayout(bar, barText, barIcon)
    if not barText or not bar then return end

    local hasIcon = barIcon and barIcon.Visible

    if hasIcon then
        barText.AnchorPoint = Vector2.new(0, 0.5)
        local iconRightEdge = barIcon.Position.X.Offset + barIcon.AbsoluteSize.X
        barText.Position = UDim2.new(0, iconRightEdge + SmallBarPadding, 0.5, 0)
        barText.TextXAlignment = Enum.TextXAlignment.Left

        local iconWidth = barIcon.AbsoluteSize.X
        local textWidth = barText.TextBounds.X
        local totalWidth = barIcon.Position.X.Offset + iconWidth + SmallBarPadding + textWidth + 14
        bar.Size = UDim2.new(0, totalWidth, 0, 14)
    else
        barText.AnchorPoint = Vector2.new(0.5, 0.5)
        barText.Position = UDim2.new(0.5, 0, 0.5, 0)
        barText.TextXAlignment = Enum.TextXAlignment.Center

        local textWidth = barText.TextBounds.X
        bar.Size = UDim2.new(0, textWidth + 16, 0, 14)
    end
end

local function UpdateSmallBarSize()
    UpdateBarLayout(SmallBar, SmallBarText, SmallBarIcon)
end

local function UpdateSmallBar2Size()
    UpdateBarLayout(SmallBar2, SmallBar2Text, SmallBar2Icon)
end

local function UpdateSmallBar3Size()
    UpdateBarLayout(SmallBar3, SmallBar3Text, SmallBar3Icon)
end

local function UpdateSmallBar4Size()
    UpdateBarLayout(SmallBar4, SmallBar4Text, SmallBar4Icon)
end

local function UpdateSmallBar5Size()
    UpdateBarLayout(SmallBar5, SmallBar5Text, SmallBar5Icon)
end

local function RefreshAllUIElements()
    if MainFrame then
        MainFrame.BackgroundColor3 = Theme["Color Background Main"] or Theme["Color Hub 1"] or Color3.fromRGB(0, 0, 0)
        ApplyRoundedCorners(MainFrame, UDim.new(0, Theme["Corner Radius"] or 12))
        local border = MainFrame:FindFirstChild("UIBorder")
        if border and border:IsA("UIStroke") then
            border.Color = Theme["UI Border Color"]
            border.Thickness = Theme["Border Thickness"]
        end
        local gradient = MainFrame:FindFirstChildOfClass("UIGradient")
        if gradient then
            gradient.Color = ColorSequence.new(Theme["Color Hub 1"])
        end
    end

    for _, Val in pairs(bearlib.Instances) do
        if not Val.Instance or not Val.Instance.Parent then continue end

        if Val.Type == "Gradient" then
            Val.Instance.Color = ColorSequence.new(Theme["Color Hub 1"])
        elseif Val.Type == "Frame" then
            Val.Instance.BackgroundColor3 = Theme["Color Hub 2"]
        elseif Val.Type == "Stroke" then
            local parent = Val.Instance.Parent
            local strokeColor = Theme["Color Stroke"]
            if parent then
                if parent:FindFirstAncestor("DiscordInviteContainer") or 
                   parent.Name:find("DiscordCard") or
                   parent:FindFirstAncestor("DiscordCard") then
                    strokeColor = Theme["Color Discord Border"]
                elseif parent:FindFirstAncestor("Profile") then
                    strokeColor = Theme["Color Profile Border"]
                elseif parent.Name == "Hub" then
                    strokeColor = Theme["UI Border Color"]
                end
            end
            Val.Instance.Color = strokeColor
            Val.Instance.Thickness = Theme["Border Thickness"]
        elseif Val.Type == "Theme" then
            Val.Instance.BackgroundColor3 = Theme["Color Theme"]
        elseif Val.Type == "Text" then
            Val.Instance.TextColor3 = Theme["Color Text"]
        elseif Val.Type == "DarkText" then
            Val.Instance.TextColor3 = Theme["Color Dark Text"]
        elseif Val.Type == "ScrollBar" then
            Val.Instance.ScrollBarImageColor3 = Theme["Color Theme"]
        elseif Val.Type == "UIBorder" then
            Val.Instance.Color = Theme["UI Border Color"]
            Val.Instance.Thickness = Theme["Border Thickness"]
        elseif Val.Type == "TabBorderGradient" then
            local themeColor = Theme["Color Hub 3"]
            Val.Instance.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, themeColor),
                ColorSequenceKeypoint.new(0.5, themeColor),
                ColorSequenceKeypoint.new(1, themeColor),
            })
            Val.Instance.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.3, 0.5),
                NumberSequenceKeypoint.new(1, 0),
            })
        elseif Val.Type == "TabBorderFrame" then
            Val.Instance.Color = Theme["Color Hub 3"]
        elseif Val.Type == "TabGroupArrow" then
            Val.Instance.TextColor3 = Theme["Color Text"]
        elseif Val.Type == "Divider" then
            Val.Instance.BackgroundColor3 = Theme["Color Theme"]
            Val.Instance.BackgroundTransparency = 0.8
            if Val.Instance:FindFirstChild("UIGradient") then
                local gradient = Val.Instance.UIGradient
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Theme["Color Theme"]),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
            end
        end
    end

    if MinimizeButton then
        MinimizeButton.ImageColor3 = Theme["Color Text"]
    end
    if MaximizeButton then
        MaximizeButton.ImageColor3 = Theme["Color Text"]
    end
    if SettingsButton then
        SettingsButton.ImageColor3 = Theme["Color Text"]
    end

    if MinimizedBar then
        ApplyRoundedCorners(MinimizedBar, UDim.new(1, 0))
        for _, child in ipairs(MinimizedBar:GetChildren()) do
            if child:IsA("ImageLabel") then
                child.ImageColor3 = Theme["Color Text"]
            elseif child:IsA("TextLabel") then
                child.TextColor3 = Theme["Color Text"]
            elseif child:IsA("UIStroke") then
                child.Color = Theme["UI Border Color"]
                child.Thickness = Theme["Border Thickness"]
            elseif child:IsA("ImageButton") then
                child.ImageColor3 = Theme["Color Text"]
            end
        end
        local gradient = MinimizedBar:FindFirstChildOfClass("UIGradient")
        if gradient then
            gradient.Color = ColorSequence.new(Theme["Color Hub 1"])
        end
    end

    if NotificationHolder then
        for _, notif in ipairs(NotificationHolder:GetChildren()) do
            if notif:IsA("Frame") and notif.Name == "Notification" then
                local stroke = notif:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = Theme["Color Stroke"]
                end
                local gradient = notif:FindFirstChildOfClass("UIGradient")
                if gradient then
                    gradient.Color = ColorSequence.new(Theme["Color Hub 1"])
                end
                ApplyRoundedCorners(notif, UDim.new(0, 8))
            end
        end
    end

    for _, TabData in pairs(bearlib.Tabs) do
        if TabData and TabData.BorderStroke then
            TabData.BorderStroke.Color = Theme["Color Hub 3"]
            TabData.BorderStroke.Thickness = Theme["Border Thickness"]
        end
        if TabData and TabData.BorderGradient then
            local themeColor = Theme["Color Hub 3"]
            TabData.BorderGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, themeColor),
                ColorSequenceKeypoint.new(0.5, themeColor),
                ColorSequenceKeypoint.new(1, themeColor),
            })
            TabData.BorderGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.3, 0.5),
                NumberSequenceKeypoint.new(1, 0),
            })
        end
    end

    for _, element in pairs(bearlib.AllElements) do
        if element and element.Instance and element.Instance.Parent then
            if element.Instance:IsA("TextButton") or element.Instance:IsA("Frame") then
                element.Instance.BackgroundColor3 = Theme["Color Hub 2"]
            end

            local stroke = element.Instance:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = Theme["Color Stroke"]
                stroke.Thickness = Theme["Border Thickness"]
            end

            for _, child in ipairs(element.Instance:GetDescendants()) do
                if child:IsA("TextLabel") then
                    if child.Name ~= "TimerText" then
                        child.TextColor3 = Theme["Color Text"]
                    end
                elseif child:IsA("TextBox") then
                    child.TextColor3 = Theme["Color Text"]
                end
            end
        end
    end

    for _, GroupData in pairs(bearlib.TabGroups) do
        if GroupData and GroupData.TabSelect then
            local textLabel = GroupData.TabSelect:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.TextColor3 = Theme["Color Text"]
            end
            local imageLabel = GroupData.TabSelect:FindFirstChildOfClass("ImageLabel")
            if imageLabel then
                imageLabel.ImageColor3 = Theme["Color Text"]
            end
            local arrow = GroupData.TabSelect:FindFirstChild("Arrow")
            if arrow and arrow:IsA("TextLabel") then
                arrow.TextColor3 = Theme["Color Text"]
            end
        end
    end

    if MainScroll then
        MainScroll.ScrollBarImageColor3 = Theme["Color Theme"]
    end
end

local MainScroll = nil

function bearlib:SetScale(NewScale)
    NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
    UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end

local Minimized = false
local UIFullVisible = true
local SaveSize = nil
local BarPosition = bearlib.Save.BarPosition
local WaitClick = false
local bgTransparency = 0.03

local function SaveBarPosition()
    if MinimizedBar and MinimizedBar.Parent then
        bearlib.Save.BarPosition = {
            X = MinimizedBar.Position.X.Offset,
            Y = MinimizedBar.Position.Y.Offset
        }
        BarPosition = bearlib.Save.BarPosition
        SaveJson("bearlib.json", bearlib.Save)
    end
end

function bearlib:MakeWindow(Configs)
    local WTitle = Configs[1] or Configs.Name or Configs.Title or "bearlib"
    local WMiniText = Configs[2] or Configs.SubTitle or "by : Quang Huy"

    Settings.ScriptFile = Configs[3] or Configs.SaveFolder or false

    local function LoadFile()
        local File = Settings.ScriptFile
        if type(File) ~= "string" then return end
        if not readfile or not isfile then return end
        local s, r = pcall(isfile, File)

        if s and r then
            local s, _Flags = pcall(readfile, File)

            if s and type(_Flags) == "string" then
                local s, r = pcall(function() return HttpService:JSONDecode(_Flags) end)
                Flags = s and r or {}
            end
        end
    end
    LoadFile()

    local UISizeX, UISizeY = unpack(bearlib.Save.UISize)
    OriginalUISize = {UISizeX, UISizeY}

    MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
        Size = UDim2.fromOffset(UISizeX, UISizeY),
        Position = UDim2.new(0.5, -UISizeX / 2, 0.5, -UISizeY / 2),
        BackgroundTransparency = bgTransparency,
        BackgroundColor3 = Theme["Color Background Main"] or Theme["Color Hub 1"] or Color3.fromRGB(0, 0, 0),
        Name = "Hub"
    }), "Main")
    Make("Gradient", MainFrame, 45)
    MakeDrag(MainFrame)

    local MainCorner = ApplyRoundedCorners(MainFrame, UDim.new(0, Theme["Corner Radius"] or 12))

    local UIBorder = Instance.new("UIStroke")
    UIBorder.Name = "UIBorder"
    UIBorder.Color = Theme["UI Border Color"] or Color3.fromRGB(255, 215, 0)
    UIBorder.Thickness = Theme["Border Thickness"] or 1.5
    UIBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIBorder.LineJoinMode = Enum.LineJoinMode.Round
    UIBorder.Parent = MainFrame

    InsertTheme(UIBorder, "UIBorder")

    local Components = Create("Folder", MainFrame, {
        Name = "Components"
    })

    local DropdownHolder = Create("Folder", ScreenGui, {
        Name = "Dropdown"
    })

    local TopBar = Create("Frame", Components, {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Name = "Top Bar"
    })

    local Title = InsertTheme(Create("TextLabel", TopBar, {
        Position = UDim2.new(0, 15, 0, 2),
        AnchorPoint = Vector2.new(0, 0),
        AutomaticSize = "XY",
        Text = WTitle,
        TextXAlignment = "Left",
        TextSize = 12,
        TextColor3 = Theme["Color Text"],
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Name = "Title"
    }), "Text")

    local SubTitle = InsertTheme(Create("TextLabel", TopBar, {
        Position = UDim2.new(0, 15, 0, 16),
        AnchorPoint = Vector2.new(0, 0),
        AutomaticSize = "XY",
        Text = WMiniText,
        TextXAlignment = "Left",
        TextSize = 9,
        TextColor3 = Theme["Color Dark Text"],
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Name = "SubTitle"
    }), "DarkText")

    local function CreateSmallBar(name, textName)
        local bar = Instance.new("Frame")
        bar.Name = name
        bar.Size = UDim2.new(0, 0, 0, 14)
        bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bar.BackgroundTransparency = 0
        bar.BorderSizePixel = 0
        bar.ClipsDescendants = false
        bar.Visible = false
        bar.Parent = TopBar

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar

        local barStroke = Instance.new("UIStroke")
        barStroke.Color = Color3.fromRGB(0, 255, 0)
        barStroke.Thickness = 1
        barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        barStroke.Parent = bar

        local barIcon = Instance.new("ImageLabel")
        barIcon.Name = "BarIcon"
        barIcon.Size = UDim2.new(0, 10, 0, 10)
        barIcon.Position = UDim2.new(0, 5, 0.5, 0)
        barIcon.AnchorPoint = Vector2.new(0, 0.5)
        barIcon.BackgroundTransparency = 1
        barIcon.Image = ""
        barIcon.Visible = false
        barIcon.Parent = bar

        local barText = Instance.new("TextLabel")
        barText.Name = textName
        barText.AnchorPoint = Vector2.new(0.5, 0.5)
        barText.Size = UDim2.new(1, -10, 1, -2)
        barText.Position = UDim2.new(0.5, 0, 0.5, 0)
        barText.BackgroundTransparency = 1
        barText.Font = Enum.Font.GothamBold
        barText.TextColor3 = Color3.fromRGB(0, 255, 0)
        barText.TextSize = 10
        barText.TextXAlignment = Enum.TextXAlignment.Center
        barText.TextYAlignment = Enum.TextYAlignment.Center
        barText.Text = ""
        barText.TextTruncate = Enum.TextTruncate.None
        barText.AutomaticSize = Enum.AutomaticSize.X
        barText.Parent = bar

        return bar, barText, barStroke, barIcon
    end

    SmallBar, SmallBarText, SmallBarStroke, SmallBarIcon = CreateSmallBar("SmallBar", "SmallBarText")
    SmallBar2, SmallBar2Text, SmallBar2Stroke, SmallBar2Icon = CreateSmallBar("SmallBar2", "SmallBar2Text")
    SmallBar3, SmallBar3Text, SmallBar3Stroke, SmallBar3Icon = CreateSmallBar("SmallBar3", "SmallBar3Text")
    SmallBar4, SmallBar4Text, SmallBar4Stroke, SmallBar4Icon = CreateSmallBar("SmallBar4", "SmallBar4Text")
    SmallBar5, SmallBar5Text, SmallBar5Stroke, SmallBar5Icon = CreateSmallBar("SmallBar5", "SmallBar5Text")

    local function UpdateAllBarPositions()
        if not Title or not Title.Parent then return end

        local titleEndX = Title.Position.X.Offset + Title.TextBounds.X
        local lastVisibleBar = nil

        local bars = {SmallBar, SmallBar2, SmallBar3, SmallBar4, SmallBar5}

        for i, bar in ipairs(bars) do
            if bar and bar.Visible then
                if lastVisibleBar then
                    local rightEdge = lastVisibleBar.Position.X.Offset + lastVisibleBar.Size.X.Offset
                    bar.Position = UDim2.new(0, rightEdge + 8, 0.5, -7)
                else
                    bar.Position = UDim2.new(0, titleEndX + 25, 0.5, -7)
                end
                lastVisibleBar = bar
            end
        end
    end

    local bars = {SmallBar, SmallBar2, SmallBar3, SmallBar4, SmallBar5}
    local barTexts = {SmallBarText, SmallBar2Text, SmallBar3Text, SmallBar4Text, SmallBar5Text}
    local barIcons = {SmallBarIcon, SmallBar2Icon, SmallBar3Icon, SmallBar4Icon, SmallBar5Icon}
    local updateFunctions = {UpdateSmallBarSize, UpdateSmallBar2Size, UpdateSmallBar3Size, UpdateSmallBar4Size, UpdateSmallBar5Size}

    for i, bar in ipairs(bars) do
        bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateAllBarPositions)
        bar:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateAllBarPositions)

        if barTexts[i] then
            barTexts[i]:GetPropertyChangedSignal("TextBounds"):Connect(function()
                task.wait()
                updateFunctions[i]()
                UpdateAllBarPositions()
            end)
            barTexts[i]:GetPropertyChangedSignal("Text"):Connect(function()
                task.wait()
                updateFunctions[i]()
                UpdateAllBarPositions()
            end)
        end

        if barIcons[i] then
            barIcons[i]:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                task.wait()
                updateFunctions[i]()
                UpdateAllBarPositions()
            end)
            barIcons[i]:GetPropertyChangedSignal("Visible"):Connect(function()
                task.wait()
                updateFunctions[i]()
                UpdateAllBarPositions()
            end)
        end
    end

    Title:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateAllBarPositions)
    Title:GetPropertyChangedSignal("TextBounds"):Connect(UpdateAllBarPositions)
    Title:GetPropertyChangedSignal("Text"):Connect(function()
        task.wait()
        UpdateAllBarPositions()
    end)

    MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
        Size = UDim2.new(0, bearlib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
        ScrollBarImageColor3 = Theme["Color Theme"],
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        ScrollBarThickness = 1.5,
        BackgroundTransparency = 1,
        ScrollBarImageTransparency = 0.2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        Name = "Tab Scroll"
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        }), Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = "LayoutOrder"
        })
    }), "ScrollBar")

    local Containers = Create("Frame", Components, {
        Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Name = "Containers"
    })

    DividerLine = Create("Frame", MainFrame, {
        Size = UDim2.new(0, 2, 1, -TopBar.Size.Y.Offset),
        Position = UDim2.new(0, MainScroll.Size.X.Offset - 1, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme["Color Theme"],
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Name = "DividerLine",
        ZIndex = 10
    })

    local dividerGradient = Instance.new("UIGradient")
    dividerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Theme["Color Theme"]),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    dividerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(0.7, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    dividerGradient.Rotation = 90
    dividerGradient.Name = "UIGradient"
    dividerGradient.Parent = DividerLine

    local dividerCorner = Instance.new("UICorner")
    dividerCorner.CornerRadius = UDim.new(0, 1)
    dividerCorner.Parent = DividerLine

    InsertTheme(DividerLine, "Divider")

    local ControlSize = Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 35, 0, 35),
        Position = MainFrame.Size,
        Active = true,
        AnchorPoint = Vector2.new(0.8, 0.8),
        BackgroundTransparency = 1,
        Name = "Control Hub Size",
        ZIndex = 100
    })
    MakeDragSmooth(ControlSize, function(finished, delta, startPos)
        if finished then
            if MainFrame.Visible then
                bearlib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
                OriginalUISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
                SaveJson("bearlib.json", bearlib.Save)
            end
        else
            local Pos = startPos
            local newX = math.clamp(Pos.X.Offset + (delta and delta.X or 0) / UIScale, 430, 1000)
            local newY = math.clamp(Pos.Y.Offset + (delta and delta.Y or 0) / UIScale, 200, 500)
            ControlSize.Position = UDim2.fromOffset(newX, newY)
            MainFrame.Size = ControlSize.Position
        end
    end)

    local ControlSize2 = Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 20, 1, -30),
        Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
        AnchorPoint = Vector2.new(0.5, 1),
        Active = true,
        BackgroundTransparency = 1,
        Name = "Control Tab Size",
        ZIndex = 100
    })
    MakeDragSmooth(ControlSize2, function(finished, delta, startPos)
        if not finished then
            local newTabX = math.clamp(startPos.X.Offset + (delta and delta.X or 0) / UIScale, 135, 250)
            ControlSize2.Position = UDim2.new(0, newTabX, 1, 0)

            MainScroll.Size = UDim2.new(0, newTabX, 1, -TopBar.Size.Y.Offset)
            Containers.Size = UDim2.new(1, -newTabX, 1, -TopBar.Size.Y.Offset)

            if DividerLine then
                DividerLine.Position = UDim2.new(0, newTabX - 1, 1, 0)
            end
        else
            bearlib.Save.TabSize = MainScroll.Size.X.Offset
            SaveJson("bearlib.json", bearlib.Save)
        end
    end)

    local ButtonsFolder = Create("Folder", TopBar, {
        Name = "Buttons"
    })

    local CloseButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10747384394",
        AutoButtonColor = false,
        Name = "Close"
    })

    MaximizeButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -35, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734886735",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "Maximize"
    })

    MinimizeButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -60, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734896206",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "Minimize"
    })

    SettingsButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -85, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734950309",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "Settings"
    })

    local InfoButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -110, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://73132811772878",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "InfoButton"
    })

    InfoButton.Activated:Connect(function()
    if MainFrame:FindFirstChild("InfoFrame") then return end
    
    local Screen = InsertTheme(Create("Frame", MainFrame, {
        BackgroundTransparency = 0.6,
        Active = true,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme["Color Stroke"],
        Name = "InfoFrame",
        ZIndex = 150
    }), "Stroke")
    ApplyRoundedCorners(Screen, UDim.new(0, 12))
    
    local InfoFrame = Create("Frame", Screen, {
        Active = true,
        Size = UDim2.fromOffset(380, 220), -- Giảm từ 350 xuống 220
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        ZIndex = 200
    })
    Make("Gradient", InfoFrame, 270)
    Make("Corner", InfoFrame, UDim.new(0, 12))
    
    local CloseBtn = Create("ImageButton", InfoFrame, {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -10, 0, 10),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10747384394",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        ZIndex = 201
    })
    
    -- ScrollingFrame để cuộn khi có nhiều card
    local ScrollContainer = Create("ScrollingFrame", InfoFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme["Color Theme"],
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        ZIndex = 2
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 8)
        })
    })
    
    -- Card nhỏ gọn hơn (giảm chiều cao từ 65 xuống 55)
    local function MakeCard(Title, Desc, Logo, Invite)
        local Holder = Create("Frame", ScrollContainer, {
            Size = UDim2.new(1, 0, 0, 55),
            BackgroundTransparency = 1
        })
        
        local Frame = Create("Frame", Holder, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme["Color Hub 2"]
        })
        Make("Corner", Frame, UDim.new(0, 8))
        Make("Stroke", Frame, nil, Theme["Color Stroke"], 1.5)
        
        Create("ImageLabel", Frame, {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 8, 0, 6),
            Image = Logo,
            BackgroundTransparency = 1
        })
        Make("Corner", Create("ImageLabel", Frame, {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 8, 0, 6),
            Image = Logo,
            BackgroundTransparency = 1
        }), UDim.new(0, 6))
        
        Create("TextLabel", Frame, {
            Size = UDim2.new(1, -58, 0, 14),
            Position = UDim2.new(0, 46, 0, 6),
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Theme["Color Text"],
            TextSize = 11,
            TextXAlignment = "Left",
            BackgroundTransparency = 1
        })
        
        Create("TextLabel", Frame, {
            Size = UDim2.new(1, -58, 0, 14),
            Position = UDim2.new(0, 46, 0, 22),
            Font = Enum.Font.Gotham,
            Text = Desc,
            TextColor3 = Theme["Color Dark Text"],
            TextSize = 9,
            TextXAlignment = "Left",
            BackgroundTransparency = 1
        })
        
        local Btn = Create("TextButton", Frame, {
            Size = UDim2.new(0, 60, 0, 16),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -6, 1, -6),
            Text = "Copy",
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        })
        Make("Corner", Btn, UDim.new(0, 4))
        
        Btn.Activated:Connect(function()
            setclipboard(Invite)
            Btn.Text = "✓"
            Btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            task.wait(1.5)
            Btn.Text = "Copy"
            Btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end)
    end
    
    -- Chỉ 2 card để khung không bị dài
    MakeCard("Bear Library", "Support server", "rbxassetid://76571437829227", "https://discord.gg/bearlib")
    MakeCard("Roblox Studio", "Scripting tips", "rbxassetid://10709752907", "https://discord.gg/roblox")
    
    CloseBtn.Activated:Connect(function() Screen:Destroy() end)
    
    Screen.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local framePos = InfoFrame.AbsolutePosition
            local frameSize = InfoFrame.AbsoluteSize
            if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                    mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
                Screen:Destroy()
            end
        end
    end)
end)

    SetChildren(ButtonsFolder, {
        CloseButton,
        MaximizeButton,
        MinimizeButton,
        SettingsButton,
        InfoButton
    })

    local Window = {}
    local ContainerList = {}
    local FirstTabCreated = nil
    local TabLayoutOrder = 0

    local function ForceUpdateScrollLayout()
        if not MainScroll then return end
        local layout = MainScroll:FindFirstChildOfClass("UIListLayout")
        if layout then
            layout.SortOrder = "Name"
            task.wait()
            layout.SortOrder = "LayoutOrder"
        end
    end

    local function ToggleMaximize()
        if not MainFrame then return end

        if IsMaximized then
            local defaultX, defaultY = unpack(OriginalUISize or bearlib.Save.UISize)
            MainFrame.Size = UDim2.fromOffset(defaultX, defaultY)
            MainFrame.Position = UDim2.new(0.5, -defaultX / 2, 0.5, -defaultY / 2)
            MaximizeButton.Image = "rbxassetid://10734886735"
            IsMaximized = false

            bearlib.Save.UISize = {defaultX, defaultY}
            SaveJson("bearlib.json", bearlib.Save)
        else
            local currentX = MainFrame.Size.X.Offset
            local currentY = MainFrame.Size.Y.Offset

            if not OriginalUISize then
                OriginalUISize = {currentX, currentY}
            end

            local newX = 700
            local newY = 410

            newX = math.min(newX, ViewportSize.X - 20)
            newY = math.min(newY, ViewportSize.Y - 20)

            MainFrame.Size = UDim2.fromOffset(newX, newY)
            MainFrame.Position = UDim2.new(0.5, -newX / 2, 0.5, -newY / 2)
            MaximizeButton.Image = "rbxassetid://10734895698"
            IsMaximized = true
        end
    end

    MaximizeButton.Activated:Connect(ToggleMaximize)

    function Window:CloseBtn()
        local Dialog = Window:Dialog({
            Title = "Window",
            Text = "Đóng window ?",
            Options = {
                {"Đóng", function()
                    ScreenGui:Destroy()
                    if ToggleGui then
                        ToggleGui:Destroy()
                    end
                    if MinimizedBar and MinimizedBar.Parent then
                        MinimizedBar:Destroy()
                    end
                end},
                {"Không"}
            }
        })
    end

    function Window:CreateMinimizedBar()
        MinimizeButton.Image = "rbxassetid://10734924532"

        local BarWidth = 250
        local BarHeight = 40

        local barX, barY
        if BarPosition then
            barX = BarPosition.X
            barY = BarPosition.Y
        else
            barX = 350
            barY = -65
        end

        MinimizedBar = Instance.new("ImageButton")
        MinimizedBar.Name = "MinimizedBar"
        MinimizedBar.Size = UDim2.new(0, BarWidth, 0, BarHeight)
        MinimizedBar.Position = UDim2.fromOffset(barX, barY)
        MinimizedBar.BackgroundColor3 = Theme["Color Hub 2"]
        MinimizedBar.BackgroundTransparency = 0
        MinimizedBar.Parent = ScreenGui
        MinimizedBar.ZIndex = 1000
        MinimizedBar.AutoButtonColor = false
        MinimizedBar.Visible = true

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = MinimizedBar

        local BarGradient = Instance.new("UIGradient")
        BarGradient.Color = ColorSequence.new(Theme["Color Hub 1"])
        BarGradient.Rotation = 45
        BarGradient.Parent = MinimizedBar
        InsertTheme(BarGradient, "Gradient")

        local BarStroke = Instance.new("UIStroke")
        BarStroke.Color = Theme["UI Border Color"]
        BarStroke.Thickness = Theme["Border Thickness"] or 1.5
        BarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BarStroke.Parent = MinimizedBar
        InsertTheme(BarStroke, "UIBorder")

        local BarIcon = Instance.new("ImageLabel")
        BarIcon.Size = UDim2.new(0, 22, 0, 22)
        BarIcon.Position = UDim2.new(0, 10, 0.5, 0)
        BarIcon.AnchorPoint = Vector2.new(0, 0.5)
        BarIcon.BackgroundTransparency = 1
        BarIcon.Image = "rbxassetid://76571437829227"
        BarIcon.ImageColor3 = Theme["Color Text"]
        BarIcon.Parent = MinimizedBar
        BarIcon.ZIndex = 1001

        local BarText = Instance.new("TextLabel")
        BarText.Size = UDim2.new(1, -20, 1, 0)
        BarText.Position = UDim2.new(0, 40, 0.5, 0)
        BarText.AnchorPoint = Vector2.new(0, 0.5)
        BarText.BackgroundTransparency = 1
        BarText.Font = Enum.Font.GothamMedium
        BarText.Text = WTitle
        BarText.TextColor3 = Theme["Color Text"]
        BarText.TextSize = 14
        BarText.TextXAlignment = Enum.TextXAlignment.Left
        BarText.TextTruncate = Enum.TextTruncate.AtEnd
        BarText.Parent = MinimizedBar
        BarText.ZIndex = 1001
        InsertTheme(BarText, "Text")

        MakeDrag(MinimizedBar)

        MinimizedBar:GetPropertyChangedSignal("Position"):Connect(function()
            if MinimizedBar and MinimizedBar.Parent then
                SaveBarPosition()
            end
        end)

        MinimizedBar.MouseButton1Click:Connect(function()
            Window:RestoreFromBar()
        end)

        MainFrame.Visible = false
        ControlSize.Visible = false
        ControlSize2.Visible = false

        Minimized = true
        UIFullVisible = false
    end

    function Window:MinimizeBtn()
        if WaitClick then return end
        WaitClick = true

        if Minimized then
            MinimizeButton.Image = "rbxassetid://10734896206"

            if MinimizedBar and MinimizedBar.Parent then
                MinimizedBar.Visible = false
            end

            MainFrame.Visible = true
            CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
            CreateTween({MainFrame, "BackgroundTransparency", bgTransparency, 0.25})
            ControlSize.Visible = true
            ControlSize2.Visible = true

            Minimized = false
            UIFullVisible = true
        else
            SaveSize = MainFrame.Size

            if not MinimizedBar or not MinimizedBar.Parent then
                Window:CreateMinimizedBar()
            else
                MinimizedBar.Visible = true
                MainFrame.Visible = false
                ControlSize.Visible = false
                ControlSize2.Visible = false
                Minimized = true
                UIFullVisible = false
            end
        end

        WaitClick = false
    end

    function Window:RestoreFromBar()
        if not Minimized then return end

        MinimizeButton.Image = "rbxassetid://10734896206"

        if MinimizedBar and MinimizedBar.Parent then
            MinimizedBar.Visible = false
        end

        MainFrame.Visible = true
        CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
        CreateTween({MainFrame, "BackgroundTransparency", bgTransparency, 0.25})
        ControlSize.Visible = true
        ControlSize2.Visible = true

        Minimized = false
        UIFullVisible = true
    end

    function Window:AddMinimizeButton(Configs)
        local Button = MakeDrag(Create("ImageButton", ScreenGui, {
            Size = UDim2.fromOffset(35, 35),
            Position = UDim2.fromScale(0.15, 0.15),
            BackgroundTransparency = 1,
            BackgroundColor3 = Theme["Color Hub 2"],
            AutoButtonColor = false
        }))

        local Stroke, Corner
        if Configs.Corner then
            Corner = Make("Corner", Button)
            SetProps(Corner, Configs.Corner)
        end
        if Configs.Stroke then
            Stroke = Make("Stroke", Button)
            SetProps(Stroke, Configs.Corner)
        end

        SetProps(Button, Configs.Button)
        Button.Activated:Connect(Window.MinimizeBtn)

        return {
            Stroke = Stroke,
            Corner = Corner,
            Button = Button
        }
    end

    function Window:Set(Val1, Val2)
        if type(Val1) == "string" then
            Title.Text = Val1
            if MinimizedBar then
                local barText = MinimizedBar:FindFirstChildOfClass("TextLabel")
                if barText then
                    barText.Text = Val1
                end
            end
        end
        if type(Val2) == "string" and SubTitle then
            SubTitle.Text = Val2
        end
    end

    function Window:Bar(Text, ColorBackground, ColorStroke, ColorText, Icon)
        if SmallBarText then
            SmallBarText.Text = Text or ""
            if Text and Text ~= "" then
                SmallBar.Visible = true

                if ColorBackground and typeof(ColorBackground) == "Color3" then
                    SmallBar.BackgroundColor3 = ColorBackground
                else
                    SmallBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                end

                if ColorStroke and typeof(ColorStroke) == "Color3" then
                    SmallBarStroke.Color = ColorStroke
                else
                    SmallBarStroke.Color = Color3.fromRGB(0, 255, 0)
                end

                if ColorText and typeof(ColorText) == "Color3" then
                    SmallBarText.TextColor3 = ColorText
                else
                    SmallBarText.TextColor3 = Color3.fromRGB(0, 255, 0)
                end

                if Icon and SmallBarIcon then
                    SmallBarIcon.Visible = true
                    SmallBarIcon.Image = bearlib:GetIcon(Icon) or Icon
                    SmallBarIcon.ImageColor3 = ColorText or Color3.fromRGB(0, 255, 0)
                elseif SmallBarIcon then
                    SmallBarIcon.Visible = false
                end
            else
                SmallBar.Visible = false
                if SmallBarIcon then SmallBarIcon.Visible = false end
            end
            task.wait()
            UpdateSmallBarSize()
            UpdateAllBarPositions()
        end
    end

    function Window:Bar2(Text, ColorBackground, ColorStroke, ColorText, Icon)
        if SmallBar2Text then
            SmallBar2Text.Text = Text or ""
            if Text and Text ~= "" then
                SmallBar2.Visible = true

                if ColorBackground and typeof(ColorBackground) == "Color3" then
                    SmallBar2.BackgroundColor3 = ColorBackground
                else
                    SmallBar2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                end

                if ColorStroke and typeof(ColorStroke) == "Color3" then
                    SmallBar2Stroke.Color = ColorStroke
                else
                    SmallBar2Stroke.Color = Color3.fromRGB(0, 255, 0)
                end

                if ColorText and typeof(ColorText) == "Color3" then
                    SmallBar2Text.TextColor3 = ColorText
                else
                    SmallBar2Text.TextColor3 = Color3.fromRGB(0, 255, 0)
                end

                if Icon and SmallBar2Icon then
                    SmallBar2Icon.Visible = true
                    SmallBar2Icon.Image = bearlib:GetIcon(Icon) or Icon
                    SmallBar2Icon.ImageColor3 = ColorText or Color3.fromRGB(0, 255, 0)
                elseif SmallBar2Icon then
                    SmallBar2Icon.Visible = false
                end
            else
                SmallBar2.Visible = false
                if SmallBar2Icon then SmallBar2Icon.Visible = false end
            end
            task.wait()
            UpdateSmallBar2Size()
            UpdateAllBarPositions()
        end
    end

    function Window:Bar3(Text, ColorBackground, ColorStroke, ColorText, Icon)
        if SmallBar3Text then
            SmallBar3Text.Text = Text or ""
            if Text and Text ~= "" then
                SmallBar3.Visible = true

                if ColorBackground and typeof(ColorBackground) == "Color3" then
                    SmallBar3.BackgroundColor3 = ColorBackground
                else
                    SmallBar3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                end

                if ColorStroke and typeof(ColorStroke) == "Color3" then
                    SmallBar3Stroke.Color = ColorStroke
                else
                    SmallBar3Stroke.Color = Color3.fromRGB(0, 255, 0)
                end

                if ColorText and typeof(ColorText) == "Color3" then
                    SmallBar3Text.TextColor3 = ColorText
                else
                    SmallBar3Text.TextColor3 = Color3.fromRGB(0, 255, 0)
                end

                if Icon and SmallBar3Icon then
                    SmallBar3Icon.Visible = true
                    SmallBar3Icon.Image = bearlib:GetIcon(Icon) or Icon
                    SmallBar3Icon.ImageColor3 = ColorText or Color3.fromRGB(0, 255, 0)
                elseif SmallBar3Icon then
                    SmallBar3Icon.Visible = false
                end
            else
                SmallBar3.Visible = false
                if SmallBar3Icon then SmallBar3Icon.Visible = false end
            end
            task.wait()
            UpdateSmallBar3Size()
            UpdateAllBarPositions()
        end
    end

    function Window:Bar4(Text, ColorBackground, ColorStroke, ColorText, Icon)
        if SmallBar4Text then
            SmallBar4Text.Text = Text or ""
            if Text and Text ~= "" then
                SmallBar4.Visible = true

                if ColorBackground and typeof(ColorBackground) == "Color3" then
                    SmallBar4.BackgroundColor3 = ColorBackground
                else
                    SmallBar4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                end

                if ColorStroke and typeof(ColorStroke) == "Color3" then
                    SmallBar4Stroke.Color = ColorStroke
                else
                    SmallBar4Stroke.Color = Color3.fromRGB(0, 255, 0)
                end

                if ColorText and typeof(ColorText) == "Color3" then
                    SmallBar4Text.TextColor3 = ColorText
                else
                    SmallBar4Text.TextColor3 = Color3.fromRGB(0, 255, 0)
                end

                if Icon and SmallBar4Icon then
                    SmallBar4Icon.Visible = true
                    SmallBar4Icon.Image = bearlib:GetIcon(Icon) or Icon
                    SmallBar4Icon.ImageColor3 = ColorText or Color3.fromRGB(0, 255, 0)
                elseif SmallBar4Icon then
                    SmallBar4Icon.Visible = false
                end
            else
                SmallBar4.Visible = false
                if SmallBar4Icon then SmallBar4Icon.Visible = false end
            end
            task.wait()
            UpdateSmallBar4Size()
            UpdateAllBarPositions()
        end
    end

    function Window:Bar5(Text, ColorBackground, ColorStroke, ColorText, Icon)
        if SmallBar5Text then
            SmallBar5Text.Text = Text or ""
            if Text and Text ~= "" then
                SmallBar5.Visible = true

                if ColorBackground and typeof(ColorBackground) == "Color3" then
                    SmallBar5.BackgroundColor3 = ColorBackground
                else
                    SmallBar5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                end

                if ColorStroke and typeof(ColorStroke) == "Color3" then
                    SmallBar5Stroke.Color = ColorStroke
                else
                    SmallBar5Stroke.Color = Color3.fromRGB(0, 255, 0)
                end

                if ColorText and typeof(ColorText) == "Color3" then
                    SmallBar5Text.TextColor3 = ColorText
                else
                    SmallBar5Text.TextColor3 = Color3.fromRGB(0, 255, 0)
                end

                if Icon and SmallBar5Icon then
                    SmallBar5Icon.Visible = true
                    SmallBar5Icon.Image = bearlib:GetIcon(Icon) or Icon
                    SmallBar5Icon.ImageColor3 = ColorText or Color3.fromRGB(0, 255, 0)
                elseif SmallBar5Icon then
                    SmallBar5Icon.Visible = false
                end
            else
                SmallBar5.Visible = false
                if SmallBar5Icon then SmallBar5Icon.Visible = false end
            end
            task.wait()
            UpdateSmallBar5Size()
            UpdateAllBarPositions()
        end
    end

    function Window:Dialog(Configs)
        if MainFrame:FindFirstChild("Dialog") then return end
        if Minimized then
            Window:RestoreFromBar()
        end

        local DTitle = Configs[1] or Configs.Title or "Dialog"
        local DText = Configs[2] or Configs.Text or "This is a Dialog"
        local DOptions = Configs[3] or Configs.Options or {}

        local Frame = Create("Frame", {
            Active = true,
            Size = UDim2.fromOffset(250 * 1.08, 150 * 1.08),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 200
        }, {
            InsertTheme(Create("TextLabel", {
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, 0, 0, 20),
                Text = DTitle,
                TextXAlignment = "Left",
                TextColor3 = Theme["Color Text"],
                TextSize = 15,
                Position = UDim2.fromOffset(15, 5),
                BackgroundTransparency = 1,
                ZIndex = 201
            }), "Text"),
            InsertTheme(Create("TextLabel", {
                Font = Enum.Font.GothamMedium,
                Size = UDim2.new(1, -25),
                AutomaticSize = "Y",
                Text = DText,
                TextXAlignment = "Left",
                TextColor3 = Theme["Color Dark Text"],
                TextSize = 12,
                Position = UDim2.fromOffset(15, 25),
                BackgroundTransparency = 1,
                TextWrapped = true,
                ZIndex = 201
            }), "DarkText")
        })
        Make("Gradient", Frame, 270)
        Make("Corner", Frame, UDim.new(0, 12))

        local ButtonsHolder = Create("Frame", Frame, {
            Size = UDim2.fromScale(1, 0.35),
            Position = UDim2.fromScale(0, 1),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Theme["Color Hub 2"],
            BackgroundTransparency = 1,
            ZIndex = 201
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                VerticalAlignment = "Center",
                FillDirection = "Horizontal",
                HorizontalAlignment = "Center"
            })
        })

        local Screen = InsertTheme(Create("Frame", MainFrame, {
            BackgroundTransparency = 0.6,
            Active = true,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme["Color Stroke"],
            Name = "Dialog",
            ZIndex = 150
        }), "Stroke")

        ApplyRoundedCorners(Screen, UDim.new(0, 12))

        for _, child in pairs(ButtonsHolder:GetDescendants()) do
            if child:IsA("TextButton") then
                ApplyRoundedCorners(child, UDim.new(0, 8))
            end
        end

        Frame.Parent = Screen

        for _, child in pairs(Frame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then
                child.ZIndex = math.max(child.ZIndex or 1, 200)
            end
        end

        CreateTween({Frame, "Size", UDim2.fromOffset(250, 150), 0.2})
        CreateTween({Frame, "Transparency", 0, 0.15})
        CreateTween({Screen, "Transparency", 0.3, 0.15})

        local ButtonCount, Dialog = 1, {}

        function Dialog:Button(Configs)
            local Name = Configs[1] or Configs.Name or Configs.Title or ""
            local Callback = Configs[2] or Configs.Callback or function() end

            ButtonCount = ButtonCount + 1
            local Button = Make("Button", ButtonsHolder)
            Make("Corner", Button, UDim.new(0, 8))
            SetProps(Button, {
                Text = Name,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"],
                TextSize = 12,
                ZIndex = 202
            })

            for _, Btn in pairs(ButtonsHolder:GetChildren()) do
                if Btn:IsA("TextButton") then
                    Btn.Size = UDim2.new(1 / ButtonCount, -(((ButtonCount - 1) * 20) / ButtonCount), 0, 32)
                    Btn.ZIndex = 202
                end
            end
            Button.Activated:Connect(Dialog.Close)
            Button.Activated:Connect(Callback)
        end

        function Dialog:Close()
            CreateTween({Frame, "Size", UDim2.fromOffset(250 * 1.08, 150 * 1.08), 0.2})
            CreateTween({Screen, "Transparency", 1, 0.15})
            CreateTween({Frame, "Transparency", 1, 0.15, true})
            Screen:Destroy()
        end
        table.foreach(DOptions, function(_, Button)
            Dialog:Button(Button)
        end)
        return Dialog
    end

    function Window:GetMainContainer()
        return Containers
    end

    function Window:SelectTab(TabSelect)
        if type(TabSelect) == "number" then
            if bearlib.Tabs[TabSelect] then
                bearlib.Tabs[TabSelect].func:Enable()
            end
        else
            for _, Tab in pairs(bearlib.Tabs) do
                if Tab.Cont == TabSelect.Cont then
                    Tab.func:Enable()
                end
            end
        end
    end

    function Window:MakeTab(Configs)
        if type(Configs) == "table" and Configs[1] == nil then
            Configs = Configs
        end
        local TName = Configs[1] or Configs.Title or "Tab!"
        local TIcon = Configs[2] or Configs.Icon or ""

        TIcon = bearlib:GetIcon(TIcon)
        if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
            TIcon = false
        end

        local Container = InsertTheme(Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 1),
            AnchorPoint = Vector2.new(0, 1),
            ScrollBarThickness = 1.5,
            BackgroundTransparency = 1,
            ScrollBarImageTransparency = 0.2,
            ScrollBarImageColor3 = Theme["Color Theme"],
            AutomaticCanvasSize = "Y",
            ScrollingDirection = "Y",
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            Name = ("Container %i [ %s ]"):format(#ContainerList + 1, TName),
            ZIndex = 1
        }, {
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            }), Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = "LayoutOrder"
            })
        }), "ScrollBar")

        table.insert(ContainerList, Container)

        local isFirstTab = (FirstTabCreated == nil)
        if isFirstTab then
            FirstTabCreated = Container
        end

        TabLayoutOrder = TabLayoutOrder + 1

        local TabSelect = Create("Frame", MainScroll, {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Name = "TabButton",
            Active = true,
            LayoutOrder = TabLayoutOrder
        })
        Make("Corner", TabSelect)

        local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
            Size = UDim2.new(1, TIcon and -25 or -15, 1),
            Position = UDim2.fromOffset(TIcon and 25 or 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = TName,
            TextColor3 = Theme["Color Text"],
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = (isFirstTab and 0) or 0.3,
            TextTruncate = "AtEnd",
            ZIndex = 5
        }), "Text")

        local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
            Position = UDim2.new(0, 8, 0.5),
            Size = UDim2.new(0, 13, 0, 13),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = TIcon or "",
            BackgroundTransparency = 1,
            ImageTransparency = (isFirstTab and 0) or 0.3,
            ImageColor3 = Theme["Color Text"],
            ZIndex = 5
        }), "Text")

        local SelectedContainer = Create("Frame", TabSelect, {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 4,
            Name = "SelectedContainer"
        })

        local BorderFrame = InsertTheme(Create("Frame", SelectedContainer, {
            Size = UDim2.new(1, -4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 4,
            Name = "BorderFrame"
        }), "TabBorderFrame")

        local BorderCorner = Instance.new("UICorner")
        BorderCorner.CornerRadius = UDim.new(0, 20)
        BorderCorner.Parent = BorderFrame

        local BorderStroke = Instance.new("UIStroke")
        BorderStroke.Color = Theme["Color Hub 3"]
        BorderStroke.Thickness = Theme["Border Thickness"] or 1.5
        BorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BorderStroke.LineJoinMode = Enum.LineJoinMode.Round
        BorderStroke.Parent = BorderFrame
        BorderStroke.Name = "BorderStroke"
        BorderStroke.Transparency = isFirstTab and 0 or 1

        InsertTheme(BorderStroke, "TabBorderFrame")

        local BorderGradient = Instance.new("UIGradient")
        BorderGradient.Name = "BorderGradient"

        local themeColor = Theme["Color Hub 3"]
        BorderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, themeColor),
            ColorSequenceKeypoint.new(0.5, themeColor),
            ColorSequenceKeypoint.new(1, themeColor),
        })
        BorderGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.5),
            NumberSequenceKeypoint.new(1, 0),
        })
        BorderGradient.Parent = BorderStroke
        BorderGradient.Enabled = isFirstTab

        if not isFirstTab then
            Container.Parent = nil
        else
            Container.Parent = Containers
        end

        ForceUpdateScrollLayout()

        local function Tabs()
            if Container.Parent then return end
            for _, Frame in pairs(ContainerList) do
                if Frame:IsA("ScrollingFrame") and Frame ~= Container then
                    Frame.Parent = nil
                end
            end
            Container.Parent = Containers
            Container.Size = UDim2.new(1, 0, 1, 150)

            table.foreach(bearlib.Tabs, function(_, Tab)
                if Tab.Cont ~= Container then
                    Tab.func:Disable()
                end
            end)

            CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
            CreateTween({LabelTitle, "TextTransparency", 0, 0.35})
            CreateTween({LabelIcon, "ImageTransparency", 0, 0.35})

            CreateTween({BorderStroke, "Transparency", 0, 0.35})
            BorderGradient.Enabled = true
        end

        local isDragging = false
        local dragStartPos = nil
        local dragThreshold = 5

        TabSelect.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
                dragStartPos = Input.Position
            end
        end)

        TabSelect.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if not isDragging and dragStartPos then
                    local delta = (Input.Position - dragStartPos).Magnitude
                    if delta < dragThreshold then
                        Tabs()
                    end
                end
                isDragging = false
                dragStartPos = nil
            end
        end)

        MainScroll.InputChanged:Connect(function(Input)
            if dragStartPos and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local delta = (Input.Position - dragStartPos).Magnitude
                if delta > dragThreshold then
                    isDragging = true
                end
            end
        end)

        local Tab = {}
        table.insert(bearlib.Tabs, {
            TabInfo = {Name = TName, Icon = TIcon},
            func = Tab,
            Cont = Container,
            BorderGradient = BorderGradient,
            BorderStroke = BorderStroke
        })
        Tab.Cont = Container

        local CurrentSectionName = nil
        local ElementCount = 0

        local function GetOrder()
            ElementCount = ElementCount + 1
            return ElementCount
        end

        function Tab:Disable()
            Container.Parent = nil
            CreateTween({LabelTitle, "TextTransparency", 0.3, 0.35})
            CreateTween({LabelIcon, "ImageTransparency", 0.3, 0.35})
            CreateTween({BorderStroke, "Transparency", 1, 0.35})
            BorderGradient.Enabled = false
        end

        function Tab:Enable()
            Tabs()
        end

        function Tab:Visible(Bool)
            Funcs:ToggleVisible(TabSelect, Bool)
        end

        function Tab:Destroy()
            TabSelect:Destroy()
            Container:Destroy()
        end

        function Tab:AddSection(Configs)
            local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
            CurrentSectionName = SectionName

            local SectionFrame = Create("Frame", Container, {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Name = "Option",
                LayoutOrder = GetOrder(),
                ZIndex = 2
            })

            local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Theme["Color Text"],
                Size = UDim2.new(1, -25, 0, 18),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextTruncate = "AtEnd",
                TextSize = 14,
                TextXAlignment = "Left",
                ZIndex = 3
            }), "Text")

            table.insert(bearlib.AllElements, {
                Name = SectionName,
                Instance = SectionFrame,
                OriginalParent = Container,
                SectionName = SectionName,
                Underline = nil,
                UnderlineGradient = nil
            })

            local Section = {}
            table.insert(bearlib.Options, {type = "Section", Name = SectionName, func = Section})

            function Section:Visible(Bool)
                if Bool == nil then
                    SectionFrame.Visible = not SectionFrame.Visible
                    return
                end
                SectionFrame.Visible = Bool
            end

            function Section:Destroy()
                SectionFrame:Destroy()
            end

            function Section:Set(New)
                if New then
                    SectionLabel.Text = GetStr(New)
                end
            end

            return Section
        end

        function Tab:AddParagraph(Configs)
            local PName = Configs[1] or Configs.Title or "Paragraph"
            local PDesc = Configs[2] or Configs.Text or ""

            local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
            Frame.LayoutOrder = GetOrder()

            table.insert(bearlib.AllElements, {
                Name = PName,
                Instance = Frame,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Paragraph = {}

            function Paragraph:Visible(...) Funcs:ToggleVisible(Frame, ...) end

            function Paragraph:Destroy() Frame:Destroy() end

            function Paragraph:SetTitle(Val)
                LabelFunc:SetTitle(GetStr(Val))
            end

            function Paragraph:SetDesc(Val)
                LabelFunc:SetDesc(GetStr(Val))
            end

            function Paragraph:Set(Val1, Val2)
                if Val1 and Val2 then
                    LabelFunc:SetTitle(GetStr(Val1))
                    LabelFunc:SetDesc(GetStr(Val2))
                elseif Val1 then
                    LabelFunc:SetDesc(GetStr(Val1))
                end
            end
            return Paragraph
        end

        function Tab:AddButton(Configs)
            local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
            local BDescription = Configs.Desc or Configs.Description or ""
            local Callback = Funcs:GetCallback(Configs, 2)

            local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
            FButton.LayoutOrder = GetOrder()

            local ButtonIcon = Create("ImageLabel", FButton, {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10709791437",
                ZIndex = 5
            })

            FButton.Activated:Connect(function()
                Funcs:FireCallback(Callback)
            end)

            table.insert(bearlib.AllElements, {
                Name = BName,
                Instance = FButton,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Button = {}

            function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end

            function Button:Destroy() FButton:Destroy() end

            function Button:Callback(...) Funcs:InsertCallback(Callback, ...)() end

            function Button:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then
                    LabelFunc:SetTitle(Val1)
                    LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then
                    LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
            end
            return Button
        end

        function Tab:AddToggle(Configs)
            local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
            local TDesc = Configs.Desc or Configs.Description or ""
            local Callback = Funcs:GetCallback(Configs, 3)
            local Flag = Configs[4] or Configs.Flag or false
            local Default = Configs[2] or Configs.Default or false
            if CheckFlag(Flag) then Default = GetFlag(Flag) end

            local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
            Button.LayoutOrder = GetOrder()

            local ToggleHolder = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 35, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Toggle Off"],
                ZIndex = 4
            }), "Stroke")
            Make("Corner", ToggleHolder, UDim.new(0.5, 0))

            local Slider = Create("Frame", ToggleHolder, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 0.8, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 4
            })

            local Toggle = InsertTheme(Create("Frame", Slider, {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 0, 0.5),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme["Color Toggle Knob Off"],
                ZIndex = 5
            }), "Theme")
            Make("Corner", Toggle, UDim.new(0.5, 0))

            local WaitClick
            local function SetToggle(Val)
                if WaitClick then return end

                WaitClick, Default = true, Val
                SetFlag(Flag, Default)
                Funcs:FireCallback(Callback, Default)
                if Default then
                    CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25})
                    CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob On"], 0.25})
                    CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25})
                    CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle On"], 0.25})
                else
                    CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25})
                    CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob Off"], 0.25})
                    CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25})
                    CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle Off"], 0.25})
                end
                WaitClick = false
            end
            task.spawn(SetToggle, Default)

            Button.Activated:Connect(function()
                SetToggle(not Default)
            end)

            table.insert(bearlib.AllElements, {
                Name = TName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local ToggleObj = {}

            function ToggleObj:Visible(...) Funcs:ToggleVisible(Button, ...) end

            function ToggleObj:Destroy() Button:Destroy() end

            function ToggleObj:Callback(...) Funcs:InsertCallback(Callback, ...)() end

            function ToggleObj:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then
                    LabelFunc:SetTitle(Val1)
                    LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then
                    LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "boolean" then
                    if WaitClick and Val2 then
                        repeat task.wait() until not WaitClick
                    end
                    task.spawn(SetToggle, Val1)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
            end
            return ToggleObj
        end

        function Tab:AddSlider(Configs)
            local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
            local SDesc = Configs.Desc or Configs.Description or ""
            local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
            local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
            local Increase = Configs[4] or Configs.Increase or 1
            local Callback = Funcs:GetCallback(Configs, 6)
            local Flag = Configs[7] or Configs.Flag or false
            local Default = Configs[5] or Configs.Default or 25
            if CheckFlag(Flag) then Default = GetFlag(Flag) end
            Min, Max = Min / Increase, Max / Increase

            local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))
            Button.LayoutOrder = GetOrder()

            local SliderHolder = Create("TextButton", Button, {
                Size = UDim2.new(0.45, 0, 1),
                Position = UDim2.new(1),
                AnchorPoint = Vector2.new(1, 0),
                AutoButtonColor = false,
                Text = "",
                BackgroundTransparency = 1,
                ZIndex = 4
            })

            local SliderBar = InsertTheme(Create("Frame", SliderHolder, {
                BackgroundColor3 = Theme["Color Stroke"],
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0.5, 0, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 4
            }), "Stroke") Make("Corner", SliderBar)

            local Indicator = InsertTheme(Create("Frame", SliderBar, {
                BackgroundColor3 = Theme["Color Theme"],
                Size = UDim2.fromScale(0.3, 1),
                BorderSizePixel = 0,
                ZIndex = 5
            }), "Theme") Make("Corner", Indicator)

            local SliderIcon = Create("Frame", SliderBar, {
                Size = UDim2.new(0, 6, 0, 12),
                BackgroundColor3 = Color3.fromRGB(220, 220, 220),
                Position = UDim2.fromScale(0.3, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 0.2,
                ZIndex = 6
            }) Make("Corner", SliderIcon)

            local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, {
                Size = UDim2.new(0, 14, 0, 14),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(0, 0, 0.5),
                BackgroundTransparency = 1,
                TextColor3 = Theme["Color Text"],
                Font = Enum.Font.FredokaOne,
                TextSize = 12,
                ZIndex = 5
            }), "Text")

            local UIScaleObj = Create("UIScale", LabelVal)

            local BaseMousePos = Create("Frame", SliderBar, {
                Position = UDim2.new(0, 0, 0.5, 0),
                Visible = false
            })

            local function UpdateLabel(NewValue)
                local Number = tonumber(NewValue * Increase)
                Number = math.floor(Number * 100) / 100

                Default, LabelVal.Text = Number, tostring(Number)
                Funcs:FireCallback(Callback, Default)
            end

            local function ControlPos()
                local MousePos = Player:GetMouse()
                local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
                local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X

                SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
            end

            local function UpdateValues()
                Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
                local SliderPos = SliderIcon.Position.X.Scale
                local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
                UpdateLabel(NewValue)
            end

            SliderHolder.MouseButton1Down:Connect(function()
                CreateTween({SliderIcon, "BackgroundTransparency", 0, 0.3})
                Container.ScrollingEnabled = false
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
                    ControlPos()
                end
                CreateTween({SliderIcon, "BackgroundTransparency", 0.2, 0.3})
                Container.ScrollingEnabled = true
                SetFlag(Flag, Default)
            end)

            LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
                UIScaleObj.Scale = 0.3
                CreateTween({UIScaleObj, "Scale", 1.2, 0.1})
                CreateTween({LabelVal, "Rotation", math.random(-1, 1) * 5, 0.15, true})
                CreateTween({UIScaleObj, "Scale", 1, 0.2})
                CreateTween({LabelVal, "Rotation", 0, 0.1})
            end)

            function SetSlider(NewValue)
                if type(NewValue) ~= "number" then return end

                local MinVal, MaxVal = Min * Increase, Max * Increase

                local SliderPos = (NewValue - MinVal) / (MaxVal - MinVal)

                SetFlag(Flag, NewValue)
                CreateTween({SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true})
            end
            SetSlider(Default)

            SliderIcon:GetPropertyChangedSignal("Position"):Connect(UpdateValues) UpdateValues()

            table.insert(bearlib.AllElements, {
                Name = SName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Slider = {}

            function Slider:Set(NewVal1, NewVal2)
                if NewVal1 and NewVal2 then
                    LabelFunc:SetTitle(NewVal1)
                    LabelFunc:SetDesc(NewVal2)
                elseif type(NewVal1) == "string" then
                    LabelFunc:SetTitle(NewVal1)
                elseif type(NewVal1) == "function" then
                    Callback = NewVal1
                elseif type(NewVal1) == "number" then
                    SetSlider(NewVal1)
                end
            end

            function Slider:Callback(...) Funcs:InsertCallback(Callback, ...)(tonumber(Default)) end

            function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end

            function Slider:Destroy() Button:Destroy() end
            return Slider
        end

        function Tab:AddTextBox(Configs)
            local TName = Configs[1] or Configs.Name or Configs.Title or "Text Box"
            local TDesc = Configs.Desc or Configs.Description or ""
            local TDefault = Configs[2] or Configs.Default or ""
            local TPlaceholderText = Configs[5] or Configs.PlaceholderText or "Input"
            local TClearText = Configs[3] or Configs.ClearText or false
            local Callback = Funcs:GetCallback(Configs, 4)

            if type(TDefault) ~= "string" or TDefault:gsub(" ", ""):len() < 1 then
                TDefault = false
            end

            local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
            Button.LayoutOrder = GetOrder()

            local SelectedFrame = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 150, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"],
                ZIndex = 4
            }), "Stroke") Make("Corner", SelectedFrame, UDim.new(0, 4))

            local TextBoxInput = InsertTheme(Create("TextBox", SelectedFrame, {
                Size = UDim2.new(0.85, 0, 0.85, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = Theme["Color Text"],
                ClearTextOnFocus = TClearText,
                PlaceholderText = TPlaceholderText,
                Text = "",
                ZIndex = 5,
                TextStrokeTransparency = 0.3,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "Text")

            local Pencil = Create("ImageLabel", SelectedFrame, {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, -5, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                Image = "rbxassetid://15637081879",
                BackgroundTransparency = 1,
                ZIndex = 5
            })

            table.insert(bearlib.AllElements, {
                Name = TName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local TextBox = {}

            local function Input()
                local Text = TextBoxInput.Text
                if Text:gsub(" ", ""):len() > 0 then
                    if TextBox.OnChanging then Text = TextBox.OnChanging(Text) or Text end
                    Funcs:FireCallback(Callback, Text)
                    TextBoxInput.Text = Text
                end
            end

            TextBoxInput.FocusLost:Connect(Input) Input()

            TextBoxInput.FocusLost:Connect(function()
                CreateTween({Pencil, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
            end)
            TextBoxInput.Focused:Connect(function()
                CreateTween({Pencil, "ImageColor3", Theme["Color Theme"], 0.2})
            end)

            TextBox.OnChanging = false

            function TextBox:Visible(...) Funcs:ToggleVisible(Button, ...) end

            function TextBox:Destroy() Button:Destroy() end
            return TextBox
        end

        function Tab:AddDropdown(Configs)
            local DName = Configs[1] or Configs.Name or Configs.Title or "Dropdown"
            local DDesc = Configs.Desc or Configs.Description or ""
            local DOptions = Configs[2] or Configs.Options or {}
            local OpDefault = Configs[3] or Configs.Default or {}
            local Flag = Configs[5] or Configs.Flag or false
            local DMultiSelect = Configs.MultiSelect or false
            local Callback = Funcs:GetCallback(Configs, 4)

            local Button, LabelFunc = ButtonFrame(Container, DName, DDesc, UDim2.new(1, -180))
            Button.LayoutOrder = GetOrder()

            local SelectedFrame = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 150, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"],
                ZIndex = 4
            }), "Stroke") Make("Corner", SelectedFrame, UDim.new(0, 4))

            local ActiveLabel = InsertTheme(Create("TextLabel", SelectedFrame, {
                Size = UDim2.new(0.85, 0, 0.85, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = Theme["Color Text"],
                Text = "...",
                ZIndex = 5
            }), "Text")

            local Arrow = Create("ImageLabel", SelectedFrame, {
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new(0, -5, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                Image = "rbxassetid://10709791523",
                BackgroundTransparency = 1,
                ZIndex = 5
            })

            local NoClickFrame = Create("TextButton", DropdownHolder, {
                Name = "AntiClick",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Text = ""
            })

            local DropFrame = Create("Frame", NoClickFrame, {
                Size = UDim2.new(SelectedFrame.Size.X, 0, 0),
                BackgroundTransparency = 0.1,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(0, 1),
                Name = "DropdownFrame",
                ClipsDescendants = true,
                Active = true,
                ZIndex = 5
            }) Make("Corner", DropFrame) Make("Stroke", DropFrame) Make("Gradient", DropFrame, {Rotation = 60})

            local SearchBox = Create("TextBox", DropFrame, {
                BackgroundColor3 = Theme["Color Hub 2"],
                Position = UDim2.new(0, 5, 0, 5),
                Size = UDim2.new(1, -10, 0, 22),
                Font = Enum.Font.Gotham,
                PlaceholderText = "Search...",
                Text = "",
                TextColor3 = Theme["Color Text"],
                TextSize = 11,
                ZIndex = 6
            }) Make("Corner", SearchBox, UDim.new(0, 8))

            local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, {
                ScrollBarImageColor3 = Theme["Color Theme"],
                Size = UDim2.new(1, 0, 1, -32),
                Position = UDim2.new(0, 0, 0, 32),
                ScrollBarThickness = 1.5,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                ScrollingDirection = "Y",
                AutomaticCanvasSize = "Y",
                Active = true,
                ZIndex = 6
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                }), Create("UIListLayout", {
                    Padding = UDim.new(0, 4)
                })
            }), "ScrollBar")

            local ScrollSize, WaitClick = 5

            local function Disable(input)
                if input then
                    local mousePos = input.Position
                    local dropPos = DropFrame.AbsolutePosition
                    local dropSize = DropFrame.AbsoluteSize

                    local isInsideDropFrame =
                        mousePos.X >= dropPos.X and
                        mousePos.X <= dropPos.X + dropSize.X and
                        mousePos.Y >= dropPos.Y and
                        mousePos.Y <= dropPos.Y + dropSize.Y

                    if isInsideDropFrame then
                        return
                    end
                end

                WaitClick = true
                CreateTween({Arrow, "Rotation", 0, 0.2})
                CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                Arrow.Image = "rbxassetid://10709791523"
                NoClickFrame.Visible = false
                SearchBox.Text = ""
                WaitClick = false
            end

            local function GetFrameSize()
                return UDim2.fromOffset(152, ScrollSize)
            end

            local function CalculateSize()
                local Count = 0
                for _, Frame in pairs(ScrollFrame:GetChildren()) do
                    if Frame:IsA("Frame") or Frame.Name == "Option" then
                        if Frame.Visible then
                            Count = Count + 1
                        end
                    end
                end
                ScrollSize = (math.clamp(Count, 0, 10) * 25) + 40
                if NoClickFrame.Visible then
                    CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
                end
            end

            local function Minimize()
                if WaitClick then return end
                WaitClick = true
                if NoClickFrame.Visible then
                    Arrow.Image = "rbxassetid://10709791523"
                    CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                    CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                    NoClickFrame.Visible = false
                    SearchBox.Text = ""
                else
                    NoClickFrame.Visible = true
                    Arrow.Image = "rbxassetid://10709790948"
                    CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.2})
                    CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
                end
                WaitClick = false
            end

            local function CalculatePos()
                local FramePos = SelectedFrame.AbsolutePosition
                local ScreenSize = ScreenGui.AbsoluteSize
                local ClampX = math.clamp((FramePos.X / UIScale), 0, ScreenSize.X / UIScale - DropFrame.Size.X.Offset)
                local ClampY = math.clamp((FramePos.Y / UIScale), 0, ScreenSize.Y / UIScale)

                local NewPos = UDim2.fromOffset(ClampX, ClampY)
                local AnchorPoint = FramePos.Y > ScreenSize.Y / 1.4 and 1 or ScrollSize > 80 and 0.5 or 0
                DropFrame.AnchorPoint = Vector2.new(0, AnchorPoint)
                CreateTween({DropFrame, "Position", NewPos, 0.1})
            end

            local AddNewOptions, GetOptions, AddOption, RemoveOption, Selected do
                local Default = type(OpDefault) ~= "table" and {OpDefault} or OpDefault
                local MultiSelect = DMultiSelect
                local Options = {}
                Selected = MultiSelect and {} or CheckFlag(Flag) and GetFlag(Flag) or Default[1]

                if MultiSelect then
                    for index, Value in pairs(CheckFlag(Flag) and GetFlag(Flag) or Default) do
                        if type(index) == "string" and (DOptions[index] or table.find(DOptions, index)) then
                            Selected[index] = Value
                        elseif DOptions[Value] then
                            Selected[Value] = true
                        end
                    end
                end

                local function CallbackSelected()
                    SetFlag(Flag, MultiSelect and Selected or tostring(Selected))
                    Funcs:FireCallback(Callback, Selected)
                end

                local function UpdateLabel()
                    if MultiSelect then
                        local list = {}
                        for index, Value in pairs(Selected) do
                            if Value then
                                table.insert(list, index)
                            end
                        end
                        ActiveLabel.Text = #list > 0 and table.concat(list, ", ") or "..."
                    else
                        ActiveLabel.Text = tostring(Selected or "...")
                    end
                end

                local function UpdateSelected()
                    if MultiSelect then
                        for _, v in pairs(Options) do
                            local nodes, Stats = v.nodes, v.Stats
                            CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 0.8, 0.35})
                            CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 4), 0.35})
                            CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.35})
                        end
                    else
                        for _, v in pairs(Options) do
                            local Slt = v.Value == Selected
                            local nodes = v.nodes
                            CreateTween({nodes[2], "BackgroundTransparency", Slt and 0 or 1, 0.35})
                            CreateTween({nodes[2], "Size", Slt and UDim2.fromOffset(4, 14) or UDim2.fromOffset(4, 4), 0.35})
                            CreateTween({nodes[3], "TextTransparency", Slt and 0 or 0.4, 0.35})
                        end
                    end
                    UpdateLabel()
                end

                local function Select(Option)
                    if MultiSelect then
                        Option.Stats = not Option.Stats
                        Option.LastCB = tick()

                        Selected[Option.Name] = Option.Stats
                        CallbackSelected()
                    else
                        Option.LastCB = tick()

                        Selected = Option.Value
                        CallbackSelected()
                    end
                    UpdateSelected()
                end

                AddOption = function(index, Value)
                    local Name = tostring(type(index) == "string" and index or Value)

                    if Options[Name] then return end
                    Options[Name] = {
                        index = index,
                        Value = Value,
                        Name = Name,
                        Stats = false,
                        LastCB = 0
                    }

                    if MultiSelect then
                        local Stats = Selected[Name]
                        Selected[Name] = Stats or false
                        Options[Name].Stats = Stats
                    end

                    local Button = Make("Button", ScrollFrame, {
                        Name = "Option",
                        Size = UDim2.new(1, 0, 0, 21),
                        Position = UDim2.new(0, 0, 0.5),
                        AnchorPoint = Vector2.new(0, 0.5),
                        ZIndex = 7
                    }) Make("Corner", Button, UDim.new(0, 4))

                    local IsSelected = InsertTheme(Create("Frame", Button, {
                        Position = UDim2.new(0, 1, 0.5),
                        Size = UDim2.new(0, 4, 0, 4),
                        BackgroundColor3 = Theme["Color Theme"],
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        ZIndex = 8
                    }), "Theme") Make("Corner", IsSelected, UDim.new(0.5, 0))

                    local OptioneName = InsertTheme(Create("TextLabel", Button, {
                        Size = UDim2.new(1, 0, 1),
                        Position = UDim2.new(0, 10),
                        Text = Name,
                        TextColor3 = Theme["Color Text"],
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = "Left",
                        BackgroundTransparency = 1,
                        TextTransparency = 0.4,
                        ZIndex = 8,
                        TextStrokeTransparency = 0.3,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    }), "Text")

                    Button.Activated:Connect(function()
                        Select(Options[Name])
                    end)

                    Options[Name].nodes = {Button, IsSelected, OptioneName}
                end

                RemoveOption = function(index, Value)
                    local Name = tostring(type(index) == "string" and index or Value)
                    if Options[Name] then
                        if MultiSelect then Selected[Name] = nil else Selected = nil end
                        Options[Name].nodes[1]:Destroy()
                        Options[Name] = nil
                    end
                end

                GetOptions = function()
                    return Options
                end

                AddNewOptions = function(List, Clear)
                    if Clear then
                        for _, opt in pairs(Options) do
                            RemoveOption(opt.index, opt.Value)
                        end
                    end
                    for _, opt in pairs(List) do
                        AddOption(opt, opt)
                    end
                    CallbackSelected()
                    UpdateSelected()
                end

                for _, opt in pairs(DOptions) do
                    AddOption(opt, opt)
                end
                CallbackSelected()
                UpdateSelected()
            end

            local function FilterOptions(filter)
                local searchText = string.lower(filter or "")
                for _, opt in pairs(GetOptions()) do
                    if opt.nodes and opt.nodes[1] then
                        local optionName = string.lower(opt.Name)
                        local isVisible = searchText == "" or string.find(optionName, searchText, 1, true)
                        opt.nodes[1].Visible = isVisible
                    end
                end
                CalculateSize()
            end

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                FilterOptions(SearchBox.Text)
            end)

            Button.Activated:Connect(Minimize)

            NoClickFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch then
                    Disable(input)
                end
            end)

            MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                Disable()
            end)
            SelectedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(CalculatePos)

            Button.Activated:Connect(CalculateSize)
            ScrollFrame.ChildAdded:Connect(CalculateSize)
            ScrollFrame.ChildRemoved:Connect(CalculateSize)
            CalculatePos()
            CalculateSize()

            table.insert(bearlib.AllElements, {
                Name = DName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Dropdown = {}

            function Dropdown:Visible(...) Funcs:ToggleVisible(Button, ...) end

            function Dropdown:Destroy() Button:Destroy() end

            function Dropdown:Callback(...) Funcs:InsertCallback(Callback, ...)(Selected) end

            function Dropdown:Add(...)
                local NewOptions = {...}
                if type(NewOptions[1]) == "table" then
                    for _, Name in ipairs(NewOptions[1]) do
                        AddOption(Name, Name)
                    end
                else
                    for _, Name in ipairs(NewOptions) do
                        AddOption(Name, Name)
                    end
                end
            end

            function Dropdown:Remove(Option)
                for index, Value in pairs(GetOptions()) do
                    if type(Option) == "number" and index == Option or Value.Name == Option then
                        RemoveOption(index, Value.Value)
                    end
                end
            end

            function Dropdown:Select(Option)
                if type(Option) == "string" then
                    for _, Val in pairs(Options) do
                        if Val.Name == Option then
                            Select(Val)
                        end
                    end
                elseif type(Option) == "number" then
                    local i = 0
                    for _, Val in pairs(Options) do
                        i = i + 1
                        if i == Option then
                            Select(Val)
                        end
                    end
                end
            end

            function Dropdown:Set(Val1, Clear)
                if type(Val1) == "table" then
                    AddNewOptions(Val1, Clear)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
            end
            return Dropdown
        end

        -- ===== PROFILE =====
        function Tab:AddProfile(Configs)
            local PName = Configs[1] or Configs.Name or "User Name"
            local PBio = Configs[2] or Configs.Bio or "No bio yet."
            local PAvatar = Configs.Avatar or "rbxassetid://0"
            local PCover = Configs.Cover or "rbxassetid://0"
            local PVerified = Configs.Verified or false

            local ProfileHolder = Create("Frame", Container, {
                Size = UDim2.new(1, 0, 0, 100),
                BackgroundTransparency = 1,
                LayoutOrder = GetOrder(),
                Name = "Profile",
                ZIndex = 1
            })

            local Card = InsertTheme(Create("Frame", ProfileHolder, {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 1
            }), "Frame")
            Make("Corner", Card, UDim.new(0, 8))

            local ProfileStroke = InsertTheme(Create("UIStroke", Card, {
                Color = Theme["Color Profile Border"] or Theme["Color Stroke"],
                Thickness = Theme["Border Thickness"] or 1.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }), "Stroke")

            local CoverImg = Create("ImageLabel", Card, {
                Size = UDim2.new(1, 0, 0, 50),
                Image = PCover,
                ScaleType = Enum.ScaleType.Crop,
                BackgroundTransparency = 1,
                ZIndex = 1
            })
            Make("Corner", CoverImg, UDim.new(0, 8))

            local CoverFix = InsertTheme(Create("Frame", CoverImg, {
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 1, -5),
                BorderSizePixel = 0,
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 2
            }), "Frame")

            local AvatarImg = Create("ImageLabel", Card, {
                Size = UDim2.fromOffset(45, 45),
                Position = UDim2.new(0, 12, 0, 30),
                Image = PAvatar,
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 3
            })
            Make("Corner", AvatarImg, UDim.new(1, 0))

            local AvatarStroke = InsertTheme(Create("UIStroke", AvatarImg, {
                Thickness = 2,
                Color = Theme["Color Profile Border"] or Theme["Color Stroke"]
            }), "Stroke")

            local NameLabel = InsertTheme(Create("TextLabel", Card, {
                Position = UDim2.new(0, 65, 0, 50),
                Size = UDim2.new(1, -75, 0, 18),
                Text = PName,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"],
                TextSize = 13,
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                TextTruncate = "AtEnd",
                ZIndex = 3,
                TextStrokeTransparency = 0.3,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "Text")

            if PVerified then
                local VerifyIcon = Create("ImageLabel", Card, {
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.new(0, 65 + NameLabel.TextBounds.X + 4, 0, 52),
                    Image = "rbxassetid://10709752907",
                    ImageColor3 = Color3.fromRGB(60, 140, 255),
                    BackgroundTransparency = 1,
                    ZIndex = 4
                })
                NameLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    VerifyIcon.Position = UDim2.new(0, 65 + NameLabel.TextBounds.X + 4, 0, 52)
                end)
            end

            local BioLabel = InsertTheme(Create("TextLabel", Card, {
                Position = UDim2.new(0, 12, 0, 78),
                Size = UDim2.new(1, -24, 0, 16),
                Text = PBio,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme["Color Dark Text"],
                TextSize = 9,
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 3,
                TextStrokeTransparency = 0.4,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "DarkText")

            table.insert(bearlib.AllElements, {
                Name = PName .. " Profile",
                Instance = ProfileHolder,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Profile = {}
            function Profile:Visible(...) Funcs:ToggleVisible(ProfileHolder, ...) end
            function Profile:Destroy() ProfileHolder:Destroy() end
            function Profile:SetBio(NewBio) BioLabel.Text = NewBio end
            function Profile:SetBorderColor(NewColor)
                if typeof(NewColor) == "Color3" then
                    ProfileStroke.Color = NewColor
                    AvatarStroke.Color = NewColor
                end
            end
            return Profile
        end

        -- ===== DISCORD CARD (Single) =====
        function Tab:AddSingleDiscordCard(Configs)
            local Title = Configs.Title or Configs[1] or "Discord Server"
            local Description = Configs.Description or Configs.Desc or Configs[2] or ""
            local Logo = Configs.Logo or Configs.Icon or Configs[3] or "rbxassetid://0"
            local BannerColor = Configs.BannerColor or Configs.Banner or Configs[4] or Color3.fromRGB(88, 101, 242)
            local Online = Configs.Online or Configs[5] or 0
            local TotalMembers = Configs.Members or Configs[6] or 0
            local InviteLink = Configs.Invite or Configs.Link or Configs[7] or "https://discord.gg/example"
            local Verified = Configs.Verified or false

            local CardContainer = Create("Frame", Container, {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 150),
                LayoutOrder = GetOrder(),
                Name = "SingleDiscordCard",
                ZIndex = 1
            })

            local Card = InsertTheme(Create("Frame", CardContainer, {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 1
            }), "Frame")
            Make("Corner", Card, UDim.new(0, 8))

            local CardStroke = InsertTheme(Create("UIStroke", Card, {
                Color = Theme["Color Discord Border"] or Theme["Color Stroke"],
                Thickness = Theme["Border Thickness"] or 1.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }), "Stroke")

            local BannerImg = Create("ImageLabel", Card, {
                Size = UDim2.new(1, 0, 0, 60),
                Image = type(BannerColor) == "string" and BannerColor or "",
                ScaleType = Enum.ScaleType.Crop,
                BackgroundColor3 = type(BannerColor) == "Color3" and BannerColor or Color3.fromRGB(88, 101, 242),
                BackgroundTransparency = type(BannerColor) == "Color3" and 0 or 1,
                ZIndex = 1
            })
            Make("Corner", BannerImg, UDim.new(0, 8))

            local BannerFix = InsertTheme(Create("Frame", BannerImg, {
                Size = UDim2.new(1, 0, 0, 12),
                Position = UDim2.new(0, 0, 1, -6),
                BorderSizePixel = 0,
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 2
            }), "Frame")

            local AvatarImg = Create("ImageLabel", Card, {
                Size = UDim2.fromOffset(50, 50),
                Position = UDim2.new(0, 15, 0, 35),
                Image = Logo,
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 3
            })
            Make("Corner", AvatarImg, UDim.new(1, 0))

            local AvatarStroke = InsertTheme(Create("UIStroke", AvatarImg, {
                Thickness = 2.5,
                Color = Theme["Color Discord Border"] or Theme["Color Stroke"]
            }), "Stroke")

            local NameLabel = InsertTheme(Create("TextLabel", Card, {
                Position = UDim2.new(0, 75, 0, 48),
                Size = UDim2.new(1, -90, 0, 20),
                Text = Title,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"],
                TextSize = 14,
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                TextTruncate = "AtEnd",
                ZIndex = 3,
                TextStrokeTransparency = 0.3,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "Text")

            if Verified then
                local VerifyIcon = Create("ImageLabel", Card, {
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.new(0, 75 + NameLabel.TextBounds.X + 5, 0, 50),
                    Image = "rbxassetid://10709752907",
                    ImageColor3 = Color3.fromRGB(60, 140, 255),
                    BackgroundTransparency = 1,
                    ZIndex = 4
                })
                NameLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    VerifyIcon.Position = UDim2.new(0, 75 + NameLabel.TextBounds.X + 5, 0, 50)
                end)
            end

            local StatsContainer = Create("Frame", Card, {
                Position = UDim2.new(0, 75, 0, 70),
                Size = UDim2.new(1, -90, 0, 20),
                BackgroundTransparency = 1,
                ZIndex = 3
            })

            local StatsLayout = Create("UIListLayout", StatsContainer, {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 15)
            })

            local function AddStat(StatColor, StatText)
                local Stat = Create("Frame", StatsContainer, {
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    ZIndex = 3
                })

                local Dot = Create("Frame", Stat, {
                    Size = UDim2.fromOffset(8, 8),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = StatColor,
                    ZIndex = 4
                })
                Make("Corner", Dot, UDim.new(1, 0))

                local StatLabel = InsertTheme(Create("TextLabel", Stat, {
                    Size = UDim2.new(0, 0, 1, 0),
                    Position = UDim2.new(0, 12, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    TextSize = 10,
                    Text = StatText,
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme["Color Dark Text"],
                    ZIndex = 4,
                    TextStrokeTransparency = 0.4,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "DarkText")
            end

            if Online and Online > 0 then
                AddStat(Color3.fromRGB(0, 255, 0), tostring(Online) .. " Online")
            end

            if TotalMembers and TotalMembers > 0 then
                AddStat(Color3.fromRGB(88, 101, 242), tostring(TotalMembers) .. " Members")
            end

            local DescLabel = InsertTheme(Create("TextLabel", Card, {
                Position = UDim2.new(0, 75, 0, 95),
                Size = UDim2.new(1, -90, 0, 35),
                Text = Description,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme["Color Dark Text"],
                TextSize = 10,
                TextXAlignment = "Left",
                TextYAlignment = "Top",
                TextWrapped = true,
                BackgroundTransparency = 1,
                ZIndex = 3,
                TextStrokeTransparency = 0.4,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "DarkText")

            local ButtonContainer = Create("Frame", Card, {
                Size = UDim2.new(1, -30, 0, 30),
                Position = UDim2.new(0.5, 0, 1, -15),
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundTransparency = 1,
                ZIndex = 3
            })

            local JoinButton = InsertTheme(Create("TextButton", ButtonContainer, {
                Size = UDim2.new(1, 0, 1, 0),
                Text = "Join Discord",
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                BackgroundColor3 = Color3.fromRGB(88, 101, 242),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 4,
                TextStrokeTransparency = 0.3,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "Text")
            Make("Corner", JoinButton, UDim.new(0.5, 0))

            local LastClick = 0
            JoinButton.Activated:Connect(function()
                if tick() - LastClick < 3 then return end
                LastClick = tick()
                local OriginalText = JoinButton.Text
                JoinButton.Text = "Copied!"
                setclipboard(InviteLink)
                task.wait(1.5)
                JoinButton.Text = OriginalText
            end)

            local function AdjustDescriptionHeight()
                local textBounds = DescLabel.TextBounds.Y
                if textBounds > 35 then
                    DescLabel.Size = UDim2.new(1, -90, 0, textBounds + 5)
                    ButtonContainer.Position = UDim2.new(0.5, 0, 1, -(15 + (textBounds - 35)))
                end
            end

            DescLabel:GetPropertyChangedSignal("Text"):Connect(AdjustDescriptionHeight)
            task.spawn(AdjustDescriptionHeight)

            table.insert(bearlib.AllElements, {
                Name = Title .. " Discord Card",
                Instance = CardContainer,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local CardObj = {}

            function CardObj:SetTitle(NewTitle)
                NameLabel.Text = NewTitle
            end

            function CardObj:SetDescription(NewDesc)
                DescLabel.Text = NewDesc
            end

            function CardObj:SetIcon(NewIcon)
                AvatarImg.Image = NewIcon
            end

            function CardObj:SetStats(NewOnline, NewMembers)
                for _, child in ipairs(StatsContainer:GetChildren()) do
                    if child:IsA("Frame") and child ~= StatsLayout then
                        child:Destroy()
                    end
                end

                if NewOnline and NewOnline > 0 then
                    AddStat(Color3.fromRGB(0, 255, 0), tostring(NewOnline) .. " Online")
                end

                if NewMembers and NewMembers > 0 then
                    AddStat(Color3.fromRGB(88, 101, 242), tostring(NewMembers) .. " Members")
                end
            end

            function CardObj:SetBanner(NewBanner)
                if type(NewBanner) == "string" then
                    BannerImg.Image = NewBanner
                    BannerImg.BackgroundTransparency = 1
                elseif typeof(NewBanner) == "Color3" then
                    BannerImg.BackgroundColor3 = NewBanner
                    BannerImg.BackgroundTransparency = 0
                    BannerImg.Image = ""
                end
            end

            function CardObj:SetInviteLink(NewLink)
                InviteLink = NewLink
            end

            function CardObj:SetVerified(IsVerified)
                Verified = IsVerified
            end

            function CardObj:Visible(...) 
                Funcs:ToggleVisible(CardContainer, ...) 
            end

            function CardObj:Destroy() 
                CardContainer:Destroy() 
            end

            return CardObj
        end

        -- ===== DISCORD INVITE CONTAINER (2 Cards) =====
        function Tab:AddDiscordInvite(Configs)
            local ContainerFrame = Create("Frame", Container, {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 150),
                LayoutOrder = GetOrder(),
                Name = "DiscordInviteContainer",
                ZIndex = 1
            })

            local ListLayout = Create("UIListLayout", ContainerFrame, {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 12),
                SortOrder = "LayoutOrder"
            })

            local function createDiscordCard(cardConfigs, layoutOrder)
                local BName = cardConfigs[1] or cardConfigs.Name or cardConfigs.Title or "Discord Server"
                local BDescription = cardConfigs[2] or cardConfigs.Description or cardConfigs.Desc or ""
                local Logo = cardConfigs[3] or cardConfigs.Icon or cardConfigs.Logo or cardConfigs.Image or ""
                local BannerColor = cardConfigs[4] or cardConfigs.Banner or cardConfigs.BannerColor or Color3.fromRGB(88, 101, 242)
                local Online = cardConfigs[5] or cardConfigs.Online or cardConfigs.MembersOnline
                local TotalMembers = cardConfigs[6] or cardConfigs.Members or cardConfigs.TotalMembers
                local InviteLink = cardConfigs[7] or cardConfigs.Invite or cardConfigs.Link or "https://discord.gg/example"

                assert(type(InviteLink) == "string", "\"Tab.AddDiscordInvite.Invite\". 'string' expected, got " .. typeof(InviteLink))

                local CardFrame = Create("Frame", ContainerFrame, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.5, -6, 1, -15),
                    LayoutOrder = layoutOrder,
                    Name = "DiscordCard_" .. layoutOrder,
                    ZIndex = 1
                })

                local Card = InsertTheme(Create("Frame", CardFrame, {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ClipsDescendants = true,
                    ZIndex = 1
                }), "Frame")
                Make("Corner", Card, UDim.new(0, 10))

                local Gradient = Make("Gradient", Card, 45)

                local StrokeFrame = Create("Frame", CardFrame, {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 2
                })

                local Stroke = InsertTheme(Create("UIStroke", StrokeFrame, {
                    Color = Theme["Color Discord Border"] or Theme["Color Stroke"],
                    Thickness = Theme["Border Thickness"] or 1.5,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }), "Stroke")
                Make("Corner", StrokeFrame, UDim.new(0, 10))

                local BannerImage = Create("ImageLabel", Card, {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Size = UDim2.fromScale(1, 0.3),
                    BackgroundTransparency = 1,
                    ZIndex = 1
                })
                Make("Corner", BannerImage, UDim.new(0, 10))

                local ServerIcon = Create("ImageLabel", Card, {
                    Size = UDim2.fromOffset(35, 35),
                    Position = UDim2.new(0, 12, 0.3, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = Logo,
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 2
                })
                Make("Corner", ServerIcon, UDim.new(0, 8))

                local IconStroke = InsertTheme(Create("UIStroke", ServerIcon, {
                    Thickness = 2,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Theme["Color Discord Border"] or Theme["Color Stroke"]
                }), "Stroke")

                local ServerName = InsertTheme(Create("TextLabel", Card, {
                    Size = UDim2.new(1, -20, 0, 12),
                    Position = UDim2.new(0, 12, 0.46, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    TextSize = 12,
                    Text = BName,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme["Color Discord Text"],
                    ZIndex = 3,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")

                local StatsFrame
                if Online or TotalMembers then
                    StatsFrame = Create("Frame", Card, {
                        Size = UDim2.new(1, -20, 0, 10),
                        Position = UDim2.new(0, 0, 0.54, 0),
                        BackgroundTransparency = 1,
                        ZIndex = 2
                    })

                    local StatsLayout = Create("UIListLayout", StatsFrame, {
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 6)
                    })

                    local function AddStat(StatColor, Text)
                        local Stat = Create("Frame", StatsFrame, {
                            Size = UDim2.fromScale(0, 1),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            ZIndex = 2
                        })

                        local Dot = Create("Frame", Stat, {
                            Size = UDim2.fromOffset(4, 4),
                            Position = UDim2.new(0, 5, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundColor3 = StatColor,
                            BackgroundTransparency = 0,
                            ZIndex = 3
                        })
                        Make("Corner", Dot, UDim.new(1, 0))

                        InsertTheme(Create("TextLabel", Stat, {
                            Size = UDim2.new(0, 0, 1, 0),
                            Position = UDim2.new(0, 14, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            TextSize = 8,
                            Text = Text,
                            Font = Enum.Font.Gotham,
                            TextColor3 = Theme["Color Discord Stats"],
                            ZIndex = 4,
                            TextStrokeTransparency = 0.4,
                            TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        }), "DarkText")
                    end

                    if Online ~= nil then
                        AddStat(Color3.fromRGB(0, 255, 0), tostring(Online) .. " Online")
                    end
                    if TotalMembers ~= nil then
                        AddStat(Color3.fromRGB(88, 101, 242), tostring(TotalMembers) .. " Members")
                    end
                end

                local Description = InsertTheme(Create("TextLabel", Card, {
                    Size = UDim2.new(1, -50, 0, 10),
                    Position = UDim2.new(0, 12, StatsFrame and 0.62 or 0.58, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    TextSize = 9,
                    Text = BDescription,
                    TextWrapped = true,
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme["Color Dark Text"],
                    ZIndex = 3,
                    TextStrokeTransparency = 0.4,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")

                local ButtonContainer = Create("Frame", Card, {
                    Size = UDim2.new(1, 0, 0.3, 0),
                    Position = UDim2.fromScale(0, 1),
                    AnchorPoint = Vector2.new(0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 2
                })

                if #Description.Text > 0 then
                    ButtonContainer.Size = UDim2.new(1, 0, 0.4, 0)
                    Create("UIGradient", ButtonContainer, {
                        Rotation = -90,
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0.00, 0.00),
                            NumberSequenceKeypoint.new(0.60, 0.00),
                            NumberSequenceKeypoint.new(1.00, 1.00)
                        }
                    })
                end

                local JoinButton = InsertTheme(Create("TextButton", ButtonContainer, {
                    Position = UDim2.new(0.5, 0, 1, -10),
                    Size = UDim2.new(1, -20, 0, 20),
                    AnchorPoint = Vector2.new(0.5, 1),
                    Text = "Join",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    BackgroundColor3 = Color3.fromRGB(37, 128, 69),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 4,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")
                Make("Corner", JoinButton, UDim.new(0.5, 0))

                local LastClick = 0
                JoinButton.Activated:Connect(function()
                    if tick() - LastClick < 5 then return end
                    LastClick = tick()
                    local OriginalText = JoinButton.Text
                    JoinButton.Text = "Copied!"
                    setclipboard(InviteLink)
                    task.wait(2)
                    JoinButton.Text = OriginalText
                end)

                if type(BannerColor) == "string" then
                    BannerImage.ScaleType = Enum.ScaleType.Crop
                    BannerImage.Image = BannerColor
                elseif typeof(BannerColor) == "Color3" then
                    BannerImage.BackgroundTransparency = 0
                    BannerImage.BackgroundColor3 = BannerColor
                end

                return {
                    Frame = CardFrame,
                    Card = Card,
                    Name = ServerName,
                    Description = Description,
                    JoinButton = JoinButton,
                    Configs = cardConfigs,
                    StrokeFrame = StrokeFrame,
                    Stroke = Stroke
                }
            end

            local card1, card2

            if Configs[1] and type(Configs[1]) == "table" then
                card1 = createDiscordCard(Configs[1], 1)
                if Configs[2] and type(Configs[2]) == "table" then
                    card2 = createDiscordCard(Configs[2], 2)
                else
                    card2 = createDiscordCard({
                        "Empty Server",
                        "Add your second Discord server here",
                        "",
                        Color3.fromRGB(50, 50, 50),
                        0,
                        0,
                        "https://discord.gg/example"
                    }, 2)
                end
            else
                card1 = createDiscordCard(Configs, 1)
                card2 = createDiscordCard({
                    "Empty Server",
                    "Add your second Discord server here",
                    "",
                    Color3.fromRGB(50, 50, 50),
                    0,
                    0,
                    "https://discord.gg/example"
                }, 2)
            end

            table.insert(bearlib.AllElements, {
                Name = "Discord Invite Container",
                Instance = ContainerFrame,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local DiscordInviteContainer = {}
            function DiscordInviteContainer:Visible(Bool)
                if Bool == nil then
                    ContainerFrame.Visible = not ContainerFrame.Visible
                else
                    ContainerFrame.Visible = Bool
                end
            end
            function DiscordInviteContainer:Destroy()
                ContainerFrame:Destroy()
            end
            function DiscordInviteContainer:UpdateCard1(NewConfigs)
                if card1 then
                    card1.Frame:Destroy()
                    card1 = createDiscordCard(NewConfigs, 1)
                end
            end
            function DiscordInviteContainer:UpdateCard2(NewConfigs)
                if card2 then
                    card2.Frame:Destroy()
                    card2 = createDiscordCard(NewConfigs, 2)
                end
            end
            function DiscordInviteContainer:GetCard1()
                return card1
            end
            function DiscordInviteContainer:GetCard2()
                return card2
            end
            return DiscordInviteContainer
        end

        -- ===== DISCORD INVITE OLD (Phiên bản cũ) =====
        function Tab:AddDiscordInviteOld(Configs)
            local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
            local Desc = Configs[2] or Configs.Desc or Configs.Description or ""
            local Logo = Configs[3] or Configs.Logo or ""
            local Invite = Configs[4] or Configs.Invite or ""

            local InviteHolder = Create("Frame", Container, {
                Size = UDim2.new(1, 0, 0, 65),
                Name = "Option",
                BackgroundTransparency = 1,
                LayoutOrder = GetOrder(),
                ZIndex = 1
            })

            local FrameHolder = InsertTheme(Create("Frame", InviteHolder, {
                Size = UDim2.new(1, 0, 0, 65),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 1
            }), "Frame")
            Make("Corner", FrameHolder)

            local ImageLabel = Create("ImageLabel", FrameHolder, {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(0, 7, 0, 7),
                Image = Logo,
                BackgroundTransparency = 1,
                ZIndex = 3
            })
            Make("Corner", ImageLabel, UDim.new(0, 4))
            Make("Stroke", ImageLabel)

            local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
                Size = UDim2.new(1, -52, 0, 15),
                Position = UDim2.new(0, 44, 0, 7),
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"],
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                TextSize = 10,
                Text = Title,
                ZIndex = 3,
                TextStrokeTransparency = 0.3,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "Text")

            local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
                Size = UDim2.new(1, -52, 0, 0),
                Position = UDim2.new(0, 44, 0, 22),
                TextWrapped = "Y",
                AutomaticSize = "Y",
                Font = Enum.Font.Gotham,
                TextColor3 = Theme["Color Dark Text"],
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                TextSize = 8,
                Text = Desc,
                ZIndex = 3,
                TextStrokeTransparency = 0.4,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            }), "DarkText")

            local JoinButton = Create("TextButton", FrameHolder, {
                Size = UDim2.new(1, -14, 0, 16),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -7),
                Text = "Copy Link",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                BackgroundColor3 = Color3.fromRGB(50, 150, 50),
                ZIndex = 4,
                TextStrokeTransparency = 0.3,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            })
            Make("Corner", JoinButton, UDim.new(0, 5))

            local ClickDelay
            JoinButton.Activated:Connect(function()
                setclipboard(Invite)
                if ClickDelay then return end

                ClickDelay = true
                SetProps(JoinButton, {
                    Text = "Copied to Clipboard",
                    BackgroundColor3 = Color3.fromRGB(100, 100, 100),
                    TextColor3 = Color3.fromRGB(150, 150, 150)
                }) task.wait(5)
                SetProps(JoinButton, {
                    Text = "Copy Link",
                    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
                    TextColor3 = Color3.fromRGB(220, 220, 220)
                }) ClickDelay = false
            end)

            table.insert(bearlib.AllElements, {
                Name = Title,
                Instance = InviteHolder,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local DiscordInvite = {}
            function DiscordInvite:Destroy() InviteHolder:Destroy() end
            function DiscordInvite:Visible(...) Funcs:ToggleVisible(InviteHolder, ...) end
            return DiscordInvite
        end

        return Tab
    end

    function Window:MakeTabGroup(Configs)
        -- Tab Group functionality (same as before)
        local TName = Configs[1] or Configs.Title or Configs.Name or "Group"
        local TIcon = Configs[2] or Configs.Icon or ""

        TIcon = bearlib:GetIcon(TIcon)
        if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
            TIcon = false
        end

        TabLayoutOrder = TabLayoutOrder + 1

        local GroupContainer = Create("Frame", MainScroll, {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Name = "GroupContainer_" .. TName,
            LayoutOrder = TabLayoutOrder,
            ClipsDescendants = false
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 1),
                SortOrder = "LayoutOrder"
            })
        })

        local GroupButton = Create("Frame", GroupContainer, {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Name = "GroupButton",
            Active = true,
            LayoutOrder = 1
        })
        Make("Corner", GroupButton)

        local ArrowLabel = InsertTheme(Create("TextLabel", GroupButton, {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -15, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "›",
            TextColor3 = Theme["Color Text"],
            TextSize = 14,
            TextTransparency = 0.3,
            ZIndex = 5,
            Name = "Arrow"
        }), "TabGroupArrow")

        local GroupTitle = InsertTheme(Create("TextLabel", GroupButton, {
            Size = UDim2.new(1, TIcon and -40 or -30, 1),
            Position = UDim2.fromOffset(TIcon and 25 or 10, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = TName,
            TextColor3 = Theme["Color Text"],
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.3,
            TextTruncate = "AtEnd",
            ZIndex = 5
        }), "Text")

        local GroupIcon
        if TIcon then
            GroupIcon = InsertTheme(Create("ImageLabel", GroupButton, {
                Position = UDim2.new(0, 8, 0.5),
                Size = UDim2.new(0, 13, 0, 13),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = TIcon or "",
                BackgroundTransparency = 1,
                ImageTransparency = 0.3,
                ImageColor3 = Theme["Color Text"],
                ZIndex = 5
            }), "Text")
        end

        local isExpanded = false
        local SubTabs = {}

        local GroupData = {
            TabSelect = GroupButton,
            GroupContainer = GroupContainer,
            SubTabs = SubTabs,
            Arrow = ArrowLabel,
            GroupTitle = GroupTitle,
            GroupIcon = GroupIcon,
            isExpanded = false
        }
        table.insert(bearlib.TabGroups, GroupData)

        ForceUpdateScrollLayout()

        local function UpdateGroupContainerSize()
            if isExpanded then
                local subTabCount = #SubTabs
                local totalHeight = 24 + (subTabCount * 21) + (subTabCount > 0 and 1 or 0)
                GroupContainer.Size = UDim2.new(1, 0, 0, totalHeight)
            else
                GroupContainer.Size = UDim2.new(1, 0, 0, 24)
            end
        end

        local function ToggleExpand()
            isExpanded = not isExpanded
            GroupData.isExpanded = isExpanded

            for _, subTab in ipairs(SubTabs) do
                subTab.Button.Visible = isExpanded
            end

            if isExpanded then
                CreateTween({ArrowLabel, "Rotation", 90, 0.25})
                CreateTween({ArrowLabel, "TextTransparency", 0, 0.25})
                CreateTween({GroupTitle, "TextTransparency", 0, 0.25})
                if GroupIcon then
                    CreateTween({GroupIcon, "ImageTransparency", 0, 0.25})
                end
            else
                CreateTween({ArrowLabel, "Rotation", 0, 0.25})
                CreateTween({ArrowLabel, "TextTransparency", 0.3, 0.25})
                CreateTween({GroupTitle, "TextTransparency", 0.3, 0.25})
                if GroupIcon then
                    CreateTween({GroupIcon, "ImageTransparency", 0.3, 0.25})
                end
            end

            UpdateGroupContainerSize()

            task.wait(0.35)
            MainScroll.CanvasSize = UDim2.new(0, 0, 0, MainScroll:FindFirstChildOfClass("UIListLayout") and MainScroll:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y or 0)
        end

        local isDragging = false
        local dragStartPos = nil
        local dragThreshold = 5

        GroupButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
                dragStartPos = Input.Position
            end
        end)

        GroupButton.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if not isDragging and dragStartPos then
                    local delta = (Input.Position - dragStartPos).Magnitude
                    if delta < dragThreshold then
                        ToggleExpand()
                    end
                end
                isDragging = false
                dragStartPos = nil
            end
        end)

        MainScroll.InputChanged:Connect(function(Input)
            if dragStartPos and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local delta = (Input.Position - dragStartPos).Magnitude
                if delta > dragThreshold then
                    isDragging = true
                end
            end
        end)

        local TabGroup = {}

        function TabGroup:AddTab(Configs)
            if type(Configs) == "table" and Configs[1] == nil then
                Configs = Configs
            end
            local TName = Configs[1] or Configs.Title or "SubTab!"
            local TIcon = Configs[2] or Configs.Icon or ""

            TIcon = bearlib:GetIcon(TIcon)
            if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
                TIcon = false
            end

            local Container = InsertTheme(Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 1),
                AnchorPoint = Vector2.new(0, 1),
                ScrollBarThickness = 1.5,
                BackgroundTransparency = 1,
                ScrollBarImageTransparency = 0.2,
                ScrollBarImageColor3 = Theme["Color Theme"],
                AutomaticCanvasSize = "Y",
                ScrollingDirection = "Y",
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                Name = ("SubContainer %i [ %s ]"):format(#ContainerList + 1, TName),
                ZIndex = 1
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 15),
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10)
                }), Create("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    SortOrder = "LayoutOrder"
                })
            }), "ScrollBar")

            table.insert(ContainerList, Container)

            local SubTabButton = Create("Frame", GroupContainer, {
                Size = UDim2.new(1, -25, 0, 20),
                Position = UDim2.new(0, 23, 0, 0),
                BackgroundTransparency = 1,
                Name = "SubTabButton_" .. TName,
                Active = true,
                Visible = false,
                LayoutOrder = #SubTabs + 2
            })

            local DotIndicator = Create("Frame", SubTabButton, {
                Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme["Color Hub 3"],
                BackgroundTransparency = 1,
                ZIndex = 4,
                Name = "DotIndicator"
            })
            Instance.new("UICorner", DotIndicator).CornerRadius = UDim.new(1, 0)

            local SubLabelTitle = InsertTheme(Create("TextLabel", SubTabButton, {
                Size = UDim2.new(1, -14, 1),
                Position = UDim2.fromOffset(10, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = TName,
                TextColor3 = Theme["Color Text"],
                TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.5,
                TextTruncate = "AtEnd",
                ZIndex = 4
            }), "Text")

            table.insert(SubTabs, {
                Button = SubTabButton,
                Container = Container,
                TitleLabel = SubLabelTitle,
                DotIndicator = DotIndicator
            })

            Container.Parent = nil

            local function SelectSubTab()
                if Container.Parent then return end

                for _, Frame in pairs(ContainerList) do
                    if Frame:IsA("ScrollingFrame") and Frame ~= Container then
                        Frame.Parent = nil
                    end
                end

                table.foreach(bearlib.Tabs, function(_, Tab)
                    if Tab.Cont ~= Container then
                        Tab.func:Disable()
                    end
                end)

                for _, subTab in ipairs(SubTabs) do
                    if subTab.Container ~= Container then
                        CreateTween({subTab.TitleLabel, "TextTransparency", 0.5, 0.25})
                        CreateTween({subTab.DotIndicator, "BackgroundTransparency", 1, 0.25})
                    end
                end

                Container.Parent = Containers
                Container.Size = UDim2.new(1, 0, 1, 150)

                CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
                CreateTween({SubLabelTitle, "TextTransparency", 0, 0.35})
                CreateTween({DotIndicator, "BackgroundTransparency", 0, 0.35})
            end

            local subIsDragging = false
            local subDragStartPos = nil
            local subDragThreshold = 5

            SubTabButton.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    subIsDragging = false
                    subDragStartPos = Input.Position
                end
            end)

            SubTabButton.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if not subIsDragging and subDragStartPos then
                        local delta = (Input.Position - subDragStartPos).Magnitude
                        if delta < subDragThreshold then
                            SelectSubTab()
                        end
                    end
                    subIsDragging = false
                    subDragStartPos = nil
                end
            end)

            MainScroll.InputChanged:Connect(function(Input)
                if subDragStartPos and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = (Input.Position - subDragStartPos).Magnitude
                    if delta > subDragThreshold then
                        subIsDragging = true
                    end
                end
            end)

            local SubTab = {}
            table.insert(bearlib.Tabs, {
                TabInfo = {Name = TName, Icon = TIcon, IsSubTab = true, GroupName = TName},
                func = SubTab,
                Cont = Container,
                BorderGradient = nil,
                BorderStroke = nil
            })
            SubTab.Cont = Container

            local CurrentSectionName = nil
            local ElementCount = 0

            local function GetOrder()
                ElementCount = ElementCount + 1
                return ElementCount
            end

            function SubTab:Disable()
                Container.Parent = nil
                CreateTween({SubLabelTitle, "TextTransparency", 0.5, 0.35})
                CreateTween({DotIndicator, "BackgroundTransparency", 1, 0.35})
            end

            function SubTab:Enable()
                if not isExpanded then
                    ToggleExpand()
                end
                SelectSubTab()
            end

            function SubTab:Visible(Bool)
                Funcs:ToggleVisible(SubTabButton, Bool)
                if not Bool then
                    Container.Parent = nil
                end
            end

            function SubTab:Destroy()
                SubTabButton:Destroy()
                Container:Destroy()
                for i, st in ipairs(SubTabs) do
                    if st.Container == Container then
                        table.remove(SubTabs, i)
                        break
                    end
                end
                UpdateGroupContainerSize()
            end

            -- Add all element functions to SubTab
            function SubTab:AddSection(Configs)
                local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
                CurrentSectionName = SectionName

                local SectionFrame = Create("Frame", Container, {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Name = "Option",
                    LayoutOrder = GetOrder(),
                    ZIndex = 2
                })

                local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
                    Font = Enum.Font.GothamBold,
                    Text = SectionName,
                    TextColor3 = Theme["Color Text"],
                    Size = UDim2.new(1, -25, 0, 18),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    TextTruncate = "AtEnd",
                    TextSize = 14,
                    TextXAlignment = "Left",
                    ZIndex = 3
                }), "Text")

                table.insert(bearlib.AllElements, {
                    Name = SectionName,
                    Instance = SectionFrame,
                    OriginalParent = Container,
                    SectionName = SectionName,
                    Underline = nil,
                    UnderlineGradient = nil
                })

                local Section = {}
                table.insert(bearlib.Options, {type = "Section", Name = SectionName, func = Section})

                function Section:Visible(Bool)
                    if Bool == nil then
                        SectionFrame.Visible = not SectionFrame.Visible
                        return
                    end
                    SectionFrame.Visible = Bool
                end

                function Section:Destroy()
                    SectionFrame:Destroy()
                end

                function Section:Set(New)
                    if New then
                        SectionLabel.Text = GetStr(New)
                    end
                end

                return Section
            end

            function SubTab:AddParagraph(Configs)
                local PName = Configs[1] or Configs.Title or "Paragraph"
                local PDesc = Configs[2] or Configs.Text or ""

                local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
                Frame.LayoutOrder = GetOrder()

                table.insert(bearlib.AllElements, {
                    Name = PName,
                    Instance = Frame,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local Paragraph = {}

                function Paragraph:Visible(...) Funcs:ToggleVisible(Frame, ...) end

                function Paragraph:Destroy() Frame:Destroy() end

                function Paragraph:SetTitle(Val)
                    LabelFunc:SetTitle(GetStr(Val))
                end

                function Paragraph:SetDesc(Val)
                    LabelFunc:SetDesc(GetStr(Val))
                end

                function Paragraph:Set(Val1, Val2)
                    if Val1 and Val2 then
                        LabelFunc:SetTitle(GetStr(Val1))
                        LabelFunc:SetDesc(GetStr(Val2))
                    elseif Val1 then
                        LabelFunc:SetDesc(GetStr(Val1))
                    end
                end
                return Paragraph
            end

            function SubTab:AddButton(Configs)
                local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
                local BDescription = Configs.Desc or Configs.Description or ""
                local Callback = Funcs:GetCallback(Configs, 2)

                local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
                FButton.LayoutOrder = GetOrder()

                local ButtonIcon = Create("ImageLabel", FButton, {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -10, 0.5),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://10709791437",
                    ZIndex = 5
                })

                FButton.Activated:Connect(function()
                    Funcs:FireCallback(Callback)
                end)

                table.insert(bearlib.AllElements, {
                    Name = BName,
                    Instance = FButton,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local Button = {}

                function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end

                function Button:Destroy() FButton:Destroy() end

                function Button:Callback(...) Funcs:InsertCallback(Callback, ...)() end

                function Button:Set(Val1, Val2)
                    if type(Val1) == "string" and type(Val2) == "string" then
                        LabelFunc:SetTitle(Val1)
                        LabelFunc:SetDesc(Val2)
                    elseif type(Val1) == "string" then
                        LabelFunc:SetTitle(Val1)
                    elseif type(Val1) == "function" then
                        Callback = Val1
                    end
                end
                return Button
            end

            function SubTab:AddToggle(Configs)
                local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
                local TDesc = Configs.Desc or Configs.Description or ""
                local Callback = Funcs:GetCallback(Configs, 3)
                local Flag = Configs[4] or Configs.Flag or false
                local Default = Configs[2] or Configs.Default or false
                if CheckFlag(Flag) then Default = GetFlag(Flag) end

                local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
                Button.LayoutOrder = GetOrder()

                local ToggleHolder = InsertTheme(Create("Frame", Button, {
                    Size = UDim2.new(0, 35, 0, 18),
                    Position = UDim2.new(1, -10, 0.5),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme["Color Toggle Off"],
                    ZIndex = 4
                }), "Stroke")
                Make("Corner", ToggleHolder, UDim.new(0.5, 0))

                local Slider = Create("Frame", ToggleHolder, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.8, 0, 0.8, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex = 4
                })

                local Toggle = InsertTheme(Create("Frame", Slider, {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 0, 0.5),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Theme["Color Toggle Knob Off"],
                    ZIndex = 5
                }), "Theme")
                Make("Corner", Toggle, UDim.new(0.5, 0))

                local WaitClick
                local function SetToggle(Val)
                    if WaitClick then return end

                    WaitClick, Default = true, Val
                    SetFlag(Flag, Default)
                    Funcs:FireCallback(Callback, Default)
                    if Default then
                        CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25})
                        CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob On"], 0.25})
                        CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25})
                        CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle On"], 0.25})
                    else
                        CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25})
                        CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob Off"], 0.25})
                        CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25})
                        CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle Off"], 0.25})
                    end
                    WaitClick = false
                end
                task.spawn(SetToggle, Default)

                Button.Activated:Connect(function()
                    SetToggle(not Default)
                end)

                table.insert(bearlib.AllElements, {
                    Name = TName,
                    Instance = Button,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local ToggleObj = {}

                function ToggleObj:Visible(...) Funcs:ToggleVisible(Button, ...) end

                function ToggleObj:Destroy() Button:Destroy() end

                function ToggleObj:Callback(...) Funcs:InsertCallback(Callback, ...)() end

                function ToggleObj:Set(Val1, Val2)
                    if type(Val1) == "string" and type(Val2) == "string" then
                        LabelFunc:SetTitle(Val1)
                        LabelFunc:SetDesc(Val2)
                    elseif type(Val1) == "string" then
                        LabelFunc:SetTitle(Val1)
                    elseif type(Val1) == "boolean" then
                        if WaitClick and Val2 then
                            repeat task.wait() until not WaitClick
                        end
                        task.spawn(SetToggle, Val1)
                    elseif type(Val1) == "function" then
                        Callback = Val1
                    end
                end
                return ToggleObj
            end

            function SubTab:AddSlider(Configs)
                local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
                local SDesc = Configs.Desc or Configs.Description or ""
                local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
                local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
                local Increase = Configs[4] or Configs.Increase or 1
                local Callback = Funcs:GetCallback(Configs, 6)
                local Flag = Configs[7] or Configs.Flag or false
                local Default = Configs[5] or Configs.Default or 25
                if CheckFlag(Flag) then Default = GetFlag(Flag) end
                Min, Max = Min / Increase, Max / Increase

                local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))
                Button.LayoutOrder = GetOrder()

                local SliderHolder = Create("TextButton", Button, {
                    Size = UDim2.new(0.45, 0, 1),
                    Position = UDim2.new(1),
                    AnchorPoint = Vector2.new(1, 0),
                    AutoButtonColor = false,
                    Text = "",
                    BackgroundTransparency = 1,
                    ZIndex = 4
                })

                local SliderBar = InsertTheme(Create("Frame", SliderHolder, {
                    BackgroundColor3 = Theme["Color Stroke"],
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0.5, 0, 0.5),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex = 4
                }), "Stroke") Make("Corner", SliderBar)

                local Indicator = InsertTheme(Create("Frame", SliderBar, {
                    BackgroundColor3 = Theme["Color Theme"],
                    Size = UDim2.fromScale(0.3, 1),
                    BorderSizePixel = 0,
                    ZIndex = 5
                }), "Theme") Make("Corner", Indicator)

                local SliderIcon = Create("Frame", SliderBar, {
                    Size = UDim2.new(0, 6, 0, 12),
                    BackgroundColor3 = Color3.fromRGB(220, 220, 220),
                    Position = UDim2.fromScale(0.3, 0.5),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 0.2,
                    ZIndex = 6
                }) Make("Corner", SliderIcon)

                local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, {
                    Size = UDim2.new(0, 14, 0, 14),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(0, 0, 0.5),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme["Color Text"],
                    Font = Enum.Font.FredokaOne,
                    TextSize = 12,
                    ZIndex = 5
                }), "Text")

                local UIScaleObj = Create("UIScale", LabelVal)

                local BaseMousePos = Create("Frame", SliderBar, {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Visible = false
                })

                local function UpdateLabel(NewValue)
                    local Number = tonumber(NewValue * Increase)
                    Number = math.floor(Number * 100) / 100

                    Default, LabelVal.Text = Number, tostring(Number)
                    Funcs:FireCallback(Callback, Default)
                end

                local function ControlPos()
                    local MousePos = Player:GetMouse()
                    local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
                    local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X

                    SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
                end

                local function UpdateValues()
                    Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
                    local SliderPos = SliderIcon.Position.X.Scale
                    local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
                    UpdateLabel(NewValue)
                end

                SliderHolder.MouseButton1Down:Connect(function()
                    CreateTween({SliderIcon, "BackgroundTransparency", 0, 0.3})
                    Container.ScrollingEnabled = false
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
                        ControlPos()
                    end
                    CreateTween({SliderIcon, "BackgroundTransparency", 0.2, 0.3})
                    Container.ScrollingEnabled = true
                    SetFlag(Flag, Default)
                end)

                LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
                    UIScaleObj.Scale = 0.3
                    CreateTween({UIScaleObj, "Scale", 1.2, 0.1})
                    CreateTween({LabelVal, "Rotation", math.random(-1, 1) * 5, 0.15, true})
                    CreateTween({UIScaleObj, "Scale", 1, 0.2})
                    CreateTween({LabelVal, "Rotation", 0, 0.1})
                end)

                function SetSlider(NewValue)
                    if type(NewValue) ~= "number" then return end

                    local MinVal, MaxVal = Min * Increase, Max * Increase

                    local SliderPos = (NewValue - MinVal) / (MaxVal - MinVal)

                    SetFlag(Flag, NewValue)
                    CreateTween({SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true})
                end
                SetSlider(Default)

                SliderIcon:GetPropertyChangedSignal("Position"):Connect(UpdateValues) UpdateValues()

                table.insert(bearlib.AllElements, {
                    Name = SName,
                    Instance = Button,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local Slider = {}

                function Slider:Set(NewVal1, NewVal2)
                    if NewVal1 and NewVal2 then
                        LabelFunc:SetTitle(NewVal1)
                        LabelFunc:SetDesc(NewVal2)
                    elseif type(NewVal1) == "string" then
                        LabelFunc:SetTitle(NewVal1)
                    elseif type(NewVal1) == "function" then
                        Callback = NewVal1
                    elseif type(NewVal1) == "number" then
                        SetSlider(NewVal1)
                    end
                end

                function Slider:Callback(...) Funcs:InsertCallback(Callback, ...)(tonumber(Default)) end

                function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end

                function Slider:Destroy() Button:Destroy() end
                return Slider
            end

            function SubTab:AddTextBox(Configs)
                local TName = Configs[1] or Configs.Name or Configs.Title or "Text Box"
                local TDesc = Configs.Desc or Configs.Description or ""
                local TDefault = Configs[2] or Configs.Default or ""
                local TPlaceholderText = Configs[5] or Configs.PlaceholderText or "Input"
                local TClearText = Configs[3] or Configs.ClearText or false
                local Callback = Funcs:GetCallback(Configs, 4)

                if type(TDefault) ~= "string" or TDefault:gsub(" ", ""):len() < 1 then
                    TDefault = false
                end

                local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
                Button.LayoutOrder = GetOrder()

                local SelectedFrame = InsertTheme(Create("Frame", Button, {
                    Size = UDim2.new(0, 150, 0, 18),
                    Position = UDim2.new(1, -10, 0.5),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme["Color Stroke"],
                    ZIndex = 4
                }), "Stroke") Make("Corner", SelectedFrame, UDim.new(0, 4))

                local TextBoxInput = InsertTheme(Create("TextBox", SelectedFrame, {
                    Size = UDim2.new(0.85, 0, 0.85, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextScaled = true,
                    TextColor3 = Theme["Color Text"],
                    ClearTextOnFocus = TClearText,
                    PlaceholderText = TPlaceholderText,
                    Text = "",
                    ZIndex = 5,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")

                local Pencil = Create("ImageLabel", SelectedFrame, {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, -5, 0.5),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Image = "rbxassetid://15637081879",
                    BackgroundTransparency = 1,
                    ZIndex = 5
                })

                table.insert(bearlib.AllElements, {
                    Name = TName,
                    Instance = Button,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local TextBox = {}

                local function Input()
                    local Text = TextBoxInput.Text
                    if Text:gsub(" ", ""):len() > 0 then
                        if TextBox.OnChanging then Text = TextBox.OnChanging(Text) or Text end
                        Funcs:FireCallback(Callback, Text)
                        TextBoxInput.Text = Text
                    end
                end

                TextBoxInput.FocusLost:Connect(Input) Input()

                TextBoxInput.FocusLost:Connect(function()
                    CreateTween({Pencil, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                end)
                TextBoxInput.Focused:Connect(function()
                    CreateTween({Pencil, "ImageColor3", Theme["Color Theme"], 0.2})
                end)

                TextBox.OnChanging = false

                function TextBox:Visible(...) Funcs:ToggleVisible(Button, ...) end

                function TextBox:Destroy() Button:Destroy() end
                return TextBox
            end

            function SubTab:AddDropdown(Configs)
                -- Same as Tab:AddDropdown
                local DName = Configs[1] or Configs.Name or Configs.Title or "Dropdown"
                local DDesc = Configs.Desc or Configs.Description or ""
                local DOptions = Configs[2] or Configs.Options or {}
                local OpDefault = Configs[3] or Configs.Default or {}
                local Flag = Configs[5] or Configs.Flag or false
                local DMultiSelect = Configs.MultiSelect or false
                local Callback = Funcs:GetCallback(Configs, 4)

                local Button, LabelFunc = ButtonFrame(Container, DName, DDesc, UDim2.new(1, -180))
                Button.LayoutOrder = GetOrder()

                local SelectedFrame = InsertTheme(Create("Frame", Button, {
                    Size = UDim2.new(0, 150, 0, 18),
                    Position = UDim2.new(1, -10, 0.5),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme["Color Stroke"],
                    ZIndex = 4
                }), "Stroke") Make("Corner", SelectedFrame, UDim.new(0, 4))

                local ActiveLabel = InsertTheme(Create("TextLabel", SelectedFrame, {
                    Size = UDim2.new(0.85, 0, 0.85, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextScaled = true,
                    TextColor3 = Theme["Color Text"],
                    Text = "...",
                    ZIndex = 5
                }), "Text")

                local Arrow = Create("ImageLabel", SelectedFrame, {
                    Size = UDim2.new(0, 15, 0, 15),
                    Position = UDim2.new(0, -5, 0.5),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Image = "rbxassetid://10709791523",
                    BackgroundTransparency = 1,
                    ZIndex = 5
                })

                local NoClickFrame = Create("TextButton", DropdownHolder, {
                    Name = "AntiClick",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Visible = false,
                    Text = ""
                })

                local DropFrame = Create("Frame", NoClickFrame, {
                    Size = UDim2.new(SelectedFrame.Size.X, 0, 0),
                    BackgroundTransparency = 0.1,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    AnchorPoint = Vector2.new(0, 1),
                    Name = "DropdownFrame",
                    ClipsDescendants = true,
                    Active = true,
                    ZIndex = 5
                }) Make("Corner", DropFrame) Make("Stroke", DropFrame) Make("Gradient", DropFrame, {Rotation = 60})

                local SearchBox = Create("TextBox", DropFrame, {
                    BackgroundColor3 = Theme["Color Hub 2"],
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 0, 22),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "Search...",
                    Text = "",
                    TextColor3 = Theme["Color Text"],
                    TextSize = 11,
                    ZIndex = 6
                }) Make("Corner", SearchBox, UDim.new(0, 8))

                local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, {
                    ScrollBarImageColor3 = Theme["Color Theme"],
                    Size = UDim2.new(1, 0, 1, -32),
                    Position = UDim2.new(0, 0, 0, 32),
                    ScrollBarThickness = 1.5,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.new(),
                    ScrollingDirection = "Y",
                    AutomaticCanvasSize = "Y",
                    Active = true,
                    ZIndex = 6
                }, {
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingTop = UDim.new(0, 5),
                        PaddingBottom = UDim.new(0, 5)
                    }), Create("UIListLayout", {
                        Padding = UDim.new(0, 4)
                    })
                }), "ScrollBar")

                local ScrollSize, WaitClick = 5

                local function Disable(input)
                    if input then
                        local mousePos = input.Position
                        local dropPos = DropFrame.AbsolutePosition
                        local dropSize = DropFrame.AbsoluteSize

                        local isInsideDropFrame =
                            mousePos.X >= dropPos.X and
                            mousePos.X <= dropPos.X + dropSize.X and
                            mousePos.Y >= dropPos.Y and
                            mousePos.Y <= dropPos.Y + dropSize.Y

                        if isInsideDropFrame then
                            return
                        end
                    end

                    WaitClick = true
                    CreateTween({Arrow, "Rotation", 0, 0.2})
                    CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                    CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                    Arrow.Image = "rbxassetid://10709791523"
                    NoClickFrame.Visible = false
                    SearchBox.Text = ""
                    WaitClick = false
                end

                local function GetFrameSize()
                    return UDim2.fromOffset(152, ScrollSize)
                end

                local function CalculateSize()
                    local Count = 0
                    for _, Frame in pairs(ScrollFrame:GetChildren()) do
                        if Frame:IsA("Frame") or Frame.Name == "Option" then
                            if Frame.Visible then
                                Count = Count + 1
                            end
                        end
                    end
                    ScrollSize = (math.clamp(Count, 0, 10) * 25) + 40
                    if NoClickFrame.Visible then
                        CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
                    end
                end

                local function Minimize()
                    if WaitClick then return end
                    WaitClick = true
                    if NoClickFrame.Visible then
                        Arrow.Image = "rbxassetid://10709791523"
                        CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                        CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                        NoClickFrame.Visible = false
                        SearchBox.Text = ""
                    else
                        NoClickFrame.Visible = true
                        Arrow.Image = "rbxassetid://10709790948"
                        CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.2})
                        CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
                    end
                    WaitClick = false
                end

                local function CalculatePos()
                    local FramePos = SelectedFrame.AbsolutePosition
                    local ScreenSize = ScreenGui.AbsoluteSize
                    local ClampX = math.clamp((FramePos.X / UIScale), 0, ScreenSize.X / UIScale - DropFrame.Size.X.Offset)
                    local ClampY = math.clamp((FramePos.Y / UIScale), 0, ScreenSize.Y / UIScale)

                    local NewPos = UDim2.fromOffset(ClampX, ClampY)
                    local AnchorPoint = FramePos.Y > ScreenSize.Y / 1.4 and 1 or ScrollSize > 80 and 0.5 or 0
                    DropFrame.AnchorPoint = Vector2.new(0, AnchorPoint)
                    CreateTween({DropFrame, "Position", NewPos, 0.1})
                end

                local AddNewOptions, GetOptions, AddOption, RemoveOption, Selected do
                    local Default = type(OpDefault) ~= "table" and {OpDefault} or OpDefault
                    local MultiSelect = DMultiSelect
                    local Options = {}
                    Selected = MultiSelect and {} or CheckFlag(Flag) and GetFlag(Flag) or Default[1]

                    if MultiSelect then
                        for index, Value in pairs(CheckFlag(Flag) and GetFlag(Flag) or Default) do
                            if type(index) == "string" and (DOptions[index] or table.find(DOptions, index)) then
                                Selected[index] = Value
                            elseif DOptions[Value] then
                                Selected[Value] = true
                            end
                        end
                    end

                    local function CallbackSelected()
                        SetFlag(Flag, MultiSelect and Selected or tostring(Selected))
                        Funcs:FireCallback(Callback, Selected)
                    end

                    local function UpdateLabel()
                        if MultiSelect then
                            local list = {}
                            for index, Value in pairs(Selected) do
                                if Value then
                                    table.insert(list, index)
                                end
                            end
                            ActiveLabel.Text = #list > 0 and table.concat(list, ", ") or "..."
                        else
                            ActiveLabel.Text = tostring(Selected or "...")
                        end
                    end

                    local function UpdateSelected()
                        if MultiSelect then
                            for _, v in pairs(Options) do
                                local nodes, Stats = v.nodes, v.Stats
                                CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 0.8, 0.35})
                                CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 4), 0.35})
                                CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.35})
                            end
                        else
                            for _, v in pairs(Options) do
                                local Slt = v.Value == Selected
                                local nodes = v.nodes
                                CreateTween({nodes[2], "BackgroundTransparency", Slt and 0 or 1, 0.35})
                                CreateTween({nodes[2], "Size", Slt and UDim2.fromOffset(4, 14) or UDim2.fromOffset(4, 4), 0.35})
                                CreateTween({nodes[3], "TextTransparency", Slt and 0 or 0.4, 0.35})
                            end
                        end
                        UpdateLabel()
                    end

                    local function Select(Option)
                        if MultiSelect then
                            Option.Stats = not Option.Stats
                            Option.LastCB = tick()

                            Selected[Option.Name] = Option.Stats
                            CallbackSelected()
                        else
                            Option.LastCB = tick()

                            Selected = Option.Value
                            CallbackSelected()
                        end
                        UpdateSelected()
                    end

                    AddOption = function(index, Value)
                        local Name = tostring(type(index) == "string" and index or Value)

                        if Options[Name] then return end
                        Options[Name] = {
                            index = index,
                            Value = Value,
                            Name = Name,
                            Stats = false,
                            LastCB = 0
                        }

                        if MultiSelect then
                            local Stats = Selected[Name]
                            Selected[Name] = Stats or false
                            Options[Name].Stats = Stats
                        end

                        local Button = Make("Button", ScrollFrame, {
                            Name = "Option",
                            Size = UDim2.new(1, 0, 0, 21),
                            Position = UDim2.new(0, 0, 0.5),
                            AnchorPoint = Vector2.new(0, 0.5),
                            ZIndex = 7
                        }) Make("Corner", Button, UDim.new(0, 4))

                        local IsSelected = InsertTheme(Create("Frame", Button, {
                            Position = UDim2.new(0, 1, 0.5),
                            Size = UDim2.new(0, 4, 0, 4),
                            BackgroundColor3 = Theme["Color Theme"],
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0, 0.5),
                            ZIndex = 8
                        }), "Theme") Make("Corner", IsSelected, UDim.new(0.5, 0))

                        local OptioneName = InsertTheme(Create("TextLabel", Button, {
                            Size = UDim2.new(1, 0, 1),
                            Position = UDim2.new(0, 10),
                            Text = Name,
                            TextColor3 = Theme["Color Text"],
                            Font = Enum.Font.GothamBold,
                            TextXAlignment = "Left",
                            BackgroundTransparency = 1,
                            TextTransparency = 0.4,
                            ZIndex = 8,
                            TextStrokeTransparency = 0.3,
                            TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        }), "Text")

                        Button.Activated:Connect(function()
                            Select(Options[Name])
                        end)

                        Options[Name].nodes = {Button, IsSelected, OptioneName}
                    end

                    RemoveOption = function(index, Value)
                        local Name = tostring(type(index) == "string" and index or Value)
                        if Options[Name] then
                            if MultiSelect then Selected[Name] = nil else Selected = nil end
                            Options[Name].nodes[1]:Destroy()
                            Options[Name] = nil
                        end
                    end

                    GetOptions = function()
                        return Options
                    end

                    AddNewOptions = function(List, Clear)
                        if Clear then
                            for _, opt in pairs(Options) do
                                RemoveOption(opt.index, opt.Value)
                            end
                        end
                        for _, opt in pairs(List) do
                            AddOption(opt, opt)
                        end
                        CallbackSelected()
                        UpdateSelected()
                    end

                    for _, opt in pairs(DOptions) do
                        AddOption(opt, opt)
                    end
                    CallbackSelected()
                    UpdateSelected()
                end

                local function FilterOptions(filter)
                    local searchText = string.lower(filter or "")
                    for _, opt in pairs(GetOptions()) do
                        if opt.nodes and opt.nodes[1] then
                            local optionName = string.lower(opt.Name)
                            local isVisible = searchText == "" or string.find(optionName, searchText, 1, true)
                            opt.nodes[1].Visible = isVisible
                        end
                    end
                    CalculateSize()
                end

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    FilterOptions(SearchBox.Text)
                end)

                Button.Activated:Connect(Minimize)

                NoClickFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch then
                        Disable(input)
                    end
                end)

                MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                    Disable()
                end)
                SelectedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(CalculatePos)

                Button.Activated:Connect(CalculateSize)
                ScrollFrame.ChildAdded:Connect(CalculateSize)
                ScrollFrame.ChildRemoved:Connect(CalculateSize)
                CalculatePos()
                CalculateSize()

                table.insert(bearlib.AllElements, {
                    Name = DName,
                    Instance = Button,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local Dropdown = {}

                function Dropdown:Visible(...) Funcs:ToggleVisible(Button, ...) end

                function Dropdown:Destroy() Button:Destroy() end

                function Dropdown:Callback(...) Funcs:InsertCallback(Callback, ...)(Selected) end

                function Dropdown:Add(...)
                    local NewOptions = {...}
                    if type(NewOptions[1]) == "table" then
                        for _, Name in ipairs(NewOptions[1]) do
                            AddOption(Name, Name)
                        end
                    else
                        for _, Name in ipairs(NewOptions) do
                            AddOption(Name, Name)
                        end
                    end
                end

                function Dropdown:Remove(Option)
                    for index, Value in pairs(GetOptions()) do
                        if type(Option) == "number" and index == Option or Value.Name == Option then
                            RemoveOption(index, Value.Value)
                        end
                    end
                end

                function Dropdown:Select(Option)
                    if type(Option) == "string" then
                        for _, Val in pairs(Options) do
                            if Val.Name == Option then
                                Select(Val)
                            end
                        end
                    elseif type(Option) == "number" then
                        local i = 0
                        for _, Val in pairs(Options) do
                            i = i + 1
                            if i == Option then
                                Select(Val)
                            end
                        end
                    end
                end

                function Dropdown:Set(Val1, Clear)
                    if type(Val1) == "table" then
                        AddNewOptions(Val1, Clear)
                    elseif type(Val1) == "function" then
                        Callback = Val1
                    end
                end
                return Dropdown
            end

            -- ===== PROFILE for SubTab =====
            function SubTab:AddProfile(Configs)
                local PName = Configs[1] or Configs.Name or "User Name"
                local PBio = Configs[2] or Configs.Bio or "No bio yet."
                local PAvatar = Configs.Avatar or "rbxassetid://0"
                local PCover = Configs.Cover or "rbxassetid://0"
                local PVerified = Configs.Verified or false

                local ProfileHolder = Create("Frame", Container, {
                    Size = UDim2.new(1, 0, 0, 100),
                    BackgroundTransparency = 1,
                    LayoutOrder = GetOrder(),
                    Name = "Profile",
                    ZIndex = 1
                })

                local Card = InsertTheme(Create("Frame", ProfileHolder, {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 1
                }), "Frame")
                Make("Corner", Card, UDim.new(0, 8))

                local ProfileStroke = InsertTheme(Create("UIStroke", Card, {
                    Color = Theme["Color Profile Border"] or Theme["Color Stroke"],
                    Thickness = Theme["Border Thickness"] or 1.5,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }), "Stroke")

                local CoverImg = Create("ImageLabel", Card, {
                    Size = UDim2.new(1, 0, 0, 50),
                    Image = PCover,
                    ScaleType = Enum.ScaleType.Crop,
                    BackgroundTransparency = 1,
                    ZIndex = 1
                })
                Make("Corner", CoverImg, UDim.new(0, 8))

                local CoverFix = InsertTheme(Create("Frame", CoverImg, {
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 2
                }), "Frame")

                local AvatarImg = Create("ImageLabel", Card, {
                    Size = UDim2.fromOffset(45, 45),
                    Position = UDim2.new(0, 12, 0, 30),
                    Image = PAvatar,
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 3
                })
                Make("Corner", AvatarImg, UDim.new(1, 0))

                local AvatarStroke = InsertTheme(Create("UIStroke", AvatarImg, {
                    Thickness = 2,
                    Color = Theme["Color Profile Border"] or Theme["Color Stroke"]
                }), "Stroke")

                local NameLabel = InsertTheme(Create("TextLabel", Card, {
                    Position = UDim2.new(0, 65, 0, 50),
                    Size = UDim2.new(1, -75, 0, 18),
                    Text = PName,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme["Color Text"],
                    TextSize = 13,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    TextTruncate = "AtEnd",
                    ZIndex = 3,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")

                if PVerified then
                    local VerifyIcon = Create("ImageLabel", Card, {
                        Size = UDim2.fromOffset(14, 14),
                        Position = UDim2.new(0, 65 + NameLabel.TextBounds.X + 4, 0, 52),
                        Image = "rbxassetid://10709752907",
                        ImageColor3 = Color3.fromRGB(60, 140, 255),
                        BackgroundTransparency = 1,
                        ZIndex = 4
                    })
                    NameLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        VerifyIcon.Position = UDim2.new(0, 65 + NameLabel.TextBounds.X + 4, 0, 52)
                    end)
                end

                local BioLabel = InsertTheme(Create("TextLabel", Card, {
                    Position = UDim2.new(0, 12, 0, 78),
                    Size = UDim2.new(1, -24, 0, 16),
                    Text = PBio,
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme["Color Dark Text"],
                    TextSize = 9,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 3,
                    TextStrokeTransparency = 0.4,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "DarkText")

                table.insert(bearlib.AllElements, {
                    Name = PName .. " Profile",
                    Instance = ProfileHolder,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local Profile = {}
                function Profile:Visible(...) Funcs:ToggleVisible(ProfileHolder, ...) end
                function Profile:Destroy() ProfileHolder:Destroy() end
                function Profile:SetBio(NewBio) BioLabel.Text = NewBio end
                function Profile:SetBorderColor(NewColor)
                    if typeof(NewColor) == "Color3" then
                        ProfileStroke.Color = NewColor
                        AvatarStroke.Color = NewColor
                    end
                end
                return Profile
            end

            -- ===== DISCORD CARD for SubTab =====
            function SubTab:AddSingleDiscordCard(Configs)
                local Title = Configs.Title or Configs[1] or "Discord Server"
                local Description = Configs.Description or Configs.Desc or Configs[2] or ""
                local Logo = Configs.Logo or Configs.Icon or Configs[3] or "rbxassetid://0"
                local BannerColor = Configs.BannerColor or Configs.Banner or Configs[4] or Color3.fromRGB(88, 101, 242)
                local Online = Configs.Online or Configs[5] or 0
                local TotalMembers = Configs.Members or Configs[6] or 0
                local InviteLink = Configs.Invite or Configs.Link or Configs[7] or "https://discord.gg/example"
                local Verified = Configs.Verified or false

                local CardContainer = Create("Frame", Container, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 150),
                    LayoutOrder = GetOrder(),
                    Name = "SingleDiscordCard",
                    ZIndex = 1
                })

                local Card = InsertTheme(Create("Frame", CardContainer, {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 1
                }), "Frame")
                Make("Corner", Card, UDim.new(0, 8))

                local CardStroke = InsertTheme(Create("UIStroke", Card, {
                    Color = Theme["Color Discord Border"] or Theme["Color Stroke"],
                    Thickness = Theme["Border Thickness"] or 1.5,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }), "Stroke")

                local BannerImg = Create("ImageLabel", Card, {
                    Size = UDim2.new(1, 0, 0, 60),
                    Image = type(BannerColor) == "string" and BannerColor or "",
                    ScaleType = Enum.ScaleType.Crop,
                    BackgroundColor3 = type(BannerColor) == "Color3" and BannerColor or Color3.fromRGB(88, 101, 242),
                    BackgroundTransparency = type(BannerColor) == "Color3" and 0 or 1,
                    ZIndex = 1
                })
                Make("Corner", BannerImg, UDim.new(0, 8))

                local BannerFix = InsertTheme(Create("Frame", BannerImg, {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 1, -6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 2
                }), "Frame")

                local AvatarImg = Create("ImageLabel", Card, {
                    Size = UDim2.fromOffset(50, 50),
                    Position = UDim2.new(0, 15, 0, 35),
                    Image = Logo,
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 3
                })
                Make("Corner", AvatarImg, UDim.new(1, 0))

                local AvatarStroke = InsertTheme(Create("UIStroke", AvatarImg, {
                    Thickness = 2.5,
                    Color = Theme["Color Discord Border"] or Theme["Color Stroke"]
                }), "Stroke")

                local NameLabel = InsertTheme(Create("TextLabel", Card, {
                    Position = UDim2.new(0, 75, 0, 48),
                    Size = UDim2.new(1, -90, 0, 20),
                    Text = Title,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme["Color Text"],
                    TextSize = 14,
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    TextTruncate = "AtEnd",
                    ZIndex = 3,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")

                if Verified then
                    local VerifyIcon = Create("ImageLabel", Card, {
                        Size = UDim2.fromOffset(16, 16),
                        Position = UDim2.new(0, 75 + NameLabel.TextBounds.X + 5, 0, 50),
                        Image = "rbxassetid://10709752907",
                        ImageColor3 = Color3.fromRGB(60, 140, 255),
                        BackgroundTransparency = 1,
                        ZIndex = 4
                    })
                    NameLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        VerifyIcon.Position = UDim2.new(0, 75 + NameLabel.TextBounds.X + 5, 0, 50)
                    end)
                end

                local StatsContainer = Create("Frame", Card, {
                    Position = UDim2.new(0, 75, 0, 70),
                    Size = UDim2.new(1, -90, 0, 20),
                    BackgroundTransparency = 1,
                    ZIndex = 3
                })

                local StatsLayout = Create("UIListLayout", StatsContainer, {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 15)
                })

                local function AddStat(StatColor, StatText)
                    local Stat = Create("Frame", StatsContainer, {
                        Size = UDim2.new(0, 0, 1, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        ZIndex = 3
                    })

                    local Dot = Create("Frame", Stat, {
                        Size = UDim2.fromOffset(8, 8),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = StatColor,
                        ZIndex = 4
                    })
                    Make("Corner", Dot, UDim.new(1, 0))

                    local StatLabel = InsertTheme(Create("TextLabel", Stat, {
                        Size = UDim2.new(0, 0, 1, 0),
                        Position = UDim2.new(0, 12, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        TextSize = 10,
                        Text = StatText,
                        Font = Enum.Font.Gotham,
                        TextColor3 = Theme["Color Dark Text"],
                        ZIndex = 4,
                        TextStrokeTransparency = 0.4,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    }), "DarkText")
                end

                if Online and Online > 0 then
                    AddStat(Color3.fromRGB(0, 255, 0), tostring(Online) .. " Online")
                end

                if TotalMembers and TotalMembers > 0 then
                    AddStat(Color3.fromRGB(88, 101, 242), tostring(TotalMembers) .. " Members")
                end

                local DescLabel = InsertTheme(Create("TextLabel", Card, {
                    Position = UDim2.new(0, 75, 0, 95),
                    Size = UDim2.new(1, -90, 0, 35),
                    Text = Description,
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme["Color Dark Text"],
                    TextSize = 10,
                    TextXAlignment = "Left",
                    TextYAlignment = "Top",
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    ZIndex = 3,
                    TextStrokeTransparency = 0.4,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "DarkText")

                local ButtonContainer = Create("Frame", Card, {
                    Size = UDim2.new(1, -30, 0, 30),
                    Position = UDim2.new(0.5, 0, 1, -15),
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundTransparency = 1,
                    ZIndex = 3
                })

                local JoinButton = InsertTheme(Create("TextButton", ButtonContainer, {
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "Join Discord",
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 4,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")
                Make("Corner", JoinButton, UDim.new(0.5, 0))

                local LastClick = 0
                JoinButton.Activated:Connect(function()
                    if tick() - LastClick < 3 then return end
                    LastClick = tick()
                    local OriginalText = JoinButton.Text
                    JoinButton.Text = "Copied!"
                    setclipboard(InviteLink)
                    task.wait(1.5)
                    JoinButton.Text = OriginalText
                end)

                local function AdjustDescriptionHeight()
                    local textBounds = DescLabel.TextBounds.Y
                    if textBounds > 35 then
                        DescLabel.Size = UDim2.new(1, -90, 0, textBounds + 5)
                        ButtonContainer.Position = UDim2.new(0.5, 0, 1, -(15 + (textBounds - 35)))
                    end
                end

                DescLabel:GetPropertyChangedSignal("Text"):Connect(AdjustDescriptionHeight)
                task.spawn(AdjustDescriptionHeight)

                table.insert(bearlib.AllElements, {
                    Name = Title .. " Discord Card",
                    Instance = CardContainer,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local CardObj = {}

                function CardObj:SetTitle(NewTitle)
                    NameLabel.Text = NewTitle
                end

                function CardObj:SetDescription(NewDesc)
                    DescLabel.Text = NewDesc
                end

                function CardObj:SetIcon(NewIcon)
                    AvatarImg.Image = NewIcon
                end

                function CardObj:SetStats(NewOnline, NewMembers)
                    for _, child in ipairs(StatsContainer:GetChildren()) do
                        if child:IsA("Frame") and child ~= StatsLayout then
                            child:Destroy()
                        end
                    end

                    if NewOnline and NewOnline > 0 then
                        AddStat(Color3.fromRGB(0, 255, 0), tostring(NewOnline) .. " Online")
                    end

                    if NewMembers and NewMembers > 0 then
                        AddStat(Color3.fromRGB(88, 101, 242), tostring(NewMembers) .. " Members")
                    end
                end

                function CardObj:SetBanner(NewBanner)
                    if type(NewBanner) == "string" then
                        BannerImg.Image = NewBanner
                        BannerImg.BackgroundTransparency = 1
                    elseif typeof(NewBanner) == "Color3" then
                        BannerImg.BackgroundColor3 = NewBanner
                        BannerImg.BackgroundTransparency = 0
                        BannerImg.Image = ""
                    end
                end

                function CardObj:SetInviteLink(NewLink)
                    InviteLink = NewLink
                end

                function CardObj:SetVerified(IsVerified)
                    Verified = IsVerified
                end

                function CardObj:Visible(...) 
                    Funcs:ToggleVisible(CardContainer, ...) 
                end

                function CardObj:Destroy() 
                    CardContainer:Destroy() 
                end

                return CardObj
            end

            -- ===== DISCORD INVITE CONTAINER for SubTab =====
            function SubTab:AddDiscordInvite(Configs)
                local ContainerFrame = Create("Frame", Container, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 150),
                    LayoutOrder = GetOrder(),
                    Name = "DiscordInviteContainer",
                    ZIndex = 1
                })

                local ListLayout = Create("UIListLayout", ContainerFrame, {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 12),
                    SortOrder = "LayoutOrder"
                })

                local function createDiscordCard(cardConfigs, layoutOrder)
                    local BName = cardConfigs[1] or cardConfigs.Name or cardConfigs.Title or "Discord Server"
                    local BDescription = cardConfigs[2] or cardConfigs.Description or cardConfigs.Desc or ""
                    local Logo = cardConfigs[3] or cardConfigs.Icon or cardConfigs.Logo or cardConfigs.Image or ""
                    local BannerColor = cardConfigs[4] or cardConfigs.Banner or cardConfigs.BannerColor or Color3.fromRGB(88, 101, 242)
                    local Online = cardConfigs[5] or cardConfigs.Online or cardConfigs.MembersOnline
                    local TotalMembers = cardConfigs[6] or cardConfigs.Members or cardConfigs.TotalMembers
                    local InviteLink = cardConfigs[7] or cardConfigs.Invite or cardConfigs.Link or "https://discord.gg/example"

                    assert(type(InviteLink) == "string", "\"Tab.AddDiscordInvite.Invite\". 'string' expected, got " .. typeof(InviteLink))

                    local CardFrame = Create("Frame", ContainerFrame, {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.5, -6, 1, -15),
                        LayoutOrder = layoutOrder,
                        Name = "DiscordCard_" .. layoutOrder,
                        ZIndex = 1
                    })

                    local Card = InsertTheme(Create("Frame", CardFrame, {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Theme["Color Hub 2"],
                        ClipsDescendants = true,
                        ZIndex = 1
                    }), "Frame")
                    Make("Corner", Card, UDim.new(0, 10))

                    local Gradient = Make("Gradient", Card, 45)

                    local StrokeFrame = Create("Frame", CardFrame, {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        ZIndex = 2
                    })

                    local Stroke = InsertTheme(Create("UIStroke", StrokeFrame, {
                        Color = Theme["Color Discord Border"] or Theme["Color Stroke"],
                        Thickness = Theme["Border Thickness"] or 1.5,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }), "Stroke")
                    Make("Corner", StrokeFrame, UDim.new(0, 10))

                    local BannerImage = Create("ImageLabel", Card, {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Size = UDim2.fromScale(1, 0.3),
                        BackgroundTransparency = 1,
                        ZIndex = 1
                    })
                    Make("Corner", BannerImage, UDim.new(0, 10))

                    local ServerIcon = Create("ImageLabel", Card, {
                        Size = UDim2.fromOffset(35, 35),
                        Position = UDim2.new(0, 12, 0.3, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Image = Logo,
                        BackgroundColor3 = Theme["Color Hub 2"],
                        ZIndex = 2
                    })
                    Make("Corner", ServerIcon, UDim.new(0, 8))

                    local IconStroke = InsertTheme(Create("UIStroke", ServerIcon, {
                        Thickness = 2,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Theme["Color Discord Border"] or Theme["Color Stroke"]
                    }), "Stroke")

                    local ServerName = InsertTheme(Create("TextLabel", Card, {
                        Size = UDim2.new(1, -20, 0, 12),
                        Position = UDim2.new(0, 12, 0.46, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        Text = BName,
                        Font = Enum.Font.GothamBold,
                        TextColor3 = Theme["Color Discord Text"],
                        ZIndex = 3,
                        TextStrokeTransparency = 0.3,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    }), "Text")

                    local StatsFrame
                    if Online or TotalMembers then
                        StatsFrame = Create("Frame", Card, {
                            Size = UDim2.new(1, -20, 0, 10),
                            Position = UDim2.new(0, 0, 0.54, 0),
                            BackgroundTransparency = 1,
                            ZIndex = 2
                        })

                        local StatsLayout = Create("UIListLayout", StatsFrame, {
                            HorizontalAlignment = Enum.HorizontalAlignment.Left,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            FillDirection = Enum.FillDirection.Horizontal,
                            Padding = UDim.new(0, 6)
                        })

                        local function AddStat(StatColor, Text)
                            local Stat = Create("Frame", StatsFrame, {
                                Size = UDim2.fromScale(0, 1),
                                AutomaticSize = Enum.AutomaticSize.X,
                                BackgroundTransparency = 1,
                                ZIndex = 2
                            })

                            local Dot = Create("Frame", Stat, {
                                Size = UDim2.fromOffset(4, 4),
                                Position = UDim2.new(0, 5, 0.5, 0),
                                AnchorPoint = Vector2.new(0, 0.5),
                                BackgroundColor3 = StatColor,
                                BackgroundTransparency = 0,
                                ZIndex = 3
                            })
                            Make("Corner", Dot, UDim.new(1, 0))

                            InsertTheme(Create("TextLabel", Stat, {
                                Size = UDim2.new(0, 0, 1, 0),
                                Position = UDim2.new(0, 14, 0.5, 0),
                                AnchorPoint = Vector2.new(0, 0.5),
                                AutomaticSize = Enum.AutomaticSize.X,
                                BackgroundTransparency = 1,
                                TextSize = 8,
                                Text = Text,
                                Font = Enum.Font.Gotham,
                                TextColor3 = Theme["Color Discord Stats"],
                                ZIndex = 4,
                                TextStrokeTransparency = 0.4,
                                TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            }), "DarkText")
                        end

                        if Online ~= nil then
                            AddStat(Color3.fromRGB(0, 255, 0), tostring(Online) .. " Online")
                        end
                        if TotalMembers ~= nil then
                            AddStat(Color3.fromRGB(88, 101, 242), tostring(TotalMembers) .. " Members")
                        end
                    end

                    local Description = InsertTheme(Create("TextLabel", Card, {
                        Size = UDim2.new(1, -50, 0, 10),
                        Position = UDim2.new(0, 12, StatsFrame and 0.62 or 0.58, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        TextSize = 9,
                        Text = BDescription,
                        TextWrapped = true,
                        Font = Enum.Font.Gotham,
                        TextColor3 = Theme["Color Dark Text"],
                        ZIndex = 3,
                        TextStrokeTransparency = 0.4,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    }), "Text")

                    local ButtonContainer = Create("Frame", Card, {
                        Size = UDim2.new(1, 0, 0.3, 0),
                        Position = UDim2.fromScale(0, 1),
                        AnchorPoint = Vector2.new(0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Theme["Color Hub 2"],
                        ZIndex = 2
                    })

                    if #Description.Text > 0 then
                        ButtonContainer.Size = UDim2.new(1, 0, 0.4, 0)
                        Create("UIGradient", ButtonContainer, {
                            Rotation = -90,
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0.00, 0.00),
                                NumberSequenceKeypoint.new(0.60, 0.00),
                                NumberSequenceKeypoint.new(1.00, 1.00)
                            }
                        })
                    end

                    local JoinButton = InsertTheme(Create("TextButton", ButtonContainer, {
                        Position = UDim2.new(0.5, 0, 1, -10),
                        Size = UDim2.new(1, -20, 0, 20),
                        AnchorPoint = Vector2.new(0.5, 1),
                        Text = "Join",
                        Font = Enum.Font.GothamBold,
                        TextSize = 12,
                        BackgroundColor3 = Color3.fromRGB(37, 128, 69),
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 4,
                        TextStrokeTransparency = 0.3,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    }), "Text")
                    Make("Corner", JoinButton, UDim.new(0.5, 0))

                    local LastClick = 0
                    JoinButton.Activated:Connect(function()
                        if tick() - LastClick < 5 then return end
                        LastClick = tick()
                        local OriginalText = JoinButton.Text
                        JoinButton.Text = "Copied!"
                        setclipboard(InviteLink)
                        task.wait(2)
                        JoinButton.Text = OriginalText
                    end)

                    if type(BannerColor) == "string" then
                        BannerImage.ScaleType = Enum.ScaleType.Crop
                        BannerImage.Image = BannerColor
                    elseif typeof(BannerColor) == "Color3" then
                        BannerImage.BackgroundTransparency = 0
                        BannerImage.BackgroundColor3 = BannerColor
                    end

                    return {
                        Frame = CardFrame,
                        Card = Card,
                        Name = ServerName,
                        Description = Description,
                        JoinButton = JoinButton,
                        Configs = cardConfigs,
                        StrokeFrame = StrokeFrame,
                        Stroke = Stroke
                    }
                end

                local card1, card2

                if Configs[1] and type(Configs[1]) == "table" then
                    card1 = createDiscordCard(Configs[1], 1)
                    if Configs[2] and type(Configs[2]) == "table" then
                        card2 = createDiscordCard(Configs[2], 2)
                    else
                        card2 = createDiscordCard({
                            "Empty Server",
                            "Add your second Discord server here",
                            "",
                            Color3.fromRGB(50, 50, 50),
                            0,
                            0,
                            "https://discord.gg/example"
                        }, 2)
                    end
                else
                    card1 = createDiscordCard(Configs, 1)
                    card2 = createDiscordCard({
                        "Empty Server",
                        "Add your second Discord server here",
                        "",
                        Color3.fromRGB(50, 50, 50),
                        0,
                        0,
                        "https://discord.gg/example"
                    }, 2)
                end

                table.insert(bearlib.AllElements, {
                    Name = "Discord Invite Container",
                    Instance = ContainerFrame,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local DiscordInviteContainer = {}
                function DiscordInviteContainer:Visible(Bool)
                    if Bool == nil then
                        ContainerFrame.Visible = not ContainerFrame.Visible
                    else
                        ContainerFrame.Visible = Bool
                    end
                end
                function DiscordInviteContainer:Destroy()
                    ContainerFrame:Destroy()
                end
                function DiscordInviteContainer:UpdateCard1(NewConfigs)
                    if card1 then
                        card1.Frame:Destroy()
                        card1 = createDiscordCard(NewConfigs, 1)
                    end
                end
                function DiscordInviteContainer:UpdateCard2(NewConfigs)
                    if card2 then
                        card2.Frame:Destroy()
                        card2 = createDiscordCard(NewConfigs, 2)
                    end
                end
                function DiscordInviteContainer:GetCard1()
                    return card1
                end
                function DiscordInviteContainer:GetCard2()
                    return card2
                end
                return DiscordInviteContainer
            end

            -- ===== DISCORD INVITE OLD for SubTab =====
            function SubTab:AddDiscordInviteOld(Configs)
                local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
                local Desc = Configs[2] or Configs.Desc or Configs.Description or ""
                local Logo = Configs[3] or Configs.Logo or ""
                local Invite = Configs[4] or Configs.Invite or ""

                local InviteHolder = Create("Frame", Container, {
                    Size = UDim2.new(1, 0, 0, 65),
                    Name = "Option",
                    BackgroundTransparency = 1,
                    LayoutOrder = GetOrder(),
                    ZIndex = 1
                })

                local FrameHolder = InsertTheme(Create("Frame", InviteHolder, {
                    Size = UDim2.new(1, 0, 0, 65),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Theme["Color Hub 2"],
                    ZIndex = 1
                }), "Frame")
                Make("Corner", FrameHolder)

                local ImageLabel = Create("ImageLabel", FrameHolder, {
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(0, 7, 0, 7),
                    Image = Logo,
                    BackgroundTransparency = 1,
                    ZIndex = 3
                })
                Make("Corner", ImageLabel, UDim.new(0, 4))
                Make("Stroke", ImageLabel)

                local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
                    Size = UDim2.new(1, -52, 0, 15),
                    Position = UDim2.new(0, 44, 0, 7),
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme["Color Text"],
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    TextSize = 10,
                    Text = Title,
                    ZIndex = 3,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "Text")

                local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
                    Size = UDim2.new(1, -52, 0, 0),
                    Position = UDim2.new(0, 44, 0, 22),
                    TextWrapped = "Y",
                    AutomaticSize = "Y",
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme["Color Dark Text"],
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    TextSize = 8,
                    Text = Desc,
                    ZIndex = 3,
                    TextStrokeTransparency = 0.4,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                }), "DarkText")

                local JoinButton = Create("TextButton", FrameHolder, {
                    Size = UDim2.new(1, -14, 0, 16),
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.new(0.5, 0, 1, -7),
                    Text = "Copy Link",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
                    ZIndex = 4,
                    TextStrokeTransparency = 0.3,
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                })
                Make("Corner", JoinButton, UDim.new(0, 5))

                local ClickDelay
                JoinButton.Activated:Connect(function()
                    setclipboard(Invite)
                    if ClickDelay then return end

                    ClickDelay = true
                    SetProps(JoinButton, {
                        Text = "Copied to Clipboard",
                        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
                        TextColor3 = Color3.fromRGB(150, 150, 150)
                    }) task.wait(5)
                    SetProps(JoinButton, {
                        Text = "Copy Link",
                        BackgroundColor3 = Color3.fromRGB(50, 150, 50),
                        TextColor3 = Color3.fromRGB(220, 220, 220)
                    }) ClickDelay = false
                end)

                table.insert(bearlib.AllElements, {
                    Name = Title,
                    Instance = InviteHolder,
                    OriginalParent = Container,
                    SectionName = CurrentSectionName
                })

                local DiscordInvite = {}
                function DiscordInvite:Destroy() InviteHolder:Destroy() end
                function DiscordInvite:Visible(...) Funcs:ToggleVisible(InviteHolder, ...) end
                return DiscordInvite
            end

            UpdateGroupContainerSize()
            MainScroll.CanvasSize = UDim2.new(0, 0, 0, MainScroll:FindFirstChildOfClass("UIListLayout") and MainScroll:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y or 0)

            return SubTab
        end

        function TabGroup:Expand()
            if not isExpanded then
                ToggleExpand()
            end
        end

        function TabGroup:Collapse()
            if isExpanded then
                ToggleExpand()
            end
        end

        function TabGroup:Visible(Bool)
            Funcs:ToggleVisible(GroupContainer, Bool)
        end

        function TabGroup:Destroy()
            for _, subTab in ipairs(SubTabs) do
                if subTab.Container then subTab.Container:Destroy() end
                if subTab.Button then subTab.Button:Destroy() end
            end
            GroupContainer:Destroy()
            for i, gd in ipairs(bearlib.TabGroups) do
                if gd == GroupData then
                    table.remove(bearlib.TabGroups, i)
                    break
                end
            end
        end

        return TabGroup
    end

    CloseButton.Activated:Connect(Window.CloseBtn)
    MinimizeButton.Activated:Connect(Window.MinimizeBtn)

    task.spawn(function()
        task.wait(0.5)
        ToggleGui = Instance.new("ScreenGui")
        ToggleGui.Name = "BearHub_Toggle_Circle"
        ToggleGui.Parent = CoreGui

        ToggleButton = Instance.new("ImageButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, 50, 0, 50)
        ToggleButton.Position = UDim2.new(0.12, 0, 0.12, 0)
        ToggleButton.Image = "rbxassetid://75089236463451"
        ToggleButton.BackgroundColor3 = Theme["Color Hub 2"]
        ToggleButton.BackgroundTransparency = 0.2
        ToggleButton.Active = true
        ToggleButton.Draggable = true
        ToggleButton.Parent = ToggleGui

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleButton

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Name = "ToggleStroke"
        ToggleStroke.Thickness = 1
        ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ToggleStroke.LineJoinMode = Enum.LineJoinMode.Round
        ToggleStroke.Parent = ToggleButton

        local RainbowColors = {
            Color3.fromRGB(255,255,255)
        }

        local colorIndex = 1
        task.spawn(function()
            while ToggleButton and ToggleButton.Parent do
                ToggleStroke.Color = RainbowColors[colorIndex]
                colorIndex = colorIndex % #RainbowColors + 1
                task.wait(0.3)
            end
        end)

        ToggleButton.MouseButton1Click:Connect(function()
            if MainFrame.Visible then
                MainFrame.Visible = false
                ControlSize.Visible = false
                ControlSize2.Visible = false
                UIFullVisible = false
            elseif Minimized then
                if MinimizedBar and MinimizedBar.Parent then
                    if MinimizedBar.Visible then
                        SaveBarPosition()
                        MinimizedBar.Visible = false
                    else
                        MinimizedBar.Visible = true
                    end
                end
            else
                MainFrame.Visible = true
                ControlSize.Visible = true
                ControlSize2.Visible = true
                UIFullVisible = true
            end
        end)

        if Theme["ShowVNFlag"] == true then
            local Flag = Instance.new("ImageLabel")
            Flag.Name = "VNFlagIcon"
            Flag.Parent = ToggleButton
            Flag.BackgroundTransparency = 1
            Flag.Image = "rbxassetid://90723031696932"
            Flag.Size = UDim2.fromOffset(28, 18)
            Flag.AnchorPoint = Vector2.new(0.5, 0.5)
            Flag.Position = UDim2.new(1, -2, 0, 2)
            Flag.ZIndex = 100
            Flag.Rotation = 15
        end
    end)

    return Window
end

-- ===== NOTIFICATION SYSTEM =====
local NotificationQueue = {}
local ActiveNotifications = {}

local function CreateNotificationHolder()
    if NotificationHolder and NotificationHolder.Parent then
        return NotificationHolder
    end

    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 280, 0, 0)
    NotificationHolder.Position = UDim2.new(1, -290, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(0, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 1000

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = NotificationHolder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 8)

    return NotificationHolder
end

local function ReorderNotifications()
    for i, notifData in ipairs(ActiveNotifications) do
        if notifData.Instance and notifData.Instance.Parent then
            notifData.Instance.LayoutOrder = i
        end
    end
end

local function CreateNotification(Icon, Title, Message, Duration)
    Duration = Duration or 5

    local holder = CreateNotificationHolder()

    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 240, 0, 0)
    Notification.AutomaticSize = Enum.AutomaticSize.Y
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Notification.BackgroundTransparency = 0
    Notification.Parent = holder
    Notification.ZIndex = 1001
    Notification.ClipsDescendants = true
    Notification.BorderSizePixel = 0
    Notification.LayoutOrder = #ActiveNotifications + 1

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 50)
    Corner.Parent = Notification

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1.5
    Stroke.Parent = Notification

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    })
    Gradient.Rotation = 90
    Gradient.Parent = Notification

    local TimerFrame = Instance.new("Frame")
    TimerFrame.Name = "TimerFrame"
    TimerFrame.Size = UDim2.new(0, 24, 0, 24)
    TimerFrame.Position = UDim2.new(1, -3, 0, 0)
    TimerFrame.BackgroundTransparency = 1
    TimerFrame.ZIndex = 1002
    TimerFrame.Parent = Notification

    local TimerText = Instance.new("TextLabel")
    TimerText.Name = "TimerText"
    TimerText.Size = UDim2.new(1, 0, 1, 0)
    TimerText.BackgroundTransparency = 1
    TimerText.Font = Enum.Font.GothamBold
    TimerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerText.TextSize = 12
    TimerText.Text = tostring(Duration)
    TimerText.TextStrokeTransparency = 0.3
    TimerText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TimerText.ZIndex = 1003
    TimerText.Parent = TimerFrame

    local MainLayout = Instance.new("UIListLayout")
    MainLayout.Parent = Notification
    MainLayout.FillDirection = Enum.FillDirection.Horizontal
    MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    MainLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    MainLayout.Padding = UDim.new(0, 8)

    local Padding = Instance.new("UIPadding")
    Padding.Parent = Notification
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingBottom = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 28)

    local IconContainer = Instance.new("Frame")
    IconContainer.Parent = Notification
    IconContainer.Size = UDim2.new(0, 32, 0, 32)
    IconContainer.BackgroundTransparency = 1
    IconContainer.BorderSizePixel = 0
    IconContainer.ZIndex = 1002

    local IconImage = Instance.new("ImageLabel")
    IconImage.Parent = IconContainer
    IconImage.Size = UDim2.new(1, 0, 1, 0)
    IconImage.BackgroundTransparency = 1
    IconImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    IconImage.Image = Icon or "rbxassetid://76571437829227"
    IconImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
    IconImage.ScaleType = Enum.ScaleType.Fit
    IconImage.BorderSizePixel = 0
    IconImage.ZIndex = 1003

    local TextContainer = Instance.new("Frame")
    TextContainer.Parent = Notification
    TextContainer.Size = UDim2.new(1, -80, 0, 0)
    TextContainer.AutomaticSize = Enum.AutomaticSize.Y
    TextContainer.BackgroundTransparency = 1
    TextContainer.BorderSizePixel = 0
    TextContainer.ZIndex = 1002

    local TextLayout = Instance.new("UIListLayout")
    TextLayout.Parent = TextContainer
    TextLayout.FillDirection = Enum.FillDirection.Vertical
    TextLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TextLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    TextLayout.Padding = UDim.new(0, 2)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TextContainer
    TitleLabel.Size = UDim2.new(1, 0, 0, 16)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
    TitleLabel.Text = Title or "Bear Hub"
    TitleLabel.ZIndex = 1003
    TitleLabel.TextStrokeTransparency = 0.3
    TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.BackgroundTransparency = 1

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Parent = TextContainer
    MessageLabel.Size = UDim2.new(1, 0, 0, 0)
    MessageLabel.AutomaticSize = Enum.AutomaticSize.Y
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    MessageLabel.TextSize = 11
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.Text = Message or ""
    MessageLabel.ZIndex = 1003
    MessageLabel.TextStrokeTransparency = 0.4
    MessageLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.RichText = true

    Notification.Position = UDim2.new(1, -8, 0, 0)
    Notification.Rotation = 0

    local closed = false
    local timeLeft = Duration
    local timerConnection
    local countdownActive = true

    local notificationData = {
        Instance = Notification,
        Duration = Duration,
        TimeLeft = timeLeft
    }
    table.insert(ActiveNotifications, notificationData)

    local function updateTimerDisplay()
        if not TimerText or not TimerText.Parent then return end
        TimerText.Text = tostring(math.ceil(timeLeft))
    end

    local function closeNotification()
        if closed then return end
        closed = true
        countdownActive = false
        if timerConnection then
            timerConnection:Disconnect()
        end

        for i, data in ipairs(ActiveNotifications) do
            if data.Instance == Notification then
                table.remove(ActiveNotifications, i)
                break
            end
        end

        if Notification and Notification.Parent then
            Notification:Destroy()
        end

        ReorderNotifications()
        ProcessNotificationQueue()
    end

    timerConnection = RunService.Heartbeat:Connect(function(dt)
        if not countdownActive or closed or not Notification or not Notification.Parent then
            if timerConnection then
                timerConnection:Disconnect()
            end
            return
        end

        timeLeft = timeLeft - dt
        notificationData.TimeLeft = timeLeft
        updateTimerDisplay()

        if timeLeft <= 0 then
            closeNotification()
        end
    end)

    return Notification
end

local function ProcessNotificationQueue()
    if #NotificationQueue == 0 then return end

    while #NotificationQueue > 0 do
        local nextNotification = table.remove(NotificationQueue, 1)
        CreateNotification(
            nextNotification.Icon,
            nextNotification.Title,
            nextNotification.Message,
            nextNotification.Duration
        )
    end
end

function bearlib:Notify(Configs)
    local Title = Configs.Title or Configs[1] or "Bear Hub"
    local Message = Configs.Message or Configs[2] or Configs.Text or ""
    local Icon = Configs.Icon or "rbxassetid://76571437829227"
    local Duration = Configs.Duration or Configs.Time or 5

    table.insert(NotificationQueue, {
        Icon = Icon,
        Title = Title,
        Message = Message,
        Duration = Duration
    })

    ProcessNotificationQueue()

    return true
end

-- ===== COLOR SETTER FUNCTIONS =====
function bearlib:SetUIBorderColor(color)
    if typeof(color) == "Color3" then
        self.Theme["UI Border Color"] = color
        RefreshAllUIElements()
    end
end

function bearlib:SetDiscordBorderColor(color)
    if typeof(color) == "Color3" then
        self.Theme["Color Discord Border"] = color
        RefreshAllUIElements()
    end
end

function bearlib:SetProfileBorderColor(color)
    if typeof(color) == "Color3" then
        self.Theme["Color Profile Border"] = color
        RefreshAllUIElements()
    end
end

function bearlib:SetStrokeColor(color)
    if typeof(color) == "Color3" then
        self.Theme["Color Stroke"] = color
        RefreshAllUIElements()
    end
end

function bearlib:SetTextColor(color)
    if typeof(color) == "Color3" then
        self.Theme["Color Text"] = color
        RefreshAllUIElements()
    end
end

function bearlib:SetHubColor(color)
    if typeof(color) == "Color3" then
        self.Theme["Color Hub 2"] = color
        RefreshAllUIElements()
    end
end

function bearlib:SetBorderThickness(thickness)
    if type(thickness) == "number" then
        self.Theme["Border Thickness"] = thickness
        RefreshAllUIElements()
    end
end

function bearlib:GetBorderColors()
    return {
        UI = self.Theme["UI Border Color"],
        Discord = self.Theme["Color Discord Border"],
        Profile = self.Theme["Color Profile Border"],
        Stroke = self.Theme["Color Stroke"],
        Thickness = self.Theme["Border Thickness"]
    }
end

function bearlib:GetToggleColors()
    return {
        ToggleOn = self.Theme["Color Toggle On"],
        ToggleOff = self.Theme["Color Toggle Off"],
        KnobOn = self.Theme["Color Toggle Knob On"],
        KnobOff = self.Theme["Color Toggle Knob Off"],
        Border = self.Theme["Color Toggle Border"]
    }
end

function bearlib:ResetBorderColors()
    self.Theme["UI Border Color"] = Color3.fromRGB(255, 255, 255)
    self.Theme["Color Discord Border"] = Color3.fromRGB(255, 255, 255)
    self.Theme["Color Profile Border"] = Color3.fromRGB(255, 255, 255)
    self.Theme["Color Stroke"] = Color3.fromRGB(0, 0, 0)
    self.Theme["Border Thickness"] = 1.5
    RefreshAllUIElements()
end

function bearlib:ResetToggleColors()
    self.Theme["Color Toggle On"] = Color3.fromRGB(255, 255, 0)
    self.Theme["Color Toggle Off"] = Color3.fromRGB(0, 0, 0)
    self.Theme["Color Toggle Knob On"] = Color3.fromRGB(255, 255, 255)
    self.Theme["Color Toggle Knob Off"] = Color3.fromRGB(255, 255, 0)
    self.Theme["Color Toggle Border"] = Color3.fromRGB(255, 255, 255)
    RefreshAllUIElements()
end

task.spawn(function()
    task.wait(2)
    bearlib:Notify({
        Title = "Bear Library",
        Message = "UI Bear Library v1.2.0",
        Duration = 10
    })
end)

return bearlib