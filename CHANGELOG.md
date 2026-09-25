# Roar Forever — Changelog

Release notes for the standalone player voice-emote sound addon.

## 0.4.1 — 2026-09-25

- Added Skyborne voice-emote support. Forever reports the race file as `Skyborne` for both High Order and Windshaper, and both factions share one male and one female voice set.
- Added Skyborne laugh support.
- Added Skyborne joke/silly support with every variant in the race's joke sound kit.
- Added Skyborne cheer and roar, which also have verified voice files. Skyborne has no dedicated moo files, so `/moo` stays Tauren-only.
- Expanded `/joke` and `/silly` for the eight classic races so playback randomly uses every line in that race and sex's joke sound kit.

## 0.4.0 — 2026-09-25

- Expanded Roar Forever beyond `/roar` into a general missing player voice-emote sound fix.
- Added remote-player restoration for `/cheer`, `/laugh` / `/lol`, `/joke` / `/silly`, and Tauren `/moo`.
- Added race/sex-specific FileDataID mappings for all eight classic races for cheer, laugh, and joke sounds.
- Added Tauren female and male moo mappings.
- Normal voiced emotes are restored only for other players to avoid doubling sounds the client already plays for the local character; `/roar` remains the exception.
- Added `/rf test <emote>` for testing `roar`, `cheer`, `laugh`, `joke`, and `moo`.
- Updated `/rf status` to report which emotes are mapped for the current character.
- Kept `/train` unsupported because Forever does not expose another player's `/train` through `CHAT_MSG_TEXT_EMOTE`.

## 0.3.0 — 2026-09-20

- Published Roar Forever as a standalone sound-only addon.
- Retained racial voice playback for detected `/roar` emotes and the short duplicate-playback cooldown.
- Included sound testing and status commands: `/rf test`, `/rf status`, and `/rf id <FileDataID>`.
- Reduced the install package to two runtime files: `RoarForever.toc` and `RoarForever.lua`.
- Removed ability-triggered emotes, their configuration window, saved profiles, and recovery setup from the public addon.
- Requires no saved settings, directory links, or account-specific configuration.

Earlier combined-addon development is outside the scope of this standalone changelog and remains available in repository history.
