targetScope = 'subscription'

@description('Token replacements array with key value paris for string replacements.')
param tokenReplacements array

@description('Location for all resources.')
param location string = deployment().location

@description('List of resource groups. The substring "$ENV" will be replaced by the value of the parameter called "envMoniker".')
param resourceGr object

param containerRegistry object

param workspace object

param environment object

param identity object

param tags object

param containerApps array



//////////////////////////////////////////////////////////// TOKEN REPLACEMENTS ////////////////////////////////////////////////////////////

func conditionalToLower(value string, valueToLower bool) string => valueToLower ? toLower(value) : value

func replaceAll(value string, replacements array, newStringtoLower bool) string => conditionalToLower(
  reduce(
    replacements,
    value,
    (aggregate, currentReplacement) => replace(aggregate, currentReplacement.oldString, currentReplacement.newString)),
  newStringtoLower)

var resourceGrName = replaceAll(resourceGr.name, tokenReplacements, false)

//////////////////////////////////////////////////////////// MODULES ////////////////////////////////////////////////////////////
module module_resourceGroup 'br/public:avm/res/resources/resource-group:0.2.4' = {
  name: 'pid-rg-${replaceAll(resourceGr.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  params: {
    name: replaceAll(resourceGr.name, tokenReplacements, false)
    location: location
    tags: tags
  }
}

module module_containerregistry 'br/public:avm/res/container-registry/registry:0.3.2' = {
  name: 'pid-cr-${replaceAll(containerRegistry.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(containerRegistry.name, tokenReplacements, true)
    acrSku: containerRegistry.acrSku
    location: location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
  ]
}

module module_workspace 'br/public:avm/res/operational-insights/workspace:0.4.1' = {
  name: 'pid-ws-${replaceAll(workspace.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: workspace.name
    location:location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
  ]
}

module module_environment 'br/public:avm/res/app/managed-environment:0.5.2' = {
  name: 'pid-en-${replaceAll(environment.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(environment.name, tokenReplacements, false)
    logAnalyticsWorkspaceResourceId: module_workspace.outputs.resourceId
    location:location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
    module_workspace
  ]
}

module module_userIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  name: 'pid-id-${replaceAll(identity.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    name: replaceAll(identity.name, tokenReplacements, false)
    location: location
    tags: tags
  }
  dependsOn: [
    module_resourceGroup
  ]
}

module module_asignidmodule_userAssignedIdentityentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  name: 'pid-id-${replaceAll(identity.assigmentName, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    name: replaceAll(identity.assigmentName, tokenReplacements, false)
    // Non-required parameters
    location: location
    roleAssignments: [
      {
        principalId: module_userIdentity.outputs.principalId
        principalType: identity.principalType //'ServicePrincipal'
        roleDefinitionIdOrName: identity.roleDefinitionIdOrName //'7f951dda-4ed3-4680-a7ca-43fe172d538d'
      }
    ]
  }
  dependsOn: [
    module_userIdentity
  ]
}

module containerApp 'br/public:avm/res/app/container-app:0.7.0' = [for container in containerApps: {
  name: 'pid-en-${replaceAll(container.name, tokenReplacements, false)}-${uniqueString(deployment().name)}'
  scope: resourceGroup(resourceGrName)
  params: {
    // Required parameters
    containers: [
      {
        image: container.image //'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: container.name//'simple-hello-world-container'
        resources: {
          cpu: container.cpu//'1'
          memory: container.memory //0.5Gi'
        }
      }
    ]
    environmentResourceId: module_environment.outputs.resourceId
    name: container.name
    location: location
    ingressExternal: container.ingressExternal
    ingressTargetPort: container.targetPort  //8080
    disableIngress: container.disableIngress //false
    ingressTransport: container.ingressTransport //'http'
    managedIdentities: {
      userAssignedResourceIds: [
        module_userIdentity.outputs.resourceId
      ]
    }
  }
  dependsOn: [
    module_environment
  ]
}
]
