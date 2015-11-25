$CONFIGURATION_FILE_NAME="configuration.xml"
$AWSCONSOLE_PATH=$PSScriptRoot

if ($AWSCONSOLE_PATH -eq $null) { $AWSCONSOLE_PATH = "." }


$CONFIGURATION_FILE_NAME=$([io.path]::Combine($PSScriptRoot,$CONFIGURATION_FILE_NAME))
[xml]$configuration_file=gc $CONFIGURATION_FILE_NAME
[System.Xml.XmlLinkedNode]$configuration = $configuration_file.configuration

if ($? -eq $true){



function Get-Status(){
    Write-Host Account: $global:CurrentProfile
    Write-Host Region: $global:CurrentRegion.Name
}

Write-Host "Loading libraries..."
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSLibrary.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSAccounts.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSRegions.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSInstances.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSCache.ps1"))

$default_account = Get-DefaultAccount
if ($default_account){
    Write-Host "Selecting default account..."
    Select-Account $default_account $true
}
$default_region = Get-DefaultRegion
if ($default_region){
    Write-Host "Selecting default region..."
    $global:CurrentRegion = select-Region $default_region $true
}

set-alias -name status -value Get-Status
Write-Host


}
else{
Write-Host "Could not read configuration file: " $CONFIGURATION_FILE
}
