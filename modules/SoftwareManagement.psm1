if (-not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
    Import-Module (Join-Path $PSScriptRoot 'Logging.psm1')
}

function Get-InstalledSoftware {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $registryPaths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object DisplayName -like "*$Name*"
    }
}


function Get-SoftwareVersion {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $software = @(Get-InstalledSoftware -Name $Name)

    if (-not $software) {
        return [PSCustomObject]@{
            Name    = $Name
            Version = $null
            Found   = $false
        }
    }

    $parsedVersions = foreach ($item in $software) {
        if (-not $item.DisplayVersion) {
            continue
        }

        try {
            [System.Version]$item.DisplayVersion
        }
        catch {
        }
    }

    $version = $parsedVersions |
        Sort-Object -Descending |
        Select-Object -First 1

    $versionText = if ($version) {
        $version.ToString()
    }
    else {
        ($software | Where-Object DisplayVersion | Select-Object -First 1).DisplayVersion
    }

    return [PSCustomObject]@{
        Name    = $Name
        Version = $versionText
        Found   = $true
    }
}


function Find-GoogleUpdater {

    $searchRoot = "C:\Program Files (x86)\Google\GoogleUpdater"

    if (-not (Test-Path $searchRoot)) {
        return $null
    }

    $updater = Get-ChildItem `
        $searchRoot `
        -Recurse `
        -Filter "updater.exe" `
        -File `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (-not $updater) {
        return $null
    }

    return $updater.FullName
}


function Find-ChromeExe {

    $candidates = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }

    $installed = Get-InstalledSoftware -Name "Chrome" | Select-Object -First 1

    if ($installed.InstallLocation) {
        $exePath = Join-Path $installed.InstallLocation "chrome.exe"
        if (Test-Path $exePath) {
            return $exePath
        }
    }

    return $null
}


function Test-ChromeRunning {
    return [bool](Get-Process -Name "chrome" -ErrorAction SilentlyContinue)
}


function Close-ChromeGracefully {
    param (
        [int]$TimeoutSeconds = 30
    )

    $processes = @(Get-Process -Name "chrome" -ErrorAction SilentlyContinue)

    if (-not $processes) {
        return $true
    }

    foreach ($process in $processes) {
        try {
            $process.CloseMainWindow() | Out-Null
        }
        catch {
        }
    }

    $stopAt = (Get-Date).AddSeconds($TimeoutSeconds)

    do {
        Start-Sleep -Seconds 1

        if (-not (Get-Process -Name "chrome" -ErrorAction SilentlyContinue)) {
            return $true
        }
    } while ((Get-Date) -lt $stopAt)

    return $false
}


function Get-ChromeFileVersion {
    param (
        [string]$ChromePath
    )

    if (-not $ChromePath -or -not (Test-Path $ChromePath)) {
        return $null
    }

    return (Get-Item $ChromePath).VersionInfo.ProductVersion
}


function Start-ChromeAndGetVersion {
    param (
        [Parameter(Mandatory)]
        [string]$ChromePath,

        [int]$TimeoutSeconds = 30
    )

    Start-Process -FilePath $ChromePath

    $stopAt = (Get-Date).AddSeconds($TimeoutSeconds)

    do {
        Start-Sleep -Seconds 1

        $running = Get-Process -Name "chrome" -ErrorAction SilentlyContinue |
            Where-Object Path |
            Select-Object -First 1

        if ($running) {
            try {
                return (Get-Item $running.Path).VersionInfo.ProductVersion
            }
            catch {
                return Get-ChromeFileVersion -ChromePath $ChromePath
            }
        }
    } while ((Get-Date) -lt $stopAt)

    return $null
}


function Update-Chrome {

    $before = Get-SoftwareVersion -Name "Chrome"
    $updaterPath = Find-GoogleUpdater
    $chromePath = Find-ChromeExe
    $maxAttempts = 3
    $chromeWasRunning = Test-ChromeRunning

    if (-not $updaterPath) {
        return [PSCustomObject]@{
            Software      = "Chrome"
            Success       = $false
            Attempts      = 0
            BeforeVersion = $before.Version
            AfterVersion  = $before.Version
            Message       = "Google Updater was not found."
        }
    }

    if (-not $chromePath) {
        return [PSCustomObject]@{
            Software      = "Chrome"
            Success       = $false
            Attempts      = 0
            BeforeVersion = $before.Version
            AfterVersion  = $before.Version
            Message       = "chrome.exe was not found."
        }
    }

    if ($chromeWasRunning) {
        Write-Log -Message "Chrome is running. Closing it before update." -Level INFO

        if (-not (Close-ChromeGracefully)) {
            return [PSCustomObject]@{
                Software      = "Chrome"
                Success       = $false
                Attempts      = 0
                BeforeVersion = $before.Version
                AfterVersion  = $before.Version
                Message       = "Chrome refused to close. Update was not started."
            }
        }
    }

    $currentVersion = $before.Version
    $exitCode = $null

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {

        try {
            $process = Start-Process `
                -FilePath $updaterPath `
                -ArgumentList "--update-apps", "--system" `
                -Wait `
                -PassThru `
                -ErrorAction Stop

            $exitCode = $process.ExitCode
        }
        catch {
            return [PSCustomObject]@{
                Software      = "Chrome"
                Success       = $false
                Attempts      = $attempt
                BeforeVersion = $before.Version
                AfterVersion  = $currentVersion
                Message       = "Failed to run Google Updater."
            }
        }

        $after = Get-SoftwareVersion -Name "Chrome"

        if ($after.Version -eq $currentVersion) {
            break
        }

        $currentVersion = $after.Version
    }

    $installedVersion = (Get-SoftwareVersion -Name "Chrome").Version

    Write-Log -Message "Launching Chrome to verify version $installedVersion" -Level INFO

    $runningVersion = Start-ChromeAndGetVersion -ChromePath $chromePath
    $fileVersion = Get-ChromeFileVersion -ChromePath $chromePath

    if (-not $runningVersion) {
        return [PSCustomObject]@{
            Software      = "Chrome"
            Success       = $false
            Attempts      = $attempt
            BeforeVersion = $before.Version
            AfterVersion  = $installedVersion
            ExitCode      = $exitCode
            Message       = "Chrome update finished but Chrome did not launch."
        }
    }

    $versionsMatch = ($runningVersion -eq $installedVersion) -or ($runningVersion -eq $fileVersion)

    if (-not $versionsMatch) {
        return [PSCustomObject]@{
            Software      = "Chrome"
            Success       = $false
            Attempts      = $attempt
            BeforeVersion = $before.Version
            AfterVersion  = $installedVersion
            RunningVersion = $runningVersion
            ExitCode      = $exitCode
            Message       = "Chrome launched, but running version $runningVersion does not match installed version $installedVersion."
        }
    }

    return [PSCustomObject]@{
        Software       = "Chrome"
        Success        = ($exitCode -eq 0)
        Attempts       = $attempt
        BeforeVersion  = $before.Version
        AfterVersion   = $installedVersion
        RunningVersion = $runningVersion
        ExitCode       = $exitCode
        Message        = "Chrome is ready. Running version $runningVersion."
    }
}


function Wait-ScheduledTaskToFinish {
    param (
        $Task,
        [int]$TimeoutSeconds = 180
    )

    $stopAt = (Get-Date).AddSeconds($TimeoutSeconds)

    do {
        $current = Get-ScheduledTask `
            -TaskName $Task.TaskName `
            -TaskPath $Task.TaskPath `
            -ErrorAction SilentlyContinue

        if (-not $current -or $current.State -ne 'Running') {
            return
        }

        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $stopAt)
}


function Wait-MozillaUpdaterProcess {
    param (
        [int]$TimeoutSeconds = 180
    )

    $stopAt = (Get-Date).AddSeconds($TimeoutSeconds)

    do {
        $updaters = Get-Process -Name "updater" -ErrorAction SilentlyContinue

        $mozillaUpdater = $updaters | Where-Object {
            try {
                (-not $_.Path) -or
                ($_.Path -like "*Mozilla*") -or
                ($_.Path -like "*Firefox*")
            }
            catch {
                $true
            }
        }

        if (-not $mozillaUpdater) {
            return
        }

        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $stopAt)
}


function Update-Firefox {

    $before = Get-SoftwareVersion -Name "Firefox"
    $maxAttempts = 3

    $task = Get-ScheduledTask |
        Where-Object TaskName -like "*Firefox Background Update*" |
        Select-Object -First 1

    if (-not $task) {
        return [PSCustomObject]@{
            Software      = "Firefox"
            Success       = $false
            Attempts      = 0
            BeforeVersion = $before.Version
            AfterVersion  = $before.Version
            Message       = "Firefox Background Update task was not found."
        }
    }

    $currentVersion = $before.Version

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {

        try {
            Start-ScheduledTask `
                -TaskName $task.TaskName `
                -TaskPath $task.TaskPath `
                -ErrorAction Stop
        }
        catch {
            $state = (
                Get-ScheduledTask `
                    -TaskName $task.TaskName `
                    -TaskPath $task.TaskPath `
                    -ErrorAction SilentlyContinue
            ).State

            if ($state -ne 'Running') {
                return [PSCustomObject]@{
                    Software      = "Firefox"
                    Success       = $false
                    Attempts      = $attempt
                    BeforeVersion = $before.Version
                    AfterVersion  = $currentVersion
                    Message       = "Failed to start Firefox Background Update task."
                }
            }
        }

        Wait-ScheduledTaskToFinish -Task $task
        Wait-MozillaUpdaterProcess
        Start-Sleep -Seconds 3

        $after = Get-SoftwareVersion -Name "Firefox"

        if ($after.Version -eq $currentVersion) {
            $firefoxRunning = Get-Process -Name "firefox" -ErrorAction SilentlyContinue

            $message = "Firefox is up to date or no further update was applied."
            if ($firefoxRunning) {
                $message = "Firefox version did not change. Close Firefox if an update is pending."
            }

            return [PSCustomObject]@{
                Software      = "Firefox"
                Success       = -not [bool]$firefoxRunning
                Attempts      = $attempt
                BeforeVersion = $before.Version
                AfterVersion  = $after.Version
                Message       = $message
            }
        }

        $currentVersion = $after.Version
    }

    return [PSCustomObject]@{
        Software      = "Firefox"
        Success       = $false
        Attempts      = $maxAttempts
        BeforeVersion = $before.Version
        AfterVersion  = $currentVersion
        Message       = "Maximum update attempts reached."
    }
}


function Update-Software {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    switch ($Name) {

        "Chrome" {
            return Update-Chrome
        }

        "Firefox" {
            return Update-Firefox
        }

        default {
            return [PSCustomObject]@{
                Software = $Name
                Success  = $false
                Message  = "No updater is configured for this software."
            }
        }
    }
}


function Update-AllSoftware {
    param (
        [string]$ConfigPath
    )

    if (-not $ConfigPath) {
        $ConfigPath = Join-Path $PSScriptRoot '..\config\software-requirements.psd1'
    }

    if (-not (Test-Path $ConfigPath)) {
        Write-Log -Message "Configuration file was not found: $ConfigPath" -Level ERROR
        return [PSCustomObject]@{
            Success = $false
            Message = "Configuration file was not found: $ConfigPath"
        }
    }

    Write-Log -Message "Starting software updates from $ConfigPath" -Level INFO

    $requirements = Import-PowerShellDataFile $ConfigPath

    foreach ($software in $requirements.Software) {

        if ($software.Update) {
            Write-Log -Message "Updating $($software.Name)" -Level INFO

            $result = Update-Software -Name $software.Name

            if ($result.Success) {
                Write-Log -Message "$($software.Name): $($result.Message)" -Level SUCCESS
            }
            else {
                Write-Log -Message "$($software.Name): $($result.Message)" -Level ERROR
            }

            $result
        }
    }

    Write-Log -Message "Software updates finished" -Level INFO
}


Export-ModuleMember -Function `
Get-InstalledSoftware, `
Get-SoftwareVersion, `
Find-GoogleUpdater, `
Update-Chrome, `
Update-Firefox, `
Update-Software, `
Update-AllSoftware