-- Trap 4.2: Огненные гейзеры.
-- Fixed, predictable cycle (learnable timing by design): fires for
-- ActiveTime out of every CycleTime seconds. A ParticleEmitter shows the
-- flame; damage only applies while active.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(script.Parent.Common)
local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.FireGeysers

local FireGeysers = {}

function FireGeysers.Build(parent, position)
	local zone = Instance.new("Part")
	zone.Name = "GeyserZone"
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 1
	zone.Size = Vector3.new(4, 8, 4)
	zone.CFrame = CFrame.new(position)
	zone.Parent = parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://243664872"
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 140, 20), Color3.fromRGB(255, 40, 0))
	emitter.Size = NumberSequence.new(2, 4)
	emitter.Lifetime = NumberRange.new(0.6, 1)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(10, 16)
	emitter.SpreadAngle = Vector2.new(5, 5)
	emitter.Parent = zone

	local active = false

	zone.Touched:Connect(function(hit)
		if not active then
			return
		end
		local humanoid, character = Common.getHumanoid(hit)
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if Common.isProtected(character) then
			return
		end
		if not Common.tryHit(humanoid, 0.5) then
			return
		end
		humanoid:TakeDamage(Config.Damage)
	end)

	task.spawn(function()
		while zone.Parent do
			task.wait(Config.CycleTime - Config.ActiveTime)
			active = true
			emitter.Rate = 80
			task.wait(Config.ActiveTime)
			active = false
			emitter.Rate = 0
		end
	end)

	return zone
end

return FireGeysers
