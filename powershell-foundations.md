# Cmdlets and Objects

Powershell commands generally produce objects, not just plain text
```
$computerInfo = Get-ComputerInfo

$computerInfo.CsTotalPhysicalMemory
```

# Pipeline |
This passes objects from one command to another
```
Get-ComputerInfo | Select-Object WindowsVersion
```

# PSCustomObject
This creates a own structured object
```
[PSCustomObject]@{
    ComputerName = $ComputerName
    MemoryGB     = 16
    Architecture = "64-bit"
}
```

# Parameters
This allows functions to accept inputs
```
function Get-WorkstationInfo {
  param (
      [string]$ComputerName
  )
}

Calling function with input: Get-WorkstationInfo -ComputerName "PC-001"
```

# Where-Object
Used to filter objects
```
Given: $computers

$computers | Where-Object MemoryGB -lt 8
```

# ForEach-Object
Used to perform an operation on each object in the pipeline
```
$computers | ForEach-Object {
  Write-Host $_.ComputerName
}

$_ means the current object
```


# Boolean Logic
- -and
- -or
- -not


# try / catch
Used for handling errors
```
TRY
 ↓
Did it work?
 ↙       ↘
YES       NO
 ↓         ↓
continue  catch
```

# Logging
```
function Write-Log {
    param (
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logMessage = "$timestamp | $Message"

    Add-Content -Path "logs\workstation.log" -Value $logMessage
}
```


# Next up is Modules for organization
```
workstation-toolkit/
│
├── scripts/
│   ├── Get-WorkstationInfo.ps1
│   ├── Test-WorkstationReadiness.ps1
│   ├── Test-Software.ps1
│   └── Update-Software.ps1
│
├── config/
│   └── requirements.psd1
│
├── logs/
│   └── workstation.log
│
├── tests/
│
└── README.md
```