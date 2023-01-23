[Parameter(Mandatory = $true)][ParameterSet("Hub", "Spoke")][string]$HubOrSpoke


if ($HubOrSpoke -eq "Hub") {
    # Create the Jumpbox VM
    $nicIPConfigJMP = New-AzNetworkInterfaceIpConfig `
        -Name $global:hubProperties.NICIPConfigNameJMP `
        -SubnetId $global:hubResources.SubnetJMP.Id `
        -PrivateIpAddress $global:hubResources.JMPPrivateIPAddress `
        -PublicIpAddressId $global:hubResources.PubIPJMP.Id `
        -PrivateIpAddressVersion IPv4 `
        -Primary `
        -AsJob

    $nicConfigJMP = New-AzNetworkInterface `
        -Name $global:hubProperties.NICNameJMP `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -Location $global:hubResources.ResourceGroup.Location `
        -IpConfigurationName $nicIPConfigJMP `
        -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
        -AsJob

    $osDiskConfigJMP = New-AzDiskConfig `
        -SkuName $global:globalProperties.storageAccountSkuName `
        -Location $global:hubResources.ResourceGroup.Location `
        -CreateOption $global:hubProperties.JMPOSDiskCreateOption `
        -DiskSizeGB $global:hubProperties.JMPOSDiskSizeGB `
        -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
        -AsJob

    $dataDiskConfigJMP = New-AzDiskConfig `
        -SkuName $global:globalProperties.storageAccountSkuName `
        -Location $global:hubResources.ResourceGroup.Location `
        -CreateOption $global:hubProperties.JMPDataDiskCreateOption `
        -DiskSizeGB $global:hubProperties.JMPDataDiskSizeGB `
        -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
        -AsJob

    $vmConfigJMP = New-AzVMConfig `
        -VMName $global:hubProperties.JMPVMName `
        -VMSize $global:globalProperties.vmSize `
        -Tags @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `

    $vmConfigJMP = Add-AzNetworkInterface `
        -VM $vmConfigJMP `
        -Id $nicConfigJMP.Id

    $vmConfigJMP = Set-AzVMOSDisk `
        -VM $vmConfigJMP `
        -Name $global:hubProperties.JMPOSDiskName `
        -Disk $osDiskConfigJMP `
        -Caching ReadWrite `
        -CreateOption $global:hubProperties.JMPOSDiskCreateOption `
        -Windows

    $vmConfigJMP = Add-AzVMDataDisk `
        -VM $vmConfigJMP `
        -Name $global:hubProperties.JMPDataDiskName `
        -Disk $dataDiskConfigJMP

    $global:hubResources.Add("VMJMP", $(New-AzVM `
                -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                -Location $global:hubResources.ResourceGroup.Location `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:hubResources.Vnet.Name `
                -Credential $credential `
                -VM $vmConfigJMP `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )
}
else {
    # Create the domain controller
    $global:spokeResources.Add("VMADC", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameADC `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameADC `
                -AvailabilitySetName $global:spokeResources.AVSetADC.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )

    # Create the web servers
    $global:spokeResources.Add("VMWeb1", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameWeb1 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetWeb.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMWeb2", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameWeb2 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetWeb.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMSQL1", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameSQL1 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetSQL.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMSQL2", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameSQL2 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetSQL.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMLNX", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameLNX `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetLNX.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMDEV", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameDEV `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetDEV.Name `
                -Tag @{ $global:globalProperties.TagName = $global:globalProperties.TagValue } `
                -AsJob
        )
    )
}