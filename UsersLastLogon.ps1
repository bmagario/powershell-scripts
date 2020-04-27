Import-Module ActiveDirectory

function Get-ADUserLastLogon([string]$userName){
  $now = Get-Date
  $dcs = Get-ADDomainController -Filter {Name -like "*"} | Where-Object {$_.Name -ne 'exampleexception'}
  $time = 0
  
  foreach($dc in $dcs)  { 
    $hostname = $dc.HostName
	$user = Get-ADUser $userName | Get-ADObject -Properties lastLogon -Server $hostname
    if($user.LastLogon -gt $time){
      $time = $user.LastLogon
    }
  }
  
  $dt = [DateTime]::FromFileTime($time)
  
  return $dt
  
}

Get-ADUserLastLogon "USERIDEXAMPLE"