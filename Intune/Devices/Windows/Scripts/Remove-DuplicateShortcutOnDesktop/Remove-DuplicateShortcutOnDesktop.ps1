<#
    .NOTES
    ===========================================================================
    Created on:		14/09/2022
    Created by:		Brice SARRAZIN
    Filename:		Remove-DuplicateShortcutOnDesktop
    ===========================================================================
    .SYNOPSIS
    Remove duplicate shortcuts on the desktop when OneDrive KFM is configured.

    .DESCRIPTION
    When OneDrive KFM (Knowns Folders Move) is configured, desktop shortcuts may end up as duplicates on the desktop on first login.

    This script performs the following actions :
    - Create the hidden ".cleaned" folder
    - Search for duplicate shortcuts on the desktop
    - Move the original shortcut to the hidden ".cleaned" folder because it sometimes lost its icon?! (unlike duplicate)
    - Rename the duplicate with the same name as the original
    - Move remaining duplicates to hidden ".cleaned" folder

    .SETTINGS
    Run this script using the logged-on credentials	No
    Enforce script signature check					No
    Run script in 64-bit PowerShell					No
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