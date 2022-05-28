# Azure Minecraft Servers on Azure Container Instances

## Introduction
This template will deploy a chosen Minecraft Server to Azure Container Instances.

## Supported editions

1. Java - Vanilla
2. Java - Forge
3. Java - Fabric
4. Bedrock

## Deployment

### How to deploy
1. Put all files of ACI-folder in a folder.
2. Open Powershell and run deploy-minecraft-aci.ps1

To perform a simulated deployment, add the -whatif switch when running deploy-minecraft-aci.ps1

### Deploymentparameters 
Script is interactive and will ask for parameters as you are running it.

1. Connecting to Azure - Supply credentials
2. Select subscription - Select subscription from list
3. Select environment - Select environment from list (List of environments can be changed in the script)
4. Select Location - Select location from list (List of locations can be changed in the script)
5. Enter your name for tagging - Enter your name or nickname. Will be used for tagging the resources.
6. Set name of server - Name you server to identify it. Default is minecraft. 
7. Set instancenumber - Set a number to identify your server if multiple share name. Default is 001.
8. Select edition - Select edition from list.
9. Set operator - Enter your Minecraft username or any username that should be operator on the server.

## Environment variables
There are environment variables you can add/edit to further customize your server like changing versions etc.
Information on these can be found on https://github.com/itzg/docker-minecraft-server

## Storage
A storageaccount is provisioned as part of the deployment. It will host a share with youre minecraft related files. 
To work with these files if needed, I suggest using Azure Storage Explorer.

## Parameterfile
There is also a parameterfile containing settings for CPU, Memory and Storage. There should in most cases be no need to change this file.

Files you might work with:
1. Settingsfiles
2. Worlds
3. Mods and resources

## Credits

Templates and deploymentscripts are authored by CerveloRS

Serverimages are the work of itzg - https://github.com/itzg/docker-minecraft-server
