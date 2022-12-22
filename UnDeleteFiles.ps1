<#
.DESCRIPTION
Delete the list of given files in the provided Visual Studio solution.

.PARAMETER Solution
The path to the .sln file

.PARAMETER FilePath
The path to the file containing the names of files to be Undeleted.

.PARAMETER TfPath
Path for TF.exe file. It can be different in different machines check if this path is right before execution.

.PARAMETER UnDeleteFromTfs
Mark files as pending undeletion in TFS

Check for the path of TF.exe before execution.
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=$true)]
	[string]$FilePath,
	[Parameter(Position=1, Mandatory=$false)]
	[string]$TfPath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe",
	[Parameter(Position=2, Mandatory=$false)]
    [switch]$UnDeleteFromTfs
)
$ErrorActionPreference = "Stop"
$arrayFromFile = [IO.File]::ReadAllLines($FilePath)

if ($UnDeleteFromTfs) 
{
	Write-Host "Marking files as Undeleted in TFS..."
	$index = 0
	$arrayFromFile | ForEach-Object {
		[Array]$arguments = @("undelete", "`"$_`"")
		& "$TfPath" $arguments
		$index += 1
	}
	Write-Host "Total" $index "was undeleted and moved to TFS Pending Changes"
}
else{
    Write-Host "UnDeleteFromDisk was not specified. Listing of files only..."
	$arrayFromFile
}
