# Re-fetches the Ultimate Shitty List and re-embeds it into roulette.html
# Run with: powershell -File update-levels.ps1

$ErrorActionPreference = 'Stop'

Write-Output "Fetching levels from ultimateshittylist.fun..."
$res = Invoke-RestMethod -Uri "https://ultimateshittylist.fun/api/levels"
if ($res.message -ne 'success') { throw "API returned: $($res.message)" }

$slim = $res.data | ForEach-Object {
    [ordered]@{
        rank         = $_.rank
        name         = $_.name
        slug         = $_.slug
        creator      = $_.creator
        verifier     = $_.verifier
        category     = $_.category
        listPercent  = $_.listPercent
        thumbnailUrl = $_.thumbnailUrl
        youtubeUrl   = $_.youtubeUrl
        gdId         = $_.gdId
        description  = $_.description
    }
}
$json = $slim | ConvertTo-Json -Compress -Depth 3

$path = Join-Path $PSScriptRoot 'roulette.html'
$html = [System.IO.File]::ReadAllText($path)
# Replace the entire EMBEDDED_LEVELS line (the JSON is a single line)
$html = [regex]::Replace($html, 'const EMBEDDED_LEVELS = [^\r\n]*;', "const EMBEDDED_LEVELS = $json;")
[System.IO.File]::WriteAllText($path, $html)

Write-Output "Done — embedded $($slim.Count) levels into roulette.html"
