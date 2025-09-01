local GameBase = require("client.src.scenes.GameBase")
local class = require("common.lib.class")

-- Scene for an endless mode instance of the game
local VsSelfGame = class(
  function (self, sceneParams)
    self.match:connectSignal("matchEnded", self, self.onMatchEnded)
  end,
  GameBase
)

VsSelfGame.name = "VsSelfGame"

function VsSelfGame:onMatchEnded(match)
  local P1 = match.players[1].stack
  GAME.scores:saveVsSelfScoreForLevel(P1.analytic.data.garbage_lines_sent, P1.level)
end

return VsSelfGame