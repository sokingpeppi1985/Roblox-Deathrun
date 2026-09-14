-- Trap 5.2: Финальная ручная ловушка.
-- The ONE instant-kill-with-no-warning trap on the map (per the map's own
-- design rule: at most one such trap). A trapdoor right before the finish
-- that opens the instant the Killer presses the button - anyone standing
-- on it drops straight into the pit below with zero telegraph.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.FinalTrapdoor

local FinalTrapdoor = {}

function FinalTrapdoor.Build(parent, position, size)
	size = size or Vector3.new(6, 1, 6)

	local door = Instance.new("Part")
	door.Name = "FinalTrapdoor"
	door.Anchored = true
	door.Size = size
	door.Material = Enum.Material.Metal
	door.Color = Color3.fromRGB(70, 70, 75)
	door.CFrame = CFrame.new(position)
	door.Parent = parent

	local busy = false
	local function trigger()
		if busy then
			return
		end
		busy = true
		door.CanCollide = false
		door.Transparency = 0.6
		task.delay(Config.ResetTime, function()
			door.CanCollide = true
			door.Transparency = 0
			busy = false
		end)
	end

	return trigger
end

return FinalTrapdoor
