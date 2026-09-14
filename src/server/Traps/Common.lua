-- Small shared helpers used by every trap module: reading the Humanoid off
-- a touched part, respecting the finish-zone immunity, and de-duplicating
-- Touched events firing multiple times per second from overlapping limbs.

local Players = game:GetService("Players")

local Common = {}

function Common.getHumanoid(hitPart)
	local character = hitPart.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil
	end
	return humanoid, character
end

-- Players standing inside the finish arch are immune to every trap (see
-- MapBuilder/Finish.lua, which sets this attribute via CollectionService's
-- FinishZone tag). The Activator is also always immune - they operate the
-- traps remotely and were never meant to run the course themselves.
function Common.isProtected(character)
	if character == nil then
		return false
	end
	if character:GetAttribute("InFinishZone") == true then
		return true
	end
	local player = Players:GetPlayerFromCharacter(character)
	return player ~= nil and player.Team ~= nil and player.Team.Name == "Activator"
end

local hitCooldowns = setmetatable({}, { __mode = "k" })

function Common.tryHit(humanoid, cooldown)
	local now = os.clock()
	local last = hitCooldowns[humanoid]
	if last and now - last < cooldown then
		return false
	end
	hitCooldowns[humanoid] = now
	return true
end

-- Convenience wrapper for the common case: a hazard part that always deals
-- damage on touch (no separate "armed" state to track).
function Common.damagePart(part, amount, cooldown)
	cooldown = cooldown or 1
	return part.Touched:Connect(function(hit)
		local humanoid, character = Common.getHumanoid(hit)
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if Common.isProtected(character) then
			return
		end
		if not Common.tryHit(humanoid, cooldown) then
			return
		end
		humanoid:TakeDamage(amount)
	end)
end

function Common.killPart(part, cooldown)
	cooldown = cooldown or 1
	return part.Touched:Connect(function(hit)
		local humanoid, character = Common.getHumanoid(hit)
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if Common.isProtected(character) then
			return
		end
		if not Common.tryHit(humanoid, cooldown) then
			return
		end
		humanoid.Health = 0
	end)
end

return Common
