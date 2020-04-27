Import-Module ActiveDirectory

$GroupName = Read-Host -Prompt 'Please insert the group name to search for its subgroups'
$OutputFileName = "C:\TEMP\SubGrupos.csv"
$ArrayItems = @()
$subgroups = (Get-ADGroup -Identity $GroupName -Properties memberof).memberof
ForEach($subgroup in $subgroups){
	$GroupObj = Get-ADGroup $subgroup -Properties Description,Info
	$Item = New-Object system.object
	$Item | Add-Member -MemberType NoteProperty -Name Nombre -Value $GroupObj.Name
	$Item | Add-Member -MemberType NoteProperty -Name Descripcion -Value $GroupObj.Description
	$Item | Add-Member -MemberType NoteProperty -Name Permisos -Value $GroupObj.Info
	$ArrayItems += $Item
}

$ArrayItems | export-csv $OutputFileName -NoTypeInformation -Delimiter ";"