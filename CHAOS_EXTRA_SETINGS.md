# Extra Settings
There are 4 extra settings that have been added to most select screens. Both players' settings must match in order for a game to be ranked.
# The Modes
There will be 4 game modes players can play on. The attributes listed below affect only the player that is playing on the selected mode.
## __Normal__
On this mode, The game will play as normal. The player will have health, and can generate stop time from chains, combos, and shocks.
## __1 HP__
On this mode, the player will have only 1 frame of health. However, the player can generate stop time for chains, combos, and shocks.
## __No Stop Time__
*NST* is the acronym for **No Stop Time.** On this mode, the player will have health, but they will not receive stop time for combos, chains, or shocks.
## __BALL Code__
Players that have played Tetris Attack or Panel de Pon know about this code and its effects. BALL does exactly that; this mode combines 1HP and No Stop Time. The player will have only 1 frame of health, and will not receive stop time for combos, chains, or shocks.
# The Garbage Types
Players can now select the garbage system type when playing in 1p Vs Self and 2p modes. Both players must select the same queue type in order for a game to be ranked.

Note: in 2p games, the selected queue type affects how *your opponent* receives garbage, not you.

Also, please note that changing this option has no effect in 1p Training.
## Classic
Garbage queues similar to how it works in the normal build, but metal garbage queues differently. Most garbage falls one-by-one.
## Modern
Garbage queues in the order it is made, and garbage falls all-together.
## Chaos
Garbage queues in the order it is made, but queued garbage goes to the front of the queue, not the back.

Garbage falls one-by-one during the first 5 minutes, but will fall all-together afterwards.
*Note: When Margin Time is disabled, garbage falls one-by-one the entire duration of the game.*
## How The Extra Settings Affect Attack Patterns
This change obviously will break old replays, but it also will break compatibility with training files made for the vanilla build. To make any attack patterns you have compatible with this build, you will need to do the following:
- Change the `name` parameter to `patternName`
- Change the `mergeMetalComboQueue` parameter to `GarbageQueueType`
- Change the value of previously named`mergeMetalComboQueue` to one of the values below:
```GarbageQueueType Values
1 = Modern
2 = Classic
3 = Chaos
```
- Add the following parameter: `ChaosMode`. Value for this parameter must be **boolean** (ie. true or false). Defaults to `false` if the parameter is omitted.

Training patterns from this build have their own folder: `training_chaos`. All training files, challenge mode patterns, and dumped attack patterns from this build will be stored there.

This change also means the Garbage setting at the select screen has no effect.
# Margin Time
Players will have the ability to turn off margin time if they choose to do so. When Margin Time is disabled, there is a hard garbage queue limit of 50 pieces to prevent games from going indefinitely.

Both players must have Margin Time enabled in order to play ranked games.
# Chaos Mode
When Chaos Mode is enabled, the player can send unconventional garbage. However, all combo garbage the player receives will cascade.