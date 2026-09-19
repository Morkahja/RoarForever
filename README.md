# Roar Forever

Restores the original player-character `/roar` voice sounds locally in World of Warcraft: Forever by listening for text-emote events and playing Blizzard's original audio via FileDataID.

This is a Forever port of the earlier `ROARSounds` addon.

## Current state

- Modern event-handler structure for the Forever client.
- Detects `/roar` through `CHAT_MSG_TEXT_EMOTE`.
- Uses sender GUID information when available to determine race and sex.
- Falls back to player/target/mouseover/focus/party/raid unit matching.
- Per-sender 0.30-second duplicate guard.
- Plays original Blizzard audio through `PlaySoundFile(FileDataID, "Master")`.
- Female Gnome roar FileDataID `540457` is verified working in the Forever beta.
- Other race/sex FileDataIDs are intentionally not included until verified.

## Test commands

`/rf test` plays the mapped roar for your current character.

`/rf status` prints the detected race/sex key and mapped FileDataID.

`/rf id 540457` directly tests a FileDataID.

## Installation status

The Lua implementation is present. The `.toc` manifest will be added using the exact Forever Interface number reported by the beta client rather than guessing it.
