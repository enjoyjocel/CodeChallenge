$data = Get-Content C:\temp\Sample_Cities1.txt

$ParsedData = @()

foreach($row in $data){

    # Get City
    $res = $row -match "(?<=\|)(.*)(?=\|.*\|)";
    $city = $Matches[0]

    # Get State
    $res = $row -match "(?<=\|)(.*)(?=\|)"
    $res = $Matches[0] -match "(?<=\|)(.*)(?=)"
    $state = $Matches[0]

    # Get Interstates
    $res = $row -match "I-.*"
    $res = $Matches[0].Split(';')
    
    $is_id = @()
    foreach($entry in $res){
        
        [Int]$id = $entry.substring(2)
        $is_id += $id
    }

    $Interstates = $is_id | Sort-Object | select @{Name="Interstate";E={"I-" + $_}} | select -ExpandProperty Interstate

    $obj = New-Object -TypeName PSObject -Property @{
        
        "City" = $city
        "State" = $state
        "Interstates" = $Interstates
        "DegreeChi" = -1
        
    }

    $ParsedData += $obj
    
}

# Loop - Modify Data

# Set Chicago to Degree 0
$DataEdit = $ParsedData | ? {$_.city -eq "Chicago"}
$dataEdit.DegreeChi = 0


for($X=0;$X -lt 10; $x++){

    $CurrentIState = @()

    $ParsedData | ? {$_.DegreeChi -eq $x} | Select -ExpandProperty Interstates |  % {
        $CurrentIState += $_    
    }

    $Undegreesed = $ParsedData | ? {$_.DegreeChi -eq "x"}

        
        foreach($istate in $CurrentIState){
            
            $istatePresent = $ParsedData | ? {($_.Interstates -contains "$istate") -and ($_.DegreeChi -eq -1)}
            $istatePresent | % {$_.DegreeChi = $x + 1}
        
        }

    if(!$CurrentIState){
        break;
    }
}

$FinalData = @()
$ParsedData | Sort-Object -Property DegreeChi -OutVariable sortparsedata
foreach ($ent in $sortparsedata) {
    $check = $FinalData | ? {$_.city -eq $ent.city}

    if (!$check) {
        $FinalData += $ent
    }
}

$FinalData | Sort-Object -Property DegreeChi -Descending | % {
    Write-Output "$($_.degreechi) $($_.city), $($_.state)"
}






