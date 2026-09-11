function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO",

        [string]$LogPath = "$PSScriptRoot\..\logs\workstation-toolkit.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logEntry = "[$timestamp] [$Level] $Message"

    Add-Content -Path $LogPath -Value $logEntry

    Write-Host $logEntry
}

Export-ModuleMember -Function Write-Log