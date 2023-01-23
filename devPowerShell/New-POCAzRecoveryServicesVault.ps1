# Create recovery services vault
Import-Module Az.RecoveryServices
Write-Output "Creating recovery services vault $($global:spokeProperties.rsvName) in $($global:spokeResources.ResourceGroup.Name)..."
$global:spokeResources.Add("RSV", $(New-AzRecoveryServicesVault `
            -Name $global:spokeProperties.rsvName `
            -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
            -Location $global:spokeResources.ResourceGroup.Location `
            -Tag @{ $global:globalProperties.tagKey = $global:globalProperties.tagValue }
    )
)