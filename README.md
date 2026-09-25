# Roar Forever

A lightweight player voice-emote sound fix for World of Warcraft: Forever.

Roar Forever restores character voice sounds that Forever does not reliably play when nearby players use voiced emotes. It uses audio already included in the game client, so there are no bundled sound files and no configuration steps.

## Restored emotes

- `/roar` — restored for your own character and other players.
- `/cheer` — restores the race/sex-specific cheer for other players.
- `/laugh` / `/lol` — restores the race/sex-specific laugh for other players.
- `/joke` / `/silly` — restores a random race/sex-specific joke voice line for other players, chosen from that voice's full joke set.
- `/moo` — restores the dedicated Tauren male/female moo for other players. Other races have no dedicated player-character moo voice file.
- `/flee` / `/retreat` — restores the flee voice for other players. Retreat uses the same voice as flee.
- `/welcome` — restores the race/sex-specific welcome for other players.
- `/yes` / `/no` — restores the race/sex-specific yes and no voices for other players.

Roar Forever deliberately does not replay your own normal voiced emotes because the client already plays those locally. `/roar` is the exception.

`/train` is not restored for other players because Forever does not emit `CHAT_MSG_TEXT_EMOTE` when another player uses it, so the addon has no reliable event to detect.

## Installation

1. Extract `RoarForever.zip` into `World of Warcraft\_classic_beta_\Interface\AddOns`.
2. Check that the `RoarForever` folder contains `RoarForever.toc` and `RoarForever.lua`.
3. Restart WoW and enable **Roar Forever** in the addon list.

The addon has no saved settings and needs no account-specific setup. Playback is local: another player does not need Roar Forever installed for you to hear a supported detected emote from them.

## Commands

| Command | Purpose |
|---|---|
| `/rf` | Show the available commands. |
| `/rf test` | Play your character's mapped roar sound. |
| `/rf test <emote>` | Test `roar`, `cheer`, `laugh`, `joke`, `moo`, `flee`, `retreat`, `welcome`, `yes`, or `no` for your character. |
| `/rf status` | Show the detected character voice and mapped emotes. |
| `/rf id <FileDataID>` | Test a specific sound ID. |

`/roarforever` can also be used in place of `/rf`.

## Compatibility

- Targets the Forever beta, Interface `16001`.
- Includes male and female voice mappings for Dwarf, Gnome, Human, Night Elf, Orc, Tauren, Troll, Undead, and Skyborne characters.
- Current emote detection recognizes English emote messages.
- Sound mappings use Blizzard FileDataIDs from the current wowdev community listfile.
- Gnome female `/roar` playback has been confirmed in-game. The new restored emotes should be treated as beta until they have been checked in the Forever client.

## Release notes

See [CHANGELOG.md](CHANGELOG.md).
