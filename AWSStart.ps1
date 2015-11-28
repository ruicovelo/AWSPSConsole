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


$global:CurrentProfile = ""
$global:CurrentRegion = ""
$global:CurrentAccount = $null

Write-Host "Loading libraries..."
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSLibrary.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSAccounts.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSRegions.ps1"))
. $([io.path]::Combine($AWSCONSOLE_PATH,"AWSInstances.ps1"))

$default_account = Get-DefaultAccount
if ($default_account){
    Write-Debug "Selecting default account..."
    Select-Account $default_account 
}
$default_region = Get-DefaultRegion
if ($default_region){
    Write-Debug "Selecting default region..."
    select-Region $default_region 
}

set-alias -name status -value Get-Status
status
Write-Host


}
else{
Write-Error "Could not read configuration file: " $CONFIGURATION_FILE
}
