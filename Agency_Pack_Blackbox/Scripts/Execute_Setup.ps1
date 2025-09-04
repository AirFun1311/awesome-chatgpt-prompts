#Requires -Version 5.1
<#
.SYNOPSIS
    Master execution script für BND_Matrix Setup
.DESCRIPTION
    Führt alle Scripts in optimaler Reihenfolge aus
.AUTHOR
    Master Daddy Agency
#>

[CmdletBinding()]
param(
    [string]$BasePath = "C:\BND_Matrix",
    [switch]$SkipIcons,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Performance Metrics
$Global:Metrics = @{
    StartTime = Get-Date
    Steps = @()
}

function Add-Metric {
    param($Step, $Duration)
    $Global:Metrics.Steps += [PSCustomObject]@{
        Step = $Step
        Duration = $Duration
        Timestamp = Get-Date
    }
}

try {
    Write-Host "`n=== BND_Matrix Setup ===" -ForegroundColor Cyan
    Write-Host "Target: $BasePath" -ForegroundColor Gray
    
    # Step 1: Create Structure
    Write-Host "`n[1/3] Creating Matrix Structure..." -ForegroundColor Yellow
    $StepStart = Get-Date
    
    $StructureResult = & "$PSScriptRoot\Create_BND_Matrix_Structure.ps1" -BasePath $BasePath -Force:$Force
    Add-Metric -Step "Structure" -Duration ((Get-Date) - $StepStart).TotalSeconds
    
    Write-Host "✓ Folders Created: $($StructureResult.FoldersCreated)" -ForegroundColor Green
    Write-Host "✓ Folders Existed: $($StructureResult.FoldersExisted)" -ForegroundColor Green
    
    # Step 2: Update with BLACKBOX
    Write-Host "`n[2/3] Integrating BLACKBOX Component..." -ForegroundColor Yellow
    $StepStart = Get-Date
    
    $BlackboxResult = & "$PSScriptRoot\Update_BND_Matrix.ps1" -BasePath $BasePath -Component "11_BLACKBOX" -Force:$Force
    Add-Metric -Step "BLACKBOX" -Duration ((Get-Date) - $StepStart).TotalSeconds
    
    Write-Host "✓ BLACKBOX Folders: $($BlackboxResult.FoldersCreated)" -ForegroundColor Green
    Write-Host "✓ Security Applied: $($BlackboxResult.Secured)" -ForegroundColor Green
    
    # Step 3: Assign Icons (optional)
    if (-not $SkipIcons) {
        Write-Host "`n[3/3] Assigning Agency Icons..." -ForegroundColor Yellow
        $StepStart = Get-Date
        
        # Check if icons exist
        $IconPath = "$PSScriptRoot\..\Icons"
        if (Test-Path $IconPath) {
            $IconResult = & "$PSScriptRoot\Assign_Agency_Icons.ps1" -BasePath $BasePath
            Add-Metric -Step "Icons" -Duration ((Get-Date) - $StepStart).TotalSeconds
            Write-Host "✓ Icons Assigned: $($IconResult.ProcessedFolders)" -ForegroundColor Green
        } else {
            Write-Warning "Icons folder not found. Skipping icon assignment."
            Add-Metric -Step "Icons" -Duration 0
        }
    }
    
    # Final Report
    $TotalDuration = ((Get-Date) - $Global:Metrics.StartTime).TotalSeconds
    
    Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
    Write-Host "Total Duration: $([Math]::Round($TotalDuration, 2))s" -ForegroundColor Cyan
    
    Write-Host "`nPerformance Breakdown:" -ForegroundColor Yellow
    $Global:Metrics.Steps | ForEach-Object {
        Write-Host "  $($_.Step): $([Math]::Round($_.Duration, 2))s" -ForegroundColor Gray
    }
    
    # Verify critical folders
    Write-Host "`nVerifying BLACKBOX..." -ForegroundColor Yellow
    $BlackboxPath = Join-Path $BasePath "11_BLACKBOX"
    $RequiredFolders = @("SNIPPETS", "TOOLS", "DOCS", "LOGS")
    
    $VerificationPassed = $true
    foreach ($folder in $RequiredFolders) {
        $FolderPath = Join-Path $BlackboxPath $folder
        if (Test-Path $FolderPath) {
            Write-Host "  ✓ $folder" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $folder" -ForegroundColor Red
            $VerificationPassed = $false
        }
    }
    
    if ($VerificationPassed) {
        Write-Host "`n✓ All systems operational" -ForegroundColor Green
    } else {
        Write-Warning "Some folders missing. Run with -Force to recreate."
    }
    
} catch {
    Write-Error "Setup failed: $_"
    Write-Host "`nPartial setup may exist at: $BasePath" -ForegroundColor Yellow
    exit 1
}