-- Prompts the first Runner to reach the finish each round: try to kill the
-- Activator with a sword (melee, get close) or a revolver duel (draw
-- first), or skip and just stay safely finished. Picking just replies on
-- DuelChoice - DuelManager.lua on the server does everything else
-- (teleport, weapons, resolving the fight).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Localization = require(ReplicatedStorage:WaitForChild("Localization"))

local player = Players.LocalPlayer
local strings = Localization.Get(player.LocaleId)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DuelOfferGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 1)
card.Position = UDim2.new(0.5, 0, 1, -40)
card.Size = UDim2.new(0, 420, 0, 150)
card.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
card.Visible = false
card.Parent = screenGui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextColor3 = Color3.new(1, 1, 1)
title.TextWrapped = true
title.Text = strings.DuelOfferTitle
title.Parent = card

local function makeButton(text, position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 125, 0, 44)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.Text = text
	button.Parent = card

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	return button
end

local swordButton = makeButton(strings.DuelChoiceSword, UDim2.new(0, 15, 1, -60))
local revolverButton = makeButton(strings.DuelChoiceRevolver, UDim2.new(0, 148, 1, -60))
local skipButton = makeButton(strings.DuelChoiceSkip, UDim2.new(0, 281, 1, -60))

local function respond(choice)
	card.Visible = false
	Remotes.DuelChoice:FireServer(choice)
end

swordButton.Activated:Connect(function()
	respond("sword")
end)
revolverButton.Activated:Connect(function()
	respond("revolver")
end)
skipButton.Activated:Connect(function()
	respond("skip")
end)

Remotes.DuelOffer.OnClientEvent:Connect(function()
	card.Visible = true
end)
