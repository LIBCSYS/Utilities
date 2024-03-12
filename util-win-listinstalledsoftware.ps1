$dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$mydt = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
$hostName = $env:COMPUTERNAME
$outputPath = "X:\psh\dev\${hostName}_${dateTime}_InstalledApps.html"

# Query both 32-bit and 64-bit registry locations and the current user's registry for installed applications
$apps32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$apps64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$userApps = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

# Combine the lists, excluding empty display names
$apps = $apps64 + $apps32 + $userApps | Where-Object { $_.DisplayName -ne $null } | Sort-Object DisplayName

# Convert to HTML
$html = $apps | ConvertTo-Html -Head @"
<style>
    body {
        font-family: 'Arial', sans-serif;
        background-color: #f4f4f4;
        color: #333;
        margin: 0;
        padding: 20px;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        margin-bottom: 20px;
    }
    th, td {
        text-align: left;
        padding: 8px;
        border-bottom: 1px solid #ddd;
    }
    th {
        background-color: #4CAF50;
        color: white;
    }
    tr:hover {
        background-color: #f5f5f5;
    }
</style>
"@ -Body "<h1>Installed Applications and Updates for: $hostName Report Date: $mydt</h1>"

# Save to HTML file
$html | Out-File $outputPath

# Open the HTML file in the default browser
Invoke-Item $outputPath
