-- =========================================================================
-- PASTE THE ENTIRE DALEY UI SHELL HERE (the code from daley_ui_shell.lua)
-- =========================================================================

-- ... (all the shell code) ...

-- =========================================================================
-- YOUR TABS AND FEATURES START HERE
-- =========================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer      = Players.LocalPlayer

-- States
local speedModeEnabled = false
local walkSpeedValue   = 32
local flyModeEnabled   = false
local flySpeedValue    = 50
-- ... rest of your states ...

-- Create your tabs
local MovementTab      = CreateTab("Movement")
local AutomationTab    = CreateTab("Automations")
local WorldUpgradesTab = CreateTab("World Upgrades")

-- Movement Tab
Section(MovementTab, "Coordinates Utility")
Button(MovementTab, "Mark Coordinates (Copy to Clipboard)", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and setclipboard then
        local p = hrp.Position
        setclipboard(string.format("Vector3.new(%f, %f, %f)", p.X, p.Y, p.Z))
    end
end)

-- ... rest of your UI elements ...

-- Your background loops go at the bottom
RunService.Heartbeat:Connect(function(dt)
    -- speed logic etc
end)
