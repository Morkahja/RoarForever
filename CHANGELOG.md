# Roar Forever — Changelog

Release notes for the standalone player voice-emote sound addon.

## 0.4.6 — 2026-09-26

- `/train` now sends "blows a train whistle. Choo choo!" so other people using Roar Forever can hear it, including in a party or raid.
- Restored the `/whistle` sound for nearby players.

## 0.4.5 — 2026-09-26

- Restored nearby-player voices for `/cry`, `/congrats` / `/congratulate`, and `/followme`.

## 0.4.4 — 2026-09-26

- Restored nearby-player voices for `/oom`, `/sigh`, and `/charge`.

## 0.4.3 — 2026-09-26

- Restored nearby-player voices for `/healme`, `/rasp`, and `/flirt`.
- In a party or raid, only `/roar` is restored. The other voices are left to the game.
- `/rf off` turns Roar Forever off. `/rf on` turns it back on.

## 0.4.2 — 2026-09-25

- Restored nearby-player voices for `/flee` and `/retreat`. Both use the flee voice.
- Restored nearby-player voices for `/welcome`.
- Restored nearby-player voices for `/yes` and `/no`.

## 0.4.1 — 2026-09-25

- Added Skyborne voices for roar, cheer, laugh, and joke.
- `/joke` and `/silly` now pick a random line from that character's full set of joke lines.
- `/moo` stays Tauren-only.

## 0.4.0 — 2026-09-25

- Expanded Roar Forever beyond `/roar` to other missing player voice emotes.
- Added nearby-player voices for `/cheer`, `/laugh` / `/lol`, `/joke` / `/silly`, and Tauren `/moo`.
- Your own normal voiced emotes are left to the client. `/roar` still plays for you as well.
- `/rf test` can try roar, cheer, laugh, joke, and moo. `/rf status` lists the voices mapped for your character.
- `/train` is not restored. Forever does not announce another player's train emote.

## 0.3.0 — 2026-09-20

- Published Roar Forever as a standalone sound-only addon.
- Retained racial voice playback for detected `/roar` emotes and the short duplicate-playback cooldown.
- Included sound testing and status commands: `/rf test`, `/rf status`, and `/rf id <FileDataID>`.
- Reduced the install package to two runtime files: `RoarForever.toc` and `RoarForever.lua`.
- Removed ability-triggered emotes, their configuration window, saved profiles, and recovery setup from the public addon.
- Requires no saved settings, directory links, or account-specific configuration.

Earlier combined-addon development is outside the scope of this standalone changelog and remains available in repository history.
