# Params ======================================================================

#param([string]$sourceFolder, [string]$destinationFolder)
$sourceFolder = 'd:\drivers\'
$destinationFolder = 'D:\dev\projects\PowershellCourse\Output\'

# Functions ===================================================================

function CheckFolderExists([string]$path, [switch]$createIfNotFound)
{
    $exists = Test-Path -Path $path -PathType Container

    if ($exists -eq $false -and $createIfNotFound)
    {
        $newItem = New-Item -Path $path -ItemType Directory -ErrorAction SilentlyContinue

        return $newItem -ne $null
    }

    return $exists
}

function GetAllFiles([string]$path)
{
    return Get-ChildItem -Path $path -File -Recurse
}

function CategoriseFilesByExtension([System.IO.FileInfo[]]$files)
{
    $filesByExtension = @{}

    Foreach ($f in $files)
    {        
        if ($filesByExtension.ContainsKey($f.Extension) -eq $false)
        {
            $list = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
            $filesByExtension.Add($f.Extension, $list)
        }

        $filesByExtension[$f.Extension].Add($f)
    }

    return $filesByExtension
}

# Logic =======================================================================

Clear-Host

if ($sourceFolder -eq $null -or $sourceFolder -eq '')
{
    'ERROR: No source folder specified.'
    return
}

if ($destinationFolder -eq $null -or $destinationFolder -eq '')
{
    'ERROR: No destination folder specified.'
    return
}


if ((CheckFolderExists $sourceFolder) -eq $false)
{
    "ERROR: Source folder not found '$sourceFolder'."
    return
}

if ((CheckFolderExists $destinationFolder -createIfNotFound) -eq $false)
{
    "ERROR: Failed to find and/or create destination folder '$destinationFolder'."
    return
}

$allFiles = GetAllFiles $sourceFolder
$filesByExtension = CategoriseFilesByExtension $allFiles