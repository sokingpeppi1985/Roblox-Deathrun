-- Persistent coin balance per player, backed by DataStoreService and
-- mirrored into leaderstats so it shows in Roblox's default player list.
-- The leaderstats IntValue is the in-memory source of truth during a
-- session; DataStore is only touched on join, leave, and periodic autosave
-- to stay well under Roblox's request budget.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local coinStore = DataStoreService:GetDataStore("DeathrunCoins_v1")

local AUTOSAVE_INTERVAL = 120
local MAX_RETRIES = 3

local PlayerData = {}

local function attempt(fn)
	for i = 1, MAX_RETRIES do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		task.wait(i)
	end
	return false, nil
end

local function getCoinsValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	return leaderstats and leaderstats:FindFirstChild("Монеты")
end

function PlayerData.AddCoins(player, amount)
	local coins = getCoinsValue(player)
	if coins then
		coins.Value += amount
	end
end

local function savePlayer(player)
	local coins = getCoinsValue(player)
	if not coins then
		return
	end
	local value = coins.Value
	attempt(function()
		coinStore:SetAsync("Player_" .. player.UserId, value)
	end)
end

local function loadPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Монеты"
	coins.Value = 0
	coins.Parent = leaderstats

	local ok, saved = attempt(function()
		return coinStore:GetAsync("Player_" .. player.UserId)
	end)
	if ok and saved then
		coins.Value = saved
	end
end

function PlayerData.Init()
	for _, player in ipairs(Players:GetPlayers()) do
		loadPlayer(player)
	end
	Players.PlayerAdded:Connect(loadPlayer)
	Players.PlayerRemoving:Connect(savePlayer)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				savePlayer(player)
			end
		end
	end)

	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end)
end

return PlayerData
