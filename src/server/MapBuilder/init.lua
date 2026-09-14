-- Builds the whole Deathrun course into Workspace.Map on server start, and
-- returns everything RoundManager / KillerController need: the manual trap
-- trigger functions, the finish line part, and a spawn CFrame.

local Workspace = game:GetService("Workspace")

local GroundUtil = require(script.GroundUtil)
local Section1 = require(script.Section1_Forest)
local Section2 = require(script.Section2_Swamp)
local Section3 = require(script.Section3_Cave)
local Section4 = require(script.Section4_Lava)
local Section5 = require(script.Section5_Final)
local Finish = require(script.Finish)
local DuelArena = require(script.DuelArena)

local MapBuilder = {}

-- A small raised booth off to the side of the start, out of reach of every
-- trap. The Activator spawns here instead of on the course - they operate
-- traps remotely via the panel, they were never meant to run the gauntlet.
local function buildActivatorBooth(parent)
	local booth = Instance.new("Part")
	booth.Name = "ActivatorBooth"
	booth.Anchored = true
	booth.Size = Vector3.new(10, 1, 10)
	booth.Material = Enum.Material.Metal
	booth.Color = Color3.fromRGB(90, 90, 95)
	booth.CFrame = CFrame.new(-20, GroundUtil.GroundY + 10, 5)
	booth.Parent = parent

	return CFrame.new(-20, GroundUtil.GroundY + 12, 5)
end

function MapBuilder.Build()
	local existing = Workspace:FindFirstChild("Map")
	if existing then
		existing:Destroy()
	end

	local map = Instance.new("Folder")
	map.Name = "Map"
	map.Parent = Workspace

	local triggers = {}
	local function merge(t)
		for key, fn in pairs(t or {}) do
			triggers[key] = fn
		end
	end

	local z, t1 = Section1.Build(map)
	merge(t1)

	local t2
	z, t2 = Section2.Build(map, z)
	merge(t2)

	local t3
	z, t3 = Section3.Build(map, z)
	merge(t3)

	local t4
	z, t4 = Section4.Build(map, z)
	merge(t4)

	local t5
	z, t5 = Section5.Build(map, z)
	merge(t5)

	local finishLine = Finish.Build(map, z)
	local duelArena = DuelArena.Build(map)
	local killerSpawnCFrame = buildActivatorBooth(map)

	return {
		Triggers = triggers,
		FinishLine = finishLine,
		SpawnCFrame = CFrame.new(0, GroundUtil.GroundY + 3, 5),
		KillerSpawnCFrame = killerSpawnCFrame,
		FinishZ = z,
		DuelArena = duelArena,
	}
end

return MapBuilder
