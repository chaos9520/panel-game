# ***The Chaos Build***
## Introduction
As some of you know, I have been working on this build for awhile. The initial idea behind this build was to scale out level difficulties properly and to cut down on match length. Funny thing is with all the changes I've implemented, this build has now transformed into something of it's own: a more 'modern' and competitive version of the game we all know and have a love/hate relationship with. :stuck_out_tongue_winking_eye:
# The Laundry List of Changes
## Level Data Changes
- The level data for both Modern and Classic levels have been changed so they scale in difficulty properly. The Classic levels also scale differently from the Modern levels. *Level 8 is the closest to level 10 on the normal build, so I take it that will be the 'gold standard'.*
## Gameplay Changes
### Global Changes
- There are now two scoring systems; one for Modern, and the other for Classic.
- The score cap has been raised to 999,999 as scoring paces will naturally be faster on this build. Yes, 100k+ Time Attack runs are now possible on both Modern and Classic styles.
- Rise Speed Algorithm: The formula for rise speed has been changed.
### Modern Style Changes (includes Vs)
There are quite a number of changes in the modern levels. Some changes are global, while others are exclusive to certain levels.
#### Changes to All Levels
- **Garbage Margin has been implemented.** The more garbage a player has queued up, the less stop *and* shake time they get!
- **Death-raising has been removed.**
- The formula for stop time has been changed.
- Health regeneration has been removed. That means if you take damage, then your health will not regenerate!
- Queued garbage will fall if there is no active chain.
#### Changes exclusive to Normal levels 1 to 11
- **An overtime mechanic has been implemented.** At 2 minutes, combo garbage attacks will send more garbage. Attack sizes increase every minute, and it maxes out at 5 minutes *(if you manage to survive that long!)*. This does *not* affect garbage patterns in Training or Challenge modes.
- Shake time will always occur when down stacking with garbage, but the base shake time has been decreased from normal.
- A player playing on these levels can send thicker combo garbage, but any 3-wides received from the opponent will cascade.
#### Changes exclusive to Classic Levels 1 to 4
I have recently ported over the Classic style levels over so that they are playable in Versus. At the select screen, they will show as levels 1 to 4, but the numbers will have a gray background instead of a colored one. There is no overtime mechanic for these levels.
- Base shake time has been increased from normal for most garbage.
- Shake time from garbage does not reset unless the next piece of garbage causes more shake time. However, shake time occurs only when falling onto the screen.
- Any 3-wides received from the opponent will not cascade.
### Classic Style Changes
- Stop time has been removed.
- The amount of panels needed to rise the speed level has been adjusted.
- A modified version of exploding lift has been implemented.
    - Stack raise cannot be stopped.
    - The stack cannot be raised manually while a clear is taking place.
    - **A natural kill screen has been implemented.** The game ends when the stack hits the top, even while panels are active.
## Server Changes
My custom ranking system has been implemented.
- ** All games in which both players are within range of each other will be ranked.**
  - This also includes games in which players are playing on different levels.
  - The rating system does take into account level differences.
  - Games in which one or both players are playing on Classic 1-4 will be unranked.
  - Touch will stay unranked.
- A player's starting rating will be adjusted based on the game level of the first ranked game played.
## Other Changes
- Challenge Mode has been completely revamped.
- Training Mode: The frequency and amount of garbage now adjusts based on the garbage size chosen for basic training modes.
- Custom Training/Challenge Mode patterns: You can choose what style of garbage pattern the game sends by changing the value for `mergeMetalComboQueue`.
  False - 'Modern' garbage queue.
  True - 'Classic' garbage queue.
- Analytics: Moves and Swaps have been removed from the analytics display, and new ones have been added. Here are the new analytics from top to bottom:
  - Panels cleared
  - ***Efficiency*** - any +3 that are not shock panels, is not part of a chain, and does not clear garbage will hurt efficiency.
  - Garbage lines sent.
  - ***Garbage lines cleared*** - counts only garbage panels that transforms into normal panels. 1 panel = 1/6 line.
  - Garbage lines per minute (GPM)
  - ***Garbage pieces sent per minute*** - Shows how many pieces of garbage a player is sending per minute.
  - ***Garbage lines cleared per minute*** - Shows how fast a player is clearing garbage.
  - ***Garbage pieces in queue*** - The number of garbage pieces in the player's queue.
  - Actions per Minute (APM)
- The default panels have been changed.
- The default telegraph and garbage images have been changed.
- APM and GPM are now measured accurately, and moves during countdown no longer count towards APM.
# What else needs to be implemented or changed?
- Shock panels from garbage needs to be ported over from v047 to the refactor.
- Garbage Mode is the main goal I would like to accomplish. This would be another useful tool for training.
