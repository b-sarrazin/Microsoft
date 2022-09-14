# Quand OneDrive KFM est configuré, des raccourcis du bureau peuvent se retrouver en doublons sur le bureau à la première ouverture de session.
# Ce script effectue les actions suivantes:
# - Chercher les raccourcis en doublons sur le bureau
# - Supprimer l'original car celui-ci a parfois perdu son icône?! (contrairement au doublon)
# - Renommer le doublon avec le même nom que l'original

# Run this script using the logged on credentials: Yes
# Enforce script signature check: No
# Run script in 64 bit PowerShell Host: No

$DesktopPath = [System.Environment]::GetFolderPath('DesktopDirectory')

$Regex = switch ($PSUICulture) {
    'de-DE' { ' \- Kopie( \(\d+\))*' }
    'es-ES' { ' \- copia( \(\d+\))*' }
    'fr-FR' { ' \- copie( \(\d+\))*' }
    Default { ' \- copy( \(\d+\))*' }
}

# Dossier .cleaned
$CleanedPath = Join-Path -Path $DesktopPath -ChildPath '.cleaned'
$CleanedFolder = Get-ChildItem -Path $CleanedPath -Directory -ErrorAction SilentlyContinue
if ($CleanedFolder) {
    # OK
}
else {
    $CleanedFolder = New-Item -Path $CleanedPath -ItemType Directory -Force -Confirm:$false
}
$CleanedFolder.Attributes = 'Hidden'

# Obtenir tous les raccourcis du bureau et les trier selon leurs noms
$Files = Get-ChildItem -Path $DesktopPath -Filter *.lnk |
    Select-Object FullName, BaseName |
    Sort-Object BaseName

# Parcourir tous les raccourcis
for ($i = 0; $i -lt $Files.Count - 1; $i++) {
    # Vérifier que le fichier n'ait pas déjà été supprimé par ce script
    if (Test-Path -Path $Files[$i].FullName -PathType Leaf) {
        # Trouver les doublons correspondants au fichier en cours
        $DuplicateFiles = $Files | Where-Object { $_.BaseName -match "$($Files[$i].BaseName)($Regex)+" }
        # Si doublons trouvés
        if ($DuplicateFiles) {
            # Supprimer l'original car celui-ci a parfois perdu son icône?! (contrairement au doublon)
            $Files[$i].FullName | Move-Item -Destination $CleanedPath -Force -Confirm:$false -ErrorAction SilentlyContinue
            # Renommer le doublon avec le même nom que l'original
            $DuplicateFiles[0].FullName | Move-Item -Destination $Files[$i].FullName -Force -Confirm:$false
            # Déplacer les doublons restants
            $DuplicateFiles.FullName | Move-Item -Destination $CleanedPath -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}