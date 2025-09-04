#Requires -Version 5.1
<#
.SYNOPSIS
    Weist Agency Icons zu BND_Matrix Ordnern zu
.DESCRIPTION
    Performance-optimiert mit Win32 API
.AUTHOR
    Master Daddy Agency
#>

[CmdletBinding()]
param(
    [string]$BasePath = "C:\BND_Matrix",
    [string]$IconPath = "$PSScriptRoot\..\Icons"
)

$ErrorActionPreference = 'Stop'

# Icon-Mapping
$IconMap = @{
    "01_OSINT"    = "osint.ico"
    "02_SIGINT"   = "sigint.ico"
    "03_HUMINT"   = "humint.ico"
    "04_TECHINT"  = "techint.ico"
    "05_CYBER"    = "cyber.ico"
    "06_COMINT"   = "comint.ico"
    "07_MASINT"   = "masint.ico"
    "08_GEOINT"   = "geoint.ico"
    "09_FININT"   = "finint.ico"
    "10_SOCINT"   = "socint.ico"
    "11_BLACKBOX" = "blackbox.ico"
    "_SHARED"     = "shared.ico"
}

# Desktop.ini Template
$DesktopIniTemplate = @"
[.ShellClassInfo]
IconResource={0},0
[ViewState]
Mode=
Vid=
FolderType=Generic
"@

try {
    $StartTime = Get-Date
    $ProcessedCount = 0

    # Parallel Icon-Zuweisung
    $IconMap.GetEnumerator() | ForEach-Object -Parallel {
        $FolderName = $_.Key
        $IconFile = $_.Value
        $FolderPath = Join-Path $using:BasePath $FolderName
        
        if (Test-Path $FolderPath) {
            $IniPath = Join-Path $FolderPath "desktop.ini"
            $IconFullPath = Join-Path $using:IconPath $IconFile
            
            # Erstelle desktop.ini
            $using:DesktopIniTemplate -f $IconFullPath | Set-Content -Path $IniPath -Force
            
            # Setze Attribute
            $Folder = Get-Item $FolderPath -Force
            $Folder.Attributes = $Folder.Attributes -bor [System.IO.FileAttributes]::System
            
            $Ini = Get-Item $IniPath -Force
            $Ini.Attributes = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
            
            [PSCustomObject]@{
                Folder = $FolderName
                Status = 'IconAssigned'
            }
        }
    } -ThrottleLimit 10

    $Duration = (Get-Date) - $StartTime
    
    # Report
    Write-Host "`nAgency Icons Assigned" -ForegroundColor Green
    Write-Host "Duration: $($Duration.TotalSeconds)s" -ForegroundColor Cyan
    Write-Host "Folders: $($IconMap.Count)" -ForegroundColor Cyan
    
    @{
        ProcessedFolders = $IconMap.Count
        Duration = $Duration.TotalSeconds
    }

} catch {
    Write-Error "Icon assignment failed: $_"
    exit 1
}