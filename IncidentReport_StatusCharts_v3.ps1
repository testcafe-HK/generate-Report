param(
    [string]$FolderPath = "C:\Users\haris\OneDrive\Documents\Zoom",
    [string]$OutputPath = ""
)

# Incident Report with Outlook-safe chart images using QuickChart.
# Usage examples:
#   .\IncidentReport_StatusCharts_v3.ps1
#   .\IncidentReport_StatusCharts_v3.ps1 -FolderPath "C:\Users\haris\OneDrive\Documents\Zoom"
#   .\IncidentReport_StatusCharts_v3.ps1 -FolderPath "C:\Users\haris\OneDrive\Documents\Zoom" -OutputPath "C:\Temp\Incident_Trend_Report.html"

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $FolderPath -PathType Container)) {
    throw "Input folder not found: $FolderPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path -Path $FolderPath -ChildPath "Incident_Trend_Report.html"
}

$outputDirectory = Split-Path -Path $OutputPath -Parent
if (-not [string]::IsNullOrWhiteSpace($outputDirectory) -and -not (Test-Path -Path $outputDirectory -PathType Container)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
}

$files = Get-ChildItem -Path $FolderPath -Filter "*.txt" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 5

if (-not $files -or $files.Count -eq 0) {
    throw "No .txt files found in folder: $FolderPath"
}

$allData = @()

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw

    # Match each incident block from INC<number> until the next INC<number> or end of file.
    $matches = [regex]::Matches($content, "(INC\d+)[\s\S]*?(?=INC\d+|$)")

    foreach ($match in $matches) {
        $incidentId = [regex]::Match($match.Value, "INC\d+").Value
        $rawText = ($match.Value -replace "INC\d+", "").Trim()

        # Extract status from patterns like: | Status - Investigating
        $status = "Unknown"
        $statusMatch = [regex]::Match($rawText, "(?i)Status\s*-\s*([^|\r\n]+)")
        if ($statusMatch.Success) {
            $status = $statusMatch.Groups[1].Value.Trim()
        }

        if ($status -match "(?i)^Investigating$") {
            $status = "In Progress"
        }

        # Description is everything before Status -
        $description = [regex]::Replace($rawText, "(?is)\|?\s*Status\s*-\s*.*$", "").Trim()
        $description = ($description -replace "\s+", " ").Trim()

        $allData += [PSCustomObject]@{
            FileName     = $file.Name
            LastModified = $file.LastWriteTime
            IncidentID   = $incidentId
            Status       = $status
            Description  = $description
        }
    }
}

if (-not $allData -or $allData.Count -eq 0) {
    throw "No incident IDs matching INC<number> were found in the latest 5 .txt files."
}

$latestFile = $files[0].Name
$currentWeek = @($allData | Where-Object { $_.FileName -eq $latestFile })

$summary = @($allData |
    Group-Object FileName |
    Select-Object @{Name="FileName";Expression={$_.Name}},
                  @{Name="TotalIncidentIDs";Expression={$_.Count}})

$statusSummary = @($allData |
    Group-Object Status |
    Select-Object @{Name="Status";Expression={$_.Name}},
                  @{Name="Count";Expression={$_.Count}})

$totalIncidents = $allData.Count
$currentWeekCount = $currentWeek.Count
$filesScanned = $files.Count

$statusColorMap = @{
    "Open"        = "#d9534f"
    "In Progress" = "#d4a017"
    "Resolved"    = "#2e9e44"
    "Closed"      = "#2e9e44"
    "Unknown"     = "#6b7280"
}

function ConvertTo-HtmlSafeText {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return "" }
    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Get-StatusBadgeHtml {
    param([string]$Status)
    $color = if ($statusColorMap.ContainsKey($Status)) { $statusColorMap[$Status] } else { "#6b7280" }
    $safeStatus = ConvertTo-HtmlSafeText $Status
    return "<span style='display:inline-block;min-width:110px;text-align:center;background:$color;color:white;padding:7px 14px;border-radius:999px;font-weight:700;font-size:13px;'>$safeStatus</span>"
}

# Outlook-safe chart images using QuickChart. No Chart.js script/canvas needed.
$trendChartConfig = @{
    type = "line"
    data = @{
        labels = @($summary | ForEach-Object { $_.FileName })
        datasets = @(
            @{
                label = "Total Incident IDs"
                data = @($summary | ForEach-Object { $_.TotalIncidentIDs })
                borderColor = "#2563eb"
                backgroundColor = "rgba(37,99,235,0.15)"
                fill = $true
                tension = 0.35
                pointRadius = 4
                pointBackgroundColor = "#2563eb"
            }
        )
    }
    options = @{
        scales = @{ y = @{ beginAtZero = $true; ticks = @{ precision = 0 } } }
    }
} | ConvertTo-Json -Depth 10 -Compress

$trendChartUrl = "https://quickchart.io/chart?width=900&height=350&devicePixelRatio=2&format=png&c=$([uri]::EscapeDataString($trendChartConfig))"

$statusLabels = @($statusSummary | ForEach-Object { $_.Status })
$statusCounts = @($statusSummary | ForEach-Object { $_.Count })
$statusColors = @($statusSummary | ForEach-Object {
    if ($statusColorMap.ContainsKey($_.Status)) { $statusColorMap[$_.Status] } else { "#6b7280" }
})

$statusChartConfig = @{
    type = "doughnut"
    data = @{
        labels = $statusLabels
        datasets = @(
            @{
                label = "Incidents by Status"
                data = $statusCounts
                backgroundColor = $statusColors
                borderColor = "#ffffff"
                borderWidth = 2
            }
        )
    }
    options = @{
        plugins = @{
            legend = @{ display = $true; position = "bottom" }
            title = @{ display = $true; text = "Incidents by Status"; font = @{ size = 16 } }
        }
    }
} | ConvertTo-Json -Depth 10 -Compress

$statusChartUrl = "https://quickchart.io/chart?width=700&height=350&devicePixelRatio=2&format=png&c=$([uri]::EscapeDataString($statusChartConfig))"

$html = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Incident Trend Report</title>
<style>
body {
    margin: 0;
    font-family: 'Segoe UI', Arial, sans-serif;
    background: linear-gradient(135deg, #eef2ff, #f8fafc);
    color: #111827;
}
.container { max-width: 1200px; margin: 30px auto; padding: 25px; }
.header { background: linear-gradient(135deg, #1e3a8a, #2563eb); color: white; padding: 28px; border-radius: 18px; box-shadow: 0 10px 25px rgba(37, 99, 235, 0.25); }
.header h1 { margin: 0; font-size: 32px; }
.header p { margin-top: 8px; opacity: 0.9; }
.cards { display: flex; gap: 18px; margin: 24px 0; }
.card { flex: 1; background: white; padding: 22px; border-radius: 16px; box-shadow: 0 8px 20px rgba(15, 23, 42, 0.08); border-left: 6px solid #2563eb; }
.card h3 { margin: 0; color: #64748b; font-size: 15px; }
.card .number { font-size: 34px; font-weight: 800; margin-top: 8px; color: #1e3a8a; }
.section { background: white; padding: 24px; border-radius: 18px; margin-bottom: 24px; box-shadow: 0 8px 20px rgba(15, 23, 42, 0.08); }
.section h2 { margin-top: 0; color: #1e293b; border-bottom: 2px solid #e5e7eb; padding-bottom: 10px; }
table { width: 100%; border-collapse: collapse; margin-top: 14px; overflow: hidden; border-radius: 12px; }
th { background: #1e3a8a; color: white; padding: 13px; text-align: left; font-size: 14px; }
td { padding: 13px; border-bottom: 1px solid #e5e7eb; vertical-align: top; }
tr:nth-child(even) { background: #f8fafc; }
.incident-badge { display: inline-block; background: #fee2e2; color: #991b1b; padding: 6px 12px; border-radius: 999px; font-weight: 700; font-size: 13px; }
.count-badge { display: inline-block; background: #dbeafe; color: #1e40af; padding: 6px 14px; border-radius: 999px; font-weight: 800; }
.footer { text-align: center; color: #64748b; font-size: 13px; margin-top: 25px; }
</style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>Incident Trend Report</h1>
        <p>Last 5 TXT files scanned from Zoom folder</p>
    </div>

    <div class="cards">
        <div class="card"><h3>Total Incidents</h3><div class="number">$totalIncidents</div></div>
        <div class="card"><h3>Current Week Incidents</h3><div class="number">$currentWeekCount</div></div>
        <div class="card"><h3>Files Scanned</h3><div class="number">$filesScanned</div></div>
    </div>

    <div class="section">
        <h2>Incident Trend Graph</h2>
        <div style="text-align:center;">
            <img src="$trendChartUrl" alt="Incident Trend Graph" style="width:100%; max-width:900px; height:auto; border-radius:12px;" />
        </div>
    </div>

    <div class="section">
        <h2>Status-Based Color Chart</h2>
        <div style="text-align:center;">
            <img src="$statusChartUrl" alt="Incidents by Status" style="width:100%; max-width:700px; height:auto; border-radius:12px;" />
        </div>
    </div>

    <div class="section">
        <h2>Current Week Incidents - $(ConvertTo-HtmlSafeText $latestFile)</h2>
        <table>
            <tr><th>Incident ID</th><th>Status</th><th>Description</th></tr>
"@

foreach ($row in $currentWeek) {
    $statusBadge = Get-StatusBadgeHtml -Status $row.Status
    $safeIncidentId = ConvertTo-HtmlSafeText $row.IncidentID
    $safeDescription = ConvertTo-HtmlSafeText $row.Description
    $html += @"
            <tr>
                <td><span class="incident-badge">$safeIncidentId</span></td>
                <td>$statusBadge</td>
                <td>$safeDescription</td>
            </tr>
"@
}

$html += @"
        </table>
    </div>

    <div class="section">
        <h2>Incident Count Summary - Last 5 Files</h2>
        <table>
            <tr><th>File Name</th><th>Total Incident IDs</th></tr>
"@

foreach ($item in $summary) {
    $safeFileName = ConvertTo-HtmlSafeText $item.FileName
    $html += @"
            <tr>
                <td>$safeFileName</td>
                <td><span class="count-badge">$($item.TotalIncidentIDs)</span></td>
            </tr>
"@
}

$html += @"
        </table>
    </div>

    <div class="section">
        <h2>Status Count Summary</h2>
        <table>
            <tr><th>Status</th><th>Total Incidents</th></tr>
"@

foreach ($item in $statusSummary) {
    $statusBadge = Get-StatusBadgeHtml -Status $item.Status
    $html += @"
            <tr>
                <td>$statusBadge</td>
                <td><span class="count-badge">$($item.Count)</span></td>
            </tr>
"@
}

$html += @"
        </table>
    </div>

    <div class="footer">Report generated automatically from TXT incident files.</div>
</div>
</body>
</html>
"@

# Write the HTML report.
Set-Content -Path $OutputPath -Value $html -Encoding UTF8 -Force

if (Test-Path -Path $OutputPath -PathType Leaf) {
    Write-Host "HTML report created successfully: $OutputPath" -ForegroundColor Green
} else {
    throw "Failed to create HTML report: $OutputPath"
}
