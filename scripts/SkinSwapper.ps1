﻿param (
[Parameter(Mandatory=$false)][switch]$skinned
)

if ($skinned) {
    $selectFile = "skins"
} else {
    $selectFile = "nackt"
}

$saveFilePath = Get-Content -Path .\scripts\settings.txt
$saveFileName = "$saveFilePath\1.save"
$uploadFileName = "$saveFileName.upload"

Copy-Item "$PSScriptRoot\saves\$selectFile.save" -Destination $saveFileName
Copy-Item "$PSScriptRoot\saves\$selectFile.save" -Destination $uploadFileName

$saveFile = (Get-Item $saveFileName)
$uploadFile = (Get-Item $uploadFileName)

$saveFile.creationtime=$(Get-Date); $saveFile.lastwritetime=$(Get-Date)
$uploadFile.creationtime=$(Get-Date); $uploadFile.lastwritetime=$(Get-Date)

Write-Output "Save getauscht. Jetzt aktiver save: $selectedFile"