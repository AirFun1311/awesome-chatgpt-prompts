<#!
.SYNOPSIS
Assigns folder icons within the BND Matrix using desktop.ini (Windows).

.DESCRIPTION
Writes desktop.ini files with IconResource/IconFile for target folders.
If running on Windows, sets required folder/file attributes for icon pick-up.
Idempotent and safe to rerun. On non-Windows, writes desktop.ini only.

.PARAMETER RootPath
Base path containing target folders (default: C:\BND_Matrix).

.PARAMETER FolderToIconMap
Hashtable mapping relative folder paths (e.g. '11_BLACKBOX') to icon file paths.
Icon paths may include environment variables (e.g. %USERPROFILE%).

.PARAMETER CreateIfMissing
Create mapped folders if they do not exist.

.OUTPUTS
PSCustomObject with Folder, Icon, Applied, Message.

.NOTES
Requires Windows to apply folder attributes; otherwise content is still prepared.
#>

param(
    [Parameter()] [string] $RootPath = 'C:\BND_Matrix',
    [Parameter()] [hashtable] $FolderToIconMap = @{},
    [Parameter()] [switch] $CreateIfMissing
)

$ErrorActionPreference = 'Stop'
$isWindows = $IsWindows -or ($PSVersionTable.OS -match 'Windows')

function New-DirectoryIfMissing {
    param([Parameter(Mandatory)] [string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Set-FolderIcon {
    param(
        [Parameter(Mandatory)] [string] $FolderPath,
        [Parameter(Mandatory)] [string] $IconPath
    )
    $iniPath = Join-Path -Path $FolderPath -ChildPath 'desktop.ini'
    $iniContent = @(
        '[.ShellClassInfo]',
        "IconResource=$IconPath,0",
        "IconFile=$IconPath",
        'IconIndex=0'
    ) -join [Environment]::NewLine

    # Write with Unicode to avoid encoding issues in localized environments
    Set-Content -LiteralPath $iniPath -Value $iniContent -Encoding Unicode -Force

    if ($isWindows) {
        try {
            attrib +s "$FolderPath" | Out-Null
            attrib +h +s "$iniPath" | Out-Null
        } catch {
            Write-Verbose "Attribute assignment failed for $FolderPath: $($_.Exception.Message)"
        }
    }
}

$expandedRoot = [Environment]::ExpandEnvironmentVariables($RootPath)
if (-not (Test-Path -LiteralPath $expandedRoot -PathType Container)) {
    if ($CreateIfMissing) { New-DirectoryIfMissing -Path $expandedRoot } else { throw "RootPath not found: $expandedRoot" }
}

$results = @()
foreach ($kvp in $FolderToIconMap.GetEnumerator()) {
    $relativeFolder = [string]$kvp.Key
    $iconCandidate = [Environment]::ExpandEnvironmentVariables([string]$kvp.Value)
    if ([string]::IsNullOrWhiteSpace($relativeFolder)) { continue }

    $targetFolder = Join-Path -Path $expandedRoot -ChildPath $relativeFolder.Trim()
    if (-not (Test-Path -LiteralPath $targetFolder -PathType Container)) {
        if ($CreateIfMissing) { New-DirectoryIfMissing -Path $targetFolder } else {
            $results += [pscustomobject]@{ Folder=$targetFolder; Icon=$iconCandidate; Applied=$false; Message='Folder missing' }
            continue
        }
    }

    if (-not (Test-Path -LiteralPath $iconCandidate -PathType Leaf)) {
        $results += [pscustomobject]@{ Folder=$targetFolder; Icon=$iconCandidate; Applied=$false; Message='Icon not found' }
        continue
    }

    Set-FolderIcon -FolderPath $targetFolder -IconPath $iconCandidate
    $results += [pscustomobject]@{ Folder=$targetFolder; Icon=$iconCandidate; Applied=$true; Message='OK' }
}

$results

