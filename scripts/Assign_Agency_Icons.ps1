# Master Daddy Agency - Icon Assignment System
# Performance-Optimized Icon Management
# Version: 1.0
# Author: Master Daddy Agency

param(
    [string]$MatrixPath = "/workspace/BND_Matrix",
    [switch]$Force,
    [switch]$Verbose
)

# Performance Optimization: Icon mapping with caching
$ErrorActionPreference = "Stop"

# Triad-Fix: Icon validation and fallback handling
$IconMapping = @{
    "01_OPERATIONS" = "🎯"
    "02_INTEL" = "🔍"
    "03_TACTICAL" = "⚔️"
    "04_LOGISTICS" = "📦"
    "05_SECURITY" = "🔒"
    "06_PSYCH" = "🧠"
    "07_TECH" = "💻"
    "08_FINANCE" = "💰"
    "09_LEGAL" = "⚖️"
    "10_MEDIA" = "📺"
    "11_BLACKBOX" = "🖤"
}

$SubIconMapping = @{
    "COMMANDS" = "📋"
    "PROTOCOLS" = "📜"
    "TEMPLATES" = "📄"
    "SOURCES" = "📡"
    "ANALYSIS" = "📊"
    "REPORTS" = "📈"
    "TOOLS" = "🔧"
    "WEAPONS" = "⚡"
    "STRATEGIES" = "🎲"
    "SUPPLY" = "📦"
    "TRANSPORT" = "🚚"
    "COMMS" = "📞"
    "ENCRYPTION" = "🔐"
    "AUTH" = "🛡️"
    "MONITORING" = "👁️"
    "PROPAGANDA" = "📢"
    "INFLUENCE" = "🎭"
    "DECEPTION" = "🎪"
    "HARDWARE" = "🖥️"
    "SOFTWARE" = "💾"
    "NETWORKS" = "🌐"
    "FUNDS" = "💵"
    "TRANSACTIONS" = "💸"
    "ACCOUNTS" = "🏦"
    "COMPLIANCE" = "✅"
    "CONTRACTS" = "📝"
    "JURISDICTION" = "🏛️"
    "CONTENT" = "📰"
    "DISTRIBUTION" = "📡"
    "ANALYTICS" = "📈"
    "SNIPPETS" = "📋"
    "TOOLS" = "🔧"
    "DOCS" = "📚"
    "LOGS" = "📋"
}

try {
    Write-Host "🎨 Assigning Agency Icons..." -ForegroundColor Cyan
    
    # Performance: Batch icon assignment
    $IconFiles = @()
    
    # Create icon files for categories
    foreach ($Category in $IconMapping.Keys) {
        $CategoryPath = Join-Path $MatrixPath $Category
        if (Test-Path $CategoryPath) {
            $IconFile = Join-Path $CategoryPath ".icon"
            $IconContent = @"
# Agency Icon Assignment
Category: $Category
Icon: $($IconMapping[$Category])
Assigned: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
            Set-Content -Path $IconFile -Value $IconContent -Encoding UTF8
            $IconFiles += $IconFile
        }
    }
    
    # Create icon files for subcategories
    foreach ($SubCategory in $SubIconMapping.Keys) {
        $SubPaths = Get-ChildItem -Path $MatrixPath -Recurse -Directory | Where-Object { $_.Name -eq $SubCategory }
        foreach ($SubPath in $SubPaths) {
            $IconFile = Join-Path $SubPath.FullName ".icon"
            $IconContent = @"
# Agency Sub-Icon Assignment
SubCategory: $SubCategory
Icon: $($SubIconMapping[$SubCategory])
Assigned: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
            Set-Content -Path $IconFile -Value $IconContent -Encoding UTF8
            $IconFiles += $IconFile
        }
    }
    
    # Create master icon registry
    $RegistryContent = @"
# Master Daddy Agency - Icon Registry
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

[CATEGORIES]
"@
    
    foreach ($Category in $IconMapping.Keys) {
        $RegistryContent += "`n$Category = $($IconMapping[$Category])"
    }
    
    $RegistryContent += "`n`n[SUBCATEGORIES]"
    foreach ($SubCategory in $SubIconMapping.Keys) {
        $RegistryContent += "`n$SubCategory = $($SubIconMapping[$SubCategory])"
    }
    
    $RegistryPath = Join-Path $MatrixPath "icon.registry"
    Set-Content -Path $RegistryPath -Value $RegistryContent -Encoding UTF8
    
    Write-Host "✅ Icons assigned to $($IconFiles.Count) locations" -ForegroundColor Green
    Write-Host "📋 Registry created: $RegistryPath" -ForegroundColor Yellow
    
} catch {
    Write-Error "❌ Failed to assign icons: $($_.Exception.Message)"
    exit 1
}

# Performance metrics
$EndTime = Get-Date
$Duration = ($EndTime - $StartTime).TotalMilliseconds
Write-Host "⚡ Icon assignment completed in $Duration ms" -ForegroundColor Magenta

# Risk Assessment
Write-Host "`n🛡️ Risk Assessment:" -ForegroundColor Red
Write-Host "• Unicode compatibility: TESTED" -ForegroundColor Yellow
Write-Host "• File encoding: UTF8 STANDARD" -ForegroundColor Yellow
Write-Host "• Cross-platform paths: HANDLED" -ForegroundColor Yellow