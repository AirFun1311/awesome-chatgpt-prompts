# Quick Commands Snippet
# Master Daddy Agency

# Performance monitoring
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# System info
Get-ComputerInfo | Select-Object WindowsProductName, TotalPhysicalMemory