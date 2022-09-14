## Remove-DuplicateShortcutFromDesktop

When OneDrive KFM (Knowns Folders Move) is configured, desktop shortcuts may end up as duplicates on the desktop on first login.

This script performs the following actions:
- Search for duplicate shortcuts on the desktop
- Delete the original because it sometimes lost its icon?! (unlike duplicate)
- Rename the duplicate with the same name as the original

Settings in Intune > Devices > Windows > Scripts :
- Run this script using the logged on credentials: Yes
- Enforce script signature check: No
- Run script in 64 bit PowerShell Host: No

The .exe file is a compiled version of the .ps1. This allows to no longer have a PowerShell window that appears during execution.