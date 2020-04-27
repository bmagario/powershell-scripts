# Get Webpage Title
# I ripped off this function from https://gallery.technet.microsoft.com/scriptcenter/e76a4213-cd05-4735-bf80-d5903171ae11 -Thanks Mike Pfeiffer!
Function Get-Title { 
    param([string] $url) 
    $wc = New-Object System.Net.WebClient 
    $data = $wc.downloadstring($url) 
    $title = [regex] '(?<=<title>)([\S\s]*?)(?=</title>)' 
    Write-Output $title.Match($data).value.trim() 
} # End Function Get-Title

##: What server UNC path do you want to store audit files in
$servers = Get-Content -Path "C:\TEMP\servers.txt"
$auditfolderpath = "C:\TEMP"

$OutputFileName = "C:\TEMP\GoogleExtensionList2.csv"
$GoogleExtensionsArray = @()

ForEach ($server in $servers){ 
    # get all user dirs
    $user_folders = Get-ChildItem -Path "\\$($server)\C$\Users"
		
    ForEach ($userFolder in $user_folders){
        if (Test-Path -Path "$($userFolder.FullName)\AppData\Local\Google\Chrome\User Data\Default\Extensions"){
            $extension_folders = Get-ChildItem -Path "$($userFolder.FullName)\AppData\Local\Google\Chrome\User Data\Default\Extensions"
            # loop trhough each extension folder
            ForEach ($extension_folder in $extension_folders){
                $version_folders = Get-ChildItem -Path "$($extension_folder.FullName)"
                foreach ($version_folder in $version_folders) {
                    ##: The extension folder name is the app id in the Chrome web store
                    $appid = $extension_folder.BaseName

                    ##: First check the manifest for a name
					$name = "https://chrome.google.com/webstore/detail/P/" + $appid
	                $Title = ((Get-Title $name).split("-"))[0]
					$GoogleExtensionsArrayItem = New-Object system.object
					$GoogleExtensionsArrayItem | Add-Member -MemberType NoteProperty -Name Path -Value $userFolder.FullName
					$GoogleExtensionsArrayItem | Add-Member -MemberType NoteProperty -Name ExtensionID -Value $appid
					$GoogleExtensionsArrayItem | Add-Member -MemberType NoteProperty -Name Title -Value $Title
					$GoogleExtensionsArrayItem | Add-Member -MemberType NoteProperty -Name Version -Value $version_folder
					$GoogleExtensionsArray += $GoogleExtensionsArrayItem	
                }
            }
            
        }
		
    }
}
$GoogleExtensionsArray | export-csv $OutputFileName -NoTypeInformation