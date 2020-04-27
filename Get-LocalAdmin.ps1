$devices = Read-Host -Prompt 'Insert the pc name'

invoke-command {
	$members = net localgroup administrators | 
    Where-Object {$_ -and $_ -NotMatch "command completed successfully"} | 
    Select-Object -Skip 4
    New-Object PSObject -Property @{
		Computername = $env:COMPUTERNAME
		Group = "Administrators"
		Members=$members
	}
} -Computer $devices -HideComputerName | 
Select-Object * -ExcludeProperty RunspaceID
# Export-CSV c:\temp\localAdmins.csv -NoTypeInformation