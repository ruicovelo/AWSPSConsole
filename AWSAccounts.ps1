


add-type @"
public struct AWSAccount  {
    public string Name;
    public object Credentials;
}
"@



Function Get-NewAWSAccountObject($profile){
    $account = new-object -TypeName AWSAccount
    $account.Name = $profile
    $account.Credentials = Get-AWSCredentials -ProfileName $profile
    return $account
}

Function Get-DefaultAccount(){
    if ($configuration.accounts){
        if ($configuration.accounts.default){
            return $configuration.accounts.default.name
        }
    }
}


Function Get-Account ($filter) {
   foreach ($profilename in (Get-AWSCredentials -ListProfiles)) { if ($profilename -match $filter) {$profilename}}
}
Set-Alias -name accounts -value Get-Account


Function Select-Account ($filter=$null,$Force=$true) {
    if ($filter -eq $null){
        return $global:CurrentProfile
    }

    $ProfileName = get-account $filter
    if ($ProfileName.count -eq 0) {
        Write-Error "Unable to find account! $filter"
        return $null
    }
    if ($ProfileName.count -eq 1){
    if ($Force -or ($ProfileName -ne $Global:CurrentProfile)){
        #Initialize-AWSDefaults -ProfileName $ProfileName
        if($?) { $global:CurrentProfile = $ProfileName; $global:CurrentAccount = Get-NewAWSAccountObject($global:CurrentProfile); Get-Status}
        return $null
    }
    }else{
        Write-Error "That would match more than one account"
        Write-Output $ProfileName
        return $null
    }
}
set-alias -name account -Value Select-account

Function Set-Credentials{
Param(
[Parameter(Mandatory=$True,Position=1)]
[string]$AccessKey,
[Parameter(Mandatory=$True,Position=2)]
[string]$SecretKey,
[Parameter(Mandatory=$False)]
[string]$ProfileName=$null
)
    if ($ProfileName -eq $null){
        Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey
    }else{
        Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName
    }
}

