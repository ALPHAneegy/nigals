local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

local visualState = {
    time = 0,
    rotationProgress = 0,
    currentRotationSpeed = 0.8,
    smoothedRotation = 5,
    lines = {
        top = {Size = UDim2.new(0, 3, 0, 40), Position = UDim2.new(0.5, -1.5, 0, 0), Color = Color3.new(0.5, 0.8, 1)},
        bottom = {Size = UDim2.new(0, 3, 0, 40), Position = UDim2.new(0.5, -1.5, 1, -40), Color = Color3.new(0.5, 0.8, 1)},
        left = {Size = UDim2.new(0, 40, 0, 3), Position = UDim2.new(0, 0, 0.5, -1.5), Color = Color3.new(0.5, 0.8, 1)},
        right = {Size = UDim2.new(0, 40, 0, 3), Position = UDim2.new(1, -40, 0.5, -1.5), Color = Color3.new(0.5, 0.8, 1)},
    },
    text = {
        Text = " ",
        Position = UDim2.new(0.5, -75, 0.5, 0),
        Color = Color3.new(0.5, 0.8, 1),
        Font = Enum.Font.SourceSans,
        TextScaled = true,
    }
}

local screenGui
local topLine, bottomLine, leftLine, rightLine
local textLabel

local lineThickness = 2.5
local baseRotationSpeed = 0.8
local pulseSpeed = 2.5
local minLength = 8
local maxLength = 20
local time = 0
local rotationProgress = 0
local currentRotationSpeed = baseRotationSpeed
local spacing = 20

local function createLine(parent, size, position, color)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.ZIndex = 9999999
    frame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(0,0,0)
    stroke.Thickness = 1
    stroke.Parent = frame

    return frame
end

local function createTextLabel(parent, text, position, color, font, scaled)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Position = position
    label.TextColor3 = color
    label.Font = font
    label.TextScaled = scaled
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 150, 0, 30)
    label.ZIndex = 9999999
    label.TextTransparency = 0.5
    label.Parent = parent

    return label
end

local function clearGui()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
    end
end

local function createGui()
    clearGui()

    local uiParent = (gethui and gethui()) or game:GetService("CoreGui")
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimSightGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = uiParent
    screenGui.DisplayOrder = 9999999

    topLine = createLine(screenGui, visualState.lines.top.Size, visualState.lines.top.Position, visualState.lines.top.Color)
    bottomLine = createLine(screenGui, visualState.lines.bottom.Size, visualState.lines.bottom.Position, visualState.lines.bottom.Color)
    leftLine = createLine(screenGui, visualState.lines.left.Size, visualState.lines.left.Position, visualState.lines.left.Color)
    rightLine = createLine(screenGui, visualState.lines.right.Size, visualState.lines.right.Position, visualState.lines.right.Color)

    textLabel = createTextLabel(screenGui, visualState.text.Text, visualState.text.Position, visualState.text.Color, visualState.text.Font, visualState.text.TextScaled)
end

local function saveVisualState()
    visualState.time = time
    visualState.rotationProgress = rotationProgress
    visualState.currentRotationSpeed = currentRotationSpeed

    visualState.lines.top.Size = topLine.Size
    visualState.lines.top.Position = topLine.Position
    visualState.lines.top.Color = topLine.BackgroundColor3

    visualState.lines.bottom.Size = bottomLine.Size
    visualState.lines.bottom.Position = bottomLine.Position
    visualState.lines.bottom.Color = bottomLine.BackgroundColor3

    visualState.lines.left.Size = leftLine.Size
    visualState.lines.left.Position = leftLine.Position
    visualState.lines.left.Color = leftLine.BackgroundColor3

    visualState.lines.right.Size = rightLine.Size
    visualState.lines.right.Position = rightLine.Position
    visualState.lines.right.Color = rightLine.BackgroundColor3

    visualState.text.Text = textLabel.Text
    visualState.text.Position = textLabel.Position
    visualState.text.Color = textLabel.TextColor3
    visualState.text.Font = textLabel.Font
    visualState.text.TextScaled = textLabel.TextScaled
end

local function restoreVisualState()
    if not (topLine and bottomLine and leftLine and rightLine and textLabel) then
        return
    end

    time = visualState.time or 0
    rotationProgress = visualState.rotationProgress or 0
    currentRotationSpeed = visualState.currentRotationSpeed or baseRotationSpeed

    topLine.Size = visualState.lines.top.Size or topLine.Size
    topLine.Position = visualState.lines.top.Position or topLine.Position
    topLine.BackgroundColor3 = visualState.lines.top.Color or topLine.BackgroundColor3

    bottomLine.Size = visualState.lines.bottom.Size or bottomLine.Size
    bottomLine.Position = visualState.lines.bottom.Position or bottomLine.Position
    bottomLine.BackgroundColor3 = visualState.lines.bottom.Color or bottomLine.BackgroundColor3

    leftLine.Size = visualState.lines.left.Size or leftLine.Size
    leftLine.Position = visualState.lines.left.Position or leftLine.Position
    leftLine.BackgroundColor3 = visualState.lines.left.Color or leftLine.BackgroundColor3

    rightLine.Size = visualState.lines.right.Size or rightLine.Size
    rightLine.Position = visualState.lines.right.Position or rightLine.Position
    rightLine.BackgroundColor3 = visualState.lines.right.Color or rightLine.BackgroundColor3

    textLabel.Text = visualState.text.Text or textLabel.Text
    textLabel.Position = visualState.text.Position or textLabel.Position
    textLabel.TextColor3 = visualState.text.Color or textLabel.TextColor3
    textLabel.Font = visualState.text.Font or textLabel.Font
    textLabel.TextScaled = visualState.text.TextScaled or textLabel.TextScaled
end

local function getBlueGradient(t)
    local r = 0.3 + math.sin(t * 0.6) * 0.15
    local g = 0.5 + math.sin(t * 0.6 + 1) * 0.25
    local b = 0.8 + math.sin(t * 0.6 + 2) * 0.2
    return Color3.new(r, g, b)
end

local function calculateRotationSpeed(progress)
    local slowdownStart = 0.6
    local slowdownDuration = 0.35
    local minSlowdownSpeed = 0.3

    if progress >= slowdownStart then
        local slowdownProgress = (progress - slowdownStart) / slowdownDuration
        local easedProgress = slowdownProgress * slowdownProgress
        local slowdownFactor = 1 - (easedProgress * (1 - minSlowdownSpeed))
        return baseRotationSpeed * math.max(slowdownFactor, minSlowdownSpeed)
    else
        return baseRotationSpeed
    end
end

local function smoothPulse(t, speed)
    local rawPulse = math.sin(t * speed) * 0.5 + 0.5
    return rawPulse * rawPulse
end

local function onCharacterAdded(character)
    createGui()
    restoreVisualState()

    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        saveVisualState()
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end

RunService.RenderStepped:Connect(function(deltaTime)
    if not (topLine and bottomLine and leftLine and rightLine and textLabel) then
        return
    end

    time = time + deltaTime

    local mouseX = mouse.X
    local mouseY = mouse.Y

    local pulse = smoothPulse(time, pulseSpeed)
    local currentLength = minLength + (maxLength - minLength) * pulse

    topLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
    bottomLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
    leftLine.Size = UDim2.new(0, currentLength, 0, lineThickness)
    rightLine.Size = UDim2.new(0, currentLength, 0, lineThickness)

    topLine.Position = UDim2.new(0, mouseX - lineThickness / 2, 0, mouseY - spacing - currentLength)
    bottomLine.Position = UDim2.new(0, mouseX - lineThickness / 2, 0, mouseY + spacing)
    leftLine.Position = UDim2.new(0, mouseX - spacing - currentLength, 0, mouseY - lineThickness / 2)
    rightLine.Position = UDim2.new(0, mouseX + spacing, 0, mouseY - lineThickness / 2)

    rotationProgress = (rotationProgress + currentRotationSpeed * deltaTime) % 1
    currentRotationSpeed = calculateRotationSpeed(rotationProgress)

    local targetRotation = rotationProgress * 360
    topLine.Rotation = targetRotation
    bottomLine.Rotation = targetRotation
    leftLine.Rotation = targetRotation
    rightLine.Rotation = targetRotation

    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local screenPos, onScreen = camera:WorldToScreenPoint(rootPart.Position)
        if onScreen then
            textLabel.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - 15)
        end
    end

    local blueColor = Color3.fromRGB(10, 10, 10)

    topLine.BackgroundColor3 = blueColor
    bottomLine.BackgroundColor3 = blueColor
    leftLine.BackgroundColor3 = blueColor
    rightLine.BackgroundColor3 = blueColor
    textLabel.TextColor3 = blueColor
end)
