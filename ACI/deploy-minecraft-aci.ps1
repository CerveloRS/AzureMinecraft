Param (

    [Parameter()]
    [switch]
    $whatif

)

Write-Output "Setting variables..."
$Environments = @("Dev", "Test", "Prod")
$Locations = @("westeurope", "northeurope")
$Editions = @("Java-Vanilla", "Java-Forge", "Java-Fabric", "Bedrock")

Write-Output "Connecting to Azure..."
$AzConnect = Connect-AzAccount
if (!$AzConnect) {
    throw "Not connected to Azure"
}

Write-Output "Collecting information..."

Write-Output "Select subscription..."
$Subscription = Get-AzSubscription | Out-GridView -OutputMode Single -Title "Select subscription for deployment:"
Select-AzSubscription $Subscription.Id | Out-Null

Write-Output "Select environment..."
$Environment = $Environments | Out-GridView -OutputMode Single -Title "Select environment:"

Write-Output "Select location..."
$Location = $Locations | Out-GridView -OutputMode Single -Title "Select location:"

$Author = Read-Host -Prompt "Enter your name for tagging"
$Tags = @{Author = $Author; Purpose = "Gaming" }

$MCName = Read-Host "Set name of server. (Default=minecraft)"
If (!$MCName) { $MCName = "minecraft" }

$InstanceNumber = Read-Host "Set instancenumber. (Default=001)"
If (!$InstanceNumber) { $InstanceNumber = "001" }

Write-Output "Select edition..."
$Edition = $Editions | Out-GridView -OutputMode Single -Title "Select edition:"

switch ($Edition) {
    "Java-Vanilla" { 
        $Image = "itzg/minecraft-server"
        $Type = "VANILLA"
    }
    "Java-Forge" { 
        $Image = "itzg/minecraft-server:java8"
        $Type = "FORGE"
    }
    "Java-Fabric" { 
        $Image = "itzg/minecraft-server"
        $Type = "FABRIC"
    }
    "Bedrock" { 
        $Image = "itzg/minecraft-bedrock-server"
        $Type = " "
    }
}

$Operator = Read-Host "Set operator. This is your Minecraft username."
If (!$Operator) { $Operator = "Op" }

$ResourceGroupName = "rg-mc$($MCName)-$($Environment)-$($InstanceNumber)".ToLower()
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tags

Write-Output "Setting deploymentparameters..."
$DeployParams = @{
    TemplateFile          = '.\minecraft-aci.bicep'
    TemplateParameterFile = '.\minecraft-aci.parameters.json'
    ResourceGroupName     = $ResourceGroupName.ToLower()
    Tags                  = $Tags
    ResourceName          = "mc$($MCName)".ToLower()
    Environment           = $Environment.ToLower()
    Instance              = $InstanceNumber.ToLower()
    Location              = $Location.ToLower()
    Image                 = $Image
    Type                  = $Type
    Operator              = $Operator
}

If ($whatif.IsPresent) { $DeployParams.whatif = $true }

Write-Output "Deploying with parameters:"
Write-Output $DeployParams | Format-Table
$Confirm = Read-Host "Enter Y to continue..."
if ($Confirm.ToLower() -ne 'y') {
    Write-Output "Canceled."
    Exit
    
}

New-AzResourceGroupDeployment @DeployParams