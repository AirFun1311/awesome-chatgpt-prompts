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

Write-SessionLog -Task 'Update_BND_Matrix' -Hypotheses 'Add 11_BLACKBOX and subfolders' -Tests 'Test-Path checks' -Result 'Started'

$blackbox = Join-Path $RootPath '11_BLACKBOX'
Ensure-Directory -Path $blackbox

$subs = 'SNIPPETS','TOOLS','DOCS','LOGS'
foreach ($s in $subs) { Ensure-Directory -Path (Join-Path $blackbox $s) }

Write-SessionLog -Task 'Update_BND_Matrix' -Result 'Completed' -Changes ("Ensured 11_BLACKBOX subfolders: " + ($subs -join ','))

