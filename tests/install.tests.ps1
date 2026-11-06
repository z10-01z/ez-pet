#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repository 'install.ps1'
$testRoot = Join-Path $repository ('.validation\' + [guid]::NewGuid().ToString('N'))
$petsRoot = Join-Path $testRoot 'custom path [test]\pets'
New-Item -ItemType Directory -Path (Join-Path $petsRoot 'other-pet') -Force | Out-Null
Set-Content -LiteralPath (Join-Path $petsRoot 'other-pet\sentinel.txt') -Value 'preserve me'
$first = & $installer -Destination ($petsRoot + '\')
if ($first.PetId -ne 'custom:ez-girl' -or $first.BackupPath) { throw 'Fresh install returned unexpected metadata.' }
if ((Get-FileHash -LiteralPath (Join-Path $first.InstallPath 'spritesheet.png')).Hash -ne $first.SpriteSha256) { throw 'Fresh install hash mismatch.' }
$manifest = Get-Content -LiteralPath (Join-Path $first.InstallPath 'pet.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.spriteVersionNumber -ne 2 -or $manifest.spritesheetPath -ne 'spritesheet.png') { throw 'Manifest mismatch.' }

Set-Content -LiteralPath (Join-Path $first.InstallPath 'old-version-marker.txt') -Value 'old installation'
$second = & $installer -Destination $petsRoot
if ($second.InstallPath -ne $first.InstallPath) { throw 'Reinstall changed identity.' }
if (-not (Test-Path -LiteralPath (Join-Path $second.BackupPath 'old-version-marker.txt'))) { throw 'Previous installation was not backed up.' }
if ($second.BackupPath.StartsWith($petsRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Backup was written inside pets.' }
$installed = @(Get-ChildItem -LiteralPath $petsRoot -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'pet.json') })
if ($installed.Count -ne 1 -or $installed[0].Name -ne 'ez-girl') { throw 'Repeat install created a duplicate pet.' }
if ((Get-Content -LiteralPath (Join-Path $petsRoot 'other-pet\sentinel.txt') -Raw).Trim() -ne 'preserve me') { throw 'Another pet was changed.' }

$env:CODEX_HOME = Join-Path $testRoot 'environment home'
$environmentInstall = & $installer
if ($environmentInstall.InstallPath -ne (Join-Path $env:CODEX_HOME 'pets\ez-girl')) { throw 'CODEX_HOME was not honored.' }
$env:CODEX_HOME = ''
$env:USERPROFILE = Join-Path $testRoot 'profile home'
$defaultInstall = & $installer
if ($defaultInstall.InstallPath -ne (Join-Path $env:USERPROFILE '.codex\pets\ez-girl')) { throw 'USERPROFILE fallback failed.' }

$packageCopy = Join-Path $testRoot 'corrupt package'
New-Item -ItemType Directory -Path (Join-Path $packageCopy 'ez-girl') -Force | Out-Null
Copy-Item -LiteralPath $installer -Destination (Join-Path $packageCopy 'install.ps1')
Copy-Item -LiteralPath (Join-Path $repository 'ez-girl\pet.json') -Destination (Join-Path $packageCopy 'ez-girl\pet.json')
Set-Content -LiteralPath (Join-Path $packageCopy 'ez-girl\spritesheet.png') -Value 'corrupt sprite'
$rejected = $false
try { & (Join-Path $packageCopy 'install.ps1') -Destination (Join-Path $testRoot 'rejected\pets') | Out-Null }
catch { $rejected = $_.Exception.Message -like '*checksum*' }
if (-not $rejected -or (Test-Path -LiteralPath (Join-Path $testRoot 'rejected\pets'))) { throw 'Corrupt package wrote destination files.' }

[pscustomobject]@{
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    FreshInstall = 'pass'
    ReinstallAndExternalBackup = 'pass'
    OtherPetPreserved = 'pass'
    CustomPathAndTrailingSeparator = 'pass'
    CodexHome = 'pass'
    UserProfileFallback = 'pass'
    CorruptPackageRejectedBeforeWrite = 'pass'
    TestRoot = $testRoot
} | ConvertTo-Json
