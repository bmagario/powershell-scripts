Import-Module ActiveDirectory
$Username = Read-Host -Prompt 'Please insert the username to ge its information'
$Path = "C:\TEMP\Evidence-$Username\"
If(!(test-path $Path)){
	New-Item -ItemType Directory -Force -Path $Path
}

Get-ADUser $Username -properties * | Sort-Object -Property name > "$Path$Username-Properties.txt" 
(Get-ADuser -Identity $Username -Properties memberof).memberof | Get-ADGroup | Select-Object name | Sort-Object name > "$Path$Username-MemberOf.txt"
Get-ADUser -Identity $Username -Properties DirectReports | Sort-Object -Property name | Select -ExpandProperty directreports > "$Path$Username-DirectReports.txt"