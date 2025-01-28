# PowerShell-Skript: Leere Ordner auf Laufwerk C: suchen und löschen

# Funktion zum Überprüfen, ob ein Ordner leer ist
function Is-EmptyFolder {
    param (
        [string]$FolderPath
    )
    # Prüfe, ob der Ordner keine Dateien oder Unterordner enthält
    return -not (Get-ChildItem -Path $FolderPath -Force -ErrorAction SilentlyContinue)
}

# Suche und Lösche alle leeren Ordner auf dem angegebenen Pfad
function Remove-EmptyFolders {
    param (
        [string]$TargetPath = "C:\"
    )

    Write-Host "Suche nach leeren Ordnern in '$TargetPath'..." -ForegroundColor Cyan

    # Hole alle Ordner rekursiv (beginnend mit den tiefsten Ordnern)
    $folders = Get-ChildItem -Path $TargetPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
               Sort-Object { $_.FullName.Length } -Descending

    foreach ($folder in $folders) {
        Write-Host "Gefundener Ordner: $($folder.FullName)" -ForegroundColor Yellow
        $confirmation = Read-Host "Warnung: Soll der Ordner '$($folder.FullName)' überprüft und ggf. gelöscht werden? (Ja/Nein)"
        if ($confirmation -notlike "Ja") {
            Write-Host "Übersprungen: $($folder.FullName)" -ForegroundColor Cyan
            continue
        }

        if (Is-EmptyFolder -FolderPath $folder.FullName) {
            try {
                # Lösche den leeren Ordner
                Remove-Item -Path $folder.FullName -Force
                Write-Host "Gelöscht: $($folder.FullName)" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Löschen: $($folder.FullName) - $_" -ForegroundColor Red
            }
        }
    }

    Write-Host "Suche abgeschlossen." -ForegroundColor Yellow
}

# Skript ausführen
Remove-EmptyFolders -TargetPath "C:\"

# Abschlussübersicht
Write-Host "Zusammenfassung:"
Write-Host "Gelöschte Ordner: $DeletedCount" -ForegroundColor Green
Write-Host "Übersprungene Ordner: $SkippedCount" -ForegroundColor Yellow
Write-Host "Fehlerhafte Löschungen: $ErrorCount" -ForegroundColor Red
