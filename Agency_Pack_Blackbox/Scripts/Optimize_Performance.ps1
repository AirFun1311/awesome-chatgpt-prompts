#Requires -Version 5.1
<#
.SYNOPSIS
    Performance-Optimierung für BND_Matrix Operations
.DESCRIPTION
    CPU/RAM/IO/Network Optimierungen
.AUTHOR
    Master Daddy Agency
#>

[CmdletBinding()]
param()

# Global Performance Settings
$Global:PerformanceConfig = @{
    # CPU Optimierung
    MaxParallelThreads = [Environment]::ProcessorCount * 2
    ThreadPriority = [System.Threading.ThreadPriority]::AboveNormal
    
    # RAM Optimierung  
    MaxMemoryMB = 512
    GCMode = 'Workstation'
    
    # I/O Optimierung
    BufferSize = 65536  # 64KB
    AsyncIO = $true
    
    # Network (falls benötigt)
    ConnectionLimit = 100
    Timeout = 30
}

# Optimierte Folder Creation
function New-OptimizedFolder {
    param(
        [string[]]$Paths,
        [int]$ThrottleLimit = $Global:PerformanceConfig.MaxParallelThreads
    )
    
    $RunspacePool = [runspacefactory]::CreateRunspacePool(1, $ThrottleLimit)
    $RunspacePool.Open()
    
    $Jobs = @()
    
    foreach ($Path in $Paths) {
        $PowerShell = [powershell]::Create()
        $PowerShell.RunspacePool = $RunspacePool
        
        [void]$PowerShell.AddScript({
            param($Path)
            try {
                if (-not (Test-Path $Path)) {
                    [System.IO.Directory]::CreateDirectory($Path) | Out-Null
                    return @{Path = $Path; Status = 'Created'}
                }
                return @{Path = $Path; Status = 'Exists'}
            } catch {
                return @{Path = $Path; Status = 'Error'; Error = $_.Exception.Message}
            }
        }).AddArgument($Path)
        
        $Jobs += @{
            PowerShell = $PowerShell
            Handle = $PowerShell.BeginInvoke()
        }
    }
    
    # Collect results
    $Results = foreach ($Job in $Jobs) {
        $Job.PowerShell.EndInvoke($Job.Handle)
        $Job.PowerShell.Dispose()
    }
    
    $RunspacePool.Close()
    $RunspacePool.Dispose()
    
    return $Results
}

# Memory-optimierte File Operations
function Write-OptimizedFile {
    param(
        [string]$Path,
        [string]$Content,
        [int]$BufferSize = $Global:PerformanceConfig.BufferSize
    )
    
    $FileStream = $null
    $StreamWriter = $null
    
    try {
        $FileStream = [System.IO.File]::Create($Path, $BufferSize, [System.IO.FileOptions]::Asynchronous)
        $StreamWriter = [System.IO.StreamWriter]::new($FileStream, [System.Text.Encoding]::UTF8, $BufferSize)
        
        $StreamWriter.Write($Content)
        $StreamWriter.Flush()
        
        return $true
    } catch {
        return $false
    } finally {
        if ($StreamWriter) { $StreamWriter.Dispose() }
        if ($FileStream) { $FileStream.Dispose() }
    }
}

# Batch Operations Optimizer
function Invoke-BatchOperation {
    param(
        [scriptblock]$Operation,
        [object[]]$InputObjects,
        [int]$BatchSize = 100
    )
    
    $Batches = for ($i = 0; $i -lt $InputObjects.Count; $i += $BatchSize) {
        ,($InputObjects[$i..([Math]::Min($i + $BatchSize - 1, $InputObjects.Count - 1))])
    }
    
    $Results = $Batches | ForEach-Object -Parallel {
        $Batch = $_
        $Batch | ForEach-Object -Process $using:Operation
    } -ThrottleLimit $Global:PerformanceConfig.MaxParallelThreads
    
    return $Results
}

# Performance Monitor
function Get-PerformanceMetrics {
    param(
        [scriptblock]$ScriptBlock
    )
    
    # Pre-execution metrics
    $PreCPU = (Get-Process -Id $PID).TotalProcessorTime
    $PreMem = [GC]::GetTotalMemory($false)
    $StartTime = Get-Date
    
    # Execute
    $Result = & $ScriptBlock
    
    # Post-execution metrics
    $PostCPU = (Get-Process -Id $PID).TotalProcessorTime
    $PostMem = [GC]::GetTotalMemory($false)
    $EndTime = Get-Date
    
    # Force garbage collection
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    [GC]::Collect()
    
    return [PSCustomObject]@{
        Result = $Result
        Metrics = @{
            Duration = ($EndTime - $StartTime).TotalSeconds
            CPUTime = ($PostCPU - $PreCPU).TotalSeconds
            MemoryUsed = [Math]::Round(($PostMem - $PreMem) / 1MB, 2)
            MemoryAfterGC = [Math]::Round([GC]::GetTotalMemory($false) / 1MB, 2)
        }
    }
}

# Export functions
Export-ModuleMember -Function @(
    'New-OptimizedFolder',
    'Write-OptimizedFile',
    'Invoke-BatchOperation',
    'Get-PerformanceMetrics'
) -Variable 'PerformanceConfig'

Write-Host "Performance Optimizations Loaded" -ForegroundColor Green
Write-Host "Max Threads: $($Global:PerformanceConfig.MaxParallelThreads)" -ForegroundColor Cyan
Write-Host "Buffer Size: $($Global:PerformanceConfig.BufferSize / 1KB)KB" -ForegroundColor Cyan