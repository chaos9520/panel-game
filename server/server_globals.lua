leagues = { {league="Unranked",     min_rating = -9999},
            {league="Newbie",         min_rating = -3000},
            {league="Beginner I",         min_rating = 400},
            {league="Beginner II",         min_rating = 600},
            {league="Novice I",         min_rating = 800},
            {league="Novice II",         min_rating = 1000},
            {league="Intermediate I",         min_rating = 1200},
            {league="Intermediate II",         min_rating = 1400},
            {league="Advanced I",         min_rating = 1600},
            {league="Advanced II",         min_rating = 1800},
            {league="Expert",     min_rating = 2000},
            {league="Candidate Master",     min_rating = 2200},
            {league="Master I",     min_rating = 2400},
            {league="Master II",     min_rating = 2600},
            {league="Master III",     min_rating = 2800},
            {league="Grandmaster",     min_rating = 3000},
          }
PLACEMENT_MATCH_COUNT_REQUIREMENT = 10
DEFAULT_RATING = 1400
RATING_SPREAD_MODIFIER = 960
ALLOWABLE_RATING_SPREAD_MULITPLIER = 1 --set this to a huge number like 100 if you want everyone to be able to play with anyone, regardless of rating gap
NAME_LENGTH_LIMIT = 16
PLACEMENT_MATCHES_ENABLED = false -- This needs to stay false for everything to work properly.
COMPRESS_REPLAYS_ENABLED = true
COMPRESS_SPECTATOR_REPLAYS_ENABLED = true -- Send current replay inputs over the internet in a compressed format to spectators who join.
TCP_NODELAY_ENABLED = true -- Disables Nagle's Algorithm for TCP. Decreases data packet delivery delay, but increases amount of bandwidth and data used.
ANY_ENGINE_VERSION_ENABLED = false -- The server will accept any engine version. Mainly to be used for debugging.
ENGINE_VERSION = "952"
MIN_LEVEL_FOR_RANKED = 1
MAX_LEVEL_FOR_RANKED = 9
MIN_COLORS_FOR_RANKED = 5
MAX_COLORS_FOR_RANKED = 7
SERVER_PORT = 49569 -- default: 49569
SERVER_MODE = true -- global to know the server is running the process