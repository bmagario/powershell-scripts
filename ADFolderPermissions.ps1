$OutputFileName = "C:\TEMP\permissions.csv"
$RootPath = "\\DISK1\"


$errors=@()
get-childitem -recurse $RootPath -ea silentlycontinue -ErrorVariable +errors | Out-Null
$errors.Count
$errors | select -expand categoryinfo | select reason,targetname | export-csv -NoTypeInformation -Delimiter ";" "C:\TEMP\errorsFolder.csv"



# $ACLArray = @()
# foreach ($Folder in $Folders) {
# 	$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access } | Where-Object { $_.IdentityReference -notlike "*BUILTIN*" -and $_.IdentityReference -notlike "*NT AUTHORITY*" }
# 	Foreach ($ACL in $ACLs) {
# 		$ACLArrayItem = New-Object system.object
# 		$ACLArrayItem | Add-Member -MemberType NoteProperty -Name Fullname -Value ($Folder.Fullname)
# 		$ACLArrayItem | Add-Member -MemberType NoteProperty -Name FileSystemRights -Value ($ACL.FileSystemRights)
# 		$ACLArrayItem | Add-Member -MemberType NoteProperty -Name IdentityReference -Value ($ACL.IdentityReference)
# 		$ACLArrayItem | Add-Member -MemberType NoteProperty -Name AccessControlType -Value ($ACL.AccessControlType)
# 		$ACLArrayItem | Add-Member -MemberType NoteProperty -Name IsInherited -Value ($ACL.IsInherited)
# 		$ACLArray += $ACLArrayItem
# 	}
# }

# # $ACLArray | Format-Table
# $ACLArray | Export-Csv $OutputFileName -NoTypeInformation -Encoding UTF8 -Delimiter ";"