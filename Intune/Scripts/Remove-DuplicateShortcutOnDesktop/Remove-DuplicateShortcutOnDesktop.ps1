<#
Author: Brice SARRAZIN
Github: https://github.com/b-sarrazin/ModernManagement/Remove-DuplicateShortcutOnDesktop

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
#>

$Regex = switch ($PSUICulture) {
    'de-DE' { ' \- Kopie( \(\d+\))*' }
    'es-ES' { ' \- copia( \(\d+\))*' }
    'fr-FR' { ' \- copie( \(\d+\))*' }
    Default { ' \- copy( \(\d+\))*' }
}

$DesktopPath = [System.Environment]::GetFolderPath('DesktopDirectory')

# Dossier .cleaned
$CleanedPath = Join-Path -Path $DesktopPath -ChildPath '.cleaned'
$CleanedFolder = Get-ChildItem -Path $CleanedPath -Directory -ErrorAction SilentlyContinue
if ($CleanedFolder) {
    # OK
} else {
    $CleanedFolder = New-Item -Path $CleanedPath -ItemType Directory -Force
}
$CleanedFolder.Attributes = 'Hidden'

# Get all desktop shortcuts and sort them by name
$Files = Get-ChildItem -Path $DesktopPath -Filter *.lnk |
    Select-Object FullName, BaseName |
    Sort-Object BaseName

# Browse all shortcuts found
for ($i = 0; $i -lt $Files.Count - 1; $i++) {
    # Check that the shortcut has not already been deleted by this script
    if (Test-Path -Path $Files[$i].FullName -PathType Leaf) {
        # Find duplicates matching the current shortcut
        $DuplicateFiles = $Files | Where-Object { $_.BaseName -match "$($Files[$i].BaseName)($Regex)+" }
        # If duplicates found
        if ($DuplicateFiles) {
            # Move the original shortcut because it sometimes lost its icon?! (unlike duplicate)
            $Files[$i].FullName | Move-Item -Destination $CleanedPath -Force -ErrorAction SilentlyContinue
            # Rename the duplicate with the same name as the original
            $DuplicateFiles[0].FullName | Move-Item -Destination $Files[$i].FullName -Force
            # Move other remaining duplicates
            $DuplicateFiles.FullName | Move-Item -Destination $CleanedPath -Force -ErrorAction SilentlyContinue
        }
    }
}