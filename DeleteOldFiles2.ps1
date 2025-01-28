# Set the root directory and age limit in days
$RootDirectory = "C:\"
$DaysOld = 365

# Get all files older than the specified days
$Files = Get-ChildItem -Path $RootDirectory -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld))
}

# Check if any files are found
if ($Files.Count -eq 0) {
    Write-Host "No files older than $DaysOld days found." -ForegroundColor Green
    return
}

# Loop through each file and ask for confirmation before deletion
foreach ($File in $Files) {
    Write-Host "File: $($File.FullName)" -ForegroundColor Yellow
    Write-Host "Last Modified: $($File.LastWriteTime)" -ForegroundColor Cyan
    $Confirm = Read-Host "Do you want to delete this file? (y/n)"

    if ($Confirm -eq 'y') {
        try {
            Remove-Item -Path $File.FullName -Force
            Write-Host "Deleted: $($File.FullName)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to delete: $($File.FullName). Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Skipped: $($File.FullName)" -ForegroundColor Gray
    }
}
if ($File.FullName -like "C:\Windows\*" -or $File.FullName -like "C:\Program Files\*") {
    Write-Host "Warnung: Systemdateien werden nicht gelöscht." -ForegroundColor Red
    continue
}
Write-Host "Zusammenfassung:" -ForegroundColor Cyan
Write-Host "Gelöschte Dateien: $DeletedCount" -ForegroundColor Green
Write-Host "Übersprungene Dateien: $SkippedCount" -ForegroundColor Yellow
Write-Host "Fehlerhafte Löschungen: $ErrorCount" -ForegroundColor Red
