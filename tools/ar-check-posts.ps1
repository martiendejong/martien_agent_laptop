$base = "https://artrevisionist.com/wp-json/wp/v2/posts"
$response = Invoke-WebRequest -Uri "$base`?per_page=10&orderby=date&order=asc" -UseBasicParsing
$posts = $response.Content | ConvertFrom-Json

Write-Host "=== Published Posts ==="
foreach ($p in $posts) {
    Write-Host "$($p.id): [$($p.status)] $($p.date) - $($p.title.rendered)"
    Write-Host "   URL: $($p.link)"
}

Write-Host "`nTotal: $($posts.Count) published posts"
Write-Host "`nNote: Scheduled (future) posts require authentication to view via REST API."
Write-Host "Post 1 was scheduled for Feb 10 09:00 - it should auto-publish tomorrow."
