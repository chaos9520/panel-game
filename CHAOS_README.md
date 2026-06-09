# ***The Chaos Build***
## Introduction
As some of you know, I have been working on this build for awhile. The initial ideas behind this build was to balance out the metagame, scale out level difficulties properly and to cut down on game length. Funny thing is with all the changes I've implemented, this build has now metamorphosed into something of its own: a more 'modern' and competitive version of the game we all know and have a love/hate relationship with. :stuck_out_tongue_winking_eye:
# The Laundry List of Changes
## Level Data Changes
- The level data for both Modern and Classic levels have been redesigned so they scale in difficulty properly. The Classic levels also scale differently from the Modern levels. *Level 8 is the closest to level 10 on the normal build, so I take it that will be the 'gold standard'.*

You can view the changes here: https://github.com/chaos9520/panel-game/blob/chaos_build/LEVEL_DATA.md
## Gameplay Changes
### Global Changes
- There are now two scoring systems; one for Modern, and the other for Classic.
- The score cap has been raised to 999,999 as scoring paces will naturally be faster on this build. Yes, 100k+ Time Attack runs are now possible on both Modern and Classic styles.
- The formulas for stop time and stack rise speed have been changed. Fair warning: 92 speed is where the fun begins. :smirk:

### PvP Changes
- Players can select different game modes and garbage queue types. More on that at https://github.com/chaos9520/panel-game/blob/chaos_build/CHAOS_GAME_MODES.md and You can view the changes here: https://github.com/chaos9520/panel-game/blob/chaos_build/CHAOS_QUEUE_TYPES.md
- Combo garbage attacks from +7 and higher send different garbage.
- **Three overtime mechanics have been implemented:**
  - Garbage Margin: The more garbage a player has queued up, the less stop *and* shake time they get.
  - Health Margin: A player's remaining health will be reduced by 10% every 15 seconds. Health regeneration has also been removed.
  - Shake Margin: Players will get less shake time as a match progresses. Shake time is also affected by the amount of garbage in a player's queue.
- Shake time will always occur when down stacking garbage, but the base shake time has been changed for all garbage.
### Classic Endless and Time Attack Changes
- The amount of panels needed to raise the speed level has been adjusted.
## Server Changes
- My Chaos ranking system has been implemented. It's basically a hybrid of ELO and glicko/glicko2, but the math is not nearly as complicated as glicko/glicko2.
## Other Changes
- Challenge Mode has been completely revamped. You can read about the changes and difficulties here: https://github.com/chaos9520/panel-game/blob/chaos_build/CHAOS_CHALLENGE_MODE.md
- Training Mode: The frequency and amount of garbage per volley now adjusts based on the garbage size chosen for basic training modes.
- Death-raising has been removed. Accidental death raises are very annoying, so I removed it.
- Custom Training Mode patterns: You can choose which garbage queue a training pettern uses by changing the value for `GarbageQueueType`, shown below:
  - 1 - 'Modern' garbage queue.
  - 2 - 'Classic' garbage queue.
  - 3 - 'Chaos' garbage queue.  
- Analytics: Moves and Swaps have been removed from the display, and three analytics have been added in their place. Here are the analytics from top to bottom:
  - Panels cleared
  - **Efficiency:** any +3 that are not shock panels, is not part of a chain, and does not clear garbage will hurt efficiency.
  - Garbage lines sent.
  - Garbage lines cleared
  - Garbage per Minute.
  - **Garbage in queue:** The amount of garbage pieces in the player's queue.
  - **Offensive Bias:** This is currently experimental. Positive numbers mean more chain heavy, and negative numbers mean more combo heavy.
  - Actions per Minute
- The default panels have been changed, and additional sets have been added.
- The default telegraph and garbage images have been changed.
- APM and GPM are now measured accurately, and moves during countdown no longer count towards APM.
