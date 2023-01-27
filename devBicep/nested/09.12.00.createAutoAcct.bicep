param autoAcctName string
param location string
param automationSchedule object

var autoAcctSku = 'Free'

resource autoAcct 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: autoAcctName
  properties: {
    sku: {
      name: autoAcctSku
    }
  }
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
  }
}

resource autoAcctName_Start_0800_Weekdays_LOCAL 'Microsoft.Automation/automationAccounts/schedules@2015-10-31' = {
  parent: autoAcct
  name: 'Start 0800 Weekdays LOCAL'
  location: location
  tags: {
    displayName: 'Startup Schedule'
  }
  properties: {
    description: 'Start 0800 Weekdays LOCAL'
    startTime: automationSchedule.scheduledStartTime
    expiryTime: automationSchedule.scheduledExpiryTime
    frequency: 'Week'
    timeZone: 'UTC'
    advancedSchedule: {
      weekDays: [
        'Monday'
        'Tuesday'
        'Wednesday'
        'Thursday'
        'Friday'
      ]
    }
  }
}

resource autoAcctName_Stop_1800_Weekdays_LOCAL 'Microsoft.Automation/automationAccounts/schedules@2015-10-31' = {
  parent: autoAcct
  name: 'Stop 1800 Weekdays LOCAL'
  location: location
  tags: {
    displayName: 'Shutdown Schedule'
  }
  properties: {
    description: 'Stop 1800 Weekdays LOCAL'
    startTime: automationSchedule.scheduledStopTime
    expiryTime: automationSchedule.scheduledExpiryTime
    frequency: 'Week'
    timeZone: 'UTC'
    advancedSchedule: {
      weekDays: [
        'Monday'
        'Tuesday'
        'Wednesday'
        'Thursday'
        'Friday'
      ]
    }
  }
}

output autoAcctId string = autoAcct.id
