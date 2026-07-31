# ***The Chaos Build***
## Introduction
As some of you know, I have been working on this build for awhile. The initial ideas behind this build was to balance out the metagame, scale out level difficulties properly and to cut down on game length. Funny thing is with all the changes I've implemented, this build has now metamorphosed into something of its own: a more 'modern' and competitive version of the game we all know and have a love/hate relationship with. :stuck_out_tongue_winking_eye:
# The Laundry List of Changes
## Level Data Changes
- Colors and Level Data have been de-coupled. That means players can now choose the amount of colors independent of the difficulty. *'Hard' is the closest to level 10 on the vanilla build, so I take it that will be the 'gold standard'.*

You can view the changes here: https://github.com/chaos9520/panel-game/blob/chaos_build/LEVEL_DATA.md
## Gameplay Changes
### Global Changes
- There are now three scoring systems; one for each mode.
- The score cap has been raised to 999,999 as scoring paces will naturally be faster on this build.
- The formulas for stop time and stack rise speed have been changed. Fair warning: 92 speed is where the fun begins. :smirk:
- Four extra settings have been added to most select screens. More on that here: <https://github.com/chaos9520/panel-game/blob/chaos_build/CHAOS_EXTRA_SETTINGS.md>
### PvP Changes
- Combo garbage attacks from +7 and higher send different garbage.
- **Margin Time has been implemented:**
  - Garbage Margin: The more garbage a player has queued up, the less stop *and* shake time they get.
  - Health Margin: A player's remaining health will be reduced by 10% every 15 seconds. Health regeneration has also been removed.
  - Shake Margin: Players will get less shake time as a match progresses. Shake time is affected by the amount of garbage in a player's queue.
  - A hard garbage queue limit of 50 pieces has been implemented.
### Classic Endless and Time Attack Changes
- Classic Endless and Time Attack have been [temporarily] removed.
## Server Changes
- My Chaos ranking system has been implemented. It's basically a hybrid of ELO and glicko/glicko2, but the math is not nearly as complicated as glicko/glicko2.
## Other Changes
- Challenge Mode has been completely revamped. You can read about the changes and difficulties here: https://github.com/chaos9520/panel-game/blob/chaos_build/CHAOS_CHALLENGE_MODE.md
- Training Mode: The frequency and amount of garbage per volley now adjusts based on the garbage size chosen for basic training modes.
- Death-raising has been removed. Accidental death raises are very annoying, so I removed it.
- Analytics: Panels Cleared, Moves and Swaps have been removed from the display, and different analytics have been added in their place. Here are the analytics from top to bottom:
  - Game Mode
  - Efficiency: any +3 that are not shock panels, is not part of a chain, and does not clear garbage will hurt efficiency.
  - Garbage lines sent.
  - Garbage lines cleared
  - Garbage per Minute.
  - Garbage in queue: The amount of garbage pieces in the player's queue.
  - Offensive Bias: This is currently experimental. Positive numbers mean more chain heavy, and negative numbers mean more combo heavy.
  - Actions per Minute
- The default panels have been changed, and additional sets have been added.
- The default telegraph and garbage images have been changed.
- APM and GPM are now measured accurately, and moves during countdown no longer count towards APM.
