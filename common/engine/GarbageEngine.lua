local logger = require("common.lib.logger")
local class = require("common.lib.class")

Garbage =
	class(
	function(self, width, height, startTime, metal, chain, endsChain)
		self.width = width
		self.height = height
		self.startTime = startTime
		self.endsChain = endsChain
		self.garbage = {width = width, height = height, isMetal = metal or false, isChain = chain}
	end
)

local GarbageEngine =
	class(
	function(self, attackSettings, character)
    self.level = -- The level that the player is playing on.
    self.chainLink = self.levelData.frameConstants.FLASH + self.levelData.frameConstants.FACE + self.levelData.frameConstants.GARBAGE_HOVER + (self.levelData.frameConstants.POP * 3)
    self.chainEndDelta = math.ceil(self.chainLink * 1.5)
    self.clock = 0
    self.delayBeforeChain = 0 -- Delay before the first or next chain is sent.
		self.delayBeforeCombo = 0 -- Delay before the first or next combo is sent.
    self.delayBeforeMetal = 3600 -- The amount of time in frames must pass before shock garbage has a chance to generate.
    self.BaseSpeed = 0 -- The speed at which garbage is sent. This will depend on the level the player is playing on.
    self.OpeningChainHeight = 0 -- The size of the first chain generated. Tracks seperately from min and max chain height.
    self.MinChainHeight = 1 -- The minimum allowed chain height.
    self.MaxChainHeight = 1 -- The maximum allowed chain height. Chain Ramping can raise this.
    self.CappedChainHeight = 12 -- The hard cap on chain height.
    self.MinComboHeight = 1 -- The minimum combo height.
    self.MaxComboHeight = 2 -- The maximum combo height.
    self.GarbageRamping = 0 -- Increases the speed at which garbage is sent every minute.
    self.ChainRamping = 0 -- Increases the maximum chain height every minute.
    self.MetalChance = 0 -- Affects whether shock garbage can be generated.
    self.MetalRamping = false -- Affects whether the metal chance can go up.
		self.treatMetalAsCombo = false
		self.outgoingGarbage = GarbageQueue(true, self.treatMetalAsCombo)
		self.character = character
	end
)

function GarbageEngine:setGarbageTarget(garbageTarget)
  assert(garbageTarget.canvasWidth ~= nil)
  assert(garbageTarget.mirror_x ~= nil)
  assert(garbageTarget.panelOriginX ~= nil)
  assert(garbageTarget.panelOriginY ~= nil)
  assert(garbageTarget.incomingGarbage ~= nil)

  self.garbageTarget = garbageTarget
  self.garbageTarget.incomingGarbage.illegalStuffIsAllowed = true
  self.garbageTarget.incomingGarbage.treatMetalAsCombo = self.treatMetalAsCombo
end