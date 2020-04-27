Import-Module ActiveDirectory

function removeGroup {
	Param($username, $VPNADGroup, $currentVPNUserGroups)
	if($currentVPNUserGroups -match $VPNADGroup){
		Remove-ADGroupMember -Identity $VPNADGroup -Members $username -Confirm:$false
		return $true
	}
	return $false
}

function addGroup {
	Param($username, $VPNADGroup, $currentVPNUserGroups)
	if(-not($currentVPNUserGroups -match $VPNADGroup)){
		Add-ADGroupMember $VPNADGroup $username
		return $true
	}
	return $false;
}

# Get the users from the csv
$users = Import-Csv "\\TEMP\VPN\VPNUsers.csv" -Delimiter "," -Encoding UTF8
$currentDate = (Get-Date).ToString("dd/MM/yyyy")

# VPN configuration
$VPN1 = "VPN1"
$VPN2 = "VPN2"
$VPN3 = "VPN3"
$$VPNTotal = "VPN LAN Access - Total Time"

# File configuration
$fileName = "ReportVPNGroupUserChanges - "+ (Get-Date).ToString("dd.MM.yyyy") + ".csv"
$CSVHeader = "User;VPN Removed;VPN 1dded"
Out-File -FilePath $fileName -InputObject $CSVHeader
$rowLines = @()

ForEach ($user in $users) {
	try {
		# Get the properties of the current user
		$username = $user.USERNMAE.trim()
		$userVPNPrevious = $user.CURRENTVPN.trim()
		$userVPN = $user.NEWVPN.trim()
		$dateFrom = $user.DATEFROM.trim()
		$dateTo = $user.DATETO.trim()
		$existsUser = Get-ADUser -Filter { SamAccountName -eq $username }
		if ($existsUser) {
			$rowLines = @()
			# Get all the groups of the user
			$currentVPNUserGroups = Get-ADPrincipalGroupMembership -Identity $username | Select-Object Name | Where-Object { $_.name -like 'VPN LAN Access - *' } | Select-Object Name
			if($currentDate -eq $dateFrom) {
				# Check the vpn which will be removed
				$resultRemove = $false;
				$VPNRemove = "-";
				if($userVPNPrevious -eq "VPN1") {
					$VPNRemove = $VPN1
				} elseif($userVPNPrevious -eq "VPN2") {
					$VPNRemove = $VPN2
				} elseif($userVPNPrevious -eq "VPNTotal") {
					$VPNRemove = $$VPNTotal
				}
				
				# Check the vpn which will add and remove the other VPN groups
				$VPNAdd = $VPN3
				if($userVPN -eq "VPN1") {
					# To add the VPN 1, first remove VPN 2 and VPNTotal
					$VPNAdd = $VPN1
					removeGroup $username $VPN2 $currentVPNUserGroups
					removeGroup $username $$VPNTotal $currentVPNUserGroups
				} elseif($userVPN -eq "VPN2") {
					# To add the VPN 2, first remove VPN 1 and VPNTotal
					$VPNAdd = $VPN2
					removeGroup $username $VPN1 $currentVPNUserGroups
					removeGroup $username $$VPNTotal $currentVPNUserGroups
				} elseif($userVPN -eq "VPNTotal") {
					# To add the VPN Total, it is not necessary to remove any of the others VPNs
					$VPNAdd = $$VPNTotal
				}
				# Add the new VPN
				$resultAdd = addGroup $username $VPNAdd $currentVPNUserGroups

				# Print the user line in the attachment file
				if($resultAdd){
					$rowLines += $username + ";" + $VPNRemove + ";" +  $VPNAdd + ";"
					Out-File -FilePath $fileName -InputObject $rowLines -Append
				}
			} elseif($currentDate -eq $dateTo) {
				# Remove the group that was first asked to be added.
				$resultRemove = $false;
				$VPNRemove = "-"; 
				if($userVPN -eq "VPN1") {
					$VPNRemove = $VPN1; 
					$resultRemove = removeGroup $username $VPNRemove $currentVPNUserGroups
				} elseif($userVPN -eq "VPN2") {
					$VPNRemove = $VPN2; 
					$resultRemove = removeGroup $username $VPNRemove $currentVPNUserGroups
				} elseif($userVPN -eq "VPNTotal") {
					$VPNRemove = $$VPNTotal; 
					$resultRemove = removeGroup $username $VPNRemove $currentVPNUserGroups
				}

				# Add the user to the previous group where it was. Default would be VPN 3.
				$VPNAdd = $VPN3
				if($userVPNPrevious -eq "VPN1") {
					$VPNAdd = $VPN1
				} elseif($userVPNPrevious -eq "VPN2") {
					$VPNAdd = $VPN2
				} elseif($userVPNPrevious -eq "VPNTotal") {
					$VPNAdd = $$VPNTotal
				}
				# Add the new VPN
				$resultAdd = addGroup $username $VPNAdd $currentVPNUserGroups

				# Print the user line in the attachment file
				if($resultRemove){
					$rowLines += $username + ";" + $VPNRemove + ";" +  $VPNAdd + ";"
					Out-File -FilePath $fileName -InputObject $rowLines -Append
				}
			}
		} else{
			$file = "LogChangeVPNUsers.txt"
			"Error " + (Get-Date).ToString("dd/MM/yyyy HH:ss") + ": The user doesnt exist in AD: " + $username| Out-File $file -Append
			continue
		}
	} catch [System.Object] {
		$file = "LogChangeVPNUsers.txt"
		"Error " + (Get-Date).ToString("dd/MM/yyyy HH:ss") + ": " + $username + "\n" + $PSItem.ToString() | Out-File $file -Append
		continue
	} finally {
	}
}

# Parameters to config the email
$from = "myemail@mydomain.com"
$to = "examplemail@exampledomain.com"
$subject = "VPN Group User Changes"
$body = "You will find attach the vpn group changes."
$smtpServer = "myserver.com"
$attachment = $fileName

# Send the email
Send-MailMessage -From $from -to $to -Subject $subject -Body $body -SmtpServer $smtpServer -Attachments $attachment -Encoding BigEndianUnicode

# Remove the file
Remove-Item $fileName