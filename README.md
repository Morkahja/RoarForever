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
- `/healme` — restores the race/sex-specific call for healing for other players.
- `/rasp` — restores the raspberry voice for other players. `/rude` uses the same line.
- `/flirt` — restores a random race/sex-specific flirt line for other players.
- `/oom` — restores the low-mana voice for other players.
- `/sigh` — restores the race/sex-specific sigh for other players.
- `/charge` — restores the race/sex-specific charge voice for other players.
- `/cry` — restores the race/sex-specific cry for other players.
- `/congrats` / `/congratulate` — restores a random congratulations line for other players.
- `/followme` — restores the follow-me voice for other players.
- `/whistle` — restores the whistle for other players.
- `/train` — Roar Forever takes over `/train`, plays the normal choo-choo, and also sends "blows a train whistle. Choo choo!" Other people using Roar Forever hear the train voice from that line, including group members.

Roar Forever does not replay your own normal voiced emotes, because the client already plays those. `/roar` is the exception. In a party or raid, the client already plays the other voices for group members, so Roar Forever restores only `/roar` there. Nearby players who are not in your group still get the full set.

Someone who is not using Roar Forever can still `/train` without sending a line, so there is nothing for the addon to hear.

## Installation

1. Extract `RoarForever.zip` into `World of Warcraft\_classic_beta_\Interface\AddOns`.
2. Check that the `RoarForever` folder contains `RoarForever.toc` and `RoarForever.lua`.
3. Restart WoW and enable **Roar Forever** in the addon list.

Playback is local: another player does not need Roar Forever installed for you to hear a supported detected emote from them. The only saved setting is whether you have turned the addon off.

## Commands

| Command | Purpose |
|---|---|
| `/rf` | Show the available commands. |
| `/rf on` | Turn Roar Forever on. |
| `/rf off` | Turn Roar Forever off. |
| `/rf test` | Play your character's mapped roar sound. |
| `/rf test <emote>` | Test a mapped emote for your character, including `train` and `whistle`. |
| `/rf status` | Show whether the addon is on, your character voice, and the mapped emotes. |
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
