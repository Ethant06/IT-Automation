# Import modules
Import-Module "$PSScriptRoot\..\modules\WorkstationInfo.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\SoftwareManagement.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\Logging.psm1" -Force

# Paths
$configPath = "$PSScriptRoot\..\config\software-requirements.psd1"

Write-Log -Message "Starting workstation setup" -Level INFO

try {

    # Get workstation information
    $computerName = $env:COMPUTERNAME

    Write-Log -Message "Collecting workstation information" -Level INFO

    $workstation = Get-WorkstationInfo -ComputerName $computerName

    Write-Log `
        -Message "Workstation: $($workstation.ComputerName) | Windows: $($workstation.WindowsVersion) | Architecture: $($workstation.Architecture) | Memory: $($workstation.MemoryGB) GB" `
        -Level SUCCESS


    # Update configured software
    Write-Log -Message "Starting software updates" -Level INFO

    $results = @(Update-AllSoftware -ConfigPath $configPath)


    # Final report
    Write-Host ""
    Write-Host "========== WORKSTATION SETUP REPORT =========="

    Write-Host "Computer: $($workstation.ComputerName)"
    Write-Host "Windows:  $($workstation.WindowsVersion)"
    Write-Host "Memory:   $($workstation.MemoryGB) GB"
    Write-Host ""

    foreach ($result in $results) {

        Write-Host "$($result.Software):"

        Write-Host "  Before:  $($result.BeforeVersion)"
        Write-Host "  After:   $($result.AfterVersion)"
        Write-Host "  Success: $($result.Success)"
        Write-Host "  Message: $($result.Message)"
        Write-Host ""
    }

    $failed = @($results | Where-Object { -not $_.Success })

    if ($failed.Count -eq 0) {
        Write-Log -Message "Workstation setup completed successfully" -Level SUCCESS

        Write-Host "STATUS: READY"
    }
    else {
        Write-Log `
            -Message "Workstation setup completed with $($failed.Count) failed software update(s)" `
            -Level WARNING

        Write-Host "STATUS: NOT READY"
    }

}
catch {

    Write-Log `
        -Message "Workstation setup failed: $($_.Exception.Message)" `
        -Level ERROR

    Write-Host "STATUS: FAILED"
}
