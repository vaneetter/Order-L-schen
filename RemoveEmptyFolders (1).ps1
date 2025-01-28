# Skript: Leere Ordner auf Laufwerk C: anzeigen und löschen

# Funktion zum Abrufen aller leeren Ordner
function Get-EmptyDirectories {
    param (
        [string]$Path
    )

    # Suche nach leeren Verzeichnissen
    Get-ChildItem -Path $Path -Recurse -Directory | Where-Object {
        (Get-ChildItem -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue).Count -eq 0
    }
}

# Starte das Skript
Write-Host "Scanne Laufwerk C: nach leeren Ordnern..." -ForegroundColor Yellow

# Überprüfen der Benutzerverzeichnisse
$userDirs = Get-ChildItem -Path "C:\Users" -Directory

foreach ($userDir in $userDirs) {
    Write-Host "\nBenutzer: $($userDir.Name)" -ForegroundColor Cyan

    # Hole leere Ordner für den aktuellen Benutzer
    $emptyDirs = Get-EmptyDirectories -Path $userDir.FullName

    if ($emptyDirs.Count -eq 0) {
        Write-Host "Keine leeren Ordner gefunden." -ForegroundColor Green
    } else {
        foreach ($dir in $emptyDirs) {
            Write-Host "Leerer Ordner gefunden: $($dir.FullName)" -ForegroundColor Yellow

            # Entscheidung, ob der Ordner gelöscht werden soll
            $response = Read-Host "Möchten Sie diesen Ordner löschen? (ja/nein)"

            if ($response -eq "ja") {
                try {
                    Remove-Item -Path $dir.FullName -Recurse -Force
                    Write-Host "Ordner gelöscht: $($dir.FullName)" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Löschen des Ordners: $($dir.FullName)" -ForegroundColor Red
                }
            } else {
                Write-Host "Ordner übersprungen: $($dir.FullName)" -ForegroundColor Cyan
            }
        }
    }
}
