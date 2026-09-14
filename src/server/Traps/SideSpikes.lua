-- Trap 3.2: Узкий проход с боковыми шипами.
-- Two spike blocks sit retracted into the corridor walls. The Killer's
-- RemoteEvent (via the trigger function returned here) drives them out
-- with TweenService, forcing the runner to be exactly centered when they
-- fire.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(script.Parent.Common)
local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.SideSpikes

local SideSpikes = {}

function SideSpikes.Build(parent, position, corridorWidth)
	corridorWidth = corridorWidth or 4
	local yLevel = position.Y + 2
	local active = false
	local spikes = {}

	for _, side in ipairs({ -1, 1 }) do
		local spike = Instance.new("Part")
		spike.Name = "SideSpike" .. (side == -1 and "Left" or "Right")
		spike.Size = Vector3.new(3, 4, 2)
		spike.Anchored = true
		spike.Material = Enum.Material.Metal
		spike.Color = Color3.fromRGB(130, 130, 140)
		spike.CanCollide = false

		local retractedX = position.X + side * (corridorWidth / 2 + 2)
		local extendedX = position.X + side * (corridorWidth / 2 - 0.5)
		spike.CFrame = CFrame.new(retractedX, yLevel, position.Z)
		spike.Parent = parent

		spikes[#spikes + 1] = { part = spike, retractedX = retractedX, extendedX = extendedX }

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

	local busy = false
	local function trigger()
		if busy then
			return
		end
		busy = true
		active = true

		for _, data in ipairs(spikes) do
			data.part.CanCollide = true
			TweenService:Create(
				data.part,
				TweenInfo.new(Config.ExtendTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = CFrame.new(data.extendedX, yLevel, position.Z) }
			):Play()
		end

		task.delay(Config.ExtendTime + Config.HoldTime, function()
			for _, data in ipairs(spikes) do
				TweenService:Create(
					data.part,
					TweenInfo.new(Config.RetractTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ CFrame = CFrame.new(data.retractedX, yLevel, position.Z) }
				):Play()
			end
			task.delay(Config.RetractTime, function()
				active = false
				for _, data in ipairs(spikes) do
					data.part.CanCollide = false
				end
				busy = false
			end)
		end)
	end

	return trigger
end

return SideSpikes
