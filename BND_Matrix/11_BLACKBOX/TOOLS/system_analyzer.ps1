# System Analyzer Tool
# Master Daddy Agency

param([string]$Target = "localhost")

Write-Host "🔍 Analyzing system: $Target" -ForegroundColor Cyan
Get-ComputerInfo | Format-List