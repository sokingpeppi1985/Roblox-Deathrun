-- Orchestrates the optional "kill the Activator" duel offered to the first
-- Runner to reach the finish each round (a nod to CS 1.6's knife round).
-- The Runner picks a mode; the fight plays out in the off-course
-- DuelArena built by MapBuilder/DuelArena.lua. Winning kills the
-- Activator's Humanoid directly - RoundManager's own win check turns that
-- into an immediate Runners win via the onRunnerWin callback. Losing just
-- kills the Runner's Humanoid, which routes through RoundManager's normal
-- elimination/spectator flow, so nothing special is needed here for that.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local OFFER_TIMEOUT = 12
local DUEL_TIMEOUT = 20
local SWORD_RANGE = 8

local DuelManager = {}

-- [player] = function(choice) to call once DuelChoice arrives for them.
local pendingChoice = {}

Remotes.DuelChoice.OnServerEvent:Connect(function(player, choice)
	local resolve = pendingChoice[player]
	if resolve then
		pendingChoice[player] = nil
		resolve(choice)
	end
end)

local function waitForChoice(player, timeoutSeconds)
	local result = nil
	local done = false
	pendingChoice[player] = function(choice)
		result = choice
		done = true
	end

	local waited = 0
	while not done and waited < timeoutSeconds do
		task.wait(0.25)
		waited += 0.25
	end
	pendingChoice[player] = nil
	return result
end

local function teleportCharacter(character, cframe)
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = cframe
	end
end

local function restoreIfAlive(character, humanoid, originalCFrame)
	if humanoid.Health > 0 then
		teleportCharacter(character, originalCFrame)
	end
end

local function giveWeapon(player, humanoid, name)
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.RequiresHandle = true
	tool.CanBeDropped = false

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 2)
	handle.Color = Color3.fromRGB(90, 60, 40)
	handle.CanCollide = false
	handle.Parent = tool

	tool.Parent = player.Backpack
	humanoid:EquipTool(tool)
	return tool
end

local function runSwordDuel(runnerPlayer, killerPlayer, arena, onComplete)
	local runnerChar, killerChar = runnerPlayer.Character, killerPlayer.Character
	local runnerHumanoid = runnerChar and runnerChar:FindFirstChildOfClass("Humanoid")
	local killerHumanoid = killerChar and killerChar:FindFirstChildOfClass("Humanoid")
	local runnerHrp = runnerChar and runnerChar:FindFirstChild("HumanoidRootPart")
	local killerHrp = killerChar and killerChar:FindFirstChild("HumanoidRootPart")
	if not (runnerHumanoid and killerHumanoid and runnerHrp and killerHrp) then
		onComplete(false)
		return
	end

	local runnerOriginalCFrame = runnerHrp.CFrame
	local killerOriginalCFrame = killerHrp.CFrame
	teleportCharacter(runnerChar, arena.DuelistSpawn)
	teleportCharacter(killerChar, arena.KillerSpawn)

	local sword = giveWeapon(runnerPlayer, runnerHumanoid, "Duel Sword")

	local concluded = false
	local connection

	local function conclude(runnerWon)
		if concluded then
			return
		end
		concluded = true
		if connection then
			connection:Disconnect()
		end
		sword:Destroy()
		restoreIfAlive(runnerChar, runnerHumanoid, runnerOriginalCFrame)
		restoreIfAlive(killerChar, killerHumanoid, killerOriginalCFrame)
		onComplete(runnerWon)
	end

	connection = sword.Activated:Connect(function()
		if killerHumanoid.Health <= 0 then
			return
		end
		if (runnerHrp.Position - killerHrp.Position).Magnitude <= SWORD_RANGE then
			killerHumanoid.Health = 0
			conclude(true)
		end
	end)

	task.delay(DUEL_TIMEOUT, function()
		conclude(false) -- the Activator outran the clock
	end)
end

local function runRevolverDuel(runnerPlayer, killerPlayer, arena, onComplete)
	local runnerChar, killerChar = runnerPlayer.Character, killerPlayer.Character
	local runnerHumanoid = runnerChar and runnerChar:FindFirstChildOfClass("Humanoid")
	local killerHumanoid = killerChar and killerChar:FindFirstChildOfClass("Humanoid")
	local runnerHrp = runnerChar and runnerChar:FindFirstChild("HumanoidRootPart")
	local killerHrp = killerChar and killerChar:FindFirstChild("HumanoidRootPart")
	if not (runnerHumanoid and killerHumanoid and runnerHrp and killerHrp) then
		onComplete(false)
		return
	end

	local runnerOriginalCFrame = runnerHrp.CFrame
	local killerOriginalCFrame = killerHrp.CFrame
	teleportCharacter(runnerChar, arena.DuelistSpawn)
	teleportCharacter(killerChar, arena.KillerSpawn)

	local runnerGun = giveWeapon(runnerPlayer, runnerHumanoid, "Duel Revolver")
	local killerGun = giveWeapon(killerPlayer, killerHumanoid, "Duel Revolver")

	local concluded = false
	local runnerConn, killerConn

	local function conclude(runnerWon)
		if concluded then
			return
		end
		concluded = true
		if runnerConn then
			runnerConn:Disconnect()
		end
		if killerConn then
			killerConn:Disconnect()
		end
		runnerGun:Destroy()
		killerGun:Destroy()
		restoreIfAlive(runnerChar, runnerHumanoid, runnerOriginalCFrame)
		restoreIfAlive(killerChar, killerHumanoid, killerOriginalCFrame)
		onComplete(runnerWon)
	end

	runnerConn = runnerGun.Activated:Connect(function()
		if killerHumanoid.Health > 0 then
			killerHumanoid.Health = 0
			conclude(true)
		end
	end)
	killerConn = killerGun.Activated:Connect(function()
		if runnerHumanoid.Health > 0 then
			runnerHumanoid.Health = 0
			conclude(false)
		end
	end)

	task.delay(DUEL_TIMEOUT, function()
		conclude(false) -- neither drew in time - the Activator keeps the round
	end)
end

-- Offers the duel to `runnerPlayer` (the first Runner to finish this
-- round). Yields on its own coroutine waiting for their mode choice, so
-- callers should task.spawn this. Calls `onRunnerWin` if the Runner kills
-- the Activator, so RoundManager can end the round immediately.
function DuelManager.OfferDuel(runnerPlayer, killerPlayer, arena, onRunnerWin)
	if not killerPlayer or not killerPlayer.Parent then
		return
	end

	Remotes.DuelOffer:FireClient(runnerPlayer)
	local choice = waitForChoice(runnerPlayer, OFFER_TIMEOUT)
	if choice ~= "sword" and choice ~= "revolver" then
		return
	end

	-- The round may have moved on to a new Activator while they were
	-- deciding; bail rather than dragging a stale pair into the arena.
	if not (killerPlayer.Team and killerPlayer.Team.Name == "Activator") then
		return
	end

	local function onComplete(runnerWon)
		if runnerWon and onRunnerWin then
			onRunnerWin()
		end
	end

	if choice == "sword" then
		runSwordDuel(runnerPlayer, killerPlayer, arena, onComplete)
	else
		runRevolverDuel(runnerPlayer, killerPlayer, arena, onComplete)
	end
end

return DuelManager
