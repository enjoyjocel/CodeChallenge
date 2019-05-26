<#

.NAME 
        Challenge-Code

.SYNOPSIS

        Answer to the POwershell challenge problem

.Notes

Solution Methodology:

I converted the data (input file content) to custom object for easier manipulation and broke down  tasks to multiple functions for easier debug

            Answer to Output 1: 
                                1. I extracted the uniqe Populations to remove duplicates. Converted them as well to Int for sorting. 
                                2. For each uniqe population (sorted in descending order), extracted all states,city (in ascending order)
                                   that contains same population
                                3. Do formatting with interstates (sorted) appended and Write them to file

            Answer to Output 2:
                                1. "un-stringed" the values and added them to the custom made object ( sorted in the function)
                                2. Removed "I-" and converted the numbers to Int for sorting.
                                3. Foreach unique interstate, count the number of cities (rows) it is present. 
                                4. Do formatting and write them to file.

.Example

        .\Parse-File.ps1 -path c:\temp\Sample_Cities1.txt

        Use this switch if you don't want to use path parameter and wantt to browse the file instead
        .\Parse-File.ps1 -browse
#>


param(
    [Parameter(Position=0,
    ParameterSetName = "Path")]
    $path,

    [Parameter(ParameterSetName = "browse")]
    [switch]$browse = $False
)

$path = "C:\Users\enjoy\OneDrive\Misc_Shared\Code Challenge\Sample_Cities1.txt"

Function Get-FileName($initialDirectory){
   
     [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

     $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
     $OpenFileDialog.initialDirectory = $initialDirectory
     $OpenFileDialog.filter = "All files (*.*)| *.*"
     $OpenFileDialog.ShowDialog() | Out-Null
     $OpenFileDialog.filename
} 

if ($browse){
    $file_content = Get-Content -path (Get-FileName)
}

else{
    $file_content = Get-Content $path
}


Function Get-Population($row_content){
    [regex]::Match($row_content, '(\d*)').Groups[0].value
}

Function Get-City($row_content){
    $res = $row_content -match "(?<=\|)(.*)(?=\|.*\|)"
    $Matches[0]
}

Function Get-State($row_content){
    $res = $row_content -match "(?<=\|)(.*)(?=\|)"
    $res = $Matches[0] -match "(?<=\|)(.*)(?=)"
    $Matches[0]
}

Function Get-Interstates($row_content){
    $res = $row_content -match "I-.*"
    $res = $Matches[0].Split(';')
    
    $is_id = @()
    foreach($entry in $res){
        
        [Int]$id = $entry.substring(2)
        $is_id += $id
    }

    $is_id | Sort-Object | select @{Name="Interstate";E={"I-" + $_}} | select -ExpandProperty Interstate
}
Function Convert-ToArray{
    param($file_content)

    $data = @()

    foreach($row_data in $file_content){
        
        $info = New-Object -TypeName PSObject

        $info | Add-Member -type NoteProperty -name "Population"  -value (get-population $row_data)
        $info | Add-Member -type NoteProperty -name "City"  -value (Get-City $row_data)
        $info | Add-Member -type NoteProperty -name "State"  -value (Get-State $row_data)
        $info | Add-Member -type NoteProperty -name "Interstates"  -value (Get-Interstates $row_data)
        $data += $info
   
        }

        $data 
}

Function Get-Converted{
    Convert-ToArray $file_content 
}

function Create-OutputOne{

    $unique_pop = Get-Converted | select @{name="Population";E={[int]($_.population)}} | Sort-Object population -Descending | select-object Population -Unique

    foreach($pop in $Unique_POP.Population){
    
            [array]$state_city = Get-Converted | ? {$_.population -eq "$pop"} | Sort-Object state,city | select *

            [string]$val = "$pop`r`n" 
            add-content -path .\Cities_By_Population.txt -value $val

            foreach($s_c in $state_city){
            
                
                [string]$val = $s_c.city + ", " + $s_c.state + "`r`nInterstates: "+ ($s_c.Interstates -join ', ') + "`r`n" 
                add-content -path .\Cities_By_Population.txt -value $val
                
            
            }

    }
}


Function Create-OutPutTwo{
    [array]$res = get-converted | select -ExpandProperty interstates

    $uniq_interstates = ($res.Split(";")).substring(2) | select @{Name="InterstateNum";E={[Int]($_)}} | Sort-Object InterstateNum| Select InterstateNum -Unique

    foreach($uniq_interstates_num in $uniq_interstates){
    
        [string]$interstate_code = "I-" + $uniq_interstates_num.InterstateNum
        [array]$num_cities = get-converted | Select City, Interstates| ? {$_.Interstates -contains "$interstate_code"}
        $interstate_code + " " + $num_cities.Length 
    }

}
Create-OutputOne 
Create-OutputTwo | Out-File .\Interstates_By_City.txt

