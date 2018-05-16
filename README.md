# What is this?

A mod that allows all players to talk to players in their proximity.

There's lots of mods like this on the workshop, although none are as
complete and as bug-free as this.

## Features

- Team-only proximity/local voice chat
- Non-team-only proximity/local voice chat
- Proximity voice chat works spectator, dead player, commander, etc., but with restrictions
- Static voice chat bar placement, so that the bar of a player does not move around constantly
- Different color for each voice channel (team-only, non-team-only, global)
- Customization of proximity/local voice chat colors through NS2+ (bottom of HUD menu)

## Bugs fixed compared to competitors
- Spectators not always being able to hear proximity/local voice chat when in first person mode
- Flickering voice chat bar, due to relevancy issues

# How to use this?

First of all you have to set your keybindings through the vanilla keybinding menu.
It's at the very bottom of the list, called something like "Proximity Chat".
Once you've set your keybindings, you can use proximity/local voice chat
on any server that has this mod enabled.

If you think the default colors are ugly, you can change them through
the HUD menu of NS2+ settings, at the very bottom.

# Voice chat restrictions

## Spectators
Spectators can **only** use local voice chat when the game is not in progress,
and even then, only when in first person mode!
This is a technical limitation, although I could work around it, but I'm too lazy.

## Commanders
Commanders can only use team-only local voice chat, and can not hear voice chat
from enemies that he can not see either (obviously).
The reason for the team-only restriction is also due to technical limitations.
