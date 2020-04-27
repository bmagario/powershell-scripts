Add-PSSnapin "*Exchange*"
Import-Module ActiveDirectory

$users = Import-Csv "users.csv" -Delimiter ";" 

ForEach ($user in $users) {
	try {
		$username = $user.ID
		$existsUser = Get-ADUser -Filter { SamAccountName -eq $username }
		if (-not $existsUser) {
			$expirationDate = [DateTime]::MaxValue
			$OU = "CN=Users,DC=mydc,DC=com,DC=ar"
			$homeFolderServer = "DISK10"
			
			$UserParams = @{
				SamAccountName        = $username
				Enabled               = $true
				AccountPassword       = ConvertTo-SecureString $user.Password -AsPlainText -Force
				ChangePasswordAtLogon = $true
				PasswordNeverExpires  = $false
				AccountExpirationDate = $expirationDate
				GivenName             = $user.FirstName
				Surname               = $user.LastName
				Name                  = ($user.LastName + ", " + $user.FirstName) + $servExterno
				DisplayName           = ($user.LastName + ", " + $user.FirstName) + $servExterno
				UserPrincipalName     = ($user.ID + "@mydomain.com")
				Description           = ""
				Office                = $user.Office
				StreetAddress         = $user.StreetAddress
				City                  = $user.City
				State                 = $user.Province
				PostalCode            = $user.PostalCode
				Title                 = $user.JobTitle
				Department            = $user.Department
				Company               = $user.Company
				Manager               = $user.Manager
				Path                  = $OU
			}
			
			# Create the user and clear the account expiration (Never Expires).
			New-ADUser @UserParams
			Clear-ADAccountExpiration -Identity $username
    	    		
			# Add the basic AD Groups.
			# Add-ADGroupMember -Identity "Domain Admins" -Members $username;
			Add-ADGroupMember -Identity "Group 1" -Members $username;
			Add-ADGroupMember -Identity "Group 2" -Members $username;
			
			# Set HomeFolder
			$path = "\\$homeFolderServer\USR\$username"
			Set-ADUser $username -homedirectory $path -homedrive L:
			New-Item -path $path -ItemType Directory -force -ea Stop
			$objacl = get-acl $path
			$AddAccessRule = New-Object 'security.accesscontrol.filesystemaccessrule'("$username", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
			$ObjAcl.AddAccessRule($AddAccessRule)
			Set-acl -path $path $objacl

			# Create the email.
			Enable-Mailbox -Identity $username -Database $user.DB
			Set-Mailbox $username -LitigationHoldEnabled $true
    		
		}
		else {
			$file = "LogCreateUser.txt"
			"Error: The following user already exists in AD: " + $username | out-file $file -Append
		}
	}
	catch [System.Object] {
		$file = "LogCreateUser.txt"
		"Error: User: " + $username + "\n" + $PSItem.ToString() | out-file $file -Append
		Write-Output $PSItem.ToString()
	}
	finally {
	}
}