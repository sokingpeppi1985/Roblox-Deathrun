-- Секция 4 — Лавовые пещеры.
-- Lava fills the whole width below; the only way across is heating
-- platforms (4.1, automatic cycle) followed by a safe strip with fire
-- geysers (4.2, automatic cycle), then a ram trap (4.3, Killer-triggered)
-- guarding a solid stretch over the lava.

local GroundUtil = require(script.Parent.GroundUtil)
local HeatingPlatforms = require(script.Parent.Parent.Traps.HeatingPlatforms)
local FireGeysers = require(script.Parent.Parent.Traps.FireGeysers)
local RamTrap = require(script.Parent.Parent.Traps.RamTrap)

local Section4 = {}

function Section4.Build(parent, z)
	local lavaStart = z
	local lavaLength = 140
	GroundUtil.buildKillZone(parent, "LavaPool", z, lavaLength, 24, nil, true)

	-- 4.1: a row of heating platforms crossing the first 50 studs of lava
	local platformSpacing = 7
	for i = 0, 6 do
		HeatingPlatforms.Build(parent, Vector3.new(0, GroundUtil.GroundY - 0.5, z + i * platformSpacing + 4))
	end
	z += 50

	-- safe stone bridge carrying the fire geysers (4.2)
	GroundUtil.buildGround(parent, "LavaBridgeA", z, 30, 8, Enum.Material.Basalt, Color3.fromRGB(40, 40, 42))
	FireGeysers.Build(parent, Vector3.new(-2, GroundUtil.GroundY + 2, z + 10))
	FireGeysers.Build(parent, Vector3.new(2, GroundUtil.GroundY + 2, z + 22))
	z += 30

	-- 4.3: solid path guarded by a ram trap that shoves runners into the lava
	GroundUtil.buildGround(parent, "LavaBridgeB", z, 40, 8, Enum.Material.Basalt, Color3.fromRGB(40, 40, 42))
	local ramSide = 1
	local ramRetracted = Vector3.new(ramSide * 8, GroundUtil.GroundY + 3, z + 20)
	local triggerRamTrap = RamTrap.Build(parent, ramRetracted, Vector3.new(-ramSide, 0, 0))
	z += 40

	z = lavaStart + lavaLength

	return z, { RamTrap = triggerRamTrap }
end

return Section4
