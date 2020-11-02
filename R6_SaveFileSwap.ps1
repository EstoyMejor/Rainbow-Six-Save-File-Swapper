﻿# Hey there!
# This script is Created by EstoyMejor#8008 on Discord. The script is shared under the GPLv3 License http://www.gnu.org/licenses/gpl-3.0.html
# So feel free to use this script to your liking.
# If you encounter any bugs, or have any ideas on how to improve this script hit me up at support@estoymejor.de
#
# Version: 1.1

# Create saves Folder
if (!(Test-Path "$PSScriptRoot\scripts\saves" -PathType Container)) {
    New-Item -ItemType Directory -Force -Path "$PSScriptRoot\scripts\saves" | Out-Null
}

#Check if we already have a folder selected, and load it.
if (Test-Path "$PSScriptRoot\scripts\settings.txt" -PathType leaf) {
    $folderSave = Get-Content -Path .\scripts\settings.txt
}
# If not, ask for the Folder or import a Backup.
Else {

    # File Browser Dialog stuffs
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FileBrowser.SelectedPath = "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\savegames\"
    $FileBrowser.Description = "Select save File folder`nWe only select the FOLDER. You will NOT be able to select the file itself!"

    # Check for backup and import if available and wanted.
    if (Test-Path "$PSScriptRoot\Backup.Zip" -PathType leaf) {
        do {
            $haveBackup = read-host -Prompt "`nYou appear to have a Backup, do you want to import that?`n[Y] Yes [N] No"
            if (!($haveBackup -like "Y" -or $haveBackup -like "N")) {
                Write-Output "Please use a valid option!`n"
            }
        } until (($haveBackup -like "Y" -or $haveBackup -like "N"))
        if ($haveBackup -like "Y") {
            Expand-Archive -Path "$PSScriptRoot\Backup.Zip" -DestinationPath "$PSScriptRoot\scripts\"
        }
        else {
            Write-Output "Sorry, you got to delete the Backup.zip yourself, for now!"
            read-host "Press ENTER to exit..."
            exit
        }
    }
    # If no Backup is available, ask the User for the folder. 
    else {
        Write-Output "Select save File folder`n"
        Write-Output "Usually it looks something like this:"
        Write-Output "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\savegames\cab1dbc6-ff8f-4071-80fa-be72c91ff7f3\635\1.save"
        Write-Output "The numbers can be any random combination, but the file inside always looks like this: 1.save"
        Write-Output "We only select the FOLDER. You will NOT be able to select the file itself!"
        read-host "Press ENTER to continue..."

        $ShowDialog = $FileBrowser.ShowDialog()
        $folderSave = $FileBrowser.SelectedPath

        # Check if the Folder is right.
        If (Test-Path "$folderSave\1.save" -PathType leaf) {
            Write-Output "File found, well done!`n"
        } else {
            Write-Output "You didnt select the right folder! Wubbel! Script now implodes!"
            read-host "Press ENTER to exit..."
            exit
        }

        # Save folder path for later.
        Set-Content -Path .\scripts\settings.txt -Value $folderSave
    }
}
# Options Menu
do {
    $modus = Read-Host -Prompt "[1] Save Equipped`n[2] Save Empty`n[3] Load Equipped`n[4] Load Empty`n[0] Settings`nModus"
    if (!($modus -like 1 -or $modus -like 2 -or $modus -like 3 -or $modus -like 4 -or $modus -like 0)) {
        Write-Output "Please use a valid option!`n"
    }
} until (($modus -like 1 -or $modus -like 2 -or $modus -like 3 -or $modus -like 4 -or $modus -like 0))

# Work all options.
switch ($modus)                         
    {                        
        1 {Invoke-Expression "&'$PSScriptRoot\scripts\Saver.ps1' -skinned"}     # Save Skinned                   
        2 {Invoke-Expression "&'$PSScriptRoot\scripts\Saver.ps1'"}              # Save Empty         
        3 {Invoke-Expression "&'$PSScriptRoot\scripts\SkinSwapper.ps1' -skinned"} # Swap to Skinned
        4 {Invoke-Expression "&'$PSScriptRoot\scripts\SkinSwapper.ps1'"}          # Swap to Empty

        # Settings
        0 {
            # Settings Menu
            do {$settingsModus = Read-Host -Prompt "[1] Factory Reset`n[2] Backup`n[3] Restore`nModus"
                    if (!($settingsModus -like 1 -or $settingsModus -like 2 -or $settingsModus -like 3)) {
                    Write-Output "Please use a valid option!`n"
                    }
            } until (($settingsModus -like 1 -or $settingsModus -like 2 -or $settingsModus -like 3))
            
            # Work all Settings.
            switch ($settingsModus)
                {   # Factory Reset
                    1 { $continue = read-host -Prompt "This will delete EVERYTHING!`n[Y] Yes`n[N] No`nContinue?";
                        if ($continue -like "Y") {
                            Remove-Item "$PSScriptRoot\scripts\settings.txt" -erroraction 'silentlycontinue'
                            Remove-Item "$PSScriptRoot\scripts\saves\nackt.save" -erroraction 'silentlycontinue'
                            Remove-Item "$PSScriptRoot\scripts\saves\skins.save" -erroraction 'silentlycontinue'
                        }
                        read-host "Press ENTER to exit..."
                        exit
                      }
                    # Backup Creating
                    2 {
                        # Check if Backup exists.
                        if (Test-Path "$PSScriptRoot\Backup.Zip" -PathType leaf) {
                            $continue = read-host -Prompt "This will replace your active backup!`n[Y] Yes`n[N] No`nContinue?"
                        }
                        # If not, create one.
                        else {
                            $compress = @{
                                Path = "$PSScriptRoot\scripts\settings.txt", "$PSScriptRoot\scripts\saves\"
                                CompressionLevel = "NoCompression"
                                DestinationPath = "$PSScriptRoot\Backup.Zip"
                            }
                            Compress-Archive @compress
                        }
                        
                        # If yes, update it!
                        if ($continue  -like "Y") {
                            Compress-Archive -Path "$PSScriptRoot\scripts\settings.txt", "$PSScriptRoot\scripts\saves\" -Update -DestinationPath "$PSScriptRoot\Backup.Zip"
                        }
                        read-host "Press ENTER to exit..."
                        exit
                      }
                    # Restore
                    3 {
                        # Check if Backup Exist, ask for Confirm.
                        if (Test-Path "$PSScriptRoot\Backup.Zip" -PathType leaf) {
                            $continue = read-host -Prompt "This will replace all current Saves!`n[Y] Yes`n[N] No`nContinue?"
                            if ($continue -like "Y") {
                                Remove-Item "$PSScriptRoot\scripts\settings.txt" -erroraction 'silentlycontinue'
                                Remove-Item "$PSScriptRoot\scripts\saves\nackt.save" -erroraction 'silentlycontinue'
                                Remove-Item "$PSScriptRoot\scripts\saves\skins.save" -erroraction 'silentlycontinue'
                                Expand-Archive -Path "$PSScriptRoot\Backup.Zip" -DestinationPath "$PSScriptRoot\scripts\"
                            }
                        }
                        # Do nothing if no backup was found.
                        else {
                            Write-Output "No Backup found."
                        }
                        read-host "Press ENTER to exit..."
                        exit
                      }
                    # Should NEVER TRIGGER.
                    Default {Write-Output "Error. Pls Dont do this. How did you do this? WTF?"; read-host "Press ENTER to exit..."; exit}
                }
            
            } 
        #Should NEVER TRIGGER.                             
        Default {Write-Output "Error. Pls Dont do this. How did you do this? WTF?"; read-host "Press ENTER to exit..."; exit}                        
    }

# We are done. 
read-host "Dont forget to use the LOCAL SAVE next time you start the game!`nEnter to exit"