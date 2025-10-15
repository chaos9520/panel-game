# ***The Chaos Build***
## Introduction
As some of you know, I have been working on this build for awhile. The initial idea behind this build was to scale out level difficulties properly and to cut down on match length. Funny thing is with all the changes I've implemented, this build has now transformed into something of it's own: a more 'modern' and competitive version of the game we all know and have a love/hate relationship with. :stuck_out_tongue_winking_eye:
# The Laundry List of Changes
## Level Data Changes
- The level data for both Modern and Classic levels have been revamped so they scale in difficulty properly. The Classic levels also scale differently from the Modern levels. *Level 8 is the closest to level 10 on the normal build, so I take it that will be the 'gold standard'.*
## Gameplay Changes
### Global Changes
- There are now two scoring systems; one for Modern, and the other for Classic.
- The score cap has been raised to 999,999 as scoring paces will naturally be faster on this build. Yes, 100k+ Time Attack runs are now possible on both Modern and Classic styles.
- The formula for stop time and stack rise speed has been changed.
### PvP Changes
- **Three overtime mechanics have been implemented:**
  - Garbage Margin: The more garbage a player has queued up, the less stop *and* shake time they get.
  - Health Margin: A player's remaining health will be reduced by 10% every 15 seconds. Health regeneration has also been removed.
  -Garbage Multiplier: At 2 minutes, combo garbage attacks send twice the amount of garbage. This does not apply to shock blocks, nor does it apply to garbage sent by training mode files.
- Shake time will always occur when down stacking with garbage, but the base shake time has been changed for all garbage.
- 3-wides will cascade instead or left and right.
- Queued garbage will fall if there is no active chain, and it will fall altogether instead of one-by-one.
### Classic Endless and Time Attack Changes
- Stop time has been removed.
- The amount of panels needed to rise the speed level has been adjusted.
## Server Changes
- The ELO rating system has been modified to allow more points to go around.
## Other Changes
- Challenge Mode has been completely revamped.
- Training Mode: The frequency and amount of garbage per volley now adjusts based on the garbage size chosen for basic training modes.
- Death-raising has been removed. Accidental death raises are very annoying, so I removed it.
- Custom Training/Challenge Mode patterns: You can choose what style of garbage pattern the game sends by changing the value for `mergeMetalComboQueue`.
  False - 'Modern' garbage queue.
  True - 'Classic' garbage queue.
- Analytics: Two analytics have been added to the display. Here are the analytics from top to bottom:
  - Panels cleared
  - Efficiency - any +3 that are not shock panels, is not part of a chain, and does not clear garbage will hurt efficiency.
  - Garbage lines sent.
  - Garbage per minute.
  - Garbage in queue - The amount of garbage pieces in the player's queue.
  - Moves
  - Swaps
  - Actions per Minute (APM)
- The default panels have been changed.
- The default telegraph and garbage images have been changed.
- APM and GPM are now measured accurately, and moves during countdown no longer count towards APM.
## What else needs to be implemented or changed?
### Port over from v048
- Endless/Time Attack kill screen.
- Garbage Lines Cleared analytic.
- My ranking system for the server. *(this one will take awhile)*
