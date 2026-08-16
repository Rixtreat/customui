local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rixtreat/customui/main/DDaley.lua"))()

local Window = UI:CreateWindow({
    Name = "Game Hub",
    SubTitle = "by Daley"
})

-- Tabs
local MainTab = Window:CreateTab("Movement Controls")
local AutoTab = Window:CreateTab("Automation")

-- Services & References
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Remote Reference
local RemoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Events"):WaitForChild("RemoteEvent")

-- State Variables: Movement
local SpeedEnabled = false
local WalkSpeedValue = 16

local NoclipEnabled = false

local FlyEnabled = false
local FlySpeedValue = 50
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil

-- Config Mapping: Index -> Enemy & Difficulty Meta
local IndexToEnemyMeta = {
    ["1"] = { EnemyId = "Sand", Difficulty = "Easy" },
    ["2"] = { EnemyId = "Lokki", Difficulty = "Medium" },
    ["3"] = { EnemyId = "Xebek", Difficulty = "Hard" },
    ["4"] = { EnemyId = "Blakbeard", Difficulty = "Ultra Hard" },
    ["5"] = { EnemyId = "Kizaro", Difficulty = "Boss" }
}

-- State Variables: Auto Farm Spawners
local AutoFarmEnabled = false
local AutoFarmInterval = 1
local FarmWalkSpeed = 50
local SelectedFarmTarget = "All"
local currentSpawnerIndex = 1

-- State Variables: Network Automations
local AutoRankUpEnabled = false
local AutoRankUpInterval = 0.5
local AutoCoinUpgradesEnabled = false
local AutoCoinUpgradesInterval = 0.5

local AutoAttackUpgradeEnabled = false
local AutoAttackUpgradeInterval = 0.5
local SelectedAttackUpgradeType = "Radius"

local AutoAscendEnabled = false
local AutoAscendInterval = 1
local SelectedAscendTier = 1
local SelectedAscendCharacter = "Garuo"

local AutoSummonEnabled = false
local AutoSummonInterval = 0.5
local SelectedSummonBanner = "Mythic"
local SelectedSummonAmount = 1
local SelectedSummonType = "Normal"

local AutoRollEnabled = false
local AutoClaimEnabled = false
local AutoJoinDungeonEnabled = false
local AutoJoinDungeonInterval = 1

local SelectedRollMode = "single"
local SelectedBanner = "skylands"

-- State Variables: Auto Skill Tree
local AutoSkillTreeEnabled = false
local AutoSkillTreeInterval = 0.5
local SkillTreeController = nil

-- State Variables: Key Spammers
local AutoSpamGEnabled = false
local AutoSpamGInterval = 0.1

local AutoSpamVEnabled = false
local AutoSpamVInterval = 0.1

-- Helper Functions
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function stopFlying()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

local function toggleFly(enable)
    if not enable then stopFlying() return end

    local char = getCharacter()
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    stopFlying()

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Name = "CustomFlyVelocity"
    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "CustomFlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.P = 9e4
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not FlyEnabled or not char or not root or not root.Parent or not cam then 
            stopFlying() 
            return 
        end

        humanoid.PlatformStand = true
        local moveVector = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end

        if moveVector.Magnitude > 0 then moveVector = moveVector.Unit end

        flyBodyVelocity.Velocity = moveVector * FlySpeedValue
        flyBodyGyro.CFrame = cam.CFrame
    end)
end

-- Helper Function to simulate key presses safely
local function pressKey(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

-- Filter Match Checker
local function matchesFilter(enemyId, difficulty, selection)
    if selection == "All" or not selection then return true end

    -- Difficulty Match
    if selection == "Easy" and difficulty == "Easy" then return true end
    if selection == "Medium" and difficulty == "Medium" then return true end
    if selection == "Hard" and difficulty == "Hard" then return true end
    if selection == "Ultra Hard" and difficulty == "Ultra Hard" then return true end
    if selection == "Boss" and difficulty == "Boss" then return true end

    -- Enemy Name Match
    if string.lower(enemyId) == string.lower(selection) then return true end

    return false
end

-- ===== AUTO FARM NORMAL WALKING TO SPAWNERS LOGIC =====

local function scanSpawners()
    local spawnersList = {}
    local zonesFolder = workspace:FindFirstChild("Zones")
    local skylandsFolder = zonesFolder and zonesFolder:FindFirstChild("skylands")
    local spawnersFolder = skylandsFolder and skylandsFolder:FindFirstChild("Spawners")

    if spawnersFolder then
        for _, spawner in ipairs(spawnersFolder:GetChildren()) do
            local spawnerName = tostring(spawner.Name)
            local meta = IndexToEnemyMeta[spawnerName] or {}

            local enemyId = spawner:GetAttribute("EnemyId") or meta.EnemyId or spawnerName
            local difficulty = spawner:GetAttribute("Difficulty") or meta.Difficulty or "Unknown"

            if matchesFilter(enemyId, difficulty, SelectedFarmTarget) then
                local targetPart = nil
                if spawner:IsA("BasePart") then
                    targetPart = spawner
                else
                    targetPart = spawner:FindFirstChild("HumanoidRootPart", true) 
                        or spawner:FindFirstChildWhichIsA("BasePart", true)
                end

                if targetPart then
                    table.insert(spawnersList, targetPart)
                end
            end
        end
    end

    return spawnersList
end

local function walkToNextSpawner()
    local spawners = scanSpawners()
    if #spawners == 0 then return end

    if currentSpawnerIndex > #spawners then currentSpawnerIndex = 1 end

    local targetSpawner = spawners[currentSpawnerIndex]
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if root and humanoid and targetSpawner and targetSpawner:IsDescendantOf(workspace) then
        humanoid:MoveTo(targetSpawner.Position)

        local reached = false
        local connection = humanoid.MoveToFinished:Connect(function()
            reached = true
        end)

        local startTime = tick()
        while not reached and AutoFarmEnabled and (tick() - startTime < 30) do
            if not root or not root.Parent or (root.Position - targetSpawner.Position).Magnitude <= 5 then
                break
            end
            task.wait(0.1)
        end

        if connection then connection:Disconnect() end

        currentSpawnerIndex = (currentSpawnerIndex % #spawners) + 1
    end
end

-- Continuous Stepped Loop for Speed & Noclip
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip Logic
    if NoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- WalkSpeed Logic
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if SpeedEnabled then
            humanoid.WalkSpeed = WalkSpeedValue
        elseif AutoFarmEnabled then
            humanoid.WalkSpeed = FarmWalkSpeed
        end
    end
end)

-- Auto Farm Loop
task.spawn(function()
    while true do
        if AutoFarmEnabled then
            pcall(walkToNextSpawner)
            task.wait(AutoFarmInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Character Reset/Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if FlyEnabled then toggleFly(true) end
    if not SpeedEnabled and not AutoFarmEnabled and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

-- ===== AUTO SKILL TREE LOGIC =====

local function getSkillTreeController()
    if SkillTreeController then return SkillTreeController end

    for _, obj in ipairs(getloadedmodules and getloadedmodules() or {}) do
        if type(obj) == "table" and rawget(obj, "GetRecommendedNode") and rawget(obj, "RequestBuy") then
            SkillTreeController = obj
            return SkillTreeController
        end
    end
    
    if getgenv().SkillTreeController then
        SkillTreeController = getgenv().SkillTreeController
    end

    return SkillTreeController
end

local function unlockAvailableNodes()
    local controller = getSkillTreeController()
    if not controller or not controller.GetRecommendedNode then return end

    local recommendedNode = controller:GetRecommendedNode()
    
    while recommendedNode and AutoSkillTreeEnabled do
        local nodeName = recommendedNode.Name
        local canUnlock = controller.CanUnlockSkill and controller:CanUnlockSkill(nodeName)
        
        if canUnlock then
            controller:RequestBuy(nodeName)
            if controller.Deselect then
                controller:Deselect()
            end
            task.wait(0.1)
            recommendedNode = controller:GetRecommendedNode()
        else
            break
        end
    end
end

-- Skill Tree Automation Loop
task.spawn(function()
    while true do
        if AutoSkillTreeEnabled then
            pcall(unlockAvailableNodes)
            task.wait(AutoSkillTreeInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ===== KEY SPAMMER AUTOMATION LOOPS =====

-- Auto Spam G Loop
task.spawn(function()
    while true do
        if AutoSpamGEnabled then
            pressKey(Enum.KeyCode.G)
            task.wait(AutoSpamGInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Spam V Loop
task.spawn(function()
    while true do
        if AutoSpamVEnabled then
            pressKey(Enum.KeyCode.V)
            task.wait(AutoSpamVInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ===== NETWORK AUTOMATION LOOPS =====

-- Auto Join Dungeon Loop
task.spawn(function()
    while true do
        if AutoJoinDungeonEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "gamemodes/join",
                        Params = {
                            "Dungeon:1"
                        }
                    }
                })
            end)
            task.wait(AutoJoinDungeonInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Rankup Power Loop
task.spawn(function()
    while true do
        if AutoRankUpEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "rankup/power",
                        Params = {}
                    }
                })
            end)
            task.wait(AutoRankUpInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Coin Upgrades Loop
task.spawn(function()
    while true do
        if AutoCoinUpgradesEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "coinupgrades/upgrade",
                        Params = {
                            "Coins"
                        }
                    }
                })
            end)
            task.wait(AutoCoinUpgradesInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Attack Upgrade Loop
task.spawn(function()
    while true do
        if AutoAttackUpgradeEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "autoAttack/upgrade",
                        Params = {
                            SelectedAttackUpgradeType
                        }
                    }
                })
            end)
            task.wait(AutoAttackUpgradeInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Ascend Loop
task.spawn(function()
    while true do
        if AutoAscendEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "Ascend",
                        Params = {
                            SelectedAscendTier,
                            SelectedAscendCharacter
                        }
                    }
                })
            end)
            task.wait(AutoAscendInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Summon Loop
task.spawn(function()
    while true do
        if AutoSummonEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "banner/requestRoll",
                        Params = {
                            "Mythic",
                            SelectedSummonAmount,
                            SelectedSummonType
                        }
                    }
                })
            end)
            task.wait(AutoSummonInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Roll Champion Loop
task.spawn(function()
    while true do
        if AutoRollEnabled then
            pcall(function()
                RemoteEvent:FireServer({
                    {
                        Path = "champions/spin",
                        Params = {
                            SelectedRollMode,
                            SelectedBanner
                        }
                    }
                })
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Claim Rewards Loop
task.spawn(function()
    while true do
        if AutoClaimEnabled then
            pcall(function()
                RemoteEvent:FireServer({{ Path = "missions/claimAll", Params = {} }})
                RemoteEvent:FireServer({{ Path = "achievement/claimAll", Params = {} }})
                RemoteEvent:FireServer({{ Path = "TimeRewards/ClaimAll", Params = {} }})
                RemoteEvent:FireServer({{ Path = "DailyRewards/Claim", Params = {} }})
            end)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

-- ===== UI CONTROLS =====

-- Movement Controls Tab
MainTab:CreateSection("Speed Settings")

MainTab:CreateToggle({
    Name = "Enable Speed Mode",
    Default = false,
    Callback = function(Value)
        SpeedEnabled = Value
        if not Value then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(Value)
        WalkSpeedValue = Value
    end,
})

MainTab:CreateSection("Collision Settings")

MainTab:CreateToggle({
    Name = "Enable Noclip Mode",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end,
})

MainTab:CreateSection("Fly Settings")

MainTab:CreateToggle({
    Name = "Enable Fly Mode",
    Default = false,
    Callback = function(Value)
        FlyEnabled = Value
        toggleFly(Value)
    end,
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 300,
    Default = 50,
    Callback = function(Value)
        FlySpeedValue = Value
    end,
})

-- Automation Tab
AutoTab:CreateSection("Gamemode Automation")

AutoTab:CreateToggle({
    Name = "Auto Join Dungeon",
    Default = false,
    Callback = function(Value)
        AutoJoinDungeonEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Dungeon Join Interval",
    Min = 0.5,
    Max = 10,
    Default = 1,
    Callback = function(Value)
        AutoJoinDungeonInterval = Value
    end,
})

AutoTab:CreateSection("Keybind Spammers")

AutoTab:CreateToggle({
    Name = "Auto Use Skill (G)",
    Default = false,
    Callback = function(Value)
        AutoSpamGEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "G Skill Delay",
    Min = 0.05,
    Max = 2,
    Default = 0.1,
    Callback = function(Value)
        AutoSpamGInterval = Value
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Use Skill (V)",
    Default = false,
    Callback = function(Value)
        AutoSpamVEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "V Skill Delay",
    Min = 0.05,
    Max = 2,
    Default = 0.1,
    Callback = function(Value)
        AutoSpamVInterval = Value
    end,
})

AutoTab:CreateSection("Skylands Spawner Auto Farm")

AutoTab:CreateDropdown({
    Name = "Farm Target Filter",
    Options = {
        "All",
        "Easy",
        "Medium",
        "Hard",
        "Ultra Hard",
        "Boss",
        "Sand",
        "Lokki",
        "Xebek",
        "Blakbeard",
        "Kizaro"
    },
    Default = "All",
    Callback = function(Option)
        SelectedFarmTarget = Option
        currentSpawnerIndex = 1
    end,
})

AutoTab:CreateToggle({
    Name = "Enable Auto Farm Spawners",
    Default = false,
    Callback = function(Value)
        AutoFarmEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Walk to Spawner Speed",
    Min = 16,
    Max = 300,
    Default = 50,
    Callback = function(Value)
        FarmWalkSpeed = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Wait Interval Between Spawners",
    Min = 0.1,
    Max = 10,
    Default = 1,
    Callback = function(Value)
        AutoFarmInterval = Value
    end,
})

AutoTab:CreateSection("Skill Tree Automation")

AutoTab:CreateToggle({
    Name = "Auto Unlock Skill Tree",
    Default = false,
    Callback = function(Value)
        AutoSkillTreeEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Skill Unlock Check Delay",
    Min = 0.1,
    Max = 5,
    Default = 0.5,
    Callback = function(Value)
        AutoSkillTreeInterval = Value
    end,
})

AutoTab:CreateSection("Character & Power Progression")

AutoTab:CreateToggle({
    Name = "Auto Upgrade Auto Attack",
    Default = false,
    Callback = function(Value)
        AutoAttackUpgradeEnabled = Value
    end,
})

AutoTab:CreateDropdown({
    Name = "Attack Upgrade Type",
    Options = {"Radius", "Interval", "Damage"},
    Default = "Radius",
    Callback = function(Option)
        SelectedAttackUpgradeType = Option
    end,
})

AutoTab:CreateSlider({
    Name = "Attack Upgrade Delay",
    Min = 0.1,
    Max = 5,
    Default = 0.5,
    Callback = function(Value)
        AutoAttackUpgradeInterval = Value
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Ascend",
    Default = false,
    Callback = function(Value)
        AutoAscendEnabled = Value
    end,
})

AutoTab:CreateTextBox({
    Name = "Ascend Character Name",
    PlaceholderText = "Garuo",
    Callback = function(Text)
        if Text and Text ~= "" then
            SelectedAscendCharacter = Text
        end
    end,
})

AutoTab:CreateSlider({
    Name = "Ascend Tier",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(Value)
        SelectedAscendTier = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Auto Ascend Delay",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Callback = function(Value)
        AutoAscendInterval = Value
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Rank Up Power",
    Default = false,
    Callback = function(Value)
        AutoRankUpEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Auto Rankup Delay",
    Min = 0.1,
    Max = 5,
    Default = 0.5,
    Callback = function(Value)
        AutoRankUpInterval = Value
    end,
})

AutoTab:CreateToggle({
    Name = "Auto Coin Upgrades",
    Default = false,
    Callback = function(Value)
        AutoCoinUpgradesEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Auto Coin Upgrade Delay",
    Min = 0.1,
    Max = 5,
    Default = 0.5,
    Callback = function(Value)
        AutoCoinUpgradesInterval = Value
    end,
})

AutoTab:CreateButton({
    Name = "Unlock Haki Gacha",
    Callback = function()
        RemoteEvent:FireServer({
            {
                Path = "systems/unlock",
                Params = {
                    "HakiGacha"
                }
            }
        })
    end,
})

-- Banner & Gacha Automation
AutoTab:CreateSection("Banner Summon Automation")

AutoTab:CreateToggle({
    Name = "Auto Summon Banner",
    Default = false,
    Callback = function(Value)
        AutoSummonEnabled = Value
    end,
})

AutoTab:CreateSlider({
    Name = "Summon Amount",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(Value)
        SelectedSummonAmount = Value
    end,
})

AutoTab:CreateDropdown({
    Name = "Summon Mode",
    Options = {"Normal", "Special"},
    Default = "Normal",
    Callback = function(Option)
        SelectedSummonType = Option
    end,
})

AutoTab:CreateSlider({
    Name = "Auto Summon Delay",
    Min = 0.1,
    Max = 5,
    Default = 0.5,
    Callback = function(Value)
        AutoSummonInterval = Value
    end,
})

AutoTab:CreateSection("Roll Configuration")

AutoTab:CreateDropdown({
    Name = "Roll Mode",
    Options = {"single", "multi"},
    Default = "single",
    Callback = function(Option)
        SelectedRollMode = Option
    end,
})

AutoTab:CreateTextBox({
    Name = "Banner Name",
    PlaceholderText = "skylands",
    Callback = function(Text)
        if Text and Text ~= "" then
            SelectedBanner = Text
        end
    end,
})

AutoTab:CreateSection("Gacha Automation")

AutoTab:CreateToggle({
    Name = "Auto Roll Champion",
    Default = false,
    Callback = function(Value)
        AutoRollEnabled = Value
    end,
})

-- Rewards Automation
AutoTab:CreateSection("Auto Claim")

AutoTab:CreateToggle({
    Name = "Auto Claim All Rewards",
    Default = false,
    Callback = function(Value)
        AutoClaimEnabled = Value
    end,
})
