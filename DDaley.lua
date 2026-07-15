-- =========================================================================
-- [[ DALEY SCRIPTS - FULL SUITE ]] -- FIXED (complete, no truncation)
-- =========================================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

local TargetParent = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("DaleyStarfieldUI") then
    TargetParent.DaleyStarfieldUI:Destroy()
end

-- ==========================================
-- [[ CONFIG STATE ]] --
-- ==========================================
local Config = {
    SpeedMode        = false,
    SpeedValue       = 16,
    Flying           = false,
    FlySpeed         = 50,
    Noclip           = false,
    InfiniteJump     = false,
    ClickTPEnabled   = false,
    SavedCoordinates = Vector3.new(0, 0, 0),
    LastScannedName  = "",
    _scanIndex       = 0,
    AimlockActive    = false,
    AimlockKey       = Enum.KeyCode.Q,
    Smoothing        = 0.2,
    AimTarget        = "HumanoidRootPart",
    SilentAim        = false,
    ESPEnabled       = false,
    ChamsEnabled     = false,
    AutoFarmEnabled  = false,
    AutoFarmTarget   = "",
    AutoFarmDelay    = 0.1,
    AntiAFK          = true,
}

local LockedTarget      = nil
local IsCurrentlyLocked = false

-- ==========================================
-- [[ UTILITY ]] --
-- ==========================================
local function GetHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetPlayerChars()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then t[p.Character] = true end
    end
    return t
end

local function GetBodyPart(char, choice)
    if not char then return nil end
    if choice == "Head"  then return char:FindFirstChild("Head") end
    if choice == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end
    if choice == "Leg" then
        return char:FindFirstChild("LeftLeg")
            or char:FindFirstChild("RightLeg")
            or char:FindFirstChild("LeftUpperLeg")
            or char:FindFirstChild("RightUpperLeg")
    end
    if choice == "Arm" then
        return char:FindFirstChild("LeftArm")
            or char:FindFirstChild("RightArm")
            or char:FindFirstChild("LeftUpperArm")
            or char:FindFirstChild("RightUpperArm")
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local closest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            local part = GetBodyPart(p.Character, Config.AimTarget)
                      or p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mp   = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                    if dist < shortest then shortest = dist; closest = p end
                end
            end
        end
    end
    return closest
end

-- ==========================================
-- [[ SCREEN GUI ]] --
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DaleyStarfieldUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = TargetParent

-- ==========================================
-- [[ MAIN WINDOW ]] --
-- ==========================================
local WindowFrame = Instance.new("Frame")
WindowFrame.Name             = "MainWindow"
WindowFrame.Size             = UDim2.new(0, 650, 0, 420)
WindowFrame.Position         = UDim2.new(0.5, -325, 0.5, -210)
WindowFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
WindowFrame.BorderSizePixel  = 0
WindowFrame.ClipsDescendants = true
WindowFrame.Active           = true
WindowFrame.Parent           = ScreenGui
Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 12)

local RGBStroke = Instance.new("UIStroke")
RGBStroke.Thickness      = 2
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent         = WindowFrame

task.spawn(function()
    local hue = 0
    while task.wait() do
        hue = (hue + 1) % 360
        RGBStroke.Color = Color3.fromHSV(hue / 360, 0.85, 1)
    end
end)

-- ==========================================
-- [[ STARFIELD ]] --
-- ==========================================
local StarContainer = Instance.new("Frame")
StarContainer.Size                   = UDim2.new(1, 0, 1, 0)
StarContainer.BackgroundTransparency = 1
StarContainer.ZIndex                 = 1
StarContainer.Parent                 = WindowFrame

local stars = {}
for i = 1, 70 do
    local s = Instance.new("Frame")
    s.Size                   = UDim2.new(0, math.random(1,3), 0, math.random(1,3))
    s.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    s.BackgroundTransparency = math.random(2,7)/10
    s.BorderSizePixel        = 0
    s.ZIndex                 = 1
    s.Position               = UDim2.new(math.random(), 0, math.random(), 0)
    s.Parent                 = StarContainer
    Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
    table.insert(stars, {f = s, spd = math.random(5,18)/1000})
end

RunService.RenderStepped:Connect(function(dt)
    for _, sd in ipairs(stars) do
        local nx = sd.f.Position.X.Scale - sd.spd * dt
        if nx < -0.02 then
            sd.f.Position = UDim2.new(1.02, 0, math.random(), 0)
        else
            sd.f.Position = UDim2.new(nx, 0, sd.f.Position.Y.Scale, 0)
        end
    end
end)

-- ==========================================
-- [[ HEADER ]] --
-- ==========================================
local Header = Instance.new("Frame")
Header.Size                   = UDim2.new(1, 0, 0, 46)
Header.BackgroundTransparency = 1
Header.Active                 = true
Header.ZIndex                 = 10
Header.Parent                 = WindowFrame

local Logo = Instance.new("TextLabel")
Logo.Size                   = UDim2.new(0, 34, 0, 34)
Logo.Position               = UDim2.new(0, 12, 0.5, -17)
Logo.BackgroundTransparency = 1
Logo.Text                   = "D"
Logo.TextColor3             = Color3.fromRGB(255, 50, 50)
Logo.TextSize               = 26
Logo.Font                   = Enum.Font.LuckiestGuy
Logo.ZIndex                 = 11
Logo.Parent                 = Header

local Title = Instance.new("TextLabel")
Title.Size                   = UDim2.new(0, 130, 0, 34)
Title.Position               = UDim2.new(0, 50, 0.5, -17)
Title.BackgroundTransparency = 1
Title.Text                   = "DALEY SCRIPTS"
Title.TextColor3             = Color3.fromRGB(230, 230, 235)
Title.TextSize               = 11
Title.Font                   = Enum.Font.GothamBold
Title.TextXAlignment         = Enum.TextXAlignment.Left
Title.ZIndex                 = 11
Title.Parent                 = Header

local HeaderRight = Instance.new("Frame")
HeaderRight.Size                   = UDim2.new(0, 240, 1, 0)
HeaderRight.Position               = UDim2.new(1, -248, 0, 0)
HeaderRight.BackgroundTransparency = 1
HeaderRight.ZIndex                 = 11
HeaderRight.Parent                 = Header

local HRL = Instance.new("UIListLayout")
HRL.FillDirection       = Enum.FillDirection.Horizontal
HRL.HorizontalAlignment = Enum.HorizontalAlignment.Right
HRL.VerticalAlignment   = Enum.VerticalAlignment.Center
HRL.Padding             = UDim.new(0, 10)
HRL.SortOrder           = Enum.SortOrder.LayoutOrder
HRL.Parent              = HeaderRight

local CtrlFrame = Instance.new("Frame")
CtrlFrame.Size                   = UDim2.new(0, 64, 0, 30)
CtrlFrame.BackgroundTransparency = 1
CtrlFrame.ZIndex                 = 11
CtrlFrame.LayoutOrder            = 2
CtrlFrame.Parent                 = HeaderRight

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size                   = UDim2.new(0, 28, 0, 28)
CloseBtn.Position               = UDim2.new(1, -28, 0.5, -14)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text                   = "×"
CloseBtn.TextColor3             = Color3.fromRGB(180, 70, 70)
CloseBtn.TextSize               = 22
CloseBtn.Font                   = Enum.Font.GothamMedium
CloseBtn.ZIndex                 = 12
CloseBtn.Parent                 = CtrlFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size                   = UDim2.new(0, 28, 0, 28)
MinBtn.Position               = UDim2.new(1, -60, 0.5, -14)
MinBtn.BackgroundTransparency = 1
MinBtn.Text                   = "—"
MinBtn.TextColor3             = Color3.fromRGB(170, 170, 175)
MinBtn.TextSize               = 14
MinBtn.Font                   = Enum.Font.GothamMedium
MinBtn.ZIndex                 = 12
MinBtn.Parent                 = CtrlFrame

local minimized    = false
local originalSize = WindowFrame.Size
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(WindowFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = minimized and UDim2.new(0, 650, 0, 46) or originalSize
    }):Play()
end)

local DiscBtn = Instance.new("TextButton")
DiscBtn.Size             = UDim2.new(0, 106, 0, 26)
DiscBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscBtn.Text             = "Join Discord"
DiscBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
DiscBtn.TextSize         = 12
DiscBtn.Font             = Enum.Font.GothamBold
DiscBtn.BorderSizePixel  = 0
DiscBtn.ZIndex           = 12
DiscBtn.LayoutOrder      = 1
DiscBtn.Parent           = HeaderRight
Instance.new("UICorner", DiscBtn).CornerRadius = UDim.new(0, 5)

local discDebounce = false
DiscBtn.MouseButton1Click:Connect(function()
    if discDebounce then return end
    discDebounce = true
    local link = "https://discord.gg/SeNPuUVsZQ"
    if setclipboard then setclipboard(link)
    elseif toclipboard then toclipboard(link) end
    DiscBtn.Text = "Copied!"
    TweenService:Create(DiscBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
    task.wait(2)
    DiscBtn.Text = "Join Discord"
    TweenService:Create(DiscBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    discDebounce = false
end)

-- ==========================================
-- [[ DRAG ]] --
-- ==========================================
local dragging, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = i.Position
        startPos  = WindowFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        WindowFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ==========================================
-- [[ HEADER DIVIDER ]] --
-- ==========================================
local Divider = Instance.new("Frame")
Divider.Size             = UDim2.new(1, 0, 0, 1)
Divider.Position         = UDim2.new(0, 0, 0, 46)
Divider.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Divider.BorderSizePixel  = 0
Divider.ZIndex           = 5
Divider.Parent           = WindowFrame

-- ==========================================
-- [[ SIDEBAR ]] --
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0, 158, 1, -46)
Sidebar.Position         = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
Sidebar.BorderSizePixel  = 0
Sidebar.ZIndex           = 3
Sidebar.Parent           = WindowFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size             = UDim2.new(0, 1, 1, 0)
SidebarLine.Position         = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
SidebarLine.BorderSizePixel  = 0
SidebarLine.ZIndex           = 4
SidebarLine.Parent           = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Size                   = UDim2.new(1, -14, 1, -20)
TabContainer.Position               = UDim2.new(0, 7, 0, 12)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex                 = 4
TabContainer.Parent                 = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding   = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent    = TabContainer

-- ==========================================
-- [[ PAGE CONTAINER ]] --
-- ==========================================
local PageContainer = Instance.new("Frame")
PageContainer.Size                   = UDim2.new(1, -172, 1, -58)
PageContainer.Position               = UDim2.new(0, 166, 0, 52)
PageContainer.BackgroundTransparency = 1
PageContainer.ClipsDescendants       = true
PageContainer.ZIndex                 = 3
PageContainer.Parent                 = WindowFrame

-- ==========================================
-- [[ TAB ENGINE ]] --
-- ==========================================
local activeTabBtn = nil

local function CreateTab(name)
    local Btn = Instance.new("TextButton")
    Btn.Name                   = name .. "_Tab"
    Btn.Size                   = UDim2.new(1, 0, 0, 33)
    Btn.BackgroundColor3       = Color3.fromRGB(20, 20, 24)
    Btn.BackgroundTransparency = 1
    Btn.BorderSizePixel        = 0
    Btn.Text                   = "  " .. name
    Btn.TextColor3             = Color3.fromRGB(130, 130, 138)
    Btn.TextSize               = 12
    Btn.Font                   = Enum.Font.GothamMedium
    Btn.TextXAlignment         = Enum.TextXAlignment.Left
    Btn.ZIndex                 = 4
    Btn.Parent                 = TabContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Accent = Instance.new("Frame")
    Accent.Size                   = UDim2.new(0, 3, 0, 15)
    Accent.Position               = UDim2.new(0, 0, 0.5, -7)
    Accent.BackgroundColor3       = Color3.fromRGB(255, 50, 50)
    Accent.BorderSizePixel        = 0
    Accent.BackgroundTransparency = 1
    Accent.ZIndex                 = 5
    Accent.Parent                 = Btn

    local Page = Instance.new("ScrollingFrame")
    Page.Name                   = name .. "_Page"
    Page.Size                   = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel        = 0
    Page.Visible                = false
    Page.ScrollBarThickness     = 3
    Page.ScrollBarImageColor3   = Color3.fromRGB(255, 50, 50)
    Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    Page.ZIndex                 = 4
    Page.Parent                 = PageContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding   = UDim.new(0, 7)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent    = Page

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop    = UDim.new(0, 7)
    PagePad.PaddingBottom = UDim.new(0, 10)
    PagePad.PaddingLeft   = UDim.new(0, 2)
    PagePad.PaddingRight  = UDim.new(0, 5)
    PagePad.Parent        = Page

    Btn.MouseButton1Click:Connect(function()
        if activeTabBtn == Btn then return end
        for _, child in ipairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.18), {
                    TextColor3             = Color3.fromRGB(130, 130, 138),
                    BackgroundTransparency = 1
                }):Play()
                local acc = child:FindFirstChildOfClass("Frame")
                if acc then TweenService:Create(acc, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play() end
            end
        end
        for _, pg in ipairs(PageContainer:GetChildren()) do
            if pg:IsA("ScrollingFrame") then pg.Visible = false end
        end
        activeTabBtn = Btn
        Page.Visible = true
        TweenService:Create(Btn, TweenInfo.new(0.18), {
            TextColor3             = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.45
        }):Play()
        TweenService:Create(Accent, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    end)

    return Page
end

-- ==========================================
-- [[ COMPONENT BUILDERS ]] --
-- ==========================================
local function Section(page, text)
    local f = Instance.new("Frame")
    f.Size                   = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.ZIndex                 = 5
    f.Parent                 = page

    local line = Instance.new("Frame")
    line.Size             = UDim2.new(1, -8, 0, 1)
    line.Position         = UDim2.new(0, 4, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    line.BorderSizePixel  = 0
    line.ZIndex           = 5
    line.Parent           = f

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize          = Enum.AutomaticSize.X
    lbl.Position               = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundColor3       = Color3.fromRGB(10, 10, 12)
    lbl.BackgroundTransparency = 0
    lbl.Text                   = "  " .. text .. "  "
    lbl.TextColor3             = Color3.fromRGB(255, 50, 50)
    lbl.TextSize               = 10
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.ZIndex                 = 6
    lbl.Parent                 = f
end

local function Label(page, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size                   = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text                   = text
    Lbl.TextColor3             = Color3.fromRGB(110, 110, 118)
    Lbl.TextSize               = 11
    Lbl.Font                   = Enum.Font.GothamMedium
    Lbl.TextXAlignment         = Enum.TextXAlignment.Left
    Lbl.TextWrapped            = true
    Lbl.ZIndex                 = 5
    Lbl.Parent                 = page
    return { Set = function(_, t) Lbl.Text = t end }
end

local function Toggle(page, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size             = UDim2.new(1, 0, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
    Row.BorderSizePixel  = 0
    Row.ZIndex           = 5
    Row.Parent           = page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size                   = UDim2.new(1, -70, 1, 0)
    Lbl.Position               = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text                   = text
    Lbl.TextColor3             = Color3.fromRGB(215, 215, 222)
    Lbl.TextSize               = 12
    Lbl.Font                   = Enum.Font.GothamMedium
    Lbl.TextXAlignment         = Enum.TextXAlignment.Left
    Lbl.ZIndex                 = 6
    Lbl.Parent                 = Row

    local Track = Instance.new("TextButton")
    Track.Size             = UDim2.new(0, 44, 0, 22)
    Track.Position         = UDim2.new(1, -54, 0.5, -11)
    Track.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    Track.Text             = ""
    Track.BorderSizePixel  = 0
    Track.ZIndex           = 6
    Track.Parent           = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 11)

    local Knob = Instance.new("Frame")
    Knob.Size             = UDim2.new(0, 16, 0, 16)
    Knob.Position         = UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(140, 140, 148)
    Knob.BorderSizePixel  = 0
    Knob.ZIndex           = 7
    Knob.Parent           = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 8)

    local state = default or false
    local function apply(v)
        state = v
        TweenService:Create(Knob, TweenInfo.new(0.18), {
            Position         = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,148)
        }):Play()
        TweenService:Create(Track, TweenInfo.new(0.18), {
            BackgroundColor3 = v and Color3.fromRGB(220,45,45) or Color3.fromRGB(32,32,38)
        }):Play()
        if callback then callback(v) end
    end

    if default then apply(true) end
    Track.MouseButton1Click:Connect(function() apply(not state) end)
    return { Set = apply, Get = function() return state end }
end

local function Slider(page, text, min, max, default, increment, callback)
    local Row = Instance.new("Frame")
    Row.Size             = UDim2.new(1, 0, 0, 50)
    Row.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
    Row.BorderSizePixel  = 0
    Row.ZIndex           = 5
    Row.Parent           = page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size                   = UDim2.new(0.7, 0, 0, 22)
    Lbl.Position               = UDim2.new(0, 12, 0, 6)
    Lbl.BackgroundTransparency = 1
    Lbl.Text                   = text
    Lbl.TextColor3             = Color3.fromRGB(215, 215, 222)
    Lbl.TextSize               = 12
    Lbl.Font                   = Enum.Font.GothamMedium
    Lbl.TextXAlignment         = Enum.TextXAlignment.Left
    Lbl.ZIndex                 = 6
    Lbl.Parent                 = Row

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size                   = UDim2.new(0.3, -12, 0, 22)
    ValLbl.Position               = UDim2.new(0.7, 0, 0, 6)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text                   = tostring(default)
    ValLbl.TextColor3             = Color3.fromRGB(255, 50, 50)
    ValLbl.TextSize               = 12
    ValLbl.Font                   = Enum.Font.GothamBold
    ValLbl.TextXAlignment         = Enum.TextXAlignment.Right
    ValLbl.ZIndex                 = 6
    ValLbl.Parent                 = Row

    local Track = Instance.new("TextButton")
    Track.Size             = UDim2.new(1, -24, 0, 5)
    Track.Position         = UDim2.new(0, 12, 0, 36)
    Track.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    Track.Text             = ""
    Track.BorderSizePixel  = 0
    Track.ZIndex           = 6
    Track.Parent           = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 3)

    local Fill = Instance.new("Frame")
    Fill.Size             = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
    Fill.BorderSizePixel  = 0
    Fill.ZIndex           = 7
    Fill.Parent           = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

    local draggingSlider = false
    local function update(x)
        local pct = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.clamp(math.round((min + pct*(max-min)) / increment) * increment, min, max)
        Fill.Size    = UDim2.new((val-min)/(max-min), 0, 1, 0)
        ValLbl.Text  = increment < 1 and string.format("%.1f", val) or tostring(math.round(val))
        if callback then callback(val) end
    end

    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true; update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
    end)
end

local function Button(page, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size             = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Btn.Text             = text
    Btn.TextColor3       = Color3.fromRGB(235, 235, 242)
    Btn.TextSize         = 12
    Btn.Font             = Enum.Font.GothamBold
    Btn.BorderSizePixel  = 0
    Btn.ZIndex           = 5
    Btn.Parent           = page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 7)

    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 1
    Stroke.Color     = Color3.fromRGB(38, 38, 46)

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,30,40)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,26)}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(180,40,40)}):Play()
        task.wait(0.12)
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,26)}):Play()
        if callback then callback() end
    end)
end

local function TextBox(page, placeholder, callback)
    local TB = Instance.new("TextBox")
    TB.Size               = UDim2.new(1, 0, 0, 36)
    TB.BackgroundColor3   = Color3.fromRGB(14, 14, 18)
    TB.PlaceholderText    = placeholder
    TB.Text               = ""
    TB.TextColor3         = Color3.fromRGB(255, 255, 255)
    TB.PlaceholderColor3  = Color3.fromRGB(90, 90, 98)
    TB.TextSize           = 12
    TB.Font               = Enum.Font.GothamMedium
    TB.BorderSizePixel    = 0
    TB.ClearTextOnFocus   = false
    TB.ZIndex             = 5
    TB.Parent             = page
    Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 7)

    local Stroke = Instance.new("UIStroke", TB)
    Stroke.Thickness = 1
    Stroke.Color     = Color3.fromRGB(34, 34, 42)

    TB.Focused:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(220,45,45)}):Play()
    end)
    TB.FocusLost:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(34,34,42)}):Play()
        if callback and TB.Text ~= "" then callback(TB.Text) end
    end)
end

local function Dropdown(page, text, list, callback)
    local Wrapper = Instance.new("Frame")
    Wrapper.Size             = UDim2.new(1, 0, 0, 38)
    Wrapper.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
    Wrapper.BorderSizePixel  = 0
    Wrapper.ZIndex           = 5
    Wrapper.ClipsDescendants = false
    Wrapper.Parent           = page
    Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 7)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size                   = UDim2.new(0.5, 0, 1, 0)
    Lbl.Position               = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text                   = text
    Lbl.TextColor3             = Color3.fromRGB(215, 215, 222)
    Lbl.TextSize               = 12
    Lbl.Font                   = Enum.Font.GothamMedium
    Lbl.TextXAlignment         = Enum.TextXAlignment.Left
    Lbl.ZIndex                 = 6
    Lbl.Parent                 = Wrapper

    local SelBtn = Instance.new("TextButton")
    SelBtn.Size             = UDim2.new(0, 138, 0, 26)
    SelBtn.Position         = UDim2.new(1, -148, 0.5, -13)
    SelBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    SelBtn.Text             = list[1] or "Select"
    SelBtn.TextColor3       = Color3.fromRGB(235, 235, 242)
    SelBtn.TextSize         = 11
    SelBtn.Font             = Enum.Font.GothamBold
    SelBtn.BorderSizePixel  = 0
    SelBtn.ZIndex           = 7
    SelBtn.Parent           = Wrapper
    Instance.new("UICorner", SelBtn).CornerRadius = UDim.new(0, 6)

    local DropFrame = Instance.new("Frame")
    DropFrame.Size             = UDim2.new(1, 0, 0, #list * 28)
    DropFrame.Position         = UDim2.new(0, 0, 1, 3)
    DropFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    DropFrame.BorderSizePixel  = 0
    DropFrame.Visible          = false
    DropFrame.ZIndex           = 20
    DropFrame.Parent           = Wrapper
    Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

    local DStroke = Instance.new("UIStroke", DropFrame)
    DStroke.Thickness = 1
    DStroke.Color     = Color3.fromRGB(40, 40, 50)

    Instance.new("UIListLayout", DropFrame).SortOrder = Enum.SortOrder.LayoutOrder

    local open = false
    SelBtn.MouseButton1Click:Connect(function()
        open = not open
        DropFrame.Visible = open
    end)

    for _, item in ipairs(list) do
        local Opt = Instance.new("TextButton")
        Opt.Size                   = UDim2.new(1, 0, 0, 28)
        Opt.BackgroundTransparency = 1
        Opt.Text                   = item
        Opt.TextColor3             = Color3.fromRGB(180, 180, 188)
        Opt.TextSize               = 11
        Opt.Font                   = Enum.Font.GothamMedium
        Opt.ZIndex                 = 21
        Opt.Parent                 = DropFrame

        Opt.MouseEnter:Connect(function()
            TweenService:Create(Opt, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        end)
        Opt.MouseLeave:Connect(function()
            TweenService:Create(Opt, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(180,180,188)}):Play()
        end)
        Opt.MouseButton1Click:Connect(function()
            open = false
            DropFrame.Visible = false
            SelBtn.Text = item
            if callback then callback(item) end
        end)
    end

    return { Get = function() return SelBtn.Text end }
end

-- ==========================================
-- [[ BUILD TABS ]] --
-- ==========================================
local MovementPage = CreateTab("Movement")
local WorldPage    = CreateTab("World")
local PlayerPage   = CreateTab("Player")
local CombatPage   = CreateTab("Combat")
local VisualsPage  = CreateTab("Visuals")
local FarmPage     = CreateTab("Auto Farm")
local MiscPage     = CreateTab("Misc")

-- Auto-select first tab
do
    local firstBtn = TabContainer:GetChildren()[1]
    if firstBtn and firstBtn:IsA("TextButton") then
        firstBtn:GetPropertyChangedSignal("Parent"):Wait()
    end
    task.defer(function()
        local btn = TabContainer:FindFirstChildOfClass("TextButton")
        if btn then btn:GetPropertyChangedSignal("Visible"):Wait() end
        -- Activate Movement tab
        local movBtn = TabContainer:FindFirstChild("Movement_Tab")
        if movBtn then movBtn.MouseButton1Click:Fire() end
    end)
end

-- ==========================================
-- [[ MOVEMENT TAB ]] --
-- ==========================================
Section(MovementPage, "Speed")
Toggle(MovementPage, "Speed Mode", false, function(v)
    Config.SpeedMode = v
    if not v then
        local h = GetHum()
        if h then h.WalkSpeed = 16 end
    end
end)
Slider(MovementPage, "Speed Value", 16, 250, 16, 1, function(v)
    Config.SpeedValue = v
end)

Section(MovementPage, "Flight")
Toggle(MovementPage, "Fly Mode", false, function(v)
    Config.Flying = v
    local char = LP.Character
    if v and char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        hum.PlatformStand = true

        local BV = Instance.new("BodyVelocity", root)
        BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        BV.Velocity = Vector3.zero

        local BG = Instance.new("BodyGyro", root)
        BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        BG.D = 100

        task.spawn(function()
            while Config.Flying and root and root.Parent
            and BV and BV.Parent and BG and BG.Parent do
                local cam = Camera.CFrame
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                BV.Velocity = dir.Magnitude > 0 and dir.Unit * Config.FlySpeed or Vector3.zero
                BG.CFrame   = cam
                task.wait()
            end
            pcall(function() BV:Destroy() end)
            pcall(function() BG:Destroy() end)
            local h2 = GetHum()
            if h2 then h2.PlatformStand = false end
        end)
    else
        local char2 = LP.Character
        if char2 then
            local root2 = char2:FindFirstChild("HumanoidRootPart")
            if root2 then
                local bv = root2:FindFirstChildOfClass("BodyVelocity")
                local bg = root2:FindFirstChildOfClass("BodyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
            local h2 = char2:FindFirstChildOfClass("Humanoid")
            if h2 then h2.PlatformStand = false end
        end
    end
end)
Slider(MovementPage, "Fly Speed", 10, 500, 50, 5, function(v)
    Config.FlySpeed = v
end)

Section(MovementPage, "Physics")
Toggle(MovementPage, "Noclip", false, function(v)
    Config.Noclip = v
end)
Toggle(MovementPage, "Infinite Jump", false, function(v)
    Config.InfiniteJump = v
end)

-- ==========================================
-- [[ WORLD TAB ]] --
-- ==========================================
Section(WorldPage, "Object Scanner")
Label(WorldPage, "Type a part/model name to scan and teleport to it.")
TextBox(WorldPage, "Scan target name (e.g. Zombie)", function(text)
    Config.LastScannedName = text
    Config._scanIndex = 0
end)
Button(WorldPage, "Teleport to First Match", function()
    if Config.LastScannedName == "" then return end
    local hrp = GetHRP()
    if not hrp then return end
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == Config.LastScannedName
        and (item:IsA("BasePart") or item:IsA("MeshPart")) then
            hrp.CFrame = item.CFrame + Vector3.new(0, 4, 0)
            return
        end
    end
end)
Button(WorldPage, "Teleport to Next Match (Cycle)", function()
    if Config.LastScannedName == "" then return end
    local hrp = GetHRP()
    if not hrp then return end
    local matches = {}
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == Config.LastScannedName
        and (item:IsA("BasePart") or item:IsA("MeshPart")) then
            table.insert(matches, item)
        end
    end
    if #matches == 0 then return end
    Config._scanIndex = (Config._scanIndex % #matches) + 1
    hrp.CFrame = matches[Config._scanIndex].CFrame + Vector3.new(0, 4, 0)
end)
Button(WorldPage, "Print All Matches to Console", function()
    if Config.LastScannedName == "" then return end
    local n = 0
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == Config.LastScannedName then
            n += 1
            print(string.format("[%d] %s", n, item:GetFullName()))
        end
    end
    print("--- " .. n .. " match(es) ---")
end)

-- ==========================================
-- [[ PLAYER TAB ]] --
-- ==========================================
Section(PlayerPage, "Teleport")
TextBox(PlayerPage, "Teleport to player (username)", function(text)
    local target = Players:FindFirstChild(text)
    if target and target.Character then
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = GetHRP()
        if hrp and tHRP then
            hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

Section(PlayerPage, "Coordinates")
Button(PlayerPage, "Mark Current Position", function()
    local hrp = GetHRP()
    if hrp then
        Config.SavedCoordinates = hrp.Position
        print("Marked: " .. tostring(Config.SavedCoordinates))
    end
end)
Button(PlayerPage, "Teleport to Marked Position", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(Config.SavedCoordinates) end
end)
Button(PlayerPage, "Copy Coordinates to Clipboard", function()
    local hrp = GetHRP()
    if hrp then
        local p   = hrp.Position
        local str = string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z)
        if setclipboard then setclipboard(str) end
        print("Copied: " .. str)
    end
end)
Toggle(PlayerPage, "Click Teleport (Ctrl+Click)", false, function(v)
    Config.ClickTPEnabled = v
end)

-- ==========================================
-- [[ COMBAT TAB ]] --
-- ==========================================
Section(CombatPage, "Aimlock")
Label(CombatPage, "Press Q to lock / unlock onto nearest player.")
Toggle(CombatPage, "Aimlock Enabled", false, function(v)
    Config.AimlockActive = v
    if not v then
        IsCurrentlyLocked = false
        LockedTarget      = nil
    end
end)
Slider(CombatPage, "Aim Smoothing", 0.05, 1, 0.2, 0.05, function(v)
    Config.Smoothing = v
end)
Dropdown(CombatPage, "Target Part",
    {"HumanoidRootPart", "Head", "Torso", "Leg", "Arm"},
    function(sel) Config.AimTarget = sel end
)

Section(CombatPage, "Silent Aim")
Toggle(CombatPage, "Silent Aim (exploit required)", false, function(v)
    Config.SilentAim = v
end)

-- ==========================================
-- [[ VISUALS TAB ]] --
-- ==========================================
Section(VisualsPage, "Player ESP")
Toggle(VisualsPage, "ESP (Highlight + Info)", false, function(v)
    Config.ESPEnabled = v
end)
Toggle(VisualsPage, "Chams (Through-Wall Fill)", false, function(v)
    Config.ChamsEnabled = v
end)

-- ==========================================
-- [[ AUTO FARM TAB ]] --
-- ==========================================
Section(FarmPage, "Target Farm")
Label(FarmPage, "Teleports onto closest matching NPC and holds until it dies.")
TextBox(FarmPage, "Farm target name (e.g. Zombie)", function(text)
    Config.AutoFarmTarget = text
end)
Toggle(FarmPage, "Auto Farm", false, function(v)
    Config.AutoFarmEnabled = v
    if v then
        task.spawn(function()
            while Config.AutoFarmEnabled do
                if Config.AutoFarmTarget == "" then task.wait(0.5); continue end
                local hrp = GetHRP()
                if not hrp then task.wait(0.5); continue end
                local pChars = GetPlayerChars()
                local target, closestD = nil, math.huge
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and not pChars[obj] then
                        local cn = string.gsub(string.gsub(obj.Name, "%d+", ""), "%s+$", "")
                        if string.lower(cn) == string.lower(Config.AutoFarmTarget) then
                            local eh = obj:FindFirstChildOfClass("Humanoid")
                            local er = obj:FindFirstChild("HumanoidRootPart")
                            if eh and eh.Health > 0 and er then
                                local d = (hrp.Position - er.Position).Magnitude
                                if d < closestD then closestD = d; target = obj end
                            end
                        end
                    end
                end
                if target then
                    local er = target:FindFirstChild("HumanoidRootPart")
                    local eh = target:FindFirstChildOfClass("Humanoid")
                    while Config.AutoFarmEnabled and er and er.Parent
                    and eh and eh.Health > 0 do
                        local r = GetHRP()
                        if r then
                            r.CFrame = CFrame.new(er.Position + Vector3.new(0, 2.5, 0))
                            r.AssemblyLinearVelocity = Vector3.zero
                        end
                        task.wait(Config.AutoFarmDelay)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)
Slider(FarmPage, "Farm Tick Rate", 1, 20, 1, 1, function(v)
    Config.AutoFarmDelay = v / 10
end)

-- ==========================================
-- [[ MISC TAB ]] --
-- ==========================================
Section(MiscPage, "Utilities")
Toggle(MiscPage, "Anti-AFK", true, function(v)
    Config.AntiAFK = v
end)
Button(MiscPage, "Reset Character", function()
    local h = GetHum()
    if h then h.Health = 0 end
end)
Button(MiscPage, "Copy Game ID", function()
    if setclipboard then setclipboard(tostring(game.PlaceId)) end
    print("Game ID: " .. tostring(game.PlaceId))
end)
Button(MiscPage, "Print All Players to Console", function()
    print("=== Players ===")
    for i, p in ipairs(Players:GetPlayers()) do
        print(string.format("[%d] %s | %d", i, p.Name, p.UserId))
    end
end)
Button(MiscPage, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- ==========================================
-- [[ ESP ENGINE ]] --
-- ==========================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name   = "DaleyESPContainer"
ESPFolder.Parent = CoreGui

local function ClearESP(player)
    local bb = ESPFolder:FindFirstChild(player.Name .. "_ESP")
    if bb then bb:Destroy() end
    if player.Character then
        local hl = player.Character:FindFirstChild("ESPHighlight")
        local ch = player.Character:FindFirstChild("ESPChams")
        if hl then hl:Destroy() end
        if ch then ch:Destroy() end
    end
end

local function CreateESP(player)
    ClearESP(player)
    if player == LP then return end

    local function setup(char)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local hum  = char:WaitForChild("Humanoid", 5)
        if not root or not hum then return end

        local Highlight = Instance.new("Highlight")
        Highlight.Name                = "ESPHighlight"
        Highlight.FillColor           = Color3.fromRGB(255, 50, 50)
        Highlight.FillTransparency    = 0.55
        Highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
        Highlight.OutlineTransparency = 0.1
        Highlight.Adornee             = char
        Highlight.Enabled             = false
        Highlight.Parent              = char

        local Chams = Instance.new("Highlight")
        Chams.Name                = "ESPChams"
        Chams.FillColor           = Color3.fromRGB(220, 45, 45)
        Chams.FillTransparency    = 0.25
        Chams.OutlineColor        = Color3.fromRGB(220, 45, 45)
        Chams.OutlineTransparency = 0
        Chams.Adornee             = char
        Chams.Enabled             = false
        Chams.Parent              = CoreGui

        local BB = Instance.new("BillboardGui")
        BB.Name          = player.Name .. "_ESP"
        BB.Size          = UDim2.new(0, 200, 0, 66)
        BB.AlwaysOnTop   = true
        BB.ExtentsOffset = Vector3.new(0, 3.5, 0)
        BB.Adornee       = root
        BB.Enabled       = false
        BB.Parent        = ESPFolder

        local Info = Instance.new("TextLabel", BB)
        Info.Size                   = UDim2.new(1, 0, 1, 0)
        Info.BackgroundTransparency = 1
        Info.Font                   = Enum.Font.GothamBold
        Info.TextSize               = 12
        Info.TextColor3             = Color3.fromRGB(255, 255, 255)
        Info.TextStrokeTransparency = 0
        Info.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        Info.TextYAlignment         = Enum.TextYAlignment.Bottom
        Info.TextWrapped            = true

        -- [[ THIS IS WHERE THE ORIGINAL SCRIPT WAS CUT OFF ]]
        -- The RenderStepped connection below is the missing piece
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char.Parent or not root.Parent
            or not hum.Parent or not BB.Parent then
                conn:Disconnect()
                pcall(function() Highlight:Destroy() end)
                pcall(function() Chams:Destroy() end)
                pcall(function() BB:Destroy() end)
                return
            end

            local myHRP = GetHRP()
            Highlight.Enabled = Config.ESPEnabled
            Chams.Enabled     = Config.ChamsEnabled
            BB.Enabled        = Config.ESPEnabled

            if Config.ESPEnabled and myHRP then
                local dist  = math.round((root.Position - myHRP.Position).Magnitude)
                local hp    = math.round(hum.Health)
                local maxHp = math.round(hum.MaxHealth)
                local bars  = math.floor(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) * 10)
                local hpBar = string.rep("|", bars) .. string.rep(".", 10 - bars)

                Info.Text = string.format(
                    "%s\n[%d studs]\n[%s] %d/%d HP",
                    player.Name, dist, hpBar, hp, maxHp
                )
            end
        end)
    end

    if player.Character then
        task.spawn(setup, player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        task.spawn(setup, char)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    pcall(function() ClearESP(p) end)
end)

-- ==========================================
-- [[ RUNTIME ENGINE ]] --
-- ==========================================

-- Speed / Noclip / Infinite Jump
RunService.Stepped:Connect(function()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if Config.Noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if Config.SpeedMode and not Config.Flying then
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + md * (Config.SpeedValue / 60)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        vu:Button2Down(Vector2.new(0,0), CFrame.new())
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), CFrame.new())
    end
end)

-- Click Teleport (Ctrl+Click)
Mouse.Button1Down:Connect(function()
    if not Config.ClickTPEnabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then return end
    local hrp = GetHRP()
    if not hrp then return end
    local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LP.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    if result then
        hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
    end
end)

-- Aimlock (Q key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.AimlockKey and Config.AimlockActive then
        if IsCurrentlyLocked then
            IsCurrentlyLocked = false
            LockedTarget      = nil
        else
            local p = GetClosestPlayer()
            if p then
                LockedTarget      = p
                IsCurrentlyLocked = true
            end
        end
    end
end)

-- Aimlock RenderStepped
RunService.RenderStepped:Connect(function()
    if not Config.AimlockActive or not IsCurrentlyLocked or not LockedTarget then return end
    local char = LockedTarget.Character
    if not char then IsCurrentlyLocked = false; LockedTarget = nil; return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local part = GetBodyPart(char, Config.AimTarget) or char:FindFirstChild("HumanoidRootPart")
    if not part or not hum or hum.Health <= 0 then
        IsCurrentlyLocked = false; LockedTarget = nil; return
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return end

    local targetVP = Vector2.new(screenPos.X, screenPos.Y)
    local currentMP = UserInputService:GetMouseLocation()
    local newPos = currentMP:Lerp(targetVP, Config.Smoothing)

    -- Move mouse toward target
    mousemoverel(
        newPos.X - currentMP.X,
        newPos.Y - currentMP.Y
    )
end)
