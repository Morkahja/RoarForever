param(
    [string]$Destination = 'C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\RoarForever'
)

$ErrorActionPreference = 'Stop'
$entries = @(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RoarForever.toc') |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') })
$files = @('RoarForever.toc', 'README.md', 'CHANGELOG.md') + $entries
foreach ($file in $files) {
    if ($file -notmatch '^[A-Za-z0-9_.-]+$') { throw "Unexpected addon filename: $file" }
    if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot $file) -PathType Leaf)) {
        throw "Incomplete checkout: missing $file. No files were installed."
    }
}

$target = [IO.Path]::GetFullPath($Destination)
if ($target.TrimEnd('\') -eq $PSScriptRoot.TrimEnd('\')) {
    throw 'The installation destination must differ from the checkout.'
}
$backup = Join-Path ([IO.Path]::GetTempPath()) ('RoarForever-backup-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
New-Item -ItemType Directory -Path $target -Force | Out-Null
foreach ($file in $files) {
    $installed = Join-Path $target $file
    if (Test-Path -LiteralPath $installed -PathType Leaf) {
        Copy-Item -LiteralPath $installed -Destination (Join-Path $backup $file)
    }
}
Write-Output "Backup: $backup"
foreach ($file in $files) {
    $source = Join-Path $PSScriptRoot $file
    $installed = Join-Path $target $file
    # This file contains the installation-specific recovery loader. Never
    # replace configured recovery with the empty distributed placeholder.
    if ($file -eq 'RoarForever_Recovery.xml' -and (Test-Path -LiteralPath $installed)) {
        Write-Output "Preserved: $file"
        continue
    }
    Copy-Item -LiteralPath $source -Destination $installed -Force
    if ((Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $installed).Hash) {
        throw "Installed file verification failed: $file. Backup: $backup"
    }
    Write-Output "Verified: $file"
}
Write-Output 'Installation verified. In WoW, run /reload, /rf status, then /rf.'
