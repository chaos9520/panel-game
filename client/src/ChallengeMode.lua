local logger = require("common.lib.logger")
local class = require("common.lib.class")
local ChallengeModePlayer = require("client.src.ChallengeModePlayer")
local GameModes = require("common.engine.GameModes")
local MessageTransition = require("client.src.scenes.Transitions.MessageTransition")
local levelPresets = require("common.engine.LevelPresets")
local Game1pChallenge = require("client.src.scenes.Game1pChallenge")
require("client.src.BattleRoom")


-- Challenge Mode is a particular play through of the challenge mode in the game, it contains all the settings for the mode.
local ChallengeMode =
  class(
  function(self, difficulty, stageIndex)
    self.mode = GameModes.getPreset("ONE_PLAYER_CHALLENGE")
    self.stages = self:createStages(difficulty)
    self.difficulty = difficulty
    self.difficultyName = loc("challenge_difficulty_" .. difficulty)
    self.continues = 0
    self.expendedTime = 0
    self.gameScene = Game1pChallenge
    self.challengeComplete = false

    self:addPlayer(GAME.localPlayer)
    GAME.localPlayer:setStyle(GameModes.Styles.MODERN)

    self.player = ChallengeModePlayer(#self.players + 1)
    self.player.settings.difficulty = difficulty
    self:addPlayer(self.player)
    self:assignInputConfigurations()
    self:setStage(stageIndex or 1)
  end,
  BattleRoom
)

ChallengeMode.numDifficulties = 11

function ChallengeMode:createStages(difficulty)
  local stages = {}

  local stageCount
  local framesToppedOutToLoseBase
  local framesToppedOutToLoseIncrement
  local lineClearGPMBase
  local lineClearGPMIncrement
  local lineHeightToKill
  local panelLevel

  if difficulty == 1 then
    stageCount = 4
    framesToppedOutToLoseBase = 193
    framesToppedOutToLoseIncrement = 193
    lineClearGPMBase = 1.5
    lineClearGPMIncrement = 1.5
    panelLevel = 1
    lineHeightToKill = 3
  elseif difficulty == 2 then
    stageCount = 6
    framesToppedOutToLoseBase = 258
    framesToppedOutToLoseIncrement = 142
    lineClearGPMBase = 4.5
    lineClearGPMIncrement = 0.9
    panelLevel = 2
    lineHeightToKill = 4
  elseif difficulty == 3 then
    stageCount = 8
    framesToppedOutToLoseBase = 322
    framesToppedOutToLoseIncrement = 126
    lineClearGPMBase = 6.75
    lineClearGPMIncrement = 0.75
    panelLevel = 3
    lineHeightToKill = 5
  elseif difficulty == 4 then
    stageCount = 10
    framesToppedOutToLoseBase = 403
    framesToppedOutToLoseIncrement = 123
    lineClearGPMBase = 9
    lineClearGPMIncrement = 0.66
    panelLevel = 4
    lineHeightToKill = 6
  elseif difficulty == 5 then
    stageCount = 12
    framesToppedOutToLoseBase = 503
    framesToppedOutToLoseIncrement = 125
    lineClearGPMBase = 11.25
    lineClearGPMIncrement = 0.61
    panelLevel = 5
    lineHeightToKill = 7
  elseif difficulty == 6 then
    stageCount = 12
    framesToppedOutToLoseBase = 629
    framesToppedOutToLoseIncrement = 157
    lineClearGPMBase = 13.5
    lineClearGPMIncrement = 0.68
    panelLevel = 6
    lineHeightToKill = 8
  elseif difficulty == 7 then
    stageCount = 12
    framesToppedOutToLoseBase = 786
    framesToppedOutToLoseIncrement = 196
    lineClearGPMBase = 15.75
    lineClearGPMIncrement = 0.75
    panelLevel = 7
    lineHeightToKill = 9
  elseif difficulty == 8 then
    stageCount = 12
    framesToppedOutToLoseBase = 983
    framesToppedOutToLoseIncrement = 245
    lineClearGPMBase = 18
    lineClearGPMIncrement = 0.81
    panelLevel = 8
    lineHeightToKill = 10
  elseif difficulty == 9 then
    stageCount = 8
    framesToppedOutToLoseBase = 1229
    framesToppedOutToLoseIncrement = 482
    lineClearGPMBase = 20.25
    lineClearGPMIncrement = 1.39
    panelLevel = 9
    lineHeightToKill = 11
  elseif difficulty == 10 then
    stageCount = 8
    framesToppedOutToLoseBase = 1536
    framesToppedOutToLoseIncrement = 603
    lineClearGPMBase = 22.5
    lineClearGPMIncrement = 1.5
    panelLevel = 10
    lineHeightToKill = 12
  elseif difficulty == 11 then
    stageCount = 8
    framesToppedOutToLoseBase = 1920
    framesToppedOutToLoseIncrement = 754
    lineClearGPMBase = 24.75
    lineClearGPMIncrement = 1.6
    panelLevel = 11
    lineHeightToKill = 13
  else
    error("Invalid challenge mode difficulty level of " .. difficulty)
  end

  for stageIndex = 1, stageCount, 1 do
    local incrementMultiplier = stageIndex - 1
    local stage = {}
    stage.attackSettings = self:getAttackSettings(difficulty, stageIndex)
    stage.healthSettings = {
      framesToppedOutToLose = framesToppedOutToLoseBase + framesToppedOutToLoseIncrement * incrementMultiplier,
      lineClearGPM = lineClearGPMBase + lineClearGPMIncrement * incrementMultiplier,
      lineHeightToKill = lineHeightToKill,
      riseSpeed = levelPresets.getModern(panelLevel).startingSpeed
    }
    stage.playerLevel = panelLevel
    stage.expendedTime = 0
    stage.index = stageIndex

    stages[stageIndex] = stage
  end

  return stages
end

function ChallengeMode:attackFilePath(difficulty, stageIndex)
  for i = stageIndex, 1, -1 do
    local path = "client/assets/default_data/training/challenge-" .. difficulty .. "-" .. i .. ".json"
    if love.filesystem.getInfo(path) then
      return path
    end
  end

  return nil
end

function ChallengeMode:getAttackSettings(difficulty, stageIndex)
  local attackFile = readAttackFile(self:attackFilePath(difficulty, stageIndex))
  assert(attackFile ~= nil, "could not find attack file for challenge mode")
  return attackFile
end

function ChallengeMode:recordStageResult(winners, gameLength)
  local stage = self.stages[self.stageIndex]
  stage.expendedTime = stage.expendedTime + gameLength
  self.expendedTime = self.expendedTime + gameLength

  if #winners == 1 then
    -- increment win count on winning player if there is only one
    winners[1]:incrementWinCount()

    if winners[1] == self.player then
      self.continues = self.continues + 1
    else
      if self.stages[self.stageIndex + 1] then
        self:setStage(self.stageIndex + 1)
      else 
        self.challengeComplete = true
      end
    end
  elseif #winners == 2 then
    -- tie, stay on the same stage
    -- the player didn't lose so they get to redo the stage without increasing the continue counter
  elseif #winners == 0 then
    -- the game wasn't played to its conclusion which has to be considered a LOSS because only the player can prematurely end the game
    self.continues = self.continues + 1
  end
end

function ChallengeMode:onMatchEnded(match)
  self.matchesPlayed = self.matchesPlayed + 1

  local winners = match:getWinners()
  -- an abort is always the responsibility of the local player in challenge mode
  -- so always record the result, even if it may have been an abort
  local gameTime = 0
  local stack = match.stacks[1]
  if stack ~= nil and stack.game_stopwatch then
    gameTime = stack.game_stopwatch
  end
  self:recordStageResult(winners, gameTime)

  if self.online and match:hasLocalPlayer() then
    GAME.netClient:reportLocalGameResult(winners)
  end

  if match.aborted then
    -- in challenge mode, an abort is always a manual pause and leave by the local player
    -- match:deinit is the responsibility of the one switching out of the game scene
    GAME.navigationStack:pop(nil, function() match:deinit() end)

    -- when challenge mode becomes spectatable, there needs to be a network abort that isn't leave_room for spectators
  end

  -- nilling the match here doesn't keep the game scene from rendering it as it has its own reference
  self.match = nil
  self.state = BattleRoom.states.Setup
end

function ChallengeMode:setStage(index)
  self.stageIndex = index
  GAME.localPlayer:setLevel(self.stages[index].playerLevel)

  local stageSettings = self.stages[self.stageIndex]
  self.player.settings.attackEngineSettings = stageSettings.attackSettings
  self.player.settings.healthSettings = stageSettings.healthSettings
  self.player.level = index
  if stageSettings.characterId then
    self.player:setCharacter(stageSettings.characterId)
  else
    self.player:setCharacterForStage(self.stageIndex)
  end
  self.player:setStage("")
end

return ChallengeMode