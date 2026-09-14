-- Awards persistent coins for round events and notifies the awarded player
-- with a toast via RemoteEvent. Amounts come from Config.Rewards so game
-- design can retune them without touching this logic.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(script.Parent.PlayerData)
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Rewards = require(ReplicatedStorage:WaitForChild("Config")).Rewards

local RewardManager = {}

local function grant(player, amount, reason)
	if not player or amount <= 0 then
		return
	end
	PlayerData.AddCoins(player, amount)
	Remotes.CoinsAwarded:FireClient(player, amount, reason)
end

function RewardManager.AwardFinish(player, isFirst)
	grant(player, Rewards.Finish, "Финиш")
	if isFirst then
		grant(player, Rewards.FirstPlace, "Первое место!")
	end
end

function RewardManager.AwardTeamWin(players)
	for _, player in ipairs(players) do
		grant(player, Rewards.TeamWin, "Победа в раунде")
	end
end

function RewardManager.AwardKill(killerPlayer)
	grant(killerPlayer, Rewards.Kill, "Убийство")
end

return RewardManager
