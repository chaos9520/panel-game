# Extra Settings
There are 4 extra settings that have been added to the 1p Vs Self/Training and 2p V2 select screens. Both players' settings must match in order
# The Game Modes
There will be 3 game modes players can play on. The attributes listed below affect only the player that is playing on the selected mode.
## __Classic Mode__
- Queued garbage will fall one-by-one for the most part.
## __Modern Mode__
The default game mode. Queued garbage falls all at once.
## __Tournament Mode__
I'm definitely keeping this as it drastically changes gameplay dynamics in a good way. This mode is similar to Modern, but with one key difference: There will be no stop time for combos or chains.
# The Garbage Queue Types
Players can now select the garbage queue type in 1p Vs Self and 2p modes. Both players must select the same queue type in order for a game to be ranked.

Note: in 2p games, the selected queue type affects how *your opponent* receives garbage, not you.

Also, please note that changing this option has no effect in 1p Training.
## Classic Queue
Garbage queues similar to how it works in the normal build, but metal garbage queues differently.
## Modern Queue
Garbage queues in the order it is made.
## Chaos Queue
Garbage queues in the order it is made, but queued garbage goes to the front of the queue, not the back.
## How The Queue Type Changes Affect Training Patterns
This change obviously will break old replays, but it also will break compatibility with training files made for the vanilla build. To make any training files you have compatible with this build, you will need to change the following:
- The `name` parameter to `patternName`
- The `mergeMetalComboQueue` parameter to `GarbageQueueType`
- The value of previously named`mergeMetalComboQueue` to one of the values below:
```GarbageQueueType Values
1 = Modern
2 = Classic
3 = Chaos
```
This also means the Queue Type setting at the select screen has no effect.
# Margin Time
Players will have the ability to turn off margin time if they choose to do so. Health will still deplete even when margin time is disabled.

Margin Time must be enabled in order to play ranked games.
# Chaos Mode
When Chaos Mode is enabled, the player can send unconventional garbage. However, all combo garbage the player receives will cascade.