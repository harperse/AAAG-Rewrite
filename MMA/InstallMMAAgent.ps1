#Login to Azure using PowerShell
Login-AzAccount

#Get list of subscriptions associated with the account
Get-AzSubscription 
Select-AzSubscription -SubscriptionID "Paste the subscription ID here"
$VM = "<VM Name>" #VM Name goes here
$RG = "<Resource Group Name where the VM is located>" #RG Name goes here
Get-AzVM -ResourceGroupName $RG -VMName $VM
$PublicSettings = @{"workspaceId" = "myWorkspaceId"} #Workspace ID goes here
$ProtectedSettings = @{"workspaceKey" = "myWorkspaceKey"} #workspace Key goes here

Set-AzVMExtension -ExtensionName "Microsoft.EnterpriseCloud.Monitoring" `
    -ResourceGroupName $RG `
    -VMName $VM `
    -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
    -ExtensionType "MicrosoftMonitoringAgent" `
    -TypeHandlerVersion 1.0 `
    -Settings $PublicSettings `
    -ProtectedSettings $ProtectedSettings `
    -Location WestUS
