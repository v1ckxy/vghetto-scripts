# William Lam
# www.virtuallygheto.com
# Using Guest Operations API to invoke command inside of Nested ESXi VM

Function runGuestOpInESXiVM() {
	param(
		$vm_moref,
		$guest_username, 
		$guest_password,
		$guest_command_path,
		$guest_command_args
	)
	
	# Guest Ops Managers
	$guestOpMgr = Get-View $session.ExtensionData.Content.GuestOperationsManager
	$authMgr = Get-View $guestOpMgr.AuthManager
	$procMgr = Get-View $guestOpMgr.processManager
	
	# Create Auth Session Object
	$auth = New-Object VMware.Vim.NamePasswordAuthentication
	$auth.username = $guest_username
	$auth.password = $guest_password
	$auth.InteractiveSession = $false
	
	# Program Spec
	$progSpec = New-Object VMware.Vim.GuestProgramSpec
	# Full path to the command to run inside the guest
	$progSpec.programPath = "$guest_command_path"
	$progSpec.workingDirectory = "/tmp"
	# Arguments to the command path, must include "++goup=host/vim/tmp" as part of the arguments
	$progSpec.arguments = "++group=host/vim/tmp $guest_command_args"
	
	# Issue guest op command
	$cmd_pid = $procMgr.StartProgramInGuest($vm_moref,$auth,$progSpec)
}

$session = Connect-VIServer -Server 192.168.1.60 -User administrator@vghetto.local -Password VMware1!

$esxi_vm = 'Nested-ESXi6'
$esxi_username = 'root'
$esxi_password = 'vmware123'

$vm = Get-VM $esxi_vm

# commands to run inside of Nested ESXi VM
$command_path = '/bin/python'
$command_args = '/bin/esxcli.py system welcomemsg set -m "vGhetto Was Here"'

Write-Host
Write-Host "Invoking command:" $command_path $command_args "to" $esxi_vm
Write-Host
runGuestOpInESXiVM -vm_moref $vm.ExtensionData.MoRef -guest_username $esxi_username -guest_password $esxi_password -guest_command_path $command_path -guest_command_args $command_args

Disconnect-VIServer -Server $session -Confirm:$false