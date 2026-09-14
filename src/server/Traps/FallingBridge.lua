-- Trap 1.1: Проваливающийся мост.
-- A rope bridge made of individual planks. Touching a plank starts a short
-- warning shake, then the plank drops away and stops colliding. It resets
-- itself a few seconds later so the next runner faces it fresh.

local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage:WaitForChild("Tags"))
local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.FallingBridge

local FallingBridge = {}

-- startCFrame is the CFrame of the first plank's center; the bridge extends
-- along +Z from there. Returns the folder holding the planks and the total
-- length of the bridge (so the caller can continue placing ground after it).
function FallingBridge.Build(parent, startCFrame, width)
	width = width or 12

	local folder = Instance.new("Folder")
	folder.Name = "FallingBridge"
	folder.Parent = parent

	for i = 0, Config.PlankCount - 1 do
		local plank = Instance.new("Part")
		plank.Name = "Plank" .. i
		plank.Size = Vector3.new(width, 1, Config.PlankLength)
		plank.Anchored = true
		plank.Material = Enum.Material.WoodPlanks
		plank.Color = Color3.fromRGB(120, 82, 45)
		plank.CFrame = startCFrame * CFrame.new(0, 0, i * Config.PlankLength + Config.PlankLength / 2)
		plank.Parent = folder
		CollectionService:AddTag(plank, Tags.Trap)

		local originalCFrame = plank.CFrame
		local triggered = false

		plank.Touched:Connect(function(hit)
			if triggered then
				return
			end
			local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end
			triggered = true

			task.spawn(function()
				local shakeEnd = os.clock() + Config.WarnTime
				while os.clock() < shakeEnd do
					local offset = (math.random() - 0.5) * 0.15
					plank.CFrame = originalCFrame * CFrame.new(offset, 0, 0)
					task.wait(0.03)
				end
				plank.CFrame = originalCFrame
			end)

			task.delay(Config.WarnTime, function()
				local dropTween = TweenService:Create(
					plank,
					TweenInfo.new(Config.DropTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{ CFrame = originalCFrame * CFrame.new(0, -Config.DropDistance, 0), Transparency = 1 }
				)
				dropTween:Play()
				dropTween.Completed:Wait()
				plank.CanCollide = false

				task.delay(Config.RespawnTime, function()
					plank.CFrame = originalCFrame
					plank.Transparency = 0
					plank.CanCollide = true
					triggered = false
				end)
			end)
		end)
	end

	return folder, Config.PlankCount * Config.PlankLength
end

return FallingBridge
