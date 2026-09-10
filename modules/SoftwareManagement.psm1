# This function checks what software is installed
function Get-InstalledSoftware {
  param (
    [Parameter(Mandatory)]
    [string]$Name
  )

  $registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
  )

  foreach($path in $registryPaths) {
    Get-ItemProperty $path |
      Where-Object DisplayName -like "*$Name*"
  }
}


# this function checks if the software version is sufficient enough
function Compare-SoftwareVersion {
  param (
    [Parameter(Mandatory)]
    [string]$InstalledVersion,

    [Parameter(Mandatory)]
    [string]$RequiredVersion
  )

  $installed = [System.Version]$InstalledVersion
  $required = [System.Version]$RequiredVersion
  return $installed -ge $required
}

function Test-SoftwareUpdated {
  param (
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$RequiredVersion
  )

  $software = Get-InstalledSoftware -Name $Name

  if (-not $software) {
    return $false
  }

  $installedVersion = $software.DisplayVersion
  return Compare-SoftwareVersion `
    -InstalledVersion $installedVersion `
    -RequiredVersion $RequiredVersion
}

Export-ModuleMember -Function Get-InstalledSoftware, Compare-SoftwareVersion, Test-SoftwareUpdated



