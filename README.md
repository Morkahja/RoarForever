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
- `RoarForever_Storage.lua`
- `RoarForever.lua`
- `RoarForever_ActionEmotes.lua`

Copy all four files together. A missing `RoarForever_Storage.lua` causes a load error at line 8 of the `.toc` and prevents the character profile from being bound to persistent storage.

On Windows, run `./Install-Local.ps1` from a complete checkout to install into the default Forever beta addon directory. The script checks every file listed in the `.toc` before copying and verifies installed file hashes. It backs up existing files to a timestamped folder under your temporary directory before replacing them. Use `-Destination 'D:\Games\World of Warcraft\_classic_beta_\Interface\AddOns\RoarForever'` for another installation.

For development, pull the repository before editing, compare any local addon changes, then run the installer after each tested change and commit/push the same files to GitHub. The installer does not pull, push, or run in the background.

After installation, type `/reload`, then `/rf status` and `/rf`. Configure an ability, reload again, and confirm the settings remain. File/hash checks do not replace this in-game check.

Settings are saved in account-wide `RoarForeverStorage.profiles`, keyed by character GUID. `RoarForeverDB` references the current character's profile; older name or name-realm profiles are migrated at login.
