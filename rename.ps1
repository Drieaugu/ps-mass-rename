 <#
.Synopsis
   Renames a large batch of files in a folder.
.DESCRIPTION
   This script will rename all files in a folder to a provided scheme. 
   Various parameters allow you to specify which files should be renamed.
.LINK
   Online version/repository: https://github.com/Drieaugu/ps-mass-rename
   Discord support server: https://discord.gg/nwpnt8B
.PARAMETER path
   Specifies the path, if not provided the current folder will be used.
.PARAMETER scheme
   Specifies the name of the files.
.PARAMETER extension
   Gives the ability to only rename files of a certain type, "all" if not provided.
.PARAMETER verbose
   If toggled will output progress on the command line.
.PARAMETER force
   If toggled the script will not ask the user to confirm
.EXAMPLE
   ./rename.ps1 -scheme "holidayPictures" -verbose
   This example will rename all files in the current folder with holidayPicturesx,
   where x is counted up starting from 0. 
   It will output the progress on the command line since the -verbose flag is toggled.
.EXAMPLE
   ./rename.ps1 -path C:\Users\myUser\desktop -extension "jpg"
   This example will rename all files in the given folder (C:\Users\myUser\desktop) that have the .jpg extension.
.EXAMPLE
   ./rename.ps1 -force
   This example will rename all files without asking the user for permission.
#>
 
 param (
    [System.IO.FileInfo]$path = $PSScriptRoot,
    [string]$scheme = "rename",
    [string]$extension = "all",
    [int]$count = 0,
    [switch]$verbose=$false,
    [switch]$force=$false
 )

$global:unvalidPath = $false

function Validate-Path{
    param (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                $global:unvalidPath = $true
                throw "NonExistent"
            } 
            if(($_ | Test-Path -PathType Leaf) ){
                $global:unvalidPath = $true
                throw "NotAllowed"
            }
            return $true

        })]
        [System.IO.FileInfo]$path = $PSScriptRoot
    )
}

function Rename-All{
    if ($extension -eq "all") {
        #No extension was provided
        Get-ChildItem -Path $path |
        Foreach-Object {
            $prev = $_.FullName
            $new = Rename-Item -Path $_.FullName -NewName ($scheme + $script:count++  + $_.extension) -PassThru
            if ($verbose) {
                Write-Host "$prev => $new"
            }
        }  
    } else {
        #Extension flag is set
        Get-ChildItem -Path $path | 
        Where-Object {$_.Extension -eq $extension} |
        Foreach-Object {
            $prev = $_.FullName
            $new = Rename-Item -Path $_.FullName -NewName ($scheme + $script:count++  + $_.extension) -PassThru
            if ($verbose) {
                Write-Host "$prev => $new"
            }
        }  
    }
}

Validate-Path $path
if (!$global:unvalidPath) {
    if (-Not $force) {
      Write-Host "Path:       $path"  
      Write-Host "Scheme:     $scheme"
      Write-Host "Extension:  $extension"
      Write-Host "Count:      $count"
      $confirmation = Read-Host "These are the correct settings [Y/N]"
      if ($confirmation -eq 'y') {
        Rename-All
      }
    } else {
        Rename-All
    }
}