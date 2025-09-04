# Create_BND_Matrix_Structure.ps1
# Master Daddy Agency - BND Matrix Infrastructure Deployment
# Performance-Optimized Directory Creation with Error Handling

[CmdletBinding()]
param(
    [string]$RootPath = "C:\BND_Matrix",
    [switch]$Force,
    [switch]$Verbose
)

# Performance: Pre-compile regex patterns
$ValidPathRegex = [regex]'^[A-Za-z]:\\[^<>:"|?*]*$'

# Error Handling: Triad-Fix Implementation
function Test-PathSafety {
    param([string]$Path)
    
    # Syntax Check
    if (-not $ValidPathRegex.IsMatch($Path)) {
        throw "Invalid path syntax: $Path"
    }
    
    # Logic Check  
    if ($Path.Length -gt 260) {
        throw "Path exceeds Windows limit: $Path"
    }
    
    # Edge Check
    if ($Path -match '[\[\]]') {
        Write-Warning "Path contains brackets - potential PowerShell parsing issues"
    }
    
    return $true
}

# Performance: Parallel directory creation
function New-BNDStructure {
    param([string]$BasePath)
    
    $Directories = @(
        "01_INTEL",
        "02_ASSETS", 
        "03_OPERATIONS",
        "04_COMMS",
        "05_TECH",
        "06_ANALYSIS",
        "07_ARCHIVE",
        "08_TRAINING",
        "09_RESOURCES",
        "10_BACKUP",
        "11_BLACKBOX"
    )
    
    # Performance: Batch creation with error collection
    $ErrorLog = @()
    
    $Directories | ForEach-Object -Parallel {
        $DirPath = Join-Path $using:BasePath $_
        try {
            New-Item -ItemType Directory -Path $DirPath -Force:$using:Force -ErrorAction Stop
            Write-Host "✓ Created: $_" -ForegroundColor Green
        }
        catch {
            $using:ErrorLog += "Failed to create $_`: $($_.Exception.Message)"
        }
    } -ThrottleLimit 5
    
    if ($ErrorLog.Count -gt 0) {
        throw "Directory creation errors: $($ErrorLog -join '; ')"
    }
}

# Main Execution Block
try {
    Write-Host "🎯 Master Daddy Agency - BND Matrix Deployment" -ForegroundColor Cyan
    
    # Pre-flight checks
    Test-PathSafety -Path $RootPath
    
    if (Test-Path $RootPath -and -not $Force) {
        $Response = Read-Host "BND_Matrix exists. Overwrite? (y/N)"
        if ($Response -ne 'y') { 
            Write-Host "❌ Operation cancelled" -ForegroundColor Red
            exit 1 
        }
    }
    
    # Performance: Single operation for root creation
    New-Item -ItemType Directory -Path $RootPath -Force | Out-Null
    
    # Deploy structure
    New-BNDStructure -BasePath $RootPath
    
    # Verification
    $CreatedDirs = Get-ChildItem $RootPath -Directory | Measure-Object
    Write-Host "✅ BND Matrix deployed: $($CreatedDirs.Count) directories" -ForegroundColor Green
    
    # Performance metrics
    $EndTime = Get-Date
    Write-Host "⚡ Execution time: $((Get-Date) - $StartTime)" -ForegroundColor Yellow
    
}
catch {
    Write-Error "🚨 BND Matrix deployment failed: $($_.Exception.Message)"
    exit 1
}

# Risk Prevention: Validate final structure
$ExpectedCount = 11
$ActualCount = (Get-ChildItem $RootPath -Directory -ErrorAction SilentlyContinue | Measure-Object).Count

if ($ActualCount -ne $ExpectedCount) {
    Write-Warning "⚠️ Structure incomplete: Expected $ExpectedCount, got $ActualCount directories"
}