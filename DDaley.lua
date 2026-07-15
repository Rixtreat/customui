-- ========================================================
-- [[ DALEY'S CUSTOM STARFIELD RGB UI - FIXED FULL BUILD ]]
-- ========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local TargetParent = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")

if TargetParent:FindFirstChild("DaleyStarfieldUI") then
    TargetParent.DaleyStarfieldUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaleyStarfieldUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- ==========================================
-- [[ MAIN WINDOW ]] --
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
-- [[ STARFIELD ]] --
-- ==========================================
local StarContainer = Instance.new("Frame")
StarContainer.Size = UDim2.new(1, 0, 1, 0)
StarContainer.BackgroundTransparency = 1
StarContainer.ZIndex = 1
StarContainer.Parent = WindowFrame

local starsList = {}
for i = 1, 60 do
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3))
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BackgroundTransparency = math.random(2, 7) / 10
    star.BorderSizePixel = 0
    star.ZIndex = 1
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.Parent = StarContainer
    table.insert(starsList, { Instance = star, Speed = math.random(5, 20) / 1000 })
end

RunService.RenderStepped:Connect(function(dt)
    for _, s in ipairs(starsList) do
        local st = s.Instance
        if st and st.Parent then
            local nx = st.Position.X.Scale - s.Speed * dt
            if nx <= -0.02 then
                st.Position = UDim2.new(1.02, 0, math.random(), 0)
            else
                st.Position = UDim2.new(nx, 0, st.Position.Y.Scale, 0)
            end
        end
    end
end)

-- ==========================================
-- [[ HEADER ]] --
-- ==========================================
local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, 0, 0, 45)
HeaderBar.BackgroundTransparency = 1
HeaderBar.Active = true
HeaderBar.ZIndex = 10
HeaderBar.Parent = WindowFrame

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
TitleLabel.Size = UDim2.new(0, 130, 0, 35)
TitleLabel.Position = UDim2.new(0, 48, 0.5, -17)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DALEY SCRIPTS"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 11
TitleLabel.Parent = HeaderBar

-- Right side controls
local HeaderRight = Instance.new("Frame")
HeaderRight.Size = UDim2.new(0, 240, 1, 0)
HeaderRight.Position = UDim2.new(1, -250, 0, 0)
HeaderRight.BackgroundTransparency = 1
HeaderRight.ZIndex = 11
HeaderRight.Parent = HeaderBar

local HRLayout = Instance.new("UIListLayout")
HRLayout.FillDirection = Enum.FillDirection.Horizontal
HRLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HRLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HRLayout.Padding = UDim.new(0, 12)
HRLayout.SortOrder = Enum.SortOrder.LayoutOrder
HRLayout.Parent = HeaderRight

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(0, 65, 0, 30)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.ZIndex = 11
ControlsFrame.LayoutOrder = 2
ControlsFrame.Parent = HeaderRight

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

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(0, 105, 0, 26)
DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordButton.Text = "Join Discord"
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextSize = 12
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.ZIndex = 12
DiscordButton.LayoutOrder = 1
DiscordButton.Parent = HeaderRight
Instance.new("UICorner", DiscordButton).CornerRadius = UDim.new(0, 5)

local copyDebounce = false
DiscordButton.MouseButton1Click:Connect(function()
    if copyDebounce then return end
    copyDebounce = true
    local link = "https://discord.gg/SeNPuUVsZQ"
    if setclipboard then setclipboard(link)
    elseif toclipboard then toclipboard(link) end
    DiscordButton.Text = "Copied!"
    TweenService:Create(DiscordButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
    task.wait(2)
    DiscordButton.Text = "Join Discord"
    TweenService:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    copyDebounce = false
end)

-- ==========================================
-- [[ SIDEBAR ]] --
-- ==========================================
local Sidebar = Instance.new("Frame")
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

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -175, 1, -60)
PageContainer.Position = UDim2.new(0, 170, 0, 50)
PageContainer.BackgroundTransparency = 1
PageContainer.ZIndex = 3
PageContainer.Parent = WindowFrame

-- ==========================================
-- [[ TAB ENGINE ]] --
-- ==========================================
local activeTab = nil
local firstTab, firstPage = nil, nil

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

    -- *** THE FIX: Page now has UIListLayout + AutomaticCanvasSize ***
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ZIndex = 4
    Page.Parent = PageContainer

    -- Layout so components stack vertically
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    -- Padding so content doesn't hug the top edge
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 8)
    PagePadding.PaddingLeft = UDim.new(0, 4)
    PagePadding.PaddingRight = UDim.new(0, 4)
    PagePadding.Parent = Page

    if not firstTab then firstTab = TabButton; firstPage = Page end

    TabButton.MouseButton1Click:Connect(function()
        if activeTab == TabButton then return end
        for _, obj in ipairs(TabContainer:GetChildren()) do
            if obj:IsA("TextButton") then
                TweenService:Create(obj, TweenInfo.new(0.2), {
                    TextColor3 = Color3.fromRGB(140, 140, 145),
                    BackgroundTransparency = 1
                }):Play()
                local acc = obj:FindFirstChildOfClass("Frame")
                if acc then
                    TweenService:Create(acc, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end
            end
        end
        for _, pg in ipairs(PageContainer:GetChildren()) do
            pg.Visible = false
        end
        activeTab = TabButton
        Page.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.4
        }):Play()
        TweenService:Create(Accent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)

    return Page
end

-- ==========================================
-- [[ COMPONENT BUILDERS ]] --
-- ==========================================
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -8, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 225)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Box = Instance.new("TextButton")
    Box.Size = UDim2.new(0, 45, 0, 22)
    Box.Position = UDim2.new(1, -57, 0.5, -11)
    Box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Box.Text = ""
    Box.BorderSizePixel = 0
    Box.ZIndex = 6
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 11)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(0, 3, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(150, 150, 155)
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 7
    Indicator.Parent = Box
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 8)

    local state = false
    Box.MouseButton1Click:Connect(function()
        state = not state
        local targetPos   = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBG    = state and Color3.fromRGB(255, 50, 50)  or Color3.fromRGB(35, 35, 40)
        local targetIndBG = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 155)
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetIndBG}):Play()
        TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = targetBG}):Play()
        if callback then callback(state) end
    end)
end

local function AddSlider(parent, text, min, max, default, increment, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -8, 0, 52)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 22)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 225)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -12, 0, 22)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = 6
    ValueLabel.Parent = Frame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -24, 0, 6)
    SliderBar.Position = UDim2.new(0, 12, 0, 36)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SliderBar.Text = ""
    SliderBar.BorderSizePixel = 0
    SliderBar.ZIndex = 6
    SliderBar.Parent = Frame
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 3)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 7
    Fill.Parent = SliderBar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

    local dragging = false

    local function update(inputX)
        local pct = math.clamp((inputX - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local raw = min + pct * (max - min)
        local val = math.clamp(math.round(raw / increment) * increment, min, max)
        Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        ValueLabel.Text = increment < 1 and string.format("%.1f", val) or tostring(math.round(val))
        if callback then callback(val) end
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -8, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 5
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(40, 40, 50)

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34, 34, 44)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

local function AddTextBox(parent, placeholder, callback)
    local TB = Instance.new("TextBox")
    TB.Size = UDim2.new(1, -8, 0, 38)
    TB.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    TB.PlaceholderText = placeholder
    TB.Text = ""
    TB.TextColor3 = Color3.fromRGB(255, 255, 255)
    TB.PlaceholderColor3 = Color3.fromRGB(100, 100, 105)
    TB.TextSize = 13
    TB.Font = Enum.Font.GothamMedium
    TB.BorderSizePixel = 0
    TB.ZIndex = 5
    TB.ClearTextOnFocus = false
    TB.Parent = parent
    Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", TB)
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(35, 35, 40)

    TB.Focused:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(255, 50, 50)}):Play()
    end)
    TB.FocusLost:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 40)}):Play()
        if callback then callback(TB.Text) end
    end)
end

local function AddDropdown(parent, text, list, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -8, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.ClipsDescendants = false
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 225)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 140, 0, 26)
    MainBtn.Position = UDim2.new(1, -152, 0.5, -13)
    MainBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    MainBtn.Text = list[1] or "Select..."
    MainBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
    MainBtn.TextSize = 12
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.BorderSizePixel = 0
    MainBtn.ZIndex = 7
    MainBtn.Parent = Frame
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)

    local ListHolder = Instance.new("Frame")
    ListHolder.Size = UDim2.new(1, 0, 0, #list * 28)
    ListHolder.Position = UDim2.new(0, 0, 1, 4)
    ListHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    ListHolder.BorderSizePixel = 0
    ListHolder.Visible = false
    ListHolder.ZIndex = 20
    ListHolder.Parent = MainBtn
    Instance.new("UICorner", ListHolder).CornerRadius = UDim.new(0, 6)
    local DropLayout = Instance.new("UIListLayout", ListHolder)
    DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local open = false
    MainBtn.MouseButton1Click:Connect(function()
        open = not open
        ListHolder.Visible = open
    end)

    for i, item in ipairs(list) do
        local Opt = Instance.new("TextButton")
        Opt.Size = UDim2.new(1, 0, 0, 28)
        Opt.BackgroundTransparency = 1
        Opt.Text = item
        Opt.TextColor3 = Color3.fromRGB(180, 180, 185)
        Opt.TextSize = 12
        Opt.Font = Enum.Font.GothamMedium
        Opt.ZIndex = 21
        Opt.Parent = ListHolder
        Opt.MouseButton1Click:Connect(function()
            open = false
            ListHolder.Visible = false
            MainBtn.Text = item
            if callback then callback(item) end
        end)
    end
end

local function AddLabel(parent, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -8, 0, 24)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(140, 140, 150)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextWrapped = true
    Lbl.ZIndex = 5
    Lbl.Parent = parent
    return {
        Set = function(_, newText) Lbl.Text = newText end
    }
end

local function AddSection(parent, text)
    local Sec = Instance.new("TextLabel")
    Sec.Size = UDim2.new(1, -8, 0, 20)
    Sec.BackgroundTransparency = 1
    Sec.Text = "— " .. text .. " —"
    Sec.TextColor3 = Color3.fromRGB(255, 50, 50)
    Sec.TextSize = 11
    Sec.Font = Enum.Font.GothamBold
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.ZIndex = 5
    Sec.Parent = parent
end

-- ==========================================
-- [[ DRAG ENGINE ]] --
-- ==========================================
local dragToggle, dragStart, dragStartPos
HeaderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        dragStartPos = WindowFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
        local delta = input.Position - dragStart
        WindowFrame.Position = UDim2.new(
            dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ==========================================
-- [[ K KEY TOGGLE ]] --
-- ==========================================
local isVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        isVisible = not isVisible
        local endPos = isVisible
            and UDim2.new(0.5, -325, 0.5, -200)
            or  UDim2.new(0.5, -325, 1, 50)
        TweenService:Create(WindowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = endPos}):Play()
    end
end)

-- ==========================================
-- [[ AUTO ACTIVATE FIRST TAB ]] --
-- ==========================================
task.defer(function()
    if firstTab and firstPage then
        activeTab = firstTab
        firstPage.Visible = true
        firstTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        firstTab.BackgroundTransparency = 0.4
        local acc = firstTab:FindFirstChildOfClass("Frame")
        if acc then acc.BackgroundTransparency = 0 end
    end
end)

-- ==========================================
-- [[ PUBLIC API ]] --
-- ==========================================
return {
    ScreenGui    = ScreenGui,
    CreateTab    = CreateTab,
    AddToggle    = AddToggle,
    AddSlider    = AddSlider,
    AddButton    = AddButton,
    AddTextBox   = AddTextBox,
    AddDropdown  = AddDropdown,
    AddLabel     = AddLabel,
    AddSection   = AddSection,
}
