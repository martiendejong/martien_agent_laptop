$base = "https://artrevisionist.com/wp-json/wp/v2"

function Get-AllPosts($endpoint) {
    $all = @()
    $page = 1
    do {
        try {
            $response = Invoke-WebRequest -Uri "$base/$endpoint`?per_page=100&page=$page" -UseBasicParsing
            $data = $response.Content | ConvertFrom-Json
            $all += $data
            $page++
        } catch {
            break
        }
    } while ($data.Count -eq 100)
    return $all
}

Write-Host "=== TOPICS ==="
$topics = Get-AllPosts "b2bk_topic"
foreach ($t in $topics) { Write-Host "$($t.id): $($t.title.rendered) -> $($t.link)" }

Write-Host "`n=== TOPIC PAGES ==="
$pages = Get-AllPosts "b2bk_topic_page"
foreach ($t in $pages) { Write-Host "$($t.id): $($t.title.rendered) -> $($t.link)" }

Write-Host "`n=== DETAILS ==="
$details = Get-AllPosts "b2bk_detail"
foreach ($t in $details) { Write-Host "$($t.id): $($t.title.rendered) -> $($t.link)" }

Write-Host "`n=== PAGES ==="
$wpPages = Get-AllPosts "pages"
foreach ($t in $wpPages) { Write-Host "$($t.id): $($t.title.rendered) -> $($t.link)" }

Write-Host "`n=== POSTS ==="
$posts = Get-AllPosts "posts"
foreach ($t in $posts) { Write-Host "$($t.id): $($t.title.rendered) -> $($t.link) [status=$($t.status)]" }
