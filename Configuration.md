# Configuration File psd1 file - powershell data file

### Example
```
@{
    Software = @(
        @{
            Name = "Chrome"
            RequiredVersion = "153.0.0.0"
        },
        @{
            Name = "Firefox"
            RequiredVersion = "142.0.0.0"
        },
        @{
            Name = "Microsoft Edge"
            RequiredVersion = "140.0.0.0"
        }
    )
}
```

### Without configuration:
```
Test-SoftwareUpdated -Name "Chrome" -RequiredVersion "153.0.0.0"
Test-SoftwareUpdated -Name "Firefox" -RequiredVersion "142.0.0.0"
Test-SoftwareUpdated -Name "Microsoft Edge" -RequiredVersion "140.0.0.0"
```
That is not Ideal

### With configuration
```
Read requirements
       ↓
Loop through software
       ↓
Check each one
       ↓
Produce results
```
So if IT changes chrome from 153.0.0.0 to 154.0.0.0, then we can simply change the config,
not the actual automatin logic code.