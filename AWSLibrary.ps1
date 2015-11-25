

Function Get-FilterMatch($filter,$regexp){
    $filter_matches=@()
    $filter_notmatches=@()
    foreach($filterword in $filter){
        if ($filterword -match $regexp){
            $filter_matches+=$filterword
        }else{
        $filter_notmatches+=$filterword
        }
    }
    if ($filter_matches.count -gt 0){
        return ($filter_matches,$filter_notmatches)
    }
    return ($null,$filter)
}