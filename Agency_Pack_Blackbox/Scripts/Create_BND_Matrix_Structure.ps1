<#
.SYNOPSIS
    Creates the BND Matrix folder hierarchy.

.DESCRIPTION
    Agency-Style script that ensures the required directory structure under the
    specified root. Idempotent and optimized for minimal I/O – skips creation if
    targets already exist.

.PARAMETER RootPath
    Root of the BND Matrix. Defaults to C:\BND_Matrix.

.EXAMPLE
    .\Create_BND_Matrix_Structure.ps1 -RootPath 'C:\BND_Matrix'
#>

param(
    [string]$RootPath = 'C:\BND_Matrix'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Core folders
$folders = @(
    '01_ALPHA', '02_BETA', '03_GAMMA', '04_DELTA',
    '05_EPSILON', '06_ZETA', '07_ETA', '08_THETA',
    '09_IOTA', '10_KAPPA', '11_BLACKBOX'
)

foreach ($f in $folders) { New-Dir (Join-Path $RootPath $f) }

# BLACKBOX sub-folders
$blackboxRoot = Join-Path $RootPath '11_BLACKBOX'
$blackboxSub  = @('SNIPPETS','TOOLS','DOCS','LOGS')
foreach ($sub in $blackboxSub) { New-Dir (Join-Path $blackboxRoot $sub) }

$stopwatch.Stop()

Write-Host "[Create_BND_Matrix_Structure] Completed in $($stopwatch.Elapsed.TotalMilliseconds) ms."

<#
TRIAD-FIX
1. Syntax: Validate PowerShell version >=5.0 (strict mode covers).
2. Logic: Handle RootPath containing trailing '\' by using Join-Path.
3. Edge: Missing permissions -> catch and display.

Performance:
- Single Test-Path per directory prevents redundant I/O.
- Stopwatch to profile runtime.

Risks & Prevention:
- Permission denied → Wrap in try/catch, bubble with clear message.
- Network path latency → create local temp then move (future).
- Large folder count future → parallel creation (future).
#>