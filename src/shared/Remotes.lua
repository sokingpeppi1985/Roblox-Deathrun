-- Creates (or fetches) the RemoteEvents used to let the Killer trigger
-- manual traps, and to push round status to clients. Safe to require from
-- both server and client - only the server ever creates the instances in
-- practice, since this module is required by init.server.lua first.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("DeathrunRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "DeathrunRemotes"
	folder.Parent = ReplicatedStorage
end

local eventNames = {
	"TriggerSwingLog",
	"TriggerHiddenSpikes",
	"TriggerSideSpikes",
	"TriggerRamTrap",
	"TriggerFinalTrapdoor",
	"RoundStatus",
	"KillerAssigned",
}

local Remotes = {}

for _, name in ipairs(eventNames) do
	local event = folder:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = folder
	end
	Remotes[name] = event
end

return Remotes
