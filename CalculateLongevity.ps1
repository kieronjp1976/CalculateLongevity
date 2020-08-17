$file="C:\temp\export.csv"
$reportpath="c:\temp\report.csv"
$data = import-csv $file | Select-Object record_type, species_name, ring_no, visit_date, location_name

$NewEncounters= $data | Where-Object {$_.record_type -match "N"} 
$SubsequentEncounters= $data | Where-Object {$_.record_type -match "S"}


class Bird  //Create a new object called bird with the properties below
{
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
foreach ($record in $SubsequentEncounters) # Loop through the records#
    {
    if ($specieslist.keys -notcontains $record.species_name) # If hash table doesnt contain a species.....
        {
       $specieslist.add($record.species_name, (new-object bird))  # Add the species to the hash table as a key 
        $specieslist.($record.species_name).speciesname = $record.species_name
        $specieslist.($record.species_name).TimeBetweenCaptures = 0
        }   
    }
#############################################################################################################


foreach ($record in $SubsequentEncounters)
{

        

        #$DateNew=($NewEncounters.Where({$_.ring_no -match $record.ring_no})).visit_date
        foreach($encounter in $newencounters) # This is MUCH faster than theline above
        {
            
            if ($encounter.ring_no -match $record.ring_no)
            {
               $datenew=$encounter.visit_date
               $firstlocation=$encounter.location_name
            }
        }
        
        if ($datenew -eq $null ) # For controls or sites with no N entry (Like Stoneacre)
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

