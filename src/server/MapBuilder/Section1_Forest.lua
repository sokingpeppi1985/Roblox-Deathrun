-- Секция 1 — Лесная тропа.
-- Safe start -> falling bridge over a gap (1.1) -> safe stretch ->
-- swinging log over solid ground (1.2) -> safe stretch.

local GroundUtil = require(script.Parent.GroundUtil)
local FallingBridge = require(script.Parent.Parent.Traps.FallingBridge)
local SwingingLog = require(script.Parent.Parent.Traps.SwingingLog)

local Section1 = {}

function Section1.Build(parent)
	local z = 0

	GroundUtil.buildGround(parent, "ForestStart", z, 40, 12)
	z += 40

	local gapLength = 33
	GroundUtil.buildKillZone(parent, "ForestPit", z, gapLength, 20)
	FallingBridge.Build(parent, CFrame.new(0, GroundUtil.GroundY, z), 12)
	z += gapLength

	GroundUtil.buildGround(parent, "ForestMid", z, 20, 12)
	z += 20

	local boostSwingLog = SwingingLog.Build(parent, Vector3.new(0, GroundUtil.GroundY + 7, z + 5))
	z += 10

	GroundUtil.buildGround(parent, "ForestEnd", z, 10, 12)
	z += 10

	return z, { SwingLog = boostSwingLog }
end

return Section1
