param(
    [Parameter(Mandatory = $true)][string]$SavedVariablesFile,
    [string]$AddonDirectory = 'C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\RoarForever'
)

# This configures recovery inside RoarForever. It does not modify saved data,
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
$link = Join-Path $addon.FullName 'SavedVariables'
if (Test-Path -LiteralPath $link) {
    $existing = Get-Item -LiteralPath $link -Force
    if ($existing.LinkType -ne 'Junction' -or
        [IO.Path]::GetFullPath([string]$existing.Target).TrimEnd('\') -ne $saved.Directory.FullName.TrimEnd('\')) {
        throw 'Existing recovery link has a different target. No files changed.'
    }
}
if (-not (Test-Path -LiteralPath $link)) {
    New-Item -ItemType Junction -Path $link -Target $saved.Directory.FullName | Out-Null
}
$loader = @'
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <Script file="SavedVariables\RoarForever.lua"/>
</Ui>
'@
$linked = Join-Path $link 'RoarForever.lua'
if ((Get-FileHash -LiteralPath $linked).Hash -ne (Get-FileHash -LiteralPath $saved.FullName).Hash) {
    throw 'Recovery file verification failed.'
}
Set-Content -LiteralPath (Join-Path $addon.FullName 'RoarForever_Recovery.xml') -Value $loader -Encoding ascii
Write-Output 'Built-in recovery installed and file verified. Only Roar Forever needs to be enabled. Restart WoW and run /rf status.'
