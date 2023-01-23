# Create automation account
Import-Module Az.Automation
Write-Output "Creating automation account $($global:hubProperties.automationAccountName) in $($alaToaaaMap[$selectedHubRegionCode].aaa)..."
$global:hubResources.Add("AutomationAccount", $(New-AzAutomationAccount `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -Location $alaToaaaMap[$selectedHubRegionCode].aaa `
            -Name $global:hubProperties.automationAccountName `
            -Plan $global:hubProperties.automationAccountPlan `
            -AssignSystemIdentity `
            -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }
    )
)

# Add modules to automation account
Write-Output "Adding modules to automation account $($global:hubProperties.automationAccountName)..."
foreach ($runbookModule in $runbookModules.GetEnumerator()) {
    if (!(Get-AzAutomationModule -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName -AutomationAccountName $global:hubProperties.aaName -Name $runbookModule.Name -ErrorAction SilentlyContinue)) 
    {
        Write-Output "Adding module $($runbookModule.Name)..."
        Import-AzAutomationModule `
            -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
            -AutomationAccountName $global:hubProperties.aaName `
            -Name $runbookModule.Name `
            -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$($runbookModule.Name)/$($runbookModule.Value)"
    }
}

# Add runbooks to automation account
Write-Output "Adding runbooks to automation account $($global:hubProperties.automationAccountName)..."
$aaStartSchedule = $global:hubProperties.aaStartSchedule
New-AzAutomationSchedule @aaStartSchedule `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

$aaStopSchedule = $global:hubProperties.aaStopSchedule
New-AzAutomationSchedule @aaStopSchedule `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

$aaStartRunbook = $global:hubProperties.aaStartRunbook
Import-AzAutomationRunbook @aaStartRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

Register-AzAutomationScheduledRunbook @aaStartRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

$aaStopRunbook = $global:hubProperties.aaStopRunbook
Import-AzAutomationRunbook @aaStopRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }

Register-AzAutomationScheduledRunbook @aaStopRunbook `
    -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $global:hubProperties.aaName `
    -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }