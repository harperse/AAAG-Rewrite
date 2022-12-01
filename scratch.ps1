$nameAAA = "testAutoAcct"
$skuAAA = "Free"
$locAAA = "eastus2"

$aaaProperties = @{
    sku = @{
        Name = $skuAAA
    }
}

$startScheduleproperties = [ordered]@{
    description      = "Start 0800 Weekdays LOCAL"
    startTime        = $([datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT08:00:00"), "00:00" -join "-")
    expiryTime       = "9999-12-31T00:00:00-00:00"
    interval         = "1"
    frequency        = "Week"
    timeZone         = "UTC"
    advancedSchedule = @{
        "weekDays" = @(
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday"
        )
    }
}

$stopScheduleproperties = [ordered]@{
    description      = "Stop 1800 Weekdays LOCAL"
    startTime        = $([datetime]::utcnow.AddDays(1).ToString("yyyy-MM-ddT18:00:00"), "00:00" -join "-")
    expiryTime       = "9999-12-31T00:00:00-00:00"
    interval         = "1"
    frequency        = "Week"
    timeZone         = "UTC"
    advancedSchedule = @{
        "weekDays" = @(
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday"
        )
    }
}

$json = [ordered]@{
    '$schema'      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    resources      = @(
        @{
            comments   = "09.12.00.createAutoAcct"
            name       = $nameAAA
            type       = "Microsoft.Automation/automationAccounts"
            apiVersion = "2020-01-13-preview"
            location   = $locAAA
            tags       = @{}
            properties = $aaaProperties
            identity   = @{
                type = "SystemAssigned"
            }
        },
        @{
            comments   = "09.12.01.createAutoAcctScheduleStartup"
            name       = $($nameAAA, '/Start 0800 Weekdays LOCAL' -join $null)
            type       = "Microsoft.Automation/automationAccounts/schedules"
            apiVersion = "2015-10-31"
            location   = $locAAA
            tags       = @{
                "displayName" = "Startup Schedule"
            }
            dependsOn  = @($nameAAA)
            properties = $startScheduleproperties
        },
        @{
            comments   = "09.12.02.createAutoAcctScheduleShutdown"
            name       = $($nameAAA, '/Stop 1800 Weekdays LOCAL' -join $null)
            type       = "Microsoft.Automation/automationAccounts/schedules"
            apiVersion = "2015-10-31"
            location   = $locAAA
            tags       = @{
                "displayName" = "Shutdown Schedule"
            }
            dependsOn  = @($nameAAA)
            properties = $stopScheduleproperties
        }
    )
}

$jsonBase = [ordered]@{
    '$schema'      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    
}