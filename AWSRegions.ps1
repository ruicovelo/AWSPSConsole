



$global:AWS_ENABLED_REGIONS=foreach ($region in $configuration.regions.ChildNodes) { $region.Name}




Function Get-DefaultRegion(){
    if ($configuration.regions){
        if ($configuration.regions.default){
            return $configuration.regions.default.name
        }
    }
}




foreach ($region in $global:AWS_ENABLED_REGIONS) {
    $awsregion = Get-AWSRegion $region
    if ($awsregion.Name -eq "Unknown") {
        Write-Error "Unsupported region!"
        Write-Error $region
    }
}


add-type @"
public struct AWSRegion  {
    public string Region;
    public string Name;
}
"@


function select-region ($filter) {
if ($filter -eq $null){
    return Get-Status
}
    $region = get-region $filter
    if ($region.count -eq 0) {
        Write-Error "Unable to find region!"
    }
    if ($region.count -eq 1){
        $global:StoredAWSRegion = $region.region
        $global:CurrentRegion = $region
        
    }else{
        Write-Error "That would match more than one region"
        Write-Host $region
    }
}


function get-region ($filter) {
    Get-AWSRegion | where { $global:AWS_ENABLED_REGIONS.Contains($_.Region) } | where { ($_.Name -match $filter) -or ($_.Region -match $filter) } 
}


function aws($filter) {
    $result = get-region $filter
    return $result
}


function get-image ($name,$region=$null) {
    return Get-EC2Image -Filter @{ Name="name"; Value="$name"} -Region $region
}


Set-Alias -name regions -value get-region
Set-Alias -name region -value select-region

