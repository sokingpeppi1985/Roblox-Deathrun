-- Shows a panel of trap buttons, visible only to whichever player is on
-- the Killer team this round. Each button just fires the matching
-- RemoteEvent; the server (KillerController) validates and applies cooldowns.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local player = Players.LocalPlayer

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
	{ Text = "Ускорить бревно (1.2)", Remote = "TriggerSwingLog" },
	{ Text = "Шипы в траве (2.2)", Remote = "TriggerHiddenSpikes" },
	{ Text = "Шипы в коридоре (3.2)", Remote = "TriggerSideSpikes" },
	{ Text = "Таран (4.3)", Remote = "TriggerRamTrap" },
	{ Text = "Финальный люк (5.2)", Remote = "TriggerFinalTrapdoor" },
}

for _, data in ipairs(buttonDefs) do
	local button = Instance.new("TextButton")
	button.Name = data.Remote
	button.Size = UDim2.new(0, 220, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.Text = data.Text
	button.Parent = container

	button.Activated:Connect(function()
		Remotes[data.Remote]:FireServer()
	end)
end

local function updateVisibility()
	screenGui.Enabled = player.Team ~= nil and player.Team.Name == "Killer"
end

player:GetPropertyChangedSignal("Team"):Connect(updateVisibility)
updateVisibility()
