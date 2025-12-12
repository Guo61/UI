local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}
local Notifications = {}

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

local themes = {
    SchemeColor = Color3.fromRGB(74, 99, 135),
    Background = Color3.fromRGB(36, 37, 43),
    Header = Color3.fromRGB(28, 29, 34),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(32, 32, 38)
}

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255,255,255),
        Header = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(0,0,0),
        ElementColor = Color3.fromRGB(224, 224, 224)
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(10, 10, 10),
        Header = Color3.fromRGB(5, 5, 5),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    GrapeTheme = {
        SchemeColor = Color3.fromRGB(166, 71, 214),
        Background = Color3.fromRGB(64, 50, 71),
        Header = Color3.fromRGB(36, 28, 41),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(74, 58, 84)
    },
    Ocean = {
        SchemeColor = Color3.fromRGB(86, 76, 251),
        Background = Color3.fromRGB(26, 32, 58),
        Header = Color3.fromRGB(38, 45, 71),
        TextColor = Color3.fromRGB(200, 200, 200),
        ElementColor = Color3.fromRGB(38, 45, 71)
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(44, 62, 82),
        Header = Color3.fromRGB(57, 81, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(52, 74, 95)
    },
    Sentinel = {
        SchemeColor = Color3.fromRGB(230, 35, 69),
        Background = Color3.fromRGB(32, 32, 32),
        Header = Color3.fromRGB(24, 24, 24),
        TextColor = Color3.fromRGB(119, 209, 138),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Synapse = {
        SchemeColor = Color3.fromRGB(46, 48, 43),
        Background = Color3.fromRGB(13, 15, 12),
        Header = Color3.fromRGB(36, 38, 35),
        TextColor = Color3.fromRGB(152, 99, 53),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Serpent = {
        SchemeColor = Color3.fromRGB(0, 166, 58),
        Background = Color3.fromRGB(31, 41, 43),
        Header = Color3.fromRGB(22, 29, 31),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(22, 29, 31)
    }
}

local oldTheme = ""
local SettingsT = {}
local Name = "KavoConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
    end
    Settings = game:service'HttpService':JSONEncode(readfile(Name))
end)

local LibName = tostring(math.random(1, 100))..tostring(math.random(1,50))..tostring(math.random(1, 100))

function Kavo:ToggleUI()
    if game.CoreGui[LibName].Enabled then
        game.CoreGui[LibName].Enabled = false
    else
        game.CoreGui[LibName].Enabled = true
    end
end

function Kavo:Notification(title, text, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"
    
    local colors = {
        Info = Color3.fromRGB(74, 99, 135),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    }
    
    local icon = {
        Info = "rbxassetid://3926305904",
        Success = "rbxassetid://3926305904",
        Warning = "rbxassetid://3926305904",
        Error = "rbxassetid://3926305904"
    }
    
    local iconRect = {
        Info = Vector2.new(84, 204),
        Success = Vector2.new(84, 364),
        Warning = Vector2.new(84, 444),
        Error = Vector2.new(84, 524)
    }
    
    local notificationFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local titleLabel = Instance.new("TextLabel")
    local textLabel = Instance.new("TextLabel")
    local iconImage = Instance.new("ImageLabel")
    local closeButton = Instance.new("ImageButton")
    local progressBar = Instance.new("Frame")
    local progressCorner = Instance.new("UICorner")
    
    notificationFrame.Name = "Notification"
    notificationFrame.Parent = game.CoreGui[LibName]
    notificationFrame.BackgroundColor3 = Color3.fromRGB(36, 37, 43)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Position = UDim2.new(1, -320, 1, -100 - (#Notifications * 120))
    notificationFrame.Size = UDim2.new(0, 300, 0, 100)
    notificationFrame.ZIndex = 100
    
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = notificationFrame
    
    iconImage.Name = "Icon"
    iconImage.Parent = notificationFrame
    iconImage.BackgroundTransparency = 1
    iconImage.Position = UDim2.new(0, 15, 0, 15)
    iconImage.Size = UDim2.new(0, 30, 0, 30)
    iconImage.Image = icon[notifType]
    iconImage.ImageColor3 = colors[notifType]
    iconImage.ImageRectOffset = iconRect[notifType]
    iconImage.ImageRectSize = Vector2.new(36, 36)
    
    titleLabel.Name = "Title"
    titleLabel.Parent = notificationFrame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 60, 0, 10)
    titleLabel.Size = UDim2.new(0, 220, 0, 25)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    textLabel.Name = "Text"
    textLabel.Parent = notificationFrame
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 60, 0, 35)
    textLabel.Size = UDim2.new(0, 220, 0, 45)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    closeButton.Name = "CloseButton"
    closeButton.Parent = notificationFrame
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -30, 0, 10)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.MouseButton1Click:Connect(function()
        Utility:TweenObject(notificationFrame, {Position = UDim2.new(1, 320, 1, notificationFrame.Position.Y.Offset)}, 0.3)
        wait(0.3)
        notificationFrame:Destroy()
        table.remove(Notifications, table.find(Notifications, notificationFrame))
        Kavo:UpdateNotificationPositions()
    end)
    
    progressBar.Name = "ProgressBar"
    progressBar.Parent = notificationFrame
    progressBar.BackgroundColor3 = colors[notifType]
    progressBar.BorderSizePixel = 0
    progressBar.Position = UDim2.new(0, 0, 1, -5)
    progressBar.Size = UDim2.new(1, 0, 0, 5)
    
    progressCorner.CornerRadius = UDim.new(0, 0)
    progressCorner.Parent = progressBar
    
    table.insert(Notifications, notificationFrame)
    
    notificationFrame.Position = UDim2.new(1, 320, 1, -100 - ((#Notifications - 1) * 120))
    Utility:TweenObject(notificationFrame, {Position = UDim2.new(1, -320, 1, -100 - ((#Notifications - 1) * 120))}, 0.3)
    
    spawn(function()
        local startTime = tick()
        while tick() - startTime < duration do
            local elapsed = tick() - startTime
            local progress = 1 - (elapsed / duration)
            Utility:TweenObject(progressBar, {Size = UDim2.new(progress, 0, 0, 5)}, 0.1)
            wait(0.1)
        end
        if notificationFrame.Parent then
            Utility:TweenObject(notificationFrame, {Position = UDim2.new(1, 320, 1, notificationFrame.Position.Y.Offset)}, 0.3)
            wait(0.3)
            notificationFrame:Destroy()
            table.remove(Notifications, table.find(Notifications, notificationFrame))
            Kavo:UpdateNotificationPositions()
        end
    end)
    
    return notificationFrame
end

function Kavo:UpdateNotificationPositions()
    for i, notif in ipairs(Notifications) do
        Utility:TweenObject(notif, {Position = UDim2.new(1, -320, 1, -100 - ((i - 1) * 120))}, 0.3)
    end
end

function Kavo.CreateLib(kavName, themeList)
    if not themeList then
        themeList = themes
    end
    if themeList == "DarkTheme" then
        themeList = themeStyles.DarkTheme
    elseif themeList == "LightTheme" then
        themeList = themeStyles.LightTheme
    elseif themeList == "BloodTheme" then
        themeList = themeStyles.BloodTheme
    elseif themeList == "GrapeTheme" then
        themeList = themeStyles.GrapeTheme
    elseif themeList == "Ocean" then
        themeList = themeStyles.Ocean
    elseif themeList == "Midnight" then
        themeList = themeStyles.Midnight
    elseif themeList == "Sentinel" then
        themeList = themeStyles.Sentinel
    elseif themeList == "Synapse" then
        themeList = themeStyles.Synapse
    elseif themeList == "Serpent" then
        themeList = themeStyles.Serpent
    else
        if themeList.SchemeColor == nil then
            themeList.SchemeColor = Color3.fromRGB(74, 99, 135)
        elseif themeList.Background == nil then
            themeList.Background = Color3.fromRGB(36, 37, 43)
        elseif themeList.Header == nil then
            themeList.Header = Color3.fromRGB(28, 29, 34)
        elseif themeList.TextColor == nil then
            themeList.TextColor = Color3.fromRGB(255,255,255)
        elseif themeList.ElementColor == nil then
            themeList.ElementColor = Color3.fromRGB(32, 32, 38)
        end
    end

    themeList = themeList or {}
    local selectedTab 
    kavName = kavName or "Library"
    table.insert(Kavo, kavName)
    for i,v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then
            v:Destroy()
        end
    end
    
    local screenSize = workspace.CurrentCamera.ViewportSize
    local uiWidth = screenSize.X * 0.75
    local uiHeight = screenSize.Y * 0.75
    
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local headerCover = Instance.new("UICorner")
    local coverup = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local close = Instance.new("ImageButton")
    local minimize = Instance.new("ImageButton")
    local MainSide = Instance.new("Frame")
    local sideCorner = Instance.new("UICorner")
    local coverup_2 = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    local infoContainer = Instance.new("Frame")
    local blurFrame = Instance.new("Frame")

    Kavo:DraggingEnabled(MainHeader, Main)

    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.0222222228, 0, -0.0371747203, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.125, 0, 0.125, 0)
    Main.Size = UDim2.new(0, uiWidth, 0, uiHeight)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)

    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main

    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    Objects[MainHeader] = "BackgroundColor3"
    MainHeader.Size = UDim2.new(0, uiWidth, 0, 40)
    headerCover.CornerRadius = UDim.new(0, 12)
    headerCover.Name = "headerCover"
    headerCover.Parent = MainHeader

    coverup.Name = "coverup"
    coverup.Parent = MainHeader
    coverup.BackgroundColor3 = themeList.Header
    Objects[coverup] = "BackgroundColor3"
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.85, 0)
    coverup.Size = UDim2.new(0, uiWidth, 0, 10)

    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0.025, 0, 0.25, 0)
    title.Size = UDim2.new(0, 300, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.RichText = true
    title.Text = kavName
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextSize = 18.000
    title.TextXAlignment = Enum.TextXAlignment.Left

    minimize.Name = "minimize"
    minimize.Parent = MainHeader
    minimize.BackgroundTransparency = 1.000
    minimize.Position = UDim2.new(0.92, 0, 0.2, 0)
    minimize.Size = UDim2.new(0, 25, 0, 25)
    minimize.ZIndex = 2
    minimize.Image = "rbxassetid://3926305904"
    minimize.ImageRectOffset = Vector2.new(324, 524)
    minimize.ImageRectSize = Vector2.new(36, 36)
    minimize.ImageColor3 = Color3.fromRGB(200, 200, 200)
    
    local minimized = false
    local originalSize = Main.Size
    local originalPosition = Main.Position
    
    minimize.MouseButton1Click:Connect(function()
        if not minimized then
            minimized = true
            Utility:TweenObject(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, uiWidth, 0, 40),
                Position = UDim2.new(0.5, 0, 0, 40)
            })
            Utility:TweenObject(minimize, {Rotation = 180}, 0.3)
        else
            minimized = false
            Utility:TweenObject(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = originalSize,
                Position = originalPosition
            })
            Utility:TweenObject(minimize, {Rotation = 0}, 0.3)
        end
    end)

    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundTransparency = 1.000
    close.Position = UDim2.new(0.96, 0, 0.2, 0)
    close.Size = UDim2.new(0, 25, 0, 25)
    close.ZIndex = 2
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.ImageColor3 = Color3.fromRGB(231, 76, 60)
    close.MouseButton1Click:Connect(function()
        Utility:TweenObject(close, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            ImageTransparency = 1
        }):Play()
        Utility:TweenObject(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)

    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = themeList.Header
    Objects[MainSide] = "Header"
    MainSide.Position = UDim2.new(0, 0, 0.1, 0)
    MainSide.Size = UDim2.new(0, 180, 0, uiHeight - 50)

    sideCorner.CornerRadius = UDim.new(0, 12)
    sideCorner.Name = "sideCorner"
    sideCorner.Parent = MainSide

    coverup_2.Name = "coverup"
    coverup_2.Parent = MainSide
    coverup_2.BackgroundColor3 = themeList.Header
    Objects[coverup_2] = "Header"
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.944, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 10, 0, uiHeight - 50)

    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabFrames.BackgroundTransparency = 1.000
    tabFrames.Position = UDim2.new(0.05, 0, 0.02, 0)
    tabFrames.Size = UDim2.new(0, 160, 0, uiHeight - 70)

    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 8)

    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pages.BackgroundTransparency = 1.000
    pages.BorderSizePixel = 0
    pages.Position = UDim2.new(0.35, 0, 0.12, 0)
    pages.Size = UDim2.new(0, uiWidth - 220, 0, uiHeight - 60)

    Pages.Name = "Pages"
    Pages.Parent = pages

    infoContainer.Name = "infoContainer"
    infoContainer.Parent = Main
    infoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    infoContainer.BackgroundTransparency = 1.000
    infoContainer.BorderColor3 = Color3.fromRGB(27, 42, 53)
    infoContainer.ClipsDescendants = true
    infoContainer.Position = UDim2.new(0.35, 0, 0.9, 0)
    infoContainer.Size = UDim2.new(0, uiWidth - 220, 0, 40)
    
    coroutine.wrap(function()
        while wait() do
            Main.BackgroundColor3 = themeList.Background
            MainHeader.BackgroundColor3 = themeList.Header
            MainSide.BackgroundColor3 = themeList.Header
            coverup_2.BackgroundColor3 = themeList.Header
            coverup.BackgroundColor3 = themeList.Header
        end
    end)()

    function Kavo:ChangeColor(prope,color)
        if prope == "Background" then
            themeList.Background = color
        elseif prope == "SchemeColor" then
            themeList.SchemeColor = color
        elseif prope == "Header" then
            themeList.Header = color
        elseif prope == "TextColor" then
            themeList.TextColor = color
        elseif prope == "ElementColor" then
            themeList.ElementColor = color
        end
    end
    
    function Kavo:Notification(title, text, duration, notifType)
        duration = duration or 5
        notifType = notifType or "Info"
        
        local colors = {
            Info = themeList.SchemeColor,
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60)
        }
        
        local notificationFrame = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local titleLabel = Instance.new("TextLabel")
        local textLabel = Instance.new("TextLabel")
        local iconImage = Instance.new("ImageLabel")
        local closeButton = Instance.new("ImageButton")
        local progressBar = Instance.new("Frame")
        local progressCorner = Instance.new("UICorner")
        
        notificationFrame.Name = "Notification"
        notificationFrame.Parent = ScreenGui
        notificationFrame.BackgroundColor3 = themeList.Background
        notificationFrame.BorderSizePixel = 0
        notificationFrame.Position = UDim2.new(1, 320, 1, -120 - (#Notifications * 140))
        notificationFrame.Size = UDim2.new(0, 300, 0, 120)
        notificationFrame.ZIndex = 100
        
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = notificationFrame
        
        iconImage.Name = "Icon"
        iconImage.Parent = notificationFrame
        iconImage.BackgroundTransparency = 1
        iconImage.Position = UDim2.new(0, 15, 0, 15)
        iconImage.Size = UDim2.new(0, 30, 0, 30)
        iconImage.Image = "rbxassetid://3926305904"
        iconImage.ImageColor3 = colors[notifType]
        
        if notifType == "Info" then
            iconImage.ImageRectOffset = Vector2.new(84, 204)
        elseif notifType == "Success" then
            iconImage.ImageRectOffset = Vector2.new(84, 364)
        elseif notifType == "Warning" then
            iconImage.ImageRectOffset = Vector2.new(84, 444)
        elseif notifType == "Error" then
            iconImage.ImageRectOffset = Vector2.new(84, 524)
        end
        
        iconImage.ImageRectSize = Vector2.new(36, 36)
        
        titleLabel.Name = "Title"
        titleLabel.Parent = notificationFrame
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 60, 0, 15)
        titleLabel.Size = UDim2.new(0, 220, 0, 25)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = themeList.TextColor
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        textLabel.Name = "Text"
        textLabel.Parent = notificationFrame
        textLabel.BackgroundTransparency = 1
        textLabel.Position = UDim2.new(0, 60, 0, 45)
        textLabel.Size = UDim2.new(0, 220, 0, 60)
        textLabel.Font = Enum.Font.Gotham
        textLabel.Text = text
        textLabel.TextColor3 = themeList.TextColor
        textLabel.TextSize = 14
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        
        closeButton.Name = "CloseButton"
        closeButton.Parent = notificationFrame
        closeButton.BackgroundTransparency = 1
        closeButton.Position = UDim2.new(1, -30, 0, 15)
        closeButton.Size = UDim2.new(0, 20, 0, 20)
        closeButton.Image = "rbxassetid://3926305904"
        closeButton.ImageColor3 = themeList.TextColor
        closeButton.ImageRectOffset = Vector2.new(284, 4)
        closeButton.ImageRectSize = Vector2.new(24, 24)
        closeButton.MouseButton1Click:Connect(function()
            Utility:TweenObject(notificationFrame, {Position = UDim2.new(1, 320, 1, notificationFrame.Position.Y.Offset)}, 0.3)
            wait(0.3)
            notificationFrame:Destroy()
        end)
        
        progressBar.Name = "ProgressBar"
        progressBar.Parent = notificationFrame
        progressBar.BackgroundColor3 = colors[notifType]
        progressBar.BorderSizePixel = 0
        progressBar.Position = UDim2.new(0, 0, 1, -5)
        progressBar.Size = UDim2.new(1, 0, 0, 5)
        
        progressCorner.CornerRadius = UDim.new(0, 0)
        progressCorner.Parent = progressBar
        
        table.insert(Notifications, notificationFrame)
        
        notificationFrame.Position = UDim2.new(1, 320, 1, -120 - ((#Notifications - 1) * 140))
        Utility:TweenObject(notificationFrame, {Position = UDim2.new(1, -320, 1, -120 - ((#Notifications - 1) * 140))}, 0.3)
        
        spawn(function()
            local startTime = tick()
            while tick() - startTime < duration do
                local elapsed = tick() - startTime
                local progress = 1 - (elapsed / duration)
                Utility:TweenObject(progressBar, {Size = UDim2.new(progress, 0, 0, 5)}, 0.1)
                wait(0.1)
            end
            if notificationFrame.Parent then
                Utility:TweenObject(notificationFrame, {Position = UDim2.new(1, 320, 1, notificationFrame.Position.Y.Offset)}, 0.3)
                wait(0.3)
                notificationFrame:Destroy()
            end
        end)
        
        return notificationFrame
    end

    local Tabs = {}
    local first = true

    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")
        local tabIcon = Instance.new("ImageLabel")

        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            game.TweenService:Create(page, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                CanvasSize = UDim2.new(0,0,0,cS.Y)
            }):Play()
        end

        page.Name = "Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundColor3 = themeList.Background
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 0, 0, 0)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 5
        page.Visible = false
        page.ScrollBarImageColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 16, themeList.SchemeColor.g * 255 - 15, themeList.SchemeColor.b * 255 - 28)

        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 15)

        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255, 0)
        tabButton.BackgroundTransparency = 0.9
        tabButton.Size = UDim2.new(0, 160, 0, 45)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = ""
        tabButton.TextColor3 = themeList.TextColor
        tabButton.TextSize = 0.000

        tabIcon.Name = "TabIcon"
        tabIcon.Parent = tabButton
        tabIcon.BackgroundTransparency = 1
        tabIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
        tabIcon.Size = UDim2.new(0, 25, 0, 25)
        tabIcon.Image = "rbxassetid://3926305904"
        tabIcon.ImageColor3 = themeList.TextColor
        tabIcon.ImageRectOffset = Vector2.new(164, 364)
        tabIcon.ImageRectSize = Vector2.new(36, 36)

        local tabText = Instance.new("TextLabel")
        tabText.Name = "TabText"
        tabText.Parent = tabButton
        tabText.BackgroundTransparency = 1
        tabText.Position = UDim2.new(0.4, 0, 0.2, 0)
        tabText.Size = UDim2.new(0, 100, 0, 25)
        tabText.Font = Enum.Font.Gotham
        tabText.Text = tabName
        tabText.TextColor3 = themeList.TextColor
        tabText.TextSize = 16
        tabText.TextXAlignment = Enum.TextXAlignment.Left

        if first then
            first = false
            page.Visible = true
            tabButton.BackgroundTransparency = 0.7
            tabButton.BackgroundColor3 = themeList.SchemeColor
            tabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            UpdateSize()
        else
            page.Visible = false
            tabButton.BackgroundTransparency = 0.9
        end

        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = tabButton
        table.insert(Tabs, tabName)

        UpdateSize()
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)

        tabButton.MouseButton1Click:Connect(function()
            UpdateSize()
            for i,v in next, Pages:GetChildren() do
                v.Visible = false
            end
            page.Visible = true
            for i,v in next, tabFrames:GetChildren() do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                    if v:FindFirstChild("TabText") then
                        Utility:TweenObject(v.TabText, {TextColor3 = themeList.TextColor}, 0.2)
                    end
                    if v:FindFirstChild("TabIcon") then
                        Utility:TweenObject(v.TabIcon, {ImageColor3 = themeList.TextColor}, 0.2)
                    end
                end
            end
            Utility:TweenObject(tabButton, {BackgroundTransparency = 0.7, BackgroundColor3 = themeList.SchemeColor}, 0.2)
            Utility:TweenObject(tabText, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            Utility:TweenObject(tabIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end)
        
        local Sections = {}
        local focusing = false
        local viewDe = false

        coroutine.wrap(function()
            while wait() do
                page.BackgroundColor3 = themeList.Background
                page.ScrollBarImageColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 16, themeList.SchemeColor.g * 255 - 15, themeList.SchemeColor.b * 255 - 28)
                tabButton.BackgroundColor3 = themeList.SchemeColor
                tabText.TextColor3 = themeList.TextColor
                tabIcon.ImageColor3 = themeList.TextColor
            end
        end)()
    
        function Sections:NewSection(secName, hidden)
            secName = secName or "Section"
            local sectionFunctions = {}
            local modules = {}
            hidden = hidden or false
            
            local sectionFrame = Instance.new("Frame")
            local sectionlistoknvm = Instance.new("UIListLayout")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            
            if hidden then
                sectionHead.Visible = false
            else
                sectionHead.Visible = true
            end

            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255, 0)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.BorderSizePixel = 0
            
            sectionlistoknvm.Name = "sectionlistoknvm"
            sectionlistoknvm.Parent = sectionFrame
            sectionlistoknvm.SortOrder = Enum.SortOrder.LayoutOrder
            sectionlistoknvm.Padding = UDim.new(0, 15)

            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = themeList.SchemeColor
            Objects[sectionHead] = "BackgroundColor3"
            sectionHead.Size = UDim2.new(0, uiWidth - 250, 0, 40)

            sHeadCorner.CornerRadius = UDim.new(0, 8)
            sHeadCorner.Name = "sHeadCorner"
            sHeadCorner.Parent = sectionHead

            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionName.BackgroundTransparency = 1.000
            sectionName.BorderColor3 = Color3.fromRGB(27, 42, 53)
            sectionName.Position = UDim2.new(0.03, 0, 0, 0)
            sectionName.Size = UDim2.new(0.97, 0, 1, 0)
            sectionName.Font = Enum.Font.GothamBold
            sectionName.Text = secName
            sectionName.RichText = true
            sectionName.TextColor3 = themeList.TextColor
            Objects[sectionName] = "TextColor3"
            sectionName.TextSize = 16.000
            sectionName.TextXAlignment = Enum.TextXAlignment.Left
            
            if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
                Utility:TweenObject(sectionName, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
            end 
            if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
                Utility:TweenObject(sectionName, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
            end 
               
            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionInners.BackgroundTransparency = 1.000
            sectionInners.Position = UDim2.new(0, 0, 0, 50)

            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 10)

            coroutine.wrap(function()
                while wait() do
                    sectionFrame.BackgroundColor3 = themeList.Background
                    sectionHead.BackgroundColor3 = themeList.SchemeColor
                    sectionName.TextColor3 = themeList.TextColor
                end
            end)()

            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                local frameSc = sectionlistoknvm.AbsoluteContentSize
                sectionFrame.Size = UDim2.new(0, uiWidth - 250, 0, frameSc.Y + 50)
            end
            
            updateSectionFrame()
            UpdateSize()
            
            local Elements = {}
            
            function Elements:NewButton(bname, tipINf, callback)
                local ButtonFunction = {}
                tipINf = tipINf or "Click this button!"
                bname = bname or "Click Me!"
                callback = callback or function() end

                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local btnInfo = Instance.new("TextLabel")
                local viewInfo = Instance.new("ImageButton")
                local touch = Instance.new("ImageLabel")
                local Sample = Instance.new("ImageLabel")

                table.insert(modules, bname)

                buttonElement.Name = bname
                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = themeList.ElementColor
                buttonElement.ClipsDescendants = true
                buttonElement.Size = UDim2.new(0, uiWidth - 250, 0, 45)
                buttonElement.AutoButtonColor = false
                buttonElement.Font = Enum.Font.SourceSans
                buttonElement.Text = ""
                buttonElement.TextColor3 = Color3.fromRGB(0, 0, 0)
                buttonElement.TextSize = 14.000
                Objects[buttonElement] = "BackgroundColor3"

                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = buttonElement

                viewInfo.Name = "viewInfo"
                viewInfo.Parent = buttonElement
                viewInfo.BackgroundTransparency = 1.000
                viewInfo.LayoutOrder = 9
                viewInfo.Position = UDim2.new(0.95, 0, 0.2, 0)
                viewInfo.Size = UDim2.new(0, 25, 0, 25)
                viewInfo.ZIndex = 2
                viewInfo.Image = "rbxassetid://3926305904"
                viewInfo.ImageColor3 = themeList.SchemeColor
                Objects[viewInfo] = "ImageColor3"
                viewInfo.ImageRectOffset = Vector2.new(764, 764)
                viewInfo.ImageRectSize = Vector2.new(36, 36)

                Sample.Name = "Sample"
                Sample.Parent = buttonElement
                Sample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Sample.BackgroundTransparency = 1.000
                Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
                Sample.ImageColor3 = themeList.SchemeColor
                Objects[Sample] = "ImageColor3"
                Sample.ImageTransparency = 0.600

                local moreInfo = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")

                moreInfo.Name = "TipMore"
                moreInfo.Parent = infoContainer
                moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
                moreInfo.Position = UDim2.new(0, 0, 2, 0)
                moreInfo.Size = UDim2.new(0, uiWidth - 250, 0, 40)
                moreInfo.ZIndex = 9
                moreInfo.Font = Enum.Font.GothamSemibold
                moreInfo.Text = "  "..tipINf
                moreInfo.RichText = true
                moreInfo.TextColor3 = themeList.TextColor
                Objects[moreInfo] = "TextColor3"
                moreInfo.TextSize = 14.000
                moreInfo.TextXAlignment = Enum.TextXAlignment.Left
                Objects[moreInfo] = "BackgroundColor3"

                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = moreInfo

                touch.Name = "touch"
                touch.Parent = buttonElement
                touch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                touch.BackgroundTransparency = 1.000
                touch.BorderColor3 = Color3.fromRGB(27, 42, 53)
                touch.Position = UDim2.new(0.03, 0, 0.2, 0)
                touch.Size = UDim2.new(0, 25, 0, 25)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageColor3 = themeList.SchemeColor
                Objects[touch] = "SchemeColor"
                touch.ImageRectOffset = Vector2.new(84, 204)
                touch.ImageRectSize = Vector2.new(36, 36)
                touch.ImageTransparency = 0

                btnInfo.Name = "btnInfo"
                btnInfo.Parent = buttonElement
                btnInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                btnInfo.BackgroundTransparency = 1.000
                btnInfo.Position = UDim2.new(0.12, 0, 0.2, 0)
                btnInfo.Size = UDim2.new(0, uiWidth - 350, 0, 25)
                btnInfo.Font = Enum.Font.GothamSemibold
                btnInfo.Text = bname
                btnInfo.RichText = true
                btnInfo.TextColor3 = themeList.TextColor
                Objects[btnInfo] = "TextColor3"
                btnInfo.TextSize = 16.000
                btnInfo.TextXAlignment = Enum.TextXAlignment.Left

                if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
                    Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
                end 
                if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
                    Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
                end 

                updateSectionFrame()
                UpdateSize()

                local ms = game.Players.LocalPlayer:GetMouse()
                local btn = buttonElement
                local sample = Sample

                btn.MouseButton1Click:Connect(function()
                    if not focusing then
                        callback()
                        local c = sample:Clone()
                        c.Parent = btn
                        local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
                        c.Position = UDim2.new(0, x, 0, y)
                        local len, size = 0.35, nil
                        if btn.AbsoluteSize.X >= btn.AbsoluteSize.Y then
                            size = (btn.AbsoluteSize.X * 1.5)
                        else
                            size = (btn.AbsoluteSize.Y * 1.5)
                        end
                        c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
                        for i = 1, 10 do
                            c.ImageTransparency = c.ImageTransparency + 0.05
                            wait(len / 12)
                        end
                        c:Destroy()
                    else
                        for i,v in next, infoContainer:GetChildren() do
                            Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                            focusing = false
                        end
                        Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                    end
                end)
                
                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 8, themeList.ElementColor.g * 255 + 9, themeList.ElementColor.b * 255 + 10)
                        }):Play()
                        hovering = true
                    end
                end)
                
                btn.MouseLeave:Connect(function()
                    if not focusing then 
                        game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            BackgroundColor3 = themeList.ElementColor
                        }):Play()
                        hovering = false
                    end
                end)
                
                viewInfo.MouseButton1Click:Connect(function()
                    if not viewDe then
                        viewDe = true
                        focusing = true
                        for i,v in next, infoContainer:GetChildren() do
                            if v ~= moreInfo then
                                Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                            end
                        end
                        Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
                        Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.2)
                        wait(1.5)
                        focusing = false
                        Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
                        Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                        wait(0)
                        viewDe = false
                    end
                end)
                
                coroutine.wrap(function()
                    while wait() do
                        if not hovering then
                            buttonElement.BackgroundColor3 = themeList.ElementColor
                        end
                        viewInfo.ImageColor3 = themeList.SchemeColor
                        Sample.ImageColor3 = themeList.SchemeColor
                        moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
                        moreInfo.TextColor3 = themeList.TextColor
                        touch.ImageColor3 = themeList.SchemeColor
                        btnInfo.TextColor3 = themeList.TextColor
                    end
                end)()
                
                function ButtonFunction:UpdateButton(newTitle)
                    btnInfo.Text = newTitle
                end
                
                return ButtonFunction
            end

            function Elements:NewToggle(tname, nTip, callback)
                local TogFunction = {}
                tname = tname or "Toggle"
                nTip = nTip or "Toggle tip"
                callback = callback or function() end
                local toggled = false
                table.insert(SettingsT, tname)

                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleDisabled = Instance.new("ImageLabel")
                local toggleEnabled = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")
                local viewInfo = Instance.new("ImageButton")
                local Sample = Instance.new("ImageLabel")

                toggleElement.Name = "toggleElement"
                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = themeList.ElementColor
                toggleElement.ClipsDescendants = true
                toggleElement.Size = UDim2.new(0, uiWidth - 250, 0, 45)
                toggleElement.AutoButtonColor = false
                toggleElement.Font = Enum.Font.SourceSans
                toggleElement.Text = ""
                toggleElement.TextColor3 = Color3.fromRGB(0, 0, 0)
                toggleElement.TextSize = 14.000

                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = toggleElement

                toggleDisabled.Name = "toggleDisabled"
                toggleDisabled.Parent = toggleElement
                toggleDisabled.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleDisabled.BackgroundTransparency = 1.000
                toggleDisabled.Position = UDim2.new(0.03, 0, 0.2, 0)
                toggleDisabled.Size = UDim2.new(0, 25, 0, 25)
                toggleDisabled.Image = "rbxassetid://3926309567"
                toggleDisabled.ImageColor3 = themeList.SchemeColor
                toggleDisabled.ImageRectOffset = Vector2.new(628, 420)
                toggleDisabled.ImageRectSize = Vector2.new(48, 48)

                toggleEnabled.Name = "toggleEnabled"
                toggleEnabled.Parent = toggleElement
                toggleEnabled.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleEnabled.BackgroundTransparency = 1.000
                toggleEnabled.Position = UDim2.new(0.03, 0, 0.2, 0)
                toggleEnabled.Size = UDim2.new(0, 25, 0, 25)
                toggleEnabled.Image = "rbxassetid://3926309567"
                toggleEnabled.ImageColor3 = themeList.SchemeColor
                toggleEnabled.ImageRectOffset = Vector2.new(784, 420)
                toggleEnabled.ImageRectSize = Vector2.new(48, 48)
                toggleEnabled.ImageTransparency = 1.000

                togName.Name = "togName"
                togName.Parent = toggleElement
                togName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                togName.BackgroundTransparency = 1.000
                togName.Position = UDim2.new(0.12, 0, 0.2, 0)
                togName.Size = UDim2.new(0, uiWidth - 350, 0, 25)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = tname
                togName.RichText = true
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 16.000
                togName.TextXAlignment = Enum.TextXAlignment.Left

                viewInfo.Name = "viewInfo"
                viewInfo.Parent = toggleElement
                viewInfo.BackgroundTransparency = 1.000
                viewInfo.LayoutOrder = 9
                viewInfo.Position = UDim2.new(0.95, 0, 0.2, 0)
                viewInfo.Size = UDim2.new(0, 25, 0, 25)
                viewInfo.ZIndex = 2
                viewInfo.Image = "rbxassetid://3926305904"
                viewInfo.ImageColor3 = themeList.SchemeColor
                viewInfo.ImageRectOffset = Vector2.new(764, 764)
                viewInfo.ImageRectSize = Vector2.new(36, 36)

                Sample.Name = "Sample"
                Sample.Parent = toggleElement
                Sample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Sample.BackgroundTransparency = 1.000
                Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
                Sample.ImageColor3 = themeList.SchemeColor
                Sample.ImageTransparency = 0.600

                local moreInfo = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")

                moreInfo.Name = "TipMore"
                moreInfo.Parent = infoContainer
                moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
                moreInfo.Position = UDim2.new(0, 0, 2, 0)
                moreInfo.Size = UDim2.new(0, uiWidth - 250, 0, 40)
                moreInfo.ZIndex = 9
                moreInfo.Font = Enum.Font.GothamSemibold
                moreInfo.RichText = true
                moreInfo.Text = "  "..nTip
                moreInfo.TextColor3 = themeList.TextColor
                moreInfo.TextSize = 14.000
                moreInfo.TextXAlignment = Enum.TextXAlignment.Left

                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = moreInfo

                local ms = game.Players.LocalPlayer:GetMouse()

                if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
                    Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
                end 
                if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
                    Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
                end 

                updateSectionFrame()
                UpdateSize()

                local btn = toggleElement
                local sample = Sample
                local img = toggleEnabled
                local infBtn = viewInfo

                btn.MouseButton1Click:Connect(function()
                    if not focusing then
                        if toggled == false then
                            game.TweenService:Create(img, TweenInfo.new(0.11, Enum.EasingStyle.Linear,Enum.EasingDirection.In), {
                                ImageTransparency = 0
                            }):Play()
                            local c = sample:Clone()
                            c.Parent = btn
                            local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
                            c.Position = UDim2.new(0, x, 0, y)
                            local len, size = 0.35, nil
                            if btn.AbsoluteSize.X >= btn.AbsoluteSize.Y then
                                size = (btn.AbsoluteSize.X * 1.5)
                            else
                                size = (btn.AbsoluteSize.Y * 1.5)
                            end
                            c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
                            for i = 1, 10 do
                                c.ImageTransparency = c.ImageTransparency + 0.05
                                wait(len / 12)
                            end
                            c:Destroy()
                        else
                            game.TweenService:Create(img, TweenInfo.new(0.11, Enum.EasingStyle.Linear,Enum.EasingDirection.In), {
                                ImageTransparency = 1
                            }):Play()
                            local c = sample:Clone()
                            c.Parent = btn
                            local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
                            c.Position = UDim2.new(0, x, 0, y)
                            local len, size = 0.35, nil
                            if btn.AbsoluteSize.X >= btn.AbsoluteSize.Y then
                                size = (btn.AbsoluteSize.X * 1.5)
                            else
                                size = (btn.AbsoluteSize.Y * 1.5)
                            end
                            c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
                            for i = 1, 10 do
                                c.ImageTransparency = c.ImageTransparency + 0.05
                                wait(len / 12)
                            end
                            c:Destroy()
                        end
                        toggled = not toggled
                        pcall(callback, toggled)
                    else
                        for i,v in next, infoContainer:GetChildren() do
                            Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                            focusing = false
                        end
                        Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                    end
                end)
                
                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 8, themeList.ElementColor.g * 255 + 9, themeList.ElementColor.b * 255 + 10)
                        }):Play()
                        hovering = true
                    end 
                end)
                
                btn.MouseLeave:Connect(function()
                    if not focusing then
                        game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            BackgroundColor3 = themeList.ElementColor
                        }):Play()
                        hovering = false
                    end
                end)

                coroutine.wrap(function()
                    while wait() do
                        if not hovering then
                            toggleElement.BackgroundColor3 = themeList.ElementColor
                        end
                        toggleDisabled.ImageColor3 = themeList.SchemeColor
                        toggleEnabled.ImageColor3 = themeList.SchemeColor
                        togName.TextColor3 = themeList.TextColor
                        viewInfo.ImageColor3 = themeList.SchemeColor
                        Sample.ImageColor3 = themeList.SchemeColor
                        moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
                        moreInfo.TextColor3 = themeList.TextColor
                    end
                end)()
                
                viewInfo.MouseButton1Click:Connect(function()
                    if not viewDe then
                        viewDe = true
                        focusing = true
                        for i,v in next, infoContainer:GetChildren() do
                            if v ~= moreInfo then
                                Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                            end
                        end
                        Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
                        Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.2)
                        wait(1.5)
                        focusing = false
                        Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
                        Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
                        wait(0)
                        viewDe = false
                    end
                end)
                
                function TogFunction:UpdateToggle(newText, isTogOn)
                    isTogOn = isTogOn or toggle
                    if newText ~= nil then 
                        togName.Text = newText
                    end
                    if isTogOn then
                        toggled = true
                        game.TweenService:Create(img, TweenInfo.new(0.11, Enum.EasingStyle.Linear,Enum.EasingDirection.In), {
                            ImageTransparency = 0
                        }):Play()
                        pcall(callback, toggled)
                    else
                        toggled = false
                        game.TweenService:Create(img, TweenInfo.new(0.11, Enum.EasingStyle.Linear,Enum.EasingDirection.In), {
                            ImageTransparency = 1
                        }):Play()
                        pcall(callback, toggled)
                    end
                end
                
                return TogFunction
            end

            return Elements
        end
        
        return Sections
    end
    
    return Tabs
end

return Kavo