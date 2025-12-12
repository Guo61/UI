local Kavo = {}

local tween = game:GetService("TweenService")
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local http = game:GetService("HttpService")

local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()

local Utility = {}
local Objects = {}
local UIStates = {}
local minimizedStates = {}
local notifications = {}
local tooltips = {}
local popups = {}
local customCursors = {}
local animations = {}
local sounds = {}
local effects = {}

local LibName = "KavoUltraUI_"..tostring(math.random(10000, 99999)).."_"..tostring(math.random(10000, 99999))

function Utility:CreateSound(id, volume, looped)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://"..tostring(id)
    sound.Volume = volume or 0.5
    sound.Looped = looped or false
    sound.Parent = game:GetService("SoundService")
    sounds[id] = sound
    return sound
end

function Utility:PlaySound(id, volume)
    if sounds[id] then
        sounds[id]:Stop()
        if volume then sounds[id].Volume = volume end
        sounds[id]:Play()
    end
end

function Utility:CreateParticleEffect(parent, effectType, color)
    local effect = Instance.new("ParticleEmitter")
    effect.Parent = parent
    
    if effectType == "sparkle" then
        effect.Texture = "rbxassetid://242098110"
        effect.Lifetime = NumberRange.new(0.5, 1)
        effect.Rate = 20
        effect.Speed = NumberRange.new(10, 20)
        effect.Rotation = NumberRange.new(0, 360)
        effect.RotSpeed = NumberRange.new(-180, 180)
        effect.Enabled = false
    elseif effectType == "glow" then
        effect.Texture = "rbxassetid://242098114"
        effect.Lifetime = NumberRange.new(1, 2)
        effect.Rate = 10
        effect.Speed = NumberRange.new(5, 10)
        effect.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
    end
    
    if color then
        effect.Color = ColorSequence.new(color)
    end
    
    effects[effect] = true
    return effect
end

function Utility:TweenObject(obj, properties, duration, easingStyle, easingDirection)
    local info = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tween = tween:Create(obj, info, properties)
    tween:Play()
    return tween
end

function Utility:SpringAnimation(obj, property, target, damping, frequency)
    local connection
    local current = obj[property]
    local velocity = 0
    
    local function update(dt)
        local force = (target - current) * frequency
        velocity = velocity * (1 - damping) + force * dt
        current = current + velocity
        obj[property] = current
        
        if math.abs(target - current) < 0.01 and math.abs(velocity) < 0.01 then
            if connection then connection:Disconnect() end
        end
    end
    
    connection = run.RenderStepped:Connect(update)
    animations[connection] = true
    return connection
end

function Utility:ShakeObject(obj, intensity, duration)
    local originalPosition = obj.Position
    local shakeConnection
    
    local function shake()
        local offsetX = math.random(-intensity, intensity)
        local offsetY = math.random(-intensity, intensity)
        obj.Position = UDim2.new(
            originalPosition.X.Scale,
            originalPosition.X.Offset + offsetX,
            originalPosition.Y.Scale,
            originalPosition.Y.Offset + offsetY
        )
    end
    
    shakeConnection = run.RenderStepped:Connect(shake)
    animations[shakeConnection] = true
    
    task.delay(duration, function()
        if shakeConnection then
            shakeConnection:Disconnect()
            animations[shakeConnection] = nil
        end
        Utility:TweenObject(obj, {Position = originalPosition}, 0.2)
    end)
    
    return shakeConnection
end

function Utility:CreateRipple(parent, position, color, size, duration)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Parent = parent
    ripple.BackgroundColor3 = color or Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.5
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X - 10, 0, position.Y - 10)
    ripple.ZIndex = 1000
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    Utility:TweenObject(ripple, {
        Size = UDim2.new(0, size or 100, 0, size or 100),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, position.X - (size or 100)/2, 0, position.Y - (size or 100)/2)
    }, duration or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(duration or 0.5, function()
        ripple:Destroy()
    end)
    
    return ripple
end

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    
    local dragging = false
    local dragInput, mousePos, framePos
    local dragSpeed = 1

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            Utility:CreateRipple(frame, input.Position, Color3.new(1, 1, 1), 50, 0.4)
            
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
                framePos.X.Offset + delta.X * dragSpeed,
                framePos.Y.Scale, 
                framePos.Y.Offset + delta.Y * dragSpeed
            )
        end
    end)
end

function Kavo:CreateCustomCursor(cursorType, color, size)
    local cursor = Instance.new("ImageLabel")
    cursor.Name = "CustomCursor"
    cursor.Parent = game.CoreGui
    cursor.BackgroundTransparency = 1
    cursor.Size = UDim2.new(0, size or 32, 0, size or 32)
    cursor.ZIndex = 99999
    cursor.Visible = false
    
    if cursorType == "pointer" then
        cursor.Image = "rbxassetid://3926305904"
        cursor.ImageRectOffset = Vector2.new(284, 4)
        cursor.ImageRectSize = Vector2.new(24, 24)
    elseif cursorType == "hand" then
        cursor.Image = "rbxassetid://3926305904"
        cursor.ImageRectOffset = Vector2.new(4, 964)
        cursor.ImageRectSize = Vector2.new(36, 36)
    elseif cursorType == "crosshair" then
        cursor.Image = "rbxassetid://3926305904"
        cursor.ImageRectOffset = Vector2.new(164, 404)
        cursor.ImageRectSize = Vector2.new(36, 36)
    elseif cursorType == "custom" then
        cursor.Image = "rbxassetid://"..tostring(cursorType)
    end
    
    if color then
        cursor.ImageColor3 = color
    end
    
    local connection = run.RenderStepped:Connect(function()
        local mouseLocation = input:GetMouseLocation()
        cursor.Position = UDim2.new(0, mouseLocation.X - (size or 32)/2, 0, mouseLocation.Y - (size or 32)/2)
    end)
    
    customCursors[cursor] = connection
    
    local function enableCursor()
        cursor.Visible = true
        game:GetService("UserInputService").MouseIconEnabled = false
    end
    
    local function disableCursor()
        cursor.Visible = false
        game:GetService("UserInputService").MouseIconEnabled = true
    end
    
    return {
        Enable = enableCursor,
        Disable = disableCursor,
        SetType = function(newType)
            cursor.Image = "rbxassetid://"..tostring(newType)
        end,
        SetColor = function(newColor)
            cursor.ImageColor3 = newColor
        end,
        Destroy = function()
            if connection then connection:Disconnect() end
            cursor:Destroy()
        end
    }
end

local themes = {
    Dark = {
        SchemeColor = Color3.fromRGB(74, 99, 135),
        Background = Color3.fromRGB(20, 20, 25),
        Header = Color3.fromRGB(15, 15, 20),
        TextColor = Color3.fromRGB(240, 240, 240),
        ElementColor = Color3.fromRGB(30, 30, 35),
        ShadowColor = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.7,
        AccentColor = Color3.fromRGB(0, 162, 255),
        SuccessColor = Color3.fromRGB(76, 175, 80),
        WarningColor = Color3.fromRGB(255, 152, 0),
        ErrorColor = Color3.fromRGB(244, 67, 54),
        GradientColors = {
            Color3.fromRGB(30, 30, 40),
            Color3.fromRGB(20, 20, 30)
        }
    },
    Neon = {
        SchemeColor = Color3.fromRGB(0, 255, 255),
        Background = Color3.fromRGB(10, 10, 20),
        Header = Color3.fromRGB(0, 20, 40),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 30, 50),
        AccentColor = Color3.fromRGB(255, 0, 255),
        SuccessColor = Color3.fromRGB(0, 255, 128),
        WarningColor = Color3.fromRGB(255, 255, 0),
        ErrorColor = Color3.fromRGB(255, 0, 64),
        GradientColors = {
            Color3.fromRGB(0, 20, 40),
            Color3.fromRGB(0, 40, 80)
        }
    },
    Cyberpunk = {
        SchemeColor = Color3.fromRGB(255, 0, 128),
        Background = Color3.fromRGB(10, 5, 15),
        Header = Color3.fromRGB(20, 10, 30),
        TextColor = Color3.fromRGB(255, 200, 255),
        ElementColor = Color3.fromRGB(30, 15, 45),
        AccentColor = Color3.fromRGB(0, 255, 255),
        SuccessColor = Color3.fromRGB(128, 255, 0),
        WarningColor = Color3.fromRGB(255, 128, 0),
        ErrorColor = Color3.fromRGB(255, 0, 64),
        GradientColors = {
            Color3.fromRGB(255, 0, 128),
            Color3.fromRGB(0, 255, 255)
        }
    },
    Material = {
        SchemeColor = Color3.fromRGB(33, 150, 243),
        Background = Color3.fromRGB(250, 250, 250),
        Header = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(33, 33, 33),
        ElementColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(255, 64, 129),
        SuccessColor = Color3.fromRGB(76, 175, 80),
        WarningColor = Color3.fromRGB(255, 152, 0),
        ErrorColor = Color3.fromRGB(244, 67, 54),
        GradientColors = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(245, 245, 245)
        }
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(0, 200, 180),
        Background = Color3.fromRGB(15, 25, 40),
        Header = Color3.fromRGB(25, 40, 65),
        TextColor = Color3.fromRGB(220, 240, 255),
        ElementColor = Color3.fromRGB(30, 50, 80),
        AccentColor = Color3.fromRGB(255, 105, 180),
        SuccessColor = Color3.fromRGB(0, 230, 118),
        WarningColor = Color3.fromRGB(255, 214, 0),
        ErrorColor = Color3.fromRGB(255, 82, 82),
        GradientColors = {
            Color3.fromRGB(25, 40, 65),
            Color3.fromRGB(15, 30, 55)
        }
    }
}

local SettingsT = {}
local Name = "KavoUltraConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, http:JSONEncode(SettingsT))
    end
    SettingsT = http:JSONDecode(readfile(Name))
end)

function Kavo:ToggleUI()
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if screenGui then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            Utility:PlaySound(4047132169, 0.3)
        else
            Utility:PlaySound(4047132467, 0.3)
        end
    end
end

function Kavo:ToggleMinimize()
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if not screenGui then return end
    
    local mainFrame = screenGui:FindFirstChild("Main")
    if not mainFrame then return end
    
    local minimized = minimizedStates[LibName] or false
    
    if minimized then
        Utility:TweenObject(mainFrame, {
            Size = UDim2.new(0, 700, 0, 500)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        for _, child in pairs(mainFrame:GetChildren()) do
            if child.Name ~= "MainHeader" then
                Utility:TweenObject(child, {
                    BackgroundTransparency = 0
                }, 0.3)
            end
        end
        
        minimizedStates[LibName] = false
        Utility:PlaySound(4047132169, 0.3)
    else
        Utility:TweenObject(mainFrame, {
            Size = UDim2.new(0, 700, 0, 60)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        for _, child in pairs(mainFrame:GetChildren()) do
            if child.Name ~= "MainHeader" then
                Utility:TweenObject(child, {
                    BackgroundTransparency = 1
                }, 0.3)
            end
        end
        
        minimizedStates[LibName] = true
        Utility:PlaySound(4047132467, 0.3)
    end
end

function Kavo:SaveUIPosition(position)
    if not UIStates[LibName] then
        UIStates[LibName] = {}
    end
    UIStates[LibName].Position = position
    if SettingsT then
        SettingsT.UIPosition = {position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset}
        writefile(Name, http:JSONEncode(SettingsT))
    end
end

function Kavo:LoadUIPosition()
    if SettingsT and SettingsT.UIPosition then
        local pos = SettingsT.UIPosition
        return UDim2.new(pos[1], pos[2], pos[3], pos[4])
    end
    return UDim2.new(0.15, 0, 0.15, 0)
end

function Kavo:BindToggleKey(keyCode)
    input.InputBegan:Connect(function(input)
        if input.KeyCode == keyCode then
            Kavo:ToggleUI()
        end
    end)
end

function Kavo:CreateTooltip(text, position, parent)
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Parent = parent or game.CoreGui
    tooltip.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tooltip.BackgroundTransparency = 0.1
    tooltip.BorderSizePixel = 0
    tooltip.Position = position or UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20)
    tooltip.Size = UDim2.new(0, 0, 0, 0)
    tooltip.ZIndex = 9999
    tooltip.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tooltip
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 150)
    stroke.Thickness = 1
    stroke.Parent = tooltip
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50))
    })
    gradient.Rotation = 90
    gradient.Parent = tooltip
    
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Parent = tooltip
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    
    local textSize = game:GetService("TextService"):GetTextSize(text, 14, label.Font, Vector2.new(300, math.huge))
    local targetSize = UDim2.new(0, math.min(textSize.X + 40, 300), 0, textSize.Y + 40)
    
    Utility:TweenObject(tooltip, {
        Size = targetSize
    }, 0.2)
    
    tooltips[tooltip] = true
    
    return {
        Update = function(newText)
            label.Text = newText
            local newSize = game:GetService("TextService"):GetTextSize(newText, 14, label.Font, Vector2.new(300, math.huge))
            Utility:TweenObject(tooltip, {
                Size = UDim2.new(0, math.min(newSize.X + 40, 300), 0, newSize.Y + 40)
            }, 0.2)
        end,
        Destroy = function()
            Utility:TweenObject(tooltip, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, 0.2, nil, nil, function()
                tooltip:Destroy()
                tooltips[tooltip] = nil
            end)
        end,
        MoveTo = function(newPosition)
            Utility:TweenObject(tooltip, {
                Position = newPosition
            }, 0.2)
        end
    }
end

function Kavo:CreatePopup(title, content, buttons, theme)
    theme = theme or themes.Dark
    
    local popup = Instance.new("Frame")
    popup.Name = "Popup"
    popup.Parent = game.CoreGui
    popup.BackgroundColor3 = theme.Background
    popup.BackgroundTransparency = 1
    popup.BorderSizePixel = 0
    popup.Size = UDim2.new(1, 0, 1, 0)
    popup.ZIndex = 9998
    
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Parent = popup
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.Size = UDim2.new(1, 0, 1, 0)
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Parent = popup
    container.BackgroundColor3 = theme.Background
    container.BorderSizePixel = 0
    container.Size = UDim2.new(0, 400, 0, 300)
    container.Position = UDim2.new(0.5, -200, 0.5, -150)
    container.ZIndex = 9999
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.SchemeColor
    stroke.Thickness = 2
    stroke.Parent = container
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(theme.GradientColors or {theme.Background, theme.Background})
    gradient.Rotation = 90
    gradient.Parent = container
    
    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.Parent = container
    titleFrame.BackgroundColor3 = theme.Header
    titleFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12, 0, 0)
    titleCorner.Parent = titleFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = titleFrame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.TextColor
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "Close"
    closeButton.Parent = titleFrame
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = theme.TextColor
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Parent = container
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 20, 0, 70)
    contentFrame.Size = UDim2.new(1, -40, 0, 180)
    contentFrame.ScrollBarThickness = 5
    contentFrame.ScrollBarImageColor3 = theme.SchemeColor
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Text"
    contentLabel.Parent = contentFrame
    contentLabel.BackgroundTransparency = 1
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Text = content
    contentLabel.TextColor3 = theme.TextColor
    contentLabel.TextSize = 14
    contentLabel.TextWrapped = true
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "Buttons"
    buttonContainer.Parent = container
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Position = UDim2.new(0, 20, 0, 260)
    buttonContainer.Size = UDim2.new(1, -40, 0, 30)
    
    local buttonList = Instance.new("UIListLayout")
    buttonList.Parent = buttonContainer
    buttonList.FillDirection = Enum.FillDirection.Horizontal
    buttonList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonList.SortOrder = Enum.SortOrder.LayoutOrder
    buttonList.Padding = UDim.new(0, 10)
    
    Utility:TweenObject(popup, {BackgroundTransparency = 0}, 0.3)
    Utility:TweenObject(container, {Size = UDim2.new(0, 400, 0, 300)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    local result = nil
    local closed = false
    
    local function closePopup(buttonResult)
        if closed then return end
        closed = true
        
        Utility:TweenObject(container, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        Utility:TweenObject(popup, {BackgroundTransparency = 1}, 0.3)
        
        task.delay(0.4, function()
            popup:Destroy()
            popups[popup] = nil
        end)
        
        result = buttonResult
    end
    
    closeButton.MouseButton1Click:Connect(function()
        closePopup(nil)
    end)
    
    for i, buttonData in pairs(buttons or {}) do
        local button = Instance.new("TextButton")
        button.Name = "Button"..i
        button.Parent = buttonContainer
        button.BackgroundColor3 = buttonData.Color or theme.SchemeColor
        button.Size = UDim2.new(0, 80, 0, 30)
        button.Font = Enum.Font.GothamSemibold
        button.Text = buttonData.Text or "Button"
        button.TextColor3 = theme.TextColor
        button.TextSize = 14
        button.AutoButtonColor = false
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            Utility:CreateRipple(button, Vector2.new(40, 15), Color3.new(1, 1, 1), 60, 0.3)
            Utility:PlaySound(4047132169, 0.3)
            closePopup(buttonData.Value or buttonData.Text)
        end)
        
        button.MouseEnter:Connect(function()
            Utility:TweenObject(button, {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(buttonData.Color.R * 255 + 20, 255),
                    math.min(buttonData.Color.G * 255 + 20, 255),
                    math.min(buttonData.Color.B * 255 + 20, 255)
                )
            }, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            Utility:TweenObject(button, {
                BackgroundColor3 = buttonData.Color or theme.SchemeColor
            }, 0.2)
        end)
    end
    
    popups[popup] = true
    
    return {
        WaitForResult = function()
            while popups[popup] do
                run.RenderStepped:Wait()
            end
            return result
        end,
        Close = function(value)
            closePopup(value)
        end
    }
end

function Kavo:Notify(title, content, duration, image, sound)
    title = title or "通知"
    content = content or ""
    duration = duration or 5
    image = image or 3926305904
    sound = sound or 4047132169
    
    if not notifications[LibName] then
        notifications[LibName] = {}
    end
    
    local screenGui = game.CoreGui:FindFirstChild(LibName)
    if not screenGui then return end
    
    if sound then Utility:PlaySound(sound, 0.3) end
    
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
    local stroke = Instance.new("UIStroke")
    local glow = Instance.new("ImageLabel")
    
    notificationFrame.Name = "Notification"..#notifications[LibName] + 1
    notificationFrame.Parent = screenGui
    notificationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Position = UDim2.new(1, 10, 1, -150)
    notificationFrame.Size = UDim2.new(0, 350, 0, 140)
    notificationFrame.ClipsDescendants = true
    notificationFrame.ZIndex = 10000
    
    glow.Name = "Glow"
    glow.Parent = notificationFrame
    glow.BackgroundTransparency = 1
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.Image = "rbxassetid://5554236805"
    glow.ImageColor3 = Color3.fromRGB(0, 100, 255)
    glow.ImageTransparency = 0.8
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(23, 23, 277, 277)
    glow.ZIndex = 9999
    
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = notificationFrame
    
    stroke.Color = Color3.fromRGB(100, 100, 150)
    stroke.Thickness = 1
    stroke.Parent = notificationFrame
    
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    }
    gradient.Rotation = 90
    gradient.Parent = notificationFrame
    
    iconImage.Name = "Icon"
    iconImage.Parent = notificationFrame
    iconImage.BackgroundTransparency = 1
    iconImage.Position = UDim2.new(0, 20, 0, 20)
    iconImage.Size = UDim2.new(0, 40, 0, 40)
    iconImage.Image = "rbxassetid://"..tostring(image)
    iconImage.ImageColor3 = Color3.fromRGB(0, 200, 255)
    iconImage.ZIndex = 10001
    iconImage.ImageTransparency = 1
    
    titleLabel.Name = "Title"
    titleLabel.Parent = notificationFrame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 80, 0, 20)
    titleLabel.Size = UDim2.new(1, -100, 0, 25)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 10001
    
    contentLabel.Name = "Content"
    contentLabel.Parent = notificationFrame
    contentLabel.BackgroundTransparency = 1
    contentLabel.Position = UDim2.new(0, 80, 0, 50)
    contentLabel.Size = UDim2.new(1, -100, 1, -90)
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    contentLabel.TextSize = 14
    contentLabel.TextTransparency = 1
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.ZIndex = 10001
    
    closeButton.Name = "Close"
    closeButton.Parent = notificationFrame
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -40, 0, 20)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = Color3.fromRGB(150, 150, 170)
    closeButton.ZIndex = 10001
    closeButton.ImageTransparency = 1
    
    progressBar.Name = "ProgressBar"
    progressBar.Parent = notificationFrame
    progressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBar.BorderSizePixel = 0
    progressBar.Position = UDim2.new(0, 0, 1, -6)
    progressBar.Size = UDim2.new(1, 0, 0, 6)
    progressBar.ZIndex = 10001
    progressBar.BackgroundTransparency = 1
    
    progressBarCorner.CornerRadius = UDim.new(0, 3)
    progressBarCorner.Parent = progressBar
    
    progressBarFill.Name = "ProgressBarFill"
    progressBarFill.Parent = progressBar
    progressBarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    progressBarFill.BorderSizePixel = 0
    progressBarFill.Size = UDim2.new(1, 0, 1, 0)
    progressBarFill.ZIndex = 10002
    
    progressBarFillCorner.CornerRadius = UDim.new(0, 3)
    progressBarFillCorner.Parent = progressBarFill
    
    local showPosition = UDim2.new(1, -370, 1, -160)
    
    Utility:TweenObject(notificationFrame, {
        Position = showPosition,
        BackgroundTransparency = 0
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    Utility:TweenObject(iconImage, {ImageTransparency = 0}, 0.3)
    Utility:TweenObject(titleLabel, {TextTransparency = 0}, 0.3)
    Utility:TweenObject(contentLabel, {TextTransparency = 0}, 0.3)
    Utility:TweenObject(closeButton, {ImageTransparency = 0}, 0.3)
    Utility:TweenObject(progressBar, {BackgroundTransparency = 0}, 0.3)
    
    closeButton.MouseButton1Click:Connect(function()
        Utility:CreateRipple(closeButton, Vector2.new(10, 10), Color3.new(1, 1, 1), 40, 0.3)
        Utility:PlaySound(4047132467, 0.3)
        
        Utility:TweenObject(iconImage, {ImageTransparency = 1}, 0.2)
        Utility:TweenObject(titleLabel, {TextTransparency = 1}, 0.2)
        Utility:TweenObject(contentLabel, {TextTransparency = 1}, 0.2)
        Utility:TweenObject(closeButton, {ImageTransparency = 1}, 0.2)
        Utility:TweenObject(progressBar, {BackgroundTransparency = 1}, 0.2)
        
        Utility:TweenObject(notificationFrame, {
            Position = UDim2.new(1, 10, 1, -150),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            notificationFrame:Destroy()
        end)
    end)
    
    local progressTime = duration
    local startTime = tick()
    local hovering = false
    
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
                
                if not hovering then
                    Utility:TweenObject(iconImage, {ImageTransparency = 1}, 0.2)
                    Utility:TweenObject(titleLabel, {TextTransparency = 1}, 0.2)
                    Utility:TweenObject(contentLabel, {TextTransparency = 1}, 0.2)
                    Utility:TweenObject(closeButton, {ImageTransparency = 1}, 0.2)
                    Utility:TweenObject(progressBar, {BackgroundTransparency = 1}, 0.2)
                    
                    Utility:TweenObject(notificationFrame, {
                        Position = UDim2.new(1, 10, 1, -150),
                        BackgroundTransparency = 1
                    }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                        notificationFrame:Destroy()
                    end)
                end
            else
                progressBarFill.Size = UDim2.new(progress, 0, 1, 0)
            end
        end)
    end
    
    notificationFrame.MouseEnter:Connect(function()
        hovering = true
        Utility:TweenObject(notificationFrame, {
            BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        }, 0.2)
        Utility:TweenObject(glow, {
            ImageTransparency = 0.5
        }, 0.2)
    end)
    
    notificationFrame.MouseLeave:Connect(function()
        hovering = false
        Utility:TweenObject(notificationFrame, {
            BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        }, 0.2)
        Utility:TweenObject(glow, {
            ImageTransparency = 0.8
        }, 0.2)
    end)
    
    notifications[LibName][notificationFrame] = true
    
    return {
        Hide = function()
            if notificationFrame and notificationFrame.Parent then
                Utility:TweenObject(notificationFrame, {
                    Position = UDim2.new(1, 10, 1, -150),
                    BackgroundTransparency = 1
                }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                    notificationFrame:Destroy()
                    notifications[LibName][notificationFrame] = nil
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
        end
    }
end

function Kavo:CreateLib(name, themeName)
    name = name or "高级UI界面"
    themeName = themeName or "Dark"
    
    local theme = themes[themeName] or themes.Dark
    
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:find("KavoUltraUI_") then
            v:Destroy()
        end
    end
    
    Utility:CreateSound(4047132169, 0.5, false)
    Utility:CreateSound(4047132467, 0.5, false)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = theme.Background
    Main.BackgroundTransparency = 0.1
    Main.ClipsDescendants = true
    Main.Position = Kavo:LoadUIPosition()
    Main.Size = UDim2.new(0, 700, 0, 500)
    Main.ZIndex = 100
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = theme.SchemeColor
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.3
    MainStroke.Parent = Main
    
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new(theme.GradientColors or {theme.Background, theme.Background})
    MainGradient.Rotation = 45
    MainGradient.Parent = Main
    
    local MainGlow = Instance.new("ImageLabel")
    MainGlow.Name = "Glow"
    MainGlow.Parent = Main
    MainGlow.BackgroundTransparency = 1
    MainGlow.Size = UDim2.new(1, 40, 1, 40)
    MainGlow.Position = UDim2.new(0, -20, 0, -20)
    MainGlow.Image = "rbxassetid://5554236805"
    MainGlow.ImageColor3 = theme.SchemeColor
    MainGlow.ImageTransparency = 0.9
    MainGlow.ScaleType = Enum.ScaleType.Slice
    MainGlow.SliceCenter = Rect.new(23, 23, 277, 277)
    MainGlow.ZIndex = 99
    
    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = theme.Header
    MainHeader.BackgroundTransparency = 0.2
    MainHeader.Size = UDim2.new(1, 0, 0, 60)
    MainHeader.ZIndex = 101
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16, 0, 0)
    HeaderCorner.Parent = MainHeader
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.min(theme.Header.R * 255 + 20, 255),
            math.min(theme.Header.G * 255 + 20, 255),
            math.min(theme.Header.B * 255 + 20, 255)
        )),
        ColorSequenceKeypoint.new(1, theme.Header)
    })
    HeaderGradient.Rotation = 90
    HeaderGradient.Parent = MainHeader
    
    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 25, 0, 0)
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = name
    title.TextColor3 = theme.TextColor
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "subtitle"
    subtitle.Parent = MainHeader
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 25, 0, 35)
    subtitle.Size = UDim2.new(0, 300, 0, 20)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "高级功能界面 v2.0"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 102
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Parent = MainHeader
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Position = UDim2.new(1, -120, 0, 15)
    buttonContainer.Size = UDim2.new(0, 120, 0, 30)
    buttonContainer.ZIndex = 102
    
    local buttonList = Instance.new("UIListLayout")
    buttonList.Parent = buttonContainer
    buttonList.FillDirection = Enum.FillDirection.Horizontal
    buttonList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonList.SortOrder = Enum.SortOrder.LayoutOrder
    buttonList.Padding = UDim.new(0, 10)
    
    local minimize = Instance.new("ImageButton")
    minimize.Name = "minimize"
    minimize.Parent = buttonContainer
    minimize.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minimize.BackgroundTransparency = 0.5
    minimize.Size = UDim2.new(0, 30, 0, 30)
    minimize.Image = "rbxassetid://3926305904"
    minimize.ImageRectOffset = Vector2.new(844, 164)
    minimize.ImageRectSize = Vector2.new(36, 36)
    minimize.ImageColor3 = theme.TextColor
    minimize.AutoButtonColor = false
    minimize.ZIndex = 103
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimize
    
    minimize.MouseButton1Click:Connect(function()
        Utility:CreateRipple(minimize, Vector2.new(15, 15), Color3.new(1, 1, 1), 40, 0.3)
        Utility:PlaySound(4047132169, 0.3)
        Kavo:ToggleMinimize()
    end)
    
    minimize.MouseEnter:Connect(function()
        Utility:TweenObject(minimize, {
            BackgroundTransparency = 0.2
        }, 0.2)
    end)
    
    minimize.MouseLeave:Connect(function()
        Utility:TweenObject(minimize, {
            BackgroundTransparency = 0.5
        }, 0.2)
    end)
    
    local close = Instance.new("ImageButton")
    close.Name = "close"
    close.Parent = buttonContainer
    close.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    close.BackgroundTransparency = 0.5
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.ImageColor3 = theme.TextColor
    close.AutoButtonColor = false
    close.ZIndex = 103
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = close
    
    close.MouseButton1Click:Connect(function()
        Utility:CreateRipple(close, Vector2.new(15, 15), Color3.new(1, 1, 1), 40, 0.3)
        Utility:PlaySound(4047132467, 0.3)
        
        Utility:TweenObject(close, {
            ImageTransparency = 1,
            BackgroundTransparency = 1
        }, 0.1)
        
        Utility:TweenObject(Main, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.delay(0.4, function()
            ScreenGui:Destroy()
        end)
    end)
    
    close.MouseEnter:Connect(function()
        Utility:TweenObject(close, {
            BackgroundTransparency = 0.2
        }, 0.2)
    end)
    
    close.MouseLeave:Connect(function()
        Utility:TweenObject(close, {
            BackgroundTransparency = 0.5
        }, 0.2)
    end)
    
    local MainSide = Instance.new("Frame")
    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainSide.BackgroundTransparency = 0.3
    MainSide.Position = UDim2.new(0, 0, 0, 60)
    MainSide.Size = UDim2.new(0, 200, 0, 440)
    MainSide.ZIndex = 101
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 0, 0, 16)
    SideCorner.Parent = MainSide
    
    local SideGradient = Instance.new("UIGradient")
    SideGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
    })
    SideGradient.Rotation = 90
    SideGradient.Parent = MainSide
    
    local userInfo = Instance.new("Frame")
    userInfo.Name = "UserInfo"
    userInfo.Parent = MainSide
    userInfo.BackgroundTransparency = 1
    userInfo.Position = UDim2.new(0, 20, 0, 20)
    userInfo.Size = UDim2.new(1, -40, 0, 80)
    userInfo.ZIndex = 102
    
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Parent = userInfo
    avatar.BackgroundColor3 = theme.SchemeColor
    avatar.Size = UDim2.new(0, 60, 0, 60)
    avatar.Image = "rbxassetid://"..tostring(localPlayer.UserId)
    avatar.ZIndex = 103
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(255, 255, 255)
    avatarStroke.Thickness = 2
    avatarStroke.Parent = avatar
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Parent = userInfo
    username.BackgroundTransparency = 1
    username.Position = UDim2.new(0, 70, 0, 10)
    username.Size = UDim2.new(1, -70, 0, 25)
    username.Font = Enum.Font.GothamBold
    username.Text = localPlayer.Name
    username.TextColor3 = theme.TextColor
    username.TextSize = 16
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.ZIndex = 103
    
    local userId = Instance.new("TextLabel")
    userId.Name = "UserId"
    userId.Parent = userInfo
    userId.BackgroundTransparency = 1
    userId.Position = UDim2.new(0, 70, 0, 35)
    userId.Size = UDim2.new(1, -70, 0, 20)
    userId.Font = Enum.Font.Gotham
    userId.Text = "ID: "..localPlayer.UserId
    userId.TextColor3 = Color3.fromRGB(180, 180, 200)
    userId.TextSize = 12
    userId.TextXAlignment = Enum.TextXAlignment.Left
    userId.ZIndex = 103
    
    local tabFrames = Instance.new("Frame")
    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundTransparency = 1
    tabFrames.Position = UDim2.new(0, 20, 0, 120)
    tabFrames.Size = UDim2.new(1, -40, 0, 300)
    tabFrames.ZIndex = 102
    
    local tabListing = Instance.new("UIListLayout")
    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 10)
    
    local pages = Instance.new("Frame")
    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0, 210, 0, 70)
    pages.Size = UDim2.new(1, -220, 1, -80)
    pages.ZIndex = 101
    
    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = pages
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = Main
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -30, 0, -30)
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = 98
    
    Kavo:DraggingEnabled(MainHeader, Main)
    
    local function savePosition()
        Kavo:SaveUIPosition(Main.Position)
    end
    
    Main.Changed:Connect(function(property)
        if property == "Position" then
            savePosition()
        end
    end)
    
    local particles = {}
    for i = 1, 20 do
        local particle = Instance.new("Frame")
        particle.Name = "Particle"..i
        particle.Parent = Main
        particle.BackgroundColor3 = theme.SchemeColor
        particle.BackgroundTransparency = 0.8
        particle.BorderSizePixel = 0
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(0, math.random(-50, 750), 0, math.random(-50, 550))
        particle.ZIndex = 95
        
        local particleCorner = Instance.new("UICorner")
        particleCorner.CornerRadius = UDim.new(1, 0)
        particleCorner.Parent = particle
        
        particles[i] = {
            frame = particle,
            speedX = math.random(-50, 50) / 100,
            speedY = math.random(-50, 50) / 100
        }
    end
    
    local particleConnection = run.RenderStepped:Connect(function(dt)
        for _, particle in pairs(particles) do
            if particle.frame and particle.frame.Parent then
                local currentPos = particle.frame.Position
                local newX = currentPos.X.Offset + particle.speedX * dt * 60
                local newY = currentPos.Y.Offset + particle.speedY * dt * 60
                
                if newX < -50 then newX = 750 particle.speedX = math.abs(particle.speedX) end
                if newX > 750 then newX = -50 particle.speedX = -math.abs(particle.speedX) end
                if newY < -50 then newY = 550 particle.speedY = math.abs(particle.speedY) end
                if newY > 550 then newY = -50 particle.speedY = -math.abs(particle.speedY) end
                
                particle.frame.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    
    animations[particleConnection] = true
    
    Utility:TweenObject(Main, {
        BackgroundTransparency = 0
    }, 0.5)
    
    Utility:TweenObject(MainGlow, {
        ImageTransparency = 0.7
    }, 0.5)
    
    Utility:PlaySound(4047132169, 0.5)
    
    local Tabs = {}
    local first = true
    
    function Tabs:NewTab(tabName, tabIcon)
        tabName = tabName or "标签页"
        tabIcon = tabIcon or 3926305904
        
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local icon = Instance.new("ImageLabel")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")
        local pagePadding = Instance.new("UIPadding")
        
        page.Name = tabName.."Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 8
        page.ScrollBarImageColor3 = theme.SchemeColor
        page.ScrollBarImageTransparency = 0.5
        page.Visible = false
        page.ZIndex = 102
        
        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 15)
        
        pagePadding.Name = "pagePadding"
        pagePadding.Parent = page
        pagePadding.PaddingLeft = UDim.new(0, 10)
        pagePadding.PaddingTop = UDim.new(0, 10)
        
        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = first and theme.SchemeColor or Color3.fromRGB(50, 50, 60)
        tabButton.BackgroundTransparency = first and 0.2 or 0.5
        tabButton.Size = UDim2.new(1, 0, 0, 50)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = ""
        tabButton.TextColor3 = theme.TextColor
        tabButton.TextSize = 14
        tabButton.ZIndex = 103
        
        UICorner.CornerRadius = UDim.new(0, 12)
        UICorner.Parent = tabButton
        
        icon.Name = "Icon"
        icon.Parent = tabButton
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 15, 0, 15)
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Image = "rbxassetid://"..tostring(tabIcon)
        icon.ImageColor3 = first and theme.TextColor or Color3.fromRGB(180, 180, 200)
        icon.ZIndex = 104
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Parent = tabButton
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 50, 0, 0)
        label.Size = UDim2.new(1, -55, 1, 0)
        label.Font = Enum.Font.GothamSemibold
        label.Text = tabName
        label.TextColor3 = first and theme.TextColor or Color3.fromRGB(180, 180, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 104
        
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Parent = tabButton
        indicator.BackgroundColor3 = theme.SchemeColor
        indicator.BackgroundTransparency = first and 0.3 or 1
        indicator.Position = UDim2.new(1, -5, 0, 15)
        indicator.Size = UDim2.new(0, 3, 0, 20)
        indicator.ZIndex = 104
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator
        
        if first then
            first = false
            page.Visible = true
            Utility:TweenObject(indicator, {BackgroundTransparency = 0.3}, 0.2)
        end
        
        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            page.CanvasSize = UDim2.new(0, 0, 0, cS.Y + 20)
        end
        
        UpdateSize()
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)
        
        tabButton.MouseButton1Click:Connect(function()
            Utility:CreateRipple(tabButton, Vector2.new(25, 25), Color3.new(1, 1, 1), 80, 0.4)
            Utility:PlaySound(4047132169, 0.2)
            
            for i, v in pairs(Pages:GetChildren()) do
                v.Visible = false
            end
            
            for i, v in pairs(tabFrames:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                        BackgroundTransparency = 0.5
                    }, 0.2)
                    
                    if v:FindFirstChild("Icon") then
                        Utility:TweenObject(v.Icon, {
                            ImageColor3 = Color3.fromRGB(180, 180, 200)
                        }, 0.2)
                    end
                    
                    if v:FindFirstChild("Label") then
                        Utility:TweenObject(v.Label, {
                            TextColor3 = Color3.fromRGB(180, 180, 200)
                        }, 0.2)
                    end
                    
                    if v:FindFirstChild("Indicator") then
                        Utility:TweenObject(v.Indicator, {
                            BackgroundTransparency = 1
                        }, 0.2)
                    end
                end
            end
            
            Utility:TweenObject(tabButton, {
                BackgroundColor3 = theme.SchemeColor,
                BackgroundTransparency = 0.2
            }, 0.2)
            
            if icon then
                Utility:TweenObject(icon, {
                    ImageColor3 = theme.TextColor
                }, 0.2)
            end
            
            if label then
                Utility:TweenObject(label, {
                    TextColor3 = theme.TextColor
                }, 0.2)
            end
            
            Utility:TweenObject(indicator, {
                BackgroundTransparency = 0.3
            }, 0.2)
            
            page.Visible = true
            UpdateSize()
        end)
        
        tabButton.MouseEnter:Connect(function()
            if tabButton.BackgroundColor3 ~= theme.SchemeColor then
                Utility:TweenObject(tabButton, {
                    BackgroundTransparency = 0.3
                }, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabButton.BackgroundColor3 ~= theme.SchemeColor then
                Utility:TweenObject(tabButton, {
                    BackgroundTransparency = 0.5
                }, 0.2)
            end
        end)
        
        local Sections = {}
        
        function Sections:NewSection(secName, secIcon)
            secName = secName or "分区"
            secIcon = secIcon or 3926305904
            
            local sectionFrame = Instance.new("Frame")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionIcon = Instance.new("ImageLabel")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            local sectionPadding = Instance.new("UIPadding")
            
            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.ZIndex = 103
            
            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            sectionHead.BackgroundTransparency = 0.5
            sectionHead.Size = UDim2.new(1, 0, 0, 45)
            sectionHead.ZIndex = 104
            
            sHeadCorner.CornerRadius = UDim.new(0, 10)
            sHeadCorner.Parent = sectionHead
            
            sectionIcon.Name = "sectionIcon"
            sectionIcon.Parent = sectionHead
            sectionIcon.BackgroundTransparency = 1
            sectionIcon.Position = UDim2.new(0, 15, 0, 12)
            sectionIcon.Size = UDim2.new(0, 20, 0, 20)
            sectionIcon.Image = "rbxassetid://"..tostring(secIcon)
            sectionIcon.ImageColor3 = theme.SchemeColor
            sectionIcon.ZIndex = 105
            
            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundTransparency = 1
            sectionName.Position = UDim2.new(0, 45, 0, 0)
            sectionName.Size = UDim2.new(1, -50, 1, 0)
            sectionName.Font = Enum.Font.GothamSemibold
            sectionName.Text = secName
            sectionName.TextColor3 = theme.TextColor
            sectionName.TextSize = 16
            sectionName.TextXAlignment = Enum.TextXAlignment.Left
            sectionName.ZIndex = 105
            
            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundTransparency = 1
            sectionInners.Position = UDim2.new(0, 0, 0, 55)
            sectionInners.Size = UDim2.new(1, 0, 0, 0)
            sectionInners.ZIndex = 103
            
            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 10)
            
            sectionPadding.Name = "sectionPadding"
            sectionPadding.Parent = sectionInners
            sectionPadding.PaddingLeft = UDim.new(0, 5)
            sectionPadding.PaddingRight = UDim.new(0, 5)
            
            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, innerSc.Y + 65)
                UpdateSize()
            end
            
            updateSectionFrame()
            sectionElListing:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionFrame)
            
            local Elements = {}
            
            function Elements:NewButton(bname, tipInf, callback, buttonIcon)
                bname = bname or "按钮"
                tipInf = tipInf or "点击执行功能"
                callback = callback or function() end
                buttonIcon = buttonIcon or 3926305904
                
                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local icon = Instance.new("ImageLabel")
                local btnInfo = Instance.new("TextLabel")
                local hoverEffect = Instance.new("Frame")
                local tooltip = nil
                
                buttonElement.Name = bname
                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                buttonElement.BackgroundTransparency = 0.5
                buttonElement.Size = UDim2.new(1, 0, 0, 50)
                buttonElement.AutoButtonColor = false
                buttonElement.Text = ""
                buttonElement.ZIndex = 105
                
                UICorner.CornerRadius = UDim.new(0, 10)
                UICorner.Parent = buttonElement
                
                icon.Name = "Icon"
                icon.Parent = buttonElement
                icon.BackgroundTransparency = 1
                icon.Position = UDim2.new(0, 15, 0, 15)
                icon.Size = UDim2.new(0, 20, 0, 20)
                icon.Image = "rbxassetid://"..tostring(buttonIcon)
                icon.ImageColor3 = theme.SchemeColor
                icon.ZIndex = 106
                
                btnInfo.Name = "btnInfo"
                btnInfo.Parent = buttonElement
                btnInfo.BackgroundTransparency = 1
                btnInfo.Position = UDim2.new(0, 50, 0, 0)
                btnInfo.Size = UDim2.new(1, -60, 1, 0)
                btnInfo.Font = Enum.Font.GothamSemibold
                btnInfo.Text = bname
                btnInfo.TextColor3 = theme.TextColor
                btnInfo.TextSize = 15
                btnInfo.TextXAlignment = Enum.TextXAlignment.Left
                btnInfo.ZIndex = 106
                
                hoverEffect.Name = "HoverEffect"
                hoverEffect.Parent = buttonElement
                hoverEffect.BackgroundColor3 = Color3.new(1, 1, 1)
                hoverEffect.BackgroundTransparency = 0.9
                hoverEffect.Size = UDim2.new(0, 0, 1, 0)
                hoverEffect.ZIndex = 106
                
                local hoverCorner = Instance.new("UICorner")
                hoverCorner.CornerRadius = UDim.new(0, 10)
                hoverCorner.Parent = hoverEffect
                
                buttonElement.MouseButton1Click:Connect(function()
                    Utility:CreateRipple(buttonElement, Vector2.new(25, 25), Color3.new(1, 1, 1), 100, 0.4)
                    Utility:PlaySound(4047132169, 0.2)
                    Utility:ShakeObject(buttonElement, 3, 0.2)
                    callback()
                end)
                
                buttonElement.MouseEnter:Connect(function()
                    Utility:TweenObject(buttonElement, {
                        BackgroundTransparency = 0.3
                    }, 0.2)
                    
                    Utility:TweenObject(hoverEffect, {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 0.7
                    }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    
                    if tipInf and tipInf ~= "" then
                        tooltip = Kavo:CreateTooltip(tipInf, UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20), game.CoreGui)
                    end
                end)
                
                buttonElement.MouseLeave:Connect(function()
                    Utility:TweenObject(buttonElement, {
                        BackgroundTransparency = 0.5
                    }, 0.2)
                    
                    Utility:TweenObject(hoverEffect, {
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 0.9
                    }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    
                    if tooltip then
                        tooltip:Destroy()
                        tooltip = nil
                    end
                end)
                
                buttonElement.MouseMoved:Connect(function()
                    if tooltip then
                        tooltip:MoveTo(UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20))
                    end
                end)
                
                updateSectionFrame()
                
                local ButtonFunction = {}
                
                function ButtonFunction:UpdateButton(newText, newIcon)
                    if newText then
                        btnInfo.Text = newText
                    end
                    if newIcon then
                        icon.Image = "rbxassetid://"..tostring(newIcon)
                    end
                end
                
                function ButtonFunction:SetEnabled(enabled)
                    buttonElement.Active = enabled
                    buttonElement.BackgroundTransparency = enabled and 0.5 or 0.8
                    icon.ImageTransparency = enabled and 0 or 0.5
                    btnInfo.TextTransparency = enabled and 0 or 0.5
                end
                
                return ButtonFunction
            end
            
            function Elements:NewToggle(tname, nTip, callback, default)
                tname = tname or "开关"
                nTip = nTip or "开启或关闭功能"
                callback = callback or function() end
                default = default or false
                
                local toggled = default
                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleFrame = Instance.new("Frame")
                local toggleCircle = Instance.new("Frame")
                local togName = Instance.new("TextLabel")
                local tooltip = nil
                
                toggleElement.Name = "toggleElement"
                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                toggleElement.BackgroundTransparency = 0.5
                toggleElement.Size = UDim2.new(1, 0, 0, 50)
                toggleElement.AutoButtonColor = false
                toggleElement.Text = ""
                toggleElement.ZIndex = 105
                
                UICorner.CornerRadius = UDim.new(0, 10)
                UICorner.Parent = toggleElement
                
                toggleFrame.Name = "toggleFrame"
                toggleFrame.Parent = toggleElement
                toggleFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
                toggleFrame.Position = UDim2.new(1, -75, 0, 15)
                toggleFrame.Size = UDim2.new(0, 50, 0, 20)
                toggleFrame.ZIndex = 106
                
                local frameCorner = Instance.new("UICorner")
                frameCorner.CornerRadius = UDim.new(1, 0)
                frameCorner.Parent = toggleFrame
                
                toggleCircle.Name = "toggleCircle"
                toggleCircle.Parent = toggleFrame
                toggleCircle.BackgroundColor3 = toggled and theme.SuccessColor or Color3.fromRGB(180, 180, 200)
                toggleCircle.Position = toggled and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
                toggleCircle.Size = UDim2.new(0, 16, 0, 16)
                toggleCircle.ZIndex = 107
                
                local circleCorner = Instance.new("UICorner")
                circleCorner.CornerRadius = UDim.new(1, 0)
                circleCorner.Parent = toggleCircle
                
                togName.Name = "togName"
                togName.Parent = toggleElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0, 15, 0, 0)
                togName.Size = UDim2.new(1, -100, 1, 0)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = tname
                togName.TextColor3 = theme.TextColor
                togName.TextSize = 15
                togName.TextXAlignment = Enum.TextXAlignment.Left
                togName.ZIndex = 106
                
                toggleElement.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Utility:PlaySound(4047132169, 0.1)
                    
                    if toggled then
                        Utility:TweenObject(toggleCircle, {
                            BackgroundColor3 = theme.SuccessColor,
                            Position = UDim2.new(1, -18, 0, 2)
                        }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        
                        Utility:TweenObject(toggleFrame, {
                            BackgroundColor3 = Color3.fromRGB(
                                theme.SuccessColor.R * 255 * 0.3,
                                theme.SuccessColor.G * 255 * 0.3,
                                theme.SuccessColor.B * 255 * 0.3
                            )
                        }, 0.2)
                    else
                        Utility:TweenObject(toggleCircle, {
                            BackgroundColor3 = Color3.fromRGB(180, 180, 200),
                            Position = UDim2.new(0, 2, 0, 2)
                        }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        
                        Utility:TweenObject(toggleFrame, {
                            BackgroundColor3 = Color3.fromRGB(70, 70, 85)
                        }, 0.2)
                    end
                    
                    callback(toggled)
                end)
                
                toggleElement.MouseEnter:Connect(function()
                    Utility:TweenObject(toggleElement, {
                        BackgroundTransparency = 0.3
                    }, 0.2)
                    
                    if nTip and nTip ~= "" then
                        tooltip = Kavo:CreateTooltip(nTip, UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20), game.CoreGui)
                    end
                end)
                
                toggleElement.MouseLeave:Connect(function()
                    Utility:TweenObject(toggleElement, {
                        BackgroundTransparency = 0.5
                    }, 0.2)
                    
                    if tooltip then
                        tooltip:Destroy()
                        tooltip = nil
                    end
                end)
                
                toggleElement.MouseMoved:Connect(function()
                    if tooltip then
                        tooltip:MoveTo(UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20))
                    end
                end)
                
                updateSectionFrame()
                
                local TogFunction = {}
                
                function TogFunction:SetState(state)
                    toggled = state
                    
                    if toggled then
                        toggleCircle.BackgroundColor3 = theme.SuccessColor
                        toggleCircle.Position = UDim2.new(1, -18, 0, 2)
                        toggleFrame.BackgroundColor3 = Color3.fromRGB(
                            theme.SuccessColor.R * 255 * 0.3,
                            theme.SuccessColor.G * 255 * 0.3,
                            theme.SuccessColor.B * 255 * 0.3
                        )
                    else
                        toggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
                        toggleCircle.Position = UDim2.new(0, 2, 0, 2)
                        toggleFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
                    end
                    
                    callback(toggled)
                end
                
                function TogFunction:GetState()
                    return toggled
                end
                
                return TogFunction
            end
            
            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, default, callback)
                slidInf = slidInf or "滑块"
                slidTip = slidTip or "调整数值"
                maxvalue = maxvalue or 100
                minvalue = minvalue or 0
                default = default or minvalue
                callback = callback or function() end
                
                local sliderElement = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local sliderName = Instance.new("TextLabel")
                local sliderValue = Instance.new("TextLabel")
                local sliderBar = Instance.new("Frame")
                local sliderFill = Instance.new("Frame")
                local sliderHandle = Instance.new("Frame")
                local tooltip = nil
                
                sliderElement.Name = "sliderElement"
                sliderElement.Parent = sectionInners
                sliderElement.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                sliderElement.BackgroundTransparency = 0.5
                sliderElement.Size = UDim2.new(1, 0, 0, 80)
                sliderElement.ZIndex = 105
                
                UICorner.CornerRadius = UDim.new(0, 10)
                UICorner.Parent = sliderElement
                
                sliderName.Name = "sliderName"
                sliderName.Parent = sliderElement
                sliderName.BackgroundTransparency = 1
                sliderName.Position = UDim2.new(0, 15, 0, 15)
                sliderName.Size = UDim2.new(0.7, -20, 0, 20)
                sliderName.Font = Enum.Font.GothamSemibold
                sliderName.Text = slidInf
                sliderName.TextColor3 = theme.TextColor
                sliderName.TextSize = 15
                sliderName.TextXAlignment = Enum.TextXAlignment.Left
                sliderName.ZIndex = 106
                
                sliderValue.Name = "sliderValue"
                sliderValue.Parent = sliderElement
                sliderValue.BackgroundTransparency = 1
                sliderValue.Position = UDim2.new(0.7, 0, 0, 15)
                sliderValue.Size = UDim2.new(0.3, -15, 0, 20)
                sliderValue.Font = Enum.Font.GothamSemibold
                sliderValue.Text = tostring(default)
                sliderValue.TextColor3 = theme.SchemeColor
                sliderValue.TextSize = 15
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                sliderValue.ZIndex = 106
                
                sliderBar.Name = "sliderBar"
                sliderBar.Parent = sliderElement
                sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
                sliderBar.Position = UDim2.new(0, 15, 0, 50)
                sliderBar.Size = UDim2.new(1, -30, 0, 8)
                sliderBar.ZIndex = 106
                
                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(1, 0)
                barCorner.Parent = sliderBar
                
                sliderFill.Name = "sliderFill"
                sliderFill.Parent = sliderBar
                sliderFill.BackgroundColor3 = theme.SchemeColor
                sliderFill.Size = UDim2.new((default - minvalue) / (maxvalue - minvalue), 0, 1, 0)
                sliderFill.ZIndex = 107
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = sliderFill
                
                sliderHandle.Name = "sliderHandle"
                sliderHandle.Parent = sliderBar
                sliderHandle.BackgroundColor3 = Color3.new(1, 1, 1)
                sliderHandle.Position = UDim2.new((default - minvalue) / (maxvalue - minvalue), -8, 0, -4)
                sliderHandle.Size = UDim2.new(0, 16, 0, 16)
                sliderHandle.ZIndex = 108
                
                local handleCorner = Instance.new("UICorner")
                handleCorner.CornerRadius = UDim.new(1, 0)
                handleCorner.Parent = sliderHandle
                
                local handleStroke = Instance.new("UIStroke")
                handleStroke.Color = theme.SchemeColor
                handleStroke.Thickness = 2
                handleStroke.Parent = sliderHandle
                
                local dragging = false
                local currentValue = default
                
                local function updateSlider(x)
                    local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                    local percentage = relativeX / sliderBar.AbsoluteSize.X
                    currentValue = math.floor(minvalue + (maxvalue - minvalue) * percentage)
                    
                    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(percentage, -8, 0, -4)
                    sliderValue.Text = tostring(currentValue)
                    callback(currentValue)
                end
                
                sliderBar.MouseButton1Down:Connect(function()
                    dragging = true
                    Utility:PlaySound(4047132169, 0.1)
                    updateSlider(mouse.X)
                end)
                
                sliderBar.MouseButton1Up:Connect(function()
                    dragging = false
                    Utility:PlaySound(4047132467, 0.1)
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
                
                sliderElement.MouseEnter:Connect(function()
                    Utility:TweenObject(sliderElement, {
                        BackgroundTransparency = 0.3
                    }, 0.2)
                    
                    if slidTip and slidTip ~= "" then
                        tooltip = Kavo:CreateTooltip(slidTip, UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20), game.CoreGui)
                    end
                end)
                
                sliderElement.MouseLeave:Connect(function()
                    Utility:TweenObject(sliderElement, {
                        BackgroundTransparency = 0.5
                    }, 0.2)
                    
                    if tooltip then
                        tooltip:Destroy()
                        tooltip = nil
                    end
                end)
                
                sliderElement.MouseMoved:Connect(function()
                    if tooltip then
                        tooltip:MoveTo(UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20))
                    end
                end)
                
                updateSectionFrame()
                
                local SliderFunction = {}
                
                function SliderFunction:SetValue(value)
                    value = math.clamp(value, minvalue, maxvalue)
                    currentValue = value
                    local percentage = (value - minvalue) / (maxvalue - minvalue)
                    
                    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(percentage, -8, 0, -4)
                    sliderValue.Text = tostring(value)
                    callback(value)
                end
                
                function SliderFunction:GetValue()
                    return currentValue
                end
                
                return SliderFunction
            end
            
            function Elements:NewDropdown(dropname, dropinf, list, default, callback)
                dropname = dropname or "下拉框"
                dropinf = dropinf or "选择选项"
                list = list or {"选项1", "选项2", "选项3"}
                default = default or list[1]
                callback = callback or function() end
                
                local opened = false
                local selected = default
                
                local dropElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local dropName = Instance.new("TextLabel")
                local dropValue = Instance.new("TextLabel")
                local dropArrow = Instance.new("ImageLabel")
                local dropOptions = Instance.new("Frame")
                local optionsList = Instance.new("UIListLayout")
                local tooltip = nil
                
                dropElement.Name = "dropElement"
                dropElement.Parent = sectionInners
                dropElement.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                dropElement.BackgroundTransparency = 0.5
                dropElement.Size = UDim2.new(1, 0, 0, 50)
                dropElement.AutoButtonColor = false
                dropElement.Text = ""
                dropElement.ZIndex = 105
                dropElement.ClipsDescendants = true
                
                UICorner.CornerRadius = UDim.new(0, 10)
                UICorner.Parent = dropElement
                
                dropName.Name = "dropName"
                dropName.Parent = dropElement
                dropName.BackgroundTransparency = 1
                dropName.Position = UDim2.new(0, 15, 0, 0)
                dropName.Size = UDim2.new(0.6, -20, 1, 0)
                dropName.Font = Enum.Font.GothamSemibold
                dropName.Text = dropname
                dropName.TextColor3 = theme.TextColor
                dropName.TextSize = 15
                dropName.TextXAlignment = Enum.TextXAlignment.Left
                dropName.ZIndex = 106
                
                dropValue.Name = "dropValue"
                dropValue.Parent = dropElement
                dropValue.BackgroundTransparency = 1
                dropValue.Position = UDim2.new(0.6, 0, 0, 0)
                dropValue.Size = UDim2.new(0.4, -40, 1, 0)
                dropValue.Font = Enum.Font.Gotham
                dropValue.Text = selected
                dropValue.TextColor3 = theme.SchemeColor
                dropValue.TextSize = 14
                dropValue.TextXAlignment = Enum.TextXAlignment.Right
                dropValue.ZIndex = 106
                
                dropArrow.Name = "dropArrow"
                dropArrow.Parent = dropElement
                dropArrow.BackgroundTransparency = 1
                dropArrow.Position = UDim2.new(1, -30, 0, 15)
                dropArrow.Size = UDim2.new(0, 20, 0, 20)
                dropArrow.Image = "rbxassetid://3926305904"
                dropArrow.ImageRectOffset = Vector2.new(884, 284)
                dropArrow.ImageRectSize = Vector2.new(36, 36)
                dropArrow.ImageColor3 = theme.SchemeColor
                dropArrow.ZIndex = 106
                
                dropOptions.Name = "dropOptions"
                dropOptions.Parent = dropElement
                dropOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                dropOptions.BackgroundTransparency = 0.3
                dropOptions.Position = UDim2.new(0, 10, 1, 5)
                dropOptions.Size = UDim2.new(1, -20, 0, 0)
                dropOptions.Visible = false
                dropOptions.ZIndex = 107
                
                local optionsCorner = Instance.new("UICorner")
                optionsCorner.CornerRadius = UDim.new(0, 8)
                optionsCorner.Parent = dropOptions
                
                optionsList.Name = "optionsList"
                optionsList.Parent = dropOptions
                optionsList.SortOrder = Enum.SortOrder.LayoutOrder
                
                local function createOptions()
                    dropOptions:ClearAllChildren()
                    optionsList.Parent = dropOptions
                    
                    for i, option in pairs(list) do
                        local optionBtn = Instance.new("TextButton")
                        local optionCorner = Instance.new("UICorner")
                        
                        optionBtn.Name = "option_"..i
                        optionBtn.Parent = dropOptions
                        optionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                        optionBtn.BackgroundTransparency = 0.5
                        optionBtn.Size = UDim2.new(1, 0, 0, 35)
                        optionBtn.AutoButtonColor = false
                        optionBtn.Text = ""
                        optionBtn.ZIndex = 108
                        
                        optionCorner.CornerRadius = UDim.new(0, 6)
                        optionCorner.Parent = optionBtn
                        
                        local optionText = Instance.new("TextLabel")
                        optionText.Name = "optionText"
                        optionText.Parent = optionBtn
                        optionText.BackgroundTransparency = 1
                        optionText.Position = UDim2.new(0, 10, 0, 0)
                        optionText.Size = UDim2.new(1, -20, 1, 0)
                        optionText.Font = Enum.Font.Gotham
                        optionText.Text = option
                        optionText.TextColor3 = option == selected and theme.SchemeColor or theme.TextColor
                        optionText.TextSize = 14
                        optionText.TextXAlignment = Enum.TextXAlignment.Left
                        optionText.ZIndex = 109
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            selected = option
                            dropValue.Text = option
                            Utility:PlaySound(4047132169, 0.1)
                            callback(option)
                            
                            for _, child in pairs(dropOptions:GetChildren()) do
                                if child:IsA("TextButton") and child:FindFirstChild("optionText") then
                                    child.optionText.TextColor3 = child.optionText.Text == option and theme.SchemeColor or theme.TextColor
                                end
                            end
                            
                            opened = false
                            dropOptions.Visible = false
                            dropElement.Size = UDim2.new(1, 0, 0, 50)
                            updateSectionFrame()
                            
                            Utility:TweenObject(dropArrow, {
                                Rotation = 0
                            }, 0.2)
                        end)
                        
                        optionBtn.MouseEnter:Connect(function()
                            Utility:TweenObject(optionBtn, {
                                BackgroundTransparency = 0.3
                            }, 0.2)
                        end)
                        
                        optionBtn.MouseLeave:Connect(function()
                            Utility:TweenObject(optionBtn, {
                                BackgroundTransparency = 0.5
                            }, 0.2)
                        end)
                    end
                end
                
                createOptions()
                
                dropElement.MouseButton1Click:Connect(function()
                    opened = not opened
                    
                    if opened then
                        local optionCount = #list
                        local optionHeight = math.min(optionCount * 35 + 10, 200)
                        
                        dropOptions.Visible = true
                        dropOptions.Size = UDim2.new(1, -20, 0, optionHeight)
                        dropElement.Size = UDim2.new(1, 0, 0, 55 + optionHeight)
                        
                        Utility:TweenObject(dropArrow, {
                            Rotation = 180
                        }, 0.2)
                        Utility:PlaySound(4047132169, 0.1)
                    else
                        dropOptions.Visible = false
                        dropElement.Size = UDim2.new(1, 0, 0, 50)
                        
                        Utility:TweenObject(dropArrow, {
                            Rotation = 0
                        }, 0.2)
                        Utility:PlaySound(4047132467, 0.1)
                    end
                    
                    updateSectionFrame()
                end)
                
                dropElement.MouseEnter:Connect(function()
                    Utility:TweenObject(dropElement, {
                        BackgroundTransparency = 0.3
                    }, 0.2)
                    
                    if dropinf and dropinf ~= "" then
                        tooltip = Kavo:CreateTooltip(dropinf, UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20), game.CoreGui)
                    end
                end)
                
                dropElement.MouseLeave:Connect(function()
                    Utility:TweenObject(dropElement, {
                        BackgroundTransparency = 0.5
                    }, 0.2)
                    
                    if tooltip then
                        tooltip:Destroy()
                        tooltip = nil
                    end
                end)
                
                dropElement.MouseMoved:Connect(function()
                    if tooltip then
                        tooltip:MoveTo(UDim2.new(0, mouse.X + 20, 0, mouse.Y + 20))
                    end
                end)
                
                updateSectionFrame()
                
                local DropFunction = {}
                
                function DropFunction:Refresh(newList)
                    list = newList or list
                    selected = list[1] or ""
                    dropValue.Text = selected
                    createOptions()
                    
                    if opened then
                        opened = false
                        dropOptions.Visible = false
                        dropElement.Size = UDim2.new(1, 0, 0, 50)
                        Utility:TweenObject(dropArrow, {
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
                        dropValue.Text = value
                        callback(value)
                    end
                end
                
                return DropFunction
            end
            
            function Elements:NewLabel(title, description)
                title = title or "标签"
                description = description or ""
                
                local labelElement = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local labelTitle = Instance.new("TextLabel")
                local labelDesc = Instance.new("TextLabel")
                
                labelElement.Name = "labelElement"
                labelElement.Parent = sectionInners
                labelElement.BackgroundColor3 = theme.SchemeColor
                labelElement.BackgroundTransparency = 0.8
                labelElement.Size = UDim2.new(1, 0, 0, description == "" and 50 or 70)
                labelElement.ZIndex = 105
                
                UICorner.CornerRadius = UDim.new(0, 10)
                UICorner.Parent = labelElement
                
                labelTitle.Name = "labelTitle"
                labelTitle.Parent = labelElement
                labelTitle.BackgroundTransparency = 1
                labelTitle.Position = UDim2.new(0, 15, 0, 10)
                labelTitle.Size = UDim2.new(1, -30, 0, 25)
                labelTitle.Font = Enum.Font.GothamBold
                labelTitle.Text = title
                labelTitle.TextColor3 = theme.TextColor
                labelTitle.TextSize = 16
                labelTitle.TextXAlignment = Enum.TextXAlignment.Left
                labelTitle.ZIndex = 106
                
                if description ~= "" then
                    labelDesc.Name = "labelDesc"
                    labelDesc.Parent = labelElement
                    labelDesc.BackgroundTransparency = 1
                    labelDesc.Position = UDim2.new(0, 15, 0, 40)
                    labelDesc.Size = UDim2.new(1, -30, 0, 25)
                    labelDesc.Font = Enum.Font.Gotham
                    labelDesc.Text = description
                    labelDesc.TextColor3 = Color3.fromRGB(200, 200, 220)
                    labelDesc.TextSize = 13
                    labelDesc.TextXAlignment = Enum.TextXAlignment.Left
                    labelDesc.TextWrapped = true
                    labelDesc.ZIndex = 106
                end
                
                updateSectionFrame()
                
                local LabelFunction = {}
                
                function LabelFunction:UpdateLabel(newTitle, newDesc)
                    if newTitle then
                        labelTitle.Text = newTitle
                    end
                    if newDesc and labelDesc then
                        labelDesc.Text = newDesc
                    end
                end
                
                return LabelFunction
            end
            
            function Elements:NewColorPicker(title, default, callback)
                title = title or "颜色选择器"
                default = default or Color3.new(1, 1, 1)
                callback = callback or function() end
                
                local colorElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local colorName = Instance.new("TextLabel")
                local colorPreview = Instance.new("Frame")
                local colorPicker = Instance.new("Frame")
                local colorHue = Instance.new("ImageButton")
                local colorSatVal = Instance.new("ImageButton")
                local colorSelector = Instance.new("Frame")
                local hueSelector = Instance.new("Frame")
                local colorValue = Instance.new("TextLabel")
                
                colorElement.Name = "colorElement"
                colorElement.Parent = sectionInners
                colorElement.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                colorElement.BackgroundTransparency = 0.5
                colorElement.Size = UDim2.new(1, 0, 0, 50)
                colorElement.AutoButtonColor = false
                colorElement.Text = ""
                colorElement.ZIndex = 105
                colorElement.ClipsDescendants = true
                
                UICorner.CornerRadius = UDim.new(0, 10)
                UICorner.Parent = colorElement
                
                colorName.Name = "colorName"
                colorName.Parent = colorElement
                colorName.BackgroundTransparency = 1
                colorName.Position = UDim2.new(0, 15, 0, 0)
                colorName.Size = UDim2.new(0.7, -20, 1, 0)
                colorName.Font = Enum.Font.GothamSemibold
                colorName.Text = title
                colorName.TextColor3 = theme.TextColor
                colorName.TextSize = 15
                colorName.TextXAlignment = Enum.TextXAlignment.Left
                colorName.ZIndex = 106
                
                colorPreview.Name = "colorPreview"
                colorPreview.Parent = colorElement
                colorPreview.BackgroundColor3 = default
                colorPreview.Position = UDim2.new(0.7, 0, 0, 10)
                colorPreview.Size = UDim2.new(0, 30, 0, 30)
                colorPreview.ZIndex = 106
                
                local previewCorner = Instance.new("UICorner")
                previewCorner.CornerRadius = UDim.new(0, 6)
                previewCorner.Parent = colorPreview
                
                local previewStroke = Instance.new("UIStroke")
                previewStroke.Color = Color3.new(1, 1, 1)
                previewStroke.Thickness = 2
                previewStroke.Parent = colorPreview
                
                colorPicker.Name = "colorPicker"
                colorPicker.Parent = colorElement
                colorPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                colorPicker.BackgroundTransparency = 0.3
                colorPicker.Position = UDim2.new(0, 10, 1, 5)
                colorPicker.Size = UDim2.new(1, -20, 0, 150)
                colorPicker.Visible = false
                colorPicker.ZIndex = 107
                
                local pickerCorner = Instance.new("UICorner")
                pickerCorner.CornerRadius = UDim.new(0, 8)
                pickerCorner.Parent = colorPicker
                
                colorHue.Name = "colorHue"
                colorHue.Parent = colorPicker
                colorHue.BackgroundColor3 = Color3.new(1, 1, 1)
                colorHue.Position = UDim2.new(0, 10, 0, 10)
                colorHue.Size = UDim2.new(0, 20, 0, 130)
                colorHue.AutoButtonColor = false
                colorHue.Image = "rbxassetid://2615689005"
                colorHue.ZIndex = 108
                
                local hueCorner = Instance.new("UICorner")
                hueCorner.CornerRadius = UDim.new(0, 4)
                hueCorner.Parent = colorHue
                
                hueSelector.Name = "hueSelector"
                hueSelector.Parent = colorHue
                hueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                hueSelector.BorderSizePixel = 2
                hueSelector.BorderColor3 = Color3.new(0, 0, 0)
                hueSelector.Size = UDim2.new(1, 4, 0, 4)
                hueSelector.Position = UDim2.new(0, -2, 0, 0)
                hueSelector.ZIndex = 109
                
                local selectorCorner = Instance.new("UICorner")
                selectorCorner.CornerRadius = UDim.new(1, 0)
                selectorCorner.Parent = hueSelector
                
                colorSatVal.Name = "colorSatVal"
                colorSatVal.Parent = colorPicker
                colorSatVal.BackgroundColor3 = Color3.new(1, 1, 1)
                colorSatVal.Position = UDim2.new(0, 40, 0, 10)
                colorSatVal.Size = UDim2.new(0, 130, 0, 130)
                colorSatVal.AutoButtonColor = false
                colorSatVal.Image = "rbxassetid://2615692420"
                colorSatVal.ZIndex = 108
                
                local satValCorner = Instance.new("UICorner")
                satValCorner.CornerRadius = UDim.new(0, 4)
                satValCorner.Parent = colorSatVal
                
                colorSelector.Name = "colorSelector"
                colorSelector.Parent = colorSatVal
                colorSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                colorSelector.BorderSizePixel = 2
                colorSelector.BorderColor3 = Color3.new(0, 0, 0)
                colorSelector.Size = UDim2.new(0, 8, 0, 8)
                colorSelector.Position = UDim2.new(0, 0, 0, 0)
                colorSelector.ZIndex = 109
                
                local colorSelectorCorner = Instance.new("UICorner")
                colorSelectorCorner.CornerRadius = UDim.new(1, 0)
                colorSelectorCorner.Parent = colorSelector
                
                colorValue.Name = "colorValue"
                colorValue.Parent = colorPicker
                colorValue.BackgroundTransparency = 1
                colorValue.Position = UDim2.new(0, 180, 0, 10)
                colorValue.Size = UDim2.new(0, 90, 0, 20)
                colorValue.Font = Enum.Font.GothamSemibold
                colorValue.Text = string.format("#%02X%02X%02X", math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255))
                colorValue.TextColor3 = theme.TextColor
                colorValue.TextSize = 14
                colorValue.TextXAlignment = Enum.TextXAlignment.Left
                colorValue.ZIndex = 108
                
                local opened = false
                local currentColor = default
                local hue = 0
                local saturation = 0
                local value = 1
                
                local function updateColor(h, s, v)
                    hue = h
                    saturation = s
                    value = v
                    currentColor = Color3.fromHSV(h, s, v)
                    colorPreview.BackgroundColor3 = currentColor
                    colorValue.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                    callback(currentColor)
                end
                
                local function hexToColor(hex)
                    hex = hex:gsub("#", "")
                    local r = tonumber(hex:sub(1, 2), 16) / 255
                    local g = tonumber(hex:sub(3, 4), 16) / 255
                    local b = tonumber(hex:sub(5, 6), 16) / 255
                    return Color3.new(r, g, b)
                end
                
                colorElement.MouseButton1Click:Connect(function()
                    opened = not opened
                    
                    if opened then
                        colorPicker.Visible = true
                        colorElement.Size = UDim2.new(1, 0, 0, 210)
                        Utility:PlaySound(4047132169, 0.1)
                    else
                        colorPicker.Visible = false
                        colorElement.Size = UDim2.new(1, 0, 0, 50)
                        Utility:PlaySound(4047132467, 0.1)
                    end
                    
                    updateSectionFrame()
                end)
                
                colorElement.MouseEnter:Connect(function()
                    Utility:TweenObject(colorElement, {
                        BackgroundTransparency = 0.3
                    }, 0.2)
                end)
                
                colorElement.MouseLeave:Connect(function()
                    Utility:TweenObject(colorElement, {
                        BackgroundTransparency = 0.5
                    }, 0.2)
                end)
                
                local function onHueInput(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local y = math.clamp((input.Position.Y - colorHue.AbsolutePosition.Y) / colorHue.AbsoluteSize.Y, 0, 1)
                        hue = 1 - y
                        hueSelector.Position = UDim2.new(0, -2, y, -2)
                        updateColor(hue, saturation, value)
                    end
                end
                
                local function onSatValInput(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local x = math.clamp((input.Position.X - colorSatVal.AbsolutePosition.X) / colorSatVal.AbsoluteSize.X, 0, 1)
                        local y = math.clamp((input.Position.Y - colorSatVal.AbsolutePosition.Y) / colorSatVal.AbsoluteSize.Y, 0, 1)
                        saturation = x
                        value = 1 - y
                        colorSelector.Position = UDim2.new(x, -4, y, -4)
                        updateColor(hue, saturation, value)
                    end
                end
                
                colorHue.InputBegan:Connect(onHueInput)
                colorSatVal.InputBegan:Connect(onSatValInput)
                
                input.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if input.UserInputState == Enum.UserInputState.Change then
                            local mousePos = input.Position
                            
                            if colorHue:IsActive() then
                                local y = math.clamp((mousePos.Y - colorHue.AbsolutePosition.Y) / colorHue.AbsoluteSize.Y, 0, 1)
                                hue = 1 - y
                                hueSelector.Position = UDim2.new(0, -2, y, -2)
                                updateColor(hue, saturation, value)
                            end
                            
                            if colorSatVal:IsActive() then
                                local x = math.clamp((mousePos.X - colorSatVal.AbsolutePosition.X) / colorSatVal.AbsoluteSize.X, 0, 1)
                                local y = math.clamp((mousePos.Y - colorSatVal.AbsolutePosition.Y) / colorSatVal.AbsoluteSize.Y, 0, 1)
                                saturation = x
                                value = 1 - y
                                colorSelector.Position = UDim2.new(x, -4, y, -4)
                                updateColor(hue, saturation, value)
                            end
                        end
                    end
                end)
                
                updateSectionFrame()
                
                local ColorFunction = {}
                
                function ColorFunction:SetColor(color)
                    currentColor = color
                    colorPreview.BackgroundColor3 = color
                    colorValue.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
                    callback(color)
                end
                
                function ColorFunction:GetColor()
                    return currentColor
                end
                
                return ColorFunction
            end
            
            return Elements
        end
        
        return Sections
    end
    
    return Tabs
end

function Kavo:Notification(title, content, duration, image, sound)
    return self:Notify(title, content, duration, image, sound)
end

Kavo:BindToggleKey(Enum.KeyCode.F9)

coroutine.wrap(function()
    wait(2)
    Kavo:Notify("Kavo Ultra UI 已加载", "高级UI界面初始化完成！\n按 F9 键切换界面显示", 5, 3926305904, 4047132169)
end)()

return Kavo