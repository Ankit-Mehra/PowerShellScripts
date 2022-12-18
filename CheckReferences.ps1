<#
.DESCRIPTION
Find References to Constants.cs or other files and check if Stored 
procedure is used or not

.PARAMETER ProceduresFile
The path to the file containing the Stored Procedure

.PARAMETER ReferencesDir
The Path of the Directory containing files that have references to stored 
procdure(Output directory of String Search)

.PARAMETER Project,
Name of the Project that we are checking Ex. "Ceridian.NextGen"

.PARAMETER OutputPath
File path were you want to store the Used.txt and NotUsed.txt files. Default is same 
directory from where script is run.

#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ProceduresFile,
	[Parameter(Position=1, Mandatory=$true)]
	[string]$ReferencesDir,
    [Parameter(Position=2, Mandatory=$true)]
	[string]$ProjectsFile,
    [Parameter(Position=3, Mandatory=$false)]
	[string]$OutputPath = "."
)

$ErrorActionPreference = "Stop"
$storedProcFromFile = [IO.File]::ReadAllLines($ProceduresFile)
$projectFromFile = [IO.File]::ReadAllLines($ProjectsFile)
function Search-PSfile
{
    param(
        [string] $ReferencesDir,
        [string] $Project,
        [string] $file
    )

    $procedureName = $file.Split(".")[0].ToLower().Trim()
    $textName = "${procedureName}.txt"

    # transforming the project names into Regex with boundary condition(\b)
    $dirPattern = $projectFromFile | ForEach-Object{
        $_ = $_.Trim()
        $_ = "\b${_}.\b"
        $_
    }

    $searchFile = $file.Split(".")[0].Trim()
    $filePattern = "\b${searchFile}\b"
    $fileContent = Get-ChildItem -Path $ReferencesDir -Filter $textName -Recurse | Get-Content

    #check for Constant.cs files in project directory-- returs true if present
    $isConstantFile = [bool]($fileContent |
            Select-String -Pattern "\bConstants.cs\b" |
            Select-String -Pattern $dirPattern |
            ForEach-Object{
                Get-Content $_  |
                Select-String '(?sm)/\*.*?\*/|^[ \t]*//[^\r\n]*'  -NotMatch | # pattern for comments 
                Select-String -Pattern $filePattern -Quiet
            })

    #check for .cs files in project directory besides Constants.cs .. returs true if present 
    $isOtherCsFile = [bool]($fileContent |
                    Select-String -Pattern "\b.cs\b" |
                    Select-String -Pattern "\bConstants.cs\b" -NotMatch |
                    Select-String -Pattern $dirPattern  |
                    ForEach-Object{
                        (Get-Content $_ -Raw) -replace '(?sm)/\*.*?\*/[ \t]*(?:\r?\n)?|^[ \t]*//[^\r\n]*(?:\r?\n)?' |
                        Select-String -Pattern $filePattern -Quiet
                    })
    

    #check for .odx or .xsd files in project directory and check if file in there in the content.
    $isOdxXsd = [bool]($fileContent |
                        Select-String -Pattern "\.odx","\.xsd" |
                        Select-String -Pattern $filePattern -NotMatch |
                        Select-String -Pattern $dirPattern |
                        ForEach-Object{
                            Get-Content $_ | 
                                    Select-String -Pattern $filePattern |
                                    Select-String -Pattern "<!--[\s\S]*?-->" -NotMatch -Quiet #Regex for Html/Xml comment
                        })


    #check for .sql files other than itself.. returs true if present
    $isUsedSql = [bool]($fileContent |
                Select-String -Pattern "\.sql"|
                Select-String -Pattern $filePattern -NotMatch |
                Select-String -Pattern $dirPattern -Quiet)

    # if there are no constant files and no .sql file and no there .cs files then SP is not used
    If(!$isConstantFile -and !$isUsedSql -and !$isOtherCsFile -and !$isOdxXsd)
    {
        return $false
    }
    # If there are Constants.cs then write SP name in Used.txt end function
    Elseif ($isConstantFile -or $isOtherCsFile -or $isOdxXsd)
    {
        return $true
    }
    # if there are no .cs files only .sql files then do a recusion and check for that .sql file
    Elseif ($isUsedSql) 
    {
        $fileContent|
        Select-String -Pattern "\.sql" |
        Select-String -Pattern $filePattern -NotMatch |
        Select-String -Pattern $dirPattern |
        ForEach-Object{
            $isUnCommented = [bool](Get-Content $_ | 
                                    Select-String -Pattern $filePattern |
                                    Select-String -Pattern "(--)+.*(exec|EXEC|Exec)+" -NotMatch |
                                    Select-String -Pattern "(/\*([^*]|(\*+[^*/]))*\*+/)|(//.*)" -NotMatch -Quiet)
            if($isUnCommented)
            {
                $sqlFile = (Get-Item $_).Name
                Search-PSfile -ReferencesDir $ReferencesDir -Project $Project -file $sqlFile -OutputPath $OutputPath
            }
            else
            {
                return $isUnCommented
            }
        } 
    }
}

function Write-PSfile
{
    param(
        [string]$OutputPath,
        [string]$File,
        [string]$FileName,
        [string]$Text
    )

    $fileExist = Test-Path "${OutputPath}\${FileName}"
    if(!$fileExist)
    {
        $line = "${File} | ${Text}"
        New-Item -Path $OutputPath -Name $FileName -ItemType "file" -Value $line
    }
    else {
        $line = "${File} | ${Text}"
        $path = "${OutputPath}\${FileName}"
        Add-Content -Path $path -Value $line
    }
}

$storedProcFromFile | ForEach-Object{
    $isUsed = Search-PSfile -ReferencesDir $ReferencesDir -Project $Project -file $_ -OutputPath $OutputPath

    if($true -in $isUsed)
    {
        Write-PSfile -OutputPath $OutputPath -File $_ -FileName "Used.txt" -Text "Used"
        
    }
    else 
    {
        Write-PSfile -OutputPath $OutputPath -File $_ -FileName "NotUsed.txt" -Text "Not Used"
        
    }
}

Write-Host "Script Ran Successfully"

