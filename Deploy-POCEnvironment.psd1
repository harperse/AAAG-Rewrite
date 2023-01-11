#region hashtables

#region DefaultHashtables
$regionCodes = @{
    #Asia
    CZEAS = "eastasia"
    CZSEA = "southeastasia"
    #Australia
    CZAU1 = "australiacentral"
    CZAU2 = "australiacentral2"
    CZEAU = "australiaeast"
    CZSAU = "australiasoutheast"
    #Brazil
    CZSBR = "brazilsouth"
    CZBSE = "brazilsoutheast"
    #Canada
    CZCCA = "canadacentral"
    CZECA = "canadaeast"
    #Europe
    CZNEU = "northeurope"
    CZWEU = "westeurope"
    #France
    CZFRC = "francecentral"
    CZFRS = "francesouth"
    #Germany
    CZGRN = "germanynorth"
    CZGWC = "germanywestcentral"
    #India
    CZCIN = "centralindia"
    CZSIN = "southindia"
    CZWIN = "westindia"
    #JioIndia
    CZJIC = "jioindiacentral"
    CZJIW = "jioindiawest"
    #Japan
    CZWJP = "japanwest"
    CZEJP = "japaneast"
    #Korea
    CZKRC = "koreacentral"
    CZKRS = "koreasouth"
    #Norway
    CZNWE = "norwayeast"
    CZNWW = "norwaywest"
    #Qatar
    CZQAC = "qatarcentral"
    #South Africa
    CZNSA = "southafricanorth"
    CZWSA = "southafricawest"
    #Sweden
    CZSWC = "swedencentral"
    #Switzerland
    CZSWN = "switzerlandnorth"
    CZSWW = "switzerlandwest"
    #UAE
    CZUAC = "uaecentral"
    CZUAN = "uaenorth"
    #UK
    CZSUK = "uksouth"
    CZWUK = "ukwest"
    #USCommercial
    CZCUS = "centralus"
    CZEU1 = "eastus"
    CZEU2 = "eastus2"
    CZCUN = "northcentralus"
    CZSCU = "southcentralus"
    CZWCU = "westcentralus"
    CZWU1 = "westus"
    CZWU2 = "westus2"
    CZWU3 = "westus3"
    #USGOV
    USGVA = "usgovvirginia"
    USGTX = "usgovtexas"
} # end hashtable; updated 10/26/2022

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