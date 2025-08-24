MaxPower Utilities (Windows)
=================================

Files:
- Build_MaxPower_EXE.ps1 — builds MaxPower.exe and Revert_MaxPower.exe from .ps1 sources
- Install_MaxPower_Shortcuts.ps1 — creates Desktop shortcuts; optional taskbar pin via -PinTaskbar
- Pin_MaxPower_Taskbar.ps1 — pins shortcuts/EXEs to Windows taskbar (best-effort; may be blocked by policy)

Usage
-----
1. Run Build_MaxPower_EXE.ps1
2. Run Install_MaxPower_Shortcuts.ps1 [-PinTaskbar]
3. Double-click shortcuts: MaxPower – Turbo ON / OFF

Notes
-----
- Taskbar pinning is blocked in some Windows builds by Microsoft policy. The pin script attempts multiple localized verbs and reports status.
- Run PowerShell as Administrator for MaxPower execution (not required for installing shortcuts).

