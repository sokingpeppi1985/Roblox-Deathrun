-- Trap 2.2: Скрытые шипы в траве.
-- Spikes start invisible and non-collidable. The Killer fires a RemoteEvent
-- (handled in KillerController, which calls the function this returns) to
-- arm them: 0.3s of grass-rustle sound first (fair warning), then the
-- spikes become solid and visible for 1s before retracting again.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(script.Parent.Common)
local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.HiddenSpikes

local HiddenSpikes = {}

function HiddenSpikes.Build(parent, position)
	local spikes = {}
	local active = false

	for i = 1, Config.SpikeCount do
		local spike = Instance.new("Part")
		spike.Name = "HiddenSpike" .. i
		spike.Shape = Enum.PartType.Cylinder
		spike.Size = Vector3.new(3, 0.6, 0.6)
		local offsetX = -Config.SpikeCount * 0.9 / 2 + i * 0.9
		spike.CFrame = CFrame.new(position.X + offsetX, position.Y, position.Z) * CFrame.Angles(0, 0, math.rad(90))
		spike.Anchored = true
		spike.Material = Enum.Material.Metal
		spike.Color = Color3.fromRGB(120, 120, 130)
		spike.Transparency = 1
		spike.CanCollide = false
		spike.Parent = parent
		table.insert(spikes, spike)

		spike.Touched:Connect(function(hit)
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
			if not Common.tryHit(humanoid, 1) then
				return
			end
			humanoid:TakeDamage(Config.Damage)
		end)
	end

	local rustleSound = Instance.new("Sound")
	rustleSound.SoundId = "rbxassetid://9125430083"
	rustleSound.Volume = 0.6
	rustleSound.Parent = spikes[1]

	local busy = false
	local function trigger()
		if busy then
			return
		end
		busy = true
		rustleSound:Play()
		task.delay(Config.WarnSoundLead, function()
			active = true
			for _, spike in ipairs(spikes) do
				spike.Transparency = 0
				spike.CanCollide = true
			end
			task.delay(Config.VisibleTime, function()
				active = false
				for _, spike in ipairs(spikes) do
					spike.Transparency = 1
					spike.CanCollide = false
				end
				busy = false
			end)
		end)
	end

	return trigger
end

return HiddenSpikes
