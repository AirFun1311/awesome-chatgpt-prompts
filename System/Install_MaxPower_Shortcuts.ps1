<#
  Purpose: Create Desktop shortcuts for MaxPower.exe (Turbo ON) and Revert_MaxPower.exe (Turbo OFF)
           and optionally pin them to the Windows taskbar.

  Usage:
    - Run Build_MaxPower_EXE.ps1 first (creates MaxPower.exe and Revert_MaxPower.exe)
    - Then run:  System/Install_MaxPower_Shortcuts.ps1 [-PinTaskbar] [-Verbose]

  Notes:
    - Requires no admin for shortcut creation. Taskbar pinning may be restricted by policy.
#>

param(
  [switch] $PinTaskbar,
  [switch] $Verbose
)

$ErrorActionPreference = "Stop"

function Write-Info($m) { Write-Host $m -ForegroundColor Cyan }
function Write-Ok($m)   { Write-Host $m -ForegroundColor Green }
function Write-Warn($m) { Write-Host $m -ForegroundColor Yellow }

function Resolve-Exe([string] $name) {
  $candidates = @(
    Join-Path $PSScriptRoot $name,
    (Join-Path (Split-Path $PSScriptRoot -Parent) $name)
  )
  foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { return (Resolve-Path -LiteralPath $c).Path } }
  return $null
}

function New-Shortcut([string] $shortcutPath, [string] $target, [string] $icon) {
  $shell = New-Object -ComObject WScript.Shell
  $dir = Split-Path -LiteralPath $shortcutPath -Parent
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $sc = $shell.CreateShortcut($shortcutPath)
  $sc.TargetPath = $target
  $sc.WorkingDirectory = Split-Path -LiteralPath $target -Parent
  if (Test-Path -LiteralPath $icon) { $sc.IconLocation = $icon }
  $sc.Save()
}

Write-Info "🧩 Installiere Desktop-Verknüpfungen für MaxPower..."

$exeOn  = Resolve-Exe 'MaxPower.exe'
$exeOff = Resolve-Exe 'Revert_MaxPower.exe'
if (-not $exeOn)  { throw "MaxPower.exe nicht gefunden. Bitte Build_MaxPower_EXE.ps1 ausführen." }
if (-not $exeOff) { throw "Revert_MaxPower.exe nicht gefunden. Bitte Build_MaxPower_EXE.ps1 ausführen." }

$desktop = [Environment]::GetFolderPath('Desktop')
if (-not (Test-Path -LiteralPath $desktop)) { throw "Desktop-Pfad nicht gefunden: $desktop" }

$lnkOn  = Join-Path $desktop 'MaxPower – Turbo ON.lnk'
$lnkOff = Join-Path $desktop 'MaxPower – Turbo OFF.lnk'

New-Shortcut -shortcutPath $lnkOn  -target $exeOn  -icon $exeOn
New-Shortcut -shortcutPath $lnkOff -target $exeOff -icon $exeOff

Write-Ok "✅ Desktop-Verknüpfungen erstellt:"
Write-Host " - $lnkOn"  -ForegroundColor DarkGray
Write-Host " - $lnkOff" -ForegroundColor DarkGray

if ($PinTaskbar) {
  Write-Info "📌 Versuche, an Taskleiste anzuheften..."
  $pinScript = Join-Path $PSScriptRoot 'Pin_MaxPower_Taskbar.ps1'
  if (-not (Test-Path -LiteralPath $pinScript)) {
    Write-Warn "Pin-Skript nicht gefunden: $pinScript. Überspringe Taskleisten-Pin."
  } else {
    try { & $pinScript } catch { Write-Warn ("Taskleisten-Pin fehlgeschlagen: " + $_.Exception.Message) }
  }
}

Write-Ok "🎯 Fertig. Doppelklick: Turbo an/aus."

