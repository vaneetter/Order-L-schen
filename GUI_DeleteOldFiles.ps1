# Add-Type für Windows Forms hinzufügen
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Funktion zum Abrufen aller alten Dateien
function Get-OldFiles {
    param (
        [string]$Path,
        [int]$DaysOld
    )
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        ($_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld))
    }
}

# Ergebnisse-Array
$results = New-Object System.Collections.ArrayList

# Erstellen des GUI-Fensters
$form = New-Object System.Windows.Forms.Form
$form.Text = "Alte Dateien anzeigen und löschen"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Ordnerpfad-Label
$labelPath = New-Object System.Windows.Forms.Label
$labelPath.Text = "Startpfad:"
$labelPath.Location = New-Object System.Drawing.Point(10, 10)
$labelPath.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($labelPath)

# Ordnerpfad-Textbox
$textBoxPath = New-Object System.Windows.Forms.TextBox
$textBoxPath.Location = New-Object System.Drawing.Point(100, 10)
$textBoxPath.Size = New-Object System.Drawing.Size(400, 20)
$textBoxPath.Text = "C:\"
$form.Controls.Add($textBoxPath)

# Durchsuchen-Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Durchsuchen"
$browseButton.Location = New-Object System.Drawing.Point(510, 10)
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBoxPath.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# Alter (Tage) Label
$labelDays = New-Object System.Windows.Forms.Label
$labelDays.Text = "Alter (in Tagen):"
$labelDays.Location = New-Object System.Drawing.Point(10, 40)
$labelDays.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelDays)

# Alter (Tage) Textbox
$textBoxDays = New-Object System.Windows.Forms.TextBox
$textBoxDays.Location = New-Object System.Drawing.Point(100, 40)
$textBoxDays.Size = New-Object System.Drawing.Size(400, 20)
$textBoxDays.Text = "365"
$form.Controls.Add($textBoxDays)

# Ergebnisse-Textbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(10, 80)
$outputBox.Size = New-Object System.Drawing.Size(560, 300)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$form.Controls.Add($outputBox)

# Start-Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Alte Dateien suchen"
$startButton.Location = New-Object System.Drawing.Point(10, 400)
$startButton.Size = New-Object System.Drawing.Size(200, 30)
$startButton.Add_Click({
    $outputBox.Clear()
    $Path = $textBoxPath.Text
    $DaysOld = [int]$textBoxDays.Text

    $outputBox.AppendText("Suche nach Dateien, die älter als $DaysOld Tage sind, im Pfad: $Path`r`n")
    $oldFiles = Get-OldFiles -Path $Path -DaysOld $DaysOld
    if ($oldFiles.Count -eq 0) {
        $outputBox.AppendText("Keine alten Dateien gefunden.`r`n")
    } else {
        foreach ($file in $oldFiles) {
            $outputBox.AppendText("Gefunden: $($file.FullName), Letzte Änderung: $($file.LastWriteTime)`r`n")
            $result = [System.Windows.Forms.MessageBox]::Show("Möchten Sie die Datei '$($file.FullName)' löschen?", "Datei löschen", [System.Windows.Forms.MessageBoxButtons]::YesNo)
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                try {
                    Remove-Item -Path $file.FullName -Force
                    $outputBox.AppendText("Gelöscht: $($file.FullName)`r`n")
                } catch {
                    $outputBox.AppendText("Fehler beim Löschen: $($file.FullName).`r`n")
                }
            } else {
                $outputBox.AppendText("Übersprungen: $($file.FullName)`r`n")
            }
        }
    }
    $outputBox.AppendText("Suche abgeschlossen.`r`n")
})
$form.Controls.Add($startButton)

# Schließen-Button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Schließen"
$closeButton.Location = New-Object System.Drawing.Point(370, 400)
$closeButton.Size = New-Object System.Drawing.Size(200, 30)
$closeButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($closeButton)

# GUI starten
[void]$form.ShowDialog()