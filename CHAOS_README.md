# ***The Chaos Build***
## Introduction
As some of you know, I have been working on this build for awhile. The initial idea behind this build was to scale out level difficulties properly and to cut down on match length. Funny thing is with all the changes I've implemented, this build has now transformed into something of it's own: a more 'modern' and competitive version of the game we all know and have a love/hate relationship with. :stuck_out_tongue_winking_eye:
# The Laundry List of Changes
## Level Data Changes
- The level data for both Modern and Classic levels have been changed so they scale in difficulty properly. The Classic levels scale differently from the Modern levels. *Level 8 is the closest to level 10 on the normal build, so I take it that will be the 'gold standard'.*
## Gameplay Changes
### Global Changes
- There are now two scoring systems; one for Modern, and the other for Classic.
- The score cap has been raised to 999,999 as scoring paces will naturally be faster on this build.
-# Yes, 100k+ Time Attack runs are now possible on both Modern and Classic styles.
- 'Wiggling' has been disabled, but stealth bridging has been implemented. It's a fair trade imo. *hello modoki lol*
- Rise Speed Algorithm: The formula for rise speed has been changed.
### Modern Style (includes Vs)
- **Garbage Margin has been implemented.** The more garbage a player has queued up, the less stop *and* shake time they get!
- **An overtime mechanic has been implemented.** At 2 minutes, two things will happen:
  - Queued garbage will no longer be held back by single-line garbage; it will fall if there is room.
  - Combo garbage attacks will send more garbage. Attack sizes increase every minute, and it maxes out at 5 minutes *(if you manage to survive that long!)*. This does *not* affect garbage patterns in Training or Challenge modes.
- The garbage queue and combo garbage system have been completely changed.
- The formula for stop time has been changed.
- Base shake time for most garbage has been increased.
- Health regeneration has been removed. That means if you take damage, then your health will not regenerate!
### Classic Style
- 'Speed margin' has been implemented into the Classic levels; higher rise speed equates to less base stop time.
- Speed levels now require 10 panels for a speed increase on *all* speed levels.
## Other Changes
- Challenge Mode has been revamped.
- Training Mode: The frequency and amount of garbage now adjusts based on the garbage size chosen for basic training modes.
- Training/Challenge Mode patterns: You can choose what style of garbage pattern the game sends by changing the value for `mergeMetalComboQueue`.
  False - 'Modern' garbage style.
  True - 'Classic' garbage style.
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
