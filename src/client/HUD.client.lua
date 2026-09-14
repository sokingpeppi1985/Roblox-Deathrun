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

-- Persistent coin balance, read straight off leaderstats (server is the
-- source of truth; this just mirrors the IntValue).
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(0, 160, 0, 32)
coinsLabel.Position = UDim2.new(1, -180, 0, 20)
coinsLabel.BackgroundTransparency = 0.4
coinsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextSize = 18
coinsLabel.Text = "Монеты: 0"
coinsLabel.Parent = screenGui

local function bindCoinsLabel()
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Монеты")
	local function refresh()
		coinsLabel.Text = "Монеты: " .. coins.Value
	end
	coins:GetPropertyChangedSignal("Value"):Connect(refresh)
	refresh()
end
task.spawn(bindCoinsLabel)

-- Floating "+N" popup whenever the server grants coins, purely visual and
-- driven client-side (tweened locally, no gameplay state involved).
local TweenService = game:GetService("TweenService")

Remotes.CoinsAwarded.OnClientEvent:Connect(function(amount, reason)
	local popup = Instance.new("TextLabel")
	popup.Size = UDim2.new(0, 200, 0, 28)
	popup.Position = UDim2.new(1, -180, 0, 56)
	popup.BackgroundTransparency = 1
	popup.TextColor3 = Color3.fromRGB(255, 215, 0)
	popup.Font = Enum.Font.GothamBold
	popup.TextSize = 16
	popup.TextXAlignment = Enum.TextXAlignment.Left
	popup.Text = string.format("+%d монет — %s", amount, reason)
	popup.Parent = screenGui

	local tween = TweenService:Create(
		popup,
		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = popup.Position - UDim2.new(0, 0, 0, 30), TextTransparency = 1 }
	)
	tween:Play()
	tween.Completed:Connect(function()
		popup:Destroy()
	end)
end)
