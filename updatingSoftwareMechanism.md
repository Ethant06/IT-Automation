# Update-Software
This function will eventually take something like
```
Update-Software -Name "Chrome"

and perform the approved update mechanism for that application
```

# Workflow
```
Chrome installed?
       ↓
Version sufficient?
   ↙         ↘
 YES          NO
  ↓            ↓
Done      Update Chrome
               ↓
        Check version again
               ↓
          Update succeeded?
```


# Powershell Concept

Powershell can launch another program with:
```
Start-Process

Example

Start-Process "notepad.exe"

Powershell starts the program and immediately continues. If we need our script to wait until the program finishes, we use

Start-Process "notepad.exe" -Wait
```
When we run that command, Notepad should open. If we leave it open for a moment, our powershell prompt will wait. Once we close notepad
then our powershell will return to the prompt.


# Process Object
```
$process = Start-Process "notepad.exe" -PassThru
```
Running this will get a process object back with properties like Id and ProcessName.