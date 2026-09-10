Rather than have one .ps1 file, a toolkit will eventually have several functions, and
we do not want one enormous file with 500+ lines of code.

# What is a module
A module is a container for related powershell functions.
```
example

math_utils.py
    ├── add()
    ├── subtract()
    └── multiply()
```

# Eventually
```
modules/
│
├── WorkstationInfo.psm1
│      └── Get-WorkstationInfo
│
├── SoftwareManagement.psm1
│      ├── Get-InstalledSoftware
│      ├── Compare-SoftwareVersion
│      └── Update-Software
│
├── Validation.psm1
│      ├── Test-Memory
│      ├── Test-DiskSpace
│      └── Test-WorkstationReadiness
│
└── Logging.psm1
       └── Write-Log
```
Then our main script becomes an orchestrator


# Export-ModuleMember
- If our .psm1 contains several functions, Powershell can potentially expose all of them
when you import the module.
- For a real toolkit, we want to ensure that these are the functions this module is
allowed to provide to the rest of the project.
```
function Get-WorkstationInfo {
    # ...
}

function Get-RawComputerInfo {
    # internal helper
}

Export-ModuleMember -Function Get-WorkstationInfo


Then Import-Module ..\modules\WorkstationInfo.psm1
makes Get-WorkstationInfo available, while Get-RawComputerInfo is kept internal.

```