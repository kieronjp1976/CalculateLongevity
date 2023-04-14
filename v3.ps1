$file = "C:\Users\Kieron Palmer\Documents\repos\Ringing-CalculateLongevity\terg.csv"
$reportpath = "c:\temp\report.csv"
$data = import-csv $file | Select-Object record_type, species_name, ring_no, visit_date, location_name

$NewEncounters = $data | Where-Object {$_.record_type -match "N"} 
$SubsequentEncounters = $data | Where-Object {$_.record_type -match "S"}

# Use a hashtable instead of a class to store the bird data
$specieslist = @{}

# Loop through the subsequent encounters and store the data in the $specieslist hashtable
foreach ($record in $SubsequentEncounters)
{
    # Check if the species name is already in the hashtable
    if (-not $specieslist.ContainsKey($record.species_name))
    {
        # If not, add the species name to the hashtable and initialize the data for the species
        $specieslist[$record.species_name] = @{
            SpeciesName = $record.species_name
            TimeBetweenCaptures = 0
        }
    }

    # Find the corresponding new encounter for the current subsequent encounter
    $newEncounter = $NewEncounters | Where-Object {$_.ring_no -eq $record.ring_no}

    # Check if a new encounter was found
    if ($newEncounter)
    {
        # Calculate the time between captures
        $DateRange = New-TimeSpan -Start $newEncounter.visit_date -End $record.visit_date
        $DRint = $DateRange.Days
        
        # Update the data for the species if the time between captures is greater than the previous value
        if ($specieslist[$record.species_name].TimeBetweenCaptures -lt $DRint)
        {
            $specieslist[$record.species_name] = @{
                SpeciesName = $record.species_name
                NewDate = $newEncounter.visit_date
                FirstLocation = $newEncounter.location_name
                TimeBetweenCaptures = $DRint
                RingNumber = $record.ring_no
                LastSeen = $record.visit_date
                Location = $record.location_name
            }
        }
    }
}

# Output the data for each species to the report file
foreach ($species in $specieslist.Values)
{
    $output = "$($species.SpeciesName):$($species.NewDate):$($species.FirstLocation):$($species.TimeBetweenCaptures):$($species.RingNumber):$($species.LastSeen):$($species.Location)"
    out-file -FilePath $reportpath -InputObject $output -Append
}
