-- Секция 3 — Вход в пещеру.
-- Solid cave floor with two falling-stalactite hazards (3.1, automatic),
-- then a one-player-wide corridor with side spikes (3.2, Killer-triggered).

local GroundUtil = require(script.Parent.GroundUtil)
local FallingStalactites = require(script.Parent.Parent.Traps.FallingStalactites)
local SideSpikes = require(script.Parent.Parent.Traps.SideSpikes)

local Section3 = {}

local CEILING_HEIGHT = 16

function Section3.Build(parent, z)
	local caveStart = z
	local caveLength = 100
	GroundUtil.buildGround(parent, "CaveFloor", z, caveLength, 12, Enum.Material.Slate, Color3.fromRGB(60, 60, 65))

	-- cave ceiling, just for atmosphere / to hang the stalactites from
	local ceiling = Instance.new("Part")
	ceiling.Name = "CaveCeiling"
	ceiling.Anchored = true
	ceiling.Material = Enum.Material.Slate
	ceiling.Color = Color3.fromRGB(45, 45, 50)
	ceiling.Size = Vector3.new(14, 2, caveLength)
	ceiling.CFrame = CFrame.new(0, GroundUtil.GroundY + CEILING_HEIGHT + 1, caveStart + caveLength / 2)
	ceiling.Parent = parent

	FallingStalactites.Build(
		parent,
		Vector3.new(-2, GroundUtil.GroundY, caveStart + 25),
		GroundUtil.GroundY + CEILING_HEIGHT
	)
	FallingStalactites.Build(
		parent,
		Vector3.new(3, GroundUtil.GroundY, caveStart + 45),
		GroundUtil.GroundY + CEILING_HEIGHT
	)

	local corridorZ = caveStart + 70
	local triggerSideSpikes = SideSpikes.Build(parent, Vector3.new(0, GroundUtil.GroundY, corridorZ), 4)

	z += caveLength

	return z, { SideSpikes = triggerSideSpikes }
end

return Section3
