# Define variables
$ipmi_tool_directory = ""
$idrac_fqdn = ""
$idrac_username = ""
$idrac_password = ""
$nested_hosts_username = ""
$nested_hosts_password = ""
$nested_host_01_fqdn = ""
$nested_host_01_fqdn = ""
$nested_host_03_fqdn = ""
$nested_host_04_fqdn = ""
$nested_host_05_fqdn = ""
$nested_host_06_fqdn = ""
$nested_host_07_fqdn = ""
$nested_host_08_fqdn = ""

# Change directory
Write-Host "Changing to the IPMI directory" -ForegroundColor Cyan
cd $ipmi_tool_directory
Start-Sleep 2

# Step 1: Send IPMI raw command (Enable Manual Fan Mode)
Write-Host "Executing IPMI raw command to set fan mode to manual..." -ForegroundColor Yellow
try {
    .\ipmitool -I lanplus -H $idrac_fqdn -U $idrac_username -P $idrac_password raw 0x30 0x30 0x01 0x00
    Write-Host "Fan mode command sent successfully." -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to send fan mode command." -ForegroundColor Red
}
Start-Sleep 5

# Step 2: Send IPMI raw command (Set Fan speed to 10%)
Write-Host "Setting fan speed to 10%..." -ForegroundColor Yellow
try {
    .\ipmitool -I lanplus -H $idrac_fqdn -U $idrac_username -P $idrac_password raw 0x30 0x30 0x02 0xff 0xa
    Write-Host "Fan speed set successfully." -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to set fan speed." -ForegroundColor Red
}
Start-Sleep 10

# Step 3: Wait for 60 seconds before powering on the chassis
Write-Host "Waiting for 60 seconds before starting the system..." -ForegroundColor Cyan
$TotalTime = 60
for ($i = $TotalTime; $i -ge 1; $i--) {
    $PercentComplete = [math]::round((($TotalTime - $i) / $TotalTime) * 100)

    # Display the progress bar
    Write-Progress -Activity "Countdown in Progress" `
                   -Status "$i seconds remaining..." `
                   -PercentComplete $PercentComplete

    Start-Sleep 1
}

# After the loop completes, clear the progress bar
Write-Progress -Activity "Countdown in Progress" -Completed

# Step 4: Power on chassis
Write-Host "Powering on the chassis..." -ForegroundColor Yellow
try {
    .\ipmitool -I lanplus -H $idrac_fqdn -U $idrac_username -P $idrac_password chassis power on
    Write-Host "Chassis powered on successfully." -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to power on the chassis." -ForegroundColor Red
}

Write-Host "All tasks completed." -ForegroundColor Green

Write-Host "Waiting 30minutes, before an attempt to start the VMs on the nested hosts, will be made." -ForegroundColor Green

$TotalTime = 1800
for ($i = $TotalTime; $i -ge 1; $i--) {
    $PercentComplete = [math]::round((($TotalTime - $i) / $TotalTime) * 100)

    # Display the progress bar
    Write-Progress -Activity "Countdown in Progress" `
                   -Status "$i seconds remaining..." `
                   -PercentComplete $PercentComplete

    Start-Sleep 1
}

# After the loop completes, clear the progress bar
Write-Progress -Activity "Countdown in Progress" -Completed

# Defined the vSphere hosts
$vmHosts = @($nested_host_01_fqdn, $nested_host_02_fqdn, $nested_host_03_fqdn, $nested_host_04_fqdn, $nested_host_05_fqdn, $nested_host_06_fqdn, $nested_host_07_fqdn, $nested_host_08_fqdn)

# Defined credentials
$username = $nested_hosts_username
$password = $nested_hosts_password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Connect to each vSphere host
foreach ($vmHost in $vmHosts) {
    Write-Host "Connecting to $vmHost..."
    Connect-VIServer -Server $vmHost -Credential $creds

    # Get all VMs excluding those whose names start with "vCLS"
    $VMsToStart = Get-VM | Where-Object { $_.Name -notlike "vCLS*" }

    # Start each VM that is powered off
    foreach ($vm in $VMsToStart) {
        if ($vm.PowerState -eq "PoweredOff") {
            Start-VM -VM $vm
            Write-Host "Starting VM: $($vm.Name) on $vmHost"
        }
    }

    # Disconnect from the current vSphere host
    Disconnect-VIServer -Confirm:$false
    Write-Host "Disconnected from $vmHost."
}