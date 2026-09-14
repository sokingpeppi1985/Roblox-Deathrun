-- Секция 5 — Финальный рывок.
-- 5.1 Комбо-мост: a narrow bridge combining heating plates and a central
-- geyser, in full view of the Killer for dramatic effect.
-- 5.2 Финальная ручная ловушка: the one no-warning insta-kill trapdoor,
-- right before the finish line.

local GroundUtil = require(script.Parent.GroundUtil)
local HeatingPlatforms = require(script.Parent.Parent.Traps.HeatingPlatforms)
local FireGeysers = require(script.Parent.Parent.Traps.FireGeysers)
local FinalTrapdoor = require(script.Parent.Parent.Traps.FinalTrapdoor)

local Section5 = {}

function Section5.Build(parent, z)
	local start = z
	local lavaLength = 60
	GroundUtil.buildKillZone(parent, "FinalLava", z, lavaLength, 16, nil, true)

	-- narrow combo bridge: heating plates down both edges, geyser dead center
	for i = 0, 5 do
		HeatingPlatforms.Build(
			parent,
			Vector3.new(0, GroundUtil.GroundY - 0.5, z + i * 9 + 5),
			Vector3.new(6, 1, 5)
		)
	end
	FireGeysers.Build(parent, Vector3.new(0, GroundUtil.GroundY + 2, z + 30))
	z += lavaLength

	-- solid ground leading to the trapdoor, with a gap under the trapdoor
	-- itself so dropping through it actually falls into a pit
	local approachLength = 22
	GroundUtil.buildGround(parent, "FinalApproachA", z, approachLength, 10, Enum.Material.Slate, Color3.fromRGB(70, 68, 66))
	local doorZ = z + approachLength + 3
	GroundUtil.buildKillZone(parent, "TrapdoorPit", z + approachLength, 6, 10)
	local triggerFinalTrapdoor = FinalTrapdoor.Build(parent, Vector3.new(0, GroundUtil.GroundY, doorZ))
	GroundUtil.buildGround(parent, "FinalApproachB", doorZ + 3, 8, 10, Enum.Material.Slate, Color3.fromRGB(70, 68, 66))
	z = doorZ + 3 + 8

	return z, { FinalTrapdoor = triggerFinalTrapdoor }
end

return Section5
