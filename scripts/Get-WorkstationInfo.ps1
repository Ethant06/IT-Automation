$computerName = $env:COMPUTERNAME

$computerInfo = Get-ComputerInfo |
    Select-Object WindowsProductName, WindowsVersion, OsArchitecture, CsTotalPhysicalMemory

Write-Host "================================"
Write-Host " Workstation Information"
Write-Host "================================"

Write-Host "Computer Name: $computerName"
Write-Host "Windows Version: $($computerInfo.WindowsVersion)"
Write-Host "Architecture: $($computerInfo.OsArchitecture)"
Write-Host "Total Memory: $($computerInfo.CsTotalPhysicalMemory)"
Write-Host "Total Memory in GB: $($computerInfo.CsTotalPhysicalMemory / 1024  / 1024 / 1024)"