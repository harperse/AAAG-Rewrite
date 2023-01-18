[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke
$credential = [credential]::new($globalProperties.vmAdminUserName, $vmAdminPassword)

if ($HubOrSpoke -eq "Hub") {
    $Image = Get-AzVMImage -Location $hubResources.ResourceGroup.Location -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition-smalldisk" -Version "20348.1487.230106" | Select-Object -First 1 | Out-Null
    
    # Create the Jumpbox VM
    $nicIPConfigJMP = New-AzNetworkInterfaceIpConfig `
        -Name $hubProperties.NICIPConfigNameJMP `
        -SubnetId $hubResources.SubnetJMP.Id `
        -PrivateIpAddress $hubResources.JMPPrivateIPAddress `
        -PublicIpAddressId $hubResources.PubIPJMP.Id `
        -PrivateIpAddressVersion IPv4 `
        -Primary `
        -AsJob

    $nicConfigJMP = New-AzNetworkInterface `
        -Name $hubProperties.NICNameJMP `
        -ResourceGroupName $hubResources.ResourceGroup.Name `
        -Location $hubResources.ResourceGroup.Location `
        -IpConfigurationName $nicIPConfigJMP
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $osDiskConfigJMP = New-AzDiskConfig `
        -SkuName $globalProperties.storageAccountSkuName `
        -Location $hubResources.ResourceGroup.Location `
        -CreateOption $hubProperties.JMPOSDiskCreateOption `
        -DiskSizeGB $hubProperties.JMPOSDiskSizeGB `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $dataDiskConfigJMP = New-AzDiskConfig `
        -SkuName $globalProperties.storageAccountSkuName `
        -Location $hubResources.ResourceGroup.Location `
        -CreateOption $hubProperties.JMPDataDiskCreateOption `
        -DiskSizeGB $hubProperties.JMPDataDiskSizeGB `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $vmConfigJMP = New-AzVMConfig `
        -VMName $hubProperties.JMPVMName `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $hubResources.Vnet.Name `
        -SubnetName $hubProperties.SubnetNameJMP `
        -PublicIpAddressName $hubResources.PIPJMP.Name `
        -OpenPorts $hubResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue } `

    $vmConfigJMP = Add-AzNetworkInterface `
        -VM $vmConfigJMP `
        -Id $nicConfigJMP.Id

    $vmConfigJMP = Set-AzVMOSDisk `
        -VM $vmConfigJMP `
        -Name $hubProperties.JMPOSDiskName `
        -Disk $osDiskConfigJMP `
        -Caching ReadWrite `
        -Windows

    $vmConfigJMP = Add-AzVMDataDisk `
        -VM $vmConfigJMP `
        -Name $hubProperties.JMPDataDiskName `
        -Disk $dataDiskConfigJMP `

    New-AzVM `
        -ResourceGroupName $hubResources.ResourceGroup.Name `
        -Location $hubResources.ResourceGroup.Location `
        -VM $vmConfigJMP `
        -AsJob

    $hubResources.VMJMP = Get-AzVM `
        -Name $hubProperties.JMPVMName `
        -ResourceGroupName $hubResources.ResourceGroup.Name

}
else {
    # Create the domain controller
    $vmConfigADC = New-AzVMConfig `
        -VMName $spokeProperties.vmNameADC `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameADC `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -AvailabilitySetId $spokeResources.AVSetADC.Id `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue } 

    $vmConfigADC | New-AzVM -AsJob

    $spokeResources.VMADC = Get-AzVM `
        -Name $spokeProperties.vmNameADC `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    # Create the web server 1
    $vmConfigWES1 = New-AzVMConfig `
        -VMName $spokeProperties.vmNameWES1 `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameWES `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -AvailabilitySetId $spokeResources.AVSetWES.Id `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue }

    $vmConfigWES1 | New-AzVM -AsJob

    $spokeResources.VMWES1 = Get-AzVM `
        -Name $spokeProperties.vmNameWES1 `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $vmConfigWES2 = New-AzVMConfig `
        -VMName $spokeProperties.vmNameWES2 `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameWES `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -AvailabilitySetId $spokeResources.AVSetWES.Id `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue }

    $vmConfigWES2 | New-AzVM -AsJob

    $spokeResources.VMWES2 = Get-AzVM `
        -Name $spokeProperties.vmNameWES2 `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $vmConfigSQL1 = New-AzVMConfig `
        -VMName $spokeProperties.vmNameSQL1 `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameSQL `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -AvailabilitySetId $spokeResources.AVSetSQL.Id `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue }

    $vmConfigSQL1 | New-AzVM -AsJob

    $spokeResources.VMSQL1 = Get-AzVM `
        -Name $spokeProperties.vmNameSQL1 `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $vmConfigSQL2 = New-AzVMConfig `
        -VMName $spokeProperties.vmNameSQL2 `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameSQL `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -AvailabilitySetId $spokeResources.AVSetSQL.Id `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue }

    $vmConfigSQL2 | New-AzVM -AsJob

    $spokeResources.VMSQL2 = Get-AzVM `
        -Name $spokeProperties.vmNameSQL2 `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $vmConfigDEV = New-AzVMConfig `
        -VMName $spokeProperties.vmNameDEV `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameDEV `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -AvailabilitySetId $spokeResources.AVSetDEV.Id `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue }

    $vmConfigDEV | New-AzVM -AsJob

    $spokeResources.VMDEV = Get-AzVM `
        -Name $spokeProperties.vmNameDEV `
        -ResourceGroupName $spokeResources.ResourceGroup.Name

    $vmConfigLNX = New-AzVMConfig `
        -VMName $spokeProperties.vmNameLNX `
        -VMSize $globalProperties.vmSize `
        -VirtualNetworkName $spokeResources.Vnet.Name `
        -SubnetName $spokeProperties.SubnetNameLNX `
        -OpenPorts $spokeResources.OpenPorts `
        -Image $Image `
        -Credential $credential `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue }
    
    $vmConfigLNX | New-AzVM -AsJob

    $spokeResources.VMLNX = Get-AzVM `
        -Name $spokeProperties.vmNameLNX `
        -ResourceGroupName $spokeResources.ResourceGroup.Name
}