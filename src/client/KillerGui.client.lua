-- Shows a panel of trap buttons, visible only to whichever player is on
-- the Activator team this round. Each button just fires the matching
-- RemoteEvent; the server (KillerController) validates and applies cooldowns.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Localization = require(ReplicatedStorage:WaitForChild("Localization"))

local player = Players.LocalPlayer
local strings = Localization.Get(player.LocaleId)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillerControls"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Name = "Container"
container.BackgroundTransparency = 1
container.Size = UDim2.new(0, 240, 0, 320)
container.Position = UDim2.new(0, 20, 0, 20)
container.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = container

local buttonDefs = {
	{ TextKey = "TrapSwingLog", Remote = "TriggerSwingLog" },
	{ TextKey = "TrapHiddenSpikes", Remote = "TriggerHiddenSpikes" },
	{ TextKey = "TrapSideSpikes", Remote = "TriggerSideSpikes" },
	{ TextKey = "TrapRam", Remote = "TriggerRamTrap" },
	{ TextKey = "TrapFinalTrapdoor", Remote = "TriggerFinalTrapdoor" },
}

for _, data in ipairs(buttonDefs) do
	local button = Instance.new("TextButton")
	button.Name = data.Remote
	button.Size = UDim2.new(0, 220, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.Text = strings[data.TextKey]
	button.Parent = container

	button.Activated:Connect(function()
		Remotes[data.Remote]:FireServer()
	end)
end

local function updateVisibility()
	screenGui.Enabled = player.Team ~= nil and player.Team.Name == "Activator"
end

player:GetPropertyChangedSignal("Team"):Connect(updateVisibility)
updateVisibility()
