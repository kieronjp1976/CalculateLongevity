# CalculateLongevity
This PowerShell script processes a csv export from Demon and calculates longevity for each species with a recapture record
This is my own work and is freely available for use, it is not supported by me or by the BTO.

The export file should be in $file  eg: $file="C:\temp\export.csv"

the output file is in the variable $reportpath   eg. $reportpath="c:\temp\report.csv"

Future changes:

0/ The two "where-object" commands at the top are slow. Loop through $data and populate the variables with conditional statements.
1/ Export to a PDF via Excel addin
2/ Export in HTML





Instructions - Only tested on windows 10.
1/ Download the export file from demon
2/ Update the variables $file and $filepath (See above)
3/ Open powershell as an administrator (type powershell into start, right click and choose run as administrator)
4/ Run "set-executionpolicy remotesigned" and choose Y when prompted
5/ Change to the directory that you saved the script in  (Type " cd c:\temp")
6/ Type in .\CalculateLongevity.ps1
7/ The output is a text file with ":" as a delimiter - I couldnt use CSV as the place names have commas in them. Use the Text to columns function in excel to get these into a table.

The script will take quite some time to run if the CSV file is large. You may want to run it and come back later.




