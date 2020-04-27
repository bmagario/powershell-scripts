Import-Module ActiveDirectory

# User to check.
$GrupoFinalUsers = Get-ADGroup "FinalUsers"
$users = Get-ADUser -Filter { (Enabled -eq $true) -and (memberOf -RecursiveMatch $GrupoFinalUsers.DistinguishedName) -and (Company -eq "MYCOMPANY S.A.") } -SearchBase "CN=Users,DC=mydc,DC=com,DC=ar" -Properties Department | Select-Object SamAccountName, Department

# Groups with certain sufix
$sufijo = "Example__*"
$gruposPD = Get-ADGroup -Filter {name -like $sufijo} -Properties Description | Select-Object DistinguishedName, Name
$ArrayItems = @()
ForEach ($user in $users) {
    try {
        $userAux = Get-ADUser -Identity $user.SamAccountName -Properties MemberOf
        
        $Item = New-Object system.object
        $Item | Add-Member -MemberType NoteProperty -Name User -Value $user.SamAccountName
        $Item | Add-Member -MemberType NoteProperty -Name Description -Value $user.Department
        ForEach ($grupoPD in $gruposPD) {
            $value = ""
            If ($userAux.MemberOf -contains $grupoPD.DistinguishedName) {
                $value = "X"
            }
            $Item | Add-Member -MemberType NoteProperty -Name $grupoPD.Name -Value $value
        }
        $ArrayItems += $Item
    } catch [System.Object] {
        $file = "logerror.txt"
        "Error: User: " + $username + "\n" + $PSItem.ToString() | out-file $file -Append
        Write-Output $PSItem.ToString()
    } finally {

    }
}

# Generate the file.
$OutputFileName = "C:\TEMP\UserGroup.csv"
$ArrayItems | export-csv $OutputFileName -NoTypeInformation -Encoding UTF8 -Delimiter ";"