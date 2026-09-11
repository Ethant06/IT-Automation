function Get-WorkstationInfo {
  param (
    [Parameter(Mandatory)]
    [string]$ComputerName
  )

  $computerInfo = Get-ComputerInfo |
    Select-Object WindowsProductName, WindowsVersion, OsArchitecture, CsTotalPhysicalMemory

  [PSCustomObject]@{
    ComputerName   = $ComputerName
    WindowsVersion = $computerInfo.WindowsVersion
    Architecture  = $computerInfo.OsArchitecture
    MemoryGB       = [Math]::Round(
        $computerInfo.CsTotalPhysicalMemory / 1GB,
        2
    )
  }
}

Export-ModuleMember -Function Get-WorkstationInfo
