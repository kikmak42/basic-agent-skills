param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

$ErrorActionPreference = "Stop"

$uri = "https://api.duckduckgo.com/?q=[uri::EscapeDataString($Query)]&format=json&no_html=1&skip_disambig=1"
try {
    $response = Invoke-WebRequest -Uri $uri -UseBasicParsing
    $json = $response.Content | ConvertFrom-Json
    if ($json.AbstractText) {
        Write-Output $json.AbstractText
    } elseif ($json.RelatedTopics.Count -gt 0) {
        Write-Output $json.RelatedTopics[0].Text
    } else {
        Write-Output "No results found."
    }
} catch {
    Write-Error "Failed to fetch search results: $_"
}
