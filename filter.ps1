# powershell -executionpolicy bypass .\filter.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


$dialogue        = New-Object System.Windows.Forms.OpenFileDialog
$dialogue.Filter = "CSV Files (*.csv)|*.csv"
$dialogue.Title  = "Selecione um arquivo CSV"
$filters         = @()
$emails          = @()
$data            = @()
$lenTypes        = @{}
$total           = 0
$lenRepeated     = 0


# Open a file selection window
if ($dialogue.ShowDialog() -ne "OK") {
    Write-Host "Nenhum arquivo foi selecionado."
    Exit
}


# Get data from file
$CSVFile = $dialogue.FileName
$lines   = Get-Content $CSVFile
$lines   = $lines[2..($lines.Count)]
foreach ($line in $lines) {

    if ($line.Trim() -eq "") {
        continue
    }
    
    $email    = ($line -split ",")[0].Trim()
    $filters += "(extensionAttribute5=$email)"
}


# Divide into blocks of 500 or fewer and process
for ($i = 0; $i -lt $filters.Count; $i += 500) {
    $currentBlock = $filters[$i..($i + 500 - 1)]
    $blockString  = $currentBlock -join ""

    $queryResult = dsquery * "dc=ifrn,dc=local" -scope subtree -limit 600 -attr sAMAccountName extensionAttribute5 extensionAttribute2 -filter "(|$blockString)"
    $queryResult = $queryResult[1..($queryResult.Count)]

    foreach ($line in $queryResult) {
        $parts = $line -split '\s+', 4

        if ($parts.Count -ge 3) {
            $email = $parts[2].Trim()
            $type  = $parts[3].Trim()
        
            if (-not $lenTypes.ContainsKey($type)) {
                $lenTypes[$type] = 0
            }

            if ($type -eq "Aluno") {
                $data += [PSCustomObject]@{
                    ID    = $parts[1].Trim()
                    Email = $email
                    Type  = $type
                }
            }

            $lenTypes[$type]++

            if ($emails -contains $email) {
                $lenRepeated++
                continue
            }

            $emails += $email
            $total++
        }
    }
}



# Create description
$result = ""

foreach ($key in $lenTypes.Keys) {
    $result += "$($key): $($lenTypes[$key]) | "
}

$result = $result.TrimEnd(' | ')


# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "User Data Viewer"
$form.Size = New-Object System.Drawing.Size(750,600)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)


# Create ListView with three columns
$listView = New-Object System.Windows.Forms.ListView
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.Size = New-Object System.Drawing.Size(695,500)
$listView.Location = New-Object System.Drawing.Point(20,20)
$listView.OwnerDraw = $true
$listView.BackColor = [System.Drawing.Color]::White


# Set fixed column widths (disable user resizing)
$listView.Columns.Add("ID", 120, [System.Windows.Forms.HorizontalAlignment]::Center) | Out-Null
$listView.Columns.Add("Email", 400) | Out-Null
$listView.Columns.Add("Type", 150, [System.Windows.Forms.HorizontalAlignment]::Center) | Out-Null
$listView.HeaderStyle = 'Nonclickable'


# Custom drawing for alternate row colors
$listView.Add_DrawColumnHeader({
    param($sender, $e)
    $e.Graphics.FillRectangle([System.Drawing.Brushes]::LightSteelBlue, $e.Bounds)
    $e.DrawText()
})

$listView.Add_DrawSubItem({
    param($sender, $e)
    
    # Set alternating background colors
    if ($e.ItemIndex % 2 -eq 0) {
        $backColor = [System.Drawing.Color]::White
    } else {
        $backColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
    }
    
    $e.Graphics.FillRectangle((New-Object System.Drawing.SolidBrush $backColor), $e.Bounds)
    $e.DrawText()
})


# Populate the list view
foreach ($item in $data) {
    $listItem = New-Object System.Windows.Forms.ListViewItem($item.ID)
    $listItem.SubItems.Add($item.Email) | Out-Null
    $listItem.SubItems.Add($item.Type) | Out-Null
    $listView.Items.Add($listItem) | Out-Null
}


# Add status bar
$statusLabel          = New-Object System.Windows.Forms.Label
$statusLabel.Text     = "Total records: $($total) = $($result) | Repeated Emails: $($lenRepeated)"
$statusLabel.Location = New-Object System.Drawing.Point(20, 540)
$statusLabel.Size     = New-Object System.Drawing.Size(760, 20)


# Add double-click event
$listView.Add_DoubleClick({
    $selected = $listView.SelectedItems[0]
    if ($selected) {
        [System.Windows.Forms.MessageBox]::Show(
            "ID: $($selected.Text)`nEmail: $($selected.SubItems[1].Text)`nType: $($selected.SubItems[2].Text)",
            "Details",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
})


# Add controls to form
$form.Controls.Add($listView)
$form.Controls.Add($statusLabel)


# Show the form
[void]$form.ShowDialog()
