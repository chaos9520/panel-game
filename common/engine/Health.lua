local logger = require("common.lib.logger")
local consts = require("common.engine.consts")
local class = require("common.lib.class")

Health =
  class(
  function(self, framesToppedOutToLose, lineClearGPM, height, riseSpeed)
    self.framesToppedOutToLose = framesToppedOutToLose -- Number of seconds currently remaining of being "topped" out before we are defeated.
    self.maxSecondsToppedOutToLose = framesToppedOutToLose -- Starting value of framesToppedOutToLose
    self.lineClearRate = lineClearGPM / 60 -- How many "lines" we clear per second. Essentially how fast we recover.
    self.currentLines = 0 -- The current number of "lines" simulated
    self.height = height -- How many "lines" need to be accumulated before we are "topped" out.
    self.lastWasFourCombo = false -- Tracks if the last combo was a +4. If two +4s hit in a row, it only counts as 1 "line"
    self.clock = 0 -- Current clock time, this should match the opponent
    self.currentRiseSpeed = riseSpeed -- rise speed is just like the normal game for now, lines are added faster the longer the match goes
    self.rollbackCopies = {}
    self.rollbackCopyPool = Queue()
  end
)

function Health:run()
  -- Increment rise speed if needed
  if self.clock > 0 and self.clock % (15 * 60) == 0 then
    self.currentRiseSpeed = math.min(self.currentRiseSpeed + 1, 99)
  end

  -- Harder to survive over time, simulating "stamina"
  local staminaPercent = math.max(0.5, 1 - ((self.clock / 60) * (0.01 / 10)))
  local decrementLines = (self.lineClearRate * (1/60.0)) * staminaPercent
  self.currentLines = math.max(0, self.currentLines - decrementLines)
  if self.currentLines >= self.height then
    self.framesToppedOutToLose = math.max(0, self.framesToppedOutToLose - 1)
  end
  self.clock = self.clock + 1
  return self.framesToppedOutToLose
end

function Health:receiveGarbage(frameToReceive, garbage)
  if garbage.width and garbage.height then
    local countGarbage = true

    if countGarbage then
      local damage_height = (garbage.height * (garbage.height + 1)) / 2
      local damage = (damage_height * garbage.width) / 6
      if garbage.isChain then
        damage = damage
      elseif garbage.isMetal then
        damage = 1.5
      else
        damage = damage
      end
      self.currentLines = math.min(self.height * 1.2, self.currentLines + damage)
    end
  end
end

function Health:getTopOutPercentage()
  return math.max(0, self.currentLines) / self.height
end

function Health:saveRollbackCopy()
  local copy

  if self.rollbackCopyPool:len() > 0 then
    copy = self.rollbackCopyPool:pop()
  else
    copy = {}
  end

  copy.currentRiseSpeed = self.currentRiseSpeed
  copy.currentLines = self.currentLines
  copy.framesToppedOutToLose = self.framesToppedOutToLose
  copy.lastWasFourCombo = self.lastWasFourCombo

  self.rollbackCopies[self.clock] = copy

  local deleteFrame = self.clock - MAX_LAG - 1
  if self.rollbackCopies[deleteFrame] then
    self.rollbackCopyPool:push(self.rollbackCopies[deleteFrame])
    self.rollbackCopies[deleteFrame] = nil
  end
end

function Health:rollbackToFrame(frame)
  local copy = self.rollbackCopies[frame]

  for i = frame + 1, self.clock do
    self.rollbackCopyPool:push(self.rollbackCopies[i])
    self.rollbackCopies[i] = nil
  end

  self.currentRiseSpeed = copy.currentRiseSpeed
  self.currentLines = copy.currentLines
  self.framesToppedOutToLose = copy.framesToppedOutToLose
  self.lastWasFourCombo = copy.lastWasFourCombo
  self.clock = frame
end

return Health
