<#!
.SYNOPSIS
Creates or updates the base C:\BND_Matrix directory structure.

.DESCRIPTION
- Ensures the root path exists (defaults to C:\BND_Matrix).
- Optionally creates additional top-level folders via -TopLevelFolders.
- Supports parallel creation on PowerShell 7+ with -UseParallel.

.PARAMETER RootPath
Target root path for the BND Matrix (default: C:\BND_Matrix).

.PARAMETER TopLevelFolders
Optional list of top-level folders to create under the root path.

.PARAMETER UseParallel
Use parallel creation when PowerShell 7+ is available for better performance.

.OUTPUTS
System.String. Returns the expanded root path.

.NOTES
Performance: batches I/O and optionally parallelizes directory creation.
Reliability: idempotent; safe to run multiple times.
#>

param(
    [Parameter()] [string] $RootPath = 'C:\BND_Matrix',
    [Parameter()] [string[]] $TopLevelFolders = @(),
    [Parameter()] [switch] $UseParallel
)

$ErrorActionPreference = 'Stop'

function New-DirectoryIfMissing {
    param([Parameter(Mandatory)] [string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# Expand environment variables if present and normalize path
$expandedRoot = [Environment]::ExpandEnvironmentVariables($RootPath)

New-DirectoryIfMissing -Path $expandedRoot

$foldersToCreate = @()
foreach ($folderName in $TopLevelFolders) {
    if ([string]::IsNullOrWhiteSpace($folderName)) { continue }
    $foldersToCreate += (Join-Path -Path $expandedRoot -ChildPath $folderName.Trim())
}

if ($foldersToCreate.Count -gt 0) {
    $isPwsh7 = ($PSVersionTable.PSVersion.Major -ge 7)
    if ($UseParallel.IsPresent -and $isPwsh7) {
        $throttle = [Math]::Max([Environment]::ProcessorCount, 2)
        $foldersToCreate | ForEach-Object -Parallel {
            param($p)
            if (-not (Test-Path -LiteralPath $p -PathType Container)) {
                New-Item -ItemType Directory -Path $p -Force | Out-Null
            }
        } -ThrottleLimit $throttle
    } else {
        foreach ($p in $foldersToCreate) {
            if (-not (Test-Path -LiteralPath $p -PathType Container)) {
                New-Item -ItemType Directory -Path $p -Force | Out-Null
            }
        }
    }
}

# Emit the resolved root path for chaining/tests
Write-Output $expandedRoot

