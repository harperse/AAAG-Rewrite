#region hashtables

<#
#region DefaultHashtables
$regionCodes = @{
    #Africa
    CZNSA = "southafricanorth"
    #AsiaPacific
    CZAU1 = "australiacentral"
    CZAU2 = "australiacentral2"
    CZCIN = "centralindia"
    CZEAS = "eastasia"
    CZEAU = "australiaeast"
    CZEJP = "japaneast"
    CZJIC = "jioindiacentral"
    CZJIW = "jioindiawest"
    CZKRC = "koreacentral"
    CZKRS = "koreasouth"
    CZQAC = "qatarcentral"
    CZSAU = "australiasoutheast"
    CZSEA = "southeastasia"
    CZSIN = "southindia"
    CZUAC = "uaecentral"
    CZUAN = "uaenorth"
    CZWIN = "westindia"
    CZWJP = "japanwest"
    #Europe
    CZFRC = "francecentral"
    CZFRS = "francesouth"
    CZGRN = "germanynorth"
    CZGWC = "germanywestcentral"
    CZNEU = "northeurope"
    CZNWE = "norwayeast"
    CZNWW = "norwaywest"
    CZSUK = "uksouth"
    CZSWC = "swedencentral"
    CZSWN = "switzerlandnorth"
    CZSWW = "switzerlandwest"
    CZWEU = "westeurope"
    CZWUK = "ukwest"
    #NorthAmerica
    CZCCA = "canadacentral"
    CZCUS = "centralus"
    CZECA = "canadaeast"
    CZEU1 = "eastus"
    CZEU2 = "eastus2"
    CZCUN = "northcentralus"
    CZSCU = "southcentralus"
    CZWCU = "westcentralus"
    CZWU1 = "westus"
    CZWU2 = "westus2"
    CZWU3 = "westus3"
    #SouthAmerica
    CZSBR = "brazilsouth"
    CZBSE = "brazilsoutheast"
    #USGOV
    USGVA = "usgovvirginia"
    USGTX = "usgovtexas"
} # end hashtable; updated 10/26/2022
#>

Enum regionCodes {
    #Africa
    CZNSA #southafricanorth
    #AsiaPacific
    CZAU1 #australiacentral
    CZAU2 #australiacentral2
    CZCIN #centralindia
    CZEAS #eastasia
    CZEAU #australiaeast
    CZEJP #japaneast
    CZJIC #jioindiacentral
    CZJIW #jioindiawest
    CZKRC #koreacentral
    CZKRS #koreasouth
    CZQAC #qatarcentral
    CZSAU #australiasoutheast
    CZSEA #southeastasia
    CZSIN #southindia
    CZUAC #uaecentral
    CZUAN #uaenorth
    CZWIN #westindia
    CZWJP #japanwest
    #Europe
    CZFRC #francecentral
    CZFRS #francesouth
    CZGRN #germanynorth
    CZGWC #germanywestcentral
    CZNEU #northeurope
    CZNWE #norwayeast
    CZNWW #norwaywest
    CZSUK #uksouth
    CZSWC #swedencentral
    CZSWN #switzerlandnorth
    CZSWW #switzerlandwest
    CZWEU #westeurope
    CZWUK #ukwest
    #NorthAmerica
    CZCCA #canadacentral
    CZCUS #centralus
    CZECA #canadaeast
    CZEU1 #eastus
    CZEU2 #eastus2
    CZCUN #northcentralus
    CZSCU #southcentralus
    CZWCU #westcentralus
    CZWU1 #westus
    CZWU2 #westus2
    CZWU3 #westus3
    #SouthAmerica
    CZSBR #brazilsouth
    CZBSE #brazilsoutheast
    #USGOV
    USGVA #usgovvirginia
    USGTX #usgovtexas
}  # end hashtable; updated 1/12/2023

[hashtable]$regionCodesGov = @{
    USGVA = "usgovvirginia" # Hub Vnet (primary)
    USGTX = "usgovtexas" # Spoke Vnet (secondary)
} # end hashtable

$alaToaaaMap = @{
    CZEAS = @{
        reg = "eastasia"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZSEA = @{
        reg = "southeastasia"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZCUS = @{
        reg = "centralus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZEU1 = @{
        reg = "eastus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZEU2 = @{
        reg = "eastus2"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZWU1 = @{
        reg = "westus"
        aaa = "westus2"
        ala = "westus2"
    } # end ht
    CZCUN = @{
        reg = "northcentralus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZSCU = @{
        reg = "southcentralus"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZNEU = @{
        reg = "northeurope"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZWEU = @{
        reg = "westeurope"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZWJP = @{
        reg = "japanwest"
        aaa = "japaneast"
        ala = "japaneast"
    } # end ht
    CZEJP = @{
        reg = "japaneast"
        aaa = "japaneast"
        ala = "japaneast"
    } # end ht
    CZSBR = @{
        reg = "brazilsouth"
        aaa = "eastus2"
        ala = "eastus"
    } # end ht
    CZEAU = @{
        reg = "australiaeast"
        aaa = "austrailiasoutheast"
        ala = "austrailiasoutheast"
    } # end ht
    CZSAU = @{
        reg = "australiasoutheast"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZSIN = @{
        reg = "southindia"
        aaa = "centralindia"
        ala = "centralindia"
    } # end ht
    CZCIN = @{
        reg = "centralindia"
        aaa = "centralindia"
        ala = "centralindia"
    } # end ht
    CZWIN = @{
        reg = "westindia"
        aaa = "centralindia"
        ala = "centralindia"
    } # end ht
    CZCCA = @{
        reg = "canadacentral"
        aaa = "canadacentral"
        ala = "canadacentral"
    } # end ht
    CZECA = @{
        reg = "canadaeast"
        aaa = "canadacentral"
        ala = "canadacentral"
    } # end ht
    CZSUK = @{
        reg = "uksouth"
        aaa = "uksouth"
        ala = "uksouth"
    } # end ht
    CZWUK = @{
        reg = "ukwest"
        aaa = "uksouth"
        ala = "uksouth"
    } # end ht
    CZWCU = @{
        reg = "westcentralus"
        aaa = "westcentralus"
        ala = "westcentralus"
    } # end ht
    CZWU2 = @{
        reg = "westus2"
        aaa = "westus2"
        ala = "westus2"
    } # end ht
    CZCKR = @{
        reg = "koreacentral"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZSKR = @{
        reg = "koreasouth"
        aaa = "southeastasia"
        ala = "southeastasia"
    } # end ht
    CZCFR = @{
        reg = "francecentral"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZSFR = @{
        reg = "francesouth"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZCAU = @{
        reg = "australiacentral"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZCA2 = @{
        reg = "australiacentral2"
        aaa = "australiasoutheast"
        ala = "australiasoutheast"
    } # end ht
    CZNSA = @{
        reg = "southafricanorth"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    CZWSA = @{
        reg = "southafricawest"
        aaa = "westeurope"
        ala = "westeurope"
    } # end ht
    USGVA = @{
        reg = "usgovvirginia"
        aaa = "usgovvirginia"
        ala = "usgovvirginia"
    } # end ht
    USGTX = @{
        reg = "usgovtexas"
        aaa = "usgovvirginia"
        ala = "usgovvirginia"
    } # end ht
} # end ht

#endregion hashtables