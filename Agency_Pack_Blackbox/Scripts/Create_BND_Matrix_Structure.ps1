#Requires -Version 5.1
<#
.SYNOPSIS
    Erstellt BND_Matrix Ordnerstruktur - Agency Style
.DESCRIPTION
    Performance-optimiert, parallel, minimal
.AUTHOR
    Master Daddy Agency
#>

[CmdletBinding()]
param(
    [string]$BasePath = "C:\BND_Matrix",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$StartTime = Get-Date

# Struktur-Definition
$Folders = @(
    "01_OSINT\TOOLS",
    "01_OSINT\REPORTS",
    "01_OSINT\CACHE",
    "02_SIGINT\INTERCEPTS",
    "02_SIGINT\ANALYSIS",
    "02_SIGINT\RAW",
    "03_HUMINT\CONTACTS",
    "03_HUMINT\REPORTS",
    "03_HUMINT\DEBRIEFS",
    "04_TECHINT\EXPLOITS",
    "04_TECHINT\MALWARE",
    "04_TECHINT\FORENSICS",
    "05_CYBER\ATTACKS",
    "05_CYBER\DEFENSE",
    "05_CYBER\MONITORING",
    "06_COMINT\INTERCEPTS",
    "06_COMINT\DECRYPTS",
    "06_COMINT\ARCHIVES",
    "07_MASINT\SENSORS",
    "07_MASINT\ANALYSIS",
    "07_MASINT\DATA",
    "08_GEOINT\IMAGERY",
    "08_GEOINT\MAPS",
    "08_GEOINT\TARGETS",
    "09_FININT\TRANSACTIONS",
    "09_FININT\NETWORKS",
    "09_FININT\ANALYSIS",
    "10_SOCINT\PROFILES",
    "10_SOCINT\NETWORKS",
    "10_SOCINT\INFLUENCE",
    "11_BLACKBOX\SNIPPETS",
    "11_BLACKBOX\TOOLS",
    "11_BLACKBOX\DOCS",
    "11_BLACKBOX\LOGS",
    "_SHARED\TEMPLATES",
    "_SHARED\SCRIPTS",
    "_SHARED\CONFIG"
)

try {
    # Base erstellen
    if (-not (Test-Path $BasePath)) {
        New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
    }

    # Parallel-Erstellung
    $Jobs = $Folders | ForEach-Object -Parallel {
        $FullPath = Join-Path $using:BasePath $_
        if (-not (Test-Path $FullPath)) {
            New-Item -ItemType Directory -Path $FullPath -Force | Out-Null
            [PSCustomObject]@{
                Path = $FullPath
                Status = 'Created'
            }
        } else {
            [PSCustomObject]@{
                Path = $FullPath
                Status = 'Exists'
            }
        }
    } -ThrottleLimit 10

    # Report
    $Duration = (Get-Date) - $StartTime
    Write-Host "`nBND_Matrix Structure Created" -ForegroundColor Green
    Write-Host "Duration: $($Duration.TotalSeconds)s" -ForegroundColor Cyan
    Write-Host "Folders: $($Folders.Count)" -ForegroundColor Cyan

    # Return stats
    @{
        BasePath = $BasePath
        FoldersCreated = ($Jobs | Where-Object {$_.Status -eq 'Created'}).Count
        FoldersExisted = ($Jobs | Where-Object {$_.Status -eq 'Exists'}).Count
        Duration = $Duration.TotalSeconds
    }

} catch {
    Write-Error "Matrix creation failed: $_"
    exit 1
}