-- Trap 1.2: Маятник-бревно.
-- A log hangs from a HingeConstraint between two tree-trunk poles and
-- swings back and forth continuously. It only deals damage while swinging
-- fast enough. The Killer can temporarily boost its speed via a RemoteEvent
-- (wired up in KillerController, which calls the function this returns).

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(script.Parent.Common)
local Config = require(ReplicatedStorage:WaitForChild("Config")).Traps.SwingingLog

local SwingingLog = {}

-- position is the resting center-point of the log, midway between the poles.
function SwingingLog.Build(parent, position)
	local poleA = Instance.new("Part")
	poleA.Name = "PoleA"
	poleA.Anchored = true
	poleA.Size = Vector3.new(2, 12, 2)
	poleA.Material = Enum.Material.Wood
	poleA.Color = Color3.fromRGB(92, 64, 36)
	poleA.CFrame = CFrame.new(position.X - 6, position.Y, position.Z)
	poleA.Parent = parent

	local poleB = poleA:Clone()
	poleB.Name = "PoleB"
	poleB.CFrame = CFrame.new(position.X + 6, position.Y, position.Z)
	poleB.Parent = parent

	local log = Instance.new("Part")
	log.Name = "SwingingLog"
	log.Shape = Enum.PartType.Cylinder
	log.Size = Vector3.new(10, 1.6, 1.6)
	log.Anchored = false
	log.Material = Enum.Material.Wood
	log.Color = Color3.fromRGB(112, 78, 45)
	log.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	log.Parent = parent

	local attachTop = Instance.new("Attachment")
	attachTop.Position = Vector3.new(0, 6, 0)
	attachTop.Parent = poleA

	local attachLog = Instance.new("Attachment")
	attachLog.Position = Vector3.new(-5, 0, 0)
	attachLog.Parent = log

	local hinge = Instance.new("HingeConstraint")
	hinge.Attachment0 = attachTop
	hinge.Attachment1 = attachLog
	hinge.ActuatorType = Enum.ActuatorType.Motor
	hinge.MotorMaxTorque = 100000
	hinge.MotorMaxAcceleration = 50
	hinge.AngularVelocity = Config.BaseAngularVelocity
	hinge.Parent = poleA

	local direction = 1
	task.spawn(function()
		while log.Parent do
			task.wait(Config.DirectionFlipInterval)
			direction = -direction
			hinge.AngularVelocity = Config.BaseAngularVelocity * direction
		end
	end)

	local function isDangerous()
		return math.abs(hinge.AngularVelocity) > Config.DamageSpeedThreshold
	end

	log.Touched:Connect(function(hit)
		if not isDangerous() then
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

	local function boost()
		local target = Config.BaseAngularVelocity * Config.BoostMultiplier * direction
		TweenService:Create(hinge, TweenInfo.new(0.5), { AngularVelocity = target }):Play()
		task.delay(Config.BoostDuration, function()
			if hinge.Parent then
				TweenService:Create(hinge, TweenInfo.new(0.5), {
					AngularVelocity = Config.BaseAngularVelocity * direction,
				}):Play()
			end
		end)
	end

	return boost
end

return SwingingLog
