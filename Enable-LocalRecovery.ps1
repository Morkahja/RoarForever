param(
    [Parameter(Mandatory = $true)][string]$SavedVariablesFile,
    [string]$AddonDirectory = 'C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\RoarForever'
)

# This installs an optional companion addon. It does not modify saved data,
# run a background process, or upload any account/character information.
$ErrorActionPreference = 'Stop'
$saved = Get-Item -LiteralPath $SavedVariablesFile
if ($saved.PSIsContainer -or $saved.Name -ne 'RoarForever.lua' -or $saved.Directory.Name -ne 'SavedVariables') {
    throw 'Choose the account-wide SavedVariables\RoarForever.lua file.'
}
if ($saved.Directory.Parent.Parent.Name -ne 'Account') {
    throw 'Choose account-wide storage, not character-specific storage.'
}
if ((Get-Content -LiteralPath $saved.FullName -Raw) -notmatch 'RoarForeverStorage\s*=\s*\{') {
    throw 'The saved file has no settings table. Restore a known-good backup with WoW closed first.'
}
$addon = Get-Item -LiteralPath $AddonDirectory
if ($addon.Name -ne 'RoarForever' -or -not $addon.PSIsContainer) {
    throw 'AddonDirectory must be the installed RoarForever folder.'
}
$recovery = Join-Path $addon.Parent.FullName 'RoarForever_Recovery'
$link = Join-Path $recovery 'SavedVariables'
if (Test-Path -LiteralPath $link) {
    $existing = Get-Item -LiteralPath $link -Force
    if ($existing.LinkType -ne 'Junction' -or
        [IO.Path]::GetFullPath([string]$existing.Target).TrimEnd('\') -ne $saved.Directory.FullName.TrimEnd('\')) {
        throw 'Existing recovery link has a different target. No files changed.'
    }
}
New-Item -ItemType Directory -Path $recovery -Force | Out-Null
if (-not (Test-Path -LiteralPath $link)) {
    New-Item -ItemType Junction -Path $link -Target $saved.Directory.FullName | Out-Null
}
$toc = @'
## Interface: 16001
## Title: Roar Forever - Local Recovery
## Notes: Loads this installation's RoarForever settings around the Forever beta SavedVariables bug.
## Version: 0.2.3

SavedVariables\RoarForever.lua
Capture.lua
'@
$capture = @'
-- Keep a reference before the main addon's normal SavedVariables load pass.
RoarForever_RecoveryStorage = RoarForeverStorage
RoarForever_RecoveryReady = type(RoarForever_RecoveryStorage) == "table"
'@
Set-Content -LiteralPath (Join-Path $recovery 'RoarForever_Recovery.toc') -Value $toc -Encoding ascii
Set-Content -LiteralPath (Join-Path $recovery 'Capture.lua') -Value $capture -Encoding ascii
$linked = Join-Path $link 'RoarForever.lua'
if ((Get-FileHash -LiteralPath $linked).Hash -ne (Get-FileHash -LiteralPath $saved.FullName).Hash) {
    throw 'Recovery file verification failed.'
}
Write-Output 'Recovery installed and file verified. Restart WoW, enable Roar Forever - Local Recovery, and run /rf status.'
