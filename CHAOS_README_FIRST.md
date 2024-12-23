# ***The Chaos Build***
## Introduction
As some of you know, I have been working on this build for awhile. The initial idea behind this build was to scale out level difficulties properly and to cut down on match length. Funny thing is with all the changes I've implemented, this build has now transformed into something of it's own: a more 'modern' and competitive version of the game we all know and have a love/hate relationship with. :stuck_out_tongue_winking_eyes:

## Latest Changes
Nothing significant for now, everything was just ported over.

## Client-Side Changes
- The level data for both Modern and Classic levels have been changed so they scale in difficulty properly.
- The Classic levels scale differently from the Modern levels.
-# Level 8 is the closest to level 10 on the normal build, so I take it that will be the 'gold standard'.
- Garbage Margin has been implemented in Vs modes. The more garbage a player has queued up, the less stop *and* shake time they get!
- 'Speed margin' has been implemented into the Classic levels; higher rise speed equates to less stop time.
- Health regeneration has been removed. That means if you take damage, then your health will not regenerate!
- 'Wiggling' has been disabled, but stealth bridging has been implemented. *hello modoki lol*
- Rise Speed Algorithm: The formula for rise speed has been changed, and Classic levels now require 10 panels for a speed increase on *all* speed levels (for now, still a WIP).
- There are now two scoring systems. The plan is to implement one scoring system for the Classic levels, and the other for the Modern levels.
- The score cap has been raised to 999,999 as scoring paces will naturally be higher on this build.
- The garbage queue and combo garbage system have been completely changed.
- Challenge Mode has been completely revamped.
- A few analytics have been removed, and new ones have been added:
    - Efficiency - any +3  that are not shock panels, is not part of a chain, and does not clear garbage will hurt efficiency.
    - Garbage lines cleared - counts only garbage panels that transforms into normal panels. 1 panel = 1/6 line.
    - Garbage pieces sent per minute
    - Garbage lines cleared per minute
    - Garbage pieces in queue
- The default telegraph and garbage images have been changed.

## Server-Side Changes
None yet, but I plan to implent my 'Chaos' ranking system to the server files when I am actually able to host my own server.

Combo garbage now queues in the order it is made. Combo garbage from +8 and higher will send multiple pieces relative to combo size while sent during a x3 or larger, and that garbage queues behind chain garbage.
Otherwise, it will send thicker garbage instead of multiple pieces relative to combo size, and it will queue in front of chain garbage.

On the normal levels, single-line garbage will hold back other garbage while clearing panels or garbage.  However, on the Chaos levels, garbage will fall immediately if there's room for it to fall, even while clearing panels or garbage.

## What else do I plan to implement?
Garbage Mode is the main goal I would like to accomplish. This would be very useful for training, but even more so for Challenge Mode stages.
