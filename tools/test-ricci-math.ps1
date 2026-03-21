# Test Ricci Flow Math - Debug floating point calculations

Write-Host "=== TESTING RICCI FLOW MATH ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Basic math
Write-Host "Test 1: Basic math" -ForegroundColor Yellow
$current = 1.0
$timestep = 0.05
$smoothing = 2 * $timestep * $current
$new = $current - $smoothing
Write-Host "  current: $current"
Write-Host "  timestep: $timestep"
Write-Host "  smoothing: $smoothing"
Write-Host "  new = current - smoothing: $new"
Write-Host "  with Max(0, ...): $([math]::Max(0, $new))"
Write-Host ""

# Test 2: From JSON
Write-Host "Test 2: From JSON" -ForegroundColor Yellow
$json = '{"value": 1.0}'
$obj = $json | ConvertFrom-Json
$val = $obj.value
Write-Host "  JSON value type: $($val.GetType().FullName)"
Write-Host "  JSON value: $val"
$smoothing2 = 2 * 0.05 * $val
$new2 = $val - $smoothing2
Write-Host "  smoothing: $smoothing2"
Write-Host "  new: $new2"
Write-Host ""

# Test 3: Actual thought-space
Write-Host "Test 3: From thought-space.json" -ForegroundColor Yellow
$ts = Get-Content 'C:\scripts\agentidentity\state\thought-space.json' | ConvertFrom-Json
$concept = $ts.concepts | Where-Object { $_.id -eq 'ricci_flow' }
Write-Host "  Concept found: $($concept -ne $null)"
Write-Host "  Curvature value: $($concept.local_curvature)"
Write-Host "  Curvature type: $($concept.local_curvature.GetType().FullName)"

$cur = $concept.local_curvature
$ts_val = 0.05
$ts_smooth = 2 * $ts_val * $cur
$ts_new = $cur - $ts_smooth
Write-Host "  Calculation: $cur - $ts_smooth = $ts_new"
Write-Host "  Type of result: $($ts_new.GetType().FullName)"
Write-Host ""

# Test 4: With type conversion
Write-Host "Test 4: Force double conversion" -ForegroundColor Yellow
$cur_double = [double]$concept.local_curvature
$ts_double = [double]0.05
$smooth_double = 2 * $ts_double * $cur_double
$new_double = $cur_double - $smooth_double
Write-Host "  current (double): $cur_double"
Write-Host "  smoothing (double): $smooth_double"
Write-Host "  new (double): $new_double"
Write-Host ""
