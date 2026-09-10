# Cmdlets and Objects

Powershell commands generally produce objects, not just plain text
```
$computerInfo = Get-ComputerInfo

$computerInfo.CsTotalPhysicalMemory
```

# Pipeline |
This passes objects from one command to another