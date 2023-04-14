$file = "C:\Users\Kieron Palmer\Documents\repos\Ringing-CalculateLongevity\terg.csv"
$reportpath = "c:\temp\report.csv"

$data = Import-Csv $file | Select-Object record_type, species_name, ring_no, visit_date, location_name

$NewEncounters = $data | Where-Object { $_.record_type -match "N" } 
$SubsequentEncounters = $data | Where-Object { $_.record_type -match "S" }

class Bird {
    [string] $SpeciesName
    [string] $NewDate
    [string] $FirstLocation
    [int] $TimeBetweenCaptures
    [string] $RingNumber
    [string] $LastSeen
    [string] $Location
}

$speciesList = @{}
foreach ($record in $SubsequentEncounters) {
    if ($speciesList.Keys -notcontains $record.species_name) {
        $speciesList.Add($record.species_name, [Bird]::new())
        $speciesList.($record.species_name).SpeciesName = $record.species_name
        $speciesList.($record.species_name).TimeBetweenCaptures = 0
    }   
}

foreach ($record in $SubsequentEncounters) {
    $dateNew = ($NewEncounters | Where-Object { $_.ring_no -match $record.ring_no }).visit_date
    $firstLocation = ($NewEncounters | Where-Object { $_.ring_no -match $record.ring_no }).location_name

    if (-not $dateNew) {
        continue
    }

    $dateRange = New-TimeSpan -Start $dateNew -End $record.visit_date
    $daysBetweenCaptures = [int]$dateRange.Days

    if ($speciesList.($record.species_name).TimeBetweenCaptures -lt $daysBetweenCaptures) {
        $speciesList.($record.species_name).TimeBetweenCaptures = $daysBetweenCaptures
        $speciesList.($record.species_name).FirstLocation = $firstLocation
        $speciesList.($record.species_name).NewDate = $dateNew
        $speciesList.($record.species_name).LastSeen = $record.visit_date
        $speciesList.($record.species_name).RingNumber = $record.ring_no
        $speciesList.($record.species_name).Location = $record.location_name
    }
}

foreach ($key in $speciesList.Keys) {
    $species = $speciesList.$key
    $output = "$($species.SpeciesName):$($species.NewDate):$($species.FirstLocation):$($species.TimeBetweenCaptures):$($species.RingNumber):$($species.LastSeen):$($species.Location)"
    Out-File -FilePath $reportpath -InputObject $output -Append
}
