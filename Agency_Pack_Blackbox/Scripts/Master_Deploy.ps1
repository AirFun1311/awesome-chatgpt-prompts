# Master_Deploy.ps1
# Master Daddy Agency - Complete Deployment Orchestrator
# Performance-Optimized Sequential Execution

[CmdletBinding()]
param(
    [string]$MatrixPath = "C:\BND_Matrix",
    [switch]$Force,
    [switch]$SkipIcons,
    [switch]$PerformanceMode
)

# Performance: Script execution order (dependency-optimized)
$DeploymentSequence = @(
    @{
        Script = "Create_BND_Matrix_Structure.ps1"
        Description = "Matrix structure deployment"
        Critical = $true
        Args = @("-RootPath", $MatrixPath)
    },
    @{
        Script = "Update_BND_Matrix.ps1" 
        Description = "BLACKBOX integration"
        Critical = $true
        Args = @("-MatrixPath", $MatrixPath)
    },
    @{
        Script = "Assign_Agency_Icons.ps1"
        Description = "Visual identity assignment"
        Critical = $false
        Args = @("-MatrixPath", $MatrixPath)
    }
)

# Add Force parameter if specified
if ($Force) {
    $DeploymentSequence[0].Args += @("-Force")
    $DeploymentSequence[1].Args += @("-ForceUpdate")
}

# Performance monitoring
$StartTime = Get-Date
$ExecutionLog = @()

try {
    Write-Host "🎯 Master Daddy Agency - Full Deployment Protocol" -ForegroundColor Cyan
    Write-Host "📍 Target: $MatrixPath" -ForegroundColor Yellow
    
    foreach ($Step in $DeploymentSequence) {
        # Skip icons if requested
        if ($SkipIcons -and $Step.Script -eq "Assign_Agency_Icons.ps1") {
            Write-Host "⏭️ Skipping: $($Step.Description)" -ForegroundColor Yellow
            continue
        }
        
        $StepStart = Get-Date
        Write-Host "`n🚀 Executing: $($Step.Description)" -ForegroundColor Magenta
        
        $ScriptPath = Join-Path $PSScriptRoot $Step.Script
        
        try {
            # Performance: Direct script execution with splatting
            $StepArgs = $Step.Args
            if ($PerformanceMode) {
                $StepArgs += @("-Verbose")
            }
            
            & $ScriptPath @StepArgs
            
            $StepDuration = (Get-Date) - $StepStart
            $ExecutionLog += "✅ $($Step.Description): $($StepDuration.TotalSeconds)s"
            
        } catch {
            $StepDuration = (Get-Date) - $StepStart
            $ErrorMsg = "❌ $($Step.Description): FAILED after $($StepDuration.TotalSeconds)s - $($_.Exception.Message)"
            $ExecutionLog += $ErrorMsg
            
            if ($Step.Critical) {
                throw "Critical deployment step failed: $($Step.Description)"
            } else {
                Write-Warning $ErrorMsg
            }
        }
    }
    
    # Final validation & performance report
    $TotalDuration = (Get-Date) - $StartTime
    
    Write-Host "`n📊 DEPLOYMENT COMPLETE" -ForegroundColor Green
    Write-Host "⚡ Total execution time: $($TotalDuration.TotalSeconds)s" -ForegroundColor Yellow
    Write-Host "`n📋 Execution Log:" -ForegroundColor Cyan
    $ExecutionLog | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    
    # Risk assessment
    $MatrixDirs = Get-ChildItem $MatrixPath -Directory -ErrorAction SilentlyContinue
    if ($MatrixDirs.Count -ge 11) {
        Write-Host "`n✅ Matrix integrity verified: $($MatrixDirs.Count) directories" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ Matrix incomplete: Expected 11+, found $($MatrixDirs.Count) directories"
    }
    
} catch {
    Write-Error "🚨 Master deployment failed: $($_.Exception.Message)"
    Write-Host "🔧 Troubleshooting: Check individual script logs" -ForegroundColor Cyan
    exit 1
}

Write-Host "`n🎯 Master Daddy Agency - Deployment Status: OPERATIONAL" -ForegroundColor Cyan