-- Shared tuning values for the Deathrun course. Kept here so trap timings
-- can be tweaked without touching trap logic.

local Config = {}

Config.CourseWidth = 12
Config.GroundY = 5

Config.Traps = {
	FallingBridge = {
		PlankCount = 11,
		PlankLength = 3,
		WarnTime = 0.4, -- vibration warning before a touched plank drops
		DropTime = 0.3,
		DropDistance = 8,
		RespawnTime = 6,
	},
	SwingingLog = {
		BaseAngularVelocity = 1.2,
		BoostMultiplier = 1.8,
		BoostDuration = 4,
		DamageSpeedThreshold = 1.5,
		Damage = 35,
		DirectionFlipInterval = 2.5,
	},
	SinkingMounds = {
		MoundCount = 8,
		SinkDistance = 5,
		SinkTime = 1.5,
		RespawnTime = 5,
	},
	HiddenSpikes = {
		VisibleTime = 1,
		WarnSoundLead = 0.3,
		Damage = 40,
		SpikeCount = 6,
	},
	SlowingMud = {
		SpeedMultiplier = 0.5,
	},
	FallingStalactites = {
		WarnTime = 1,
		FallTime = 0.5,
		Damage = 45,
		MinInterval = 4,
		MaxInterval = 8,
	},
	SideSpikes = {
		ExtendTime = 0.25,
		HoldTime = 1,
		RetractTime = 0.3,
		Damage = 50,
	},
	HeatingPlatforms = {
		SafeTime = 3,
		WarnTime = 2,
		RespawnTime = 4,
		Damage = 25,
	},
	FireGeysers = {
		CycleTime = 4,
		ActiveTime = 1,
		Damage = 30,
	},
	RamTrap = {
		ExtendTime = 0.5,
		HoldTime = 1.5,
		RetractTime = 0.5,
		TravelDistance = 10,
	},
	FinalTrapdoor = {
		ResetTime = 1.5,
	},
}

return Config
