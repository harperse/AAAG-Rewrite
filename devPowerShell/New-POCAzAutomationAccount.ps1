$hubResources.Add("AutomationAccount", $(New-AzAutomationAccount `
            -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
            -Location $alaToaaaMap[$selectedHubRegionCode].aaa `
            -Name $hubProperties.automationAccountName `
            -Plan $hubProperties.automationAccountPlan `
            -AssignSystemIdentity `
            -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
    )
)

foreach ($runbookModule in $runbookModules) {
    Import-AzAutomationModule `
        -ResourceGroupName $hubResources.ResourceGroup.ResourceGroupName `
        -AutomationAccountName $hubProperties.aaName `
        -Name $runbookModule
}

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