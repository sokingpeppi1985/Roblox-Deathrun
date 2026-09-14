-- Entry point: builds the course, wires the Killer's manual traps, and
-- starts the round loop.

local MapBuilder = require(script.MapBuilder)
local RoundManager = require(script.RoundManager)
local KillerController = require(script.KillerController)
local PlayerData = require(script.Economy.PlayerData)

PlayerData.Init()

local mapData = MapBuilder.Build()

KillerController.Init(mapData.Triggers)
RoundManager.Start(mapData)
