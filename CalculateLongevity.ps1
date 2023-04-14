$StartMS=(get-date).timeofday.totalseconds
$file="C:\Users\Kieron Palmer\Documents\repos\Ringing-CalculateLongevity\combined.csv"

$reportpath="c:\temp\report.csv"
$FileCheck=Test-Path $reportpath
if ($FileCheck -eq $true)
{
    Remove-Item $reportpath
}
$data = import-csv $file | Select-Object record_type, species_name, ring_no, visit_date, location_name

$NewEncounters= $data | Where-Object {$_.record_type -match "N"} 
$SubsequentEncounters= $data | Where-Object {$_.record_type -match "S"}


class Bird{  ##Create a new object called bird with the properties below
[string]$SpeciesName
[string]$NewDate
[string]$firstlocation
[int]$TimeBetweenCaptures
[string]$ringnumber
[string]$lastseen
[string]$location
}

#####################################################################################################

# This loops through the records and takes out individual species names and put them in the HT specieslist

$specieslist=@{} 
#foreach ($record in $SubsequentEncounters) # Loop through the records#
   # {
  # if ($specieslist.keys -notcontains $record.species_name) # If hash table doesnt contain a species.....
   #    {
   #    $specieslist.add($record.species_name, (new-object bird))  # Add the species to the hash table as a key 
   #     $specieslist.($record.species_name).speciesname = $record.species_name
    #    $specieslist.($record.species_name).TimeBetweenCaptures = 0
    #    }   
   #}
   
#############################################################################################################

# Adding the above loop into this loop to reduce the number of time I need to scan all of the records as it is so slow
foreach ($record in $SubsequentEncounters)
{
    if ($specieslist.keys -notcontains $record.species_name) # If hash table doesnt contain a species.....
        {
        $specieslist.add($record.species_name, (new-object Bird))  # Add the species to the hash table as a key 
        $specieslist.($record.species_name).speciesname = $record.species_name
        $specieslist.($record.species_name).TimeBetweenCaptures = 0
        } 
        

        
        #foreach($encounter in $newencounters) 
        $NewEncounters | foreach-object
        {
            if ($_.ring_no -match $record.ring_no)
            {
            $DateNew=$_.visit_date
            $firstlocation=$_.location_name
            }
        }
        
        if (!$datenew) # For controls or sites with no N entry (Like Stoneacre)
        {
          continue
        }
       
$DateRange = new-timespan -start $DateNew -end $record.visit_date

[int]$DRint=$DateRange.Days # cast to integer, might not be needed anymore

if ($specieslist.($record.species_name).TimeBetweenCaptures -lt $DRint)
{

   $specieslist.($record.species_name).TimeBetweenCaptures=$DRint
   $specieslist.($record.species_name).firstlocation=$firstlocation
   $specieslist.($record.species_name).newdate =$datenew
   $specieslist.($record.species_name).lastseen=$record.visit_date
   $specieslist.($record.species_name).ringnumber=$record.ring_no
   $specieslist.($record.species_name).location=$record.location_name
   
}
 # The lines below empty the variables before the next loop otherwise they can stay populated in certain circumstances
Clear-Variable -name datenew
Clear-Variable -name firstlocation 
Clear-Variable -name daterange  
    
}


foreach ($key in $specieslist.keys)
{
    
    $output= $specieslist.$key.speciesname +":"+ $specieslist.$key.newdate+ ":"+ $specieslist.$key.firstlocation +":" +$specieslist.$key.TimeBetweenCaptures +":"+ $specieslist.$key.ringnumber +":"+ $specieslist.$key.lastseen +":"+ $specieslist.$key.location +":" +"`n"
    out-file -FilePath $reportpath -InputObject $output -Append
}
$EndMS=(get-date).timeofday.totalseconds
Write-host "This Script took $($EndMS-$StartMS) ticks to run"
