# Params ======================================================================

param([string]$sourceFolder='d:\drivers\', [string]$destinationFolder='d:\drivers\output\')

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
        $extension = $f.Extension

        if ($extension -eq $null -or $extension.length -eq 0)
        {
            $extension = '_none'
        }

        if ($extension[0] -eq '.')
        {
            $extension = $extension.Remove(0, 1)
        }

        if ($filesByExtension.ContainsKey($extension) -eq $false)
        {
            $list = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
            $filesByExtension.Add($extension, $list)
        }

        $filesByExtension[$extension].Add($f)
    }

    return $filesByExtension
}

function CopyFilesToFolder([string]$folderPath, [System.IO.FileInfo[]]$files)
{
    if ((CheckFolderExists $folderPath -createIfNotFound) -eq $false)
    {
        "ERROR: Failed to find and/or create folder '$folderPath'."
        return
    }

    Foreach ($f in $files)
    {
        Write-Host "$($f.FullName) => $folderPath"
        Copy-Item -Path $f.FullName -Destination $folderPath
    }
}

function GenerateReport([string]$path)
{
    $folders = Get-ChildItem -Path $path -Directory

    Foreach ($folder in $folders)
    {
        $totalSizeInBytes = (Get-ChildItem -Path $folder.FullName -File | Measure-Object -Sum Length).Sum
        Write-Host "$folder.Name : $totalSizeInBytes"
    }
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

Foreach ($extension in $filesByExtension.Keys)
{
    CopyFilesToFolder "$($destinationFolder)\$extension" $filesByExtension[$extension]
}

GenerateReport $destinationFolder