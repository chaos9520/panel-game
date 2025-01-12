local class = require("common.lib.class")
local logger = require("common.lib.logger")
local Replay = require("common.engine.Replay")
local ReplayPlayer = require("common.engine.ReplayPlayer")
local ServerProtocol = require("common.network.ServerProtocol")
local NetworkProtocol = require("common.network.NetworkProtocol")
local GameModes = require("common.engine.GameModes")
-- heresy, remove once communication of levelData is established
local LevelPresets = require("common.engine.LevelPresets")
local util = require("common.lib.util")

local sep = package.config:sub(1, 1) --determines os directory separator (i.e. "/" or "\")

-- Object that represents a current session of play between two connections
-- Players alternate between the character select state and playing, and spectators can join and leave
Room =
class(
function(self, a, b, roomNumber, leaderboard, server)
  --TODO: it would be nice to call players a and b something more like self.players[1] and self.players[2]
  self.a = a --player a as a connection object
  self.b = b --player b as a connection object
  self.a:connectSignal("settingsUpdated", self, self.onPlayerSettingsUpdate)
  self.b:connectSignal("settingsUpdated", self, self.onPlayerSettingsUpdate)
  self.server = server
  self.stage = nil -- stage for the game, randomly picked from both players
  self.name = a.name .. " vs " .. b.name
  self.roomNumber = roomNumber
  self.a.room = self
  self.b.room = self
  self.spectators = {} -- array of spectator connection objects
  self.win_counts = {} -- win counts by player number
  self.win_counts[1] = 0
  self.win_counts[2] = 0
  local a_rating, b_rating
  local a_placement_match_progress, b_placement_match_progress

  if a.user_id then
    if leaderboard.players[a.user_id] and leaderboard.players[a.user_id].rating then
      a_rating = math.round(leaderboard.players[a.user_id].rating)
    end
    local a_qualifies, a_progress = self.server:qualifies_for_placement(a.user_id)
    if not (leaderboard.players[a.user_id] and leaderboard.players[a.user_id].placement_done) and not a_qualifies then
      a_placement_match_progress = a_progress
    end
  end

  if b.user_id then
    if leaderboard.players[b.user_id] and leaderboard.players[b.user_id].rating then
      b_rating = math.round(leaderboard.players[b.user_id].rating or 0)
    end
    local b_qualifies, b_progress = self.server:qualifies_for_placement(b.user_id)
    if not (leaderboard.players[b.user_id] and leaderboard.players[b.user_id].placement_done) and not b_qualifies then
      b_placement_match_progress = b_progress
    end
  end

  self.ratings = {
    {old = a_rating or 0, new = a_rating or 0, difference = 0, league = self.server:get_league(a_rating or 0), placement_match_progress = a_placement_match_progress},
    {old = b_rating or 0, new = b_rating or 0, difference = 0, league = self.server:get_league(b_rating or 0), placement_match_progress = b_placement_match_progress}
  }

  self.game_outcome_reports = {} -- mapping of what each player reports the outcome of the game

  self.b.cursor = "__Ready"
  self.a.cursor = "__Ready"

  self.a.opponent = self.b
  self.b.opponent = self.a

  self:prepare_character_select()

  local messageForA = ServerProtocol.createRoom(
    self.roomNumber,
    a:getSettings(),
    b:getSettings(),
    self.ratings[1],
    self.ratings[2],
    b.name,
    2
  )
  a:sendJson(messageForA)

  local messageForB = ServerProtocol.createRoom(
    self.roomNumber,
    a:getSettings(),
    b:getSettings(),
    self.ratings[1],
    self.ratings[2],
    a.name,
    1
  )
  b:sendJson(messageForB)
end
)

function Room:onPlayerSettingsUpdate(player)
  if self:state() == "character select" then
    logger.debug("about to check for rating_adjustment_approval for " .. self.a.name .. " and " .. self.b.name)
    if self.a.wants_ranked_match or self.b.wants_ranked_match then
      local ranked_match_approved, reasons = self:rating_adjustment_approved()
      self:broadcastJson(ServerProtocol.updateRankedStatus(ranked_match_approved, reasons))
    end

    if self.a.ready and self.b.ready then
      self:start_match()
    else
      local settings = player:getSettings()
      local msg = ServerProtocol.menuState(settings, player.player_number)
      self:broadcastJson(msg, player)
    end
  end
end

function Room:start_match()
  local a = self.a
  local b = self.b

  a.wantsReady = false
  b.wantsReady = false

  if (a.player_number ~= 1) then
    logger.debug("players a and b need to be swapped.")
    a, b = b, a
    if (a.player_number == 1) then
      logger.debug("Success, player a now has player_number 1.")
    else
      logger.error("ERROR: player a still doesn't have player_number 1.")
    end
  end

  self.replay = Replay(ENGINE_VERSION, math.random(1,9999999), GameModes.getPreset("TWO_PLAYER_VS"))
  self.replay:setStage(math.random(1, 2) == 1 and a.stage or b.stage)

  self.inputs = {}
  local players = {a, b}
  for i, player in ipairs(players) do
    self.inputs[i] = {}
    local replayPlayer = ReplayPlayer(player.name, player.player.publicPlayerID, true)
    replayPlayer:setWins(self.win_counts[i])
    replayPlayer:setCharacterId(player.character)
    replayPlayer:setPanelId(player.panels_dir)
    if player.levelData then
      replayPlayer:setLevelData(player.levelData)
    else
      replayPlayer:setLevelData(LevelPresets.getModern(player.level))
    end
    replayPlayer:setInputMethod(player.inputMethod)
    -- TODO: pack the adjacent color setting with level data or send it with player settings
    -- this is not something for the server to decide, it should just take what it gets
    if self.replay.gameMode.StackInteractions == GameModes.StackInteractions.NONE then
      replayPlayer:setAllowAdjacentColors(true)
    else
      replayPlayer:setAllowAdjacentColors(player.level < 8)
    end
    -- this is a display-only prop, the true info is stored in levelData
    replayPlayer:setLevel(player.level)

    self.replay:updatePlayer(i, replayPlayer)
  end

  local aRating, bRating
  local roomIsRanked, reasons = self:rating_adjustment_approved()

  self.replay:setRanked(roomIsRanked)

  if roomIsRanked then
    if leaderboard.players[a.user_id] then
      aRating = math.round(leaderboard.players[a.user_id].rating)
    else
      aRating = DEFAULT_RATING
    end
    if leaderboard.players[b.user_id] then
      bRating = math.round(leaderboard.players[b.user_id].rating)
    else
      bRating = DEFAULT_RATING
    end
  end

  local aDumbSettings = a:getDumbSettings(aRating)
  local bDumbSettings = b:getDumbSettings(bRating)

  local messageForA = ServerProtocol.startMatch(
    self.replay.seed,
    self.replay.ranked,
    self.replay.stageId,
    aDumbSettings,
    bDumbSettings
  )
  a:sendJson(messageForA)
  self:sendJsonToSpectators(messageForA)

  local messageForB = ServerProtocol.startMatch(
    self.replay.seed,
    self.replay.ranked,
    self.replay.stageId,
    bDumbSettings,
    aDumbSettings
  )
  b:sendJson(messageForB)

  a:setup_game()
  b:setup_game()

  for _, v in pairs(self.spectators) do
    v:setup_game()
  end
end

function Room:character_select()
  self:prepare_character_select()
  self:broadcastJson(
    ServerProtocol.characterSelect(
      self.ratings[1],
      self.ratings[2],
      self.a:getSettings(),
      self.b:getSettings()
    )
  )
end

function Room:prepare_character_select()
  logger.debug("Called Server.lua Room.character_select")
  self.a.state = "character select"
  self.b.state = "character select"
  if self.a.player_number and self.a.player_number ~= 0 and self.a.player_number ~= 1 then
    logger.debug("initializing room. player a does not have player_number 1. Swapping players a and b")
    self.a, self.b = self.b, self.a
    if self.a.player_number == 1 then
      logger.debug("Success. player a has player_number 1 now.")
    else
      logger.error("ERROR. Player a still doesn't have player_number 1")
    end
  else
    self.a.player_number = 1
    self.b.player_number = 2
  end
  self.a.cursor = "__Ready"
  self.b.cursor = "__Ready"
  self.a.ready = false
  self.b.ready = false
end

function Room:state()
  if self.a.state == "character select" then
    return "character select"
  elseif self.a.state == "playing" then
    return "playing"
  else
    return self.a.state
  end
end

function Room:add_spectator(new_spectator_connection)
  new_spectator_connection.state = "spectating"
  new_spectator_connection.room = self
  self.spectators[#self.spectators + 1] = new_spectator_connection
  logger.debug(new_spectator_connection.name .. " joined " .. self.name .. " as a spectator")

  if self.replay then
    for i, player in ipairs(self.replay.players) do
      player.settings.inputs = table.concat(self.inputs[i])
      if COMPRESS_REPLAYS_ENABLED then
        player.settings.inputs = ReplayPlayer.compressInputString(player.settings.inputs)
      end
    end
  end

  local message = ServerProtocol.spectateRequestGranted(
    self.roomNumber,
    self.a:getSettings(),
    self.b:getSettings(),
    self.ratings[1],
    self.ratings[2],
    self.a.name,
    self.b.name,
    self.win_counts,
    self.stage,
    self.replay,
    self.ranked,
    self.a:getDumbSettings(),
    self.b:getDumbSettings()
  )

  new_spectator_connection:sendJson(message)
  local spectatorList = self:spectator_names()
  logger.debug("sending spectator list: " .. json.encode(spectatorList))
  self:broadcastJson(ServerProtocol.updateSpectators(spectatorList))
end

function Room:spectator_names()
  local list = {}
  for k, v in pairs(self.spectators) do
    list[#list + 1] = v.name
  end
  return list
end

function Room:remove_spectator(connection)
  local lobbyChanged = false
  for k, v in pairs(self.spectators) do
    if v.name == connection.name then
      self.spectators[k].state = "lobby"
      logger.debug(connection.name .. " left " .. self.name .. " as a spectator")
      self.spectators[k] = nil
      connection.room = nil
      lobbyChanged = true
    end
  end
  local spectatorList = self:spectator_names()
  logger.debug("sending spectator list: " .. json.encode(spectatorList))
  self:broadcastJson(ServerProtocol.updateSpectators(spectatorList))
  return lobbyChanged
end

function Room:close()
  if self.a then
    self.a.player_number = 0
    self.a.state = "lobby"
    self.a.room = nil
  end
  if self.b then
    self.b.player_number = 0
    self.b.state = "lobby"
    self.b.room = nil
  end
  for k, v in pairs(self.spectators) do
    if v.room then
      v.room = nil
      v.state = "lobby"
    end
  end
  self:sendJsonToSpectators(ServerProtocol.leaveRoom())
end

function Room:sendJsonToSpectators(message)
  for k, v in pairs(self.spectators) do
    if v then
      v:sendJson(message)
    end
  end
end

function Room:broadcastInput(input, sender)
  self.inputs[sender.player_number][#self.inputs[sender.player_number] + 1] = input

  local inputMessage = NetworkProtocol.markedMessageForTypeAndBody(NetworkProtocol.serverMessageTypes.opponentInput.prefix, input)
  sender.opponent:send(inputMessage)

  if sender.player_number == 1 then
    inputMessage = NetworkProtocol.markedMessageForTypeAndBody(NetworkProtocol.serverMessageTypes.secondOpponentInput.prefix, input)
  end

  for _, v in pairs(self.spectators) do
    if v then
      v:send(inputMessage)
    end
  end
end

-- broadcasts the message to everyone in the room
-- if an optional sender is specified, they are excluded from the broadcast
function Room:broadcastJson(message, sender)
  if self.a and self.a ~= sender then
    self.a:sendJson(message)
  end
  if self.b and self.b ~= sender then
    self.b:sendJson(message)
  end
  self:sendJsonToSpectators(message)
end

function Room:reportOutcome(player, outcome)
  self.game_outcome_reports[player.player_number] = outcome
  if self:resolve_game_outcome() then
    logger.debug("\n*******************************")
    logger.debug("***" .. self.a.name .. " " .. self.win_counts[1] .. " - " .. self.win_counts[2] .. " " .. self.b.name .. "***")
    logger.debug("*******************************\n")
    self.game_outcome_reports = {}
    self:character_select()
  end
end

function Room:resolve_game_outcome()
  --Note: return value is whether the outcome could be resolved
  if not self.game_outcome_reports[1] or not self.game_outcome_reports[2] then
    return false
  else
    local outcome = nil
    if self.game_outcome_reports[1] ~= self.game_outcome_reports[2] then
      --if clients disagree, the server needs to decide the outcome, perhaps by watching a replay it had created during the game.
      --for now though...
      logger.warn("clients " .. self.a.name .. " and " .. self.b.name .. " disagree on their game outcome. So the server will declare a tie.")
      outcome = 0
    else
      outcome = self.game_outcome_reports[1]
    end
    local gameID = self.server.database:insertGame(self.replay.ranked)
    self.replay.gameId = gameID
    if outcome ~= 0 then
      self.replay.winnerIndex = outcome
      self.replay.winnerId = self.replay.players[outcome].publicId
      self.server.database:insertPlayerGameResult(self.a.user_id, gameID, self.replay.players[1].settings.level, (self.a.player_number == outcome) and 1 or 2)
      self.server.database:insertPlayerGameResult(self.b.user_id, gameID, self.replay.players[2].settings.level, (self.b.player_number == outcome) and 1 or 2)
    else
      self.server.database:insertPlayerGameResult(self.a.user_id, gameID, self.replay.players[1].settings.level, 0)
      self.server.database:insertPlayerGameResult(self.b.user_id, gameID, self.replay.players[2].settings.level, 0)
    end

    logger.debug("resolve_game_outcome says: " .. outcome)
    --outcome is the player number of the winner, or 0 for a tie
    if self.a.save_replays_publicly ~= "not at all" and self.b.save_replays_publicly ~= "not at all" then
      if self.a.save_replays_publicly == "anonymously" then
        self.replay.players[1].name = "anonymous"
        if self.replay.players[1].publicId == self.replay.winnerId then
          self.replay.winnerId = -1
        end
        self.replay.players[1].publicId = -1
      end
      if self.b.save_replays_publicly == "anonymously" then
        self.replay.players[2].name = "anonymous"
        if self.replay.players[2].publicId == self.replay.winnerId then
          self.replay.winnerId = -2
        end
        self.replay.players[2].publicId = -2
      end

      local path = "ftp" .. sep .. self.replay:generatePath(sep)
      local filename = self.replay:generateFileName() .. ".json"

      for i, player in ipairs(self.replay.players) do
        player.settings.inputs = table.concat(self.inputs[i])
        if COMPRESS_REPLAYS_ENABLED then
          player.settings.inputs = ReplayPlayer.compressInputString(player.settings.inputs)
        end
      end

      logger.debug("saving replay as " .. path .. sep .. filename)
      write_replay_file(self.replay, path, filename)
    else
      logger.debug("replay not saved because a player didn't want it saved")
    end

    self.replay = nil

    --check that it's ok to adjust ratings
    local shouldAdjustRatings, reasons = self:rating_adjustment_approved()

    -- record the game result for statistics, record keeping, and testing new features
    local resultValue = 0.5
    if self.a.player_number == outcome then
      resultValue = 1
    elseif self.b.player_number == outcome then
      resultValue = 0
    end
    local rankedValue = 0
    if shouldAdjustRatings then
      rankedValue = 1
    end
    logGameResult(self.a.user_id, self.b.user_id, resultValue, rankedValue)

    if outcome == 0 then
      logger.debug("tie.  Nobody scored")
      --do nothing. no points or rating adjustments for ties.
      return true
    else
      local someone_scored = false

      for i = 1, 2, 1 --[[or Number of players if we implement more than 2 players]] do
        logger.debug("checking if player " .. i .. " scored...")
        if outcome == i then
          logger.trace("Player " .. i .. " scored")
          self.win_counts[i] = self.win_counts[i] + 1
          if shouldAdjustRatings then
            self.server:adjust_ratings(self, i, gameID)
          else
            logger.debug("Not adjusting ratings because: " .. reasons[1])
          end
          someone_scored = true
        end
      end

      if someone_scored then
        local message = ServerProtocol.winCounts(self.win_counts[1], self.win_counts[2])
        self:broadcastJson(message)
      end
      return true
    end
  end
end

function Room:rating_adjustment_approved()
  --returns whether both players in the room have game states such that rating adjustment should be approved
  local players = {self.a, self.b}
  local reasons = {}
  local caveats = {}
  local both_players_are_placed = nil

  if PLACEMENT_MATCHES_ENABLED then
    if leaderboard.players[players[1].user_id] and leaderboard.players[players[1].user_id].placement_done and leaderboard.players[players[2].user_id] and leaderboard.players[players[2].user_id].placement_done then
      --both players are placed on the leaderboard.
      both_players_are_placed = true
    elseif not (leaderboard.players[players[1].user_id] and leaderboard.players[players[1].user_id].placement_done) and not (leaderboard.players[players[2].user_id] and leaderboard.players[players[2].user_id].placement_done) then
      reasons[#reasons + 1] = "Neither player has finished enough placement matches against already ranked players"
    end
  else
    both_players_are_placed = true
  end
  -- don't let players use the same account
  if players[1].user_id == players[2].user_id then
    reasons[#reasons + 1] = "Players cannot use the same account"
  end

  --don't let players too far apart in rating play ranked
  local ratings = {}
  for k, v in ipairs(players) do
    if leaderboard.players[v.user_id] then
      if not leaderboard.players[v.user_id].placement_done and leaderboard.players[v.user_id].placement_rating then
        ratings[k] = leaderboard.players[v.user_id].placement_rating
      elseif leaderboard.players[v.user_id].rating and leaderboard.players[v.user_id].rating ~= 0 then
        ratings[k] = leaderboard.players[v.user_id].rating
      else
        ratings[k] = DEFAULT_RATING
      end
    else
      ratings[k] = DEFAULT_RATING
    end
  end
  if math.abs(ratings[1] - ratings[2]) > RATING_SPREAD_MODIFIER * ALLOWABLE_RATING_SPREAD_MULITPLIER then
    reasons[#reasons + 1] = "Players' ratings are too far apart"
  end

  local player_level_out_of_bounds_for_ranked = false
  for i = 1, 2 do --we'll change 2 here when more players are allowed.
    if (players[i].level < MIN_LEVEL_FOR_RANKED or players[i].level > MAX_LEVEL_FOR_RANKED) then
      player_level_out_of_bounds_for_ranked = true
    end
  end
  if player_level_out_of_bounds_for_ranked then
    reasons[#reasons + 1] = "Only levels between " .. MIN_LEVEL_FOR_RANKED .. " and " .. MAX_LEVEL_FOR_RANKED .. " are allowed for ranked play."
  end
  -- local playerColorsOutOfBoundsForRanked = false
  -- for i, player in ipairs(players) do
  --   if player.levelData.colorCount < MIN_COLORS_FOR_RANKED or player.levelData.colorCount > MAX_COLORS_FOR_RANKED then
  --     playerColorsOutOfBoundsForRanked = true
  --   end
  -- end
  -- if playerColorsOutOfBoundsForRanked then
  --   reasons[#reasons + 1] = "Only color counts between " .. MIN_COLORS_FOR_RANKED .. " and " .. MAX_COLORS_FOR_RANKED .. " are allowed for ranked play."
  -- end
  if players[1].level ~= players[2].level then
    reasons[#reasons + 1] = "Levels don't match"
  -- elseif not deep_content_equal(players[1].levelData or LevelPresets.getModern(players[1].level), players[2].levelData or LevelPresets.getModern(players[2].level)) then
  --  reasons[#reasons + 1] = "Level data doesn't match"
  end

  for i, player in ipairs(players) do
    if not deep_content_equal(player.levelData, LevelPresets.getModern(player.level)) then
      reasons[#reasons + 1] = player.name .. " uses modified level data"
    end
  end

  if players[1].inputMethod == "touch" or players[2].inputMethod == "touch" then
    reasons[#reasons + 1] = "Touch input is not currently allowed in ranked matches."
  end
  for player_number = 1, 2 do
    if not players[player_number].wants_ranked_match then
      reasons[#reasons + 1] = players[player_number].name .. " doesn't want ranked"
    end
  end
  if reasons[1] then
    return false, reasons
  else
    if PLACEMENT_MATCHES_ENABLED and not both_players_are_placed and ((leaderboard.players[players[1].user_id] and leaderboard.players[players[1].user_id].placement_done) or (leaderboard.players[players[2].user_id] and leaderboard.players[players[2].user_id].placement_done)) then
      caveats[#caveats + 1] = "Note: Rating adjustments for these matches will be processed when the newcomer finishes placement."
    end
    return true, caveats
  end
end
