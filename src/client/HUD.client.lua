-- Shows round status (waiting / countdown / timer / result) and who the
-- Killer is, pushed from RoundManager via RemoteEvents.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeathrunHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 420, 0, 40)
label.Position = UDim2.new(0.5, -210, 0, 20)
label.BackgroundTransparency = 0.4
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 22
label.Text = "Deathrun"
label.Parent = screenGui

Remotes.RoundStatus.OnClientEvent:Connect(function(text, timeLeft)
	if timeLeft then
		label.Text = string.format("%s — %d сек", text, timeLeft)
	else
		label.Text = text
	end
end)

Remotes.KillerAssigned.OnClientEvent:Connect(function(killerPlayer)
	if killerPlayer == player then
		label.Text = "Вы — Убийца! Используйте панель ловушек."
	end
end)
