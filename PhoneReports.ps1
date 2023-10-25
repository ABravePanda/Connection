# Prompt the user to select the type of files to process
$selection = Read-Host "[1] Daily`n[2] Weekly`n[3] Weekly & Daily`nSelect the type of files to process"

# Call correct function depending on input
if ($selection -eq "1") {
        Daily
}
elseif ($selection -eq "2") {
        Weekly
}
elseif ($selection -eq "3") {
        Weekly
        Daily
}
else {
  Write-Host "Invalid Selection"
  exit
}

# TODO: Implement weekly :)
function Weekly {
    Write-Host "Starting Weekly"
    Write-Host "Finished Weekly"
}

# Daily report function
function Daily {
   Write-Host "Starting Daily"

    # Calculate dates
    $date = Get-Date
    $today = $date.ToString("MMddyyyy")
    $yesterday = $date.AddDays(-1).ToString("MMddyyyy")

    # Get correct folders
    # TODO: REPLACE WITH FOLDER NAME
    $sourceFolder = "SOURCE"
    $destinationFolder = "DESTINATION"


    # Define an array to track the processed files
    $processedFileTypes = @()

    # Get a list of files in the source folder
    $files = Get-ChildItem $sourceFolder

    # Loop through each file in the source folder
    foreach ($file in $files) {

        # Check if the file matches the correct naming convention
         if ($file.Name -match "^(.+)(\d{8})\d{4}\.xlsx$") {
            $fileType = $matches[1]
            $fileDate = $matches[2]

            # Check if the file date matches today's or yesterdays date
            if (($fileDate -eq $today -or $fileDate -eq $yesterday) -and $processedFileTypes -notcontains $fileType) {
                Write-Host " - Processing file: $($file.Name)"

                # Construct the new filename with yesterday's date
                $newFileName = $fileType + " " + $yesterday + ".xlsx"

                # Determine the destination subfolder based on the file type
                $destinationSubfolder = $destinationFolder
                if ($fileType -eq "CSHDDailyAgentPerf") {
                    $destinationSubfolder = Join-Path -Path $destinationFolder -ChildPath "Agent Perf"
                } elseif ($fileType -eq "CSHDDailyCDNStats") {
                    $destinationSubfolder = Join-Path -Path $destinationFolder -ChildPath "CDN Stats"
                }

                # Create the full path for the destination file
                $destinationPath = Join-Path -Path $destinationSubfolder -ChildPath $newFileName

                # Copy the file to the destination folder and rename it
                Copy-Item $file.FullName $destinationPath -Force

                # Add the processed file type to the array
                $processedFileTypes += $fileType

                # Check if all three file types have been processed
                if ($processedFileTypes.Count -eq 3) {
                    break
                }
            }
        }
    }
    Write-Host "Finished Daily"
}
