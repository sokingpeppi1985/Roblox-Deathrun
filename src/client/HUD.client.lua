-- Shows round status (waiting / countdown / timer / result) and who the
-- Activator is, pushed from RoundManager via RemoteEvents. Status and
-- reward-reason payloads are keys, not literal text, so they render in
-- each client's own language via Localization.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Localization = require(ReplicatedStorage:WaitForChild("Localization"))

local player = Players.LocalPlayer
local strings = Localization.Get(player.LocaleId)

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

local STATUS_KEYS = {
	waiting = "StatusWaiting",
	intermission = "StatusIntermission",
	active = "StatusRoundActive",
	player_finished = "StatusPlayerFinished",
	activator_win = "StatusActivatorWin",
	runners_win = "StatusRunnersWin",
}

local FORMATTED_STATUSES = {
	intermission = true,
	active = true,
	player_finished = true,
}

Remotes.RoundStatus.OnClientEvent:Connect(function(statusKey, param)
	local template = strings[STATUS_KEYS[statusKey]]
	if not template then
		return
	end
	label.Text = FORMATTED_STATUSES[statusKey] and string.format(template, param) or template
end)

Remotes.KillerAssigned.OnClientEvent:Connect(function(killerPlayer)
	if killerPlayer == player then
		label.Text = strings.YouAreActivator
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
coinsLabel.Text = string.format(strings.CoinsLabel, 0)
coinsLabel.Parent = screenGui

local function bindCoinsLabel()
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Coins")
	local function refresh()
		coinsLabel.Text = string.format(strings.CoinsLabel, coins.Value)
	end
	coins:GetPropertyChangedSignal("Value"):Connect(refresh)
	refresh()
end
task.spawn(bindCoinsLabel)

-- Floating "+N" popup whenever the server grants coins, purely visual and
-- driven client-side (tweened locally, no gameplay state involved).
local TweenService = game:GetService("TweenService")

local REASON_KEYS = {
	finish = "ReasonFinish",
	first_place = "ReasonFirstPlace",
	team_win = "ReasonTeamWin",
	kill = "ReasonKill",
}

Remotes.CoinsAwarded.OnClientEvent:Connect(function(amount, reasonKey)
	local reasonText = strings[REASON_KEYS[reasonKey]] or reasonKey

	local popup = Instance.new("TextLabel")
	popup.Size = UDim2.new(0, 200, 0, 28)
	popup.Position = UDim2.new(1, -180, 0, 56)
	popup.BackgroundTransparency = 1
	popup.TextColor3 = Color3.fromRGB(255, 215, 0)
	popup.Font = Enum.Font.GothamBold
	popup.TextSize = 16
	popup.TextXAlignment = Enum.TextXAlignment.Left
	popup.Text = string.format(strings.CoinsAwardedFormat, amount, reasonText)
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
