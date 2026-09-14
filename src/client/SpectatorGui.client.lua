-- Camera-follow spectator mode for eliminated Runners. When the server
-- fires PlayerEliminated at this client, the local character stays where
-- it died (auto-respawn is disabled server-side for the rest of the
-- round) and the camera instead follows a living Runner, cyclable with
-- the < / > buttons. Falls back to watching the Activator if no Runners
-- are left racing. Exits automatically at the next round (KillerAssigned
-- fires once per round, right as teams are reassigned).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Localization = require(ReplicatedStorage:WaitForChild("Localization"))

local player = Players.LocalPlayer
local strings = Localization.Get(player.LocaleId)
local camera = Workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpectatorGui"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 320, 0, 28)
title.Position = UDim2.new(0.5, -160, 1, -96)
title.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Text = strings.SpectatorTitle
title.Parent = screenGui

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 320, 0, 40)
bar.Position = UDim2.new(0.5, -160, 1, -60)
bar.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
bar.BackgroundTransparency = 0.15
bar.Parent = screenGui

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 8)
barCorner.Parent = bar

local prevButton = Instance.new("TextButton")
prevButton.Size = UDim2.new(0, 40, 1, 0)
prevButton.BackgroundTransparency = 1
prevButton.Font = Enum.Font.GothamBold
prevButton.TextSize = 20
prevButton.TextColor3 = Color3.new(1, 1, 1)
prevButton.Text = "<"
prevButton.Parent = bar

local nextButton = Instance.new("TextButton")
nextButton.Size = UDim2.new(0, 40, 1, 0)
nextButton.Position = UDim2.new(1, -40, 0, 0)
nextButton.BackgroundTransparency = 1
nextButton.Font = Enum.Font.GothamBold
nextButton.TextSize = 20
nextButton.TextColor3 = Color3.new(1, 1, 1)
nextButton.Text = ">"
nextButton.Parent = bar

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -80, 1, 0)
nameLabel.Position = UDim2.new(0, 40, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextSize = 15
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Text = ""
nameLabel.Parent = bar

local spectating = false
local targetIndex = 1

local function getRacingRunners()
	local targets = {}
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Team and other.Team.Name == "Runners" then
			local humanoid = other.Character and other.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				table.insert(targets, other)
			end
		end
	end
	return targets
end

local function watch(targetPlayer)
	local humanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	camera.CameraSubject = humanoid
	nameLabel.Text = targetPlayer.Name
	return true
end

-- Nobody left racing (everyone else finished or died too) - watch the
-- Activator instead of leaving the camera stuck on nothing.
local function watchActivatorFallback()
	for _, other in ipairs(Players:GetPlayers()) do
		if other.Team and other.Team.Name == "Activator" and watch(other) then
			return
		end
	end
end

local function applyTarget()
	local targets = getRacingRunners()
	if #targets == 0 then
		watchActivatorFallback()
		return
	end

	targetIndex = ((targetIndex - 1) % #targets) + 1
	watch(targets[targetIndex])
end

prevButton.Activated:Connect(function()
	targetIndex -= 1
	applyTarget()
end)

nextButton.Activated:Connect(function()
	targetIndex += 1
	applyTarget()
end)

local function enterSpectatorMode()
	if spectating then
		return
	end
	spectating = true
	targetIndex = 1
	screenGui.Enabled = true
	camera.CameraType = Enum.CameraType.Custom
	applyTarget()
end

local function exitSpectatorMode()
	if not spectating then
		return
	end
	spectating = false
	screenGui.Enabled = false
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = nil
end

Remotes.PlayerEliminated.OnClientEvent:Connect(enterSpectatorMode)
Remotes.KillerAssigned.OnClientEvent:Connect(exitSpectatorMode)
