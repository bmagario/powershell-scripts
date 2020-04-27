Import-Module ActiveDirectory

# First generate the file name.
$now = Get-Date
$curDay = $now.Day
$curMonth = $now.Month
$curYear = $now.Year
$resultFileName = "ReportInactivePC - MYCOMPANY - "+ $curYear + "-" + $curMonth + "-" + $curDay + ".csv"


# Email parameters.
$from = "myemail@mydomain.com"
$to = "myemail@mydomain.com", "otheremail@mydomain.com"
$subject = $resultFileName
$body = "PC which are inactives"
$smtpServer = "myserver.mydomain.com"
$searchOU = "CN=Computers,DC=mydc,DC=com,DC=ar"
$attachment = $resultFileName

# Amount of inactivity in days.
$DaysInactive = 180
$time = (Get-Date).Adddays(-($DaysInactive))

# Get all the computers.
Get-ADComputer -SearchBase $searchOU -Filter * -Properties LastLogonTimestamp |
Where { ($_.LastLogonTimestamp -eq $null -or [datetime]::FromFileTime($_.LastLogonTimestamp) -lt $time) -and $_.Enabled -eq $true} |
Select-Object @{Name="PC"; Expression={$_.Name}},@{Name="Last Logon"; Expression={[DateTime]::FromFileTime($_.LastLogonTimestamp)}},@{Name="Days Last Logon"; Expression={($now - [DateTime]::FromFileTime($_.LastLogonTimestamp)).Days}} |
Export-Csv $resultFileName -NoTypeInformation -Encoding UTF8 -Delimiter ";"

# Send the email.
send-mailmessage -from $from -to $to -subject $subject -body $body -smtpServer $smtpServer -Attachments $attachment -Encoding BigEndianUnicode

Remove-Item $resultFileName