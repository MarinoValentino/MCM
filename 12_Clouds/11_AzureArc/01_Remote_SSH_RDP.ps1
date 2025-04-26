## Arc Onboard Server
# https://aka.ms/AzureConnectedMachineAgent
azcmagent connect -s 7fe8a55f-a687-4894-817a-9792e2815909 -g p-rg-AzureArc -l switzerlandnorth

## Remote Desktop Connection (RDP) to Azure Arc-enabled Windows Server machines anywhere
## https://www.thomasmaurer.ch/2024/09/remote-desktop-connection-rdp-to-azure-arc-enabled-windows-server-machines-anywhere/

## SSH access to Azure Arc-enabled servers
## https://learn.microsoft.com/en-us/azure/azure-arc/servers/ssh-arc-overview?tabs=azure-cli

# Get started with OpenSSH for Windows i.e. VM-RDS-RRAS
# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell&pivots=windows-server-2019
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
Get-Service sshd
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd

## Install local command line tool and extension i.e. VM-RDS-RRAS
## https://www.thomasmaurer.ch/2019/07/how-to-install-azure-cli-on-windows-one-liner/
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
az extension add --name ssh

## You must also configure role assignments for the VM. Two Azure roles are used to authorize VM login:
- Virtual Machine Administrator Login: Users who have this role assigned can log in to an Azure virtual machine with administrator privileges.
- Virtual Machine User Login: Users who have this role assigned can log in to an Azure virtual machine with regular user privileges.

## Check if the HybridConnectivity subscription resource provider (RP) has been registered:
## This is a one-time operation that needs to be performed on each subscription.
az provider show -n Microsoft.HybridConnectivity -o tsv --query registrationState
# If the RP hasn't been registered, run the following:
az provider register -n Microsoft.HybridConnectivity

## Create default connectivity endpoint
# PowerShell
Invoke-AzRestMethod -Method put -Path /subscriptions/7fe8a55f-a687-4894-817a-9792e2815909/resourceGroups/p-rg-AzureArc/providers/Microsoft.HybridCompute/machines/VM-RDS-RRAS/providers/Microsoft.HybridConnectivity/endpoints/default?api-version=2023-03-15 -Payload '{"properties": {"type": "default"}}'
Invoke-AzRestMethod -Method get -Path /subscriptions/7fe8a55f-a687-4894-817a-9792e2815909/resourceGroups/p-rg-AzureArc/providers/Microsoft.HybridCompute/machines/VM-RDS-RRAS/providers/Microsoft.HybridConnectivity/endpoints/default?api-version=2023-03-15
# Az CLI
az rest --method put --uri https://management.azure.com/subscriptions/<subscription>/resourceGroups/<resourcegroup>/providers/Microsoft.HybridCompute/machines/<arc enabled server name>/providers/Microsoft.HybridConnectivity/endpoints/default?api-version=2023-03-15 --body '{\"properties\":{\"type\":\"default\"}}'
az rest --method get --uri https://management.azure.com/subscriptions/<subscription>/resourceGroups/<resourcegroup>/providers/Microsoft.HybridCompute/machines/<arc enabled server name>/providers/Microsoft.HybridConnectivity/endpoints/default?api-version=2023-03-15

## Enable functionality on your Arc-enabled server
az rest --method put --uri https://management.azure.com/subscriptions/7fe8a55f-a687-4894-817a-9792e2815909/resourceGroups/p-rg-AzureArc/providers/Microsoft.HybridCompute/machines/VM-RDS-DC/providers/Microsoft.HybridConnectivity/endpoints/default/serviceconfigurations/SSH?api-version=2023-03-15 --body '{"properties": {"serviceName": "SSH", "port": 22}}'
az rest --method get --uri https://management.azure.com/subscriptions/7fe8a55f-a687-4894-817a-9792e2815909/resourceGroups/p-rg-AzureArc/providers/Microsoft.HybridCompute/machines/VM-RDS-DC/providers/Microsoft.HybridConnectivity/endpoints/default/serviceconfigurations/SSH?api-version=2023-03-15

## Optional: Install Azure AD login extension (Linux only)
az connectedmachine extension create --machine-name VM-RDS-RRAS --resource-group p-rg-AzureArc --publisher Microsoft.Azure.ActiveDirectory --name AADSSHLogin --type AADSSHLoginForLinux --location switzerlandnorth 

### Connect with:
az login
az ssh arc --resource-group p-rg-AzureArc --vm-name VM-RDS-SRV2025 --local-user rds\administrator --rdp
