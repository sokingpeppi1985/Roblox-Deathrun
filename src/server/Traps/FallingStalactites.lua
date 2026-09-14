-- Trap 3.1: Падающие сталактиты.
-- Loops forever on its own (no Killer input): waits a random interval,
-- shows a crack decal on the ceiling for 1s as a warning, then drops the
-- stalactite via TweenService. It only deals damage while actually falling.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.FallingStalactites

local FallingStalactites = {}

function FallingStalactites.Build(parent, position, ceilingY)
	local stalactite = Instance.new("Part")
	stalactite.Name = "Stalactite"
	stalactite.Shape = Enum.PartType.Cylinder
	stalactite.Size = Vector3.new(4, 1.2, 1.2)
	stalactite.Anchored = true
	stalactite.Material = Enum.Material.Rock
	stalactite.Color = Color3.fromRGB(90, 90, 95)
	stalactite.CFrame = CFrame.new(position.X, ceilingY, position.Z) * CFrame.Angles(0, 0, math.rad(90))
	stalactite.Parent = parent

	local crack = Instance.new("Part")
	crack.Name = "CrackMarker"
	crack.Size = Vector3.new(3, 0.05, 3)
	crack.Anchored = true
	crack.CanCollide = false
	crack.Transparency = 1
	crack.Material = Enum.Material.SmoothPlastic
	crack.CFrame = CFrame.new(position.X, position.Y + 0.03, position.Z)
	crack.Parent = parent

	local decal = Instance.new("Decal")
	decal.Texture = "rbxassetid://4570576986"
	decal.Transparency = 1
	decal.Face = Enum.NormalId.Top
	decal.Parent = crack

	local falling = false
	local restCFrame = stalactite.CFrame

	stalactite.Touched:Connect(function(hit)
		if not falling then
			return
		end
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		humanoid:TakeDamage(Config.Damage)
	end)

	task.spawn(function()
		while stalactite.Parent do
			task.wait(math.random(Config.MinInterval, Config.MaxInterval))

			TweenService:Create(decal, TweenInfo.new(Config.WarnTime), { Transparency = 0.2 }):Play()
			task.wait(Config.WarnTime)

			falling = true
			local dropTween = TweenService:Create(
				stalactite,
				TweenInfo.new(Config.FallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ CFrame = CFrame.new(position.X, position.Y + 3, position.Z) * CFrame.Angles(0, 0, math.rad(90)) }
			)
			dropTween:Play()
			dropTween.Completed:Wait()
			falling = false

			decal.Transparency = 1
			stalactite.CFrame = restCFrame
		end
	end)
end

return FallingStalactites
