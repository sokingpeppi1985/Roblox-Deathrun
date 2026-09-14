-- Round loop: waits for players, picks one Killer at random, teleports
-- everyone to the start, runs a countdown while runners try to reach the
-- finish line, and declares a winner when the timer runs out or everyone
-- on one side is done.

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local RewardManager = require(script.Parent.Economy.RewardManager)

local ROUND_TIME = 240
local INTERMISSION_TIME = 15
local POST_ROUND_PAUSE = 8

local RoundManager = {}

local function getOrCreateTeam(name, color, autoAssign)
	local team = Teams:FindFirstChild(name)
	if not team then
		team = Instance.new("Team")
		team.Name = name
		team.TeamColor = color
		team.AutoAssignable = autoAssign
		team.Parent = Teams
	end
	return team
end

local killerTeam = getOrCreateTeam("Activator", BrickColor.new("Really red"), false)
local runnerTeam = getOrCreateTeam("Runners", BrickColor.new("Bright blue"), true)

local currentKiller = nil
local roundActive = false
local finishedPlayers = {}
local firstFinisher = false

-- Awards the Killer coins whenever a Runner's Humanoid dies during a live
-- round, regardless of which trap (or respawn cycle) caused it.
local function trackDeaths(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			if roundActive and currentKiller and player ~= currentKiller and player.Team == runnerTeam then
				RewardManager.AwardKill(currentKiller)
			end
		end)
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	trackDeaths(player)
end
Players.PlayerAdded:Connect(trackDeaths)

function RoundManager.GetKiller()
	return currentKiller
end

function RoundManager.IsRoundActive()
	return roundActive
end

-- Sends a status key (not literal text) so each client can render it in its
-- own language via Localization.lua. `param` is either a number (countdown
-- / time left) or a player name, depending on the key.
local function broadcastStatus(statusKey, param)
	Remotes.RoundStatus:FireAllClients(statusKey, param)
end

local function assignTeams()
	local players = Players:GetPlayers()
	if #players == 0 then
		return nil
	end
	currentKiller = players[math.random(1, #players)]
	currentKiller.Team = killerTeam
	for _, player in ipairs(players) do
		if player ~= currentKiller then
			player.Team = runnerTeam
		end
	end
	Remotes.KillerAssigned:FireAllClients(currentKiller)
	return currentKiller
end

local function teleportAll(spawnCFrame)
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
		hrp.CFrame = spawnCFrame
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
	end
end

local function countAliveRunners()
	local alive = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= currentKiller and player.Team == runnerTeam and not finishedPlayers[player] then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				alive += 1
			end
		end
	end
	return alive
end

local function countTotalRunners()
	local total = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= currentKiller then
			total += 1
		end
	end
	return total
end

function RoundManager.PlayerFinished(player)
	if not roundActive or player == currentKiller or finishedPlayers[player] then
		return
	end
	finishedPlayers[player] = true

	local isFirst = not firstFinisher
	firstFinisher = true
	RewardManager.AwardFinish(player, isFirst)

	broadcastStatus("player_finished", player.Name)
end

function RoundManager.Start(mapData)
	mapData.FinishLine.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			RoundManager.PlayerFinished(player)
		end
	end)

	task.spawn(function()
		while true do
			broadcastStatus("waiting", nil)
			while #Players:GetPlayers() < 2 do
				task.wait(2)
			end

			for i = INTERMISSION_TIME, 1, -1 do
				broadcastStatus("intermission", i)
				task.wait(1)
			end

			finishedPlayers = {}
			firstFinisher = false
			assignTeams()
			teleportAll(mapData.SpawnCFrame)
			roundActive = true

			local timeLeft = ROUND_TIME
			local result = nil

			while timeLeft > 0 do
				broadcastStatus("active", timeLeft)
				task.wait(1)
				timeLeft -= 1

				if countAliveRunners() == 0 then
					result = "killer"
					break
				end

				local total = countTotalRunners()
				local finishedCount = 0
				for _ in pairs(finishedPlayers) do
					finishedCount += 1
				end
				if total > 0 and finishedCount >= total then
					result = "runners"
					break
				end
			end

			result = result or "killer"
			roundActive = false

			if result == "killer" then
				broadcastStatus("activator_win", nil)
				RewardManager.AwardTeamWin({ currentKiller })
			else
				broadcastStatus("runners_win", nil)
				local runners = {}
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= currentKiller then
						table.insert(runners, player)
					end
				end
				RewardManager.AwardTeamWin(runners)
			end

			currentKiller = nil
			task.wait(POST_ROUND_PAUSE)
		end
	end)
end

return RoundManager
