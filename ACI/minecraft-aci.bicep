param Location string
param Tags object
param ResourceName string
param Environment string
param Instance string

param StorageSKU string
param StorageKind string

param CPU int
param MEM string
param Operator string

param Image string
param Type string
param Port int

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'st${ResourceName}${Environment}${Instance}'
  location: Location
  tags: Tags
  sku: {
    name: StorageSKU
  }
  kind: StorageKind
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource storagefileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: '${storageaccount.name}/default/${ResourceName}'
  properties: {
    enabledProtocols: 'SMB'
  }
}

resource aci 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: 'ci-${ResourceName}-${Environment}-${Instance}'
  location: Location
  tags: Tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: Port
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: '${ResourceName}-${Environment}-${Instance}'
    }
    volumes: [
      {
        name: 'data'
        azureFile: {
          shareName: ResourceName
          storageAccountName: storageaccount.name
          storageAccountKey: storageaccount.listKeys().keys[0].value
        }
      }
    ]
    containers: [
      {
        name: 'ci-${ResourceName}-${Environment}-${Instance}'
        properties: {
          volumeMounts: [
            {
              mountPath: 'data'
              name: 'data'
            }
          ]
          image: Image
          resources: {
            requests: {
              cpu: CPU
              memoryInGB: MEM
            }
          }
          environmentVariables: [
            {
              name: 'EULA'
              value: 'TRUE'
            }
            {
              name: 'TYPE'
              value: Type
            }
            {
              name: 'OPS'
              value: Operator
            }
          ]
          ports: [
            {
              port: Port
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
  }
}
