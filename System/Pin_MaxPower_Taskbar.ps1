<#
  Purpose: Pin MaxPower.exe (Turbo ON) and Revert_MaxPower.exe (Turbo OFF) to the Windows taskbar.
  Usage:
    1) Run Build_MaxPower_EXE.ps1 first (to generate the EXEs)
    2) Run System/Install_MaxPower_Shortcuts.ps1 (to create Desktop shortcuts)
    3) Run this script to pin both to the taskbar automatically

  Notes:
    - Works by operating on the .lnk shortcuts and invoking the taskbar pin verb via Shell COM.
    - On some Windows 10/11 builds, Microsoft blocks programmatic taskbar pinning. This script will try
      multiple localized verb variants and report a clear status for each item.
#>

param(
  [switch] $VerboseLog
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) {
  Write-Host $msg -ForegroundColor Cyan
}

function Write-Ok($msg) {
  Write-Host $msg -ForegroundColor Green
}

function Write-WarnMsg($msg) {
  Write-Host $msg -ForegroundColor Yellow
}

function Resolve-ExePath([string] $fileName) {
  # Prefer same folder as this script, then parent folder
  $candidates = @(
    Join-Path $PSScriptRoot $fileName,
    (Join-Path (Split-Path $PSScriptRoot -Parent) $fileName)
  )
  foreach ($c in $candidates) {
    if (Test-Path -LiteralPath $c) { return (Resolve-Path -LiteralPath $c).Path }
  }
  return $null
}

function Ensure-Shortcut([string] $shortcutPath, [string] $targetPath, [string] $iconPath) {
  $shell = New-Object -ComObject WScript.Shell
  $dir = Split-Path -LiteralPath $shortcutPath -Parent
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

  $sc = $shell.CreateShortcut($shortcutPath)
  $sc.TargetPath = $targetPath
  $sc.WorkingDirectory = Split-Path -LiteralPath $targetPath -Parent
  if (Test-Path -LiteralPath $iconPath) { $sc.IconLocation = $iconPath }
  $sc.Save()
}

function Invoke-TaskbarPinOnShortcut([string] $shortcutPath) {
  # Uses Shell COM to find a suitable verb for taskbar pinning (localized variants included)
  $shell = New-Object -ComObject Shell.Application
  $folderPath = Split-Path -LiteralPath $shortcutPath -Parent
  $leaf = Split-Path -Leaf $shortcutPath
  $folder = $shell.Namespace($folderPath)
  if (-not $folder) { throw "Cannot access folder: $folderPath" }
  $item = $folder.ParseName($leaf)
  if (-not $item) { throw "Cannot access shortcut item: $shortcutPath" }

  $verbPatterns = @(
    '(?i)taskbar',           # generic English pattern
    '(?i)taskleiste',        # German (Taskleiste)
    '(?i)anheften',          # German (An Taskleiste anheften)
    '(?i)barra\s*de\s*tareas', # Spanish
    '(?i)bara\s*de\s*tareas',  # common misspelling fallback
    '(?i)barra\s*das\s*tarefas', # Portuguese
    '(?i)dok\s*panel',      # Russian transliteration-ish fallback
    '(?i)taskbarpin'         # canonical verb id (if exposed)
  )

  $verbs = @($item.Verbs())
  if ($VerboseLog) {
    Write-Info ("Available verbs for '" + $leaf + "': " + (($verbs | ForEach-Object { $_.Name }) -join ', '))
  }

  foreach ($pattern in $verbPatterns) {
    $candidate = $verbs | Where-Object { $_ -and ($_.Name -match $pattern -or $_.Verb -match $pattern) } | Select-Object -First 1
    if ($candidate) {
      if ($VerboseLog) { Write-Info ("Using verb: '" + $candidate.Name + "' (" + $candidate.Verb + ")") }
      $candidate.DoIt()
      Start-Sleep -Milliseconds 250
      return $true
    }
  }

  return $false
}

# --- Entry ---

Write-Info "📌 Pinne MaxPower-Shortcuts an die Taskleiste..."

$exeOn  = Resolve-ExePath 'MaxPower.exe'
$exeOff = Resolve-ExePath 'Revert_MaxPower.exe'

if (-not $exeOn -or -not (Test-Path -LiteralPath $exeOn)) {
  throw "MaxPower.exe nicht gefunden. Bitte zuerst Build_MaxPower_EXE.ps1 ausführen."
}
if (-not $exeOff -or -not (Test-Path -LiteralPath $exeOff)) {
  throw "Revert_MaxPower.exe nicht gefunden. Bitte zuerst Build_MaxPower_EXE.ps1 ausführen."
}

# Desktop paths (current user + public)
$desktopPaths = @([Environment]::GetFolderPath('Desktop'))
try {
  $publicDesktop = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) '.'
  if ($publicDesktop) { $desktopPaths += (Split-Path $publicDesktop -Parent) }
} catch {}
$desktopPaths = $desktopPaths | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique

if (-not $desktopPaths -or $desktopPaths.Count -eq 0) {
  throw "Konnte keinen Desktop-Pfad ermitteln."
}

$primaryDesktop = $desktopPaths[0]

$lnkOn  = Join-Path $primaryDesktop 'MaxPower – Turbo ON.lnk'
$lnkOff = Join-Path $primaryDesktop 'MaxPower – Turbo OFF.lnk'

# Try to reuse existing shortcuts, else create
if (-not (Test-Path -LiteralPath $lnkOn))  { Ensure-Shortcut -shortcutPath $lnkOn  -targetPath $exeOn  -iconPath $exeOn }
if (-not (Test-Path -LiteralPath $lnkOff)) { Ensure-Shortcut -shortcutPath $lnkOff -targetPath $exeOff -iconPath $exeOff }

$okOn  = $false
$okOff = $false

try {
  $okOn = Invoke-TaskbarPinOnShortcut -shortcutPath $lnkOn
} catch {
  Write-WarnMsg ("ON: " + $_.Exception.Message)
}

try {
  $okOff = Invoke-TaskbarPinOnShortcut -shortcutPath $lnkOff
} catch {
  Write-WarnMsg ("OFF: " + $_.Exception.Message)
}

if ($okOn -and $okOff) {
  Write-Ok "✅ Beide Verknüpfungen wurden (sofern vom System erlaubt) an die Taskleiste angeheftet."
  exit 0
}

if (-not $okOn)  { Write-WarnMsg "⚠️ Konnte 'MaxPower – Turbo ON' nicht automatisch anheften (mögliche Richtlinienbeschränkung)." }
if (-not $okOff) { Write-WarnMsg "⚠️ Konnte 'MaxPower – Turbo OFF' nicht automatisch anheften (mögliche Richtlinienbeschränkung)." }

Write-Host "Hinweis: Manche Windows-Builds blockieren das automatische Anheften. Rechtsklick auf die Desktop-Verknüpfungen → 'An Taskleiste anheften'." -ForegroundColor DarkYellow
exit 2

