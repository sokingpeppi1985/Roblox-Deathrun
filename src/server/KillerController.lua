-- Validates and dispatches the Killer's manual trap triggers. Every
-- RemoteEvent fired from KillerGui.client.lua lands here first: we check
-- that the sender actually is the current Killer, that the round is live,
-- and that the trap isn't on cooldown, before calling into the trigger
-- function the matching trap module handed back to MapBuilder.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local RoundManager = require(script.Parent.RoundManager)

local COOLDOWNS = {
	TriggerSwingLog = 3,
	TriggerHiddenSpikes = 5,
	TriggerSideSpikes = 4,
	TriggerRamTrap = 6,
	TriggerFinalTrapdoor = 0,
}

local TRIGGER_KEYS = {
	TriggerSwingLog = "SwingLog",
	TriggerHiddenSpikes = "HiddenSpikes",
	TriggerSideSpikes = "SideSpikes",
	TriggerRamTrap = "RamTrap",
	TriggerFinalTrapdoor = "FinalTrapdoor",
}

local lastUse = {}

local function canUse(player, remoteName)
	if RoundManager.GetKiller() ~= player then
		return false
	end
	if not RoundManager.IsRoundActive() then
		return false
	end
	local cooldown = COOLDOWNS[remoteName] or 2
	local now = os.clock()
	if lastUse[remoteName] and now - lastUse[remoteName] < cooldown then
		return false
	end
	lastUse[remoteName] = now
	return true
end

local KillerController = {}

function KillerController.Init(triggers)
	for remoteName, triggerKey in pairs(TRIGGER_KEYS) do
		local remote = Remotes[remoteName]
		remote.OnServerEvent:Connect(function(player)
			if not canUse(player, remoteName) then
				return
			end
			local trigger = triggers[triggerKey]
			if trigger then
				task.spawn(trigger)
			end
		end)
	end
end

return KillerController
