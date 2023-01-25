[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][ValidateSet("Hub", "Spoke")][string]$HubOrSpoke
)

Import-Module -Name Az.Compute -Force
if ($HubOrSpoke -eq "Hub") {
    # Create the Jumpbox VM
    # Create the NIC for the Jumpbox VM
    $nicIPConfigJMP1 = New-AzNetworkInterfaceIpConfig `
        -Name $global:hubProperties.NICIPConfigNameJMP1 `
        -Subnet $global:hubResources.SubnetJMP `
        -PrivateIpAddress $global:hubResources.JMPPrivateIPAddress `
        -PrivateIpAddressVersion IPv4 `
        -Primary
         
    $nicIPConfigJMP2 = New-AzNetworkInterfaceIpConfig `
        -Name $hubProperties.NICIPConfigNameJMP2 `
        -Subnet $global:hubResources.SubnetJMP `
        -PublicIpAddress $global:hubResources.PubIPJMP 

    $nicConfigJMP = New-AzNetworkInterface `
        -Name $global:hubProperties.JMPNicName `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -Location $global:hubResources.ResourceGroup.Location `
        -IpConfiguration @($nicIPConfigJMP1, $nicIPConfigJMP2) `
        -Tag $global:globalProperties.globalTags
    $global:hubResources.Add("NICJMP", $nicConfigJMP)

    # Create the OS disk for the Jumpbox VM
    $osDiskConfigJMP = New-AzDiskConfig `
        -OsType Windows `
        -Location $global:hubResources.ResourceGroup.Location `
        -Architecture X64 `
        -SkuName Premium_LRS `
        -Tier P30 `
        -DiskSizeGB 128 `
        -HyperVGeneration V2 `
        -ImageReference @{"Id" = $global:globalProperties.vmImageJMP.Id } `
        -CreateOption FromImage `
        -Tag $global:globalProperties.globalTags

    $osDiskJMP = New-AzDisk `
        -Disk $osDiskConfigJMP `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -DiskName $hubProperties.JMPOSDiskName
    $global:hubResources.Add("OSDiskJMP", $osDiskJMP)

    # Create the Jumpbox VM config
    $vmConfigJMP = New-AzVMConfig `
        -VMName $global:hubProperties.JMPVMName `
        -VMSize $global:globalProperties.vmSize `
        -Tags $global:globalProperties.globalTags

    # Add the NIC to the VM config
    $vmConfigJMP = Add-AzVMNetworkInterface `
        -VM $vmConfigJMP `
        -Id $nicConfigJMP.Id
    
    # Add the OS disk to the VM config
    $vmConfigJMP = Set-AzVMOSDisk `
        -VM $vmConfigJMP `
        -CreateOption FromImage `
        -ManagedDiskId $osDiskJMP.Id

    # Add the data disk to the VM config
    $vmConfigJMP = Add-AzVMDataDisk `
        -VM $vmConfigJMP `
        -Name $global:hubProperties.JMPDataDiskName `
        -DiskSizeInGB $global:hubProperties.JMPDataDiskSizeGB `
        -Lun 1 `
        -CreateOption Empty `
        -DeleteOption Delete `
        -Caching ReadOnly

    # Add the VM OS config to the VM
    $vmConfigJMP = Set-AzVMSourceImage `
        -VM $vmConfigJMP `
        -PublisherName 'MicrosoftWindowsServer' `
        -Offer 'WindowsServer' `
        -Skus '2022-datacenter-azure-edition' `
        -Version latest

    # Create the VM
    New-AzVM `
        -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
        -Location $global:hubResources.ResourceGroup.Location `
        -VM $vmConfigJMP
    $global:hubResources.Add("VMJMP", $(Get-AzVM `
                -ResourceGroupName $global:hubResources.ResourceGroup.ResourceGroupName `
                -Name $global:hubProperties.JMPVMName
        )
    )
                
    
}
else {
    $spokeVMProperties = @{
        ResourceGroupName  = $global:spokeResources.ResourceGroup.ResourceGroupName
        Location           = $global:spokeResources.ResourceGroup.Location
        VirtualNetworkName = $global:spokeResources.Vnet.Name
        Size               = $global:globalProperties.vmSize
        Image              = $global:globalProperties.vmImage
        Credential         = $global:credential
    }
    # Create the domain controller
    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameADC `
        -SubnetName $global:spokeProperties.SubnetNameADC `
        -AvailabilitySetName $global:spokeResources.AVSetADC.Name
    $global:spokeResources.Add("VMADC", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameADC
        )
    )

    # Create the web servers
    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameWeb1 `
        -SubnetName $global:spokeProperties.SubnetNameSRV `
        -AvailabilitySetName $global:spokeResources.AVSetWeb.Name
    $global:spokeResources.Add("VMWeb1", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameWeb1
        )
    )

    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameWeb2 `
        -SubnetName $global:spokeProperties.SubnetNameSRV `
        -AvailabilitySetName $global:spokeResources.AVSetWeb.Name
    $global:spokeResources.Add("VMWeb2", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameWeb2
        )
    )

    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameSQL1 `
        -SubnetName $global:spokeProperties.SubnetNameSRV `
        -AvailabilitySetName $global:spokeResources.AVSetSQL.Name
    $global:spokeResources.Add("VMSQL1", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameSQL1
        )
    )

    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameSQL2 `
        -SubnetName $global:spokeProperties.SubnetNameSRV `
        -AvailabilitySetName $global:spokeResources.AVSetSQL.Name
    $global:spokeResources.Add("VMSQL2", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameSQL2
        )
    )

    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameLNX `
        -SubnetName $global:spokeProperties.SubnetNameSRV `
        -Image "UbuntuLTS" `
        -AvailabilitySetName $global:spokeResources.AVSetLNX.Name
    $global:spokeResources.Add("VMLNX", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameLNX
        )
    )

    New-AzVM @spokeVMProperties `
        -Name $global:spokeProperties.vmNameDEV `
        -SubnetName $global:spokeProperties.SubnetNameSRV `
        -AvailabilitySetName $global:spokeResources.AVSetDEV.Name
    $global:spokeResources.Add("VMDEV", $(Get-AzVM `
                -ResourceGroupName $global:spokeResources.ResourceGroup.ResourceGroupName `
                -Name $global:spokeProperties.vmNameDEV
        )
    )
}