# IPMI and vSphere Automation Script

This PowerShell script automates the process of controlling fan speed and powering on a chassis via IPMI, followed by starting virtual machines (VMs) on nested vSphere hosts. The script performs a series of steps, including sending IPMI raw commands, waiting for specific intervals, and starting VMs that are powered off on vSphere hosts.

## Features

- Set manual fan mode on the chassis using IPMI.
- Control fan speed to 10% via IPMI raw commands.
- Power on the chassis after a brief countdown.
- Connect to nested vSphere hosts and start powered-off VMs (excluding `vCLS` VMs).
  
## Requirements

- **PowerShell** (This script is written in PowerShell)
- **ipmitool**: A utility to send IPMI commands to the chassis.
- **VMware PowerCLI**: For managing vSphere hosts and starting VMs.

# Script Variables:

$ipmi_tool_directory = ""       # Path to the ipmitool directory
$idrac_fqdn = ""                # iDRAC fully qualified domain name
$idrac_username = ""            # iDRAC username
$idrac_password = ""            # iDRAC password

$nested_hosts_username = ""     # Username for nested vSphere hosts
$nested_hosts_password = ""     # Password for nested vSphere hosts

## FQDNs for nested vSphere hosts (replace with actual FQDNs of each host)
$nested_host_01_fqdn = ""
$nested_host_02_fqdn = ""
$nested_host_03_fqdn = ""
$nested_host_04_fqdn = ""
$nested_host_05_fqdn = ""
$nested_host_06_fqdn = ""
$nested_host_07_fqdn = ""
$nested_host_08_fqdn = ""
