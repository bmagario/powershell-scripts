Import-Module ActiveDirectory
$path = Read-Host -Prompt 'Please insert the folder path to search for'
$path = "*$path*"
Get-ADGroup -Filter {Info -like $path} -Properties Info | Select Name,Info | Out-GridView