# 1. Where Windows stores installed software

Windows has something called the Registry - hierarchical database of windows
configuration information.
```
Registry
└── Software
    └── Microsoft
        └── Windows
            └── CurrentVersion
                └── Uninstall
                    ├── Chrome
                    ├── Firefox
                    ├── ...
```
Each installed application can have properties such as
```
DisplayName
DisplayVersion
Publisher
InstallLocation
```


# 2. 32-bit and 64-bit Windows Paths