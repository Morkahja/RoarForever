# Roar Forever

Restores player-character `/roar` voice sounds in World of Warcraft: Forever.

## Installation

Extract `RoarForever.zip` into the Forever client's `Interface/AddOns` directory. The `RoarForever` folder contains just:

- `RoarForever.toc`
- `RoarForever.lua`

Restart WoW and enable **Roar Forever**. Use `/roar` normally.

No settings, account-specific paths, folder links, or recovery setup are required. The addon uses sounds already included in the game client.

## Commands

- `/rf test` plays your character's mapped roar sound.
- `/rf status` shows the detected character voice and sound ID.
- `/rf id <FileDataID>` tests a specific sound ID.

## Compatibility

- Forever Interface: `16001`.
- Listens to `CHAT_MSG_TEXT_EMOTE` and plays matching racial roar audio locally.
- Current roar-message detection recognizes English emote text.
- Gnome female sound has been confirmed in the beta; the other racial mappings still need in-game confirmation.

## Scope

Version 0.3.0 is sound-only. Ability-triggered emotes and their settings recovery are excluded from the public addon while beta persistence remains unreliable. They may return in a later release.

See [CHANGELOG.md](CHANGELOG.md) for release notes.
