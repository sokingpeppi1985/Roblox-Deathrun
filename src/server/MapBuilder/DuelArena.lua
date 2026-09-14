-- Duel arena: a small enclosed room, well clear of the main course, where
-- the first Runner to reach the finish can challenge the Activator
-- one-on-one (see DuelManager.lua). Built once alongside the rest of the
-- map so it's just more generated geometry, not a hand-placed Studio room.

local ARENA_SIZE = 50
local WALL_HEIGHT = 20
local ARENA_CENTER = Vector3.new(0, 100, -400) -- floating well away from the course

local DuelArena = {}

local function wall(parent, size, cframe)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Material = Enum.Material.Concrete
	part.Color = Color3.fromRGB(60, 60, 65)
	part.Parent = parent
end

-- Returns the spawn CFrames DuelManager teleports the two combatants to.
function DuelArena.Build(parent)
	local folder = Instance.new("Folder")
	folder.Name = "DuelArena"
	folder.Parent = parent

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(ARENA_SIZE, 2, ARENA_SIZE)
	floor.CFrame = CFrame.new(ARENA_CENTER)
	floor.Material = Enum.Material.Sand
	floor.Color = Color3.fromRGB(150, 130, 100)
	floor.Parent = folder

	local half = ARENA_SIZE / 2
	wall(folder, Vector3.new(ARENA_SIZE, WALL_HEIGHT, 1), CFrame.new(ARENA_CENTER + Vector3.new(0, WALL_HEIGHT / 2 + 1, half)))
	wall(folder, Vector3.new(ARENA_SIZE, WALL_HEIGHT, 1), CFrame.new(ARENA_CENTER + Vector3.new(0, WALL_HEIGHT / 2 + 1, -half)))
	wall(folder, Vector3.new(1, WALL_HEIGHT, ARENA_SIZE), CFrame.new(ARENA_CENTER + Vector3.new(half, WALL_HEIGHT / 2 + 1, 0)))
	wall(folder, Vector3.new(1, WALL_HEIGHT, ARENA_SIZE), CFrame.new(ARENA_CENTER + Vector3.new(-half, WALL_HEIGHT / 2 + 1, 0)))

	return {
		DuelistSpawn = CFrame.new(ARENA_CENTER + Vector3.new(0, 4, half - 6), ARENA_CENTER),
		KillerSpawn = CFrame.new(ARENA_CENTER + Vector3.new(0, 4, -(half - 6)), ARENA_CENTER),
	}
end

return DuelArena
