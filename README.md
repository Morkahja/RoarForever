# Roar Forever

See [CHANGELOG.md](CHANGELOG.md) for release notes.

Roar Forever restores player-character `/roar` voice sounds in World of Warcraft: Forever and adds an optional ability-triggered emote system.

## Forever compatibility

- Forever Interface number: `16001`
- Uses `CHAT_MSG_TEXT_EMOTE` for roar sound restoration
- Uses `UNIT_SPELLCAST_SUCCEEDED` for ability-triggered emotes
- Uses Blizzard's internal FileDataIDs, so no copied audio files are bundled
- Per-character action-emote configuration with persistent saved settings

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

When an assigned ability succeeds, Roar Forever checks its chance and cooldown, chooses one enabled emote at random, and executes it with `DoEmote`. If the selected emote is `/roar`, the roar-sound system then plays that character's racial roar voice.

## Roar FileDataIDs

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
- `RoarForever_Recovery.xml`
- `RoarForever_Storage.lua`
- `RoarForever.lua`
- `RoarForever_ActionEmotes.lua`

Copy all five files together. Preserve an existing configured `RoarForever_Recovery.xml` when updating; the installer does this automatically.

On Windows, run `./Install-Local.ps1` from a complete checkout to install into the default Forever beta addon directory. Use `-Destination 'D:\Games\World of Warcraft\_classic_beta_\Interface\AddOns\RoarForever'` for another installation.

After installation, type `/reload`, then `/rf status` and `/rf`.

Settings are saved per character in `RoarForeverStorage.profiles`, keyed by character GUID.

## Forever beta settings recovery (Windows)

Current Forever beta builds have reports of saved settings being written to disk but not restored on login/restart. Changing between account-wide and per-character variables does not resolve that client defect. See the [reproduction on Blizzard's forum](https://eu.forums.blizzard.com/en/wow/t/addon-savedvariables-never-load-on-160169893/629799).

Version 0.2.4 includes recovery inside Roar Forever; no companion addon is needed. Back up your account-wide `WTF/Account/<account>/SavedVariables/RoarForever.lua`, install the addon, then run:

```powershell
./Enable-LocalRecovery.ps1 -SavedVariablesFile 'C:\Program Files (x86)\World of Warcraft\_classic_beta_\WTF\Account\<account>\SavedVariables\RoarForever.lua'
```

Use `-AddonDirectory` for a non-default addon location. Select the account you actually play; rerun setup only for the same target, or use a separate installation for another account. Do not publish the installed `SavedVariables` junction: it points to private local saved data.

The script creates a directory junction inside RoarForever pointing to the existing SavedVariables directory. An XML loader reads only `RoarForever.lua`, then the storage module captures the table before the client's normal saved-variable pass. RoarForever uses this table if the normal client restore fails. This reads the live saved file on each load, so future edits and removals are not replaced with a frozen snapshot. The script does not overwrite settings or run a background service. Updates through the installer preserve this setup. WoW must still write the settings on a normal logout/reload; this does not protect unsaved changes from crashes.

Fully restart WoW after first setup. Only **Roar Forever** needs to be enabled. `/rf status` should say `built-in recovery loaded`. Change a setting, log out and in, then fully exit/restart and check it again. If the recovery message is absent, check the XML loader and junction still exist. Client acceptance of this loading path must be verified in-game. When upgrading from 0.2.3, disable the old **Roar Forever - Local Recovery** companion after configuring built-in recovery.

To stop using the workaround once the client is fixed, replace the installed `RoarForever_Recovery.xml` with the empty repository version. Do not recursively delete a `SavedVariables` junction or files through it: they are your actual saved settings.

Run `lua tests/persistence.lua` with Lua 5.1 from the checkout to reproduce the failed restore and test the recovery logic across isolated simulated sessions. These tests do not replace a real client restart test.
