@description('Location of the automation account')
param location string = resourceGroup().location
@description('Automation account name')
param name string
@description('Automation account sku')
@allowed([
  'Free'
  'Basic'
])
param sku string = 'Basic'
@description('Modules to import into automation account')
@metadata({
  name: 'Module name'
  version: 'Module version or specify latest to get the latest version'
  uri: 'Module package uri, e.g. https://www.powershellgallery.com/api/v2/package'
})
param modules array = []
@description('Runbooks to import into automation account')
@metadata({
  runbookName: 'Runbook name'
  runbookUri: 'Runbook URI'
  runbookType: 'Runbook type: Graph, Graph PowerShell, Graph PowerShellWorkflow, PowerShell, PowerShell Workflow, Script'
  logProgress: 'Enable progress logs'
  logVerbose: 'Enable verbose logs'
})
param runbooks array = []

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: sku
    }
  }
}

resource automationAccountModules 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = [for module in modules: {
  parent: automationAccount
  name: module.name
  properties: {
    contentLink: {
      uri: module.version == 'latest' ? concat(module.uri, '/', module.name) : concat(module.uri, '/', module.name, '/', module.version)
      version: module.version == 'latest' ? null : module.version
    }
  }
}]

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = [for runbook in runbooks: {
  parent: automationAccount
  name: runbook.runbookName
  location: location
  properties: {
    runbookType: runbook.runbookType
    logProgress: runbook.logProgress
    logVerbose: runbook.logVerbose
    publishContentLink: {
      uri: runbook.runbookUri
    }
  }
}]

output systemIdentityPrincipalId string = automationAccount.identity.principalId
