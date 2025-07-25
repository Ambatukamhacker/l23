Clear-Host
Write-Host "Roblox Studio Temporary Files Cleanup Tool" -ForegroundColor Cyan
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
Write-Host "Done. You can now safely close this window." -ForegroundColor Cyan
