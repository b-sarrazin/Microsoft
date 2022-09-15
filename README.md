# Remove-DuplicateShortcutOnDesktop

**When OneDrive KFM (Knowns Folders Move) is configured, desktop shortcuts may end up as duplicates on the desktop on first login.**

**This script performs the following actions :**
>- Create the hidden ".cleaned" folder
>- Search for duplicate shortcuts on the desktop
>- Move the original shortcut to the hidden ".cleaned" folder because it sometimes lost its icon?! (unlike duplicate)
>- Rename the duplicate with the same name as the original
>- Move remaining duplicates to hidden ".cleaned" folder

**Why move duplicate shortcuts to the hidden ".cleaned" folder?**
>
> Deleting files could trigger a warning window from OneDrive. For a seamless user experience, duplicate shortcuts are therefore moved to the hidden ".cleaned" folder and remain recoverable if needed.

**Settings in Intune :**
> - Run this script using the logged on credentials: Yes
> - Enforce script signature check: No
> - Run script in 64 bit PowerShell Host: No

The **.exe** file is a compiled version of the .ps1. This **allows to no longer have a PowerShell window that appears during execution**.

---