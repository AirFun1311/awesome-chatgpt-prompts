param(
    [string]$RootPath = 'C:\\BND_Matrix',
    [switch]$WhatIf,
    [string]$LogPath = "$PSScriptRoot/../SESSION_LOG.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-SessionLog {
    param(
        [string]$Task,
        [string]$Hypotheses = '-',
        [string]$Tests = '-',
        [string]$Result = '-',
        [string]$Changes = '-',
        [string]$Next = '-'
    )
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ssK')
    $entry = "$timestamp | $Task | $Hypotheses | $Tests | $Result | $Changes | $Next"
    $dir = Split-Path -Parent $LogPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Add-Content -Path $LogPath -Value $entry
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] Create directory: $Path"; return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

Write-SessionLog -Task 'Create_BND_Matrix_Structure' -Hypotheses 'Base structure missing' -Tests 'Test-Path checks' -Result 'Started'

$structure = @(
    '00_ADMIN','01_CLIENTS','02_PROJECTS','03_DELIVERY','04_ASSETS','05_ARCHIVE',
    '06_LEGAL','07_FINANCE','08_HR','09_RnD','10_OPERATIONS','11_BLACKBOX'
)

Ensure-Directory -Path $RootPath
foreach ($folder in $structure) {
    Ensure-Directory -Path (Join-Path $RootPath $folder)
}

Write-SessionLog -Task 'Create_BND_Matrix_Structure' -Result 'Completed' -Changes ("Created: " + ($structure -join ','))

