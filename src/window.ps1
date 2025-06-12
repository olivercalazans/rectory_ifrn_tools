# Hide PowerShell console window
if (-not ([System.Management.Automation.PSTypeName]'GUI').Type)
{
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class GUI {
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@ -Language CSharp
}
$consolePtr = [GUI]::GetConsoleWindow()
[GUI]::ShowWindow($consolePtr, 0)


# Rest of your existing code
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


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
$listView.Columns.Add("ID", 80, [System.Windows.Forms.HorizontalAlignment]::Center) | Out-Null
$listView.Columns.Add("Email", 450) | Out-Null
$listView.Columns.Add("Type", 150, [System.Windows.Forms.HorizontalAlignment]::Center) | Out-Null
$listView.HeaderStyle = 'Nonclickable'


# Sample data - replace with your actual data
$sampleData = @(
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"},
    [PSCustomObject]@{ID=105; Email="david.brown@company.com"; Type="Admin"}
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"},
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"},
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"},
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"},
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"},
    [PSCustomObject]@{ID=101; Email="john.doe@company.com"; Type="Admin"},
    [PSCustomObject]@{ID=102; Email="jane.smith@company.com"; Type="User"},
    [PSCustomObject]@{ID=103; Email="mike.jones@company.com"; Type="Guest"},
    [PSCustomObject]@{ID=104; Email="sarah.williams@company.com"; Type="User"}
    # Add more items as needed
)


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
foreach ($item in $sampleData) {
    $listItem = New-Object System.Windows.Forms.ListViewItem($item.ID)
    $listItem.SubItems.Add($item.Email) | Out-Null
    $listItem.SubItems.Add($item.Type) | Out-Null
    $listView.Items.Add($listItem) | Out-Null
}


# Add status bar
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Total records: $($sampleData.Count) | Double-click a row for details"
$statusLabel.Location = New-Object System.Drawing.Point(20, 540)
$statusLabel.Size = New-Object System.Drawing.Size(760, 20)


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
