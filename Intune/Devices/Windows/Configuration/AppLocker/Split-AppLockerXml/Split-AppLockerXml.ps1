<#
    .NOTES
    ===========================================================================
    Created on:		05/05/2025
    Created by:		Brice SARRAZIN
    Filename:		Split-AppLockerXml
    ===========================================================================

    .SYNOPSIS
    Splits an AppLocker XML file into separate files based on RuleCollection types.

    .DESCRIPTION
    This script takes an AppLocker XML file and splits it into multiple XML files, each containing a single RuleCollection. The output files are saved in a specified folder, which is created if it does not exist. The script also detects the environment based on the XML file name and organizes the output accordingly.

    .LINK
    Github: https://github.com/b-sarrazin/Microsoft

    .EXAMPLE
    .\Split-XML.ps1
    Prompts the user to select an XML file and splits it into separate files, saving them in the default output folder based on the detected environment.

    .\Split-XML.ps1 -XmlFilePath "C:\Path\To\AppLocker.xml" -OutputFolder "C:\Output" -Environment "PROD"
    Splits the specified AppLocker XML file into separate files and saves them in the specified output folder for the PROD environment.
#>


[CmdletBinding()]
param (
    [string]$XmlFilePath = (Get-ChildItem -Path $PSScriptRoot -Filter "*.xml" | Out-GridView -Title "Select XML File" -PassThru | Select-Object -First 1).FullName,
    [string]$OutputFolder = "$PSScriptRoot\AppLockerRulesByCollection",
    [string]$Environment,
    [bool]$Overwrite = $true
)

# Check if the XML file exists
if (-Not $XmlFilePath) {
    Write-Error "No XML file selected. Please select a valid XML file." -ErrorAction Stop
    exit
}
if (-Not (Test-Path $XmlFilePath -PathType Leaf)) {
    Write-Error "XML file not found. Please check the path." -ErrorAction Stop
    exit
}

# Load the XML file
[xml]$xmlContent = Get-Content $XmlFilePath -ErrorAction Stop
if ($null -eq $xmlContent) {
    Write-Error "Failed to load XML file. Please check the file format." -ErrorAction Stop
    exit
}

# Environment detection based on the XML file name
if ([string]::IsNullOrEmpty($Environment)) {

    switch (Split-Path -Path $XmlFilePath -Leaf) {
        { $_ -match "DEV" } {
            $Environment = "DEV"
            break
        }
        { $_ -match "TEST" } {
            $Environment = "TEST"
            break
        }
        { $_ -match "POC" } {
            $Environment = "POC"
            break
        }
        { $_ -match "PREPROD" } {
            $Environment = "PREPROD"
            break
        }
        { $_ -match "PROD" } {
            $Environment = "PROD"
            break
        }
        Default {
            $Environment = "Unknown"
            break
        }
    }

    Write-Host "------------------------------------" -ForegroundColor Green
    Write-Host "- Environment detected: $Environment" -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green

    $OutputFolder = Join-Path -Path $OutputFolder -ChildPath $Environment
}

Write-Host "XML file: $XmlFilePath"
Write-Host "Output folder: $OutputFolder"


# Create the output folder if it doesn't exist
if (-Not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

# Loop through each RuleCollection in the XML and save them as separate files
foreach ($ruleCollection in $xmlContent.AppLockerPolicy.RuleCollection) {
    $type = $ruleCollection.Type
    $outputFile = "$OutputFolder\$type.xml"

    # Create a new XML containing only RuleCollection
    $newXml = New-Object System.Xml.XmlDocument
    $xmlDeclaration = $newXml.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $newXml.AppendChild($xmlDeclaration) | Out-Null

    # Import only the RuleCollection node
    $importedNode = $newXml.ImportNode($ruleCollection, $true)
    $newXml.AppendChild($importedNode) | Out-Null

    # Save the XML file
    $newXml.Save($outputFile)
    Write-Output "File created: $outputFile"

    # Remove old file if it exists and overwrite if specified
    if ($Overwrite -and (Test-Path $outputFile)) {
        Remove-Item $outputFile -Force
        Write-Output "Old file removed: $outputFile"
    }

    # Remove the line containing the XML declaration and write output file
    (Get-Content $outputFile | Where-Object { $_ -notmatch '^<\?xml ' }) | Set-Content $outputFile
}