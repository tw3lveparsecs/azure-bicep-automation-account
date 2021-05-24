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
param modules array = [
  {
    name: 'Az.Accounts'
    version: '2.2.5'
    uri: 'https://www.powershellgallery.com/api/v2/package'
  }
  {
    name: 'Az.Storage'
    version: 'latest'
    uri: 'https://www.powershellgallery.com/api/v2/package'
  }
]

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

output systemIdentityPrincipalId string = automationAccount.identity.principalId
