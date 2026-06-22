# The Garbage Queue Types
Players can now select the garbage queue type in 1p Vs Self and 2p modes. Both players must select the same queue type in order for a game to be ranked.

Note: in 2p games, the selected queue type affects how *your opponent* receives garbage, not you.

Also, please note that changing this option at the select screen has no effect in 1p Training.
## Classic Queue
Garbage queues similar to how it works in the normal build, but metal garbage queues differently.
## Modern Queue
Garbage queues in the order it is made.
## Chaos Queue
Garbage queues in the order it is made, but queued garbage goes to the front of the queue, not the back.
## Testing Queues 1 and 2
I've also included two experimental garbage queue styles. Both work in a similar fashion. The only difference is that Testing 1 sends queued garbage to the back, while Testing 2 sends it to the front.
### How This Change Affects Training Patterns
This change obviously will break old replays, but it also will break compatibility with training files made for the vanilla build. To make any training files you have compatible with this build, you will need to change the following:
- The `name` parameter to `patternName`
- The `mergeMetalComboQueue` parameter to `GarbageQueueType`
- The value of previously named`mergeMetalComboQueue` to one of the values below:
```GarbageQueueType Values
1 = Modern
2 = Classic
3 = Chaos
4 = Testing 1
5 = Testing 2```
This means the Queue Type setting at the select screen has no effect.