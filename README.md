*For DeleteTFS*

*Visual Studio File Remover PowerShell Script*

This is an Explanation for the PowerShell Script that removes the files from TFs
- Parameters - Solution The path to the .sln file (Mandatory)
- Parameters - FilePath The path to the file containing the names of files to deleted. (Mandatory)
- Parameters - TfPath Path for TF.exe file. It can be different in different machines check if this path is right before execution. (Not Mandatory)
- Parameters - DeleteFromTfs Mark files as pending deletion in TFS (Not Mandatory)
- Parameters - DeleteFromDisk Delete the files directly from the disk ( Not Mandatory)

This script has two mandatory parameters (mentioned above). First is the path of the solution and second is the path of the text file containing the name of the files to be deleted.
if DeleteFromTfs is provided as a parameter it will mark those file as pending deletion in the TFS otherwise it will only show the full path of the files.
If DeleteFromDisk is provided as parameter it will delete the file from the location where they are located. 
Remember to check the path of the TF.exe (TfPath). It can be different for different machines. The default has been set to `"C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"`
 
 Example
`.\VisualStudioFileRemoval.ps1 "C:\bureau\Bureau\CeridianTax\Dev\DevNG+1\Ceridian.NextGenACADB\Ceridian.NextGenACADB.sln" "C:\bureau\test.txt" -DeleteFromTfs`

In the example above 
-	“.\VisualStudioFileRemoval.ps1“ is the name of the script
-	“"C:\bureau\Bureau\CeridianTax\Dev\DevNG+1\Ceridian.NextGenACADB\Ceridian.NextGenACADB.sln"“ is the path of the solution file     from  which we need to remove files
-	“"C:\bureau\test.txt"“ is the path of the text file containing the name of files to be deleted
-	“-DeleteFromTfs“ is the parameter if provided will mark the file as pending deletion in tfs.
 
  Related Articles/References
Some of the articles or posts that I referenced for making this PowerShell Script 
https://stackoverflow.com/questions/8800977/remove-unused-cs-files-in-solution 
https://gist.github.com/mikesigs/3512dbccc1767d447977#file-deleteexcludedfiles-ps1 
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-7.3 
https://learn.microsoft.com/en-us/azure/devops/repos/tfvc/use-team-foundation-version-control-commands?view=azure-devops 







Share


:scroll:
Reference Finding Script

Created by Ankit Mehra
Last updated: yesterday at 1:42 PM2 min read
2 people viewed
This is an Explanation for the PowerShell Script that removes the files from TFs

Parameters - ProceduresFile The path to the file containing the Stored Procedure (Mandatory)

Parameters - ReferencesDir The Path of the Directory containing files that have references to stored  procedure (Output directory of String Search Tool) (Mandatory)

Parameters - ProjectsFile Path of the Project file containing the name of project files that we are checking (Not Mandatory)

Parameters - OutputPath File path were you want to store the Used.txt and NotUsed.txt files. Default is same the directory from where script is run. (Not Mandatory)

 

:outbox_tray: Output

Two files used.txt and NotUsed.txt containing the names of the stored procedures used and not used respectively.

Example

 `& ./CheckReferences.ps1 "C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\TAXPORTAL_SP\Sps.txt" "C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\SearchResults" "C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\TAXPORTAL_SP\projects.txt" "C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\TAXPORTAL_SP\AllSpsTest"`
 In the example above  

`“& ./CheckReferences.ps1` call operator and the name of the PowerShell script 

`"C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\TAXPORTAL_SP\Sps.txt"` is the path of the text files containing the names of the files stored procedure that we want to find references for.

`"C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\SearchResults"` is the path of the directory that was the output directory of StringSearch Tool i.e. directory containing the files that have references for stored procedure

`"C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\TAXPORTAL_SP\projects.txt"` is the path of files containing the names of projects that we want to search for references

`"C:\Users\P12A2B3\OneDrive - Ceridian HCM Inc\Desktop\TAXPORTAL_SP\AllSpsTest"` is an optional argument if given will store the used and notused files in the given path else it will just store in the directory where the script was ran from.

 

 

:clipboard: Related Articles/References
Some of the articles or posts that I referenced for making this PowerShell Script 

[Regular Expression for inline Comments Powershell ](https://stackoverflow.com/questions/74829156/regular-expression-for-inline-comments-powershell)

[Finding Comments in Source Code Using Regular Expressions - Stephen Ostermiller ](https://blog.ostermiller.org/finding-comments-in-source-code-using-regular-expressions/)
 
