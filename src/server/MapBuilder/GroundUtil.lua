-- Shared helpers for building ground segments and kill zones (pits, lava,
-- swamp water) that the section builders use to lay out the course.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage:WaitForChild("Tags"))
local Common = require(script.Parent.Parent.Traps.Common)

local GroundUtil = {}
GroundUtil.GroundY = 5

function GroundUtil.buildGround(parent, name, z0, length, width, material, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Material = material or Enum.Material.Grass
	part.Color = color or Color3.fromRGB(74, 122, 56)
	part.Size = Vector3.new(width or 12, 2, length)
	part.CFrame = CFrame.new(0, GroundUtil.GroundY - 1, z0 + length / 2)
	part.Parent = parent
	return part
end

-- A non-collidable hazard volume beneath a gap/pit/lava run. Anyone who
-- falls into it dies (or is set on fire visually if isLava is true).
function GroundUtil.buildKillZone(parent, name, z0, length, width, yLevel, isLava)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(width or 40, 2, length)
	part.CFrame = CFrame.new(0, yLevel or (GroundUtil.GroundY - 60), z0 + length / 2)
	part.Parent = parent

	if isLava then
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(207, 61, 15)
		part.Transparency = 0.1
	else
		part.Material = Enum.Material.Air
		part.Transparency = 1
	end

	CollectionService:AddTag(part, Tags.KillZone)
	Common.killPart(part, 1)

	return part
end

return GroundUtil
