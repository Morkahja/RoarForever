# Roar Forever

Restores the original player-character `/roar` voice sounds locally in World of Warcraft: Forever by listening for text-emote events and playing Blizzard's original audio via FileDataID.

This is a Forever port of the earlier `ROARSounds` addon.

## Forever compatibility

- Forever Interface number: `16001`
- Uses `CHAT_MSG_TEXT_EMOTE`
- Uses the sender GUID when available to resolve race and sex
- Falls back to player/target/mouseover/focus/party/raid unit matching
- Uses Blizzard's internal FileDataIDs, so no copied audio files are bundled
- Plays through the `Master` sound channel
- Keeps the original addon's 0.30-second duplicate guard

## Original roar FileDataIDs

The following mappings were resolved from the current `wowdev/wow-listfile` sound list:

| Character | FileDataID |
|---|---:|
| Dwarf Female | `539992` |
| Dwarf Male | `540087` |
| Gnome Female | `540457` |
| Gnome Male | `540497` |
| Human Female | `540615` |
| Human Male | `540697` |
| Night Elf Female | `541072` |
| Night Elf Male | `541132` |
| Orc Female | `541347` |
| Orc Male | `541398` |
| Tauren Female | `543016` |
| Tauren Male | `543062` |
| Troll Female | `543226` |
| Troll Male | `543311` |
| Undead Female | `542680` |
| Undead Male | `542740` |

`540457` (`VO_PCGnomeFemaleRoar01.ogg`) has been directly confirmed to play in the WoW Forever beta client. The remaining IDs are verified filename-to-FileDataID mappings and are now ready for in-client testing.

## Commands

- `/rf test` or `/roarforever test` plays the mapped roar for your current character.
- `/rf status` prints the detected race/sex key and mapped FileDataID.
- `/rf id 540457` directly tests any FileDataID.

## Installation

Place the repository contents in:

`World of Warcraft/_classic_era_/Interface/AddOns/RoarForever/`

The `RoarForever` folder should contain both `RoarForever.toc` and `RoarForever.lua`.
