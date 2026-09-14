-- Секция 2 — Болото.
-- Sinking mounds over swamp water (2.1) -> grassy strip hiding spikes
-- (2.2, Killer-triggered) -> slowing mud zone (2.3).

local GroundUtil = require(script.Parent.GroundUtil)
local SinkingMounds = require(script.Parent.Parent.Traps.SinkingMounds)
local HiddenSpikes = require(script.Parent.Parent.Traps.HiddenSpikes)
local SlowingMud = require(script.Parent.Parent.Traps.SlowingMud)

local Section2 = {}

function Section2.Build(parent, z)
	local mireLength = 40
	GroundUtil.buildKillZone(parent, "SwampWater", z, mireLength, 20)
	SinkingMounds.Build(parent, z, mireLength, 16)
	z += mireLength

	GroundUtil.buildGround(parent, "SwampGrassA", z, 30, 12, Enum.Material.LeafyGrass, Color3.fromRGB(63, 92, 47))
	local triggerHiddenSpikes = HiddenSpikes.Build(parent, Vector3.new(0, GroundUtil.GroundY + 0.3, z + 15))
	z += 30

	GroundUtil.buildGround(parent, "SwampGrassB", z, 20, 12, Enum.Material.LeafyGrass, Color3.fromRGB(63, 92, 47))
	z += 20

	GroundUtil.buildGround(parent, "SwampMud", z, 30, 12, Enum.Material.Mud, Color3.fromRGB(70, 58, 36))
	SlowingMud.Build(parent, z, 30, 12)
	z += 30

	return z, { HiddenSpikes = triggerHiddenSpikes }
end

return Section2
