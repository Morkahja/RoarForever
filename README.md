# Roar Forever

Roar Forever restores the original player-character `/roar` voice sounds locally in World of Warcraft: Forever and adds an optional ability-triggered emote system.

This is a Forever port and expansion of the earlier `ROARSounds` / RoarGuild ideas.

## Forever compatibility

- Forever Interface number: `16001`
- Uses `CHAT_MSG_TEXT_EMOTE` for roar sound restoration
- Uses `UNIT_SPELLCAST_SUCCEEDED` for ability-triggered emotes
- Uses Blizzard's internal FileDataIDs, so no copied audio files are bundled
- Per-character action-emote configuration through `RoarForeverDB`

## Ability emotes

Open the configuration with:

`/rf`

The Blizzard-style configuration window provides:

- master enable/disable toggle for ability emotes
- ability dropdown populated from the character's known active abilities
- one saved configuration instance per selected ability
- checklist of the client's available emote tokens
- random selection from the checked emotes
- chance slider from 0-100%
- cooldown slider from 0-120 seconds
- remove button for configured abilities

When an assigned ability succeeds, Roar Forever checks its chance and cooldown, chooses one enabled emote at random, and executes it with `DoEmote`. If the selected emote is `/roar`, the roar-sound system then plays that character's original racial roar voice.

## Original roar FileDataIDs

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

`540457` (`VO_PCGnomeFemaleRoar01.ogg`) has been directly confirmed to play in the WoW Forever beta client. The remaining mappings come from the current `wowdev/wow-listfile` sound list.

## Commands

- `/rf` or `/rf config` opens the configuration window.
- `/rf test` plays the mapped roar for your current character.
- `/rf status` prints roar and ability-emote status.
- `/rf id 540457` directly tests a FileDataID.

## Installation

Place the `RoarForever` folder in the Forever client's `Interface/AddOns/` directory. It must contain:

- `RoarForever.toc`
- `RoarForever.lua`
- `RoarForever_ActionEmotes.lua`
