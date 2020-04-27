$ou = "CN=Users,DC=mydc,DC=com,DC=ar"
$ExemptGroup = Get-ADGroup "FinalUsers"
Get-ADUser  `
    -Filter { (memberOf -RecursiveMatch $ExemptGroup.DistinguishedName) -and (Enabled -eq $true) }  `
    -SearchBase $ou -Properties * | `
    Where-Object { $_.HomeDrive -eq $null } | `
    Select-Object Name, DisplayName, SamAccountName