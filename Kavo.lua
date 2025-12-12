-- Kavo UI Library - 修复美化版
-- 修复了UI错误，增加了拖放功能，优化了界面布局
-- 作者：江砚辰

local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local Utility = {}
local Objects = {}
local UIStates = {}
local minimizedStates = {}
local notifications = {}

-- 修复：添加缺失的拖放功能
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
            parent.Position = UDim2.new(
                framePos.X.Scale, 
                framePos.X.Offset + delta.X, 
                framePos.Y.Scale, 
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- 美观的主题系统
local themes = {
    SchemeColor = Color3.fromRGB(74, 99, 135),
    Background = Color3.fromRGB(36, 37, 43),
    Header = Color3.fromRGB(28, 29, 34),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(32, 32, 38),
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    AccentColor = Color3.fromRGB(0, 162, 255)
}

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(20, 20, 25),
        Header = Color3.fromRGB(15, 15, 20),
        TextColor = Color3.fromRGB(240, 240, 240),
        ElementColor = Color3.fromRGB(30, 30, 35),
        AccentColor = Color3.fromRGB(100, 100, 100)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(200, 200, 200),
        Background = Color3.fromRGB(245, 245, 245),
        Header = Color3.fromRGB(230, 230, 230),
        TextColor = Color3.fromRGB(30, 30, 30),
        ElementColor = Color3.fromRGB(220, 220, 220),
        AccentColor = Color3.fromRGB(100, 100, 255)
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(15, 10, 10),
        Header = Color3.fromRGB(10, 5, 5),
        TextColor = Color3.fromRGB(255, 220, 220),
        ElementColor = Color3.fromRGB(25, 15, 15),
        AccentColor = Color3.fromRGB(255, 50, 50)
    },
    GrapeTheme = {
        SchemeColor = Color3.fromRGB(166, 71, 214),
        Background = Color3.fromRGB(40, 30, 45),
        Header = Color3.fromRGB(30, 20, 35),
        TextColor = Color3.fromRGB(255, 240, 255),
        ElementColor = Color3.fromRGB(50, 35, 55),
        AccentColor = Color3.fromRGB(200, 100, 255)
    },
    Ocean = {
        SchemeColor = Color3.fromRGB(86, 76, 251),
        Background = Color3.fromRGB(20, 25, 45),
        Header = Color3.fromRGB(30, 35, 60),
        TextColor = Color3.fromRGB(220, 220, 240),
        ElementColor = Color3.fromRGB(30, 35, 60),
        AccentColor = Color3.fromRGB(100, 150, 255)
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(35, 50, 70),
        Header = Color3.fromRGB(45, 65, 90),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(40, 60, 80),
        AccentColor = Color3.fromRGB(0, 200, 180)
    },
    Sentinel = {
        SchemeColor = Color3.fromRGB(230, 35, 69),
        Background = Color3.fromRGB(25, 25, 25),
        Header = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(119, 209, 138),
        ElementColor = Color3.fromRGB(20, 20, 20),
        AccentColor = Color3.fromRGB(255, 60, 90)
    },
    Synapse = {
        SchemeColor = Color3.fromRGB(46, 48, 43),
        Background = Color3.fromRGB(10, 12, 10),
        Header = Color3.fromRGB(30, 32, 28),
        TextColor = Color3.fromRGB(152, 99, 53),
        ElementColor = Color3.fromRGB(20, 22, 18),
        AccentColor = Color3.fromRGB(180, 120, 60)
    },
    Serpent = {
        SchemeColor = Color3.fromRGB(0, 166, 58),
        Background = Color3.fromRGB(25, 35, 38),
        Header = Color3.fromRGB(18, 25, 27),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(18, 25, 27),
        AccentColor = Color3.fromRGB(0, 200, 80)
    }
}

-- 配置保存
local SettingsT = {}
local Name = "KavoConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
    end
    SettingsT = game:service'HttpService':JSONDecode(readfile(Name))
end)

local LibName = "KavoUI_"..tostring(math.random(1, 10000))..tostring(math.random(1, 10000))

-- 修复：切换UI显示/隐藏
function Kavo:ToggleUI()
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if screenGui then
        screenGui.Enabled = not screenGui.Enabled
    end
end

-- 优化：美观的最小化功能
function Kavo:ToggleMinimize()
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if not screenGui then return end
    
    local mainFrame = screenGui:FindFirstChild("Main")
    if not mainFrame then return end
    
    local minimized = minimizedStates[LibName] or false
    
    if minimized then
        -- 展开UI
        Utility:TweenObject(mainFrame, {
            Size = UDim2.new(0, 600, 0, 400)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- 显示内容区域
        for _, child in pairs(mainFrame:GetChildren()) do
            if child.Name ~= "MainHeader" then
                Utility:TweenObject(child, {
                    BackgroundTransparency = 0
                }, 0.3)
            end
        end
        
        minimizedStates[LibName] = false
    else
        -- 最小化UI
        Utility:TweenObject(mainFrame, {
            Size = UDim2.new(0, 600, 0, 40)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- 隐藏内容区域（标题栏除外）
        for _, child in pairs(mainFrame:GetChildren()) do
            if child.Name ~= "MainHeader" then
                Utility:TweenObject(child, {
                    BackgroundTransparency = 1
                }, 0.3)
            end
        end
        
        minimizedStates[LibName] = true
    end
end

function Kavo:SaveUIPosition(position)
    if not UIStates[LibName] then
        UIStates[LibName] = {}
    end
    UIStates[LibName].Position = position
end

function Kavo:LoadUIPosition()
    if UIStates[LibName] and UIStates[LibName].Position then
        return UIStates[LibName].Position
    end
    -- 屏幕中央75%大小
    return UDim2.new(0.125, 0, 0.125, 0)
end

function Kavo:ToggleVisibility()
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if screenGui then
        screenGui.Enabled = not screenGui.Enabled
    end
end

function Kavo:BindToggleKey(keyCode)
    input.InputBegan:Connect(function(input)
        if input.KeyCode == keyCode then
            Kavo:ToggleVisibility()
        end
    end)
end

-- 修复：通知系统
function Kavo:Notify(title, content, duration, image)
    title = title or "通知"
    content = content or ""
    duration = duration or 5
    image = image or 3926305904
    
    if not notifications[LibName] then
        notifications[LibName] = {}
    end
    
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if not screenGui then return end
    
    local notificationId = #notifications[LibName] + 1
    
    local notificationFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local gradient = Instance.new("UIGradient")
    local titleLabel = Instance.new("TextLabel")
    local contentLabel = Instance.new("TextLabel")
    local iconImage = Instance.new("ImageLabel")
    local closeButton = Instance.new("ImageButton")
    local progressBar = Instance.new("Frame")
    local progressBarCorner = Instance.new("UICorner")
    local progressBarFill = Instance.new("Frame")
    local progressBarFillCorner = Instance.new("UICorner")
    
    notificationFrame.Name = "Notification"..notificationId
    notificationFrame.Parent = screenGui
    notificationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Position = UDim2.new(1, 10, 1, -150)
    notificationFrame.Size = UDim2.new(0, 320, 0, 120)
    notificationFrame.ClipsDescendants = true
    notificationFrame.ZIndex = 100
    
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = notificationFrame
    
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
    }
    gradient.Rotation = 90
    gradient.Parent = notificationFrame
    
    iconImage.Name = "Icon"
    iconImage.Parent = notificationFrame
    iconImage.BackgroundTransparency = 1
    iconImage.Position = UDim2.new(0, 15, 0, 15)
    iconImage.Size = UDim2.new(0, 50, 0, 50)
    iconImage.Image = "rbxassetid://"..tostring(image)
    iconImage.ImageColor3 = themes.SchemeColor
    iconImage.ZIndex = 101
    
    titleLabel.Name = "Title"
    titleLabel.Parent = notificationFrame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 80, 0, 15)
    titleLabel.Size = UDim2.new(1, -95, 0, 25)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 101
    
    contentLabel.Name = "Content"
    contentLabel.Parent = notificationFrame
    contentLabel.BackgroundTransparency = 1
    contentLabel.Position = UDim2.new(0, 80, 0, 45)
    contentLabel.Size = UDim2.new(1, -95, 1, -80)
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 14
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.ZIndex = 101
    
    closeButton.Name = "Close"
    closeButton.Parent = notificationFrame
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -35, 0, 15)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = Color3.fromRGB(150, 150, 150)
    closeButton.ZIndex = 101
    
    progressBar.Name = "ProgressBar"
    progressBar.Parent = notificationFrame
    progressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    progressBar.BorderSizePixel = 0
    progressBar.Position = UDim2.new(0, 0, 1, -4)
    progressBar.Size = UDim2.new(1, 0, 0, 4)
    progressBar.ZIndex = 101
    
    progressBarCorner.CornerRadius = UDim.new(0, 2)
    progressBarCorner.Parent = progressBar
    
    progressBarFill.Name = "ProgressBarFill"
    progressBarFill.Parent = progressBar
    progressBarFill.BackgroundColor3 = themes.SchemeColor
    progressBarFill.BorderSizePixel = 0
    progressBarFill.Size = UDim2.new(1, 0, 1, 0)
    progressBarFill.ZIndex = 102
    
    progressBarFillCorner.CornerRadius = UDim.new(0, 2)
    progressBarFillCorner.Parent = progressBarFill
    
    -- 动画显示
    notificationFrame.Position = UDim2.new(1, 10, 1, -150)
    local showPosition = UDim2.new(1, -340, 1, -150)
    
    Utility:TweenObject(notificationFrame, {
        Position = showPosition
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    closeButton.MouseButton1Click:Connect(function()
        Utility:TweenObject(notificationFrame, {
            Position = UDim2.new(1, 10, 1, -150),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            notificationFrame:Destroy()
            if notifications[LibName] then
                notifications[LibName][notificationId] = nil
            end
        end)
    end)
    
    -- 自动关闭计时器
    local progressTime = duration
    local startTime = tick()
    
    if progressTime > 0 then
        local connection = run.RenderStepped:Connect(function()
            if not notificationFrame or not notificationFrame.Parent then
                connection:Disconnect()
                return
            end
            
            local elapsed = tick() - startTime
            local progress = 1 - (elapsed / progressTime)
            
            if progress <= 0 then
                progressBarFill.Size = UDim2.new(0, 0, 1, 0)
                connection:Disconnect()
                
                Utility:TweenObject(notificationFrame, {
                    Position = UDim2.new(1, 10, 1, -150),
                    BackgroundTransparency = 1
                }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                    notificationFrame:Destroy()
                    if notifications[LibName] then
                        notifications[LibName][notificationId] = nil
                    end
                end)
            else
                progressBarFill.Size = UDim2.new(progress, 0, 1, 0)
            end
        end)
    end
    
    -- 悬停效果
    local hovering = false
    notificationFrame.MouseEnter:Connect(function()
        hovering = true
        Utility:TweenObject(notificationFrame, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }, 0.2)
    end)
    
    notificationFrame.MouseLeave:Connect(function()
        hovering = false
        Utility:TweenObject(notificationFrame, {
            BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        }, 0.2)
    end)
    
    return {
        Hide = function()
            if notificationFrame and notificationFrame.Parent then
                Utility:TweenObject(notificationFrame, {
                    Position = UDim2.new(1, 10, 1, -150),
                    BackgroundTransparency = 1
                }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                    notificationFrame:Destroy()
                    if notifications[LibName] then
                        notifications[LibName][notificationId] = nil
                    end
                end)
            end
        end,
        
        Update = function(newTitle, newContent, newImage)
            if notificationFrame and notificationFrame.Parent then
                if newTitle then
                    titleLabel.Text = newTitle
                end
                if newContent then
                    contentLabel.Text = newContent
                end
                if newImage then
                    iconImage.Image = "rbxassetid://"..tostring(newImage)
                end
            end
        end,
        
        Extend = function(extraTime)
            if notificationFrame and notificationFrame.Parent then
                progressTime = progressTime + (extraTime or 0)
                startTime = tick()
            end
        end
    }
end

function Kavo:Notification(title, content, duration, image)
    return self:Notify(title, content, duration, image)
end

-- 创建主UI
function Kavo.CreateLib(kavName, themeList)
    kavName = kavName or "江砚辰 - 功能脚本"
    
    -- 处理主题
    if type(themeList) == "string" then
        themeList = themeStyles[themeList] or themes
    elseif not themeList then
        themeList = themes
    end
    
    -- 合并主题
    local theme = {}
    for k, v in pairs(themes) do
        theme[k] = themeList[k] or v
    end
    
    -- 清理旧UI
    for i, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:find("KavoUI_") then
            v:Destroy()
        end
    end
    
    -- 创建主UI容器
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- 主窗口框架
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = theme.Background
    Main.ClipsDescendants = true
    Main.Position = Kavo:LoadUIPosition()
    Main.Size = UDim2.new(0, 600, 0, 400)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    -- 标题栏
    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = theme.Header
    MainHeader.Size = UDim2.new(1, 0, 0, 40)
    
    local headerCover = Instance.new("UICorner")
    headerCover.CornerRadius = UDim.new(0, 10)
    headerCover.Parent = MainHeader
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = kavName
    title.TextColor3 = theme.TextColor
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 最小化按钮
    local minimize = Instance.new("ImageButton")
    minimize.Name = "minimize"
    minimize.Parent = MainHeader
    minimize.BackgroundTransparency = 1
    minimize.Position = UDim2.new(1, -80, 0, 10)
    minimize.Size = UDim2.new(0, 20, 0, 20)
    minimize.Image = "rbxassetid://3926305904"
    minimize.ImageRectOffset = Vector2.new(844, 164)
    minimize.ImageRectSize = Vector2.new(36, 36)
    minimize.ImageColor3 = theme.TextColor
    
    minimize.MouseButton1Click:Connect(function()
        Kavo:ToggleMinimize()
    end)
    
    -- 关闭按钮
    local close = Instance.new("ImageButton")
    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(1, -40, 0, 10)
    close.Size = UDim2.new(0, 20, 0, 20)
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.ImageColor3 = theme.TextColor
    
    close.MouseButton1Click:Connect(function()
        Utility:TweenObject(close, {
            ImageTransparency = 1
        }, 0.1)
        Utility:TweenObject(Main, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(
                0.5, 0,
                0.5, 0
            )
        }, 0.2)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- 侧边栏
    local MainSide = Instance.new("Frame")
    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = theme.Header
    MainSide.Position = UDim2.new(0, 0, 0, 40)
    MainSide.Size = UDim2.new(0, 180, 0, 360)
    
    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 10)
    sideCorner.Parent = MainSide
    
    -- 标签页容器
    local tabFrames = Instance.new("Frame")
    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundTransparency = 1
    tabFrames.Position = UDim2.new(0, 10, 0, 10)
    tabFrames.Size = UDim2.new(1, -20, 1, -20)
    
    local tabListing = Instance.new("UIListLayout")
    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 8)
    
    -- 内容区域
    local pages = Instance.new("Frame")
    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0, 190, 0, 50)
    pages.Size = UDim2.new(1, -200, 1, -60)
    
    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = pages
    
    -- 阴影效果
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = Main
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    
    -- 启用拖放功能
    Kavo:DraggingEnabled(MainHeader, Main)
    
    -- 保存位置
    local function savePosition()
        Kavo:SaveUIPosition(Main.Position)
    end
    
    Main.Changed:Connect(function(property)
        if property == "Position" then
            savePosition()
        end
    end)
    
    -- 主题更新循环
    coroutine.wrap(function()
        while wait(0.1) do
            Main.BackgroundColor3 = theme.Background
            MainHeader.BackgroundColor3 = theme.Header
            MainSide.BackgroundColor3 = theme.Header
            title.TextColor3 = theme.TextColor
            minimize.ImageColor3 = theme.TextColor
            close.ImageColor3 = theme.TextColor
            shadow.ImageTransparency = theme.ShadowTransparency or 0.6
        end
    end)()
    
    -- 主题颜色修改函数
    function Kavo:ChangeColor(property, color)
        if property == "Background" then
            theme.Background = color
        elseif property == "SchemeColor" then
            theme.SchemeColor = color
        elseif property == "Header" then
            theme.Header = color
        elseif property == "TextColor" then
            theme.TextColor = color
        elseif property == "ElementColor" then
            theme.ElementColor = color
        end
    end
    
    -- 标签页系统
    local Tabs = {}
    local first = true
    
    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")
        
        -- 创建页面
        page.Name = tabName.."Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 5
        page.ScrollBarImageColor3 = theme.SchemeColor
        page.Visible = false
        
        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 10)
        
        -- 创建标签按钮
        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = first and theme.SchemeColor or theme.Header
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = tabName
        tabButton.TextColor3 = first and theme.TextColor or Color3.fromRGB(180, 180, 180)
        tabButton.TextSize = 14
        tabButton.TextWrapped = true
        
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = tabButton
        
        if first then
            first = false
            page.Visible = true
        end
        
        -- 页面大小更新
        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            page.CanvasSize = UDim2.new(0, 0, 0, cS.Y + 20)
        end
        
        UpdateSize()
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)
        
        -- 标签按钮点击事件
        tabButton.MouseButton1Click:Connect(function()
            -- 隐藏所有页面
            for i, v in pairs(Pages:GetChildren()) do
                v.Visible = false
            end
            
            -- 重置所有标签按钮
            for i, v in pairs(tabFrames:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {
                        BackgroundColor3 = theme.Header,
                        TextColor3 = Color3.fromRGB(180, 180, 180)
                    }, 0.2)
                end
            end
            
            -- 激活当前标签
            Utility:TweenObject(tabButton, {
                BackgroundColor3 = theme.SchemeColor,
                TextColor3 = theme.TextColor
            }, 0.2)
            
            -- 显示当前页面
            page.Visible = true
            UpdateSize()
        end)
        
        -- 悬停效果
        tabButton.MouseEnter:Connect(function()
            if tabButton.BackgroundColor3 ~= theme.SchemeColor then
                Utility:TweenObject(tabButton, {
                    BackgroundColor3 = Color3.fromRGB(
                        theme.Header.r * 255 + 20,
                        theme.Header.g * 255 + 20,
                        theme.Header.b * 255 + 20
                    )
                }, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabButton.BackgroundColor3 ~= theme.SchemeColor then
                Utility:TweenObject(tabButton, {
                    BackgroundColor3 = theme.Header
                }, 0.2)
            end
        end)
        
        -- 主题更新
        coroutine.wrap(function()
            while wait(0.1) do
                tabButton.BackgroundColor3 = tabButton.BackgroundColor3 == theme.SchemeColor and theme.SchemeColor or theme.Header
                page.ScrollBarImageColor3 = theme.SchemeColor
            end
        end)()
        
        -- 分区系统
        local Sections = {}
        
        function Sections:NewSection(secName)
            secName = secName or "Section"
            
            local sectionFrame = Instance.new("Frame")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            
            -- 分区框架
            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            
            -- 分区标题
            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = theme.SchemeColor
            sectionHead.Size = UDim2.new(1, 0, 0, 35)
            
            sHeadCorner.CornerRadius = UDim.new(0, 8)
            sHeadCorner.Parent = sectionHead
            
            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundTransparency = 1
            sectionName.Position = UDim2.new(0, 15, 0, 0)
            sectionName.Size = UDim2.new(1, -30, 1, 0)
            sectionName.Font = Enum.Font.GothamSemibold
            sectionName.Text = secName
            sectionName.TextColor3 = theme.TextColor
            sectionName.TextSize = 14
            sectionName.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 控件容器
            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundTransparency = 1
            sectionInners.Position = UDim2.new(0, 0, 0, 45)
            sectionInners.Size = UDim2.new(1, 0, 0, 0)
            
            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 8)
            
            -- 更新大小
            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, innerSc.Y + 50)
                UpdateSize()
            end
            
            updateSectionFrame()
            sectionElListing:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionFrame)
            
            -- 主题更新
            coroutine.wrap(function()
                while wait(0.1) do
                    sectionHead.BackgroundColor3 = theme.SchemeColor
                    sectionName.TextColor3 = theme.TextColor
                end
            end)()
            
            -- 控件元素
            local Elements = {}
            
            -- 按钮控件
            function Elements:NewButton(bname, tipInf, callback)
                bname = bname or "按钮"
                tipInf = tipInf or "点击执行功能"
                callback = callback or function() end
                
                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local btnInfo = Instance.new("TextLabel")
                local touch = Instance.new("ImageLabel")
                
                buttonElement.Name = bname
                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = theme.ElementColor
                buttonElement.Size = UDim2.new(1, 0, 0, 40)
                buttonElement.AutoButtonColor = false
                buttonElement.Text = ""
                
                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = buttonElement
                
                touch.Name = "touch"
                touch.Parent = buttonElement
                touch.BackgroundTransparency = 1
                touch.Position = UDim2.new(0, 10, 0, 10)
                touch.Size = UDim2.new(0, 20, 0, 20)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageRectOffset = Vector2.new(84, 204)
                touch.ImageRectSize = Vector2.new(36, 36)
                touch.ImageColor3 = theme.SchemeColor
                
                btnInfo.Name = "btnInfo"
                btnInfo.Parent = buttonElement
                btnInfo.BackgroundTransparency = 1
                btnInfo.Position = UDim2.new(0, 40, 0, 0)
                btnInfo.Size = UDim2.new(1, -50, 1, 0)
                btnInfo.Font = Enum.Font.GothamSemibold
                btnInfo.Text = bname
                btnInfo.TextColor3 = theme.TextColor
                btnInfo.TextSize = 14
                btnInfo.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 点击效果
                buttonElement.MouseButton1Click:Connect(function()
                    callback()
                    
                    -- 点击动画
                    Utility:TweenObject(buttonElement, {
                        BackgroundColor3 = Color3.fromRGB(
                            theme.SchemeColor.r * 255,
                            theme.SchemeColor.g * 255,
                            theme.SchemeColor.b * 255
                        )
                    }, 0.1)
                    
                    wait(0.1)
                    
                    Utility:TweenObject(buttonElement, {
                        BackgroundColor3 = theme.ElementColor
                    }, 0.1)
                end)
                
                -- 悬停效果
                buttonElement.MouseEnter:Connect(function()
                    Utility:TweenObject(buttonElement, {
                        BackgroundColor3 = Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        )
                    }, 0.2)
                end)
                
                buttonElement.MouseLeave:Connect(function()
                    Utility:TweenObject(buttonElement, {
                        BackgroundColor3 = theme.ElementColor
                    }, 0.2)
                end)
                
                updateSectionFrame()
                
                -- 主题更新
                coroutine.wrap(function()
                    while wait(0.1) do
                        buttonElement.BackgroundColor3 = buttonElement.BackgroundColor3 == Color3.fromRGB(
                            theme.SchemeColor.r * 255,
                            theme.SchemeColor.g * 255,
                            theme.SchemeColor.b * 255
                        ) and Color3.fromRGB(
                            theme.SchemeColor.r * 255,
                            theme.SchemeColor.g * 255,
                            theme.SchemeColor.b * 255
                        ) or theme.ElementColor
                        
                        touch.ImageColor3 = theme.SchemeColor
                        btnInfo.TextColor3 = theme.TextColor
                    end
                end)()
                
                local ButtonFunction = {}
                
                function ButtonFunction:UpdateButton(newText)
                    btnInfo.Text = newText or bname
                end
                
                return ButtonFunction
            end
            
            -- 开关控件
            function Elements:NewToggle(tname, nTip, callback)
                tname = tname or "开关"
                nTip = nTip or "开启或关闭功能"
                callback = callback or function() end
                
                local toggled = false
                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleDisabled = Instance.new("ImageLabel")
                local toggleEnabled = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")
                
                toggleElement.Name = "toggleElement"
                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = theme.ElementColor
                toggleElement.Size = UDim2.new(1, 0, 0, 40)
                toggleElement.AutoButtonColor = false
                toggleElement.Text = ""
                
                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = toggleElement
                
                toggleDisabled.Name = "toggleDisabled"
                toggleDisabled.Parent = toggleElement
                toggleDisabled.BackgroundTransparency = 1
                toggleDisabled.Position = UDim2.new(0, 10, 0, 10)
                toggleDisabled.Size = UDim2.new(0, 20, 0, 20)
                toggleDisabled.Image = "rbxassetid://3926309567"
                toggleDisabled.ImageColor3 = theme.SchemeColor
                toggleDisabled.ImageRectOffset = Vector2.new(628, 420)
                toggleDisabled.ImageRectSize = Vector2.new(48, 48)
                
                toggleEnabled.Name = "toggleEnabled"
                toggleEnabled.Parent = toggleElement
                toggleEnabled.BackgroundTransparency = 1
                toggleEnabled.Position = UDim2.new(0, 10, 0, 10)
                toggleEnabled.Size = UDim2.new(0, 20, 0, 20)
                toggleEnabled.Image = "rbxassetid://3926309567"
                toggleEnabled.ImageColor3 = theme.SchemeColor
                toggleEnabled.ImageRectOffset = Vector2.new(784, 420)
                toggleEnabled.ImageRectSize = Vector2.new(48, 48)
                toggleEnabled.ImageTransparency = 1
                
                togName.Name = "togName"
                togName.Parent = toggleElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0, 40, 0, 0)
                togName.Size = UDim2.new(1, -50, 1, 0)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = tname
                togName.TextColor3 = theme.TextColor
                togName.TextSize = 14
                togName.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 切换开关
                toggleElement.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    
                    if toggled then
                        Utility:TweenObject(toggleEnabled, {
                            ImageTransparency = 0
                        }, 0.1)
                    else
                        Utility:TweenObject(toggleEnabled, {
                            ImageTransparency = 1
                        }, 0.1)
                    end
                    
                    callback(toggled)
                end)
                
                -- 悬停效果
                toggleElement.MouseEnter:Connect(function()
                    Utility:TweenObject(toggleElement, {
                        BackgroundColor3 = Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        )
                    }, 0.2)
                end)
                
                toggleElement.MouseLeave:Connect(function()
                    Utility:TweenObject(toggleElement, {
                        BackgroundColor3 = theme.ElementColor
                    }, 0.2)
                end)
                
                updateSectionFrame()
                
                -- 主题更新
                coroutine.wrap(function()
                    while wait(0.1) do
                        toggleElement.BackgroundColor3 = toggleElement.BackgroundColor3 == Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        ) and Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        ) or theme.ElementColor
                        
                        toggleDisabled.ImageColor3 = theme.SchemeColor
                        toggleEnabled.ImageColor3 = theme.SchemeColor
                        togName.TextColor3 = theme.TextColor
                    end
                end)()
                
                local TogFunction = {}
                
                function TogFunction:SetState(state)
                    toggled = state
                    if toggled then
                        toggleEnabled.ImageTransparency = 0
                    else
                        toggleEnabled.ImageTransparency = 1
                    end
                    callback(toggled)
                end
                
                function TogFunction:GetState()
                    return toggled
                end
                
                return TogFunction
            end
            
            -- 滑块控件
            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, callback)
                slidInf = slidInf or "滑块"
                slidTip = slidTip or "调整数值"
                maxvalue = maxvalue or 100
                minvalue = minvalue or 0
                callback = callback or function() end
                
                local sliderElement = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")
                local sliderBtn = Instance.new("TextButton")
                local sliderDrag = Instance.new("Frame")
                local val = Instance.new("TextLabel")
                local write = Instance.new("ImageLabel")
                
                sliderElement.Name = "sliderElement"
                sliderElement.Parent = sectionInners
                sliderElement.BackgroundColor3 = theme.ElementColor
                sliderElement.Size = UDim2.new(1, 0, 0, 60)
                
                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = sliderElement
                
                write.Name = "write"
                write.Parent = sliderElement
                write.BackgroundTransparency = 1
                write.Position = UDim2.new(0, 10, 0, 10)
                write.Size = UDim2.new(0, 20, 0, 20)
                write.Image = "rbxassetid://3926307971"
                write.ImageColor3 = theme.SchemeColor
                write.ImageRectOffset = Vector2.new(404, 164)
                write.ImageRectSize = Vector2.new(36, 36)
                
                togName.Name = "togName"
                togName.Parent = sliderElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0, 40, 0, 10)
                togName.Size = UDim2.new(0.5, -50, 0, 20)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = slidInf
                togName.TextColor3 = theme.TextColor
                togName.TextSize = 14
                togName.TextXAlignment = Enum.TextXAlignment.Left
                
                val.Name = "val"
                val.Parent = sliderElement
                val.BackgroundTransparency = 1
                val.Position = UDim2.new(0.5, 0, 0, 10)
                val.Size = UDim2.new(0.5, -10, 0, 20)
                val.Font = Enum.Font.GothamSemibold
                val.Text = tostring(minvalue)
                val.TextColor3 = theme.TextColor
                val.TextSize = 14
                val.TextXAlignment = Enum.TextXAlignment.Right
                
                sliderBtn.Name = "sliderBtn"
                sliderBtn.Parent = sliderElement
                sliderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                sliderBtn.Position = UDim2.new(0, 10, 0, 35)
                sliderBtn.Size = UDim2.new(1, -20, 0, 15)
                sliderBtn.AutoButtonColor = false
                sliderBtn.Text = ""
                
                sliderDrag.Name = "sliderDrag"
                sliderDrag.Parent = sliderBtn
                sliderDrag.BackgroundColor3 = theme.SchemeColor
                sliderDrag.Size = UDim2.new(0, 0, 1, 0)
                
                -- 滑块拖动
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local dragging = false
                
                local function updateSlider(x)
                    local relativeX = math.clamp(x - sliderBtn.AbsolutePosition.X, 0, sliderBtn.AbsoluteSize.X)
                    local percentage = relativeX / sliderBtn.AbsoluteSize.X
                    local value = math.floor(minvalue + (maxvalue - minvalue) * percentage)
                    
                    sliderDrag.Size = UDim2.new(percentage, 0, 1, 0)
                    val.Text = tostring(value)
                    callback(value)
                end
                
                sliderBtn.MouseButton1Down:Connect(function()
                    dragging = true
                    updateSlider(mouse.X)
                end)
                
                sliderBtn.MouseButton1Up:Connect(function()
                    dragging = false
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                mouse.Move:Connect(function()
                    if dragging then
                        updateSlider(mouse.X)
                    end
                end)
                
                updateSectionFrame()
                
                -- 主题更新
                coroutine.wrap(function()
                    while wait(0.1) do
                        sliderElement.BackgroundColor3 = theme.ElementColor
                        write.ImageColor3 = theme.SchemeColor
                        togName.TextColor3 = theme.TextColor
                        val.TextColor3 = theme.TextColor
                        sliderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                        sliderDrag.BackgroundColor3 = theme.SchemeColor
                    end
                end)()
            end
            
            -- 下拉框控件
            function Elements:NewDropdown(dropname, dropinf, list, callback)
                dropname = dropname or "下拉框"
                dropinf = dropinf or "选择选项"
                list = list or {"选项1", "选项2", "选项3"}
                callback = callback or function() end
                
                local opened = false
                local selected = list[1] or ""
                
                local dropFrame = Instance.new("Frame")
                local dropOpen = Instance.new("TextButton")
                local listImg = Instance.new("ImageLabel")
                local itemTextbox = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")
                local dropOptions = Instance.new("Frame")
                
                dropFrame.Name = "dropFrame"
                dropFrame.Parent = sectionInners
                dropFrame.BackgroundTransparency = 1
                dropFrame.Size = UDim2.new(1, 0, 0, 40)
                dropFrame.ClipsDescendants = true
                
                dropOpen.Name = "dropOpen"
                dropOpen.Parent = dropFrame
                dropOpen.BackgroundColor3 = theme.ElementColor
                dropOpen.Size = UDim2.new(1, 0, 0, 40)
                dropOpen.AutoButtonColor = false
                dropOpen.Text = ""
                
                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = dropOpen
                
                listImg.Name = "listImg"
                listImg.Parent = dropOpen
                listImg.BackgroundTransparency = 1
                listImg.Position = UDim2.new(0, 10, 0, 10)
                listImg.Size = UDim2.new(0, 20, 0, 20)
                listImg.Image = "rbxassetid://3926305904"
                listImg.ImageColor3 = theme.SchemeColor
                listImg.ImageRectOffset = Vector2.new(644, 364)
                listImg.ImageRectSize = Vector2.new(36, 36)
                
                itemTextbox.Name = "itemTextbox"
                itemTextbox.Parent = dropOpen
                itemTextbox.BackgroundTransparency = 1
                itemTextbox.Position = UDim2.new(0, 40, 0, 0)
                itemTextbox.Size = UDim2.new(1, -80, 1, 0)
                itemTextbox.Font = Enum.Font.GothamSemibold
                itemTextbox.Text = dropname
                itemTextbox.TextColor3 = theme.TextColor
                itemTextbox.TextSize = 14
                itemTextbox.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 下拉箭头
                local arrow = Instance.new("ImageLabel")
                arrow.Name = "arrow"
                arrow.Parent = dropOpen
                arrow.BackgroundTransparency = 1
                arrow.Position = UDim2.new(1, -30, 0, 10)
                arrow.Size = UDim2.new(0, 20, 0, 20)
                arrow.Image = "rbxassetid://3926305904"
                arrow.ImageColor3 = theme.SchemeColor
                arrow.ImageRectOffset = Vector2.new(884, 284)
                arrow.ImageRectSize = Vector2.new(36, 36)
                
                dropOptions.Name = "dropOptions"
                dropOptions.Parent = dropFrame
                dropOptions.BackgroundColor3 = theme.ElementColor
                dropOptions.Position = UDim2.new(0, 0, 0, 45)
                dropOptions.Size = UDim2.new(1, 0, 0, 0)
                dropOptions.Visible = false
                
                UIListLayout.Parent = dropOptions
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                -- 创建选项
                local function createOptions()
                    dropOptions:ClearAllChildren()
                    UIListLayout.Parent = dropOptions
                    
                    for i, option in pairs(list) do
                        local optionBtn = Instance.new("TextButton")
                        local optionCorner = Instance.new("UICorner")
                        
                        optionBtn.Name = "option_"..i
                        optionBtn.Parent = dropOptions
                        optionBtn.BackgroundColor3 = theme.ElementColor
                        optionBtn.Size = UDim2.new(1, 0, 0, 35)
                        optionBtn.AutoButtonColor = false
                        optionBtn.Text = ""
                        
                        optionCorner.CornerRadius = UDim.new(0, 6)
                        optionCorner.Parent = optionBtn
                        
                        local optionText = Instance.new("TextLabel")
                        optionText.Name = "optionText"
                        optionText.Parent = optionBtn
                        optionText.BackgroundTransparency = 1
                        optionText.Position = UDim2.new(0, 15, 0, 0)
                        optionText.Size = UDim2.new(1, -30, 1, 0)
                        optionText.Font = Enum.Font.Gotham
                        optionText.Text = option
                        optionText.TextColor3 = theme.TextColor
                        optionText.TextSize = 14
                        optionText.TextXAlignment = Enum.TextXAlignment.Left
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            selected = option
                            itemTextbox.Text = option
                            callback(option)
                            dropOpen.Text = ""
                            
                            -- 关闭下拉框
                            opened = false
                            dropOptions.Visible = false
                            dropFrame.Size = UDim2.new(1, 0, 0, 40)
                            updateSectionFrame()
                            
                            Utility:TweenObject(arrow, {
                                Rotation = 0
                            }, 0.2)
                        end)
                        
                        optionBtn.MouseEnter:Connect(function()
                            Utility:TweenObject(optionBtn, {
                                BackgroundColor3 = Color3.fromRGB(
                                    theme.ElementColor.r * 255 + 10,
                                    theme.ElementColor.g * 255 + 10,
                                    theme.ElementColor.b * 255 + 10
                                )
                            }, 0.2)
                        end)
                        
                        optionBtn.MouseLeave:Connect(function()
                            Utility:TweenObject(optionBtn, {
                                BackgroundColor3 = theme.ElementColor
                            }, 0.2)
                        end)
                    end
                end
                
                createOptions()
                
                -- 切换下拉框
                dropOpen.MouseButton1Click:Connect(function()
                    opened = not opened
                    
                    if opened then
                        local optionCount = #list
                        local optionHeight = math.min(optionCount * 35, 200)
                        
                        dropOptions.Visible = true
                        dropOptions.Size = UDim2.new(1, 0, 0, optionHeight)
                        dropFrame.Size = UDim2.new(1, 0, 0, 40 + optionHeight)
                        
                        Utility:TweenObject(arrow, {
                            Rotation = 180
                        }, 0.2)
                    else
                        dropOptions.Visible = false
                        dropFrame.Size = UDim2.new(1, 0, 0, 40)
                        
                        Utility:TweenObject(arrow, {
                            Rotation = 0
                        }, 0.2)
                    end
                    
                    updateSectionFrame()
                end)
                
                -- 悬停效果
                dropOpen.MouseEnter:Connect(function()
                    Utility:TweenObject(dropOpen, {
                        BackgroundColor3 = Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        )
                    }, 0.2)
                end)
                
                dropOpen.MouseLeave:Connect(function()
                    Utility:TweenObject(dropOpen, {
                        BackgroundColor3 = theme.ElementColor
                    }, 0.2)
                end)
                
                updateSectionFrame()
                
                -- 主题更新
                coroutine.wrap(function()
                    while wait(0.1) do
                        dropOpen.BackgroundColor3 = dropOpen.BackgroundColor3 == Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        ) and Color3.fromRGB(
                            theme.ElementColor.r * 255 + 10,
                            theme.ElementColor.g * 255 + 10,
                            theme.ElementColor.b * 255 + 10
                        ) or theme.ElementColor
                        
                        listImg.ImageColor3 = theme.SchemeColor
                        itemTextbox.TextColor3 = theme.TextColor
                        arrow.ImageColor3 = theme.SchemeColor
                        dropOptions.BackgroundColor3 = theme.ElementColor
                        
                        for _, optionBtn in pairs(dropOptions:GetChildren()) do
                            if optionBtn:IsA("TextButton") then
                                optionBtn.BackgroundColor3 = optionBtn.BackgroundColor3 == Color3.fromRGB(
                                    theme.ElementColor.r * 255 + 10,
                                    theme.ElementColor.g * 255 + 10,
                                    theme.ElementColor.b * 255 + 10
                                ) and Color3.fromRGB(
                                    theme.ElementColor.r * 255 + 10,
                                    theme.ElementColor.g * 255 + 10,
                                    theme.ElementColor.b * 255 + 10
                                ) or theme.ElementColor
                                
                                if optionBtn:FindFirstChild("optionText") then
                                    optionBtn.optionText.TextColor3 = theme.TextColor
                                end
                            end
                        end
                    end
                end)()
                
                local DropFunction = {}
                
                function DropFunction:Refresh(newList)
                    list = newList or list
                    selected = list[1] or ""
                    itemTextbox.Text = dropname
                    createOptions()
                    
                    if opened then
                        opened = false
                        dropOptions.Visible = false
                        dropFrame.Size = UDim2.new(1, 0, 0, 40)
                        Utility:TweenObject(arrow, {
                            Rotation = 0
                        }, 0.2)
                        updateSectionFrame()
                    end
                end
                
                function DropFunction:GetSelected()
                    return selected
                end
                
                function DropFunction:SetSelected(value)
                    if table.find(list, value) then
                        selected = value
                        itemTextbox.Text = value
                        callback(value)
                    end
                end
                
                return DropFunction
            end
            
            -- 标签控件
            function Elements:NewLabel(title)
                title = title or "标签"
                
                local label = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")
                
                label.Name = "label"
                label.Parent = sectionInners
                label.BackgroundColor3 = theme.SchemeColor
                label.Size = UDim2.new(1, 0, 0, 35)
                label.Font = Enum.Font.Gotham
                label.Text = "  "..title
                label.TextColor3 = theme.TextColor
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                
                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = label
                
                updateSectionFrame()
                
                local LabelFunction = {}
                
                function LabelFunction:UpdateLabel(newText)
                    label.Text = "  "..(newText or title)
                end
                
                return LabelFunction
            end
            
            return Elements
        end
        
        return Sections
    end
    
    return Tabs
end

-- 发送初始通知
coroutine.wrap(function()
    wait(1)
    if Kavo.Notify then
        Kavo:Notify("Kavo UI 已加载", "版本：修复美化版\n按 F9 切换界面显示", 5, 3926305904)
    end
end)()

return Kavo