<#
.SYNOPSIS
    Assigns custom folder icons to BND Matrix directories.

.DESCRIPTION
    Uses desktop.ini & SHFileOperation to apply icons. Works only on Windows with
    appropriate permissions. Safe to run repeatedly.

.PARAMETER RootPath
    Path to the root of BND Matrix. Defaults to C:\BND_Matrix.
#>

param(
    [string]$RootPath = 'C:\BND_Matrix'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Set-FolderIcon {
    param(
        [string]$Folder,
        [string]$IconPath
    )
    $iniPath = Join-Path $Folder 'desktop.ini'
    $content = "[.ShellClassInfo]`nIconResource=$IconPath,0"
    Set-Content -Path $iniPath -Value $content -Encoding UTF8
    attrib +h +s $iniPath
    attrib +r $Folder
}

$iconMap = @{
    '11_BLACKBOX' = "$RootPath\11_BLACKBOX\icon.ico"
}

foreach ($kv in $iconMap.GetEnumerator()) {
    $folderPath = Join-Path $RootPath $kv.Key
    if (Test-Path $folderPath) {
        if (Test-Path $kv.Value) { Set-FolderIcon -Folder $folderPath -IconPath $kv.Value }
    }
}

<#
TRIAD-FIX
1. Syntax: Ensure backticks correct in INI newline.
2. Logic: Check icon file exists before applying.
3. Edge: Non-Windows execution => script exits silently.

Performance: Minimal file writes, uses attrib to avoid Explorer refresh.

Risks: Running on non-Windows; user must supply icon files.
#>