-- Trap 2.1: Тонущие кочки.
-- Stepping-stone mounds across a swamp pit. Each mound sinks into the mud
-- shortly after being stepped on; a runner who doesn't jump off in time
-- falls into the kill zone underneath (built separately by Section2_Swamp).

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.SinkingMounds

local SinkingMounds = {}

function SinkingMounds.Build(parent, startZ, length, width)
	local spacing = length / (Config.MoundCount + 1)

	for i = 1, Config.MoundCount do
		local mound = Instance.new("Part")
		mound.Name = "Mound" .. i
		mound.Shape = Enum.PartType.Cylinder
		mound.Size = Vector3.new(2, 3, 3)
		local offsetX = (math.random() - 0.5) * (width - 4)
		mound.CFrame = CFrame.new(offsetX, 5, startZ + spacing * i) * CFrame.Angles(0, 0, math.rad(90))
		mound.Anchored = true
		mound.Material = Enum.Material.Ground
		mound.Color = Color3.fromRGB(87, 74, 44)
		mound.Parent = parent

		local original = mound.CFrame
		local sinking = false

		mound.Touched:Connect(function(hit)
			if sinking then
				return
			end
			local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end
			sinking = true

			task.spawn(function()
				local tween = TweenService:Create(
					mound,
					TweenInfo.new(Config.SinkTime, Enum.EasingStyle.Sine),
					{ CFrame = original * CFrame.new(0, -Config.SinkDistance, 0) }
				)
				tween:Play()
				tween.Completed:Wait()
				task.delay(Config.RespawnTime, function()
					mound.CFrame = original
					sinking = false
				end)
			end)
		end)
	end
end

return SinkingMounds
