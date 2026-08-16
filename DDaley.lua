-- SAFE TO USE UI PARENT (Completely avoids the nil gethui call error)
local TargetParent = CoreGui or (LP and LP:WaitForChild("PlayerGui"))

-- Global active dropdown tracker to close existing open menus
local ActiveDropdownFrame = nil

-- =========================================================================
-- [[ GLOBAL MOUSE STATE TRACKER (FIXES ENUM ERRORS) ]] --
-- =========================================================================
@@ -56,7 +53,7 @@ local UISettings = {
function DaleyUI:CreateWindow(config)
    config = config or {}
    local windowName  = config.Name     or "Daley Hub"
    

    -- Force-resolve a strict string fallback immediately so clipboard never fails
    local rawDiscord = config.Discord or config.discord or "https://discord.gg/YaBAzdzh9m"
    local discordLink = tostring(rawDiscord)
@@ -130,10 +127,10 @@ function DaleyUI:CreateWindow(config)

    RunService.RenderStepped:Connect(function(dt)
        if not ScreenGui.Parent then return end
        

        -- Instantly toggle visual container visibility based on global setting
        StarContainer.Visible = UISettings.StarsEnabled
        

        if UISettings.StarsEnabled then
            for _, sd in ipairs(stars) do
                local nx = sd.f.Position.X.Scale - sd.spd * dt
@@ -264,7 +261,7 @@ function DaleyUI:CreateWindow(config)
        discDebounce = true
        DiscBtn.Text = "Copied!"
        TweenService:Create(DiscBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
        

        pcall(function()
            if setclipboard then setclipboard(discordLink)
            elseif toclipboard then toclipboard(discordLink)
@@ -274,7 +271,7 @@ function DaleyUI:CreateWindow(config)
            elseif fluxus and fluxus.set_clipboard then fluxus.set_clipboard(discordLink)
            end
        end)
        

        task.wait(2)
        DiscBtn.Text = "Join Discord"
        TweenService:Create(DiscBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
@@ -290,9 +287,10 @@ function DaleyUI:CreateWindow(config)
            startPos  = WindowFrame.Position
        end
    end)
    

    UserInputService.InputChanged:Connect(function(i)
        if dragging then
            -- Fallback verification using custom state tracker (Fixes sticking)
            if not isLeftMouseDown then
                dragging = false
                return
@@ -306,7 +304,7 @@ function DaleyUI:CreateWindow(config)
            end
        end
    end)
    

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
@@ -396,25 +394,8 @@ function DaleyUI:CreateWindow(config)
    PageContainer.ZIndex                 = 3
    PageContainer.Parent                 = WindowFrame

    -- Overlay Container for Dropdowns so they don't get clipped by Page Container
    local OverlayContainer = Instance.new("Frame")
    OverlayContainer.Name                   = "OverlayContainer"
    OverlayContainer.Size                   = UDim2.new(1, 0, 1, 0)
    OverlayContainer.BackgroundTransparency = 1
    OverlayContainer.ZIndex                 = 100
    OverlayContainer.ClipsDescendants       = false
    OverlayContainer.Parent                 = WindowFrame

    -- Close dropdowns when scrolling
    local function closeActiveDropdown()
        if ActiveDropdownFrame then
            ActiveDropdownFrame.Visible = false
            ActiveDropdownFrame = nil
        end
    end

    -- =========================================================================
    -- [[ TRANSPARENT 4-CORNER RESIZE HANDLERS ]] --
    -- [[ TRANSPARENT 4-CORNER RESIZE HANDLERS (STUCK-PROOF) ]] --
    -- =========================================================================
    local resizeHandles = {
        BR = { Pos = UDim2.new(1, -16, 1, -16), Anchor = Vector2.new(0,0), FactorX = 1,  FactorY = 1,  MoveX = 0, MoveY = 0 },
@@ -451,23 +432,25 @@ function DaleyUI:CreateWindow(config)
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

@@ -486,7 +469,7 @@ function DaleyUI:CreateWindow(config)
    end)

    local activeTabBtn = nil
    local tabCount = 0
    local tabCount = 0 -- Keeps track of custom tab creation order

    -- =====================================================================
    -- Window Object
@@ -509,7 +492,7 @@ function DaleyUI:CreateWindow(config)
        Btn.Font                   = Enum.Font.GothamMedium
        Btn.TextXAlignment         = Enum.TextXAlignment.Left
        Btn.ZIndex                 = 4
        Btn.LayoutOrder            = layoutOrder or tabCount
        Btn.LayoutOrder            = layoutOrder or tabCount -- High custom priority defaults or standard auto-incremental ordering
        Btn.Parent                 = TabContainer
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

@@ -522,6 +505,7 @@ function DaleyUI:CreateWindow(config)
        Accent.ZIndex                 = 5
        Accent.Parent                 = Btn

        -- Maintain aesthetic accent matching
        task.spawn(function()
            while ScreenGui.Parent do
                if UISettings.RGBOutline then
@@ -547,11 +531,8 @@ function DaleyUI:CreateWindow(config)
        Page.ScrollingDirection     = Enum.ScrollingDirection.Y
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        Page.ClipsDescendants       = true
        Page.Parent                 = PageContainer

        Page:GetPropertyChangedSignal("CanvasPosition"):Connect(closeActiveDropdown)

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding   = UDim.new(0, 7)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
@@ -568,9 +549,9 @@ function DaleyUI:CreateWindow(config)
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 25)
        end)

        -- Tab click logic
        Btn.MouseButton1Click:Connect(function()
            if activeTabBtn == Btn then return end
            closeActiveDropdown()
            for _, child in ipairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.18), {
@@ -595,6 +576,7 @@ function DaleyUI:CreateWindow(config)
            TweenService:Create(Accent, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
        end)

        -- Auto-select first loaded tab ONLY if it is not UI Settings
        if not activeTabBtn and name ~= "UI Settings" then
            activeTabBtn = Btn
            Page.Visible = true
@@ -898,7 +880,8 @@ function DaleyUI:CreateWindow(config)
            Wrapper.Size             = UDim2.new(1, 0, 0, 38)
            Wrapper.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            Wrapper.BorderSizePixel  = 0
            Wrapper.ZIndex           = 5
            Wrapper.ZIndex           = 15
            Wrapper.ClipsDescendants = false
            Wrapper.Parent           = Page
            Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 7)

@@ -911,7 +894,7 @@ function DaleyUI:CreateWindow(config)
            Lbl.TextSize               = 12
            Lbl.Font                   = Enum.Font.GothamMedium
            Lbl.TextXAlignment         = Enum.TextXAlignment.Left
            Lbl.ZIndex                 = 6
            Lbl.ZIndex                 = 16
            Lbl.Parent                 = Wrapper

            local SelBtn = Instance.new("TextButton")
@@ -923,23 +906,23 @@ function DaleyUI:CreateWindow(config)
            SelBtn.TextSize         = 11
            SelBtn.Font             = Enum.Font.GothamBold
            SelBtn.BorderSizePixel  = 0
            SelBtn.ZIndex           = 7
            SelBtn.ZIndex           = 17
            SelBtn.Parent           = Wrapper
            Instance.new("UICorner", SelBtn).CornerRadius = UDim.new(0, 6)

            -- DropFrame parented to OverlayContainer so it never gets clipped by Page bounds
            local DropFrame = Instance.new("ScrollingFrame")
            DropFrame.Size                   = UDim2.new(0, 138, 0, math.clamp(#list * 28, 0, 140))
            DropFrame.Size                   = UDim2.new(1, 0, 0, math.clamp(#list * 28, 0, 140))
            DropFrame.Position               = UDim2.new(0, 0, 1, 3)
            DropFrame.BackgroundColor3       = Color3.fromRGB(20, 20, 25)
            DropFrame.BorderSizePixel        = 0
            DropFrame.Visible                = false
            DropFrame.ZIndex                 = 200
            DropFrame.ZIndex                 = 50
            DropFrame.ScrollBarThickness     = 3
            DropFrame.ScrollBarImageColor3   = Color3.fromRGB(255, 50, 50)
            DropFrame.ScrollingDirection     = Enum.ScrollingDirection.Y
            DropFrame.Active                 = true
            DropFrame.CanvasSize             = UDim2.new(0, 0, 0, #list * 28)
            DropFrame.Parent                 = OverlayContainer
            DropFrame.Parent                 = Wrapper
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

            local DStroke = Instance.new("UIStroke", DropFrame)
@@ -950,34 +933,9 @@ function DaleyUI:CreateWindow(config)
            DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local open = false

            local function updateDropPosition()
                local btnPos = SelBtn.AbsolutePosition
                local winPos = WindowFrame.AbsolutePosition
                local relX = btnPos.X - winPos.X
                local relY = btnPos.Y - winPos.Y + SelBtn.AbsoluteSize.Y + 3
                DropFrame.Position = UDim2.new(0, relX, 0, relY)
            end

            local function setOpenState(state)
                open = state
                if open then
                    if ActiveDropdownFrame and ActiveDropdownFrame ~= DropFrame then
                        ActiveDropdownFrame.Visible = false
                    end
                    updateDropPosition()
                    ActiveDropdownFrame = DropFrame
                    DropFrame.Visible = true
                else
                    DropFrame.Visible = false
                    if ActiveDropdownFrame == DropFrame then
                        ActiveDropdownFrame = nil
                    end
                end
            end

            SelBtn.MouseButton1Click:Connect(function()
                setOpenState(not open)
                open = not open
                DropFrame.Visible = open
            end)

            local function createOptionButton(item)
@@ -988,7 +946,7 @@ function DaleyUI:CreateWindow(config)
                Opt.TextColor3             = Color3.fromRGB(180, 180, 188)
                Opt.TextSize               = 11
                Opt.Font                   = Enum.Font.GothamMedium
                Opt.ZIndex                 = 201
                Opt.ZIndex                 = 51
                Opt.Parent                 = DropFrame

                Opt.MouseEnter:Connect(function()
@@ -998,7 +956,8 @@ function DaleyUI:CreateWindow(config)
                    TweenService:Create(Opt, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(180,180,188)}):Play()
                end)
                Opt.MouseButton1Click:Connect(function()
                    setOpenState(false)
                    open = false
                    DropFrame.Visible = false
                    SelBtn.Text = item
                    callback(item)
                end)
@@ -1019,7 +978,7 @@ function DaleyUI:CreateWindow(config)
                            child:Destroy()
                        end
                    end
                    DropFrame.Size = UDim2.new(0, 138, 0, math.clamp(#newList * 28, 0, 140))
                    DropFrame.Size = UDim2.new(1, 0, 0, math.clamp(#newList * 28, 0, 140))
                    DropFrame.CanvasSize = UDim2.new(0, 0, 0, #newList * 28)
                    for _, item in ipairs(newList) do
                        createOptionButton(item)
@@ -1067,6 +1026,7 @@ function DaleyUI:CreateWindow(config)
            Label.ZIndex = 6
            Label.Parent = PickerRow

            -- Current Color Indicator Box
            local ColorPreview = Instance.new("Frame")
            ColorPreview.Size = UDim2.new(0, 50, 0, 20)
            ColorPreview.Position = UDim2.new(0, 12, 0, 45)
@@ -1080,14 +1040,16 @@ function DaleyUI:CreateWindow(config)
            PreviewStroke.Color = Color3.fromRGB(45, 45, 55)
            PreviewStroke.Thickness = 1

            -- Color Wheel Image (Radial HSV Color Map Asset)
            local Wheel = Instance.new("ImageButton")
            Wheel.Size = UDim2.new(0, 100, 0, 100)
            Wheel.Position = UDim2.new(1, -240, 0.5, -50)
            Wheel.BackgroundTransparency = 1
            Wheel.Image = "rbxassetid://415583266"
            Wheel.Image = "rbxassetid://415583266" -- Default High-Res Color Wheel asset
            Wheel.ZIndex = 7
            Wheel.Parent = PickerRow

            -- Cursor Selection Pin
            local WheelPin = Instance.new("Frame")
            WheelPin.Size = UDim2.new(0, 8, 0, 8)
            WheelPin.AnchorPoint = Vector2.new(0.5, 0.5)
@@ -1098,6 +1060,7 @@ function DaleyUI:CreateWindow(config)
            Instance.new("UICorner", WheelPin).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", WheelPin).Color = Color3.fromRGB(0, 0, 0)

            -- Saturation / Value Vertical Slider Bar
            local ValSlider = Instance.new("TextButton")
            ValSlider.Size = UDim2.new(0, 15, 0, 100)
            ValSlider.Position = UDim2.new(1, -110, 0.5, -50)
@@ -1125,6 +1088,7 @@ function DaleyUI:CreateWindow(config)
            ValPin.Parent = ValSlider
            Instance.new("UIStroke", ValPin).Color = Color3.fromRGB(0, 0, 0)

            -- Internal State
            local currentH, currentS, currentV = defaultColor:ToHSV()
            local pickingWheel = false
            local pickingVal = false
@@ -1139,19 +1103,21 @@ function DaleyUI:CreateWindow(config)
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
@@ -1165,6 +1131,7 @@ function DaleyUI:CreateWindow(config)
                updateColor()
            end

            -- Input Listeners
            Wheel.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    pickingWheel = true
@@ -1213,11 +1180,14 @@ function DaleyUI:CreateWindow(config)

    -- =========================================================================
    -- [[ AUTOMATIC COMBINED "UI Settings" TAB GENERATION ]] --
    -- Layout Priority = 9999 ensures this is always at the absolute bottom.
    -- =========================================================================
    local MiscTab = Window:CreateTab("UI Settings", 9999)

    -- Customization Settings Section
    MiscTab:CreateSection("Customization Settings")

    -- Toggle RGB Outline
    MiscTab:CreateToggle({
        Name = "RGB Outline Theme",
        Default = UISettings.RGBOutline,
@@ -1226,6 +1196,7 @@ function DaleyUI:CreateWindow(config)
        end
    })

    -- Background Stars Toggle
    MiscTab:CreateToggle({
        Name = "Background Starfield",
        Default = UISettings.StarsEnabled,
@@ -1234,6 +1205,7 @@ function DaleyUI:CreateWindow(config)
        end
    })

    -- ========== ANTI-AFK TOGGLE (ADDED) ==========
    local antiAFKRunning = false
    local antiAFKTask = nil

@@ -1251,7 +1223,7 @@ function DaleyUI:CreateWindow(config)
                            vu:CaptureController()
                            vu:ClickButton2(Vector2.new())
                        end)
                        task.wait(60)
                        task.wait(60) -- Adjust interval if needed
                    end
                end)
            else
@@ -1262,7 +1234,9 @@ function DaleyUI:CreateWindow(config)
            end
        end
    })
    -- =============================================

    -- Interactive Color Wheel for Theme Color selection (Replaced custom typing)
    MiscTab:CreateColorPicker({
        Name = "Theme Outline Color Picker",
        Default = UISettings.OutlineColor,
@@ -1271,8 +1245,10 @@ function DaleyUI:CreateWindow(config)
        end
    })

    -- Control Settings Section
    MiscTab:CreateSection("Control Settings")

    -- Keybind Change Configuration Box
    MiscTab:CreateTextBox({
        Name = "Change UI Toggle Key (e.g. K, P, L)",
        Callback = function(val)
