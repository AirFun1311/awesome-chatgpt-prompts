param(
    [string]$RootPath = 'C:\\BND_Matrix',
    [string]$IconsSource = "$PSScriptRoot/../assets/icons",
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

function Safe-CopyFile {
    param([string]$Source,[string]$Destination)
    if ($WhatIf) { Write-Host "[WhatIf] Copy $Source -> $Destination"; return }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

Write-SessionLog -Task 'Assign_Agency_Icons' -Hypotheses 'Icons missing in folders' -Tests 'Test-Path source/target' -Result 'Started'

if (-not (Test-Path -LiteralPath $IconsSource)) {
    Write-SessionLog -Task 'Assign_Agency_Icons' -Result 'Skipped' -Changes 'Icons source missing' -Next 'Provide icons'
    return
}

$targets = Get-ChildItem -LiteralPath $RootPath -Directory -ErrorAction SilentlyContinue
foreach ($dir in $targets) {
    $icon = Join-Path $IconsSource ("{0}.png" -f $dir.Name)
    if (Test-Path -LiteralPath $icon) {
        Safe-CopyFile -Source $icon -Destination (Join-Path $dir.FullName 'icon.png')
    }
}

Write-SessionLog -Task 'Assign_Agency_Icons' -Result 'Completed' -Changes 'Icons assigned where available'

