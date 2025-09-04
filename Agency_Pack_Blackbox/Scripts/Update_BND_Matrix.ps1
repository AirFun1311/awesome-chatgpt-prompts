<#
.SYNOPSIS
    Ensures BLACKBOX integration into existing BND Matrix.

.DESCRIPTION
    Invokes structure creator and updates to guarantee 11_BLACKBOX exists with
    required sub-folders. Designed to be CI-friendly.
#>

param(
    [string]$RootPath = 'C:\BND_Matrix'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve path to sibling script and execute
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Create_BND_Matrix_Structure.ps1" -RootPath $RootPath

Write-Host "[Update_BND_Matrix] Structure verified."

<#
TRIAD-FIX
1. Syntax: Dot-source path calculation robust.
2. Logic: Idempotent addition of 11_BLACKBOX ensured by creator.
3. Edge: Execution policy blocking -> instruct user to bypass.

Performance: Reuses idempotent creator; minimal additional I/O.

Risks: Relative path resolution if script moved.
#>