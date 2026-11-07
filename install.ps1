#Requires -Version 5.1
<#
.SYNOPSIS
Installs or updates the EZ companion for the current Windows user.
.PARAMETER Destination
The pets root directory, not the individual ez-girl directory.
#>
[CmdletBinding()]
param(
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'ez-girl'
$spriteHash = 'ee1d890fa7175ece69283ce4e25ac53d6dc8e03e307e5abec2453683407e682d'
$manifest = Get-Content -LiteralPath (Join-Path $source 'pet.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.spriteVersionNumber -ne 2 -or $manifest.spritesheetPath -ne 'spritesheet.png' -or [string]::IsNullOrWhiteSpace($manifest.displayName)) {
    throw 'The package pet.json does not match the EZ v2 package.'
}
if ((Get-FileHash -LiteralPath (Join-Path $source 'spritesheet.png') -Algorithm SHA256).Hash -ne $spriteHash) {
    throw 'The sprite checksum does not match this release. Download the package again.'
}

if ([string]::IsNullOrWhiteSpace($Destination)) {
    $codexDirectory = if ([string]::IsNullOrWhiteSpace($env:CODEX_HOME)) { Join-Path $env:USERPROFILE '.codex' } else { $env:CODEX_HOME }
    $Destination = Join-Path $codexDirectory 'pets'
}
$petsRoot = [System.IO.Path]::GetFullPath($Destination).TrimEnd('\', '/')
if ($petsRoot -eq [System.IO.Path]::GetPathRoot($petsRoot).TrimEnd('\', '/')) {
    throw 'Destination must be a pets directory below the drive root.'
}
$target = Join-Path $petsRoot 'ez-girl'
if ($target.TrimEnd('\') -eq $source.TrimEnd('\')) {
    throw 'Choose an installation directory outside the downloaded package.'
}

$backup = $null
if (Test-Path -LiteralPath $target) {
    # The desktop picker scans direct children of pets. Backups must live outside it.
    $backup = Join-Path (Split-Path -Parent $petsRoot) ('pet-backups\ez-girl\' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
    Copy-Item -LiteralPath $target -Destination $backup -Recurse
}

New-Item -ItemType Directory -Path $target -Force | Out-Null
@('spritesheet.png', 'pet.json') | ForEach-Object {
    Copy-Item -LiteralPath (Join-Path $source $_) -Destination (Join-Path $target $_) -Force
}
if ((Get-FileHash -LiteralPath (Join-Path $target 'spritesheet.png') -Algorithm SHA256).Hash -ne $spriteHash) {
    throw 'Installed sprite verification failed. The previous installation is available at the backup path.'
}

Write-Host 'EZ companion installed. Open Settings > Pets, refresh the list, and select EZ.'
if ($backup) { Write-Host ('Previous installation backed up to: ' + $backup) }
[pscustomobject]@{
    PetId = 'custom:ez-girl'
    InstallPath = $target
    BackupPath = $backup
    SpriteSha256 = $spriteHash
}
