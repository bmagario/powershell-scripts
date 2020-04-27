param (
    [string]$username,
    [string]$server
)

$path = "\\$server\USR\$username"

Set-ADUser $username -homedirectory $path -homedrive L:

New-Item -path $path -ItemType Directory -force -ea Stop
$objacl = get-acl $path
$AddAccessRule = New-Object 'security.accesscontrol.filesystemaccessrule'("$username", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$ObjAcl.AddAccessRule($AddAccessRule)
Set-acl -path $path $objacl
