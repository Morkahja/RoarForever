# Roar Forever

**Version 0.3.0** — a lightweight roar sound fix for World of Warcraft: Forever.

Roar Forever plays the matching character voice when it detects a `/roar` emote. It uses audio already included in the game client, so there are no sound downloads or configuration steps.

## Installation

1. Extract `RoarForever.zip` into `World of Warcraft\_classic_beta_\Interface\AddOns`.
2. Check that the `RoarForever` folder contains `RoarForever.toc` and `RoarForever.lua`.
3. Restart WoW and enable **Roar Forever** in the addon list.
4. Use `/roar` normally.

The addon has no saved settings and needs no account-specific setup. Playback is local: other players need their own sound fix to hear the restored audio on their computers.

## Commands

| Command | Purpose |
|---|---|
| `/rf` | Show the available commands. |
| `/rf test` | Play your character's mapped roar sound. |
| `/rf status` | Show the detected character voice and sound ID. |
| `/rf id <FileDataID>` | Test a specific sound ID. |

`/roarforever` can also be used in place of `/rf`.

## Compatibility

- Targets the Forever beta, Interface `16001`.
- Includes male and female voice mappings for Dwarf, Gnome, Human, Night Elf, Orc, Tauren, Troll, and Undead characters.
- Current emote detection recognizes English roar messages.
- Gnome female playback has been confirmed in-game. The other mapped voices still need in-game confirmation.

## Release notes

See [CHANGELOG.md](CHANGELOG.md).
