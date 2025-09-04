<#!
.SYNOPSIS
Updates the BND Matrix by ensuring the 11_BLACKBOX node and its subfolders exist.

.DESCRIPTION
Ensures C:\BND_Matrix\11_BLACKBOX exists and contains SNIPPETS, TOOLS, DOCS, LOGS.
Uses Create_BND_Matrix_Structure.ps1 when available for root creation.
Parallelizes subfolder creation on PowerShell 7+ when -UseParallel is specified.

.PARAMETER RootPath
Target root path (default: C:\BND_Matrix).

.PARAMETER UseParallel
Enable parallel subfolder creation on PowerShell 7+.

.OUTPUTS
System.String[] of created or confirmed directories.
#>

param(
    [Parameter()] [string] $RootPath = 'C:\BND_Matrix',
    [Parameter()] [switch] $UseParallel
)

$ErrorActionPreference = 'Stop'

function New-DirectoryIfMissing {
    param([Parameter(Mandatory)] [string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

$expandedRoot = [Environment]::ExpandEnvironmentVariables($RootPath)

# Try to use the Create script if present for root creation
$createScript = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'Create_BND_Matrix_Structure.ps1'
if (Test-Path -LiteralPath $createScript -PathType Leaf) {
    & $createScript -RootPath $expandedRoot | Out-Null
} else {
    New-DirectoryIfMissing -Path $expandedRoot
}

$blackboxRoot = Join-Path -Path $expandedRoot -ChildPath '11_BLACKBOX'
New-DirectoryIfMissing -Path $blackboxRoot

$subFolders = @('SNIPPETS','TOOLS','DOCS','LOGS') | ForEach-Object { Join-Path -Path $blackboxRoot -ChildPath $_ }

$createdOrConfirmed = New-Object System.Collections.Generic.List[string]
foreach ($p in @($blackboxRoot) + $subFolders) {
    if (-not (Test-Path -LiteralPath $p -PathType Container)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
    [void]$createdOrConfirmed.Add($p)
}

Write-Output $createdOrConfirmed.ToArray()

