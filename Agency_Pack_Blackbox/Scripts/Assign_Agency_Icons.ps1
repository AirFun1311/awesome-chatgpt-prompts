# Assign_Agency_Icons.ps1
# Master Daddy Agency - Icon Assignment System
# High-Performance Visual Identity Deployment

[CmdletBinding()]
param(
    [string]$MatrixPath = "C:\BND_Matrix",
    [hashtable]$CustomIcons = @{},
    [switch]$SkipValidation
)

# Performance: Pre-compiled icon mappings
$AgencyIcons = @{
    "01_INTEL"      = "🔍"  # Intelligence gathering
    "02_ASSETS"     = "💎"  # High-value assets  
    "03_OPERATIONS" = "⚡"  # Active operations
    "04_COMMS"      = "📡"  # Communications
    "05_TECH"       = "🔧"  # Technical resources
    "06_ANALYSIS"   = "📊"  # Data analysis
    "07_ARCHIVE"    = "🗃️"   # Archived materials
    "08_TRAINING"   = "🎯"  # Training protocols
    "09_RESOURCES"  = "📚"  # Reference materials
    "10_BACKUP"     = "🛡️"   # Security backups
    "11_BLACKBOX"   = "⬛"  # Classified operations
}

# Merge custom icons (override defaults)
$FinalIcons = $AgencyIcons.Clone()
foreach ($Key in $CustomIcons.Keys) {
    $FinalIcons[$Key] = $CustomIcons[$Key]
}

# Triad-Fix: Error handling framework
function Set-DirectoryIcon {
    param(
        [string]$DirectoryPath,
        [string]$Icon,
        [string]$DirectoryName
    )
    
    try {
        # Syntax Check
        if (-not (Test-Path $DirectoryPath)) {
            throw "Directory not found: $DirectoryPath"
        }
        
        # Logic Check - Windows-specific icon assignment
        if ($IsWindows -or $env:OS -eq "Windows_NT") {
            $DesktopIni = Join-Path $DirectoryPath "desktop.ini"
            $IniContent = @"
[.ShellClassInfo]
IconResource=$Icon
InfoTip=Master Daddy Agency - $DirectoryName
"@
            Set-Content -Path $DesktopIni -Value $IniContent -Encoding UTF8
            Set-ItemProperty -Path $DesktopIni -Name Attributes -Value "Hidden,System"
            Set-ItemProperty -Path $DirectoryPath -Name Attributes -Value "ReadOnly"
        }
        
        # Cross-platform: Create marker file with icon
        $MarkerFile = Join-Path $DirectoryPath ".agency_icon"
        Set-Content -Path $MarkerFile -Value $Icon -Encoding UTF8
        
        # Edge Check - Verify icon assignment
        if (-not (Test-Path $MarkerFile)) {
            throw "Icon marker creation failed for: $DirectoryName"
        }
        
        return $true
        
    } catch {
        Write-Error "Icon assignment failed for $DirectoryName`: $($_.Exception.Message)"
        return $false
    }
}

# Performance: Parallel icon assignment
function Deploy-AgencyIcons {
    param([string]$BasePath)
    
    $SuccessCount = 0
    $FailureLog = @()
    
    $FinalIcons.GetEnumerator() | ForEach-Object -Parallel {
        $DirPath = Join-Path $using:BasePath $_.Key
        $Icon = $_.Value
        $DirName = $_.Key
        
        $Result = & $using:SetDirectoryIcon -DirectoryPath $DirPath -Icon $Icon -DirectoryName $DirName
        
        if ($Result) {
            $using:SuccessCount++
            Write-Host "✓ $DirName assigned icon: $Icon" -ForegroundColor Green
        } else {
            $using:FailureLog += $DirName
        }
    } -ThrottleLimit 8
    
    return @{
        Success = $SuccessCount
        Failures = $FailureLog
    }
}

# Main execution
try {
    Write-Host "🎯 Master Daddy Agency - Icon Deployment Initiated" -ForegroundColor Cyan
    $StartTime = Get-Date
    
    # Pre-flight validation
    if (-not $SkipValidation) {
        if (-not (Test-Path $MatrixPath)) {
            throw "BND_Matrix not found at: $MatrixPath"
        }
    }
    
    # Deploy icons
    $Results = Deploy-AgencyIcons -BasePath $MatrixPath
    
    # Performance report
    $Duration = (Get-Date) - $StartTime
    Write-Host "✅ Icon deployment complete" -ForegroundColor Green
    Write-Host "📊 Success: $($Results.Success) | Failures: $($Results.Failures.Count)" -ForegroundColor Yellow
    Write-Host "⚡ Execution time: $($Duration.TotalSeconds)s" -ForegroundColor Yellow
    
    # Risk mitigation report
    if ($Results.Failures.Count -gt 0) {
        Write-Warning "⚠️ Failed assignments: $($Results.Failures -join ', ')"
        Write-Host "🔧 Recommended: Re-run with -Force parameter" -ForegroundColor Cyan
    }
    
} catch {
    Write-Error "🚨 Icon deployment failed: $($_.Exception.Message)"
    exit 1
}