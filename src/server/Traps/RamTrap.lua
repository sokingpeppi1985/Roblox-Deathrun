-- Trap 4.3: Ловушка-таран.
-- A slab of wall retracted into the cave side. On the Killer's command it
-- shoves out across the path via TweenService (physically pushing anyone
-- standing there, since it stays CanCollide = true), holds, then retracts.
-- Getting shoved off the path means falling into the lava KillZone below.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.RamTrap

local RamTrap = {}

-- direction is a Vector3 (not necessarily unit length) pointing from the
-- retracted position towards the path/lava it should shove players into.
function RamTrap.Build(parent, retractedPosition, direction)
	local wall = Instance.new("Part")
	wall.Name = "RamWall"
	wall.Anchored = true
	wall.CanCollide = true
	wall.Size = Vector3.new(2, 8, 8)
	wall.Material = Enum.Material.Rock
	wall.Color = Color3.fromRGB(80, 40, 30)
	wall.CFrame = CFrame.new(retractedPosition)
	wall.Parent = parent

	local extendedPosition = retractedPosition + direction.Unit * Config.TravelDistance
	local busy = false

	local function trigger()
		if busy then
			return
		end
		busy = true

		local outTween = TweenService:Create(
			wall,
			TweenInfo.new(Config.ExtendTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = CFrame.new(extendedPosition) }
		)
		outTween:Play()
		outTween.Completed:Wait()

		task.wait(Config.HoldTime)

		local inTween = TweenService:Create(
			wall,
			TweenInfo.new(Config.RetractTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ CFrame = CFrame.new(retractedPosition) }
		)
		inTween:Play()
		inTween.Completed:Wait()

		busy = false
	end

	return trigger
end

return RamTrap
