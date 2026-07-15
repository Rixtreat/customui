-- ========================================================
-- [[ DALEY'S CUSTOM STARFIELD RGB UI WITH FIXED SOCIALS ]]
-- ========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local TargetParent = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")

-- Safely clear previous instances
if TargetParent:FindFirstChild("DaleyStarfieldUI") then
    TargetParent.DaleyStarfieldUI:Destroy()
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaleyStarfieldUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- ==========================================
-- [[ MAIN WINDOW & BORDERS ]] --
-- ==========================================
local WindowFrame = Instance.new("Frame")
WindowFrame.Name = "MainWindow"
WindowFrame.Size = UDim2.new(0, 650, 0, 400)
WindowFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
WindowFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
WindowFrame.BorderSizePixel = 0
WindowFrame.ClipsDescendants = true
WindowFrame.Active = true
WindowFrame.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 12)
WindowCorner.Parent = WindowFrame

-- Dynamic RGB Outline
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness = 2
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = WindowFrame

task.spawn(function()
    local hue = 0
    while task.wait() do
        hue = (hue + 1) % 360
        RGBStroke.Color = Color3.fromHSV(hue / 360, 0.8, 1)
    end
end)

-- ==========================================
-- [[ STARFIELD BACKGROUND ENGINE ]] --
-- ==========================================
local StarContainer = Instance.new("Frame")
StarContainer.Name = "StarContainer"
StarContainer.Size = UDim2.new(1, 0, 1, 0)
StarContainer.BackgroundTransparency = 1
StarContainer.ZIndex = 1
StarContainer.Parent = WindowFrame

local MAX_STARS = 60
local starsList = {}

for i = 1, MAX_STARS do
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3))
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BackgroundTransparency = math.random(2, 7) / 10
    star.BorderSizePixel = 0
    star.ZIndex = 1
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.Parent = StarContainer
    
    table.insert(starsList, {
        Instance = star,
        Speed = math.random(5, 20) / 1000
    })
end

RunService.RenderStepped:Connect(function(deltaTime)
    for _, starData in ipairs(starsList) do
        local star = starData.Instance
        if star and star.Parent then
            local currentX = star.Position.X.Scale
            local nextX = currentX - (starData.Speed * deltaTime)
            star.BackgroundTransparency = math.clamp(star.BackgroundTransparency + (math.random(-1, 1) * 0.05), 0.1, 0.8)
            if nextX <= -0.02 then
                star.Position = UDim2.new(1.02, 0, math.random(), 0)
            else
                star.Position = UDim2.new(nextX, 0, star.Position.Y.Scale, 0)
            end
        end
    end
end)

-- ==========================================
-- [[ HEADER BAR ]] --
-- ==========================================
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 45)
HeaderBar.BackgroundTransparency = 1
HeaderBar.Active = true
HeaderBar.ZIndex = 10   
HeaderBar.Parent = WindowFrame

-- Logo & Title Brand elements explicitly inside the HeaderBar now
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 35, 0, 35)
LogoLabel.Position = UDim2.new(0, 12, 0.5, -17)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "D"
LogoLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
LogoLabel.TextSize = 26
LogoLabel.Font = Enum.Font.LuckiestGuy
LogoLabel.ZIndex = 11
LogoLabel.Parent = HeaderBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 90, 0, 35)
TitleLabel.Position = UDim2.new(0, 48, 0.5, -17)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DALEY SCRIPTS"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 11
TitleLabel.Parent = HeaderBar

-- YouTube Icon placed neatly adjacent to the title header
local YTIcon = Instance.new("ImageLabel")
YTIcon.Name = "YTIcon"
YTIcon.Size = UDim2.new(0, 18, 0, 18)
YTIcon.Position = UDim2.new(0, 142, 0.5, -9)
YTIcon.BackgroundTransparency = 1
YTIcon.Image = "rbxassetid://12411303126"
YTIcon.ImageColor3 = Color3.fromRGB(255, 50, 50)
YTIcon.ZIndex = 11
YTIcon.Parent = HeaderBar

-- Dynamic Right Actions Container
local HeaderRightContent = Instance.new("Frame")
HeaderRightContent.Name = "HeaderRightContent"
HeaderRightContent.Size = UDim2.new(0, 240, 1, 0)
HeaderRightContent.Position = UDim2.new(1, -250, 0, 0)
HeaderRightContent.BackgroundTransparency = 1
HeaderRightContent.ZIndex = 11
HeaderRightContent.Parent = HeaderBar

local HeaderRightLayout = Instance.new("UIListLayout")
HeaderRightLayout.FillDirection = Enum.FillDirection.Horizontal
HeaderRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HeaderRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderRightLayout.Padding = UDim.new(0, 12)
HeaderRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
HeaderRightLayout.Parent = HeaderRightContent

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Size = UDim2.new(0, 65, 0, 30)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.ZIndex = 11
ControlsFrame.LayoutOrder = 2
ControlsFrame.Parent = HeaderRightContent

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(180, 180, 185)
CloseButton.TextSize = 22
CloseButton.Font = Enum.Font.GothamMedium
CloseButton.ZIndex = 12
CloseButton.Parent = ControlsFrame
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0.5, -15)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 185)
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.GothamMedium
MinimizeButton.ZIndex = 12
MinimizeButton.Parent = ControlsFrame

local minimized = false
local originalSize = WindowFrame.Size
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 650, 0, 45) or originalSize
    TweenService:Create(WindowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- Discord Clipboard Action Button
local DiscordButton = Instance.new("TextButton")
DiscordButton.Name = "DiscordButton"
DiscordButton.Size = UDim2.new(0, 105, 0, 26)
DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordButton.Text = "Join Discord"
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextSize = 12
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.ZIndex = 12
DiscordButton.LayoutOrder = 1
DiscordButton.Parent = HeaderRightContent

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 5)
DiscordCorner.Parent = DiscordButton

local copyDebounce = false
DiscordButton.MouseButton1Click:Connect(function()
    if copyDebounce then return end
    copyDebounce = true
    
    local inviteLink = "https://discord.gg/SeNPuUVsZQ"
    
    -- Universal clipboard fallback handler
    if setclipboard then
        setclipboard(inviteLink)
    elseif toclipboard then
        toclipboard(inviteLink)
    elseif Clipboard and Clipboard.set then
        Clipboard.set(inviteLink)
    end
    
    -- Dynamic Confirmation Alert visual feedback loop
    DiscordButton.Text = "Link Copied!"
    TweenService:Create(DiscordButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play() -- Success Green
    
    task.wait(2)
    
    DiscordButton.Text = "Join Discord"
    TweenService:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    copyDebounce = false
end)

-- ==========================================
-- [[ SIDEBAR SYSTEM ]] --
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = WindowFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 4
SidebarLine.Parent = Sidebar

-- Tab List Container Layout
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -16, 1, -25)
TabContainer.Position = UDim2.new(0, 8, 0, 15)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 4
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabContainer

-- ==========================================
-- [[ PAGES SPACE ]] --
-- ==========================================
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -175, 1, -60)
PageContainer.Position = UDim2.new(0, 170, 0, 50)
PageContainer.BackgroundTransparency = 1
PageContainer.ZIndex = 3
PageContainer.Parent = WindowFrame

-- ==========================================
-- [[ TAB ENGINE LOGIC ]] --
-- ==========================================
local activeTab = nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 34)
    TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    TabButton.BackgroundTransparency = 1
    TabButton.BorderSizePixel = 0
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(140, 140, 145)
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.ZIndex = 4
    TabButton.Parent = TabContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = TabButton
    
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 3, 0, 16)
    Accent.Position = UDim2.new(0, 0, 0.5, -8)
    Accent.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Accent.BorderSizePixel = 0
    Accent.BackgroundTransparency = 1
    Accent.ZIndex = 5
    Accent.Parent = TabButton

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ZIndex = 4
    Page.Parent = PageContainer
    
    TabButton.MouseButton1Click:Connect(function()
        if activeTab == TabButton then return end
        
        for _, obj in ipairs(TabContainer:GetChildren()) do
            if obj:IsA("TextButton") then
                TweenService:Create(obj, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(140, 140, 145), BackgroundTransparency = 1}):Play()
                TweenService:Create(obj:FindFirstChildOfClass("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end
        for _, pg in ipairs(PageContainer:GetChildren()) do
            pg.Visible = false
        end
        
        activeTab = TabButton
        Page.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.4}):Play()
        TweenService:Create(Accent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    return Page
end

local MovementPage = CreateTab("Movement")
local WorldPage    = CreateTab("World")
local PlayerPage   = CreateTab("Player")
local CombatPage   = CreateTab("Combat")

-- Default Visual Init
activeTab = TabContainer:FindFirstChild("MovementTab")
if activeTab then
    MovementPage.Visible = true
    activeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    activeTab.BackgroundTransparency = 0.4
    activeTab:FindFirstChildOfClass("Frame").BackgroundTransparency = 0
end

-- ==========================================
-- [[ DRAG ENGINE ]] --
-- ==========================================
local dragToggle, dragStart, startPos
local dragSpeed = 0.08

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(WindowFrame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = position}):Play()
end

HeaderBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = WindowFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
        updateInput(input)
    end
end)

-- ==========================================
-- [[ KEYBOARD TOGGLE ENGINE [K] ]] --
-- ==========================================
local isVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.K then
        isVisible = not isVisible
        local endPos = isVisible and UDim2.new(0.5, -325, 0.5, -200) or UDim2.new(0.5, -325, 1, 50)
        TweenService:Create(WindowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = endPos}):Play()
    end
end)
