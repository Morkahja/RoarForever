# Changelog

## 0.3.0

- The public addon now focuses exclusively on restoring `/roar` voice sounds.
- Removed the ability-emote engine, configuration UI, saved profiles, and beta recovery setup from the public package.
- Installation now needs only `RoarForever.toc` and `RoarForever.lua`, with no account-specific setup or saved settings.
- Kept `/rf test`, `/rf status`, and `/rf id <FileDataID>` sound commands.
- Ability-emote development is deferred; existing private local settings can be maintained separately.

## 0.2.4

- Integrated settings recovery into Roar Forever. The separate **Roar Forever - Local Recovery** addon is no longer needed after migrating the local setup.
- Preserved the recovery workaround for the Forever beta bug that writes settings but fails to restore them after login or restart.
- Added a built-in loader that reads the current saved settings, preserving later edits, removals, and enable/disable changes.
- Updated `/rf status` to report **built-in recovery loaded** when active.
- Updated the installer to preserve the local recovery configuration during future updates.
- Kept character profiles and existing settings compatible with version 0.2.3.

The beta workaround still requires a one-time local setup using `Enable-LocalRecovery.ps1`. Existing configured installations retain their setup when updated with `Install-Local.ps1`.

## 0.2.3

- Added a local recovery workaround for the Forever beta SavedVariables loading bug, initially through a separate companion addon.
- Rebound character settings when accessed to avoid continuing to use an unbound session-only table.
- Added storage status information to `/rf status`.
- Added regression tests covering failed client restores, separate sessions, settings changes, removals, enable/disable state, character isolation, and older profile migration.
