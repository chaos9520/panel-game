leagues = { {league="Provisional",     min_rating = -9999},
            {league="Newbie",         min_rating = -3000},
            {league="Beginner",         min_rating = 500},
            {league="Novice",         min_rating = 1000},
            {league="Intermediate",         min_rating = 1500},
            {league="Advanced",         min_rating = 2000},
            {league="Expert",     min_rating = 2500},
            {league="Master",     min_rating = 3000},
          }
PLACEMENT_MATCH_COUNT_REQUIREMENT = 10
DEFAULT_RATING = 1500 -- With the new formula, DEFAULT_RATING and RATING_SPREAD_MODIFIER should be the same (50% of rating_scale).
RATING_SPREAD_MODIFIER = 1500
ALLOWABLE_RATING_SPREAD_MULITPLIER = 1 --set this to a huge number like 100 if you want everyone to be able to play with anyone, regardless of rating gap
NAME_LENGTH_LIMIT = 16
PLACEMENT_MATCHES_ENABLED = false -- This needs to stay false for everything to work properly. Currently untested.
COMPRESS_REPLAYS_ENABLED = true
COMPRESS_SPECTATOR_REPLAYS_ENABLED = true -- Send current replay inputs over the internet in a compressed format to spectators who join.
TCP_NODELAY_ENABLED = true -- Disables Nagle's Algorithm for TCP. Decreases data packet delivery delay, but increases amount of bandwidth and data used.
ANY_ENGINE_VERSION_ENABLED = false -- The server will accept any engine version. Mainly to be used for debugging.
ENGINE_VERSION = "952"
MIN_LEVEL_FOR_RANKED = 1
MAX_LEVEL_FOR_RANKED = 11
MIN_COLORS_FOR_RANKED = 5
MAX_COLORS_FOR_RANKED = 7
SERVER_PORT = 49569 -- default: 49569
SERVER_MODE = true -- global to know the server is running the process