# Quick yesterday activity - 3 columns

$yesterday = (Get-Date).Date.AddDays(-1).ToString("yyyy-MM-dd")
Write-Host "Generating report for $yesterday ..."

# Output HTML directly
@"
<!DOCTYPE html>
<html>
<head>
<title>Team Yesterday $yesterday</title>
<style>
body { font-family: Arial; margin: 20px; background: #667eea; }
.container { background: white; padding: 20px; border-radius: 10px; }
table { width: 100%; border-collapse: collapse; }
th { background: #667eea; color: white; padding: 15px; text-align: left; }
td { padding: 15px; border-bottom: 1px solid #eee; vertical-align: top; }
.name { font-weight: bold; color: #667eea; width: 20%; }
.tasks { width: 50%; }
.branches { width: 30%; font-family: monospace; }
</style>
</head>
<body>
<div class="container">
<h1>Team Activity - $yesterday</h1>
<table>
<tr>
<th>Name</th>
<th>ClickUp Tasks</th>
<th>Branches & Commits</th>
</tr>
<tr>
<td class="name">Martien</td>
<td class="tasks">Example task<br/>Another task</td>
<td class="branches">main (5 commits)<br/>feature/test (2 commits)</td>
</tr>
</table>
</div>
</body>
</html>
"@ | Out-File "C:/temp/yesterday-simple.html" -Encoding UTF8

Write-Host "✅ Saved to C:/temp/yesterday-simple.html"
Start-Process "C:/temp/yesterday-simple.html"
