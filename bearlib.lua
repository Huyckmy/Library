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
    Themes = {
        -- Theme mặc định
        QuangHuy = {
            ["Color Hub 1"] = Color3.fromRGB(0, 0, 0),
            ["Color Hub 2"] = Color3.fromRGB(15,15,15),
            ["Color Stroke"] = Color3.fromRGB(0,0,0),
            ["Color Theme"] = Color3.fromRGB(255,255,0),
            ["Color Text"] = Color3.fromRGB(255, 255, 255),
            ["Color Dark Text"] = Color3.fromRGB(170, 170, 170),
            ["Color Discord Text"] = Color3.fromRGB(255, 255, 255),
            ["Color Discord Stats"] = Color3.fromRGB(255, 255, 255),
            ["Color Discord Border"] = Color3.fromRGB(255, 255, 255),
            ["Color Profile Border"] = Color3.fromRGB(255, 255,255),
            ["Color Card Border"] = Color3.fromRGB(255, 255, 255),
            ["Color Toggle On"] = Color3.fromRGB(255, 255, 0),
            ["Color Toggle Off"] = Color3.fromRGB(0, 0, 0),
            ["Color Toggle Knob On"] = Color3.fromRGB(255, 255, 255),
            ["Color Toggle Knob Off"] = Color3.fromRGB(255, 255, 0),
            ["Color Toggle Border"] = Color3.fromRGB(255, 255, 255),
            ["Border Thickness"] = 1.5,
            ["UI Border Color"] = Color3.fromRGB(255,255,255),
        },
        
        -- Theme 1: NeonX
        NeonX = {
            ["Color Hub 1"] = Color3.fromRGB(10, 10, 20),
            ["Color Hub 2"] = Color3.fromRGB(20, 18, 30),
            ["Color Stroke"] = Color3.fromRGB(180, 0, 255),
            ["Color Theme"] = Color3.fromRGB(0, 255, 200),
            ["Color Text"] = Color3.fromRGB(220, 220, 255),
            ["Color Dark Text"] = Color3.fromRGB(150, 150, 200),
            ["Color Discord Text"] = Color3.fromRGB(220, 220, 255),
            ["Color Discord Stats"] = Color3.fromRGB(180, 180, 220),
            ["Color Discord Border"] = Color3.fromRGB(180, 0, 255),
            ["Color Profile Border"] = Color3.fromRGB(180, 0, 255),
            ["Color Card Border"] = Color3.fromRGB(180, 0, 255),
            ["Color Toggle On"] = Color3.fromRGB(0, 255, 200),
            ["Color Toggle Off"] = Color3.fromRGB(40, 35, 60),
            ["Color Toggle Knob On"] = Color3.fromRGB(255, 255, 255),
            ["Color Toggle Knob Off"] = Color3.fromRGB(150, 100, 200),
            ["Color Toggle Border"] = Color3.fromRGB(180, 0, 255),
            ["Border Thickness"] = 2,
            ["UI Border Color"] = Color3.fromRGB(180, 0, 255),
        },

        -- Theme 2: DarkOcean
        DarkOcean = {
            ["Color Hub 1"] = Color3.fromRGB(5, 10, 20),
            ["Color Hub 2"] = Color3.fromRGB(15, 25, 40),
            ["Color Stroke"] = Color3.fromRGB(0, 150, 255),
            ["Color Theme"] = Color3.fromRGB(0, 200, 255),
            ["Color Text"] = Color3.fromRGB(210, 235, 255),
            ["Color Dark Text"] = Color3.fromRGB(140, 180, 220),
            ["Color Discord Text"] = Color3.fromRGB(210, 235, 255),
            ["Color Discord Stats"] = Color3.fromRGB(170, 200, 230),
            ["Color Discord Border"] = Color3.fromRGB(0, 150, 255),
            ["Color Profile Border"] = Color3.fromRGB(0, 150, 255),
            ["Color Card Border"] = Color3.fromRGB(0, 150, 255),
            ["Color Toggle On"] = Color3.fromRGB(0, 200, 255),
            ["Color Toggle Off"] = Color3.fromRGB(30, 50, 80),
            ["Color Toggle Knob On"] = Color3.fromRGB(255, 255, 255),
            ["Color Toggle Knob Off"] = Color3.fromRGB(100, 150, 200),
            ["Color Toggle Border"] = Color3.fromRGB(0, 150, 255),
            ["Border Thickness"] = 1.5,
            ["UI Border Color"] = Color3.fromRGB(0, 150, 255),
        },
        
        -- Theme 3: RoyalPurple (thêm mới)
        RoyalPurple = {
            ["Color Hub 1"] = Color3.fromRGB(20, 10, 30),
            ["Color Hub 2"] = Color3.fromRGB(30, 15, 45),
            ["Color Stroke"] = Color3.fromRGB(180, 100, 255),
            ["Color Theme"] = Color3.fromRGB(200, 120, 255),
            ["Color Text"] = Color3.fromRGB(240, 220, 255),
            ["Color Dark Text"] = Color3.fromRGB(180, 160, 200),
            ["Color Discord Text"] = Color3.fromRGB(240, 220, 255),
            ["Color Discord Stats"] = Color3.fromRGB(200, 180, 220),
            ["Color Discord Border"] = Color3.fromRGB(180, 100, 255),
            ["Color Profile Border"] = Color3.fromRGB(180, 100, 255),
            ["Color Card Border"] = Color3.fromRGB(180, 100, 255),
            ["Color Toggle On"] = Color3.fromRGB(200, 120, 255),
            ["Color Toggle Off"] = Color3.fromRGB(50, 30, 70),
            ["Color Toggle Knob On"] = Color3.fromRGB(255, 255, 255),
            ["Color Toggle Knob Off"] = Color3.fromRGB(180, 140, 220),
            ["Color Toggle Border"] = Color3.fromRGB(180, 100, 255),
            ["Border Thickness"] = 2,
            ["UI Border Color"] = Color3.fromRGB(180, 100, 255),
        }
    },
    -- Phần còn lại giữ nguyên...
}
    Info = {
        Version = "1.2.0"
    },
    Save = {
        UISize = {550, 380},
        TabSize = 160,
        Theme = "QuangHuy",
        BarPosition = {X = 350, Y = -65}
    },
    Settings = {},
    Connection = {},
    Instances = {},
    Elements = {},
    Options = {},
    Flags = {},
    Tabs = {},
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
            table.foreach(Children, function(_,Child)
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
                if rawget(decode, "Theme") and VerifyTheme(decode["Theme"]) then bearlib.Save["Theme"] = decode["Theme"] end
                if rawget(decode, "BarPosition") then 
                    bearlib.Save["BarPosition"] = decode["BarPosition"]
                end
            end
        end
    end
    
    pcall(Save, "bear library OneUi.json")
end

local Funcs = {} do
    function Funcs:InsertCallback(tab, func)
        if type(func) == "function" then
            table.insert(tab, func)
        end
        return func
    end
    
    function Funcs:FireCallback(tab, ...)
        for _,v in ipairs(tab) do
            if type(v) == "function" then
                task.spawn(v, ...)
            end
        end
    end
    
    function Funcs:ToggleVisible(Obj, Bool)
        Obj.Visible = Bool ~= nil and Bool or Obj.Visible
    end
    
    function Funcs:GetConnectionFunctions(ConnectedFuncs, func)
        local Connected = { Function = func, Connected = true }
        
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
        local func = Configs[index] or Configs.Callback or function()end
        
        if type(func) == "table" then
            return ({function(Value) func[1][func[2]] = Value end})
        end
        return {func}
    end
end

local Connections, Connection = {}, bearlib.Connection do
    local function NewConnectionList(List)
        if type(List) ~= "table" then return end
        
        for _,CoName in ipairs(List) do
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
                    
                    local _NFunc;_NFunc = function(...)
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
        for _,Func in pairs(Connection) do
            task.spawn(Func, ...)
        end
    end
    
    NewConnectionList({"FlagsChanged", "ThemeChanged", "FileSaved", "ThemeChanging", "OptionAdded"})
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
            db=true;task.wait(0.1);db=false
            
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
    Name = "bear Library OneUi",
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

local function GetStr(val)
    if type(val) == "function" then
        return val()
    end
    return val
end

local function ConnectSave(Instance, func)
    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
            end
            func()
        end
    end)
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
        
        Instance.MouseButton1Down:Connect(function()
            InputOn = true
        end)
        
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                StartPos = Instance.Position
                DragStart = Input.Position
                
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do RunService.Heartbeat:Wait()
                    if InputOn then
                        Update(Input)
                    end
                end
                InputOn = false
            end
        end)
    end)
    return Instance
end

local function VerifyTheme(Theme)
    for name,_ in pairs(bearlib.Themes) do
        if name == Theme then
            return true
        end
    end
end

local function SaveJson(FileName, save)
    if writefile then
        local json = HttpService:JSONEncode(save)
        writefile(FileName, json)
    end
end

local Theme = bearlib.Themes[bearlib.Save.Theme]

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
    }) Make("Corner", Frame, UDim.new(0, 6))
    
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

local function GetColor(Instance)
    if Instance:IsA("Frame") then
        return "BackgroundColor3"
    elseif Instance:IsA("ImageLabel") then
        return "ImageColor3"
    elseif Instance:IsA("TextLabel") then
        return "TextColor3"
    elseif Instance:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif Instance:IsA("UIStroke") then
        return "Color"
    end
    return ""
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

function bearlib:SetTheme(NewTheme)
    if not VerifyTheme(NewTheme) then return end
    
    bearlib.Save.Theme = NewTheme
    SaveJson("bear library OneUi.json", bearlib.Save)
    
    local OldTheme = Theme
    Theme = bearlib.Themes[NewTheme]
    
    if MainFrame then
        if NewTheme == "QuangHuy" then
            MainFrame.BackgroundTransparency = 0.03
        end
    end
    
    Connection:FireConnection("ThemeChanged", NewTheme)
    
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
                elseif parent.Name == "Hub" or (parent:IsA("ImageButton") and parent.Name == "Hub") then
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
        end
    end
    
    if SearchButton then
        SearchButton.ImageColor3 = Theme["Color Text"]
    end
    if MinimizeButton then
        MinimizeButton.ImageColor3 = Theme["Color Text"]
    end
    if MusicButton then
        MusicButton.ImageColor3 = Theme["Color Text"]
    end
    
    if MinimizedBar then
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
    end
    
    for _, TabData in pairs(bearlib.Tabs) do
        if TabData and TabData.func and TabData.func.Cont then
            local container = TabData.func.Cont
            local tabButton = container and container.Parent
            if tabButton and tabButton:IsA("TextButton") then
                local textLabel = tabButton:FindFirstChildOfClass("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = Theme["Color Text"]
                end
                
                local imageLabel = tabButton:FindFirstChildOfClass("ImageLabel")
                if imageLabel then
                    imageLabel.ImageColor3 = Theme["Color Text"]
                end
                
                local selectedFrame = tabButton:FindFirstChildOfClass("Frame")
                if selectedFrame and selectedFrame.Name ~= "Selected" then
                    for _, child in pairs(tabButton:GetChildren()) do
                        if child:IsA("Frame") and child.BackgroundColor3 == OldTheme["Color Theme"] then
                            child.BackgroundColor3 = Theme["Color Theme"]
                        end
                    end
                end
            end
        end
    end
    
    task.wait()
    if MainFrame then
        MainFrame.BackgroundTransparency = MainFrame.BackgroundTransparency
    end
    
    print("Theme changed to:", NewTheme)
end

function bearlib:SetScale(NewScale)
    NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
    UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end

local MainFrame = nil
local SearchButton = nil
local MinimizeButton = nil
local MusicButton = nil
local ToggleButton = nil
local ToggleGui = nil
local MinimizedBar = nil
local Minimized = false
local UIFullVisible = true
local SaveSize = nil
local BarPosition = bearlib.Save.BarPosition
local WaitClick = false
local bgTransparency = 0.03

local MusicFrameVisible = false
local MusicFrame = nil

local function SaveBarPosition()
    if MinimizedBar and MinimizedBar.Parent then
        bearlib.Save.BarPosition = {
            X = MinimizedBar.Position.X.Offset,
            Y = MinimizedBar.Position.Y.Offset
        }
        BarPosition = bearlib.Save.BarPosition
        SaveJson("bear library OneUi.json", bearlib.Save)
    end
end

local function LoadMusicFrame()
    if MusicFrame and MusicFrame.Parent then
        if MusicFrame.Enabled then
            MusicFrame.Enabled = false
            MusicFrameVisible = false
            MusicButton.Image = "rbxassetid://10734972621"
        else
            MusicFrame.Enabled = true
            MusicFrameVisible = true
            MusicButton.Image = "rbxassetid://10734923549"
        end
        return
    end
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")
    
    MusicFrame = Instance.new("ScreenGui")
    MusicFrame.Name = "KhungAnhKhongChu"
    MusicFrame.Parent = gui
    MusicFrame.IgnoreGuiInset = true
    MusicFrame.ResetOnSpawn = false
    MusicFrame.Enabled = true
    
    local sound = Instance.new("Sound")
    sound.Name = "BackgroundMusic"
    sound.SoundId = "rbxassetid://99152674992699"
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = MusicFrame
    
    local isPlaying = true
    local songList = {
        "rbxassetid://99152674992699",
        "rbxassetid://87726330432189",
        "rbxassetid://110919391228823"
    }
    local currentSongIndex = 1
    
    local function getSongNameFromId(soundId)
        local id = soundId:match("%d+")
        if id then
            local success, result = pcall(function()
                return game:GetService("MarketplaceService"):GetProductInfo(tonumber(id))
            end)
            if success and result then
                return result.Name
            end
        end
        return "Âm nhạc"
    end
    
    local songName = getSongNameFromId(sound.SoundId)
    
    local mainControlFrame = Instance.new("Frame")
    mainControlFrame.Name = "MainControlFrame"
    mainControlFrame.Size = UDim2.new(0, 220, 0, 120)
    mainControlFrame.Position = UDim2.new(1, -230, 0, 10)
    mainControlFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainControlFrame.BackgroundTransparency = 0.2
    mainControlFrame.Parent = MusicFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainControlFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 255, 255)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = mainControlFrame
    
    local idInputFrame = Instance.new("Frame")
    idInputFrame.Name = "IDInputFrame"
    idInputFrame.Size = UDim2.new(1, -20, 0, 30)
    idInputFrame.Position = UDim2.new(0, 10, 0, 10)
    idInputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    idInputFrame.BackgroundTransparency = 0.3
    idInputFrame.Parent = mainControlFrame
    
    local idInputCorner = Instance.new("UICorner")
    idInputCorner.CornerRadius = UDim.new(0, 6)
    idInputCorner.Parent = idInputFrame
    
    local idTextBox = Instance.new("TextBox")
    idTextBox.Name = "IDTextBox"
    idTextBox.Size = UDim2.new(1, -35, 1, 0)
    idTextBox.Position = UDim2.new(0, 5, 0, 0)
    idTextBox.BackgroundTransparency = 1
    idTextBox.Text = "Nhập ID nhạc..."
    idTextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    idTextBox.TextSize = 12
    idTextBox.Font = Enum.Font.SourceSans
    idTextBox.TextXAlignment = Enum.TextXAlignment.Left
    idTextBox.PlaceholderText = "Nhập ID nhạc..."
    idTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    idTextBox.ClearTextOnFocus = true
    idTextBox.Parent = idInputFrame
    
    local playButton = Instance.new("ImageButton")
    playButton.Name = "PlayButton"
    playButton.Size = UDim2.new(0, 20, 0, 20)
    playButton.Position = UDim2.new(1, -25, 0.5, -10)
    playButton.BackgroundTransparency = 1
    playButton.Image = "rbxassetid://10734923549"
    playButton.ScaleType = Enum.ScaleType.Fit
    playButton.Parent = idInputFrame
    
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlFrame"
    controlFrame.Size = UDim2.new(1, -20, 0, 30)
    controlFrame.Position = UDim2.new(0, 10, 0, 45)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = mainControlFrame
    
    local prevButton = Instance.new("ImageButton")
    prevButton.Name = "PreviousMusic"
    prevButton.Size = UDim2.new(0, 24, 0, 24)
    prevButton.Position = UDim2.new(0.2, -12, 0, 3)
    prevButton.BackgroundTransparency = 1
    prevButton.Image = "rbxassetid://10734972621"
    prevButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    prevButton.ScaleType = Enum.ScaleType.Fit
    prevButton.Rotation = 180
    prevButton.Parent = controlFrame
    
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Name = "ToggleMusic"
    toggleButton.Size = UDim2.new(0, 24, 0, 24)
    toggleButton.Position = UDim2.new(0.5, -12, 0, 3)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Image = "rbxassetid://10734923549"
    toggleButton.ScaleType = Enum.ScaleType.Fit
    toggleButton.Parent = controlFrame
    
    local nextButton = Instance.new("ImageButton")
    nextButton.Name = "NextMusic"
    nextButton.Size = UDim2.new(0, 24, 0, 24)
    nextButton.Position = UDim2.new(0.8, -12, 0, 3)
    nextButton.BackgroundTransparency = 1
    nextButton.Image = "rbxassetid://10734972621"
    nextButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    nextButton.ScaleType = Enum.ScaleType.Fit
    nextButton.Parent = controlFrame
    
    local musicText = Instance.new("TextLabel")
    musicText.Name = "MusicText"
    musicText.Size = UDim2.new(1, -20, 0, 20)
    musicText.Position = UDim2.new(0, 10, 0, 80)
    musicText.BackgroundTransparency = 1
    musicText.Text = songName
    musicText.TextColor3 = Color3.fromRGB(255, 255, 255)
    musicText.TextSize = 12
    musicText.Font = Enum.Font.SourceSansBold
    musicText.TextStrokeTransparency = 0.3
    musicText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    musicText.TextXAlignment = Enum.TextXAlignment.Center
    musicText.TextTruncate = Enum.TextTruncate.AtEnd
    musicText.Parent = mainControlFrame
    
    local timeFrame = Instance.new("Frame")
    timeFrame.Name = "TimeFrame"
    timeFrame.Size = UDim2.new(1, -30, 0, 4)
    timeFrame.Position = UDim2.new(0, 15, 0, 105)
    timeFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    timeFrame.BackgroundTransparency = 0.3
    timeFrame.Parent = mainControlFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressBar.Parent = timeFrame
    
    local timeCorner = Instance.new("UICorner")
    timeCorner.CornerRadius = UDim.new(1, 0)
    timeCorner.Parent = timeFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBar
    
    local seekButton = Instance.new("ImageButton")
    seekButton.Name = "SeekButton"
    seekButton.Size = UDim2.new(1, 0, 3, 0)
    seekButton.Position = UDim2.new(0, 0, 0.5, -6)
    seekButton.BackgroundTransparency = 1
    seekButton.Parent = timeFrame
    
    local function playMusicById(id)
        local success, result = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(tonumber(id))
        end)
        
        if success and result and result.AssetTypeId == 3 then
            sound:Stop()
            sound.SoundId = "rbxassetid://" .. id
            sound:Play()
            isPlaying = true
            toggleButton.Image = "rbxassetid://10734923549"
            musicText.Text = result.Name or "ID: " .. id
            idTextBox.Text = ""
            progressBar.Size = UDim2.new(0, 0, 1, 0)
        else
            idTextBox.Text = "ID không hợp lệ!"
            task.wait(1)
            idTextBox.Text = "Nhập ID nhạc..."
        end
    end
    
    playButton.MouseButton1Click:Connect(function()
        local id = idTextBox.Text:match("%d+")
        if id then
            playMusicById(id)
        else
            idTextBox.Text = "Vui lòng nhập ID!"
            task.wait(1)
            idTextBox.Text = "Nhập ID nhạc..."
        end
    end)
    
    idTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local id = idTextBox.Text:match("%d+")
            if id then
                playMusicById(id)
            else
                idTextBox.Text = "ID không hợp lệ!"
                task.wait(1)
                idTextBox.Text = "Nhập ID nhạc..."
            end
        end
    end)
    
    local isDragging = false
    local totalTime = 0
    
    local function updateSongInfo()
        songName = getSongNameFromId(sound.SoundId)
        musicText.Text = songName
    end
    
    local function playSong(index)
        if index < 1 then
            index = #songList
        elseif index > #songList then
            index = 1
        end
        currentSongIndex = index
        
        sound:Stop()
        sound.SoundId = songList[currentSongIndex]
        sound:Play()
        isPlaying = true
        toggleButton.Image = "rbxassetid://10734923549"
        updateSongInfo()
        progressBar.Size = UDim2.new(0, 0, 1, 0)
    end
    
    local function updateProgress()
        if sound.TimeLength > 0 and sound.TimeLength < 1e6 then
            totalTime = sound.TimeLength
            if not isDragging then
                local progress = sound.TimePosition / totalTime
                progressBar.Size = UDim2.new(progress, 0, 1, 0)
            end
        end
    end
    
    game:GetService("RunService").RenderStepped:Connect(updateProgress)
    
    local function seekToMouse(input)
        if timeFrame.AbsoluteSize.X > 0 then
            local relativeX = math.clamp(input.Position.X - timeFrame.AbsolutePosition.X, 0, timeFrame.AbsoluteSize.X)
            local seekPercent = relativeX / timeFrame.AbsoluteSize.X
            progressBar.Size = UDim2.new(seekPercent, 0, 1, 0)
        end
    end
    
    seekButton.MouseButton1Down:Connect(function()
        isDragging = true
        local moveConnection = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                seekToMouse(input)
            end
        end)
        local releaseConnection = game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
                if sound.TimeLength > 0 and sound.TimeLength < 1e6 then
                    sound.TimePosition = progressBar.Size.X.Scale * sound.TimeLength
                end
                moveConnection:Disconnect()
                releaseConnection:Disconnect()
            end
        end)
    end)
    
    seekButton.MouseButton1Click:Connect(function(input)
        seekToMouse(input)
        if sound.TimeLength > 0 and sound.TimeLength < 1e6 then
            sound.TimePosition = progressBar.Size.X.Scale * sound.TimeLength
        end
    end)
    
    sound.Ended:Connect(function()
        if not sound.Looped then
            playSong(currentSongIndex + 1)
        end
    end)
    
    toggleButton.MouseButton1Click:Connect(function()
        if isPlaying then
            sound:Pause()
            toggleButton.Image = "rbxassetid://10734972621"
        else
            sound:Play()
            toggleButton.Image = "rbxassetid://10734923549"
        end
        isPlaying = not isPlaying
    end)
    
    prevButton.MouseButton1Click:Connect(function()
        playSong(currentSongIndex - 1)
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        playSong(currentSongIndex + 1)
    end)
    
    sound:Play()
    
    game:BindToClose(function()
        if sound then
            sound:Stop()
        end
    end)
    
    MusicFrameVisible = true
    MusicButton.Image = "rbxassetid://10734923549"
end

function bearlib:MakeWindow(Configs)
    local WTitle = Configs[1] or Configs.Name or Configs.Title or "bear Library OneUi"
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
                local s,r = pcall(function() return HttpService:JSONDecode(_Flags) end)
                Flags = s and r or {}
            end
        end
    end;LoadFile()
    
    local UISizeX, UISizeY = unpack(bearlib.Save.UISize)
    
    MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
        Size = UDim2.fromOffset(UISizeX, UISizeY),
        Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
        BackgroundTransparency = bgTransparency,
        Name = "Hub"
    }), "Main")
    Make("Gradient", MainFrame, 45)
    MakeDrag(MainFrame)
    
    local MainCorner = Make("Corner", MainFrame, UDim.new(0, 7))
    
    local UIBorder = Instance.new("UIStroke")
    UIBorder.Name = "UIBorder"
    UIBorder.Color = Theme["UI Border Color"] or Color3.fromRGB(255, 215, 0)
    UIBorder.Thickness = 1.5
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
        Position = UDim2.new(0, 15, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = "XY",
        Text = WTitle,
        TextXAlignment = "Left",
        TextSize = 12,
        TextColor3 = Theme["Color Text"],
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Name = "Title"
    }, {
        InsertTheme(Create("TextLabel", {
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = "X",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(1, 5, 0.9),
            Text = WMiniText,
            TextColor3 = Theme["Color Dark Text"],
            BackgroundTransparency = 1,
            TextXAlignment = "Left",
            TextYAlignment = "Bottom",
            TextSize = 8,
            Font = Enum.Font.Gotham,
            Name = "SubTitle"
        }), "DarkText")
    }), "Text")
    
    local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
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
            Padding = UDim.new(0, 5)
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
    
    local SearchContainer = InsertTheme(Create("ScrollingFrame", Components, {
        Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 1.5,
        ScrollBarImageTransparency = 0.2,
        ScrollBarImageColor3 = Theme["Color Theme"],
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        Name = "SearchContainer"
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        }),
        Create("UIListLayout", {
            SortOrder = "LayoutOrder",
            Padding = UDim.new(0, 5)
        })
    }), "ScrollBar")
    
    local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 35, 0, 35),
        Position = MainFrame.Size,
        Active = true,
        AnchorPoint = Vector2.new(0.8, 0.8),
        BackgroundTransparency = 1,
        Name = "Control Hub Size"
    })), MakeDrag(Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 20, 1, -30),
        Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
        AnchorPoint = Vector2.new(0.5, 1),
        Active = true,
        BackgroundTransparency = 1,
        Name = "Control Tab Size"
    }))
    
    local function ControlSize()
        local Pos1, Pos2 = ControlSize1.Position, ControlSize2.Position
        ControlSize1.Position = UDim2.fromOffset(math.clamp(Pos1.X.Offset, 430, 1000), math.clamp(Pos1.Y.Offset, 200, 500))
        ControlSize2.Position = UDim2.new(0, math.clamp(Pos2.X.Offset, 135, 250), 1, 0)
        
        MainScroll.Size = UDim2.new(0, ControlSize2.Position.X.Offset, 1, -TopBar.Size.Y.Offset)
        Containers.Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
        SearchContainer.Size = Containers.Size
        MainFrame.Size = ControlSize1.Position
    end
    
    ControlSize1:GetPropertyChangedSignal("Position"):Connect(ControlSize)
    ControlSize2:GetPropertyChangedSignal("Position"):Connect(ControlSize)
    
    ConnectSave(ControlSize1, function()
        if MainFrame.Visible then
            bearlib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
            SaveJson("bear library OneUi.json", bearlib.Save)
        end
    end)
    
    ConnectSave(ControlSize2, function()
        bearlib.Save.TabSize = MainScroll.Size.X.Offset
        SaveJson("bear library OneUi.json", bearlib.Save)
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
    
    local MinimizeButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -35, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734896206",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "Minimize"
    })
    
    MusicButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -60, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734972621",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "Music"
    })
    
    local SearchButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -85, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734943674",
        ImageColor3 = Theme["Color Text"],
        Name = "Search"
    })
    
    SetChildren(ButtonsFolder, {
        CloseButton,
        MinimizeButton,
        MusicButton,
        SearchButton
    })
    
    local SearchInputFrame = InsertTheme(Create("Frame", TopBar, {
        Size = UDim2.new(0, 0, 0, 22),
        Position = UDim2.new(1, -85, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme["Color Hub 2"],
        ClipsDescendants = true
    }), "Frame")
    Make("Corner", SearchInputFrame, UDim.new(0, 4))
    Make("Stroke", SearchInputFrame)
    
    local SearchInput = InsertTheme(Create("TextBox", SearchInputFrame, {
        Size = UDim2.new(1, -5, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search...",
        TextColor3 = Theme["Color Text"],
        TextSize = 10,
        TextXAlignment = "Left",
        Text = ""
    }), "Text")
    
    local SearchActive = false
    
    local function UpdateSearch(Query)
        Query = string.lower(Query)
        
        for _, ElementData in pairs(bearlib.AllElements) do
            if ElementData.Instance and ElementData.OriginalParent then
                if ElementData.Instance.Parent == SearchContainer then
                    ElementData.Instance.Parent = ElementData.OriginalParent
                    ElementData.Instance.Visible = true
                end
            end
        end
        
        if Query == "" then return end
        
        for _, ElementData in pairs(bearlib.AllElements) do
            local Name = string.lower(ElementData.Name)
            local MatchName = string.find(Name, Query)
            
            if MatchName then
                if ElementData.Instance then
                    ElementData.Instance.Parent = SearchContainer
                    ElementData.Instance.Visible = true
                end
            end
        end
    end
    
    SearchButton.Activated:Connect(function()
        SearchActive = not SearchActive
        if SearchActive then
            CreateTween({SearchInputFrame, "Size", UDim2.new(0, 120, 0, 22), 0.3})
            SearchContainer.Visible = true
            Containers.Visible = false
            SearchInput:CaptureFocus()
        else
            CreateTween({SearchInputFrame, "Size", UDim2.new(0, 0, 0, 22), 0.3})
            SearchInput.Text = ""
            UpdateSearch("")
            SearchContainer.Visible = false
            Containers.Visible = true
        end
    end)
    
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        if SearchActive then
            UpdateSearch(SearchInput.Text)
        end
    end)
    
    MusicButton.Activated:Connect(function()
        LoadMusicFrame()
    end)
    
    local Window, FirstTab = {}, false
    
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
        ControlSize1.Visible = false
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
            ControlSize1.Visible = true
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
                ControlSize1.Visible = false
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
        ControlSize1.Visible = true
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
        if type(Val1) == "string" and type(Val2) == "string" then
            Title.Text = Val1
            Title.SubTitle.Text = Val2
            if MinimizedBar then
                local barText = MinimizedBar:FindFirstChildOfClass("TextLabel")
                if barText then
                    barText.Text = Val1
                end
            end
        elseif type(Val1) == "string" then
            Title.Text = Val1
            if MinimizedBar then
                local barText = MinimizedBar:FindFirstChildOfClass("TextLabel")
                if barText then
                    barText.Text = Val1
                end
            end
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
        Make("Corner", Frame)
        
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
        
        MainCorner:Clone().Parent = Screen
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
            local Callback = Configs[2] or Configs.Callback or function()end
            
            ButtonCount = ButtonCount + 1
            local Button = Make("Button", ButtonsHolder)
            Make("Corner", Button)
            SetProps(Button, {
                Text = Name,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"],
                TextSize = 12,
                ZIndex = 202
            })
            
            for _,Btn in pairs(ButtonsHolder:GetChildren()) do
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
        table.foreach(DOptions, function(_,Button)
            Dialog:Button(Button)
        end)
        return Dialog
    end
    
    function Window:SelectTab(TabSelect)
        if type(TabSelect) == "number" then
            bearlib.Tabs[TabSelect].func:Enable()
        else
            for _,Tab in pairs(bearlib.Tabs) do
                if Tab.Cont == TabSelect.Cont then
                    Tab.func:Enable()
                end
            end
        end
    end
    
    local ContainerList = {}
    function Window:MakeTab(paste, Configs)
        if type(paste) == "table" then Configs = paste end
        local TName = Configs[1] or Configs.Title or "Tab!"
        local TIcon = Configs[2] or Configs.Icon or ""
        
        TIcon = bearlib:GetIcon(TIcon)
        if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
            TIcon = false
        end
        
        local TabSelect = Make("Button", MainScroll, {
            Size = UDim2.new(1, 0, 0, 24)
        }) Make("Corner", TabSelect)
        
        local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
            Size = UDim2.new(1, TIcon and -25 or -15, 1),
            Position = UDim2.fromOffset(TIcon and 25 or 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = TName,
            TextColor3 = Theme["Color Text"],
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = (FirstTab and 0.3) or 0,
            TextTruncate = "AtEnd",
            ZIndex = 5
        }), "Text")
        
        local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
            Position = UDim2.new(0, 8, 0.5),
            Size = UDim2.new(0, 13, 0, 13),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = TIcon or "",
            BackgroundTransparency = 1,
            ImageTransparency = (FirstTab and 0.3) or 0,
            ImageColor3 = Theme["Color Text"],
            ZIndex = 5
        }), "Text")
        
        local Selected = InsertTheme(Create("Frame", TabSelect, {
            Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13),
            Position = UDim2.new(0, 1, 0.5),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme["Color Theme"],
            BackgroundTransparency = FirstTab and 1 or 0,
            ZIndex = 4
        }), "Theme") Make("Corner", Selected, UDim.new(0.5, 0))
        
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
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            }), Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = "LayoutOrder"
            })
        }), "ScrollBar")
        
        table.insert(ContainerList, Container)
        
        if not FirstTab then Container.Parent = Containers end
        
        local function Tabs()
            if Container.Parent then return end
            for _,Frame in pairs(ContainerList) do
                if Frame:IsA("ScrollingFrame") and Frame ~= Container then
                    Frame.Parent = nil
                end
            end
            Container.Parent = Containers
            Container.Size = UDim2.new(1, 0, 1, 150)
            table.foreach(bearlib.Tabs, function(_,Tab)
                if Tab.Cont ~= Container then
                    Tab.func:Disable()
                end
            end)
            CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
            CreateTween({LabelTitle, "TextTransparency", 0, 0.35})
            CreateTween({LabelIcon, "ImageTransparency", 0, 0.35})
            CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35})
            CreateTween({Selected, "BackgroundTransparency", 0, 0.35})
        end
        TabSelect.Activated:Connect(Tabs)
        
        FirstTab = true
        local Tab = {}
        table.insert(bearlib.Tabs, {TabInfo = {Name = TName, Icon = TIcon}, func = Tab, Cont = Container})
        Tab.Cont = Container
        
        local ElementCount = 0
        local function GetOrder()
            ElementCount = ElementCount + 1
            return ElementCount
        end
        
        function Tab:Disable()
            Container.Parent = nil
            CreateTween({LabelTitle, "TextTransparency", 0.3, 0.35})
            CreateTween({LabelIcon, "ImageTransparency", 0.3, 0.35})
            CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35})
            CreateTween({Selected, "BackgroundTransparency", 1, 0.35})
        end
        function Tab:Enable()
            Tabs()
        end
        function Tab:Visible(Bool)
            Funcs:ToggleVisible(TabSelect, Bool)
        end
        function Tab:Destroy() TabSelect:Destroy() Container:Destroy() end
        
        local CurrentSectionName = nil
        
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
            
            local UnderlineFrame = Create("Frame", SectionFrame, {
                Size = UDim2.new(1, -10, 0, 1.5),
                Position = UDim2.new(0, 5, 1, -5),
                BackgroundColor3 = Theme["UI Border Color"],
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                ZIndex = 2
            })
            
            table.insert(bearlib.Instances, {
                Instance = UnderlineFrame,
                Type = "UIBorder"
            })
            
            local UnderlineGradient = Instance.new("UIGradient")
            UnderlineGradient.Rotation = 90
            UnderlineGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Theme["UI Border Color"]),
                ColorSequenceKeypoint.new(0.50, Theme["Color Theme"]),
                ColorSequenceKeypoint.new(1.00, Theme["UI Border Color"])
            })
            UnderlineGradient.Parent = UnderlineFrame
            
            table.insert(bearlib.Instances, {
                Instance = UnderlineGradient,
                Type = "Gradient"
            })
            
            table.insert(bearlib.AllElements, {
                Name = SectionName,
                Instance = SectionFrame,
                OriginalParent = Container,
                SectionName = SectionName,
                Underline = UnderlineFrame,
                UnderlineGradient = UnderlineGradient
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
            
            local Toggle = {}
            function Toggle:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function Toggle:Destroy() Button:Destroy() end
            function Toggle:Callback(...) Funcs:InsertCallback(Callback, ...)() end
            function Toggle:Set(Val1, Val2)
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
            return Toggle
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
            }) Make("Corner", DropFrame) Make("Stroke", DropFrame) Make("Gradient", DropFrame, 60)
            
            local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, {
                ScrollBarImageColor3 = Theme["Color Theme"],
                Size = UDim2.new(1, 0, 1, 0),
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
            local function Disable()
                WaitClick = true
                CreateTween({Arrow, "Rotation", 0, 0.2})
                CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                Arrow.Image = "rbxassetid://10709791523"
                NoClickFrame.Visible = false
                WaitClick = false
            end
            
            local function GetFrameSize()
                return UDim2.fromOffset(152, ScrollSize)
            end
            
            local function CalculateSize()
                local Count = 0
                for _,Frame in pairs(ScrollFrame:GetChildren()) do
                    if Frame:IsA("Frame") or Frame.Name == "Option" then
                        Count = Count + 1
                    end
                end
                ScrollSize = (math.clamp(Count, 0, 10) * 25) + 10
                if NoClickFrame.Visible then
                    NoClickFrame.Visible = true
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
                local ClampY = math.clamp((FramePos.Y / UIScale) , 0, ScreenSize.Y / UIScale)
                
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
                        for _,v in pairs(Options) do
                            local nodes, Stats = v.nodes, v.Stats
                            CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 0.8, 0.35})
                            CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 4), 0.35})
                            CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.35})
                        end
                    else
                        for _,v in pairs(Options) do
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
            
            Button.Activated:Connect(Minimize)
            NoClickFrame.MouseButton1Down:Connect(Disable)
            NoClickFrame.MouseButton1Click:Connect(Disable)
            MainFrame:GetPropertyChangedSignal("Visible"):Connect(Disable)
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
                    for _,Val in pairs(Options) do
                        if Val.Name == Option then
                            Select(Val)
                        end
                    end
                elseif type(Option) == "number" then
                    local i = 0
                    for _,Val in pairs(Options) do
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
                CreateTween({ SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true })
            end; SetSlider(Default)
            
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
                card2 = createDiscordCard(Configs[2], 2)
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
        ToggleButton.Image = "rbxassetid://108449485047823"
        ToggleButton.BackgroundColor3 = Theme["Color Hub 2"]
        ToggleButton.BackgroundTransparency = 0.2
        ToggleButton.Active = true
        ToggleButton.Draggable = true
        ToggleButton.Parent = ToggleGui
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleButton
        
        ToggleButton.MouseButton1Click:Connect(function()
            if MainFrame.Visible then
                MainFrame.Visible = false
                ControlSize1.Visible = false
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
                ControlSize1.Visible = true
                ControlSize2.Visible = true
                UIFullVisible = true
            end
        end)
        
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
    end)
    
    return Window
end

local NotificationHolder = nil
local NotificationQueue = {}
local NotificationActive = false
local ActiveNotifications = {}

local function CreateNotificationHolder()
    if NotificationHolder and NotificationHolder.Parent then
        return NotificationHolder
    end
    
    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 340, 0, 0)
    NotificationHolder.Position = UDim2.new(1, -350, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(0, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 1000
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = NotificationHolder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 10)
    
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
    Notification.Size = UDim2.new(0, 300, 0, 0)
    Notification.AutomaticSize = Enum.AutomaticSize.Y
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Notification.BackgroundTransparency = 0
    Notification.Parent = holder
    Notification.ZIndex = 1001
    Notification.ClipsDescendants = true
    Notification.BorderSizePixel = 0
    Notification.LayoutOrder = #ActiveNotifications + 1
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2
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
    TimerFrame.Size = UDim2.new(0, 30, 0, 30)
    TimerFrame.Position = UDim2.new(1, -5, 0, 0)
    TimerFrame.BackgroundTransparency = 1
    TimerFrame.ZIndex = 1002
    TimerFrame.Parent = Notification
    
    local TimerText = Instance.new("TextLabel")
    TimerText.Name = "TimerText"
    TimerText.Size = UDim2.new(1, 0, 1, 0)
    TimerText.BackgroundTransparency = 1
    TimerText.Font = Enum.Font.GothamBold
    TimerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerText.TextSize = 14
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
    MainLayout.Padding = UDim.new(0, 12)
    
    local Padding = Instance.new("UIPadding")
    Padding.Parent = Notification
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 35)
    
    local IconContainer = Instance.new("Frame")
    IconContainer.Parent = Notification
    IconContainer.Size = UDim2.new(0, 40, 0, 40)
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
    TextContainer.Size = UDim2.new(1, -100, 0, 0)
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
    TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15
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
    MessageLabel.TextSize = 13
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.Text = Message or ""
    MessageLabel.ZIndex = 1003
    MessageLabel.TextStrokeTransparency = 0.4
    MessageLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.RichText = true
    
    Notification.Position = UDim2.new(1, -10, 0, 0)
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

function bearlib:SetUIBorderColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["UI Border Color"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "UIBorder" then
                    Val.Instance.Color = color
                elseif Val.Type == "Stroke" then
                    local parent = Val.Instance.Parent
                    if parent and parent.Name == "Hub" then
                        Val.Instance.Color = color
                    end
                end
            end
        end
    end
end

function bearlib:SetDiscordBorderColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Discord Border"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "Stroke" then
                    local parent = Val.Instance.Parent
                    if parent then
                        if parent:FindFirstAncestor("DiscordInviteContainer") or 
                           parent.Name:find("DiscordCard") or
                           parent:FindFirstAncestor("DiscordCard") then
                            Val.Instance.Color = color
                        end
                    end
                end
            end
        end
    end
end

function bearlib:SetProfileBorderColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Profile Border"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "Stroke" then
                    local parent = Val.Instance.Parent
                    if parent and parent:FindFirstAncestor("Profile") then
                        Val.Instance.Color = color
                    end
                end
            end
        end
    end
end

function bearlib:SetHubColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Hub 2"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "Frame" then
                    Val.Instance.BackgroundColor3 = color
                end
            end
            if MainFrame then
                MainFrame.BackgroundColor3 = color
            end
        end
    end
end

function bearlib:SetStrokeColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Stroke"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "Stroke" then
                    local parent = Val.Instance.Parent
                    if parent then
                        if not parent:FindFirstAncestor("DiscordInviteContainer") and 
                           not parent:FindFirstAncestor("Profile") and
                           not parent.Name:find("DiscordCard") and
                           parent.Name ~= "Hub" then
                            Val.Instance.Color = color
                        end
                    end
                end
            end
        end
    end
end

function bearlib:SetTextColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Text"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "Text" then
                    Val.Instance.TextColor3 = color
                end
            end
            if SearchButton then SearchButton.ImageColor3 = color end
            if MinimizeButton then MinimizeButton.ImageColor3 = color end
            if MusicButton then MusicButton.ImageColor3 = color end
        end
    end
end

function bearlib:SetToggleOnColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Toggle On"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
        end
    end
end

function bearlib:SetToggleOffColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Toggle Off"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
        end
    end
end

function bearlib:SetToggleKnobOnColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Toggle Knob On"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
        end
    end
end

function bearlib:SetToggleKnobOffColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Toggle Knob Off"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
        end
    end
end

function bearlib:SetToggleBorderColor(color)
    if typeof(color) == "Color3" then
        self.Themes[self.Save.Theme]["Color Toggle Border"] = color
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
        end
    end
end

function bearlib:SetBorderThickness(thickness)
    if type(thickness) == "number" then
        self.Themes[self.Save.Theme]["Border Thickness"] = thickness
        if self.Save.Theme == bearlib.Save.Theme then
            Theme = self.Themes[self.Save.Theme]
            for _, Val in pairs(self.Instances) do
                if Val.Type == "Stroke" or Val.Type == "UIBorder" then
                    Val.Instance.Thickness = thickness
                end
            end
        end
    end
end

function bearlib:GetBorderColors()
    return {
        UI = Theme["UI Border Color"],
        Discord = Theme["Color Discord Border"],
        Profile = Theme["Color Profile Border"],
        Stroke = Theme["Color Stroke"],
        Thickness = Theme["Border Thickness"]
    }
end

function bearlib:GetToggleColors()
    return {
        ToggleOn = Theme["Color Toggle On"],
        ToggleOff = Theme["Color Toggle Off"],
        KnobOn = Theme["Color Toggle Knob On"],
        KnobOff = Theme["Color Toggle Knob Off"],
        Border = Theme["Color Toggle Border"]
    }
end

function bearlib:ResetBorderColors()
    local defaultTheme = self.Themes.QuangHuy
    self.Themes[self.Save.Theme]["UI Border Color"] = defaultTheme["UI Border Color"]
    self.Themes[self.Save.Theme]["Color Discord Border"] = defaultTheme["Color Discord Border"]
    self.Themes[self.Save.Theme]["Color Profile Border"] = defaultTheme["Color Profile Border"]
    self.Themes[self.Save.Theme]["Color Stroke"] = defaultTheme["Color Stroke"]
    self.Themes[self.Save.Theme]["Border Thickness"] = defaultTheme["Border Thickness"]
    
    if self.Save.Theme == bearlib.Save.Theme then
        Theme = self.Themes[self.Save.Theme]
        for _, Val in pairs(self.Instances) do
            if Val.Type == "Stroke" then
                local parent = Val.Instance.Parent
                if parent then
                    if parent:FindFirstAncestor("DiscordInviteContainer") or 
                       parent.Name:find("DiscordCard") then
                        Val.Instance.Color = Theme["Color Discord Border"]
                    elseif parent:FindFirstAncestor("Profile") then
                        Val.Instance.Color = Theme["Color Profile Border"]
                    elseif parent.Name == "Hub" then
                        Val.Instance.Color = Theme["UI Border Color"]
                    else
                        Val.Instance.Color = Theme["Color Stroke"]
                    end
                end
                Val.Instance.Thickness = Theme["Border Thickness"]
            elseif Val.Type == "UIBorder" then
                Val.Instance.Color = Theme["UI Border Color"]
                Val.Instance.Thickness = Theme["Border Thickness"]
            end
        end
    end
end

function bearlib:ResetToggleColors()
    local defaultTheme = self.Themes.QuangHuy
    self.Themes[self.Save.Theme]["Color Toggle On"] = defaultTheme["Color Toggle On"]
    self.Themes[self.Save.Theme]["Color Toggle Off"] = defaultTheme["Color Toggle Off"]
    self.Themes[self.Save.Theme]["Color Toggle Knob On"] = defaultTheme["Color Toggle Knob On"]
    self.Themes[self.Save.Theme]["Color Toggle Knob Off"] = defaultTheme["Color Toggle Knob Off"]
    self.Themes[self.Save.Theme]["Color Toggle Border"] = defaultTheme["Color Toggle Border"]
    
    if self.Save.Theme == bearlib.Save.Theme then
        Theme = self.Themes[self.Save.Theme]
    end
end

task.spawn(function()
    task.wait(2)
    bearlib:Notify({
        Title = "Bear Library",
        Message = "UI Bear Library Download Completed",
        Duration = 10
    })
end)

return bearlib