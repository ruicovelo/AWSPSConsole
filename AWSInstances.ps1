

$instance_id_regexp="^i-.*"
$instance_state_regexp="^running$|^stopped$|^pending$|^terminated$"


add-type @"
public struct AWSInstance  {
    public string Name;
    public string Id;
    public string State;
    public object Instance;
    public object Region;
    public object Account;
}
"@

Function Start-Instance($instance,$credentials,$region){
if ($credentials -eq $null){
    $credentials = $Global:CurrentAccount.Credentials
}
if ($region -eq $null){
    Write-Host "Using default region"
    $region = $Global:CurrentRegion
}

    Start-EC2Instance -InstanceId (Get-InstanceId($instance)) -Credential $credentials -Region $region
}

Function Stop-Instance($instance,$credentials,$region){
if ($credentials -eq $null){
    $credentials = $Global:CurrentAccount.Credentials
}
if ($region -eq $null){
    $region = $Global:CurrentRegion
}

    Stop-EC2Instance -Instance (Get-InstanceId($instance)) -Credential $credentials -Region $region
}

Function Get-NewAWSInstanceObject($item){

        $instance = New-Object -TypeName AWSInstance
        $instance.Region = $global:CurrentRegion
        $instance.Account = $global:CurrentAccount
        $instance | Add-Member ScriptMethod Populate {
        Param($item) 
            $this.Id = $item.InstanceId
            $this.Name = ($item.tags | ? {$_.Key -eq "Name"}).Value
            $this.State = $item.State.Name
            $this.Instance = $item
        }
        $instance | Add-Member ScriptMethod Stop { stop-instance $this.id $this.Account.Credentials $this.Region.Region }      
        $instance | Add-Member ScriptMethod Start { start-instance $this.id $this.Account.Credentials $this.Region.Region }
        $instance | Add-Member ScriptMethod Update {
             $new=(get-instance $this.id $this.Account.Credentials $this.Region.Region)
             $this.Populate($new.Instance)  
             $this
        }
        $instance | Add-Member ScriptMethod WaitState {
        Param($State,[Int]$timeout_minutes=10,[Int]$polling_interval_seconds=5)
            While ($timeout_minutes -gt 0){
             $new=(get-instance $this.id $this.Account.Credentials $this.Region.Region)
             $this.Populate($new.Instance) 
             if ($this.State -match $State){
                return $this
             } 
             Start-Sleep $polling_interval_seconds
             }
        }

        
        $instance.Populate($item)

        $instance 
}



Function Get-InstanceList($filter){
    $instances =  Get-Instance $filter 
    foreach ($item in $instances){
        $instance = Get-NewAWSInstanceObject $item 
        $instance
    }    
}

Function Get-Instance($filter,$credentials,$region){
if ($credentials -eq $null){
    $credentials = $Global:CurrentAccount.Credentials
}
if ($region -eq $null){
    $region = $Global:CurrentRegion
}


    
    $instance_filter = @()
    ($id_filter,$filter)=Get-FilterMatch $filter $instance_id_regexp
    ($state_filter,$filter)=Get-FilterMatch $filter $instance_state_regexp

    if ($id_filter){
        $instance_filter+=@{name='instance-id';values="*$id_filter*"}
    }
    if ($state_filter){
        $instance_filter+=@{name='instance-state-name';values="*$state_filter*"}
    }
    if ($filter){
        $instance_filter+=@{name='tag:Name'; values="*$filter*"}
    }
    if ($filter.count -gt 1){
        Write-Error "Unknown query format! Unparsable words. " 
        return
    }
            #Set-AWSCredentials -ProfileName $Global:CurrentProfile   
            $instances = (Get-EC2Instance -Filter $instance_filter -Credential $credentials -Region $region).Instances 
      
        #$instances = (Get-EC2Instance).Instances
        foreach ($item in $instances){
            #if (($item.tags | ? {$_.Key -eq "Name" -and $_.Value -match $filter}).count -gt 0){
                Get-NewAWSInstanceObject($item)
            #}
        }
}
Set-Alias -name instances -value Get-Instance
Set-Alias -name instancelist -value Get-InstanceList

Function Select-Instance($filter){
    
}
Set-Alias -name instance -value Select-Instance



Function Get-InstanceId($instance){
    if ($instance.GetType().Name -eq "AWSInstance"){
        return $instance.InstanceId
    }
    else{
        if ($instance -match "^i-"){
            return $instance
        }
    }
}

