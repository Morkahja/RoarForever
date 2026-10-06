# Roar Forever

A lightweight player voice-emote sound fix for World of Warcraft: Forever.

Roar Forever restores character voice sounds that Forever does not reliably play when nearby players use voiced emotes. It uses audio already included in the game client, so there are no bundled sound files. It works with default settings; `/rf` opens its options.

## Options and previews

Open `/rf` or `/rf config` for a movable Warcraft-style menu. Toggle individual emote categories, enable or disable the addon, and choose whether `/train` sends its extra chat message. Aliases such as `/flee` and `/retreat` share one switch.

Each speaker button plays one randomly selected sound for that emote from all mapped races and genders. It does not use only your character's voice. Previews work even if that emote or the addon is switched off, never send chat, and stop the previous preview when you choose another.

These switches control voices added by Roar Forever. They do not silence voices that WoW itself plays. In particular, turning off the train announcement does not disable the native `/train` animation or voice.

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
2. Check that the `RoarForever` folder contains `RoarForever.toc`, `Locales.lua`, `RoarForever.lua`, and `Options.lua`. Install all four files together.
3. Restart WoW and enable **Roar Forever** in the addon list.

Playback is local: another player does not need Roar Forever installed for you to hear a supported detected emote from them (except the announced train emote). Your on/off state, individual emote choices, and train-announcement choice are saved through the normal account-wide `RoarForeverDB`. No folder links or account-specific setup are used.

## Commands

| Command | Purpose |
|---|---|
| `/rf` or `/rf config` | Open or close the options window. |
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
- Bundled languages: English, German, French, Spanish, and Russian. The menu and standard emote detection follow your client language. `enGB` uses English and `esMX` uses the Spanish pack; unsupported client languages fall back to English labels/templates.
- Translated full-message templates come from [Forever 1.60.1.70009 EmotesTextData](https://wago.tools/db2/EmotesTextData?build=1.60.1.70009). No separate CurseForge language downloads are needed. French grammatical prefixes and Russian declined names are accounted for; newer client wording may need updates.
- The custom train announcement remains the same English line in every locale so different-language addon users can recognize it.
- Sound mappings use Blizzard FileDataIDs from the current wowdev community listfile.
- Gnome female `/roar` playback has been confirmed in-game. The new restored emotes should be treated as beta until they have been checked in the Forever client.

## Release notes

See [CHANGELOG.md](CHANGELOG.md).

## Development checks

Run `python tests/test_addon.py` with the `lupa` package installed (Lua 5.1 runtime). Tests are excluded from CurseForge packages. Automated checks use simulated WoW APIs; verify window layout, actual audio, and a logout/login settings cycle in the game before treating a beta release as fully validated.
