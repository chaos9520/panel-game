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

ChallengeMode.numDifficulties = 14

function ChallengeMode:createStages(difficulty)
  local stages = {}

  local stageCount
  local framesToppedOutToLoseBase
  local framesToppedOutToLoseIncrement
  local lineClearGPMBase
  local lineClearGPMIncrement
  local lineHeightToKillBase
  local lineHeightToKillIncrement
  local panelLevel
  local panelLevelIncrement

  if difficulty == 1 then
    stageCount = 8
    framesToppedOutToLoseBase = 180
    framesToppedOutToLoseIncrement = 128
    lineClearGPMBase = 9
    lineClearGPMIncrement = (6 / 7)
    panelLevel = 1
    panelLevelIncrement = 0.25
    lineHeightToKillBase = 2
    lineHeightToKillIncrement = (3 / 7)
  elseif difficulty == 2 then
    stageCount = 10
    framesToppedOutToLoseBase = 360
    framesToppedOutToLoseIncrement = 100
    lineClearGPMBase = 12
    lineClearGPMIncrement = (2 / 3)
    panelLevel = 3
    panelLevelIncrement = (1 / 6)
    lineHeightToKillBase = 3
    lineHeightToKillIncrement = (1 / 3)
  elseif difficulty == 3 then
    stageCount = 12
    framesToppedOutToLoseBase = 540
    framesToppedOutToLoseIncrement = 81
    lineClearGPMBase = 15
    lineClearGPMIncrement = (6 / 11)
    panelLevel = 5
    panelLevelIncrement = 0.125
    lineHeightToKillBase = 5
    lineHeightToKillIncrement = (3 / 11)
  elseif difficulty == 4 then
    stageCount = 12
    framesToppedOutToLoseBase = 720
    framesToppedOutToLoseIncrement = 81
    lineClearGPMBase = 18
    lineClearGPMIncrement = (6 / 11)
    panelLevel = 5
    panelLevelIncrement = (1 / 6)
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 11)
  elseif difficulty == 5 then
    stageCount = 12
    framesToppedOutToLoseBase = 900
    framesToppedOutToLoseIncrement = 81
    lineClearGPMBase = 21
    lineClearGPMIncrement = (6 / 11)
    panelLevel = 7
    panelLevelIncrement = (1 / 6)
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 11)
  elseif difficulty == 6 then
    stageCount = 12
    framesToppedOutToLoseBase = 1080
    framesToppedOutToLoseIncrement = 81
    lineClearGPMBase = 24
    lineClearGPMIncrement = (6 / 11)
    panelLevel = 8
    panelLevelIncrement = (1 / 6)
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 11)
  elseif difficulty == 7 then
    stageCount = 8
    framesToppedOutToLoseBase = 1260
    framesToppedOutToLoseIncrement = 128
    lineClearGPMBase = 27
    lineClearGPMIncrement = (6 / 7)
    panelLevel = 10
    panelLevelIncrement = 0.25
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 8 then
    stageCount = 4
    framesToppedOutToLoseBase = 3600
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 15
    lineClearGPMIncrement = 0
    panelLevel = 1
    panelLevelIncrement = 0.5
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 9 then
    stageCount = 6
    framesToppedOutToLoseBase = 3600
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 18
    lineClearGPMIncrement = 0
    panelLevel = 3
    panelLevelIncrement = (1 / 3)
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 10 then
    stageCount = 8
    framesToppedOutToLoseBase = 3600
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 21
    lineClearGPMIncrement = 0
    panelLevel = 5
    panelLevelIncrement = 0.25
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 11 then
    stageCount = 8
    framesToppedOutToLoseBase = 3600
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 24
    lineClearGPMIncrement = 0
    panelLevel = 7
    panelLevelIncrement = 0.25
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 12 then
    stageCount = 9
    framesToppedOutToLoseBase = 3600
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 27
    lineClearGPMIncrement = 0
    panelLevel = 7
    panelLevelIncrement = (1 / 3)
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 13 then
    stageCount = 9
    framesToppedOutToLoseBase = 3600
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 30
    lineClearGPMIncrement = 0
    panelLevel = 9
    panelLevelIncrement = (1 / 3)
    lineHeightToKillBase = 6
    lineHeightToKillIncrement = (2 / 7)
  elseif difficulty == 14 then
    stageCount = 8
    framesToppedOutToLoseBase = 1
    framesToppedOutToLoseIncrement = 0
    lineClearGPMBase = 0
    lineClearGPMIncrement = 0
    panelLevel = 14
    panelLevelIncrement = 0
    lineHeightToKillBase = 10
    lineHeightToKillIncrement = 10
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
      lineHeightToKill = lineHeightToKillBase + lineHeightToKillIncrement * incrementMultiplier,
      riseSpeed = levelPresets.getModern(math.floor(panelLevel + panelLevelIncrement * incrementMultiplier)).startingSpeed
    }
    stage.playerLevel = math.floor(panelLevel + panelLevelIncrement * incrementMultiplier)
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