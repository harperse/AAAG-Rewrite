# Create automation account
Write-Output "Creating automation account $($hubProperties.automationAccountName) in $($alaToaaaMap[$selectedHubRegionCode].aaa)..."
$hubResources.Add("AutomationAccount", $(New-AzAutomationAccount `
            -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
            -Location $alaToaaaMap[$selectedHubRegionCode].aaa `
            -Name $hubProperties.automationAccountName `
            -Plan $hubProperties.automationAccountPlan `
            -AssignSystemIdentity `
            -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    )
)

# Add modules to automation account
Write-Output "Adding modules to automation account $($hubProperties.automationAccountName)..."
foreach ($runbookModule in $runbookModules.GetEnumerator()) {
    if (!(Get-AzAutomationModule -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName -AutomationAccountName $hubProperties.aaName -Name $runbookModule.Name -ErrorAction SilentlyContinue)) 
    {
        Write-Output "Adding module $($runbookModule.Name)..."
        Import-AzAutomationModule `
            -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
            -AutomationAccountName $hubProperties.aaName `
            -Name $runbookModule.Name `
            -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$($runbookModule.Name)/$($runbookModule.Value)"
    }
}

# Add runbooks to automation account
Write-Output "Adding runbooks to automation account $($hubProperties.automationAccountName)..."
$aaStartSchedule = $hubProperties.aaStartSchedule
New-AzAutomationSchedule @aaStartSchedule `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

$aaStopSchedule = $hubProperties.aaStopSchedule
New-AzAutomationSchedule @aaStopSchedule `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

$aaStartRunbook = $hubProperties.aaStartRunbook
Import-AzAutomationRunbook @aaStartRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Register-AzAutomationScheduledRunbook @aaStartRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

$aaStopRunbook = $hubProperties.aaStopRunbook
Import-AzAutomationRunbook @aaStopRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }

Register-AzAutomationScheduledRunbook @aaStopRunbook `
    -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
    -AutomationAccountName $hubProperties.aaName `
    -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }