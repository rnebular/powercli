# Script to update a cluster DRS rule specific to Operating System version. It will check and add all VM's that
# match the OS condition to a DRS VM Group

# Prerequisites to run this script
# PowerCLI 6.x, prefer 6.5.1 or newer
# Powershell module "DRSRule", http://www.lucd.info/2015/01/22/drsrule-drs-rules-and-groups-module/

# Get user input
$clustername = Read-Host "What cluster should I update?"

# Set rulename variables
$winrulename = "$clustername"+"-"+"windows"
$linuxrulename = "$clustername"+"-"+"linux"

# UPDATE DRS RULE FUNCTION
function DRSrule {
param (
   $cluster,
   $VMs,
   $groupVMName)
   $cluster = Get-Cluster $cluster
   $spec = New-Object VMware.Vim.ClusterConfigSpecEx
   $groupVM = New-Object VMware.Vim.ClusterGroupSpec
   $groupVM.operation = "edit"
#Operation edit will replace the contents of the GroupVMName with the new contents selected below.
   $groupVM.Info = New-Object VMware.Vim.ClusterVmGroup
   $groupVM.Info.Name = $groupVMName
   Get-VM $VMs | %{
$groupVM.Info.VM += $_.Extensiondata.MoRef
   }
   $spec.GroupSpec += $groupVM
   #Apply the settings to the cluster
   $cluster.ExtensionData.ReconfigureComputeResource($spec,$true)
   }
# END OF DRS RULE FUNCTION


# BEGIN EXECUTION


# Get master list of VM's from the Cluster with matching Operating System version
Write-Output "Gathering list of Windows VM's"
$winvms = Get-Cluster $clustername | Get-VM | where GuestId -like "windows*" | where PowerState -eq PoweredOn

Write-Output "Gathering list of Non-Windows VM's"
$linuxvms = Get-Cluster $clustername | Get-VM | where GuestId -lt "windows" | where PowerState -eq PoweredOn

# Creating the DRS Groups. Had logic to check first, but this will just error with "already exists" and move on.
Write-Host "Creating DRS Group for Windows VM's"
New-DrsVMGroup -Name $winrulename -VM $winvms[0] -Cluster $clustername
Write-Host "Creating DRS Group for Non-Windows VM's"
New-DrsVMGroup -Name $linuxrulename -VM $linuxvms[0] -Cluster $clustername

# Update DRS rules
Write-Output "Stand by, updating the DRS Group membership for $clustername"
DRSrule -cluster $clustername -VMs $linuxvms -groupVMName $linuxrulename
DRSrule -cluster $clustername -VMs $winvms -groupVMName $winrulename
