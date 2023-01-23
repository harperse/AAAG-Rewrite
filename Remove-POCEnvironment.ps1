$pocResources = Get-AzResource -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
Write-Output "Removing $($pocResources.Count) resources"

foreach ($pocResource in $pocResources) {
    Write-Output "Removing $($pocResource.ResourceGroupName)/$($pocResource.ResourceName)"
    Remove-AzResource -ResourceId $pocResource.Id -Force | Out-Null
}

$pocResourceGroups = Get-AzResourceGroup -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
Write-Output "Removing $($pocResourceGroups.Count) resource groups"
foreach ($pocResourceGroup in $pocResourceGroups) {
    Write-Output "Removing $($pocResourceGroup.ResourceGroupName)"
    Remove-AzResourceGroup -Name $pocResourceGroup.ResourceGroupName -Force | Out-Null
}

$pocResourcesAfter = Get-AzResource -Tag @{ $globalProperties.tagKey = $globalProperties.tagValue }
Write-Output "Removed $($pocResources.Count - $pocResourcesAfter.Count) resources"