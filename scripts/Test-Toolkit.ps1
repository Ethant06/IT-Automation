Import-Module ..\modules\WorkstationInfo.psm1

$info = Get-WorkstationInfo -ComputerName $env:COMPUTERNAME
$info