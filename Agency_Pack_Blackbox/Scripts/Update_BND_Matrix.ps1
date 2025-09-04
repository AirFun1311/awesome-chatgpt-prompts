#Requires -Version 5.1
<#
.SYNOPSIS
    Aktualisiert BND_Matrix mit neuen Komponenten
.DESCRIPTION
    Fügt 11_BLACKBOX und Substrukturen hinzu
.AUTHOR
    Master Daddy Agency
#>

[CmdletBinding()]
param(
    [string]$BasePath = "C:\BND_Matrix",
    [string]$Component = "11_BLACKBOX",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Blackbox-Struktur
$BlackboxFolders = @(
    "SNIPPETS\PowerShell",
    "SNIPPETS\Python",
    "SNIPPETS\Batch",
    "SNIPPETS\Exploits",
    "TOOLS\Recon",
    "TOOLS\Exploit",
    "TOOLS\PostExploit",
    "TOOLS\Persistence",
    "DOCS\Procedures",
    "DOCS\Targets",
    "DOCS\Reports",
    "LOGS\Operations",
    "LOGS\Errors",
    "LOGS\Access"
)

# Security Attributes
$SecurityDescriptor = @"
D:(A;OICI;FA;;;BA)(A;OICI;FA;;;SY)
"@

try {
    $StartTime = Get-Date
    $ComponentPath = Join-Path $BasePath $Component
    
    # Erstelle Hauptkomponente
    if (-not (Test-Path $ComponentPath)) {
        New-Item -ItemType Directory -Path $ComponentPath -Force | Out-Null
    }
    
    # Parallel Subfolder-Erstellung
    $Results = $BlackboxFolders | ForEach-Object -Parallel {
        $FullPath = Join-Path $using:ComponentPath $_
        
        if (-not (Test-Path $FullPath)) {
            New-Item -ItemType Directory -Path $FullPath -Force | Out-Null
            
            # Setze Sicherheit (nur Admins/System)
            if ($using:Force) {
                $Acl = Get-Acl $FullPath
                $Acl.SetSecurityDescriptorSddlForm($using:SecurityDescriptor)
                Set-Acl -Path $FullPath -AclObject $Acl
            }
            
            [PSCustomObject]@{
                Path = $FullPath
                Status = 'Created'
                Secured = $using:Force
            }
        } else {
            [PSCustomObject]@{
                Path = $FullPath
                Status = 'Exists'
                Secured = $false
            }
        }
    } -ThrottleLimit 10
    
    # Erstelle README in BLACKBOX
    $ReadmePath = Join-Path $ComponentPath "README.md"
    $ReadmeContent = @"
# 11_BLACKBOX

## Structure
- **SNIPPETS**: Code fragments for operations
- **TOOLS**: Operational tools and utilities  
- **DOCS**: Documentation and procedures
- **LOGS**: Operation logs and audit trails

## Security
Access restricted to authorized personnel only.

## Usage
Follow agency protocols for all operations.

---
*Master Daddy Agency*
"@
    
    $ReadmeContent | Set-Content -Path $ReadmePath -Force
    
    $Duration = (Get-Date) - $StartTime
    
    # Report
    Write-Host "`nBLACKBOX Integration Complete" -ForegroundColor Green
    Write-Host "Duration: $($Duration.TotalSeconds)s" -ForegroundColor Cyan
    Write-Host "Folders Created: $(($Results | Where-Object {$_.Status -eq 'Created'}).Count)" -ForegroundColor Cyan
    Write-Host "Security Applied: $Force" -ForegroundColor Yellow
    
    @{
        Component = $Component
        FoldersCreated = ($Results | Where-Object {$_.Status -eq 'Created'}).Count
        FoldersExisted = ($Results | Where-Object {$_.Status -eq 'Exists'}).Count
        Duration = $Duration.TotalSeconds
        Secured = $Force
    }

} catch {
    Write-Error "BLACKBOX update failed: $_"
    exit 1
}