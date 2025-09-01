local logger = require("common.lib.logger")
local class = require("common.lib.class")

GarbagePattern =
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
	function(self, GarbageSettings, character)
    self.level = -- The level that the player is playing on.
    self.IsChallengeMode = GarbageSettings.IsChallengeMode or false -- checks to see if the player is playing on Challenge Mode.
    self.MatchTime = self.levelData.frameConstants.FLASH + self.levelData.frameConstants.FACE + self.levelData.frameConstants.GARBAGE_HOVER
    self.CurrentChainHeight = 0
    self.EndHeight = 1
    self.NewChain = GarbageSettings.NewChain or false
    self.chainLink = self.MatchTime + (self.levelData.frameConstants.POP * 3)
    self.ThrottledLink = self.MatchTime + (self.levelData.frameConstants.POP * 36)
    self.chainEndDelta = math.ceil(self.chainLink * 1.5)
    self.clock = 0
    self.lines_sent = 0 -- Keeps track of the amount lines the engine has sent
    self.gpm_threshold = 30 -- Used for throttling garbage output when necessary.
    self.ThrottleGarbage = GarbageSettings.ThrottleGarbage or false
    self.delayBeforeChain = 480 -- Delay before the first or next chain is sent.
		self.delayBeforeCombo = 300 -- Delay before the first or next combo is sent.
    self.delayBeforeMetal = 3600 -- The amount of time in frames that must pass before shock garbage has a chance to generate.
    self.BaseSpeed = 0 -- The speed at which garbage is sent. This will depend on the level the player is playing on.
    self.BaseVariation = 0 -- The variation in garbage delay times.
    self.OpeningChainHeight = 0 -- The size of the first chain generated. Tracks seperately from min and max chain height.
    self.MinChainHeight = 1 -- The minimum allowed chain height.
    self.MaxChainHeight = 1 -- The maximum allowed chain height. Chain Ramping can raise this.
    self.CappedChainHeight = 12 -- The hard cap on chain height.
    self.MinComboHeight = 1 -- The minimum combo height.
    self.MaxComboHeight = 2 -- The maximum combo height.
    self.GarbageRamping = 0 -- Increases the speed at which garbage is sent every minute.
    self.ChainRamping = 0 -- Increases the maximum chain height every minute.
    self.MetalChance = 0 -- Affects whether shock garbage can be generated.
    self.MetalRamping = GarbageSettings.MetalRamping or false -- Affects whether the metal chance can go up.
		self.treatMetalAsCombo = GarbageSettings.treatMetalAsCombo or false -- Garbage queue type.
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

function GarbageEngine:GenerateChainGarbage()
  local delay_base = (self.MatchTime * height) + (( height * (height + 1)) / 2) * (self.levelData.frameConstants.POP * 6)
  local delay = math.max(91, math.ceil(delay_base * math.random(self.BaseSpeed * (1 / self.BaseVariation), self.BaseSpeed * self.BaseVariation) / 100))
  local chain_link
  local end_delta

  if self.ThrottleGarbage then
    chain_link = self.ThrottledLink
    end_delta = self.ThrottledLink + self.chainEndDelta
  else
    chain_link = self.chainLink
    end_delta = self.chainEndDelta
  end

  if self.clock >= self.delayBeforeChain then
    -- begin new chain
    if self.CurrentChainHeight == 0 then
      local height = math.random(self.MinChainHeight, self.MaxChainHeight)
      self.NewChain = true
      self.EndHeight = height
      self.CurrentChainHeight = self.CurrentChainHeight + 1
    end
    -- build current chain
    if self.CurrentChainHeight < self.EndHeight then
      self.CurrentChainHeight = self.CurrentChainHeight + 1
      -- placeholder
      self.delayBeforeChain = self.clock + chain_link
    end
    -- finalize chain
    if self.CurrentChainHeight == self.EndHeight then
      -- placeholder
      self.delayBeforeChain = self.clock + end_delta + delay
      self.CurrentChainHeight = 0
      self.lines_sent = self.lines_sent + self.EndHeight
      self.NewChain = false
    end
  end
end

function GarbageEngine:GenerateComboGarbage()
  -- placeholder
end

function GarbageEngine:ThrottleCheck()
  gpm = self.lines_sent / ((self.clock - 180) / 3600)

  if gpm > 30 then
    return true
  else
    return false
  end
end

function GarbageEngine.Ramping()
  -- palceholder
end

function GarbageEngine.run(self)
  assert(self.garbageTarget, "No target set on garbage engine")

  self.ThrottleGarbage = GarbageEngine:ThrottleCheck()

  self.outgoingGarbage:processStagedGarbageForClock(self.clock)
  local garbageDelivery = self.outgoingGarbage:popFinishedTransitsAt(self.clock)
  if garbageDelivery then
    logger.debug("Pushing garbage delivery to incoming garbage queue: " .. table_to_string(garbageDelivery))
    self.garbageTarget.incomingGarbage:pushTable(garbageDelivery)
  end

  local metalCount = 0
  if hasMetal then
    metalCount = 3
  end
  local newComboChainInfo = Stack.attackSoundInfoForMatch(maxChain > 0, maxChain, maxCombo, metalCount)
  if newComboChainInfo and self.character then
    self.character:playAttackSfx(newComboChainInfo)
  end

  self.clock = self.clock + 1
end

function GarbageEngine:rollbackCopy(frame)
  self.outgoingGarbage:rollbackCopy(frame)
end

function GarbageEngine:rollbackToFrame(frame)
  self.outgoingGarbage:rollbackToFrame(frame)
  self.clock = frame
end

function GarbageEngine:rewindToFrame(frame)
  self.outgoingGarbage:rewindToFrame(frame)
  self.clock = frame
end

return AttackEngine