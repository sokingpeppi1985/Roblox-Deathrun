-- Финишная арка.
-- Everyone inside the finish zone is tagged (via a character attribute)
-- immune to every trap - Common.isProtected checks this attribute before
-- any trap deals damage. The FinishLine part is what RoundManager listens
-- to for detecting that a runner has completed the course.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage:WaitForChild("Tags"))
local GroundY = require(ReplicatedStorage:WaitForChild("Config")).GroundY

local Finish = {}

function Finish.Build(parent, z)
	local archLeft = Instance.new("Part")
	archLeft.Name = "ArchLeft"
	archLeft.Anchored = true
	archLeft.Size = Vector3.new(2, 16, 2)
	archLeft.Material = Enum.Material.Marble
	archLeft.Color = Color3.fromRGB(230, 220, 200)
	archLeft.CFrame = CFrame.new(-8, 13, z)
	archLeft.Parent = parent

	local archRight = archLeft:Clone()
	archRight.Name = "ArchRight"
	archRight.CFrame = CFrame.new(8, 13, z)
	archRight.Parent = parent

	local archTop = Instance.new("Part")
	archTop.Name = "ArchTop"
	archTop.Anchored = true
	archTop.Size = Vector3.new(18, 2, 2)
	archTop.Material = Enum.Material.Marble
	archTop.Color = Color3.fromRGB(230, 220, 200)
	archTop.CFrame = CFrame.new(0, 20, z)
	archTop.Parent = parent

	local floor = Instance.new("Part")
	floor.Name = "FinishFloor"
	floor.Anchored = true
	floor.Size = Vector3.new(18, 2, 16)
	floor.Material = Enum.Material.Marble
	floor.Color = Color3.fromRGB(210, 200, 180)
	floor.CFrame = CFrame.new(0, GroundY - 1, z + 8)
	floor.Parent = parent

	local zone = Instance.new("Part")
	zone.Name = "FinishZone"
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 1
	zone.Size = Vector3.new(18, 10, 16)
	zone.CFrame = CFrame.new(0, GroundY + 3, z + 8)
	zone.Parent = parent
	CollectionService:AddTag(zone, Tags.FinishZone)

	local touchCount = setmetatable({}, { __mode = "k" })

	zone.Touched:Connect(function(hit)
		local character = hit.Parent
		if character and character:FindFirstChildOfClass("Humanoid") then
			touchCount[character] = (touchCount[character] or 0) + 1
			character:SetAttribute("InFinishZone", true)
		end
	end)

	zone.TouchEnded:Connect(function(hit)
		local character = hit.Parent
		if character and touchCount[character] then
			touchCount[character] -= 1
			if touchCount[character] <= 0 then
				touchCount[character] = nil
				character:SetAttribute("InFinishZone", false)
			end
		end
	end)

	local finishLine = Instance.new("Part")
	finishLine.Name = "FinishLine"
	finishLine.Anchored = true
	finishLine.CanCollide = false
	finishLine.Transparency = 1
	finishLine.Size = Vector3.new(18, 8, 1)
	finishLine.CFrame = CFrame.new(0, GroundY + 3, z + 2)
	finishLine.Parent = parent
	CollectionService:AddTag(finishLine, Tags.FinishLine)

	return finishLine
end

return Finish
