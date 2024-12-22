local fileUtils = require("client.src.FileUtils")
local class = require("common.lib.class")
local analytics = {}

local analytics_version = 3

local function create_blank_data()
  return {
    -- the amount of destroyed panels
    destroyed_panels = 0,
    -- the amount of sent garbage
    sent_garbage_lines = 0,
    -- the amount of times the cursor was moved
    move_count = 0,
    -- the amount of times the panels were swapped
    swap_count = 0,
    -- sparse dictionary with a count of each chain reached, mystery chains are recorded as whatever chain they were, 1 is obviously meaningless
    reached_chains = {},
    -- sparse dictionary with a count of each combo reached, 1 to 3 being meaningless
    used_combos = {},
    shockGarbageCount = 0,
    -- the amound of wasted panels, used to determine efficiency
    wasted_panels = 0,
    -- the amount of garbage pieces sent
    garbage_pieces_sent = 0,
    -- the amount of garbage panels cleared
    garbage_cleared = 0
  }
end

-- The class representing one set of analytics data
AnalyticsInstance =
  class(
  function(self, save_to_overall)
    self.save_to_overall = save_to_overall -- whether this data should count towards the overall
    self.data = create_blank_data()
    
    -- temporary
    self.lastGPM = 0
    self.lastAPM = 0
    self.efficiency = 0
    self.lastPPM = 0
    self.garbage_in_queue = 0
    self.lastGCPM = 0
    self.lines_cleared = 0
  end
)

local analytics_data = {
  -- The lastly used version
  version = analytics_version,
  last_game = create_blank_data(),
  overall = create_blank_data()
}

local function analytic_clear(analytic)
  analytic.destroyed_panels = 0
  analytic.sent_garbage_lines = 0
  analytic.move_count = 0
  analytic.swap_count = 0
  analytic.reached_chains = {}
  analytic.used_combos = {}
  analytic.shockGarbageCount = 0
  analytic.wasted_panels = 0
  analytic.garbage_pieces_sent = 0
  analytic.garbage_cleared = 0
end

local amount_of_garbages_lines_per_combo = {0,0,0,0.5,0.7,0.8,1,1,1.3,1.7,
2, 1.5, 2, 2.5, 3, 2, 2.7, 3.3, 4, 2.5,
3.3, 4.2, 5, 3, 4, 5, 6, 3.5, 4.7, 5.8,
7, 4, 5.3, 6.7, 8, 8, 4.5, 6, 7.5, 9,
5,6.7,8.3,10,5.5,7.3,9.2,11,6,8,
10,12,6.5,8.7,10.8,13,7,9.3,11.7,14,
7.5,10,12.5,15,8,10.7,13.3,16,8.5,11.3,
14.2,17,9}
for i = 1, 72 do
  amount_of_garbages_lines_per_combo[i] = amount_of_garbages_lines_per_combo[i] or amount_of_garbages_lines_per_combo[i - 1]
end

local function compute_above_chain_card_limit(analytic, chainLimit)
  --computing chain ? count
  local chain_above_limit = 0
  for k, v in pairs(analytic.reached_chains) do
    if k > chainLimit then
      chain_above_limit = chain_above_limit + v
    end
  end
  return chain_above_limit
end

local function refresh_sent_garbage_lines(analytic)
  local sent_garbage_lines_count = 0
  for k, v in pairs(analytic.used_combos) do
    if k then
      sent_garbage_lines_count = sent_garbage_lines_count + amount_of_garbages_lines_per_combo[k] * v
    end
  end
  for i = 2, 13 do
    if analytic.reached_chains[i] then
      sent_garbage_lines_count = sent_garbage_lines_count + (i - 1) * analytic.reached_chains[i]
    end
  end
  local chain_above_13 = compute_above_chain_card_limit(analytics.last_game, 13)
  sent_garbage_lines_count = sent_garbage_lines_count + 13 * chain_above_13
  sent_garbage_lines_count = sent_garbage_lines_count + analytic.shockGarbageCount
  analytic.sent_garbage_lines = sent_garbage_lines_count
end

--TODO: cleanup all functions in this file to be object oriented and not global
function maxComboReached(data)
  local maxCombo = 0
  for index, _ in pairs(data.used_combos) do
    maxCombo = math.max(index, maxCombo)
  end
  return maxCombo
end

--TODO: cleanup all functions in this file to be object oriented and not global
function maxChainReached(data)
  local maxChain = 0
  for index, _ in pairs(data.reached_chains) do
    maxChain = math.max(index, maxChain)
  end
  return maxChain
end

-- this is a function that exists to address issue https://github.com/panel-attack/panel-game/issues/190
-- analytics - per standard - increment the values on number indices such as used_combos[4] = used_combos[4] + 1
-- for unknown reasons, at some point in time, some combos started to get saved as string values - and they are loaded every time on analytics.init
-- the json library we use does not support string and integer keys on the same table and only saves the entries with a string key to analytics.json
-- due to that, combo data is lost and in this function any string indices are converted to int
-- honestly no idea how they ever became strings, I assume someone fixed that already in the past but the lingering data continued to screw stuff over
local function correctComboIndices(dataToCorrect)
  local correctedCombos = {}
  for key, value in pairs(dataToCorrect["overall"]["used_combos"]) do
    local numberKey = tonumber(key)
    if type(numberKey) == "number" then
      if correctedCombos[numberKey] then
        correctedCombos[numberKey] = correctedCombos[numberKey] + value
      else
        correctedCombos[numberKey] = value
      end
    end
  end

  dataToCorrect["overall"]["used_combos"] = correctedCombos

  return dataToCorrect
end

function analytics.init()
  pcall(
    function()
      local data = fileUtils.readJsonFile("analytics_chaos.json")
      if data then
        analytics_data = data
      end
      if analytics_data then
        analytic_clear(analytics_data.last_game)
        analytics_data = correctComboIndices(analytics_data)

        -- do stuff regarding version compatibility here, before we patch it
        if analytics_data.version < 2 then
          refresh_sent_garbage_lines(analytics_data.overall)
        end

        analytics_data.version = analytics_version
      end
    end
  )
end

local function output_pretty_analytics()
  if not config.enable_analytics then
    return
  end

  local analytics_filters = {analytics_data.last_game, analytics_data.overall}
  local titles = {"Last game\n-------------------------------------\n", "Overall\n-------------------------------------\n"}
  local text = ""
  for i, analytic in pairs(analytics_filters) do
    text = text .. titles[i]
    text = text .. "Destroyed " .. analytic.destroyed_panels .. " panels.\n"
    text = text .. "Wasted" .. analytic.wasted_panels .. " panels.\n"
    text = text .. "Cleared " .. analytic.garbage_cleared .. " garbage panels.\n"
    text = text .. "Sent " .. analytic.sent_garbage_lines .. " lines of garbage.\n"
    text = text .. "Sent " .. analytic.garbage_pieces_sent .. " pieces of garbage.\n"
    text = text .. "Moved " .. analytic.move_count .. " times.\n"
    text = text .. "Swapped " .. analytic.swap_count .. " times.\n"
    text = text .. "Performed combos:\n"
    local maxCombo = maxComboReached(analytic)
    for j = 4, maxCombo do
      if analytic.used_combos[j] ~= nil then
        text = text .. "\t" .. analytic.used_combos[j] .. " combo(s) of size " .. j .. "\n"
      end
    end
    text = text .. "Reached chains:\n"
    local maxChain = maxChainReached(analytic)
    for j = 2, maxChain do
      if analytic.reached_chains[j] ~= nil then
        text = text .. "\t" .. analytic.reached_chains[j] .. " chain(s) have ended at length " .. j .. "\n"
      end
    end
    text = text .. "\n\n"
  end
  pcall(
    function()
      love.filesystem.write("analytics_chaos.txt", text)
    end
  )
end

local function write_analytics_files()
  pcall(
    function()
      if not config.enable_analytics then
        return
      end

      love.filesystem.write("analytics_chaos.json", json.encode(analytics_data))
    end
  )
  output_pretty_analytics()
end

function AnalyticsInstance.compute_above_chain_card_limit(self, chainLimit)
  return compute_above_chain_card_limit(self.data, chainLimit)
end

function AnalyticsInstance.data_update_list(self)
  local data_update_list = {self.data}

  if self.save_to_overall then
    table.insert(data_update_list, analytics_data.overall)
  end

  return data_update_list
end

function AnalyticsInstance.register_destroyed_panels(self, amount)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.destroyed_panels = analytic.destroyed_panels + amount
    if amount > 3 then
      if not analytic.used_combos[amount] then
        analytic.used_combos[amount] = 1
      else
        analytic.used_combos[amount] = analytic.used_combos[amount] + 1
      end
      analytic.sent_garbage_lines = analytic.sent_garbage_lines + amount_of_garbages_lines_per_combo[amount]
    end
  end
end

function AnalyticsInstance.register_wasted_panels(self, amount)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.wasted_panels = analytic.wasted_panels + amount
  end
end

function AnalyticsInstance.register_chain(self, size)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    if not analytic.reached_chains[size] then
      analytic.reached_chains[size] = 1
    else
      analytic.reached_chains[size] = analytic.reached_chains[size] + 1
    end
    analytic.sent_garbage_lines = analytic.sent_garbage_lines + (size - 1)
  end
end

function AnalyticsInstance.register_swap(self)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.swap_count = analytic.swap_count + 1
  end
end

function AnalyticsInstance.register_move(self)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.move_count = analytic.move_count + 1
  end
end

function AnalyticsInstance.register_pieces_sent(self, amount)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.garbage_pieces_sent = analytic.garbage_pieces_sent + amount
  end
end

function AnalyticsInstance.register_garbage_cleared(self)
  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.garbage_cleared = analytic.garbage_cleared + 1
  end
end

function AnalyticsInstance:registerShock()
  -- we don't track shock garbage sent in all-time analytics - for now
  self.data.shockGarbageCount = self.data.shockGarbageCount

  local analytics_filters = self:data_update_list()
  for _, analytic in pairs(analytics_filters) do
    analytic.sent_garbage_lines = analytic.sent_garbage_lines + 1
  end
end

function analytics.game_ends(analytic)
  if analytic then
    analytics_data.last_game = analytic.data
  end
  if config.enable_analytics then
    write_analytics_files()
  end
end

function AnalyticsInstance:getRoundedGPM(clock)
  local garbagePerMinute = self.data.sent_garbage_lines / (clock / 60 / 60)
  return string.format("%0.1f", math.round(garbagePerMinute, 1))
end

function AnalyticsInstance:getRoundedPPM(clock)
  local PiecesPerMinute = self.data.garbage_pieces_sent / (clock / 60 / 60)
  return string.format("%0.1f", math.round(PiecesPerMinute, 1))
end

function AnalyticsInstance:getRoundedGCPM(clock)
  local PiecesPerMinute = (self.data.garbage_cleared / 6) / (clock / 60 / 60)
  return string.format("%0.1f", math.round(PiecesPerMinute, 1))
end

return analytics
