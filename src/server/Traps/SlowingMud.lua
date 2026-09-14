-- Trap 2.3: Замедляющая жижа.
-- A mud zone that halves WalkSpeed for as long as a player stands in it,
-- and restores it on exit. Doesn't kill on its own - it exists to make
-- runners vulnerable to whatever trap the Killer springs next.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.SlowingMud

local SlowingMud = {}

function SlowingMud.Build(parent, startZ, length, width)
	local zone = Instance.new("Part")
	zone.Name = "SlowingMud"
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 0.5
	zone.Material = Enum.Material.Mud
	zone.Color = Color3.fromRGB(64, 52, 32)
	zone.Size = Vector3.new(width, 3, length)
	zone.CFrame = CFrame.new(0, 5.5, startZ + length / 2)
	zone.Parent = parent

	local baseSpeeds = setmetatable({}, { __mode = "k" })

	zone.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or baseSpeeds[humanoid] then
			return
		end
		baseSpeeds[humanoid] = humanoid.WalkSpeed
		humanoid.WalkSpeed = humanoid.WalkSpeed * Config.SpeedMultiplier
	end)

	zone.TouchEnded:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or not baseSpeeds[humanoid] then
			return
		end
		humanoid.WalkSpeed = baseSpeeds[humanoid]
		baseSpeeds[humanoid] = nil
	end)

	return zone
end

return SlowingMud
