# Check if fast boot is enabled
$FastBootEnabled = (Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -ErrorAction SilentlyContinue)

if ($FastBootEnabled -eq $null) {
    Write-Output "Fast boot status: Not found"
} elseif ($FastBootEnabled -eq 0) {
    Write-Output "Fast boot status: Disabled"
} elseif ($FastBootEnabled -eq 1) {
    Write-Output "Fast boot status: Enabled"
} else {
    Write-Output "Fast boot status: Unknown"
}

# Get the last boot time
$LastReboot = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime

# Get the last boot time from event logs
$BootEvent = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot' | Where-Object {$_.ID -eq 27}
if ($BootEvent -ne $null) {
    $LastBoot = $BootEvent[0].TimeCreated
} else {
    $LastBoot = $null
}

# Determine the correct uptime
if ($LastBoot -eq $null) {
    $Uptime = $LastReboot
} else {
    $Uptime = [System.Math]::Max($LastReboot, $LastBoot)
}

# Calculate the uptime duration
$UptimeDuration = (Get-Date) - $Uptime
$Days = $UptimeDuration.Days
$Hours = $UptimeDuration.Hours
$Minutes = $UptimeDuration.Minutes

# Display the results
Write-Output "Uptime: $Days day(s), $Hours hour(s), $Minutes minute(s)"
