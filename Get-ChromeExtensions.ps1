################ BEGIN SCRIPT ################

#Example: Get-ChromeExtensions -Computername $Computername -Username $Username

#Define the function with computername and username
function Get-ChromeExtensions {
[CmdletBinding()]            
 Param             
   (                       
    [Parameter(Mandatory=$true,
               Position=0,                          
               ValueFromPipeline=$true,            
               ValueFromPipelineByPropertyName=$true)]            
    [String[]]$ComputerName,
    [Parameter(Mandatory=$true,
               Position=1,                          
               ValueFromPipeline=$true,            
               ValueFromPipelineByPropertyName=$true)]            
    [String[]]$UserName
   )#End Param

Process
{
    #Get Webpage Title
    #I ripped off this function from https://gallery.technet.microsoft.com/scriptcenter/e76a4213-cd05-4735-bf80-d5903171ae11 -Thanks Mike Pfeiffer!
    Function Get-Title { 
    param([string] $url) 
    $wc = New-Object System.Net.WebClient 
    $data = $wc.downloadstring($url) 
    $title = [regex] '(?<=<title>)([\S\s]*?)(?=</title>)' 
    write-output $title.Match($data).value.trim() 
    } #End Function Get-Title

    #Build the path to the remote Chrome Extension folder
    $GoogleExtensionPath = "\\" + $ComputerName + "\C$\Users\" + $Username + "\AppData\Local\Google\Chrome\User Data\Default\Extensions"
    
    #Check that the computer is reachable
    If ((Test-Connection $Computername -Quiet -Count 1) -eq $False){
        Write-Host -foregroundcolor Red "$ComputerName is not online"
        return
    } #End If

    #Check that the path exists
    If ((Test-Path $GoogleExtensionPath) -eq $False){
        Write-Host -foregroundcolor Red "Path not Found: $GoogleExtensionPath"
        Write-Host -foregroundcolor Red "Chrome is probably not installed OR the username has no profile/is wrong" 
        return
    } #End If

    #Get the foldernames, which are the Google Play Store ID #s
    $ExtensionIDNumbers = Get-Childitem $GoogleExtensionPath *. | select name

    #Build a name for the output file
    $OutputFileName = "C:\TEMP\GoogleExtensionList_" + $Computername + "_" + $Username + ".csv"

    #Create an array
    $GoogleExtensionsArray = @()

    #Cycle through each Google ID, and look up the Google Play Store Title, which is the extension name
    Foreach ($GoogleID in $ExtensionIDNumbers){
        $GoogleExtensionsArrayItem = New-Object system.object
        $ExtensionSite = "https://chrome.google.com/webstore/detail/adblock-plus/" + $GoogleID.Name
        $Title = ((Get-Title $ExtensionSite).split("-"))[0]
        $GoogleExtensionsArrayItem | Add-Member -MemberType NoteProperty -Name AppName -Value $Title
        $GoogleExtensionsArrayItem | Add-Member -MemberType NoteProperty -Name ExtensionID -Value ($GoogleID.Name)
        $GoogleExtensionsArray += $GoogleExtensionsArrayItem
    } #End Foreach

    #Export the list of extensions
    $GoogleExtensionsArray | export-csv $OutputFileName -NoTypeInformation
    

}#Process

}#Get-ChromeExtensions

################ END SCRIPT ################