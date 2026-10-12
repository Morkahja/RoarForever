# Roar Forever — Changelog

Release notes for the standalone player voice-emote sound addon.

## 0.5.6-beta — 2026-10-12

- Fixed "Interface action failed because of an AddOn" on `/train` and faction cries. Restored the working `C_ChatInfo.SendChatMessage` path and send the custom `/e` line immediately on the slash/keybind call stack instead of after `C_Timer.After`, which Forever treats as an automated chat action.
- Kept the 0.5.5 faction-cry fix: `/forthehorde` and `/forthealliance` still announce from the slash command even when `DoEmote` is a no-op.

## 0.5.5-beta — 2026-10-12

- Fixed faction-cry chat announcements so `/forthehorde` and `/forthealliance` send their distinctive `/e` line from the slash command even when `DoEmote` does nothing. A follow-up 0.5.6 fix restored the safe chat API path after `/train` broke.

## 0.5.4-beta — 2026-10-12

- Restores the missing `/forthehorde` and `/forthealliance` faction cries using the original race/sex-specific voice assets contained in the World of Warcraft Forever client.
- Added `/forthealliance` (alias `/fta`) for Alliance characters, with the same announcement, multiplayer, group/raid, options, and `/rf test` support as `/forthehorde` / `/fth`.
- Verified Alliance voices for Human, Dwarf, Gnome, and Night Elf (male and female). No Skyborne faction-cry line was found for either faction.
- Shared faction-emote handling for both cries. Forever still has no native emote tokens, so the cheer animation may be missing until Blizzard wires them; the addon keeps calling `DoEmote("FORTHEHORDE")` and `DoEmote("FORTHEALLIANCE")` for forward compatibility.

## 0.5.3-beta — 2026-10-12

- Added `/forthehorde` (alias `/fth`) for Horde characters. Forever still has the race/sex “For the Horde!” voice files, but does not wire the emote, so Roar Forever plays them and sends a distinctive chat line other Roar Forever users can hear.
- Verified Orc, Tauren, Troll, and Undead male/female FileDataIDs in the Forever client. No Skyborne for-horde line was found yet.
- Forever’s EmotesText has no `FORTHEHORDE` token yet, so the native cheer animation may not play until Blizzard wires it. The addon keeps calling `DoEmote("FORTHEHORDE")` so a future client build can pick it up automatically.

## 0.5.2-beta — 2026-10-11

- Skyborne already have a client `/roar`. Roar Forever no longer double-plays roar for yourself or for Skyborne group members. Other races still get the addon roar there. Nearby non-grouped Skyborne roars are still restored.

## 0.5.1-beta — 2026-10-07

- Stopped group-member `/train` from playing twice. Like the other non-roar voices, train is left to the game in a party or raid.

## 0.5.0-beta — 2026-10-07

- Added a movable Warcraft-style options window, opened with `/rf` or `/rf config`.
- Added individual switches for all 20 supported emote categories. Aliases share one switch.
- Added speaker buttons that preview a random mapped sound across all races and genders, including the full joke and flirt pools. Previews work with automatic playback disabled and never send chat messages.
- Added a separate switch for the `/train` chat announcement. Turning it off leaves the native train emote available.
- Bundled English, German, French, Spanish, and Russian emote detection and menu labels; English GB and Spanish MX use their corresponding language packs.
- Replaced broad keyword detection with full client-message templates from Forever build 1.60.1.70009. Custom emote chat is accepted only for the exact train announcement.
- Fixed player identity checks so a different GUID cannot be mistaken for the local player or a group member just because names match.
- Kept the existing congratulations `ding` exclusion unchanged.
- Settings use the existing account-wide `RoarForeverDB`; prior on/off settings are preserved and new switches default to on.

Validation: Lua 5.1 checks cover 593 localized template cases and options, previews, train announcements, saved-option loading, and identity regressions. Actual translated-client behavior and UI appearance still require in-game validation.

## 0.4.7 — 2026-09-30

- Fixed a Lua error that could fire when a party or raid member used a voiced emote such as `/oom`.

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
