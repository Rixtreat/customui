-- =========================================================================
-- [[ DALEY UI LIBRARY - COLOR WHEEL, RESIZE, & COMBINED MISC TAB ]] --
-- Host this file on GitHub and load it via:
--   local DaleyUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--   local Window = DaleyUI:CreateWindow({ Name = "My Hub", Discord = "YOUR_LINK" })
-- =========================================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

-- SAFE LOCAL PLAYER ACQUISITION (Fixes Line 13 Nil Errors)
local LP = Players.LocalPlayer
if not LP and RunService:IsClient() then
    LP = Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
end

-- STUDIO SAFE CORE-GUI FALLBACK
local CoreGui = game:GetService("CoreGui")
local TargetParent
pcall(function()
    -- This safely attempts to use CoreGui, but falls back to PlayerGui in Studio
    TargetParent = CoreGui
end)
if not TargetParent then
    TargetParent = LP and LP:WaitForChild("PlayerGui")
end

-- =========================================================================
-- [[ GLOBAL MOUSE STATE TRACKER (FIXES LINE 31 NIL ERRORS) ]] --
-- =========================================================================
local isLeftMouseDown = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    -- Added safety check "if input and ..." to prevent indexing nil errors
    if input and input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- Added safety check "if input and ..." to prevent indexing nil errors
    if input and input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = false
    end
end)

-- =========================================================================
-- [[ LIBRARY OBJECT ]] --
-- =========================================================================
local DaleyUI = {}
DaleyUI.__index = DaleyUI

-- Global Settings Reference (Shared between Library, Windows, and UI Settings)
local UISettings = {
    RGBOutline = true,
    OutlineColor = Color3.fromRGB(255, 50, 50),
    ToggleKey = Enum.KeyCode.K,
    StarsEnabled = true
}

-- =========================================================================
-- [[ CREATE WINDOW ]] --
-- =========================================================================
function DaleyUI:CreateWindow(config)
    config = config or {}
    local windowName  = config.Name     or "Daley Hub"
    
    -- Force-resolve a strict string fallback immediately so clipboard never fails
    local rawDiscord = config.Discord or config.discord or "https://discord.gg/SeNPuUVsZQ"
    local discordLink = tostring(rawDiscord)

    -- Cleanup existing
    if TargetParent and TargetParent:FindFirstChild("DaleyStarfieldUI") then
        TargetParent.DaleyStarfieldUI:Destroy()
    end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "DaleyStarfieldUI"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if TargetParent then
        ScreenGui.Parent     = TargetParent
    end

    -- Main Window Frame
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name             = "MainWindow"
    WindowFrame.Size             = UDim2.new(0, 650, 0, 420)
    WindowFrame.Position         = UDim2.new(0.5, -325, 0.5, -210)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    WindowFrame.BorderSizePixel  = 0
    WindowFrame.ClipsDescendants = false
    WindowFrame.Active           = true
    WindowFrame.Parent           = ScreenGui
    Instance.new("UICorner", WindowFrame).CornerRadius = UDim.new(0, 12)

    -- RGB / Static Outline Border
    local RGBStroke = Instance.new("UIStroke")
    RGBStroke.Thickness       = 2
    RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RGBStroke.Parent          = WindowFrame

    -- Dynamic Border Loop
    task.spawn(function()
        local hue = 0
        while ScreenGui.Parent do
            if UISettings.RGBOutline then
                hue = (hue + 1) % 360
                RGBStroke.Color = Color3.fromHSV(hue / 360, 0.85, 1)
            else
                RGBStroke.Color = UISettings.OutlineColor
            end
            task.wait()
        end
    end)

    -- Starfield Star Container
    local StarContainer = Instance.new("Frame")
    StarContainer.Size                   = UDim2.new(1, 0, 1, 0)
    StarContainer.BackgroundTransparency = 1
    StarContainer.ZIndex                 = 1
    StarContainer.ClipsDescendants       = true
    StarContainer.Parent                 = WindowFrame
    Instance.new("UICorner", StarContainer).CornerRadius = UDim.new(0, 12)

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
        if not ScreenGui.Parent then return end
        
        -- Instantly toggle visual container visibility based on global setting
        StarContainer.Visible = UISettings.StarsEnabled
        
        if UISettings.StarsEnabled then
            for _, sd in ipairs(stars) do
                local nx = sd.f.Position.X.Scale - sd.spd * dt
                if nx < -0.02 then
                    sd.f.Position = UDim2.new(1.02, 0, math.random(), 0)
                else
                    sd.f.Position = UDim2.new(nx, 0, sd.f.Position.Y.Scale, 0)
                end
            end
        end
    end)

    -- Header
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

    -- Dynamically match the Logo color to your outline theme color
    task.spawn(function()
        while ScreenGui.Parent do
            if UISettings.RGBOutline then
                Logo.TextColor3 = RGBStroke.Color
            else
                Logo.TextColor3 = UISettings.OutlineColor
            end
            task.wait(0.1)
        end
    end)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size                   = UDim2.new(0, 200, 0, 34)
    TitleLbl.Position               = UDim2.new(0, 50, 0.5, -17)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text                   = windowName
    TitleLbl.TextColor3             = Color3.fromRGB(230, 230, 235)
    TitleLbl.TextSize               = 11
    TitleLbl.Font                   = Enum.Font.GothamBold
    TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left
    TitleLbl.ZIndex                 = 11
    TitleLbl.Parent                 = Header

    -- Header Right Controls
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
    MinBtn.TextSize         = 14
    MinBtn.Font             = Enum.Font.GothamMedium
    MinBtn.ZIndex           = 12
    MinBtn.Parent           = CtrlFrame

    local minimized    = false
    local originalSize = WindowFrame.Size
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(WindowFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimized and UDim2.new(0, WindowFrame.Size.X.Offset, 0, 46) or UDim2.new(0, WindowFrame.Size.X.Offset, 0, originalSize.Y.Offset)
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

    -- Discord Clipboard
    local discDebounce = false
    DiscBtn.MouseButton1Click:Connect(function()
        if discDebounce then return end
        discDebounce = true
        DiscBtn.Text = "Copied!"
        TweenService:Create(DiscBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
        
        pcall(function()
            if setclipboard then setclipboard(discordLink)
            elseif toclipboard then toclipboard(discordLink)
            elseif writeclipboard then writeclipboard(discordLink)
            elseif set_clipboard then set_clipboard(discordLink)
            elseif syn and syn.write_clipboard then syn.write_clipboard(discordLink)
            elseif fluxus and fluxus.set_clipboard then fluxus.set_clipboard(discordLink)
            end
        end)
        
        task.wait(2)
        DiscBtn.Text = "Join Discord"
        TweenService:Create(DiscBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
        discDebounce = false
    end)

    -- Drag System with Custom State Safeguard
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = WindowFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging then
            -- Fallback verification using custom state tracker (Fixes sticking)
            if not isLeftMouseDown then
                dragging = false
                return
            end
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - dragStart
                WindowFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Keybind Toggle with Scale Animation
    local uiVisible = true
    local animating = false

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == UISettings.ToggleKey then
            if animating then return end
            animating = true
            uiVisible = not uiVisible

            if uiVisible then
                WindowFrame.Visible = true
                TweenService:Create(WindowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = originalSize
                }):Play()
                local t = TweenService:Create(WindowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0
                })
                t:Play()
                t.Completed:Wait()
                animating = false
            else
                originalSize = WindowFrame.Size
                TweenService:Create(WindowFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0)
                }):Play()
                local t = TweenService:Create(WindowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1
                })
                t:Play()
                t.Completed:Wait()
                WindowFrame.Visible = false
                animating = false
            end
        end
    end)

    -- Divider Line
    local Divider = Instance.new("Frame")
    Divider.Size             = UDim2.new(1, 0, 0, 1)
    Divider.Position         = UDim2.new(0, 0, 0, 46)
    Divider.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Divider.BorderSizePixel  = 0
    Divider.ZIndex           = 5
    Divider.Parent           = WindowFrame

    -- Sidebar
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

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Size                   = UDim2.new(1, -172, 1, -58)
    PageContainer.Position               = UDim2.new(0, 166, 0, 52)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ClipsDescendants       = true
    PageContainer.ZIndex                 = 3
    PageContainer.Parent                 = WindowFrame

    -- =========================================================================
    -- [[ TRANSPARENT 4-CORNER RESIZE HANDLERS (STUCK-PROOF) ]] --
    -- =========================================================================
    local resizeHandles = {
        BR = { Pos = UDim2.new(1, -16, 1, -16), Anchor = Vector2.new(0,0), FactorX = 1,  FactorY = 1,  MoveX = 0, MoveY = 0 },
        BL = { Pos = UDim2.new(0, 0, 1, -16),   Anchor = Vector2.new(0,0), FactorX = -1, FactorY = 1,  MoveX = 1, MoveY = 0 },
        TR = { Pos = UDim2.new(1, -16, 0, 0),   Anchor = Vector2.new(0,0), FactorX = 1,  FactorY = -1, MoveX = 0, MoveY = 1 },
        TL = { Pos = UDim2.new(0, 0, 0, 0),     Anchor = Vector2.new(0,0), FactorX = -1, FactorY = -1, MoveX = 1, MoveY = 1 }
    }

    local activeResize = false
    local activeCorner = nil
    local resizeStartMouse = nil
    local resizeStartSize = nil
    local resizeStartPos = nil

    for cornerName, info in pairs(resizeHandles) do
        local Handle = Instance.new("ImageButton")
        Handle.Name                   = cornerName .. "_Resize"
        Handle.Size                   = UDim2.new(0, 16, 0, 16)
        Handle.Position               = info.Pos
        Handle.BackgroundTransparency = 1 
        Handle.Image                  = "rbxassetid://0"
        Handle.BorderSizePixel        = 0
        Handle.ZIndex                 = 100
        Handle.Parent                 = WindowFrame

        Handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                activeResize     = true
                activeCorner     = info
                resizeStartMouse = i.Position
                resizeStartSize  = WindowFrame.Size
                resizeStartPos   = WindowFrame.Position
            end
        end)
    end

    -- InputChanged Handler checking custom safety state
    UserInputService.InputChanged:Connect(function(i)
        if activeResize then
            -- Fallback verification using custom state tracker
            if not isLeftMouseDown then
                activeResize = false
                activeCorner = nil
                return
            end
            
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - resizeStartMouse
                
                local newWidth  = math.clamp(resizeStartSize.X.Offset + (delta.X * activeCorner.FactorX), 480, 950)
                local newHeight = math.clamp(resizeStartSize.Y.Offset + (delta.Y * activeCorner.FactorY), 280, 650)
                
                local changeX = newWidth - resizeStartSize.X.Offset
                local changeY = newHeight - resizeStartSize.Y.Offset
                
                local posX = resizeStartPos.X.Offset - (changeX * activeCorner.MoveX)
                local posY = resizeStartPos.Y.Offset - (changeY * activeCorner.MoveY)

                WindowFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                WindowFrame.Position = UDim2.new(resizeStartPos.X.Scale, posX, resizeStartPos.Y.Scale, posY)
                originalSize = WindowFrame.Size
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            activeResize = false
            activeCorner = nil
        end
    end)

    local activeTabBtn = nil

    -- =====================================================================
    -- Window Object
    -- =====================================================================
    local Window = {}

    function Window:CreateTab(name)
        -- Sidebar Button
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

        -- Maintain aesthetic accent matching
        task.spawn(function()
            while ScreenGui.Parent do
                if UISettings.RGBOutline then
                    Accent.BackgroundColor3 = RGBStroke.Color
                else
                    Accent.BackgroundColor3 = UISettings.OutlineColor
                end
                task.wait(0.1)
            end
        end)

        -- Scrollable Pages
        local Page = Instance.new("ScrollingFrame")
        Page.Name                   = name .. "_Page"
        Page.Size                   = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.Visible                = false
        Page.ScrollBarThickness     = 4
        Page.ScrollBarImageColor3   = Color3.fromRGB(255, 50, 50)
        Page.ZIndex                 = 4
        Page.Active                 = true
        Page.ScrollingDirection     = Enum.ScrollingDirection.Y
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        Page.Parent                 = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding   = UDim.new(0, 7)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent    = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop    = UDim.new(0, 7)
        PagePad.PaddingBottom = UDim.new(0, 15)
        PagePad.PaddingLeft   = UDim.new(0, 4)
        PagePad.PaddingRight  = UDim.new(0, 8)
        PagePad.Parent        = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 25)
        end)

        -- Tab click logic
        Btn.MouseButton1Click:Connect(function()
            if activeTabBtn == Btn then return end
            for _, child in ipairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.18), {
                        TextColor3             = Color3.fromRGB(130, 130, 138),
                        BackgroundTransparency = 1
                    }):Play()
                    local acc = child:FindFirstChildOfClass("Frame")
                    if acc then
                        TweenService:Create(acc, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
                    end
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

        if not activeTabBtn then
            activeTabBtn = Btn
            Page.Visible = true
            Btn.TextColor3             = Color3.fromRGB(255, 255, 255)
            Btn.BackgroundTransparency = 0.45
            Accent.BackgroundTransparency = 0
        end

        -- =====================================================================
        -- Tab Object Elements
        -- =====================================================================
        local Tab = {}

        function Tab:CreateSection(text)
            local f = Instance.new("Frame")
            f.Size                   = UDim2.new(1, 0, 0, 22)
            f.BackgroundTransparency = 1
            f.ZIndex                 = 5
            f.Parent                 = Page

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

        function Tab:CreateLabel(text)
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
            Lbl.Parent                 = Page
            return { Set = function(_, t) Lbl.Text = t end }
        end

        function Tab:CreateToggle(config)
            config = config or {}
            local text     = config.Name     or "Toggle"
            local default  = config.Default  or config.CurrentValue or false
            local callback = config.Callback or function() end

            local Row = Instance.new("Frame")
            Row.Size             = UDim2.new(1, 0, 0, 38)
            Row.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            Row.BorderSizePixel  = 0
            Row.ZIndex           = 5
            Row.Parent           = Page
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

            local state = false
            local function apply(v)
                state = v
                TweenService:Create(Knob, TweenInfo.new(0.18), {
                    Position         = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                    BackgroundColor3 = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,148)
                }):Play()
                TweenService:Create(Track, TweenInfo.new(0.18), {
                    BackgroundColor3 = v and Color3.fromRGB(220,45,45) or Color3.fromRGB(32,32,38)
                }):Play()
                callback(v)
            end

            if default then apply(true) end
            Track.MouseButton1Click:Connect(function() apply(not state) end)
            return { Set = apply, Get = function() return state end }
        end

        function Tab:CreateSlider(config)
            config = config or {}
            local text      = config.Name         or "Slider"
            local min       = config.Min          or config.Range and config.Range[1] or 0
            local max       = config.Max          or config.Range and config.Range[2] or 100
            local default   = config.CurrentValue or config.Default or min
            local increment = config.Increment    or 1
            local suffix    = config.ValueName    or config.Suffix or ""
            local callback  = config.Callback     or function() end

            local Row = Instance.new("Frame")
            Row.Size             = UDim2.new(1, 0, 0, 50)
            Row.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            Row.BorderSizePixel  = 0
            Row.ZIndex           = 5
            Row.Parent           = Page
            Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)

            local Lbl = Instance.new("TextLabel")
            Lbl.Size                   = UDim2.new(0.65, 0, 0, 22)
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
            ValLbl.Size                   = UDim2.new(0.35, -12, 0, 22)
            ValLbl.Position               = UDim2.new(0.65, 0, 0, 6)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text                   = tostring(default) .. (suffix ~= "" and (" " .. suffix) or "")
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
                ValLbl.Text  = (increment < 1 and string.format("%.1f", val) or tostring(math.round(val)))
                              .. (suffix ~= "" and (" " .. suffix) or "")
                callback(val)
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

        function Tab:CreateButton(config)
            config = config or {}
            local text     = config.Name     or "Button"
            local callback = config.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size             = UDim2.new(1, 0, 0, 36)
            Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            Btn.Text             = text
            Btn.TextColor3       = Color3.fromRGB(235, 235, 242)
            Btn.TextSize         = 12
            Btn.Font             = Enum.Font.GothamBold
            Btn.BorderSizePixel  = 0
            Btn.ZIndex           = 5
            Btn.Parent           = Page
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
                callback()
            end)
        end

        function Tab:CreateTextBox(config)
            config = config or {}
            local placeholder = config.Name        or config.PlaceholderText or "Enter text..."
            local callback    = config.Callback    or function() end

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
            TB.Parent             = Page
            Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 7)

            local Stroke = Instance.new("UIStroke", TB)
            Stroke.Thickness = 1
            Stroke.Color     = Color3.fromRGB(34, 34, 42)

            TB.Focused:Connect(function()
                TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(220,45,45)}):Play()
            end)
            TB.FocusLost:Connect(function()
                TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(34,34,42)}):Play()
                if TB.Text ~= "" then callback(TB.Text) end
            end)
        end

        function Tab:CreateDropdown(config)
            config = config or {}
            local text     = config.Name     or "Dropdown"
            local list     = config.Options  or {}
            local callback = config.Callback or function() end

            local Wrapper = Instance.new("Frame")
            Wrapper.Size             = UDim2.new(1, 0, 0, 38)
            Wrapper.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            Wrapper.BorderSizePixel  = 0
            Wrapper.ZIndex           = 15
            Wrapper.ClipsDescendants = false
            Wrapper.Parent           = Page
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
            Lbl.ZIndex                 = 16
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
            SelBtn.ZIndex           = 17
            SelBtn.Parent           = Wrapper
            Instance.new("UICorner", SelBtn).CornerRadius = UDim.new(0, 6)

            local DropFrame = Instance.new("ScrollingFrame")
            DropFrame.Size                   = UDim2.new(1, 0, 0, math.clamp(#list * 28, 0, 140))
            DropFrame.Position               = UDim2.new(0, 0, 1, 3)
            DropFrame.BackgroundColor3       = Color3.fromRGB(20, 20, 25)
            DropFrame.BorderSizePixel        = 0
            DropFrame.Visible                = false
            DropFrame.ZIndex                 = 50
            DropFrame.ScrollBarThickness     = 3
            DropFrame.ScrollBarImageColor3   = Color3.fromRGB(255, 50, 50)
            DropFrame.ScrollingDirection     = Enum.ScrollingDirection.Y
            DropFrame.Active                 = true
            DropFrame.CanvasSize             = UDim2.new(0, 0, 0, #list * 28)
            DropFrame.Parent                 = Wrapper
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

            local DStroke = Instance.new("UIStroke", DropFrame)
            DStroke.Thickness = 1
            DStroke.Color     = Color3.fromRGB(40, 40, 50)

            local DropLayout = Instance.new("UIListLayout", DropFrame)
            DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local open = false
            SelBtn.MouseButton1Click:Connect(function()
                open = not open
                DropFrame.Visible = open
            end)

            local function createOptionButton(item)
                local Opt = Instance.new("TextButton")
                Opt.Size                   = UDim2.new(1, -6, 0, 28)
                Opt.BackgroundTransparency = 1
                Opt.Text                   = item
                Opt.TextColor3             = Color3.fromRGB(180, 180, 188)
                Opt.TextSize               = 11
                Opt.Font                   = Enum.Font.GothamMedium
                Opt.ZIndex                 = 51
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
                    callback(item)
                end)
            end

            for _, item in ipairs(list) do
                createOptionButton(item)
            end

            return {
                Get = function() 
                    return SelBtn.Text 
                end,
                Refresh = function(self, newList)
                    newList = newList or {}
                    for _, child in ipairs(DropFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    DropFrame.Size = UDim2.new(1, 0, 0, math.clamp(#newList * 28, 0, 140))
                    DropFrame.CanvasSize = UDim2.new(0, 0, 0, #newList * 28)
                    for _, item in ipairs(newList) do
                        createOptionButton(item)
                    end
                    local found = false
                    for _, item in ipairs(newList) do
                        if item == SelBtn.Text then
                            found = true
                            break
                        end
                    end
                    if not found then
                        SelBtn.Text = newList[1] or "Select"
                    end
                end
            }
        end

        -- =====================================================================
        -- [[ DYNAMIC ROTATABLE COLOR WHEEL ELEMENT ]] --
        -- =====================================================================
        function Tab:CreateColorPicker(config)
            config = config or {}
            local name = config.Name or "Color Picker"
            local defaultColor = config.Default or Color3.fromRGB(255, 50, 50)
            local callback = config.Callback or function() end

            local PickerRow = Instance.new("Frame")
            PickerRow.Size = UDim2.new(1, 0, 0, 140)
            PickerRow.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            PickerRow.BorderSizePixel = 0
            PickerRow.ZIndex = 5
            PickerRow.Parent = Page
            Instance.new("UICorner", PickerRow).CornerRadius = UDim.new(0, 7)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.4, 0, 0, 30)
            Label.Position = UDim2.new(0, 12, 0, 10)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(215, 215, 222)
            Label.TextSize = 12
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 6
            Label.Parent = PickerRow

            -- Current Color Indicator Box
            local ColorPreview = Instance.new("Frame")
            ColorPreview.Size = UDim2.new(0, 50, 0, 20)
            ColorPreview.Position = UDim2.new(0, 12, 0, 45)
            ColorPreview.BackgroundColor3 = defaultColor
            ColorPreview.BorderSizePixel = 0
            ColorPreview.ZIndex = 6
            ColorPreview.Parent = PickerRow
            Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 4)

            local PreviewStroke = Instance.new("UIStroke", ColorPreview)
            PreviewStroke.Color = Color3.fromRGB(45, 45, 55)
            PreviewStroke.Thickness = 1

            -- Color Wheel Image (Radial HSV Color Map Asset)
            local Wheel = Instance.new("ImageButton")
            Wheel.Size = UDim2.new(0, 100, 0, 100)
            Wheel.Position = UDim2.new(1, -240, 0.5, -50)
            Wheel.BackgroundTransparency = 1
            Wheel.Image = "rbxassetid://415583266" -- Default High-Res Color Wheel asset
            Wheel.ZIndex = 7
            Wheel.Parent = PickerRow

            -- Cursor Selection Pin
            local WheelPin = Instance.new("Frame")
            WheelPin.Size = UDim2.new(0, 8, 0, 8)
            WheelPin.AnchorPoint = Vector2.new(0.5, 0.5)
            WheelPin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            WheelPin.BorderSizePixel = 0
            WheelPin.ZIndex = 8
            WheelPin.Parent = Wheel
            Instance.new("UICorner", WheelPin).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", WheelPin).Color = Color3.fromRGB(0, 0, 0)

            -- Saturation / Value Vertical Slider Bar
            local ValSlider = Instance.new("TextButton")
            ValSlider.Size = UDim2.new(0, 15, 0, 100)
            ValSlider.Position = UDim2.new(1, -110, 0.5, -50)
            ValSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ValSlider.BorderSizePixel = 0
            ValSlider.Text = ""
            ValSlider.ZIndex = 7
            ValSlider.Parent = PickerRow
            Instance.new("UICorner", ValSlider).CornerRadius = UDim.new(0, 4)

            local ValGradient = Instance.new("UIGradient")
            ValGradient.Rotation = 90
            ValGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
            })
            ValGradient.Parent = ValSlider

            local ValPin = Instance.new("Frame")
            ValPin.Size = UDim2.new(1, 4, 0, 4)
            ValPin.Position = UDim2.new(0, -2, 0, 0)
            ValPin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ValPin.BorderSizePixel = 0
            ValPin.ZIndex = 8
            ValPin.Parent = ValSlider
            Instance.new("UIStroke", ValPin).Color = Color3.fromRGB(0, 0, 0)

            -- Internal State
            local currentH, currentS, currentV = defaultColor:ToHSV()
            local pickingWheel = false
            local pickingVal = false

            local function updateColor()
                local finalColor = Color3.fromHSV(currentH, currentS, currentV)
                ColorPreview.BackgroundColor3 = finalColor
                ValGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(currentH, currentS, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                })
                callback(finalColor)
            end

            -- Place initial pins based on default color HSV calculations
            local function updatePins()
                local r = currentS * 50
                local angle = currentH * (math.pi * 2)
                WheelPin.Position = UDim2.new(0, 50 + math.cos(angle) * r, 0, 50 - math.sin(angle) * r)
                ValPin.Position = UDim2.new(0, -2, 1 - currentV, -2)
            end

            -- Update HSV based on selection position within the Color Wheel circle boundary
            local function processWheel(x, y)
                local rPos = Vector2.new(x - Wheel.AbsolutePosition.X - 50, y - Wheel.AbsolutePosition.Y - 50)
                local dist = math.clamp(rPos.Magnitude, 0, 50)
                local angle = math.atan2(-rPos.Y, rPos.X)
                if angle < 0 then angle = angle + (math.pi * 2) end
                
                currentH = angle / (math.pi * 2)
                currentS = dist / 50
                WheelPin.Position = UDim2.new(0, 50 + math.cos(angle) * dist, 0, 50 - math.sin(angle) * dist)
                updateColor()
            end

            local function processSlider(y)
                local pct = math.clamp((y - ValSlider.AbsolutePosition.Y) / ValSlider.AbsoluteSize.Y, 0, 1)
                currentV = 1 - pct
                ValPin.Position = UDim2.new(0, -2, pct, -2)
                updateColor()
            end

            -- Input Listeners
            Wheel.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    pickingWheel = true
                    processWheel(i.Position.X, i.Position.Y)
                end
            end)

            ValSlider.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    pickingVal = true
                    processSlider(i.Position.Y)
                end
            end)

            UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                    if pickingWheel then
                        processWheel(i.Position.X, i.Position.Y)
                    elseif pickingVal then
                        processSlider(i.Position.Y)
                    end
                end
            end)

            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    pickingWheel = false
                    pickingVal = false
                end
            end)

            updatePins()
            updateColor()

            return {
                SetColor = function(color)
                    currentH, currentS, currentV = color:ToHSV()
                    updatePins()
                    updateColor()
                end
            end
        end

        return Tab
    end

    -- =========================================================================
    -- [[ AUTOMATIC COMBINED "MISC" TAB GENERATION ]] --
    -- =========================================================================
    local MiscTab = Window:CreateTab("Misc")

    -- Customization Settings Section
    MiscTab:CreateSection("Customization Settings")

    -- Toggle RGB Outline
    MiscTab:CreateToggle({
        Name = "RGB Outline Theme",
        Default = UISettings.RGBOutline,
        Callback = function(v)
            UISettings.RGBOutline = v
        end
    })

    -- Background Stars Toggle
    MiscTab:CreateToggle({
        Name = "Background Starfield",
        Default = UISettings.StarsEnabled,
        Callback = function(v)
            UISettings.StarsEnabled = v
        end
    })

    -- Interactive Color Wheel for Theme Color selection (Replaced custom typing)
    MiscTab:CreateColorPicker({
        Name = "Theme Outline Color Picker",
        Default = UISettings.OutlineColor,
        Callback = function(color)
            UISettings.OutlineColor = color
        end
    })

    -- Control Settings Section
    MiscTab:CreateSection("Control Settings")

    -- Keybind Change Configuration Box
    MiscTab:CreateTextBox({
        Name = "Change UI Toggle Key (e.g. K, P, L)",
        Callback = function(val)
            local targetKey = string.upper(val:sub(1,1))
            pcall(function()
                local newCode = Enum.KeyCode[targetKey]
                if newCode then
                    UISettings.ToggleKey = newCode
                end
            end)
        end
    })

    return Window
end

return DaleyUI
