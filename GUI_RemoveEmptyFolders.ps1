# Add-Type für Windows Forms hinzufügen
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Funktion zum Überprüfen, ob ein Ordner leer ist
function Is-EmptyFolder {
    param (
        [string]$FolderPath
    )
    # Prüfe, ob der Ordner keine Dateien oder Unterordner enthält
    return -not (Get-ChildItem -Path $FolderPath -Force -ErrorAction SilentlyContinue)
}

# Funktion zum Löschen leerer Ordner
function Remove-EmptyFolders {
    param (
        [string]$TargetPath
    )
    $results.Clear()
    $folders = Get-ChildItem -Path $TargetPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
               Sort-Object { $_.FullName.Length } -Descending

    foreach ($folder in $folders) {
        if (Is-EmptyFolder -FolderPath $folder.FullName) {
            try {
                Remove-Item -Path $folder.FullName -Force
                $results.Add("Gelöscht: $($folder.FullName)")
            } catch {
                $results.Add("Fehler beim Löschen: $($folder.FullName) - $_")
            }
        } else {
            $results.Add("Nicht leer: $($folder.FullName)")
        }
    }
    return $results
}

# Ergebnisse-Array
$results = New-Object System.Collections.ArrayList

# Erstellen des GUI-Fensters
$form = New-Object System.Windows.Forms.Form
$form.Text = "Leere Ordner suchen und löschen"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"

# Ordnerpfad-Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Zielpfad:"
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($label)

# Ordnerpfad-Textbox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(100, 10)
$textBox.Size = New-Object System.Drawing.Size(400, 20)
$textBox.Text = "C:\"
$form.Controls.Add($textBox)

# Durchsuchen-Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Durchsuchen"
$browseButton.Location = New-Object System.Drawing.Point(510, 10)
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBox.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# Ergebnisse-Textbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(10, 50)
$outputBox.Size = New-Object System.Drawing.Size(560, 250)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$form.Controls.Add($outputBox)

# Start-Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Leere Ordner suchen & löschen"
$startButton.Location = New-Object System.Drawing.Point(10, 320)
$startButton.Size = New-Object System.Drawing.Size(200, 30)
$startButton.Add_Click({
    $targetPath = $textBox.Text
    $outputBox.Clear()
    $outputBox.AppendText("Suche nach leeren Ordnern in '$targetPath'...`r`n")
    $resultMessages = Remove-EmptyFolders -TargetPath $targetPath
    foreach ($message in $resultMessages) {
        $outputBox.AppendText("$message`r`n")
    }
    $outputBox.AppendText("Suche abgeschlossen.`r`n")
})
$form.Controls.Add($startButton)

# Abbrechen-Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Schließen"
$cancelButton.Location = New-Object System.Drawing.Point(370, 320)
$cancelButton.Size = New-Object System.Drawing.Size(200, 30)
$cancelButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($cancelButton)

# GUI starten
[void]$form.ShowDialog()