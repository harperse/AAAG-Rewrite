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
        -ResourceGroupName $global:hubResources.ResourceGroup.Name `
        -Location $global:hubResources.ResourceGroup.Location `
        -IpConfigurationName $nicIPConfigJMP `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $osDiskConfigJMP = New-AzDiskConfig `
        -SkuName $global:globalProperties.storageAccountSkuName `
        -Location $global:hubResources.ResourceGroup.Location `
        -CreateOption $global:hubProperties.JMPOSDiskCreateOption `
        -DiskSizeGB $global:hubProperties.JMPOSDiskSizeGB `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $dataDiskConfigJMP = New-AzDiskConfig `
        -SkuName $global:globalProperties.storageAccountSkuName `
        -Location $global:hubResources.ResourceGroup.Location `
        -CreateOption $global:hubProperties.JMPDataDiskCreateOption `
        -DiskSizeGB $global:hubProperties.JMPDataDiskSizeGB `
        -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
        -AsJob

    $vmConfigJMP = New-AzVMConfig `
        -VMName $global:hubProperties.JMPVMName `
        -VMSize $global:globalProperties.vmSize `
        -Tags @{ $globalResources.TagName = $globalResources.TagValue } `

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
                -ResourceGroupName $global:hubResources.ResourceGroup.Name `
                -Location $global:hubResources.ResourceGroup.Location `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:hubResources.Vnet.Name `
                -Credential $credential `
                -VM $vmConfigJMP `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )
}
else {
    # Create the domain controller
    $global:spokeResources.Add("VMADC", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameADC `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameADC `
                -AvailabilitySetName $global:spokeResources.AVSetADC.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    # Create the web servers
    $global:spokeResources.Add("VMWeb1", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameWeb1 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetWeb.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMWeb2", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameWeb2 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetWeb.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMSQL1", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameSQL1 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetSQL.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMSQL2", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameSQL2 `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetSQL.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMLNX", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameLNX `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetLNX.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )

    $global:spokeResources.Add("VMDEV", $(New-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.Name `
                -Location $global:spokeResources.ResourceGroup.Location `
                -Name $global:spokeProperties.vmNameDEV `
                -Size $global:globalProperties.vmSize `
                -Image $global:globalProperties.vmImage `
                -VirtualNetworkName $global:spokeResources.Vnet.Name `
                -Credential $global:credential `
                -SubnetName $global:spokeProperties.SubnetNameSRV `
                -AvailabilitySetName $global:spokeResources.AVSetDEV.Name `
                -Tag @{ $globalResources.TagName = $globalResources.TagValue } `
                -AsJob
        )
    )
}