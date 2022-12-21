<#
.DESCRIPTION
Delete the list of given files in the provided Visual Studio solution.

.PARAMETER Solution
The path to the .sln file

.PARAMETER FilePath
The path to the file containing the names of files to deleted.

.PARAMETER TfPath
Path for TF.exe file. It can be different in different machines check if this path is right before execution.

.PARAMETER DeleteFromTfs
Mark files as pending deletion in TFS

.PARAMETER DeleteFromDisk
Delete the files directly from the disk

Check for the path of TF.exe before execution.
#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Solution,
	[Parameter(Position=1, Mandatory=$true)]
	[string]$FilePath,
	[Parameter(Position=2, Mandatory=$false)]
	[string]$TfPath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe",
	[Parameter(Position=3, Mandatory=$false)]
    [switch]$DeleteFromTfs
)
$ErrorActionPreference = "Stop"
$solutionDir = Split-Path $Solution | ForEach-Object { (Resolve-Path $_).Path }
$projectFileName = get-childitem  $solutionDir -include *.*proj -recurse | Select-Object -ExpandProperty FullName

$arrayFromFile = [IO.File]::ReadAllLines($FilePath)
$fullPaths = New-Object System.Collections.Generic.List[System.Object]
foreach($file in $arrayFromFile)
{
	$path = Get-ChildItem -Path $solutionDir -Filter $file -Recurse | Select-Object -ExpandProperty FullName
	$fullPaths.Add($path)
}

Write-Host "Found" $fullPaths.count "files"

if($arrayFromFile.Count -ne $fullPaths.Count)
{
	exit
}

$DeleteFromTfs = $true
if ($DeleteFromTfs) 
{
	Write-Host "Marking files as deleted in TFS..."
	$index = 0
	$fullPaths | ForEach-Object {
		[Array]$arguments = @("delete", "`"$_`"")
		& "$TfPath" $arguments
		$index += 1
	}
	Write-Host "Total" $index "was deleted and moved to TFS Pending Changes"

	Write-Host "Deleting References from Project file .."
	foreach($file in $arrayFromFile)
	{
		$filePattern = "\b${file}\b"
		(get-content $projectFileName | select-string -pattern $filePattern -notmatch) | Set-Content $projectFileName -Encoding UTF8
	}
	Write-Host "Total" $arrayFromFile.Count "line references was deleted from" $projectFileName
} 
elseif($DeleteFromDisk)
{
	Write-Host "Deleting excluded files from disk..."
	$fullPaths | ForEach-Object { Remove-Item -Path $_ -Force -Verbose}
}
else 
{
	Write-Host "Neither DeleteFromTfs or DeleteFromDisk was specified. Listing of files only..."
	$fullPaths
}