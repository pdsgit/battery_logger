# This targets the Desktop folder of whoever is running the script
$OutputFile = "$HOME\Desktop\battery_logger\battery_log.csv"

# Create the folder if it doesn't exist
$logFolder = Split-Path $OutputFile
if (-not (Test-Path $logFolder)) { New-Item -Path $logFolder -ItemType Directory }

# Add CSV header if the file doesn't exist
if (-not (Test-Path $OutputFile)) {
    "Timestamp,Percentage,Charger_Connected" | Out-File -FilePath $OutputFile -Encoding utf8
}

Write-Host "Logging started. Saving to: $OutputFile"
Write-Host "Close window to stop."

while ($true) {
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop
        
        if ($null -ne $battery) {
            $isCharging = if ($battery.BatteryStatus -eq 2 -or ($battery.BatteryStatus -ge 6 -and $battery.BatteryStatus -le 9)) { "Yes" } else { "No" }
            $percent = "$($battery.EstimatedChargeRemaining)%"

            "$timestamp,$percent,$isCharging" | Add-Content -Path $OutputFile
        }
    }
    catch {
        Write-Warning "Waiting for battery service..."
    }

    Start-Sleep -Seconds 5
}