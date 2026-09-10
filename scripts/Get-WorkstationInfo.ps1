$computers = @(
    "PC-001"
    "PC-002"
    "PC-003"
)

forEach ($computer in $computers) {
    Write-Host $computer
}

function Test-Memory {
    param (
        [int]$MemoryGB
    )
    if ($MemoryGB -ge 8) {
        return "true"
    }
    else {
        return "false"
    }
}


function Write-log {
    param (
        [string]$Message
    )

    Add-Content -Path "logs\workstation.log" -Value $Message
}


function Write-Log {
    param (
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logMessage = "$timestamp | $Message"

    Add-Content -Path "logs\workstation.log" -Value $logMessage
}

function Test-File {
    param (
        [string]$Path
    )

    try {
        $file = Get-Item $Path -ErrorAction Stop

        Write-log -Message "Successfully found: $Path"

        return $true
    }
    catch {
        Write-Log -Message "Failed to find: $Path"
        return $false
    }
}

$result = Test-File -Path "C:\Fake\File.exe"
$result