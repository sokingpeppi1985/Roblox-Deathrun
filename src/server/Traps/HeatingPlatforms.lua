-- Trap 4.1: Раскаляющиеся платформы.
-- Cycles forever: 3s safe (grey, solid) -> 2s warning (color tweens
-- green->yellow->red, already dangerous to touch) -> disappears (falls
-- into lava below, handled by the lava KillZone) -> respawns after 4s.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(script.Parent.Common)
local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.HeatingPlatforms

local SAFE_COLOR = Color3.fromRGB(90, 200, 90)
local WARN_COLOR_1 = Color3.fromRGB(255, 200, 50)
local WARN_COLOR_2 = Color3.fromRGB(255, 60, 20)

local HeatingPlatforms = {}

function HeatingPlatforms.Build(parent, position, size)
	size = size or Vector3.new(6, 1, 6)

	local platform = Instance.new("Part")
	platform.Name = "HeatingPlatform"
	platform.Anchored = true
	platform.Size = size
	platform.Material = Enum.Material.Metal
	platform.Color = SAFE_COLOR
	platform.CFrame = CFrame.new(position)
	platform.Parent = parent

	local dangerous = false

	platform.Touched:Connect(function(hit)
		if not dangerous then
			return
		end
		local humanoid, character = Common.getHumanoid(hit)
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if Common.isProtected(character) then
			return
		end
		if not Common.tryHit(humanoid, 1) then
			return
		end
		humanoid:TakeDamage(Config.Damage)
	end)

	task.spawn(function()
		while platform.Parent do
			dangerous = false
			platform.Color = SAFE_COLOR
			platform.CanCollide = true
			platform.Transparency = 0
			task.wait(Config.SafeTime)

			dangerous = true
			TweenService:Create(platform, TweenInfo.new(Config.WarnTime / 2), { Color = WARN_COLOR_1 }):Play()
			task.wait(Config.WarnTime / 2)
			TweenService:Create(platform, TweenInfo.new(Config.WarnTime / 2), { Color = WARN_COLOR_2 }):Play()
			task.wait(Config.WarnTime / 2)

			platform.CanCollide = false
			platform.Transparency = 1
			task.wait(Config.RespawnTime)
		end
	end)

	return platform
end

return HeatingPlatforms
