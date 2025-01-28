# Add-Type für Windows Forms hinzufügen
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

# Ergebnisse-Array
$results = New-Object System.Collections.ArrayList

# Erstellen des GUI-Fensters
$form = New-Object System.Windows.Forms.Form
$form.Text = "Leere Ordner anzeigen und löschen"
$form.Size = New-Object System.Drawing.Size(600, 450)
$form.StartPosition = "CenterScreen"

# Ordnerpfad-Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Startpfad:"
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($label)

# Ordnerpfad-Textbox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(100, 10)
$textBox.Size = New-Object System.Drawing.Size(400, 20)
$textBox.Text = "C:\Users"
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
$outputBox.Size = New-Object System.Drawing.Size(560, 300)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$form.Controls.Add($outputBox)

# Start-Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Leere Ordner suchen"
$startButton.Location = New-Object System.Drawing.Point(10, 360)
$startButton.Size = New-Object System.Drawing.Size(200, 30)
$startButton.Add_Click({
    $outputBox.Clear()
    $outputBox.AppendText("Scanne nach leeren Ordnern im Pfad: $($textBox.Text)`r`n")
    $emptyDirs = Get-EmptyDirectories -Path $textBox.Text
    if ($emptyDirs.Count -eq 0) {
        $outputBox.AppendText("Keine leeren Ordner gefunden.`r`n")
    } else {
        foreach ($dir in $emptyDirs) {
            $outputBox.AppendText("Leerer Ordner gefunden: $($dir.FullName)`r`n")
            $result = [System.Windows.Forms.MessageBox]::Show("Möchten Sie den Ordner '$($dir.FullName)' löschen?", "Ordner löschen", [System.Windows.Forms.MessageBoxButtons]::YesNo)
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                try {
                    Remove-Item -Path $dir.FullName -Recurse -Force
                    $outputBox.AppendText("Ordner gelöscht: $($dir.FullName)`r`n")
                } catch {
                    $outputBox.AppendText("Fehler beim Löschen des Ordners: $($dir.FullName)`r`n")
                }
            } else {
                $outputBox.AppendText("Ordner übersprungen: $($dir.FullName)`r`n")
            }
        }
    }
    $outputBox.AppendText("Scan abgeschlossen.`r`n")
})
$form.Controls.Add($startButton)

# Abbrechen-Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Schließen"
$cancelButton.Location = New-Object System.Drawing.Point(370, 360)
$cancelButton.Size = New-Object System.Drawing.Size(200, 30)
$cancelButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($cancelButton)

# GUI starten
[void]$form.ShowDialog()