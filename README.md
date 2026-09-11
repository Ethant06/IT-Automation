# Workstation Provisioning & Validation Toolkit

A PowerShell-based toolkit for automating workstation setup, software updates, system information collection, and operational logging.

## Overview

This project automates repetitive workstation onboarding and maintenance tasks that would otherwise require manual verification.

The toolkit currently:

* Collects workstation information
* Detects installed software through Windows Registry entries
* Checks installed software versions
* Triggers approved Chrome and Firefox update mechanisms
* Verifies software versions after update attempts
* Records operations and results to a log file
* Produces a final workstation readiness report

## Project Structure

```text
workstation-toolkit/
├── modules/
│   ├── WorkstationInfo.psm1
│   ├── SoftwareManagement.psm1
│   └── Logging.psm1
├── scripts/
│   ├── Invoke-WorkstationSetup.ps1
│   └── Test-Toolkit.ps1
├── config/
│   └── software-requirements.psd1
├── logs/
├── tests/
└── README.md
```

## How It Works

The master provisioning script coordinates the workflow:

```text
Invoke-WorkstationSetup.ps1
        │
        ├── Collect workstation information
        │
        ├── Read software requirements
        │
        ├── Update Chrome
        │
        ├── Update Firefox
        │
        ├── Record results
        │
        └── Generate readiness report
```

## Running the Toolkit

Open PowerShell from the project root:

```powershell
.\scripts\Invoke-WorkstationSetup.ps1
```

The script displays a final report containing workstation information and software update results.

Example:

```text
========== WORKSTATION SETUP REPORT ==========

Computer: WORKSTATION-01
Windows:  Windows 11
Memory:   16 GB

Chrome:
  Before:  153.0.8010.37
  After:   153.0.8010.37
  Success: True

Firefox:
  Before:  ...
  After:   ...
  Success: True

STATUS: READY
```

## Configuration

Software managed by the toolkit is defined in:

```text
config/software-requirements.psd1
```

Example:

```powershell
@{
    Software = @(
        @{
            Name = "Chrome"
            Update = $true
        },
        @{
            Name = "Firefox"
            Update = $true
        }
    )
}
```

This allows software update behavior to be controlled through configuration rather than hard-coding every software requirement into the master script.

## Logging

Operations are written to:

```text
logs/workstation-toolkit.log
```

## Requirements

* Windows
* Windows PowerShell 5.1 or PowerShell 7+
* Administrator privileges may be required for certain workstation operations
* Chrome and/or Firefox installed for their respective update workflows

## Design

The toolkit is organized into separate PowerShell modules so that workstation information, software management, and logging responsibilities remain independent.

The master script acts as the orchestration layer rather than containing the implementation details for each operation.

## Current Scope

Currently supported software:

* Google Chrome
* Mozilla Firefox

